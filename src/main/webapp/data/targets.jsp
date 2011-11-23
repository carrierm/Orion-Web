<%@ page language="java"%>
<%@ page pageEncoding="UTF-8"%>
<%@ page contentType="text/html; charset=UTF-8"%>

<%@page import="java.io.*, java.util.*, java.text.*"%>
<%@page import="java.sql.*, javax.sql.*, javax.naming.*"%>

<%@page import="javax.xml.transform.*, javax.xml.transform.dom.*, javax.xml.transform.stream.*, org.w3c.dom.*"%>

<%@page import="javax.xml.parsers.DocumentBuilderFactory"%>
<%@page import="javax.xml.parsers.DocumentBuilder"%>
<%@page import="org.apache.xerces.jaxp.DocumentBuilderFactoryImpl"%>
<%@page import="org.apache.xerces.jaxp.DocumentBuilderImpl"%>
<%@page import="org.apache.xml.serialize.XMLSerializer"%>
<%@page import="org.apache.xml.serialize.OutputFormat"%>
<%@page import="org.xml.sax.InputSource"%>

<%!
	final String schema = "public";
	private static String userName = "";
	private static String dn_key = "";
	private static String className = "Targets.jsp";
%>
<% 
	Document xmlDoc  = null;
	Element main;
	Element root;
	Element item;
	//String xmlStr = null;
	DataSource ds = null;
	Connection conn = null;
	ResultSet pointResult = null;
	ResultSet polylineResult = null;
	ResultSet polygonResult = null;
	Statement stmt = null;
	Statement polylineStmt = null;
	Statement polygonStmt = null;
	ResultSetMetaData rsmd = null;
	
	String requestSource = null;
	String requestType = null;
	String destination = null;
	String type=null;
	String value=null;
	String latString=null;
	String longString=null;
	String crList = null;
	String targetList = null;
	String cocom = null;
	String country = null;
	String cocomCode = null;
	String countryCode = null;
	String polygonValue = null;
	boolean containsMapData = false;
	
	requestSource = request.getParameter("SOURCE");
	requestType = request.getParameter("TYPE");
	destination = request.getParameter("DESTINATION");
	
	if (destination != null) {
		destination = destination.substring(1, destination.length()-1);
	}
	final String OPEN_LAYERS_DISPLAY_MAP = "OPEN_LAYERS_DISPLAY_MAP";
	final String GOOGLE_EARTH_DISPLAY_MAP = "GOOGLE_EARTH_DISPLAY_MAP";
	final String WORLD_WIND_DISPLAY_MAP = "WORLD_WIND_DISPLAY_MAP";
	
	final String databaseURL = "jdbc:postgresql://localhost:7443/postgis";
	final String schema = "public";
	final String userName = "";
	final String password = "";
	
	if(requestSource!=null && (requestSource.equals("NAVIGATION_MAP")) || (requestSource.equals("DISPLAY_MAP") || requestSource.equals("CR_LIST") || requestSource.equals("TARGET_LIST")) ) {
	
		try {
			if(requestType != null && requestType.equals("COCOM") ) {
				cocomCode = request.getParameter("COCOMVAL");
			} else if(requestType != null && requestType.equals("COUNTRY")) {
				countryCode = request.getParameter("COUNTRYCODE");
			} else if(requestType != null && requestType.equals("POLYGON")) {
				polygonValue = request.getParameter("POLYGON");
			}
			
			if (request.getParameter("TYPE") != null) {
				type = request.getParameter("TYPE");
				type = type.substring(1, type.length()-1);
			}
	
			if (request.getParameter("VALUE") != null) {
				value = request.getParameter("VALUE");
				value = value.substring(1, value.length()-1);
			}
			
			if ("COCOM".equals(type)) {
				value = request.getParameter("COCOMVAL");
				value = value.substring(1, value.length()-1);
			}
			if ("COUNTRY".equals(type)) {
				value = request.getParameter("COUNTRYCODE");
				value = value.substring(1, value.length()-1);
			}
			if ("POLYGON".equals(type)) {
				value = request.getParameter("POLYGON");
				value = value.substring(1, value.length()-1);
			}
	
			if (request.getParameter("CRLIST") != null) {
				crList = request.getParameter("CRLIST");
				crList = crList.substring(1, crList.length()-1);
				
				String[] arrSelectedCRs = crList.split(",");
				crList = "";
				for (int i=0; i<arrSelectedCRs.length; i++) {
					crList += "'" + arrSelectedCRs[i] + "'";
					if (i != arrSelectedCRs.length - 1) {
						crList += ", ";
					}
				}
			}
			if (request.getParameter("TARGETLIST") != null) {
				targetList = request.getParameter("TARGETLIST");
				targetList = targetList.substring(1, targetList.length()-1);
				
				String[] arrSelectedTargets = targetList.split(",");
				targetList = "";
				for (int i=0; i<arrSelectedTargets.length; i++) {
					targetList += "'" + arrSelectedTargets[i] + "'";	
					if (i != arrSelectedTargets.length - 1) {
						targetList += ", ";
					}
				}
			}
			
			DocumentBuilderFactory dbFactory = DocumentBuilderFactoryImpl.newInstance();
		    DocumentBuilder docBuilder = dbFactory.newDocumentBuilder();
		    xmlDoc = docBuilder.newDocument();

			try {
				Class.forName("org.postgresql.Driver");
			} catch (ClassNotFoundException cnfe) {
				System.out.println("Couldn't find the driver!");
				cnfe.printStackTrace();
				System.exit(1);
			}
			try {
				conn = DriverManager.getConnection(databaseURL, userName, password);
			} catch (SQLException se) {
				System.out.println("Couldn't connect");
				se.printStackTrace();
			}
			
			try {
				if (conn != null) {
					stmt = conn.createStatement();
					polylineStmt = conn.createStatement();
					polygonStmt = conn.createStatement();
					
					String pointResultQuery = "SELECT DISTINCT ON (tcr.TARGET_KEY) tcr.TARGET_KEY, tcr.TARGET_NAME, tcr.TARGET_ID, ST_AsKML(tcr.GEO_SEARCH_REF) FROM \"" + schema + "\".TARGET_COLLECTION_REQUEST tcr WHERE tcr.TARGET_TYPE = 'P'";
					if ("CRLIST".equals(type) && value != null){
						pointResultQuery += " AND tcr.CR_KEY IN (" + value + ")";
					} else if ("TARGETLIST".equals(type) && value != null){
						pointResultQuery += " AND tcr.TARGET_KEY IN (" + value + ")";
					} else if ("COCOM".equals(type) && value != null) {
						pointResultQuery += " AND UPPER(tcr.COCOM) = UPPER('" + value + "')";
					} else if ("COUNTRY".equals(type) && value != null) {
						pointResultQuery += " AND UPPER(tcr.COUNTRY) = UPPER('" + value + "')";
					} else if ("POLYGON".equals(type) && value != null) {
						pointResultQuery += " AND ST_INTERSECTS( tcr.GEO_SEARCH_REF, ST_GeographyFromText('" + value + "') )";
					}
					
					generateServerLogInfoMessage("pointResultQuery: " + pointResultQuery);
					pointResult = stmt.executeQuery(pointResultQuery);
				
					String polylineResultQuery = "SELECT DISTINCT ON (tcr.TARGET_KEY) tcr.TARGET_KEY, tcr.TARGET_NAME, tcr.TARGET_ID, ST_AsKML(tcr.GEO_SEARCH_REF) FROM \"" + schema + "\".TARGET_COLLECTION_REQUEST tcr WHERE tcr.TARGET_TYPE = 'L'";
					if ("CRLIST".equals(type) && value != null){
						polylineResultQuery += " AND tcr.CR_KEY IN (" + value + ")";
					} else if ("TARGETLIST".equals(type) && value != null){
						polylineResultQuery += " AND tcr.TARGET_KEY IN (" + value + ")";
					} else if ("COCOM".equals(type) && value != null) {
						polylineResultQuery += " AND UPPER(tcr.COCOM) = UPPER('" + value + "')";
					} else if ("COUNTRY".equals(type) && value != null) {
						polylineResultQuery += " AND UPPER(tcr.COUNTRY) = UPPER('" + value + "')";
					} else if ("POLYGON".equals(type) && value != null) {
						polylineResultQuery += " AND ST_INTERSECTS( tcr.GEO_SEARCH_REF, ST_GeographyFromText('" + value + "') )";
					}
					generateServerLogInfoMessage("polylineResultQuery: " + polylineResultQuery);
					polylineResult = polylineStmt.executeQuery(polylineResultQuery);
				
					String polygonResultQuery = "SELECT DISTINCT ON (tcr.TARGET_KEY) tcr.TARGET_KEY, tcr.TARGET_NAME, tcr.TARGET_ID, ST_AsKML(tcr.GEO_SEARCH_REF) FROM \"" + schema + "\".TARGET_COLLECTION_REQUEST tcr WHERE tcr.TARGET_TYPE IN ('A', 'R', 'D')";
					if ("CRLIST".equals(type) && value != null){
						polygonResultQuery += " AND tcr.CR_KEY IN (" + value + ")";
					} else if ("TARGETLIST".equals(type) && value != null){
						polygonResultQuery += " AND tcr.TARGET_KEY IN (" + value + ")";
					} else if ("COCOM".equals(type) && value != null) {
						polygonResultQuery += " AND UPPER(tcr.COCOM) = UPPER('" + value + "')";
					} else if ("COUNTRY".equals(type) && value != null) {
						polygonResultQuery += " AND UPPER(tcr.COUNTRY) = UPPER('" + value + "')";
					} else if ("POLYGON".equals(type) && value != null) {
						polygonResultQuery += " AND ST_INTERSECTS( tcr.GEO_SEARCH_REF, ST_GeographyFromText('" + value + "') )";
					}
					generateServerLogInfoMessage("polygonResultQuery: " + polygonResultQuery);
					polygonResult = polygonStmt.executeQuery(polygonResultQuery);
				}
			} catch (Exception ex) {
				ex.printStackTrace();
			}
			   
			root = xmlDoc.createElement("kml");
			root.setAttribute("xmlns", "http://www.opengis.net/kml/2.2");
			root.setAttribute("xmlns:gx", "http://www.google.com/kml/ext/2.2");
			xmlDoc.appendChild(root);
			
			Element docElement = xmlDoc.createElement("Document");
			root.appendChild(docElement);    
		
			Element docNameEle = xmlDoc.createElement("name");
			docElement.appendChild(docNameEle);
			docNameEle.appendChild(xmlDoc.createTextNode("Target Locations"));        
		
			Element docDescEle = xmlDoc.createElement("description");
			docElement.appendChild(docDescEle);
			docDescEle.appendChild(xmlDoc.createTextNode("Target Locations"));  
			
			if (OPEN_LAYERS_DISPLAY_MAP.equalsIgnoreCase(destination)) {
				// Style for Point Marker
				Element styleElement = xmlDoc.createElement("Style");
				docElement.appendChild(styleElement);
				styleElement.setAttribute("id", "pointMarker");
				
				Element iconStyleElement = xmlDoc.createElement("IconStyle");
				styleElement.appendChild(iconStyleElement);
				
				Element scaleElement = xmlDoc.createElement("scale");
				iconStyleElement.appendChild(scaleElement);
				scaleElement.appendChild(xmlDoc.createTextNode("0.5"));
				
				Element iconElement = xmlDoc.createElement("Icon");
				iconStyleElement.appendChild(iconElement);
				
				Element hrefElement = xmlDoc.createElement("href");
				iconElement.appendChild(hrefElement);
				hrefElement.appendChild(xmlDoc.createTextNode("../images/marker.png"));
			
				// LineString Style
				Element styleLSElement = xmlDoc.createElement("Style");
				docElement.appendChild(styleLSElement);
				styleLSElement.setAttribute("id", "blueLSStyle");
				
				Element iconStyleLSElement = xmlDoc.createElement("IconStyle");
				styleLSElement.appendChild(iconStyleLSElement);
				
				Element scaleLSElement = xmlDoc.createElement("scale");
				iconStyleLSElement.appendChild(scaleLSElement);
				scaleLSElement.appendChild(xmlDoc.createTextNode("0.5"));
				
				Element iconLSElement = xmlDoc.createElement("Icon");
				iconStyleLSElement.appendChild(iconLSElement);
				
				Element hrefLSElement = xmlDoc.createElement("href");
				iconLSElement.appendChild(hrefLSElement);
				hrefLSElement.appendChild(xmlDoc.createTextNode("../images/marker-blue.png"));
				
				Element lineStyleElement = xmlDoc.createElement("LineStyle");
				styleLSElement.appendChild(lineStyleElement);
				
				Element colorLSElement = xmlDoc.createElement("color");
				lineStyleElement.appendChild(colorLSElement);
				colorLSElement.appendChild(xmlDoc.createTextNode("#000099"));
				
				Element widthLSElement = xmlDoc.createElement("width");
				lineStyleElement.appendChild(widthLSElement);
				widthLSElement.appendChild(xmlDoc.createTextNode("2"));
				
				// Polygon Style
				Element stylePolygonElement = xmlDoc.createElement("Style");
				docElement.appendChild(stylePolygonElement);
				stylePolygonElement.setAttribute("id", "greenPolygonStyle");
				
				Element iconStylePolygonElement = xmlDoc.createElement("IconStyle");
				stylePolygonElement.appendChild(iconStylePolygonElement);
				
				Element scalePolygonElement = xmlDoc.createElement("scale");
				iconStylePolygonElement.appendChild(scalePolygonElement);
				scalePolygonElement.appendChild(xmlDoc.createTextNode("0.5"));
				
				Element iconPolygonElement = xmlDoc.createElement("Icon");
				iconStylePolygonElement.appendChild(iconPolygonElement);
				
				Element hrefPolygonElement = xmlDoc.createElement("href");
				iconPolygonElement.appendChild(hrefPolygonElement);
				hrefPolygonElement.appendChild(xmlDoc.createTextNode("../images/marker-green.png"));
				
				Element polygonStyleElement = xmlDoc.createElement("LineStyle");
				stylePolygonElement.appendChild(polygonStyleElement);
				
				Element colorPolygonElement = xmlDoc.createElement("color");
				polygonStyleElement.appendChild(colorPolygonElement);
				colorPolygonElement.appendChild(xmlDoc.createTextNode("#000099"));
				
				Element widthPolygonElement = xmlDoc.createElement("width");
				polygonStyleElement.appendChild(widthPolygonElement);
				widthPolygonElement.appendChild(xmlDoc.createTextNode("2"));
			}
			Element folderPointEle = xmlDoc.createElement("Folder");
			docElement.appendChild(folderPointEle);
			
			final double LONGITUDE_MIN = -180.0;
			final double LONGITUDE_MAX = 180.0;
			final double LATITUDE_MIN = -90.0;
			final double LATITUDE_MAX = 90.0;
			
			double eastBoundary = LONGITUDE_MIN;
			double westBoundary = LONGITUDE_MAX;
			double northBoundary = LATITUDE_MIN;
			double southBoundary = LATITUDE_MAX;
			
			// Point
			while (pointResult.next()) {
				
				if (!containsMapData) {
					containsMapData = true;
				}
				String xmlStr=null;
				String target_key = pointResult.getString(1);
				String target_name = pointResult.getString(2);
				String target_id = pointResult.getString(3);
				xmlStr = pointResult.getString(4);
				
				Document doc1 = docBuilder.parse(new ByteArrayInputStream(xmlStr.getBytes())); 		
				NodeList pNode = doc1.getElementsByTagName("Point");
				
				Document pointDoc = docBuilder.parse(new ByteArrayInputStream(xmlStr.getBytes())); 		
				NodeList pointNode = pointDoc.getElementsByTagName("Polygon");
				
				for (int i = 0; i < pointNode.getLength(); i++) {
					Element element = (Element) pointNode.item(i);
		
					Element placemarkEle = xmlDoc.createElement("Placemark");
					folderPointEle.appendChild(placemarkEle);
		
					Element nameElement = xmlDoc.createElement("name");
					nameElement.appendChild(xmlDoc.createTextNode("Target Name: " + target_name));
					placemarkEle.appendChild(nameElement);
					
					NodeList name = element.getElementsByTagName("coordinates");
					Element line = (Element) name.item(0);
					String targetCoordinates = getCharacterDataFromElement(line);
					
					String[] arrCoords = targetCoordinates.split(" ");
					for (int index=0; index<arrCoords.length; index++) {
						String nextCoordinates = arrCoords[index];
						String[] coords = nextCoordinates.split(",");
						String latitude = coords[0].trim();
						String longitude = coords[1].trim();
						
						double dblLatitude = Double.valueOf(latitude);
						double dblLongitude = Double.valueOf(longitude);
						
						if (dblLatitude > eastBoundary) {
							eastBoundary = dblLatitude;
						}
						if (dblLatitude < westBoundary) {
							westBoundary = dblLatitude;
						}
						if (dblLongitude < southBoundary) {
							southBoundary = dblLongitude;
						}
						if (dblLongitude > northBoundary) {
							northBoundary = dblLongitude;
						}
						
						if (index == 0) {
							Element placemarkPolygonPointEle = xmlDoc.createElement("Placemark");
							folderPointEle.appendChild(placemarkPolygonPointEle);
				
							Element namePolygonPointElement = xmlDoc.createElement("name");
							namePolygonPointElement.appendChild(xmlDoc.createTextNode("Target Name: " + target_name));
							placemarkPolygonPointEle.appendChild(namePolygonPointElement);
							
							String polygonPointDescriptionText = "";
							if (OPEN_LAYERS_DISPLAY_MAP.equalsIgnoreCase(destination)) {
								polygonPointDescriptionText = "<h3>Target ID: " + target_id + "</h3><p><b>Latitude: </b>" + latitude + "</p><p><b>Longitude: </b>" + longitude + "</p><div width=\"100%\" align=\"center\"><img src=\"../images/details.gif\" onclick=\"javascript:getAllTargetWidgetDetails({target_key:'" + target_key + "'});\"/></div>";
							} else {
								polygonPointDescriptionText = "<details><target_key>" + target_key + "</target_key><target_id>" + target_id + "</target_id><latitude>" + latitude + "</latitude><longitude>" + longitude + "</longitude></details>";
							}
							Element descriptionPolygonPointElement = xmlDoc.createElement("description");
							descriptionPolygonPointElement.appendChild(xmlDoc.createTextNode(polygonPointDescriptionText));
							placemarkPolygonPointEle.appendChild(descriptionPolygonPointElement);
							
							Element stylePolygonPointURLElement = xmlDoc.createElement("styleUrl");
							placemarkPolygonPointEle.appendChild(stylePolygonPointURLElement);
							stylePolygonPointURLElement.appendChild(xmlDoc.createTextNode("#greenPolygonStyle"));  
							
							Element pointPolygonPointElement = xmlDoc.createElement("Point");
							placemarkPolygonPointEle.appendChild(pointPolygonPointElement);
					
							Element coordPolygonPointElement = xmlDoc.createElement("coordinates");
							pointPolygonPointElement.appendChild(coordPolygonPointElement);
							coordPolygonPointElement.appendChild(xmlDoc.createTextNode( nextCoordinates ));
						}
					}
					/* String[] coords = targetCoordinates.split(" ");
					String latitude = coords[0].trim();
					String longitude = coords[1].trim();
					
					double dblLatitude = Double.valueOf(latitude);
					double dblLongitude = Double.valueOf(longitude);
					
					if (dblLatitude > eastBoundary) {
						eastBoundary = dblLatitude;
					}
					if (dblLatitude < westBoundary) {
						westBoundary = dblLatitude;
					}
					if (dblLongitude < southBoundary) {
						southBoundary = dblLongitude;
					}
					if (dblLongitude > northBoundary) {
						northBoundary = dblLongitude;
					} */
					
					/* String descriptionText = "";
					if (OPEN_LAYERS_DISPLAY_MAP.equalsIgnoreCase(destination)) {
						descriptionText = "<h3>Target ID: " + target_id + "</h3><p><b>Latitude: </b>" + latitude + "</p><p><b>Longitude: </b>" + longitude + "</p><div width=\"100%\" align=\"center\"><img src=\"../images/details.gif\" onclick=\"javascript:getAllTargetWidgetDetails({target_key:'" + target_key + "'});\"/></div>";
					} else {
						descriptionText = "<details><target_key>" + target_key + "</target_key><target_id>" + target_id + "</target_id><latitude>" + latitude + "</latitude><longitude>" + longitude + "</longitude></details>";
					}
					Element descriptionElement = xmlDoc.createElement("description");
					descriptionElement.appendChild(xmlDoc.createTextNode(descriptionText));
					placemarkEle.appendChild(descriptionElement);
					
					Element styleURLElement = xmlDoc.createElement("styleUrl");
					placemarkEle.appendChild(styleURLElement);
					styleURLElement.appendChild(xmlDoc.createTextNode("#pointMarker"));  
					
					Element pointElement = xmlDoc.createElement("Point");
					placemarkEle.appendChild(pointElement);
			
					Element coordElement = xmlDoc.createElement("coordinates");
					pointElement.appendChild(coordElement);
					coordElement.appendChild(xmlDoc.createTextNode( targetCoordinates )); */
				}
			}
	
			Element folderLineStrEle = xmlDoc.createElement("Folder");
			docElement.appendChild(folderLineStrEle);
			
			// LineString
			while (polylineResult.next()) {
				if (!containsMapData) {
					containsMapData = true;
				}
				String xmlLineStr=null;
				String target_key = polylineResult.getString(1);
				String target_name = polylineResult.getString(2);
				String target_id = polylineResult.getString(3);
				xmlLineStr = polylineResult.getString(4);
				
				//Document lineStringDoc = docBuilder.parse(new ByteArrayInputStream(xmlLineStr.getBytes())); 		
				//NodeList lineStringNode = lineStringDoc.getElementsByTagName("LineString");
				
				Document polyLineDoc = docBuilder.parse(new ByteArrayInputStream(xmlLineStr.getBytes())); 		
				NodeList polyLineNode = polyLineDoc.getElementsByTagName("Polygon");
				
				for (int i = 0; i < polyLineNode.getLength(); i++) {
					Element element = (Element) polyLineNode.item(i);
		
					Element placemarkEle = xmlDoc.createElement("Placemark");
					folderLineStrEle.appendChild(placemarkEle);
		
					Element nameElement = xmlDoc.createElement("name");
					nameElement.appendChild(xmlDoc.createTextNode("Target Name: " + target_name));
					placemarkEle.appendChild(nameElement);
					
					String descriptionText = "";
					if (OPEN_LAYERS_DISPLAY_MAP.equalsIgnoreCase(destination)) {
						descriptionText = "<h3>Target ID: " + target_id + "</h3><div width=\"100%\" align=\"center\"><img src=\"../images/details.gif\" onclick=\"javascript:getAllTargetWidgetDetails({target_key:'" + target_key + "'});\"/></div>";
					} else {
						descriptionText = "<details><target_key>" + target_key + "</target_key><target_id>" + target_id + "</target_id></details>";
					}
					Element descriptionElement = xmlDoc.createElement("description");
					descriptionElement.appendChild(xmlDoc.createTextNode(descriptionText));
					placemarkEle.appendChild(descriptionElement);
					
					NodeList name = element.getElementsByTagName("coordinates");
					Element line = (Element) name.item(0);
					
					String targetCoordinates = getCharacterDataFromElement(line);
					String[] arrCoords = targetCoordinates.split(" ");
					for (int index=0; index<arrCoords.length; index++) {
						String nextCoordinates = arrCoords[index];
						String[] coords = nextCoordinates.split(",");
						String latitude = coords[0].trim();
						String longitude = coords[1].trim();
						
						double dblLatitude = Double.valueOf(latitude);
						double dblLongitude = Double.valueOf(longitude);
						
						if (dblLatitude > eastBoundary) {
							eastBoundary = dblLatitude;
						}
						if (dblLatitude < westBoundary) {
							westBoundary = dblLatitude;
						}
						if (dblLongitude < southBoundary) {
							southBoundary = dblLongitude;
						}
						if (dblLongitude > northBoundary) {
							northBoundary = dblLongitude;
						}
						
						if (index == 0) {
							Element placemarkPointEle = xmlDoc.createElement("Placemark");
							folderPointEle.appendChild(placemarkPointEle);
				
							Element namePointElement = xmlDoc.createElement("name");
							namePointElement.appendChild(xmlDoc.createTextNode("Target Name: " + target_name));
							placemarkPointEle.appendChild(namePointElement);
							
							String pointDescriptionText = "";
							if (OPEN_LAYERS_DISPLAY_MAP.equalsIgnoreCase(destination)) {
								pointDescriptionText = "<h3>Target ID: " + target_id + "</h3><p><b>Latitude: </b>" + latitude + "</p><p><b>Longitude: </b>" + longitude + "</p><div width=\"100%\" align=\"center\"><img src=\"../images/details.gif\" onclick=\"javascript:getAllTargetWidgetDetails({target_key:'" + target_key + "'});\"/></div>";
							} else {
								pointDescriptionText = "<details><target_key>" + target_key + "</target_key><target_id>" + target_id + "</target_id><latitude>" + latitude + "</latitude><longitude>" + longitude + "</longitude></details>";
							}
							Element descriptionPointElement = xmlDoc.createElement("description");
							descriptionPointElement.appendChild(xmlDoc.createTextNode(pointDescriptionText));
							placemarkPointEle.appendChild(descriptionPointElement);
							
							Element stylePointURLElement = xmlDoc.createElement("styleUrl");
							placemarkPointEle.appendChild(stylePointURLElement);
							stylePointURLElement.appendChild(xmlDoc.createTextNode("#blueLSStyle"));  
							
							Element pointPointElement = xmlDoc.createElement("Point");
							placemarkPointEle.appendChild(pointPointElement);
					
							Element coordPointElement = xmlDoc.createElement("coordinates");
							pointPointElement.appendChild(coordPointElement);
							coordPointElement.appendChild(xmlDoc.createTextNode( nextCoordinates ));
						}
					}
					
					Element styleURLElement = xmlDoc.createElement("styleUrl");
					placemarkEle.appendChild(styleURLElement);
					styleURLElement.appendChild(xmlDoc.createTextNode("#blueLSStyle"));  
					
					Element lineStringElement = xmlDoc.createElement("LineString");
					placemarkEle.appendChild(lineStringElement);
			
					Element coordElement = xmlDoc.createElement("coordinates");
					lineStringElement.appendChild(coordElement);
					coordElement.appendChild(xmlDoc.createTextNode( getCharacterDataFromElement(line) ));  	
				}			
			}
			
			//Polygon		
			Element folderPolygonEle = xmlDoc.createElement("Folder");
			docElement.appendChild(folderPolygonEle);
			
			while (polygonResult.next()) {
				if (!containsMapData) {
					containsMapData = true;
				}
				String xmlPolygonStr=null;
				String target_key = polygonResult.getString(1);
				String target_name = polygonResult.getString(2);
				String target_id = polygonResult.getString(3);
				xmlPolygonStr = polygonResult.getString(4);
				
				Document polygonDoc = docBuilder.parse(new ByteArrayInputStream(xmlPolygonStr.getBytes())); 		
				NodeList polygonNode = polygonDoc.getElementsByTagName("Polygon");
				
				Element placemarkPolygonEle = xmlDoc.createElement("Placemark");
				folderPolygonEle.appendChild(placemarkPolygonEle);
		
				Element nameElement = xmlDoc.createElement("name");
				nameElement.appendChild(xmlDoc.createTextNode("Target Name: " + target_name));
				placemarkPolygonEle.appendChild(nameElement);
				
				String descriptionText = "";
				if (OPEN_LAYERS_DISPLAY_MAP.equalsIgnoreCase(destination)) {
					descriptionText = "<h3>Target ID: " + target_id + "</h3><div width=\"100%\" align=\"center\"><img src=\"../images/details.gif\" onclick=\"javascript:getAllTargetWidgetDetails({target_key:'" + target_key + "'});\"/></div>";
				} else {
					descriptionText = "<details><target_key>" + target_key + "</target_key><target_id>" + target_id + "</target_id></details>";
				}
				Element descriptionElement = xmlDoc.createElement("description");
				descriptionElement.appendChild(xmlDoc.createTextNode(descriptionText));
				placemarkPolygonEle.appendChild(descriptionElement);
				
				Element styleURLPolygonElement = xmlDoc.createElement("styleUrl");
				placemarkPolygonEle.appendChild(styleURLPolygonElement);
				styleURLPolygonElement.appendChild(xmlDoc.createTextNode("#blueLSStyle"));
					
				Element polygonElement = xmlDoc.createElement("Polygon");
				placemarkPolygonEle.appendChild(polygonElement);
				
				for (int i = 0; i < polygonNode.getLength(); i++) {
					Element outerBoundaryIsElement = (Element) polygonNode.item(i);
					
					NodeList outerBoundaryIsNode = outerBoundaryIsElement.getElementsByTagName("outerBoundaryIs");
					Element outerBoundaryIsElement1 = xmlDoc.createElement("outerBoundaryIs");
					polygonElement.appendChild(outerBoundaryIsElement1);
							
					for (int j = 0; j < outerBoundaryIsNode.getLength(); j++) {
						Element linearRingElement = (Element) outerBoundaryIsNode.item(j);
						
						NodeList linearRingNode = linearRingElement.getElementsByTagName("LinearRing");
						Element linearRingElement1 = xmlDoc.createElement("LinearRing");
						outerBoundaryIsElement1.appendChild(linearRingElement1);
							
						for (int k = 0; k < linearRingNode.getLength(); k++) {
							Element element = (Element) linearRingNode.item(k);
							
							NodeList name = element.getElementsByTagName("coordinates");
							Element line = (Element) name.item(k);
							
							String targetCoordinates = getCharacterDataFromElement(line);
							String[] arrCoords = targetCoordinates.split(" ");
							for (int index=0; index<arrCoords.length; index++) {
								String nextCoordinates = arrCoords[index];
								String[] coords = nextCoordinates.split(",");
								String latitude = coords[0].trim();
								String longitude = coords[1].trim();
								
								double dblLatitude = Double.valueOf(latitude);
								double dblLongitude = Double.valueOf(longitude);
								
								if (dblLatitude > eastBoundary) {
									eastBoundary = dblLatitude;
								}
								if (dblLatitude < westBoundary) {
									westBoundary = dblLatitude;
								}
								if (dblLongitude < southBoundary) {
									southBoundary = dblLongitude;
								}
								if (dblLongitude > northBoundary) {
									northBoundary = dblLongitude;
								}
								
								if (index == 0) {
									Element placemarkPolygonPointEle = xmlDoc.createElement("Placemark");
									folderPointEle.appendChild(placemarkPolygonPointEle);
						
									Element namePolygonPointElement = xmlDoc.createElement("name");
									namePolygonPointElement.appendChild(xmlDoc.createTextNode("Target Name: " + target_name));
									placemarkPolygonPointEle.appendChild(namePolygonPointElement);
									
									String polygonPointDescriptionText = "";
									if (OPEN_LAYERS_DISPLAY_MAP.equalsIgnoreCase(destination)) {
										polygonPointDescriptionText = "<h3>Target ID: " + target_id + "</h3><p><b>Latitude: </b>" + latitude + "</p><p><b>Longitude: </b>" + longitude + "</p><div width=\"100%\" align=\"center\"><img src=\"../images/details.gif\" onclick=\"javascript:getAllTargetWidgetDetails({target_key:'" + target_key + "'});\"/></div>";
									} else {
										polygonPointDescriptionText = "<details><target_key>" + target_key + "</target_key><target_id>" + target_id + "</target_id><latitude>" + latitude + "</latitude><longitude>" + longitude + "</longitude></details>";
									}
									Element descriptionPolygonPointElement = xmlDoc.createElement("description");
									descriptionPolygonPointElement.appendChild(xmlDoc.createTextNode(polygonPointDescriptionText));
									placemarkPolygonPointEle.appendChild(descriptionPolygonPointElement);
									
									Element stylePolygonPointURLElement = xmlDoc.createElement("styleUrl");
									placemarkPolygonPointEle.appendChild(stylePolygonPointURLElement);
									stylePolygonPointURLElement.appendChild(xmlDoc.createTextNode("#greenPolygonStyle"));  
									
									Element pointPolygonPointElement = xmlDoc.createElement("Point");
									placemarkPolygonPointEle.appendChild(pointPolygonPointElement);
							
									Element coordPolygonPointElement = xmlDoc.createElement("coordinates");
									pointPolygonPointElement.appendChild(coordPolygonPointElement);
									coordPolygonPointElement.appendChild(xmlDoc.createTextNode( nextCoordinates ));
								}
							}
							
							Element coordElement = xmlDoc.createElement("coordinates");
							linearRingElement1.appendChild(coordElement);
							coordElement.appendChild(xmlDoc.createTextNode( getCharacterDataFromElement(line) ));  	
						}
					}
				}			
			}
	
			if (OPEN_LAYERS_DISPLAY_MAP.equalsIgnoreCase(destination)) {
				double avgLongitude = (eastBoundary + westBoundary) / 2;
				double avgLatitude = (northBoundary + southBoundary) / 2;
				double diffLongitude = eastBoundary - westBoundary;
				double diffLatitude = northBoundary - southBoundary;
				double dblAltitude = getAltitudeValue(diffLatitude, diffLongitude);
				
				String strLatitude = "" + avgLatitude;
				String strLongitude = "" + avgLongitude;
				String altitude = "" + dblAltitude;
				
				String strEastBoundary = "" + eastBoundary;
				String strWestBoundary = "" + westBoundary;
				String strNorthBoundary = "" + northBoundary;
				String strSouthBoundary = "" + southBoundary;
				
				Element cameraElement = xmlDoc.createElement("Camera");
				docElement.appendChild(cameraElement);
				
				Element cameraLatitudeElement = xmlDoc.createElement("centerLatitude");
				cameraLatitudeElement.appendChild(xmlDoc.createTextNode(strLatitude));
				cameraElement.appendChild(cameraLatitudeElement);
				
				Element cameraLongitudeElement = xmlDoc.createElement("centerLongitude");
				cameraLongitudeElement.appendChild(xmlDoc.createTextNode(strLongitude));
				cameraElement.appendChild(cameraLongitudeElement);
				
				Element cameraAltitudeElement = xmlDoc.createElement("centerAltitude");
				cameraAltitudeElement.appendChild(xmlDoc.createTextNode(altitude));
				cameraElement.appendChild(cameraAltitudeElement);
				
				Element eastBoundaryElement = xmlDoc.createElement("eastBoundary");
				eastBoundaryElement.appendChild(xmlDoc.createTextNode(strEastBoundary));
				cameraElement.appendChild(eastBoundaryElement);
				
				Element westBoundaryElement = xmlDoc.createElement("westBoundary");
				westBoundaryElement.appendChild(xmlDoc.createTextNode(strWestBoundary));
				cameraElement.appendChild(westBoundaryElement);
				
				Element northBoundaryElement = xmlDoc.createElement("northBoundary");
				northBoundaryElement.appendChild(xmlDoc.createTextNode(strNorthBoundary));
				cameraElement.appendChild(northBoundaryElement);
				
				Element southBoundaryElement = xmlDoc.createElement("southBoundary");
				southBoundaryElement.appendChild(xmlDoc.createTextNode(strSouthBoundary));
				cameraElement.appendChild(southBoundaryElement);
			}
			else if (eastBoundary != LONGITUDE_MIN && westBoundary != LONGITUDE_MAX && northBoundary != LATITUDE_MIN && southBoundary != LATITUDE_MAX) {
				double avgLongitude = (eastBoundary + westBoundary) / 2;
				double avgLatitude = (northBoundary + southBoundary) / 2;
				double diffLongitude = eastBoundary - westBoundary;
				double diffLatitude = northBoundary - southBoundary;
				double dblAltitude = getAltitudeValue(diffLatitude, diffLongitude);
				
				String strLatitude = "" + avgLatitude;
				String strLongitude = "" + avgLongitude;
				String altitude = "" + dblAltitude;
				
				Element cameraElement = xmlDoc.createElement("Camera");
				docElement.appendChild(cameraElement);
				
				Element cameraLatitudeElement = xmlDoc.createElement("latitude");
				cameraLatitudeElement.appendChild(xmlDoc.createTextNode(strLatitude));
				cameraElement.appendChild(cameraLatitudeElement);
				
				Element cameraLongitudeElement = xmlDoc.createElement("longitude");
				cameraLongitudeElement.appendChild(xmlDoc.createTextNode(strLongitude));
				cameraElement.appendChild(cameraLongitudeElement);
				
				Element cameraAltitudeElement = xmlDoc.createElement("altitude");
				cameraAltitudeElement.appendChild(xmlDoc.createTextNode(altitude));
				cameraElement.appendChild(cameraAltitudeElement);
			}
			//System.out.println("containsMapData: " + containsMapData);
			if (containsMapData) {
				//Serialize DOM
				OutputFormat format    = new OutputFormat (xmlDoc); 
				// as a String
				StringWriter stringOut = new StringWriter ();    
				XMLSerializer serial   = new XMLSerializer (stringOut, format);
				serial.serialize(xmlDoc);
				// Display the XML
				out.write(stringOut.toString().trim());
			}
			
		} catch (SQLException e) {
			generateServerLogErrorMessage("SQL Exception occurred: " + e);
		    out.write("Error occurred " + e);
		} catch(Exception e) {
			generateServerLogErrorMessage("Exception occurred: " + e);
			out.write("Error occurred " + e);
		} finally {
			try {
				if (stmt != null)
					stmt.close();
			}  catch (SQLException e) {}
			try {
				if (conn != null)
					conn.close();
			} catch (SQLException e) {}
		}
	} // end of IF	
	else {
		out.write("QUERY_STRING returns NULL");
	}
%>
	
<%!
	public static String getCharacterDataFromElement(Element e) {
	    Node child = e.getFirstChild();
	    if (child instanceof CharacterData) {
	       CharacterData cd = (CharacterData) child;
	       return cd.getData();
	    }
	    return "?";
	}
	  
	public static double getAltitudeValue(double diffLatitude, double diffLongitude) {
		double altitudeValue = 0.0;
		
		double latitudeZoomLevel = Math.ceil(diffLatitude / 10);
		if (latitudeZoomLevel < 1) {
			latitudeZoomLevel = 0.5;
		}
		latitudeZoomLevel *=  1000000;
		
		double longitudeZoomLevel = Math.ceil(diffLongitude / 15);
		if (longitudeZoomLevel < 1) {
			longitudeZoomLevel = 0.5;
		}
		longitudeZoomLevel *=  1000000;
	
		altitudeValue = Math.max(latitudeZoomLevel, longitudeZoomLevel);
		return altitudeValue;
	}
	
	public void createPointElement(Element folderPointEle, String xmlStr) 
	{
		try {
			DocumentBuilderFactory dbFactory = DocumentBuilderFactoryImpl.newInstance();
			DocumentBuilder docBuilder = dbFactory.newDocumentBuilder();
			Document xmlDoc = docBuilder.newDocument();
			
			Document doc1 = docBuilder.parse(new ByteArrayInputStream(xmlStr.getBytes())); 		
			NodeList pNode = doc1.getElementsByTagName("Point");
			
			for (int i = 0; i < pNode.getLength(); i++) {
				Element element = (Element) pNode.item(i);
	
				Element placemarkEle = xmlDoc.createElement("Placemark");
				folderPointEle.appendChild(placemarkEle);
	
				NodeList name = element.getElementsByTagName("coordinates");
				Element line = (Element) name.item(0);
				
				Element styleURLElement = xmlDoc.createElement("styleUrl");
				placemarkEle.appendChild(styleURLElement);
				styleURLElement.appendChild(xmlDoc.createTextNode("#pointMarker"));  
				
				Element pointElement = xmlDoc.createElement("Point");
				placemarkEle.appendChild(pointElement);
		
				Element coordElement = xmlDoc.createElement("coordinates");
				pointElement.appendChild(coordElement);
				coordElement.appendChild(xmlDoc.createTextNode( getCharacterDataFromElement(line) ));  	
			}
			
		} catch(Exception e) {
			generateServerLogErrorMessage("Exception occurred " + e);
		}
	}
	
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