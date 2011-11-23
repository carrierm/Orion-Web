<%@ page contentType="text/html; charset=UTF-8" %>

<html>
   <head>	
	<style>
		body {
			font-family:helvetica,tahoma,verdana,sans-serif;		
			font-size:8px;
			padding:0px;
			padding-top:0px;
		}		
		#map {
			 width: 600px; 
             height: 350px;
             border: 1px solid gray;
		}
	</style>
	<%@ include file="common.jsp" %>
	
	<link rel="stylesheet" href="<%=serverStylesPath%>/style-2gdb.css" type="text/css" />
	<link rel="stylesheet" href="<%=serverStylesPath%>/style.css" type="text/css" />
	
	<script src="<%=serverScriptsPath%>/OpenLayers/OpenLayers.js"></script>
    <script src="<%=serverScriptsPath%>/owf-widget-min.js"></script>

	<script type="text/javascript" src="http://www.google.com/jsapi?key=ABQIAAAAwbkbZLyhsmTCWXbTcjbgbRSzHs7K5SvaUdm8ua-Xxy_-2dYwMxQMhnagaawTo7L1FE1-amhuQxIlXw"></script>
	<script type="text/javascript" src="<%=serverScriptsPath%>/communicationAgent.js"></script>
	<script type="text/javascript" src="<%=serverScriptsPath%>/2gdb_eventing.js"></script>

   	<script type="text/javascript">
   		try {  
			var Ozone;
			var logger;
			var appender;
			var ge;
			var KMLURL = '';
			
			google.load("earth", "1");
			
			function setupGEObject() {
				google.earth.createInstance('map3d', initCallback, failureCallback);
			}
			
			function failureCallback(errorCode) {
				logger.debug("Google Earth Display Map Widget: failureCallback(): errorCode: " + errorCode);
			}
			
			function initCallback(instance) {
				logger.debug("Google Earth Display Map Widget: Begin initCallback() instance: " + instance);
				try {
					ge = instance;
				    ge.getWindow().setVisibility(true);
					
					var cam = ge.getView().copyAsCamera(ge.ALTITUDE_ABSOLUTE);
					cam.setAltitude(10000000);
					cam.setTilt(0);
					ge.getView().setAbstractView(cam);
					
					ge.getNavigationControl().setVisibility(ge.VISIBILITY_SHOW);
					
					ge.getLayerRoot().enableLayerById(ge.LAYER_BORDERS, true);
				    ge.getLayerRoot().enableLayerById(ge.LAYER_ROADS, true);
				    ge.getLayerRoot().enableLayerById(ge.LAYER_BUILDINGS, true);
				    
				    ge.getOptions().setStatusBarVisibility(true);
				    ge.getOptions().setScaleLegendVisibility(true);
				    ge.getOptions().setOverviewMapVisibility(true);
				    
				    logger.debug("Google Earth Display Map Widget: ge: " + ge);
				} catch(err) {
					logger.debug("Google Earth Display Map Widget: initCallback(): err: " + err);
				}
				logger.debug("Google Earth Display Map Widget: Completed initCallback()");
			}
			
			//google.setOnLoadCallback(setupGEObject);
			
			function getTagNodeValue(xmlContent, tagName) {
				var parser, xmlDoc;
				var returnResult = '';
				if (window.DOMParser) {
				  	parser=new DOMParser();
				  	xmlDoc=parser.parseFromString(xmlContent,"text/xml");
				}
				// Internet Explorer
				else {
					xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
				  	xmlDoc.async="false";
				  	xmlDoc.loadXML(xmlContent);
				}
				
				var x = xmlDoc.getElementsByTagName(tagName);
				if (x.length > 0) {
					var result = x[0].childNodes[0].nodeValue;
					if (result != null && result != "null") {
						returnResult = result;
					}
				}
	  			return returnResult;
			}
			
			function addObjectToEarth() {
				if (ge != null) {
					if (KMLURL != '') {
						var xmlHttpReq = false;
					    var self = this;
						
					    if (window.XMLHttpRequest) { self.xmlHttpReq = new XMLHttpRequest(); }
					    // IE
					    else if (window.ActiveXObject) { self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP"); }
					    
					    self.xmlHttpReq.open('POST', KMLURL, true);
					    self.xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
				    	self.xmlHttpReq.onreadystatechange = function() {
					    	try {
						        if (self.xmlHttpReq.readyState == 4) {
						            var generatedKML = trim(self.xmlHttpReq.responseText);
						            generatedKML = generatedKML.replace(/&lt;/g,"<");
						            generatedKML = generatedKML.replace(/&gt;/g,">");
						            logger.debug('generatedKML: ' + generatedKML);
						            var kmlLayer = ge.parseKml(generatedKML);
						            if (kmlLayer != null) {
						            	ge.getFeatures().appendChild(kmlLayer);
						            	
						            	if (kmlLayer.getAbstractView()) {
						            		ge.getView().setAbstractView(kmlLayer.getAbstractView());
						            	}
						            	google.earth.addEventListener(kmlLayer, 'click', function(event) {
						            		event.preventDefault(); 
						            		try {
						            			var kmlPlacemark = event.getTarget();
						            			
						            			var target_name = kmlPlacemark.getName();
						            			var description = kmlPlacemark.getDescription();
						            			var target_key = getTagNodeValue(description, 'target_key');
						            			var target_id = getTagNodeValue(description, 'target_id');
						            			var latitude = getTagNodeValue(description, 'latitude');
						            			var longitude = getTagNodeValue(description, 'longitude');
						            			
						            			var balloon_text = '';
						            			balloon_text += '<h3>' + target_name + '</h3>';
						            			balloon_text += '<p><b>Target ID: </b>' + target_id + '</p>';
						            			if (latitude != '') {
							            			balloon_text += '<p><b>Latitude: </b>' + latitude + '</p>';
						            			}
						            			if (longitude != '') {
						            				balloon_text += '<p><b>Longitude: </b>' + longitude + '</p>';
						            			}
						            			
						            			balloon_text += '<div width=\"100%\" align=\"center\">';
						            			balloon_text += '<img src="../images/details.gif" onclick="javascript:getAllTargetWidgetDetails({target_key:\'' + target_key + '\'});"/>';
						            			balloon_text += '</div>';
						            			
						            			var balloon = ge.createHtmlStringBalloon('');
						            			balloon.setContentString(balloon_text);
						            			ge.setBalloon(balloon);
						            		} catch(err) {
						            			logger.debug("Google Earth Display Map Widget: addObjectToEarth(): err: " + err);
						            		}
						            	});
						            }
						        }
					    	} catch(err){
					    		logger.debug("Google Earth Display Map Widget: addObjectToEarth(): err: " + err);
					    	}
					    }
					    self.xmlHttpReq.send(null);
					}
				} else {
					logger.debug("Google Earth Display Map Widget: addObjectToEarth(): ge not initialized");
				}
			}
			
			/**
			* function to make AJAX call to get the KML data from server
			* @author	:	Mark Carrier
			* @date		:	08/26/2011
			*/	
			function getTargetsKML(data) {
				try {
					if (data != null) {
						var dataObj = Ozone.util.parseJson(data);
						var sourceWidget = dataObj.source;

						var url = serverDataPath + "/targets.jsp";
						
						if(dataObj.type == "LATLONG") {
							KMLURL = url + "?SOURCE="+dataObj.source+"&DESTINATION='GOOGLE_EARTH_DISPLAY_MAP'&TYPE='"+ dataObj.type+ "'&LAT="+dataObj.latlong.latitude+"&LONG="+dataObj.latlong.longitude;
						} 
						else if (dataObj.type == "COCOM") {
							KMLURL = url + "?SOURCE="+dataObj.source+"&DESTINATION='GOOGLE_EARTH_DISPLAY_MAP'&TYPE='"+ dataObj.type+ "'&COCOMVAL='"+dataObj.value+"'";
						}
						else if (dataObj.type == "COUNTRY") {
							KMLURL = url + "?SOURCE="+dataObj.source+"&DESTINATION='GOOGLE_EARTH_DISPLAY_MAP'&TYPE='"+ dataObj.type+ "'&COUNTRYCODE='"+dataObj.value+"'";
						}
						else if (dataObj.type == "POLYGON") {
							KMLURL = url + "?SOURCE="+dataObj.source+"&DESTINATION='GOOGLE_EARTH_DISPLAY_MAP'&TYPE='"+ dataObj.type+ "'&POLYGON='"+dataObj.value+"'";
						}						
						else if (dataObj.type == "CRLIST") {
							KMLURL = url + "?SOURCE=" + dataObj.source +"&DESTINATION='GOOGLE_EARTH_DISPLAY_MAP'&TYPE='" + dataObj.type + "'&VALUE='" + dataObj.value + "'";
						}
						else if (dataObj.type == "TARGETLIST") {
							KMLURL = url + "?SOURCE=" + dataObj.source +"&DESTINATION='GOOGLE_EARTH_DISPLAY_MAP'&TYPE='" + dataObj.type + "'&VALUE='" + dataObj.value + "'";
						} else {
							KMLURL = url + "?SOURCE=DISPLAY_MAP&DESTINATION='GOOGLE_EARTH_DISPLAY_MAP'&TYPE='COCOM'&COCOMVAL='NORTHCOM'";
						}
						logger.debug("Google Earth Display Map Widget: getTargetsKML(): KMLURL: " + KMLURL);
						
						addObjectToEarth();
					}
				} catch(err) {
					logger.debug("Google Earth Display Map Widget: getTargetsKML(): err: " + err);
				}	
			}
			
			/**
			* function to initialize the channel tracker to listen 
			* @author	:	Mark Carrier
			* @date		:	08/26/2011
			*/
			function trackerInit() {
				try {
					var launchConfig = Ozone.launcher.WidgetLauncherUtils.getLaunchConfigData();   
		
					if(launchConfig == null) {
						data = {channel: CHANNEL_NAME_displayMap};
						launchConfig = Ozone.util.toString(data);
					}
					
					if(!launchConfig) {
						 var scope = this;
						 this.gadgetEventingController = new Ozone.eventing.Widget('rpc_relay.uncompressed.html',
							function() {
							   scope.gadgetEventingController.subscribe.apply(scope,["ClockChannel", scope.update]);    
						 });
					}
					else {
						var launchConfigJson = Ozone.util.parseJson(launchConfig);
						var channelToUse = launchConfigJson.channel;
						
						getTargetsKML(launchConfig);
						
						var scope = this;
						this.gadgetEventingController = new Ozone.eventing.Widget('rpc_relay.uncompressed.html',
						   function() {						
							  scope.gadgetEventingController.subscribe.apply(scope,[channelToUse, scope.update]); 
							  scope.update;		
						   });
					}
				} catch(err) {
					logger.debug("Google Earth Display Map Widget: trackerInit(): err: " + err);
				}
			}
			
			
			/**
			* function to respond when channel update
			* @author	:	Mark Carrier
			* @date		:	08/26/2011
			*/
			var update = function(sender, msg) {
				try {
					if (ge!=null) {
						logger.debug('Google Earth Display Map Widget: update(): MSG: ' + msg);
						var features = ge.getFeatures();
						if (features.getChildNodes().getLength() > 0) {
							while (features.getFirstChild()) {
							   features.removeChild(features.getFirstChild());
							}
						}
					}
					getTargetsKML(msg);
				} catch(err) {
					logger.debug("Google Earth Display Map Widget: update(): err: " + err);
				}	
			}
			
			
			/**
			* function to initialize the logging
			* @author	:	Mark Carrier
			* @date		:	08/26/2011
			*/
			function logInit() {
				try {
				 	// Initialize logging objects
				 	Ozone = Ozone || {};
				 	Ozone.log = Ozone.log || {};
	
				 	logger = Ozone.log.getDefaultLogger();
				 	Ozone.log.setEnabled(true);
	
				 	appender = logger.getEffectiveAppenders()[0];
				 	appender.setThreshold(log4javascript.Level.DEBUG);
				} catch(err){
					logger.debug("Google Earth Display Map Widget: logInit(): err: " + err);
				}
			}
			
			/**
			* function to initialize th epage
			* @author	:	Mark Carrier
			* @date		:	08/26/2011
			*/				
			function initPage() {
				try {
					logInit();
					setupGEObject();
					trackerInit();
				} catch(err){
					logger.debug("Google Earth Display Map Widget: initPage(): err: " + err);
				}
			}
   		} catch(err) {
   			logger.debug("Google Earth Display Map Widget: err: " + err);
   		}
      </script>
   </head>
   <body onload="initPage(); ">
		<div id="map3d" style="border: 1px solid silver; width: 650px; height: 500px;"></div>
   </body>
</html>