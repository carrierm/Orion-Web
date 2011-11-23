var store;
var editorGrid;

function getData(config) {
	try {
		var url = serverDataPath + "/JSON_Data_List.jsp";
		var jsonContent = postURL(url,null);
		logger.debug('jsonContent: ' + jsonContent);
		return eval(trim(jsonContent));
	} catch (err) {
		logger.debug('Display Grid Widget: getData(): err: ' + err);
	}
}

function drawGridObject(configString) {
	try {
		store = Ext.create('Ext.data.ArrayStore', {
	        fields: [
				{name: 'cr_key'},
				{name: 'cr_name'},
				{name: 'cr_priority'},
				{name: 'resp_org'},
				{name: 'start_dateTime'},
				{name: 'stop_dateTime'},
				{name: 'cocom'}
	        ],
	        pageSize: 50,
	        sortInfo:{field: 'cr_key', direction: "ASC"},
	        data: getData(configString)
	    });
		
		editorGrid = Ext.create('Ext.grid.Panel', {
	        store: store,
	        columns: [
	            new Ext.grid.RowNumberer({width: 30}),
	            {
				 header     : 'CR Key',
				 width     	: 200,
				 align		: 'center',
				 sortable 	: true,
				 dataIndex	: 'cr_key',
				 style		: {"text-align": 'center'},
				 editor: new Ext.form.TextField({
					 readOnly	: true,
					 editable	: false
		         }),
				 renderer	:  function(val, x, store) {
					 return '<div class=\"cellContent\">' + val + '</div>';
				 }
			 }, {
				 header     : 'CR Name',
				 width	 	: 200,
				 sortable 	: true,
				 align		: 'center',
				 dataIndex	: 'cr_name',
				 style		: {"text-align": 'center'},
				 editor: new Ext.form.TextField({
					 readOnly	: true,
					 editable	: false
		         }),
				 renderer	:  function(val, x, store) {
					 return '<div class=\"cellContent\">' + val + '</div>'; 
				 }
			 }, {
				 header     : 'Priority',
				 width    	: 75,
				 sortable 	: true,
				 align		: 'center',
				 dataIndex	: 'cr_priority',
				 style		: {"text-align": 'center'},
				 editor: new Ext.form.TextField({
					 readOnly	: true,
					 editable	: false
		         }),
				 renderer	:  function(val, x, store) {
					 return '<div class=\"cellContent\">' + val + '</div>'; 
				 }
			 }, {
				 header     : 'Responsible Org',
				 width    	: 150,
				 sortable 	: true,
				 align		: 'center',
				 dataIndex	: 'resp_org',
				 style		: {"text-align": 'center'},
				 editor: new Ext.form.TextField({
					 readOnly	: true,
					 editable	: false
		         }),
				 renderer	:  function(val, x, store) {
					 return '<div class=\"cellContent\">' + val + '</div>'; 
				 }
			 }, {
				 header     : 'Start Date',
				 width    	: 125,
				 sortable 	: true,
				 align		: 'center',
				 dataIndex	: 'start_dateTime',
				 style		: {"text-align": 'center'},
				 editor: new Ext.form.TextField({
					 readOnly	: true,
					 editable	: false
		         }),
				 renderer	:  function(val, x, store) {
					 return '<div class=\"cellContent\">' + val + '</div>'; 
				 }
			 }, {
				 header     : 'Stop Date',
				 width    	: 125,
				 sortable 	: true,
				 align		: 'center',
				 dataIndex	: 'stop_dateTime',
				 style		: {"text-align": 'center'},
				 editor: new Ext.form.TextField({
					 readOnly	: true,
					 editable	: false
		         }),
				 renderer	:  function(val, x, store) {
					 return '<div class=\"cellContent\">' + val + '</div>'; 
				 }
			 }
	        ],
	        bbar: new Ext.PagingToolbar({
	            pageSize	: 50,
	            store		: store,
	            displayInfo	: true,
	            displayMsg	: 'Displaying Records {0} - {1} of {2}',
				emptyMsg	: 'No Records To Display',
	            items:[]
	        }),
	        renderTo: Ext.getBody(),
			tbar : [],
	        viewConfig: {
	            stripeRows: true
	        }
	    });
		
		store.load();
	} catch (err) {
		logger.debug("Display Grid Widget: drawGridObject(): err: " + err);
	} 
}

var update = function(sender, msg) {
	try {
		if (!listeningForUpdates) {
			logger.debug("Display Grid Widget: update(): msg: " + msg);
			
			var data = Ozone.util.parseJson(msg);
			if (data.type != null) {
				eventType = data.type;
			}
			store.loadData(getData(msg));
		}
	} catch(err) {
		logger.debug("Display Grid Widget: update(): err: " + err);
	}
}

Ext.onReady(function(){
	Ext.require([
	     'Ext.grid.*',
	     'Ext.window.Window',
	     'Ext.data.*',
	     'Ext.util.*',
	     'Ext.state.*'
     ]);
	
	Ext.QuickTips.init();
	drawGridObject();
});