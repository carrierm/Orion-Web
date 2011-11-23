<%@ page contentType="text/html; charset=UTF-8" %>
<%@page import="java.io.*, java.util.*, java.text.*"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*,org.postgresql.util.PSQLException" %>
<%@ page import="java.security.cert.X509Certificate, java.security.Principal, javax.security.auth.x500.X500Principal" %>
<%@ page import="java.security.cert.CertificateExpiredException" %>
<%@ page import="java.security.cert.CertificateNotYetValidException" %>

<%!
	private static String userName = "";
	private static String dn_key = "";
	private static String className = "common.jsp";
%>

<%
	final String database_schema = "public";
               
	// Server Protocol, Scheme
	String scheme = request.getScheme();
               
	// Server Host Name
	String serverName = request.getServerName();
               
	// Server Port Number
	int portNumber = request.getServerPort();
               
	// Application Context Name
	String contextPath = request.getContextPath();
	String servletPath = request.getServletPath();
	String pathInfo = request.getPathInfo();
	String query = request.getQueryString();
	
	String serverContextPath = scheme + "://" + serverName + ":" + portNumber + contextPath;
	String serverJSPPath = serverContextPath + "/jsp";
	String serverScriptsPath = serverContextPath + "/scripts";
	String serverImagesPath = serverContextPath + "/images";
	String serverKMLPath = serverContextPath + "/kml";
	String serverStylesPath = serverContextPath + "/styles";
	String serverExtPath = serverContextPath + "/ext-3.4.0";
	String serverExt402aPath = serverContextPath + "/ext-4.0.2a";
	String serverDataPath = serverContextPath + "/data";
	//mapServer = "http://vmap0.tiles.osgeo.org/wms/vmap0";
	//String mapServer1 = "http://vmap0.tiles.osgeo.org/wms/vmap0";
    //String mapTileLayer = "basic";
	//String mapServer1 = "http://localhost:8081/geoserver/VMAP/wms";
%>

<script type="text/javascript">
	var serverContextPath = "<%= serverContextPath%>";
	var serverScriptsPath = "<%= serverScriptsPath%>";
	var serverImagesPath = "<%= serverImagesPath%>";
	var serverKMLPath = "<%= serverKMLPath%>";
	var serverStylesPath = "<%= serverStylesPath%>";
	var serverDataPath = "<%= serverDataPath%>";
	
	formatLatLongDMS = function(coordinate) {
		var coords = new Array();
		var formattedString;
		
		abscoordinate = Math.abs(coordinate)
		coordinatedegrees = Math.floor(abscoordinate);
		coordinateminutes = (abscoordinate - coordinatedegrees)/(1/60);
		tempcoordinateminutes = coordinateminutes;
		coordinateminutes = Math.floor(coordinateminutes);
		coordinateseconds = (tempcoordinateminutes - coordinateminutes)/(1/60);
		coordinateseconds =  Math.round(coordinateseconds*10);
		coordinateseconds /= 10;
		
		if( coordinatedegrees < 10 ) {
		  	coordinatedegrees = "0" + coordinatedegrees;
		}
		
		if( coordinateminutes < 10 ) {
			coordinateminutes = "0" + coordinateminutes;
		}
		
		if( coordinateseconds < 10 ) {
			coordinateseconds = "0" + coordinateseconds;
		}
		coords[0] = coordinatedegrees + "&deg;";
		coords[1] = coordinateminutes + "&rsquo;";
		coords[2] = coordinateseconds + "&rdquo;";
		formattedString = coords[0]+ "&nbsp;" + coords[1]+ "&nbsp;" + coords[2];
		
		return formattedString;
	}
</script>

<%!
	public static void generateServerLogInfoMessage(String message) {
		String logMessage = generateLogMessage(message);
		//if (log != null) {
		//	log.info(logMessage);
		//} else {
		//	if (displayLogging) {
				System.out.println(logMessage);
		//	}
		//}
	}
	
	public static void generateServerLogErrorMessage(String message) {
		String logMessage = generateLogMessage(message);
		//if (log != null) {
		//	log.error(logMessage);
		//} else {
			System.err.println(logMessage);
		//}
	}
	
	public static String generateLogMessage(String message) {		
		String logMessage = "[UserName: " + userName + "] [" + "DN_KEY: " + dn_key + "] [Class: " + className + "] " + message;
		return logMessage;
	}
%>