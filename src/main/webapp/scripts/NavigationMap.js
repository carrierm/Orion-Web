/**
 * NavigationMap: Allows the user to select an area based
 * on the COCOM, Country or polygon. Once an area is selected
 * an OWF event with the area information will be broadcast.
 */
NavigationMap = Ext.extend(Ext.Panel, {
   layout: 'fit',
   border: false,
   /**
    * WMS Server used for the base map tiles.
    */
   wmsServer: '<%=mapServer%>',//'http://vmap0.tiles.osgeo.org/wms/vmap0',
   /**
    * Base tile layer name that will be used with the wmsServer parameter.
    */
   tileLayer: '<%=mapTileLayer%>',
   
   useGeoServer: '<%=blnUseGeoServer%>',
   /**
    * Location of the COCOM KML overlay.
    */
   cocomKML: '<%=serverKMLPath%>/cocom.kml',
   /**
    * Location of the Countries KML overlay.
    */
   countryKML: '<%=serverKMLPath%>/countries.kml',
   /**
    * OWF channel on which to publish area selection events.
    */
   publishChannel: CHANNEL_NAME_DEFAULT,
   navMapPublishChannel: CHANNEL_NAME_navigationMap,
   displayMapPublishChannel: CHANNEL_NAME_displayMap,
   crListPublishChannel: CHANNEL_NAME_collectionRequirements,
   targetListPublishChannel: CHANNEL_NAME_targets,
   crRollupPublishChannel: CHANNEL_NAME_crRollup,
   crTrendsPublishChannel: CHANNEL_NAME_crTrends,
   targetCollectionRequestsPublishChannel: CHANNEL_NAME_targetCollectionRequests,
   
   /**
    * Extra options for the OpenLayers map object.
    */
   mapOptions: {
      maxResolution: 'auto',
      numZoomLevels: 8
   },
   /**
    * Set of colors used to color features (at this moment countries)
    * if the overrideCountryColors parameter is true.
    */
   featureColors: [
      '#ff0000', '#00ff00', '#800000', '#808000', '#00ffff', '#800080', '#2f4f4f',
      '#eee8aa', '#000080', '#008080', '#87cefa', '#a0522d', '#ff8c00'
   ],
   /**
    * If true then the featureColors will be used to color in the
    * countries of the map. If false then the countryKML's own style
    * will be used to color the map. 
    */
   overrideCountryColors: false,
   /**
    * Publish an event to the OWF channel.
    * 
    * @param {Object} data
    */
   publishEvent: function(data) {
	   try {
    	  this.widgetEventingController.publish(this.displayMapPublishChannel, data);
    	  this.widgetEventingController.publish(this.targetListPublishChannel, data);
    	  this.widgetEventingController.publish(this.crListPublishChannel, data);
    	  this.widgetEventingController.publish(this.crRollupPublishChannel, data);
    	  this.widgetEventingController.publish(this.crTrendsPublishChannel, data);
    	  this.widgetEventingController.publish(this.targetCollectionRequestsPublishChannel, data);
      } catch (ex) {
         logger.debug('Error publishing: ' + data);
      }
   },
   selectCOCOM: function(combo, record, index) {
	  var selectedItem = combo.getValue();
 	  // Set up the data to be published via OWF eventing
      var passedValueStr = { source: 'NAVIGATION_MAP', type: 'COCOM', value: selectedItem };
      
      // Zoom in on the selected COCOM
      //this.mapPanel.map.zoomToExtent(feature.geometry.bounds);
      
      // Switch to the countries layer
      this.countryButton.toggle(true);
      this.countryButton.handler.call(this);
      
      // Publish the OWF event
      this.publishEvent(passedValueStr);
   },
   onCOCOMSelect: function(feature) {
      // Set up the data to be published via OWF eventing
      var passedValueStr = { source: 'NAVIGATION_MAP', type: 'COCOM', value: feature.attributes.cocomCode };
      
      // Zoom in on the selected COCOM
      this.mapPanel.map.zoomToExtent(feature.geometry.bounds);
      
      // Switch to the countries layer
      this.countryButton.toggle(true);
      this.countryButton.handler.call(this);
      
      // Publish the OWF event
      this.publishEvent(passedValueStr);
   },
   selectCountry: function(combo, record, index) {
	  var selectedItem = combo.getValue();
	  
	  var passedValueStr = { source: 'NAVIGATION_MAP', type: 'COUNTRY', value: selectedItem };
      
      // Publish the OWF event
      this.publishEvent(passedValueStr);
   },
   onCountrySelect: function(feature) {
      var passedValueStr = { source: 'NAVIGATION_MAP', type: 'COUNTRY', value: feature.attributes.countryCode };
      
      // Publish the OWF event
      this.publishEvent(passedValueStr);
   },
   polygonAdded: function(feature) {
      this.polygonLayer.drawControl.deactivate();
      
   },
   clearPolygon: function() {
      if (this.polygonFeature) {
         this.polygonLayer.destroyFeatures([this.polygonFeature]);
      }
   },
   handlePolygonFeatureAdded: function(evt) {
      this.polygonLayer.drawControl.deactivate();
      this.drawPolyAction.enable();
      
      var feature = evt.feature;
      if (feature.geometry.getVertices().length >= 3) {
         this.polygonFeature = feature;
         var passedValueStr = { source: 'NAVIGATION_MAP', type: 'POLYGON', value: feature.geometry.toString() };
         this.publishEvent(passedValueStr);
      }
   },
   polyInstructionPopup: function () {
      var textStyle = 'style="font-size:1.2em;font-weight: bold;font-style: arial sans-serif;"';
      if (!this.polyInstructions) {
         this.polyInstructions = new Ext.Window({
            title: 'Draw Polygon',
            width: 250,
            height: 100,
            y: 25,
            padding: 5,
            resizable: false,
            html: '<p ' + textStyle + '>Click on the map to draw points.</p><br/>' +
                  '<p ' + textStyle + '>Double-click to finish editing.</p>',
            closeAction: 'hide'
         });
      }
      
      this.polyInstructions.show();
      this.polyInstructions.hide.defer(4000, this.polyInstructions);
   },
   initComponent: function() {
      
      try {
         this.widgetEventingController = new Ozone.eventing.Widget('rpc_relay.uncompressed.html'); 
         this.widgetLauncher = new Ozone.launcher.WidgetLauncher(this.widgetEventingController);
      } catch(err){
         logger.debug("Navigation Map Widget: eventInit(): err: " + err);
      }
            
      // Set up standard controls for the map
      this.mapOptions.controls = [
            new OpenLayers.Control.Navigation(),
            new OpenLayers.Control.ScaleLine(),
            new OpenLayers.Control.MousePosition(),
            new OpenLayers.Control.PanZoom()
      ];

      var useGeoServer = false;
      if (this.useGeoServer == 'true') {
    	  useGeoServer = true;
      }
      if (useGeoServer) {
    	  this.baseLayer = new OpenLayers.Layer.WMS(
    		'<%=mapName%>',
    		this.wmsServer, 
    		{LAYERS: this.tileLayer, STYLES: ''},
			{singleTile: true, ratio: 1, isBaseLayer: true}
    	  );
      } else {
    	  // Set up the WMS tile layer - this will be the base layer
	      this.baseLayer = new OpenLayers.Layer.WMS( "WMS Base Layer", 
    		  this.wmsServer, 
    		  {layers: this.tileLayer, isBaseLayer: true}
	      );
      }
      
      /*
      this.baseLayer = new OpenLayers.Layer.GML("WORLD_KML", '../kml/worldBorders.kml', {
         isBaseLayer: true,
         format: OpenLayers.Format.KML,
         formatOptions: {
            'extractStyles': false,
            'extractAttributes': true
         },
         styleMap: new OpenLayers.StyleMap({
           "default": new OpenLayers.Style({
                         strokeColor: "#555555",
                         strokeWidth:1,
                         strokeOpacity:1,
                         fillColor:"#ECE9D8",
                         fillOpacity: 1.0
                         
//                         fontSize: 8,
//                         fontColor:"#C0C0C0",
//                         label : "${name}"
                      })
         }),
         eventListeners:  {
            loadend: function() {
               Ext.select('div.olMap').first().setStyle({background:'#ff0000'}); 
            }
         } 
      });
      */
     
      var cocomStyleMap = new OpenLayers.StyleMap({
         "default": new OpenLayers.Style({
                       //strokeColor: '${strokeColor}',
                       strokeWidth: '${strokeWidth}',
                       strokeOpacity: '${strokeOpacity}',
                       //fillColor: '${fillColor}',
                       fillOpacity: '${fillOpacity}',
                       fontOpacity: '${fontOpacity}',
                       fontFamily: 'Arial, sans-serif',
                       fontColor: '${fontColor}',
                       fontWeight: 'bold'//,
                       //label : "${title}"
                    }),
         "select": new OpenLayers.Style({
                       strokeColor: '#000080',
                       strokeWidth:3,
                       strokeOpacity:1,
                       fontColor: '${fontColor}',
                       fontWeight: 'bold',
                       fillColor:"#0000ff",
                       fillOpacity: 0.6,
                       cursor: 'pointer',
                       label : "${title}"
         })
      });  
            
      // COCOM KML layer
      this.cocomLayer = new OpenLayers.Layer.Vector("COCOM_KML", {
         strategies: [new OpenLayers.Strategy.Fixed()],
         protocol: new OpenLayers.Protocol.HTTP({
             url: this.cocomKML,
             format: new OpenLayers.Format.KML({
                 extractStyles: false, 
                 extractAttributes: true,
                 maxDepth: 2,
                 // OpenLayers default KML parsing, if extractStyles is true,
                 // will override any styleMaps we set. So just pull the style
                 // for the feature into the attributes and reference them in
                 // our custom styleMap so that labels and highlighting work.
                 parseAttributes: function(node) {
                    var args = OpenLayers.Format.KML.prototype.parseAttributes.apply(this, arguments);
                    var style = this.parseStyle(node);
                    Ext.apply(args, style);
                    return args;
                 }
             })
         }),
         styleMap: cocomStyleMap
      });
      // Lower the default opacity some
      this.cocomLayer.setOpacity(0.7);
      
      // When the mouse is over a COCOM area, put the area title in 
      // the mouseover field at the bottom of the screen
      this.cocomLayer.highlightControl = new OpenLayers.Control.SelectFeature(this.cocomLayer, {
         hover: true,
         highlightOnly: true,
         eventListeners: {
            featurehighlighted: function(evt) {
               this.mouseoverField.setValue(evt.feature.attributes.title);
            }.createDelegate(this),
            featureunhighlighted: function(evt) {
               this.mouseoverField.setValue('');
            }.createDelegate(this)
         },
         clickFeature: this.onCOCOMSelect.createDelegate(this)
      });

      // GeoExt slider for setting the layer opacity
      var cocomLayerOpacity = new GeoExt.LayerOpacitySlider({
         width: 100,
         layer: this.cocomLayer,
         aggressive: true,
         tooltip: 'Layer Opacity'
      });
      
      // Set up the country layer
      
      // Use a pseudo-random distribution for country colors if
      // the overrideCountryColors configuration is true
      var colorIdx = 0;
      var colorAry = this.featureColors;
      var ownColors = this.overrideCountryColors;
      
      var countryStyleMap = new OpenLayers.StyleMap({
         "default": new OpenLayers.Style({
                       //strokeColor: ownColors ? '${fillColor}' :'${strokeColor}',
                       strokeWidth: ownColors ? 2 : '${strokeWidth}',
                       strokeOpacity: ownColors ? 1.0 : '${strokeOpacity}',
                       fillColor: '#C0C0C0',//'${fillColor}',
                       fillOpacity: ownColors ? 0.7 : '${fillOpacity}',
                       fontOpacity: 0.7,
                       fontFamily: 'Arial, sans-serif',
                       fontColor: '#eeeeee',
                       fontWeight: 'bold',
                       fontSize: '10px'//,
                       //label : '${title}'
                    }),
         "select": new OpenLayers.Style({
                       strokeColor: '#000080',
                       strokeWidth:3,
                       strokeOpacity:1,
                       fillColor:"#0000ff",
                       fillOpacity: 0.6,
                       cursor: 'pointer',
                       label : '${title}'
         })
      });
      
      this.countryLayer = new OpenLayers.Layer.Vector("COUNTRY_KML", {
         strategies: [new OpenLayers.Strategy.Fixed()],
         protocol: new OpenLayers.Protocol.HTTP({
             url: this.countryKML,
             format: new OpenLayers.Format.KML({
                 extractStyles: false, 
                 extractAttributes: true,
                 // OpenLayers default KML parsing, if extractStyles is true,
                 // will override any styleMaps we set. So just pull the style
                 // for the feature into the attributes and reference them in
                 // our custom styleMap so that labels and highlighting work.
                 parseAttributes: function(node) {
                    var attr = OpenLayers.Format.KML.prototype.parseAttributes.apply(this, arguments);
                    var style = this.parseStyle(node);
                    if (ownColors) {
                       var i = (colorIdx++ + (attr.title.charCodeAt(0))) % colorAry.length;
                       style.fillColor = colorAry[i];
                    }
                    Ext.apply(attr, style);
                    return attr;
                 }
             })
         }),
         styleMap: countryStyleMap
      });
      // Lower the default opacity some
      this.countryLayer.setOpacity(0.7);
      
      this.countryLayer.events.on({ featureselected: this.onFeatureCountrySelect });
      // When the mouse is over a country, put the country name in 
      // the mouseover field at the bottom of the screen
      this.countryLayer.highlightControl = new OpenLayers.Control.SelectFeature(this.countryLayer, {
         hover: true,
         highlightOnly: true,
         eventListeners: {
            featurehighlighted: function(evt) {
               this.mouseoverField.setValue(evt.feature.attributes.title);
            }.createDelegate(this),
            featureunhighlighted: function(evt) {
               this.mouseoverField.setValue('');
            }.createDelegate(this)
         },
         clickFeature: this.onCountrySelect.createDelegate(this)
      });
      
      var countryLayerOpacity = new GeoExt.LayerOpacitySlider({
         width: 100,
         layer: this.countryLayer,
         aggressive: true,
         tooltip: 'Layer Opacity',
         hidden: true
      });
      
      // Set up the polygon layer
      this.polygonLayer = new OpenLayers.Layer.Vector("POLYGON_LAYER");
      this.polygonLayer.drawControl = new OpenLayers.Control.DrawFeature(this.polygonLayer, OpenLayers.Handler.Polygon);
      this.polygonLayer.drawControl.events.on({ featureadded: this.handlePolygonFeatureAdded.createDelegate(this) });
      
      // Set up selection controls
      this.mapOptions.controls.push(this.cocomLayer.highlightControl);
      this.mapOptions.controls.push(this.countryLayer.highlightControl);
      this.mapOptions.controls.push(this.polygonLayer.drawControl);
            
      var map = new OpenLayers.Map(this.mapOptions);
      this.map = map;
      
      this.cocomLayer.highlightControl.activate();
      this.countryLayer.highlightControl.activate();
      
      this.drawPolyAction = new Ext.Action({
         text: 'Draw Polygon',
         icon: this.imagePath + '/shape_square_edit.png',
         hidden: true,
         handler: function() {
            this.polyInstructionPopup();
            this.clearPolygon();
            this.drawPolyAction.disable();
            this.polygonLayer.drawControl.activate();
         },
         scope: this
      });

      var resetOnButtonPress = function() {
         this.clearPolygon();
         this.polygonLayer.drawControl.deactivate();
         this.drawPolyAction.hide();
         countryLayerOpacity.disable();
         cocomLayerOpacity.disable();
      };
      
      this.worldViewButton = new Ext.Button({
          text: 'World View',
          icon: this.imagePath + '/world.png',
          enableToggle: true,
          toggleGroup: 'layerselect',
          pressed: false,
          allowDepress: false,
          handler: function() {
        	  this.worldViewButton.toggle(true);
        	  this.mapPanel.map.zoomToMaxExtent();
              resetOnButtonPress.call(this);
              this.countryLayer.setVisibility(false);
              this.cocomLayer.setVisibility(true);
              countryLayerOpacity.hide();
              cocomLayerOpacity.enable();
              cocomLayerOpacity.show();
              
              this.combo_COCOM.show();
              this.combo_Country.hide();
              
        	  var passedValueStr = { source: 'NAVIGATION_MAP', type: 'WORLDVIEW', value: '' };
              this.publishEvent(passedValueStr);
          },
          scope: this
       });
      
      this.cocomButton = new Ext.Button({
         text: 'COCOM',
         icon: this.imagePath + '/world.png',
         enableToggle: true,
         toggleGroup: 'layerselect',
         pressed: true,
         allowDepress: false,
         handler: function() {
            this.mapPanel.map.zoomToMaxExtent();
            resetOnButtonPress.call(this);
            this.countryLayer.setVisibility(false);
            this.cocomLayer.setVisibility(true);
            countryLayerOpacity.hide();
            cocomLayerOpacity.enable();
            cocomLayerOpacity.show();
            
            this.combo_COCOM.show();
            this.combo_Country.hide();
         },
         scope: this
      });
      
      this.countryButton = new Ext.Button({
         text: 'Countries',
         icon: this.imagePath + '/us.gif',
         enableToggle: true,
         toggleGroup: 'layerselect',
         pressed: false,
         allowDepress: false,         
         handler: function() {
            resetOnButtonPress.call(this);
            this.cocomLayer.setVisibility(false);
            this.countryLayer.setVisibility(true);
            cocomLayerOpacity.hide();
            countryLayerOpacity.enable();
            countryLayerOpacity.show();
            
            this.combo_COCOM.hide();
            this.combo_Country.show();
         },
         scope: this
      });
      
      this.polygonButton = new Ext.Button({
         text: 'Polygon',
         icon: this.imagePath + '/shape_handles.png',
         enableToggle: true,
         toggleGroup: 'layerselect',
         pressed: false,
         allowDepress: false,         
         handler: function() {
            // If we are already in the polygon layer then just ignore the button press.
            if (this.cocomLayer.getVisibility() || this.countryLayer.getVisibility()) {
               resetOnButtonPress.call(this);
               this.cocomLayer.setVisibility(false);
               this.countryLayer.setVisibility(false);
               this.drawPolyAction.enable();
               this.drawPolyAction.show();
               
               this.combo_COCOM.hide();
               this.combo_Country.hide();
            }
         },
         scope: this
      });
      
      this.combo_COCOM = new Ext.form.ComboBox({
			store: new Ext.data.SimpleStore({
				fields	: ['searchType', 'value'],
				data	: getCOCOMDropDownValues()
			}),
			autoSelect 		: true,
			triggerAction	: 'all',
			fieldLabel		: 'Filter Criteria',
			labelStyle		: 'text-align:right;',
			displayField	: 'value',
			valueField		: 'searchType',
			allowBlank		: false,
			editable		: false,
			mode			: 'local',
			width			: 150,
			listeners:{
				'select': this.selectCOCOM.createDelegate(this)		   
		    }
		});
      this.combo_COCOM.show();
      
      this.combo_Country = new Ext.form.ComboBox({
			store: new Ext.data.SimpleStore({
				fields	: ['searchType', 'value'],
				data	: getCountryDropDownValues()
			}),
			autoSelect 		: true,
			triggerAction	: 'all',
			fieldLabel		: 'Filter Criteria',
			labelStyle		: 'text-align:right;',
			displayField	: 'value',
			valueField		: 'searchType',
			allowBlank		: false,
			editable		: false,
			mode			: 'local',
			width			: 225,
			listeners:{
				'select': this.selectCountry.createDelegate(this)
		    }
      });
      this.combo_Country.hide();
      
      this.mouseoverField = new Ext.form.TextField({
         readOnly: true,
         width: 250
      });

      var bounds = null;
      
      if (useGeoServer) {
	      bounds = new OpenLayers.Bounds(-184, -85.53, 180, 83.627);
      } else {
    	  bounds = new OpenLayers.Bounds(-180, -90, 180, 90);
      }
      
      // Wrap the OpenLayer map in an Ext panel using GeoExt
      this.mapPanel = new GeoExt.MapPanel({
         map: map,
         layers: [this.baseLayer, this.polygonLayer, this.cocomLayer, this.countryLayer],
         extent: bounds,//new OpenLayers.Bounds(-180, -90, 180, 90),
         tbar: [
            this.worldViewButton,
            ' ',
            {
               xtype: 'label',
               text: 'Filter by:'
            },
            ' ',
            this.cocomButton,
            ' ',
            this.countryButton,
            ' ',
            this.polygonButton,
            ' ',
            this.drawPolyAction,
            ' ',
            this.combo_COCOM,
            ' ',
            this.combo_Country
         ],
         bbar: [
            {
               xtype: 'label',
               text: 'Mouse over:'
            },
            ' ',
            this.mouseoverField,
            '->',
            {
               xtype: 'label',
               text: 'Layer Opacity:'
            },
            cocomLayerOpacity,
            countryLayerOpacity
         ],
         listeners: {
            render: function() {
               this.countryLayer.setVisibility.defer(1000, this.countryLayer, [false]);
            },
            scope: this
         }
      });
      
      this.items = this.mapPanel;
      
      NavigationMap.superclass.initComponent.call(this);
   }
});