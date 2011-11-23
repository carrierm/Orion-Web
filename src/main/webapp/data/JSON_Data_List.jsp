<%@ page language="java" %> 
<%@ page pageEncoding="UTF-8" %> 
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, java.sql.*, java.io.*, javax.naming.*" %>
<%@ page import="net.sf.json.JSONObject" %>
<%@ page import="net.sf.json.JSONArray" %>

<%
	boolean retValue = true;
   	final String databaseURL = "jdbc:postgresql://localhost:7443/postgis";
	final String schema = "public";
	final String userName = "";
	final String password = "";
	
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	JSONArray array = new JSONArray();
	
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
	
	try {
		if (conn != null) {
			stmt = conn.createStatement();	
		
			String queryStmt = "SELECT DISTINCT ON (cr.CR_KEY) cr.CR_KEY, cr.CR_NAME, cr.CR_PRIORITY, cr.RESP_ORG, cr.START_DATETIME, cr.STOP_DATETIME FROM \"" + schema + "\".COLLECTION_REQUIREMENT_GEO cr";
			rs = stmt.executeQuery(queryStmt);
		
			JSONArray jsonObj;
			while (rs.next()) {
				jsonObj = new JSONArray();
				
				jsonObj.add(getNonNullResultString(rs.getString("cr_key")));
				jsonObj.add(getNonNullResultString(rs.getString("cr_name")));
				jsonObj.add(getNonNullResultString(rs.getString("cr_priority")));
				jsonObj.add(getNonNullResultString(rs.getString("resp_org")));
				jsonObj.add(getNonNullResultString(rs.getString("start_datetime")));
				jsonObj.add(getNonNullResultString(rs.getString("stop_datetime")));
			
				array.add(jsonObj);
			}
		} else {
			Random rand = new Random();
			JSONArray jsonObj;
			for (int index=0; index<25; index++) {
				jsonObj = new JSONArray();
				
				jsonObj.add("cr key " + index);
				jsonObj.add("cr name " + index);
				jsonObj.add(rand.nextInt());
				jsonObj.add("responsible org");
				jsonObj.add("start date");
				jsonObj.add("stop date");
			
				array.add(jsonObj);
			}
		}
	} catch (Exception ex) {
		ex.printStackTrace();
	}

	out.println(array.toString());
%>

<%!
public static String getNonNullResultString(String stringToAdd) {
	if ( stringToAdd == null ) {
		stringToAdd = "";
	}
	return stringToAdd;
}
%>