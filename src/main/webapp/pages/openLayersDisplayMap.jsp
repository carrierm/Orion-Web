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
	<script type="text/javascript" src="<%=serverScriptsPath%>/communicationAgent.js"></script>
	<script type="text/javascript" src="<%=serverScriptsPath%>/2gdb_eventing.js"></script>

   	<script type="text/javascript">
   		try {  
			var Ozone;
			var logger;
			var appender;
			var map;
			var select;
			var layerkml;
			var bounds;
			var eastBoundary = 0.0;
			var westBoundary = 0.0;
			var northBoundary = 0.0;
			var southBoundary = 0.0;
			var centerLatitude = 0.0;
			var centerLongitude = 0.0;
			
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
			
			/**
			* function to make AJAX call to get the KML data from server
			* @author	:	Mark Carrier
			* @date		:	05/25/2011
			*/	
			function getTargetsKML(data) {
				try {
					if (data != null) {
						var dataObj = Ozone.util.parseJson(data);
						var sourceWidget = dataObj.source;
						var KMLURL = "";

						var url = serverDataPath + "/targets.jsp";
						
						if(dataObj.type == "LATLONG") {
							KMLURL = url + "?SOURCE="+dataObj.source+"&DESTINATION='OPEN_LAYERS_DISPLAY_MAP'&TYPE='"+ dataObj.type+ "'&LAT="+dataObj.latlong.latitude+"&LONG="+dataObj.latlong.longitude;
						} 
						else if (dataObj.type == "COCOM") {
							KMLURL = url + "?SOURCE="+dataObj.source+"&DESTINATION='OPEN_LAYERS_DISPLAY_MAP'&TYPE='"+ dataObj.type+ "'&COCOMVAL='"+dataObj.value+"'";
						}
						else if (dataObj.type == "COUNTRY") {
							KMLURL = url + "?SOURCE="+dataObj.source+"&DESTINATION='OPEN_LAYERS_DISPLAY_MAP'&TYPE='"+ dataObj.type+ "'&COUNTRYCODE='"+dataObj.value+"'";
						}
						else if (dataObj.type == "POLYGON") {
							KMLURL = url + "?SOURCE="+dataObj.source+"&DESTINATION='OPEN_LAYERS_DISPLAY_MAP'&TYPE='"+ dataObj.type+ "'&POLYGON='"+dataObj.value+"'";
						}						
						else if (dataObj.type == "CRLIST") {
							KMLURL = url + "?SOURCE=" + dataObj.source + "&DESTINATION='OPEN_LAYERS_DISPLAY_MAP'&TYPE='" + dataObj.type + "'&VALUE='" + dataObj.value + "'";
						}
						else if (dataObj.type == "TARGETLIST") {
							KMLURL = url + "?SOURCE=" + dataObj.source + "&DESTINATION='OPEN_LAYERS_DISPLAY_MAP'&TYPE='" + dataObj.type + "'&VALUE='" + dataObj.value + "'";
						} else {
							KMLURL = url + "?SOURCE=DISPLAY_MAP&DESTINATION='OPEN_LAYERS_DISPLAY_MAP'&TYPE='COCOM'&COCOMVAL='NORTHCOM'";
						}
						logger.debug("Display Map Widget: getTargetsKML(): KMLURL: " + KMLURL);
				
						if (map.getNumLayers() > 1) {
							map.destroy();
							initMap();
						}
						var style = new OpenLayers.Style({
		                    pointRadius: "${radius}",
		                    fillColor: "#00ff00",
		                    fillOpacity: 0.8,
		                    strokeColor: "#cc6633",
		                    strokeWidth: 2,
		                    strokeOpacity: 0.8
		                }, {
		                    context: {
		                        radius: function(feature) {
		                            return Math.min(feature.attributes.count, 7) + 3;
		                        }
		                    }
		                });
						
						if (KMLURL != '') {
							var MyKmlLayer= new OpenLayers.Layer.Vector("This Is My KML Layer", {
								projection: new OpenLayers.Projection("EPSG:4326"),
								strategies: [new OpenLayers.Strategy.Fixed()],
								protocol: new OpenLayers.Protocol.HTTP({
										//set the url to your variable//
										url: KMLURL,
										//format this layer as KML//
										format: new OpenLayers.Format.KML({
											//maxDepth is how deep it will follow network links//
											//maxDepth: 1,
											//extract styles from the KML Layer//
											extractStyles: true,
											//extract attributes from the KML Layer//
											extractAttributes: true
										})
								}),
								styleMap: new OpenLayers.StyleMap({
			                        "default": style,
			                        "select": {
			                            fillColor: "#8aeeef",
			                            strokeColor: "#32a8a9"
			                        }
			                    })
							});
							// If the map is not destroyed and reinitialized, any new layers added to the map will be put on top of each other. 
							// Destroying and reinitializing the map will help distinguish between various data sets to be displayed
							map.addLayers([MyKmlLayer]);
							select = new OpenLayers.Control.SelectFeature(MyKmlLayer);
							
							MyKmlLayer.events.on({
				                "featureselected":   onFeatureSelect,
				                "featureunselected": onFeatureUnselect
				            });
							map.addControl(select);
				            select.activate();
				            
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
							            
							            centerLatitude = getTagNodeValue(generatedKML, 'centerLatitude');
				            			centerLongitude = getTagNodeValue(generatedKML, 'centerLongitude');
				            			
				            			eastBoundary = getTagNodeValue(generatedKML, 'eastBoundary');
				            			westBoundary = getTagNodeValue(generatedKML, 'westBoundary');
				            			northBoundary = getTagNodeValue(generatedKML, 'northBoundary');
				            			southBoundary = getTagNodeValue(generatedKML, 'southBoundary');
				            			
				            			bounds = new OpenLayers.Bounds( westBoundary, southBoundary, eastBoundary, northBoundary );
				            			map.zoomToExtent(bounds, false);		
										map.setCenter(new OpenLayers.LonLat(centerLongitude, centerLatitude ));
							        }
						    	} catch(err){
						    		logger.debug(err);
						    	}
						    }
						    self.xmlHttpReq.send(null);
						}
					}
				} catch(err) {
					logger.debug('Display Map Widget: getTargetsKML(): err: ' + err);
				}	
			}
			
			function onFeatureSelect(event) {
				try {
		            var feature = event.feature;
		            var content = "<h2>"+feature.attributes.name + "</h2>" + feature.attributes.description;
		            if (content.search("<script") != -1) {
		                content = "Content contained Javascript! Escaped content below.<br />" + content.replace(/</g, "&lt;");
		            }
		            popup = new OpenLayers.Popup.FramedCloud(
		            						"targetWindowPopup",	// id    
											feature.geometry.getBounds().getCenterLonLat(), // lonlat
		                                    new OpenLayers.Size(100,100),	// size
		                                    content,	// contentHTML
		                                    null, //closeBox 
		                                    true, //
		                                    onPopupClose);
		            popup.maxSize = new OpenLayers.Size(300,300);
		            popup.panMapIfOutOfView = true;
		            
		            feature.popup = popup;
		            map.addPopup(popup);
				} catch(err) {
					logger.debug("Display Map Widget: onFeatureSelect(): err: " + err);
				}
	        }
			
			function onPopupClose(evt) {
				try {
	            	select.unselectAll();
				} catch(err){
					logger.debug("Display Map Widget: onPopupClose(): err: " + err);
				}
	        }
			
			function onFeatureUnselect(event) {
				try {
		            var feature = event.feature;
		            if(feature.popup) {
		                map.removePopup(feature.popup);
		                feature.popup.destroy();
		                delete feature.popup;
		            }
				} catch(err){
					logger.debug("Display Map Widget: onFeatureUnselect(): err: " + err);
				}
	        }
			/**
			* function to initialize the display map
			* @author	:	Mark Carrier
			* @date		:	05/25/2011
			*/		
			function initMap() {
				try {
					logger.debug('initMap()');
					var options = { maxResolution: "auto", numZoomLevels: 9, controls: [	new OpenLayers.Control.Navigation(), new OpenLayers.Control.MousePosition(), new OpenLayers.Control.PanZoomBar() ] };
					var bounds = null;
					map = new OpenLayers.Map('map', options);
					
					var blnUseGeoServer = true;
					var useGeoServer = true;
					if (blnUseGeoServer == 'true') {
						useGeoServer = true;
						bounds = new OpenLayers.Bounds(-184, -85.53, 180, 83.627);
					} else {
						bounds = new OpenLayers.Bounds(-180, -90, 180, 90 );
					}
					if (useGeoServer) {
			    	  var baseLayer = new OpenLayers.Layer.WMS(
			    		'vmap:vmap_edge_thin - Untiled',
			    		'http://vmap0.tiles.osgeo.org/wms/vmap0', 
			    		{LAYERS: 'basic', STYLES: ''},
						{singleTile: true, ratio: 1, isBaseLayer: true}
			    	  );
			    	  map.addLayers([baseLayer]);
				    } else {
				    	// Set up the WMS tile layer - this will be the base layer
					    var baseLayer = new OpenLayers.Layer.WMS( "WMS Base Layer", 
					    	'http://vmap0.tiles.osgeo.org/wms/vmap0', 
					    	{layers: 'basic', isBaseLayer: true}
					    );
					    map.addLayers([baseLayer]);
				    }
					
					map.zoomToMaxExtent(bounds);
					map.setCenter(new OpenLayers.LonLat(0, 0));
				} catch(err){
					logger.debug("Display Map Widget: initMap(): err: " + err);
				}
			}		
	
			
			/**
			* function to initialize the channel tracker to listen 
			* @author	:	Mark Carrier
			* @date		:	05/25/2011
			*/
			function trackerInit() {
				try {
					var launchConfig = Ozone.launcher.WidgetLauncherUtils.getLaunchConfigData();   
					logger.debug('Display Map Widget: launchConfig : ' + launchConfig );
		
					if(launchConfig == null) {
						data = {channel: CHANNEL_NAME_displayMap};
						launchConfig = Ozone.util.toString(data);
					}
					
					if (!launchConfig) {
						var scope = this;
						this.gadgetEventingController = new Ozone.eventing.Widget('rpc_relay.uncompressed.html', 
							function() { 
								scope.gadgetEventingController.subscribe.apply(scope, [ channelToUse, scope.update ]);
								scope.update;
							}
						);
					} else {
						// We are expecting the channel to listen on to be passed in dynamically.
						// Update it on the page
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
					logger.debug("Display Map Widget: trackerInit(): err: " + err);
				}
			}
			
			
			/**
			* function to respond when channel update
			* @author	:	Mark Carrier
			* @date		:	05/25/2011
			*/
			var update = function(sender, msg) {
				try {
					logger.debug('Display Map Widget: update(): MSG: ' + msg);
					getTargetsKML(msg);
				} catch(err) {
					logger.debug("Display Map Widget: update(): err: " + err);
				}	
			}
			
			
			/**
			* function to initialize the logging
			* @author	:	Mark Carrier
			* @date		:	05/25/2011
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
					logger.debug("Display Map Widget: logInit(): err: " + err);
				}
			}
			
			/**
			* function to initialize th epage
			* @author	:	Mark Carrier
			* @date		:	05/25/2011
			*/				
			function initPage() {
				try {
					logInit();
					initMap();
					trackerInit();
				} catch(err){
					logger.debug("Display Map Widget: initPage(): err: " + err);
				}
			}
   		} catch(err) {
   			logger.debug("Display Map Widget: err: " + err);
   		}
      </script>
   </head>
   <body onload="initPage(); ">
		<div id="map"></div>
   </body>
</html>