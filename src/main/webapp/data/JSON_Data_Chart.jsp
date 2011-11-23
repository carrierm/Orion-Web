<%@ page language="java" %> 
<%@ page pageEncoding="UTF-8" %> 
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, java.sql.*, java.io.*, javax.naming.*, org.postgresql.util.PSQLException" %>
<%@ page import="net.sf.json.JSONObject" %>
<%@ page import="net.sf.json.JSONArray" %>

<%! 
	private static String className = "JSON_CR_Rollup.jsp";
	private static String userName = "";
	private static String dn_key = "";
%>
<%
	boolean retValue = true;
	final String schema = "public";
	String connectionURL 	= "";
	String driverClass 		= "";
	String userName 		= "";
	String password 		= "";
	
	final String NOT_TASKED 	= "NOT TASKED";
	final String UNTASKED		= "UNTASKED";
	final String UNFULFILLED 	= "UNFULFILLED";
	final String ACCOMPLISHED 	= "ACCOMPLISHED";
	
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	JSONArray array = new JSONArray();
	
	InputStream in = this.getClass().getResourceAsStream("/jdbc.properties");
	System.out.println("in: " + in);
	
	Properties jdbcProperties = new Properties();
	if (in != null) {
		jdbcProperties.load(in);
	}
	
	// Retrieve jdbc connection properties from WEB-INF/classes/jdbc.properties
	if (jdbcProperties != null) {
		connectionURL = jdbcProperties.getProperty("connectionURL");
		driverClass = jdbcProperties.getProperty("driverClass");
		userName = jdbcProperties.getProperty("userName");
		password = jdbcProperties.getProperty("password");
	} else {
		System.out.println("check jdbc properties");
	}
	
	try {
		if (!"".equals(driverClass.trim())) {
			Class.forName(driverClass);
		} else {
			System.out.println("Couldn't find the driver! - empty configuration value");
		}
	} catch (ClassNotFoundException cnfe) {
		retValue = false;
		System.out.println("Couldn't find the driver!");
		cnfe.printStackTrace();
		System.exit(1);
	}
	try {
		if ("".equals(connectionURL.trim())) {
			System.out.println("check connection url value");
		}
		if ("".equals(userName.trim())) {
			System.out.println("check userName value");
		}
		if ("".equals(password.trim())) {
			System.out.println("check password value");
		}
		conn = DriverManager.getConnection(connectionURL, userName, password);
	} catch (SQLException se) {
		retValue = false;
		System.out.println("Couldn't connect");
		se.printStackTrace();
	}
	
	String queryStmt = "";
	int numberOfCriteria = 0;
	if (retValue) {
		if (conn != null) {
			try {
				stmt = conn.createStatement();

				String sql_date = "";
				sql_date = "TO_CHAR(current_date, 'YYYY-MM-DD')";
				
				String displayName = "";
				queryStmt = "SELECT COCOM AS \"name\", STATUS_ROLLUP, COUNT(*) FROM \"" + schema + "\".TARGET_COLLECTION_REQUEST tcr WHERE TO_CHAR(tcr.NEXT_DUE, 'YYYY-MM-DD') = " + sql_date + " GROUP BY COCOM, STATUS_ROLLUP ORDER BY COCOM, STATUS_ROLLUP";	
				
				generateServerLogInfoMessage("queryStmt: " + queryStmt);
				if (!"".equals(queryStmt)) {
					rs = stmt.executeQuery(queryStmt);
				}
				
				LinkedHashMap<String, LinkedHashMap<String, String>> hmap = new LinkedHashMap<String, LinkedHashMap<String, String>>();
				
				while (rs.next()) {
					String name = rs.getString("NAME");
					
					String status_rollup = rs.getString("STATUS_ROLLUP");
					String count = rs.getString("COUNT");
					
					if (NOT_TASKED.equalsIgnoreCase(status_rollup)) {
						status_rollup = UNTASKED;
					}

					if (hmap.containsKey(name)) {
						LinkedHashMap<String, String> map = (LinkedHashMap<String, String>) hmap.get(name);
						map.put(status_rollup, count);
					} else {
						LinkedHashMap<String, String> map = new LinkedHashMap<String, String>();
						map.put(status_rollup, count);
						hmap.put(name, map);
					}
				}
				Set entrySet = hmap.keySet();
				Iterator iter = entrySet.iterator();
				while (iter.hasNext()) {
					String name = (String)iter.next();
					LinkedHashMap<String, String>  map = (LinkedHashMap) hmap.get(name);
					if (!map.isEmpty()) {
						JSONArray jsonObj = new JSONArray(); 
						jsonObj.add(name);

						if (map.containsKey(UNTASKED)) {
							jsonObj.add(map.get(UNTASKED));
						} else {
							jsonObj.add("0");
						}
						
						if (map.containsKey(UNFULFILLED)) {
							jsonObj.add(map.get(UNFULFILLED));
						} else {
							jsonObj.add("0");
						}
						if (map.containsKey(ACCOMPLISHED)) {
							jsonObj.add(map.get(ACCOMPLISHED));
						} else {
							jsonObj.add("0");
						}
						array.add(jsonObj);
					}
				}
			} catch (PSQLException psqlEx) {
				generateServerLogErrorMessage("PSQLException running query: " + queryStmt);
				retValue = false;
				psqlEx.printStackTrace();
			} catch (Exception ex) {
				generateServerLogErrorMessage("exception running query: " + queryStmt);
				retValue = false;
				ex.printStackTrace();
			}
		}
	}

	if (conn != null) {
		conn.close();
	}
	generateServerLogInfoMessage("array: " + array.toString());
	out.println(array.toString());
%>

<%!
	public static void generateServerLogInfoMessage(String message) {
		String logMessage = generateLogMessage(message);
		System.out.println(logMessage);
	}
	
	public static void generateServerLogErrorMessage(String message) {
		String logMessage = generateLogMessage(message);
		System.err.println(logMessage);
	}
	
	public static String generateLogMessage(String message) {
		String logMessage = "[UserName: " + userName + "] [" + "DN_KEY: " + dn_key + "] [Class: " + className + "] " + message;
		return logMessage;
	}
%>