<%@ page language="java" %> 
<%@ page pageEncoding="UTF-8" %> 
<%@ page contentType="text/html; charset=UTF-8" %>

<%@ page import="java.util.*, java.sql.*, org.postgresql.util.PSQLException" %>
<%@ page import="net.sf.json.JSONObject" %>
<%@ page import="net.sf.json.JSONArray" %>

<%! 
	private static String className = "JSON_CR_Rollup.jsp";
	private static String userName = "";
	private static String dn_key = "";
%>
<%
	final String databaseURL = "jdbc:postgresql://localhost:7443/postgis";
	final String schema = "public";
	final String userName = "";
	final String password = "";
	
	final String NOT_TASKED 	= "NOT TASKED";
	final String UNTASKED		= "UNTASKED";
	final String UNFULFILLED 	= "UNFULFILLED";
	final String ACCOMPLISHED 	= "ACCOMPLISHED";
	
	JSONArray array = new JSONArray();
	boolean retValue = true;
	
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	ResultSetMetaData rsmd = null;

	try {
		Class.forName("org.postgresql.Driver");
	} catch (ClassNotFoundException cnfe) {
		retValue = false;
		System.out.println("Couldn't find the driver!");
		cnfe.printStackTrace();
		System.exit(1);
	}
	try {
		conn = DriverManager.getConnection(databaseURL, userName, password);
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
				queryStmt = "SELECT COCOM AS \"name\" FROM \"" + schema + "\".TARGET_COLLECTION_REQUEST tcr WHERE TO_CHAR(tcr.NEXT_DUE, 'YYYY-MM-DD') = " + sql_date + " GROUP BY COCOM ORDER BY COCOM";
				
				generateServerLogInfoMessage("queryStmt: " + queryStmt);
				if (!"".equals(queryStmt)) {
					rs = stmt.executeQuery(queryStmt);
				}
				
				JSONArray jsonObj;
				while (rs.next()) {
					String name = rs.getString("NAME");
					
					jsonObj = new JSONArray(); 
					jsonObj.add(name);
					jsonObj.add(Math.floor(Math.max((Math.random() * 100), 20)));
					jsonObj.add(Math.floor(Math.max((Math.random() * 100), 20)));
					jsonObj.add(Math.floor(Math.max((Math.random() * 100), 20)));
					array.add(jsonObj);
				}
			} catch (PSQLException psqlEx) {
				generateServerLogErrorMessage("PSQLException running query: " + queryStmt);
				psqlEx.printStackTrace();
			} catch (Exception ex) {
				generateServerLogErrorMessage("exception running query: " + queryStmt);
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