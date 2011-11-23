/* 
//High Side Map URI
<!-- FUSION MAPS -->
<script src="http://gis.geoint.nga.ic.gov/GoogleEarth/fusionmaps_local.js" type="text/javascript"></script>
<script src="http://gis.geoint.nga.ic.gov/GoogleEarth/fusionmaptypes.js" type="text/javascript"></script>
<script src="http://giatkhsstl01.nga.ic.gov/default_map/query?request=LayerDefs" type="text/javascript"></script>
<script src="http://gis.geoint.nga.ic.gov/GoogleEarth/gmap-wms.js" type="text/javascript"></script>

//GOOGLE MAPS
<script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAzr2EBOXUKnm_jVnk0OJI7xSosDVG8KKPE1-m51RBrvYughuyMxQ-i1QfUnH94QxWIa6N4U6MouMmBA" type="text/javascript"></script>
*/

//URI
//var FUSION_MAP_SERVER = "http://giatkhsstl01.nga.ic.gov";
//var FUSION_MAP_URI = "/default_map";
//Additional Map Types
//var MAPS_WMS_URL_ROUTE = "http://maps.geoint.nga.ic.gov/tiledb/Tile_Server.image?";
//var NGA_WMS_URL_ROUTE = "http://gis.geoint.nga.ic.gov/cgi-bin/muse/webinter/nga_wms.cgi?";

var Map = {}

Map.createOpenLayers = 
	/**
	 *	Helper function that determines map availablity
	 *	and returns a map.
	 */
	function(elLocation)
	{
		//Try Fusion (NGA) maps
		try
		{
			if( InitializeFusionTypes )
				return _createFusionMap(elLocation);		
		}
		catch (err) { /* cannot use Fusion maps */ }
		
		//Google Maps?
		try
		{
			if( GMap2 )
				return _createGoogleMap(elLocation);
		} 
		catch (err) { /* cannot use Fusion maps */ }
		
		//Resort to using this server's maps
		return _createServerMap(elLocation);
	};
	
	
var _createFusionMap =
	function( elLocation )
	{
		var fusion_map_types = InitializeFusionTypes();
		
		var oMap = new OpenLayers.Map( elLocation );
		var oLayer = new OpenLayers.Layer.Google( "Google Hybrid", {type:fusion_map_types[0]});
		
		oMap.addLayer( oLayer );
		
		oMap.setCenter( new OpenLayers.LonLat(0,0),2);
		
		return oMap;
	};
	
var _createGoogleMap =
	function( elLocation )
	{
		//var options = { controls: [	new OpenLayers.Control.MousePosition(),
		
		var options = { controls: [	new OpenLayers.Control.MousePosition( {formatOutput: function(lonLat) { var markup = 'Lat: ' + formatLatLongDMS(lonLat.lat); markup += '&nbsp;&nbsp;&nbsp;Lon: ' + formatLatLongDMS(lonLat.lon); return markup; } } ),
								new OpenLayers.Control.PanZoom(),
								new OpenLayers.Control.ScaleLine()],
					numZoomLevels:5 };
		
		var map = new OpenLayers.Map( elLocation , options );
		var layer = new OpenLayers.Layer.Google( "Google Hybrid" , {type: G_HYBRID_MAP });
	    map.addLayer( layer);
	    map.setBaseLayer( layer );
	    map.setCenter(new OpenLayers.LonLat(0,0), 3); //center and zoom
		
		return map;
	};
	
var _createServerMap =
	function( elLocation )
	{
		//var options = { controls: [	new OpenLayers.Control.MousePosition(),
		
		var options = { controls: [	new OpenLayers.Control.MousePosition( {formatOutput: function(lonLat) { var markup = 'Lat: ' + formatLatLongDMS(lonLat.lat); markup += '&nbsp;&nbsp;&nbsp;Lon: ' + formatLatLongDMS(lonLat.lon); return markup; } } ),
								new OpenLayers.Control.PanZoom(),
								new OpenLayers.Control.ScaleLine()],
					numZoomLevels:5 };
	
		var map = new OpenLayers.Map( elLocation, options );
		
		var layer = new OpenLayers.Layer.WMS( "VMap0", "/maps/tilecache.cgi?", {layers: 'basic', format: 'image/png' } );
		map.addLayer( layer );
		map.setBaseLayer( layer );
		map.setCenter(new OpenLayers.LonLat(0,0), 3); //center and zoom
		
		
		//if ( !  map.getCenter()) 
		//	map.zoomToMaxExtent();
		
		return map;
	};
	
	
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
	
		if( coordinatedegrees < 10 )
		  coordinatedegrees = "0" + coordinatedegrees;
	
		if( coordinateminutes < 10 )
		  coordinateminutes = "0" + coordinateminutes;
	
		if( coordinateseconds < 10 )
		  coordinateseconds = "0" + coordinateseconds;
	
		coords[0] = coordinatedegrees + "&deg;";
		coords[1] = coordinateminutes + "&rsquo;";
		coords[2] = coordinateseconds + "&rdquo;";
	
		formattedString = coords[0]+ "&nbsp;" + coords[1]+ "&nbsp;" + coords[2];
	
		return formattedString;
	}	