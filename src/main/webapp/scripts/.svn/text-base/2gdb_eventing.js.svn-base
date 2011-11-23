/**
 * 
 */

var Ozone;
var logger;
var appender;
var widgetLauncher;

var CHANNEL_NAME = '';
var CHANNEL_NAME_DEFAULT							= "owf.sampleWidget.chart.launcher.crcounts";
var CHANNEL_NAME_crRollup							= "owf.sampleWidget.chart.launcher.crRollup";
var CHANNEL_NAME_crTrends							= "owf.sampleWidget.chart.launcher.crTrends";
var CHANNEL_NAME_collectionRequirements 			= "owf.sampleWidget.chart.launcher.collectionRequirements";
var CHANNEL_NAME_targets 							= "owf.sampleWidget.chart.launcher.targets";
var CHANNEL_NAME_navigationMap 						= "owf.sampleWidget.chart.launcher.navMap";
var CHANNEL_NAME_displayMap 						= "owf.sampleWidget.chart.launcher.displayMap";
var CHANNEL_NAME_targetCollectionHistory 			= "owf.sampleWidget.chart.launcher.targetCollectionHistory";
var CHANNEL_NAME_targetCollectionRequests 			= "owf.sampleWidget.chart.launcher.targetCollectionRequests";
var CHANNEL_NAME_userCollectionRequirments 			= "owf.sampleWidget.chart.launcher.userCollectionRequirements";
var CHANNEL_NAME_userTargets 						= "owf.sampleWidget.chart.launcher.userTargets";

var WIDGET_NAME_CR_List 							= "CR List Widget";
var WIDGET_NAME_CR_Details 							= "CR Details";
var WIDGET_NAME_Target_List 						= "Target List Widget";
var WIDGET_NAME_Target_Details 						= "Target Details";
var WIDGET_NAME_Target_Collection_History 			= "Target Collection History Widget";
var WIDGET_NAME_Target_Collection_History_Details 	= "Target Collection History Details";
var WIDGET_NAME_Target_Collection_Requests 			= "Target Collection Requests Widget";
var WIDGET_NAME_Target_Collection_Request_Details 	= "Target Collection Request Details";
var WIDGET_NAME_User_CR_List 						= "User CR List Widget";
var WIDGET_NAME_User_Target_List 					= "User Target List Widget";

var WIDGET_TO_LAUNCH;
var PASSED_VALUE_STRING;
var SOURCE_WIDGET;

var configString = '';
var configLaunchString = '';
var selectedCocom = '';
var selectedCountry = '';
var arrSelectedCRs = '';
var arrSelectedTargets;

document.write("<script type='text/javascript' src='owf-widget-min.js'></script>");

if(!Array.indexOf){
    Array.prototype.indexOf = function(obj){
        for(var i=0; i<this.length; i++){
            if(this[i]==obj){
                return i;
            }
        }
        return -1;
    }
}

function callGenericWidget() {
	try {
		var searchConfig = {
	    	searchParams:  { widgetName: WIDGET_TO_LAUNCH }, 
	    	onSuccess: launchWidgetTracker, 
	    	onFailure: failWidgetLookupError("Widget was not found in user profile.  User may not have access.")
	 	};
	 	logger.debug('Looking up:'+searchConfig.searchParams.widgetName);
	 	Ozone.pref.PrefServer.findWidgets(searchConfig);
	 	widgetEventingController.publish(CHANNEL_NAME, configString);
	} catch(err) {
		logger.debug('callGenericWidget() err: ' + err);
	}
}

function lookupCRListWidget(config) {
	try {
		CHANNEL_NAME = CHANNEL_NAME_collectionRequirements;
		configString = Ozone.util.toString(config);
		WIDGET_TO_LAUNCH = "CR List Widget";
		callGenericWidget();
	} catch(err) {
		logger.debug('lookupCRListWidget() err: ' + err);
	}
}

function lookupTargetListWidget() {
	try {
		var data;
		CHANNEL_NAME = CHANNEL_NAME_targets;
		if (selectedCocom != '') {
			data = {channel: CHANNEL_NAME, cocom: selectedCocom};
		} else {
			data = {channel: CHANNEL_NAME};
		}
    	configString = Ozone.util.toString(data);
		WIDGET_TO_LAUNCH = "Target List Widget";
		callGenericWidget();
	} catch(err) {
		logger.debug('lookupTargetListWidget() err: ' + err);
	}
}

function lookupDisplayMapWidget() {
	try {
		WIDGET_TO_LAUNCH = "Display Map";
		CHANNEL_NAME = CHANNEL_NAME_displayMap;
		var data;
		if (arrSelectedCRs != '') {
			data = {channel: CHANNEL_NAME, source: "CR_LIST", type: "CRLIST", value: arrSelectedCRs};
		} else if (arrSelectedTargets != '') {
			data = {channel: CHANNEL_NAME, source: "TARGET_LIST", type: "TARGETLIST", value: arrSelectedTargets};
		} else if (selectedCocom != '') {
			data = {channel: CHANNEL_NAME, source: "NAVIGATION_MAP", type: "COCOM", cocom: selectedCocom};
		} else if (selectedCountry != '') {
			data = {channel: CHANNEL_NAME, source: "NAVIGATION_MAP", type: "COUNTRY", country: selectedCountry};
		} else {
			data = {channel: CHANNEL_NAME, source: "NAVIGATION_MAP" };
		}
    	configString = Ozone.util.toString(data);
    	callGenericWidget();
	} catch(err) {
		logger.debug('lookupDisplayMapWidget() err: ' + err);
	}
}

function lookupTargetCollectionRequestsWidget() {
	try {
		var data;
		CHANNEL_NAME = CHANNEL_NAME_targetCollectionRequests;
		if (selectedCocom != '') {
			data = {channel: CHANNEL_NAME, cocom: selectedCocom};
		} else {
			data = {channel: CHANNEL_NAME};
		}
    	configString = Ozone.util.toString(data);
		WIDGET_TO_LAUNCH = "Target Collection Requests Widget";
		callGenericWidget();
	} catch(err) {
		logger.debug('lookupTargetCollectionRequestsWidget() err: ' + err);
	}
}

function lookupTargetCollectionHistoryWidget(cocom_Selected) {
	try {
		CHANNEL_NAME = CHANNEL_NAME_targetCollectionHistory;
		var data = {channel: CHANNEL_NAME, cocom: cocom_Selected};
    	configString = Ozone.util.toString(data);
		WIDGET_TO_LAUNCH = "Target Collection History Widget";
		callGenericWidget();
	} catch(err) {
		logger.debug('lookupTargetCollectionHistoryWidget() err: ' + err);
	}
}

function lookupUserTargetListWidget() {
	try {
		CHANNEL_NAME = CHANNEL_NAME_userTargets;
		var data = {channel: CHANNEL_NAME, source: "TARGET_LIST"};
    	configString = Ozone.util.toString(data);
		WIDGET_TO_LAUNCH = "User Target List Widget";
		callGenericWidget();
	} catch(err) {
		logger.debug('lookupUserTargetListWidget() err: ' + err);
	}
}

function lookupUserCRListWidget() {
	try {
		CHANNEL_NAME = CHANNEL_NAME_userCollectionRequirments;
		var data = {channel: CHANNEL_NAME, source: "CR_LIST"};
    	configString = Ozone.util.toString(data);
		WIDGET_TO_LAUNCH = "User CR List Widget";
		callGenericWidget();
	} catch(err) {
		logger.debug('lookupUserCRListWidget() err: ' + err);
	}
}

function updateUserCRList(action) {
	var returnValue = true;
	try {
		if (arrSelectedCRs != null && arrSelectedCRs != '' && action!=null && action != '') {
			var url = "../jsp/JSON/User_CR_List_Update.jsp?ACTION='" + action + "'&CRLIST='" + arrSelectedCRs+"'";
			var responseVal = postURL(url,null);
			var result = trim(responseVal);
			if (result != 'success') {
				returnValue = false;
			}
		} else {
			returnValue = false;
		}
	} catch(err) {
		logger.debug('updateUserCRList() err: ' + err);
	}
	return returnValue;
}

function updateUserTargetList(action) {
	var returnValue = true;
	try {
		if (arrSelectedTargets != null && arrSelectedTargets != '' && action!=null && action != '') {
			var url = "JSON/User_Target_List_Update.jsp?ACTION='" + action + "'&TARGETLIST='" + arrSelectedTargets+"'";
			var responseVal = postURL(url,null);
			var result = trim(responseVal);
			if (result != 'success') {
				returnValue = false;
			}
		} else {
			returnValue = false;
		}
	} catch(err) {
		logger.debug('updateUserTargetList() err: ' + err);
	}
	return returnValue;
}

function getAllCRWidgetDetails(config) {
	try {
		CHANNEL_NAME = CHANNEL_NAME_collectionRequirements;
		configString = Ozone.util.toString(config);
		WIDGET_TO_LAUNCH = "CR Details";
		callGenericWidget();
	} catch(err) {
		logger.debug('getAllCRWidgetDetails() err: ' + err);
	}
}

function getAllTargetWidgetDetails(config) {
	try {
		CHANNEL_NAME = CHANNEL_NAME_targets;
		configString = Ozone.util.toString(config);
		WIDGET_TO_LAUNCH = "Target Details";
		callGenericWidget();
	} catch(err) {
		logger.debug('getAllTargetWidgetDetails() err: ' + err);
	}
}

function getTargetCollectionRequests(config){
	try {
		CHANNEL_NAME = CHANNEL_NAME_targetCollectionRequests;
		WIDGET_TO_LAUNCH = "Target Collection Requests Widget"; 
		var launchConfig = Ozone.util.toString(config);
		var configJSON = Ozone.util.parseJson(launchConfig);
		var data;
		if (configJSON.cr_key != null) {
			data = {channel: CHANNEL_NAME, type: "CR_KEY", value: configJSON.cr_key};
		} else if (configJSON.target_key != null) {
			data = {channel: CHANNEL_NAME, type: "TARGET_KEY", value: configJSON.target_key};
		} else {
			data = {channel: CHANNEL_NAME};
		}
		logger.debug('configJSON target_key: ' + configJSON.target_key);
		configString = Ozone.util.toString(data);
		logger.debug('configString: ' + configString);
		callGenericWidget();
	} catch(err) {
		logger.debug.debug('getTargetCollectionRequests() err: ' + err);
	}
}

function getAllTargetCollectionRequestWidgetDetails(config){
	try {
		CHANNEL_NAME = CHANNEL_NAME_targetCollectionRequests;
		configString = Ozone.util.toString(config);
		WIDGET_TO_LAUNCH = "Target Collection Request Details"; 
		callGenericWidget();
	} catch(err) {
		logger.debug.debug('getAllTargetCollectionRequestWidgetDetails() err: ' + err);
	}
}

function getTargets(config){
	try {
		CHANNEL_NAME = CHANNEL_NAME_targets;
		WIDGET_TO_LAUNCH = "Target List Widget"; 
		var launchConfig = Ozone.util.toString(config);
		var configJSON = Ozone.util.parseJson(launchConfig);
		var data;
		if (configJSON.cr_key != null) {
			data = {channel: CHANNEL_NAME, type: "CR_KEY", value: configJSON.cr_key};
		} else {
			data = {channel: CHANNEL_NAME};
		}
		configString = Ozone.util.toString(data);
		callGenericWidget();
	} catch(err) {
		logger.debug('getTargets() err: ' + err);
	}
}

function getTargetHistory(config){
	try {
		CHANNEL_NAME = CHANNEL_NAME_targetCollectionHistory;
		WIDGET_TO_LAUNCH = "Target Collection History Widget"; 
		var launchConfig = Ozone.util.toString(config);
		var configJSON = Ozone.util.parseJson(launchConfig);
		var data;
		if (configJSON.target_key != null) {
			data = {channel: CHANNEL_NAME, type: "TARGET_KEY", value: configJSON.target_key};
		} else {
			data = {channel: CHANNEL_NAME};
		}
		configString = Ozone.util.toString(data);

		callGenericWidget();
	} catch(err) {
		logger.debug('getTargetHistory() err: ' + err);
	}
}

function getAllTargetCollectionHistoryWidgetDetails(config){
	try {
		WIDGET_TO_LAUNCH = "Target Collection History Details"; 
		CHANNEL_NAME = CHANNEL_NAME_targetCollectionHistory;
		configString = Ozone.util.toString(config);
		callGenericWidget();
	} catch(err) {
		logger.debug.debug('getAllTargetCollectionHistoryWidgetDetails() err: ' + err);
	}
}

/**
 *  Look up the launched widget in OWF, for the purpose of acquiring its GUID
 */
function lookupWidget( WIDGET_NAME) {
	try {
		WIDGET_TO_LAUNCH = WIDGET_NAME;
		var searchConfig = {
	    	searchParams:  { widgetName: WIDGET_TO_LAUNCH }, 
	    	onSuccess: launchWidgetTracker, 
	    	onFailure: failWidgetLookupError("")
	 	};
	 	logger.debug('Looking up:'+searchConfig.searchParams.widgetName);
	 
	 	Ozone.pref.PrefServer.findWidgets(searchConfig);
	} catch(err) {
		logger.debug('lookupWidget() err: ' + err);
	}
}
 
/**
* Launch the WidgetTracker; called as a callback from findWidgets() on success
*/
function launchWidgetTracker (findResultsResponseJSON) {
	try {
		logger.debug('Search result:'+ findResultsResponseJSON);
	 	if(findResultsResponseJSON.length == 0) {
	    	// Did not find Widget
	    	failWidgetLookupError("Widget was not found in user profile.  User may not have access.");
	 	}
	    else {
	    	var guidOfWidgetToLaunch = findResultsResponseJSON[0].path;
	    	logger.debug('Search result [GUID]:'+ guidOfWidgetToLaunch);
	       
	    	var data = {channel: CHANNEL_NAME};
	    	var dataString = Ozone.util.toString(data);
	    	
	    	var data_string = '';
	    	if (configString != '') {
	    		data_string = configString;
	    	} else {
	    		data_string = dataString;
	    	}

	    	if (widgetLauncher == null) {
	    		eventInit();
	    	}

	        widgetLauncher.launchWidget(
	        {
	           guid: guidOfWidgetToLaunch,  	// The retrieved GUID of the widget to launch
	           launchOnlyIfClosed: true, 		// If true will only launch the widget if it is not already opened.
	           data: data_string  				// Initial launch config data to be passed to 
	                             				// a widget only if the widget is opened.  This must be a string!
	        }, 
	        callbackOnLaunch
	        );
	    }
	} catch(err) {
		logger.debug('launchWidgetTracker() err: ' + err);
	}
}

/**
 * Display an error when a widget cannot be located
 */
function failWidgetLookupError(widgetLookupErrorMessage) {
	try {
		logger.debug('Launch Failure: [' + WIDGET_TO_LAUNCH +']: ' + widgetLookupErrorMessage);
	    //document.getElementById("error-panel").innerHTML= "Launch Failure: [" + WIDGET_TO_LAUNCH +"]: " + widgetLookupErrorMessage;
	} catch(err) {
		logger.debug('failWidgetLookupError() err: ' + err);
	}
}

/**
  *  Widget Launching callback function indicating success or failure
 */
function callbackOnLaunch (resultJson) {
	try {
		var launchResultsMessage = "";
		
		if(resultJson.error) {
			// if there was an error, print that out on the launching widget
			launchResultsMessage += ("Launch Error:" + resultJson.message);
		}
		
		if(resultJson.newWidgetLaunched) {
			// if the new widget was launched, say so
			launchResultsMessage += ("Widget Launched; new unique id: " + resultJson.uniqueId);
		}
		else {
			// if the new widget was not launched, say so and explain why not
			launchResultsMessage += ("Launch Error: " + resultJson.message  + " Widget exists already with id: " + resultJson.uniqueId);               
		}
	} catch (err) {
		logger.debug('callbackOnLaunch() err: ' + err);
	}
}

function logInit() {
	try {
		// Initialize logging objects
		Ozone = Ozone || {};
	    Ozone.log = Ozone.log || {};
	    Ozone.util = Ozone.util || {};
	 	   
	    logger = Ozone.log.getDefaultLogger();
	    Ozone.log.setEnabled(true);
	
	    appender = logger.getEffectiveAppenders()[0];
	    appender.setThreshold(log4javascript.Level.DEBUG);
	} catch (err) {
		alert("logInit() err: " + err);
	}
}
   
function eventInit() {
	try {
		this.widgetEventingController = new Ozone.eventing.Widget('rpc_relay.uncompressed.html'); 
		this.widgetLauncher = new Ozone.launcher.WidgetLauncher(this.widgetEventingController);
	} catch (err) {
		alert("eventInit() err: " + err);
	}
}

function updateInit() {
	try {
		var launchConfig = Ozone.launcher.WidgetLauncherUtils.getLaunchConfigData();
		if(!launchConfig) {
			 // Receive clock broadcast in a default manner
			 var scope = this;
			 this.gadgetEventingController = new Ozone.eventing.Widget('rpc_relay.uncompressed.html',
				function() {
				   scope.gadgetEventingController.subscribe.apply(scope,["ClockChannel", scope.update]);
				   scope.update;
			 });
		}
		else {
			// We are expecting the channel to listen on to be passed in dynamically.
			// Update it on the page
			var launchConfigJson = Ozone.util.parseJson(launchConfig);				
			var channelToUse = launchConfigJson.channel;
			var scope = this;
			this.gadgetEventingController = new Ozone.eventing.Widget('rpc_relay.uncompressed.html',
			   function() {
				  scope.gadgetEventingController.subscribe.apply(scope,[channelToUse, scope.update]); 
				  scope.update;
			   }
			);
		}
	} catch(err) {
		logger.debug('updateInit() err: ' + err);
	}
}

function initPage() {
	try {
		logInit();
		eventInit();
		updateInit();
	} catch (err) {
		alert("initPage() err: " + err);
	}
}

function initPrefs() {
	Ozone.pref.PrefServer.getUserPreference(  {namespace:'mil.ono.gdb.Map', 
		name:'PASSED_VALUE_STRING', 
		onSuccess:function(){}, 
		onFailure:onGetFailure} );
}   

function onGetFailure(error,status) {
	if (status != 404) {
		Ozone.util.ErrorDlg.show("Got an error getting preferences! Status Code: " + status + " . Error message: " + error);
	}
}

function setConfigString(config_string) {
	this.configString = config_string;
}

function getConfigString() {
	return this.configString;
}

function setSelectedCocom(cocom_selected) {
	this.selectedCocom = cocom_selected;
}

function setSelectedCountry(country_selected) {
	this.selectedCountry = country_selected;
}

function setSelectedCRs(selectedCRs) {
	this.arrSelectedCRs = selectedCRs;
}

function setSelectedTargets(selectedTargets) {
	this.arrSelectedTargets = selectedTargets;
}

function checkCharacters(stringValue) {
	stringValue = escape(stringValue);
	
	return stringValue;
}

function createFeedbackForm(widgetName) {
	try {
		var feedbackForm;
		var feedbackWindow;
		
		var NameField;
		var CompanyField;
		var WidgetNameField;
		var EmailField;		
		var SubjectField;
		var MessageField;
		
		function listSearch(){
			try {
				feedbackWindow.close();
			} catch(err) {
				logger.debug("CR List Widget: listSearch(): err: " + err);
			}
		}

		function resetSearch() {
			try {
				feedbackWindow.close();
			} catch(err) {
				logger.debug("CR List Widget: resetSearch(): err: " + err);
			}
		}

		NameField = new Ext.form.TextField({
			fieldLabel	: 'Your Name',
			emptyText	: 'Enter First and Last Name',
			name		: 'name',
			width		: 300,
			allowBlank	: false,
			labelStyle	: 'margin-left:5px; width:95px;',
			anchor 		: '100%'
		});
		
		CompanyField = new Ext.form.TextField({
			fieldLabel	: 'Your Name',
			emptyText	: 'Enter Company Name',
			name		: 'company',
			width		: 300,
			//allowBlank	: false,
			labelStyle	: 'margin-left:5px; width:95px;',
			anchor 		: '100%'
		});
		
		WidgetNameField = new Ext.form.TextField({
			fieldLabel	: 'Widget Name',
			name		: 'widgetName',
			value		: widgetName,
			labelStyle	: 'margin-left:5px; width:95px;',
			disabled	: true,
			readOnly	: true,
			editable	: false,
			width		: 300,
			allowBlank	: false,
			anchor 		: '100%'
		});
		
		EmailField = new Ext.form.TextField({
			fieldLabel	: 'Contact Email',
			name		: 'emailAddress',
			vtype		: 'email',
			width		: 300,
			emptyText	: 'Enter e-mail address',
			labelStyle	: 'margin-left:5px; width:95px;',
			allowBlank	: false,
			anchor 		: '100%'
		});
		
		SubjectField = new Ext.form.TextField({
			fieldLabel	: 'Subject',
			emptyText	: 'Enter a subject',
			width		: 300,
			labelStyle	: 'margin-left:5px; width:95px;',
			allowBlank	: false,
			anchor 		: '100%'
		});
		
		MessageField = new Ext.form.TextArea({
			fieldLabel	: 'Feedback',
			name		: 'message',
			labelAlign	: 'top',
			width		: 300,
			height		: 100,
			labelStyle	: 'margin-left:5px; width:95px;',
            allowBlank	: false,
			anchor 		: '100%'
		});
		
		feedbackForm = new Ext.form.FormPanel({
			url			: 'JSON/UserFeedbackForm.jsp',
			bodyStyle	: 'padding: 5px',
			resizable	: false,
			collapsible	: false,
			x: 0, y: 0,
			height		: 1000,
			draggable	: false,
			minimizable	: false,
			autoScroll	: true,
			autoDestroy	: true,
			layout: {
                type: 'vbox',
                align: 'stretch'
            },
            border: false,
            bodyPadding: 10,
            fieldDefaults: {
                labelAlign: 'top',
                labelWidth: 100,
                labelStyle: 'font-weight:bold'
            },
			defaults	: {
                margins: '0 0 10 0'
            },
			items		: [{
				layout	: 'form',
				items: [
					{
					   html: 'Use This Form To Provide Feedback on comments',
					   border: false,
					   cls: 'x-form-item custom-label'
					}, {
			        	xtype : 'container',layout : 'column', anchor : '100%', defaultType : 'field',
			        	items : [
							{ xtype  : 'container', layout : 'form', style: {"padding-top": '10px'}, items : [ NameField ]}
			        	]
			        }, {
			        	xtype : 'container',layout : 'column', anchor : '100%', defaultType : 'field',
			        	items : [
							{ xtype  : 'container', layout : 'form', style: {"padding-top": '10px'}, items : [ CompanyField ]}
			        	]
			        }, {
			        	xtype : 'container',layout : 'column', anchor : '100%', defaultType : 'field',
			        	items : [
			        	     { xtype  : 'container', layout : 'form', style: {"padding-top": '10px'}, items : [ WidgetNameField ]}
			        	]
			        }, {
			        	xtype : 'container',layout : 'column', anchor : '100%', defaultType : 'field',
			        	items : [
			        	     { xtype  : 'container', layout : 'form', style: {"padding-top": '10px'}, items : [ EmailField ]}
						]
			        }, {
			        	xtype : 'container',layout : 'column', anchor : '100%', defaultType : 'field',
			        	items : [
			        	     { xtype  : 'container', layout : 'form', style: {"padding-top": '10px'}, items : [ SubjectField ]}
			        	]
			        }, {
			        	xtype : 'container',layout : 'column', anchor : '100%', defaultType : 'field',
			        	items : [
			        	     { xtype  : 'container', layout : 'form', style: {"padding-top": '10px'}, items : [ MessageField ]}
			        	]
			        }
				]
			}]
		});

		feedbackWindow = new Ext.Window({
			title		: 'Submit Feedback',
			closable	: true,
			width		: 435,
			height		: 400,
			minWidth	: 435,
	        minHeight	: 365,
			plain		: true,
			layout		: 'fit',
			items		: feedbackForm,
			buttons: [{
                text: 'Submit',
                handler: function() {
                	function isValid() {
                		var valid = true;
                		if (NameField.getValue() == '' || EmailField.getValue() == '' || SubjectField.getValue() == '' || MessageField.getValue() == '' ) {
                			valid = false;
                		}
                		return valid;
                	}
                	function getResponseFromURL(){
                		var name = encodeURIComponent(NameField.getValue());
                		var company = '';
                		if (CompanyField.getValue != '') {
                			company = encodeURIComponent(CompanyField.getValue());
                		}
                        var emailAddress = encodeURIComponent(EmailField.getValue());
                        var widgetName = encodeURIComponent(WidgetNameField.getValue());
                        var subject = encodeURIComponent(SubjectField.getValue());
                        var message = encodeURIComponent(MessageField.getValue());
                        
                        var url = 'JSON/UserFeedbackForm.jsp?name='+name+'&company='+company+'&widgetName='+widgetName+'&emailAddress='+emailAddress+'&subject='+subject+'&message='+message;
                        var responseVal = postURL(url,null);
                		return trim(responseVal);
                	}
                	
                	try {
                		var submittedForm = feedbackForm;
	                    if (isValid()) {
	                        var result = getResponseFromURL();
	                        logger.debug('result: ' + result);
	                        if (result == 'success') {
	                        	Ext.MessageBox.alert('Thank You For Your Feedback!', 'Your Feedback has been sent. We will respond as soon as possible.');
	                        } else {
	                        	Ext.MessageBox.alert('Error', 'An error has occurred sending your feedback. Please contact your system administrator or try again later');
	                        }
	                        feedbackWindow.hide();
	                    } else {
	                    	Ext.MessageBox.alert("Please Provide All Required Information");
	                    }
                	} catch(err) {
                		logger.debug('createFeedbackForm err: ' + err);
                	}
                }
            }, {
                text: 'Cancel',
                handler: function() {
                	feedbackWindow.hide();
                }
            }]
		});

		// once all is done, show the search window
		feedbackWindow.show();
	} catch(err) {
		logger.debug("CR List Widget: startAdvancedSearch(): err: " + err);
	}
}

function getCountryDropDownValues() {
	var countryValues = [
		['AFG','AFGHANISTAN'], ['ALB','ALBANIA'], ['DZA','ALGERIA'], ['ASM','AMERICAN SAMOA'], ['AND','ANDORRA'], 
		['AIA','ANGUILLA'], ['ATA','ANTARCTICA'], ['ATG','ANTIGUA AND BARBUDA'], ['ARG','ARGENTINA'], ['ARM','ARMENIA'], 
		['AUS','AUSTRALIA'], ['AUT','AUSTRIA'], ['AZE','AZERBAIJAN'], ['BHS','BAHAMAS'], ['BHR','BAHRAIN'], 
		['BRB','BARBADOS'], ['BLR','BELARUS'], ['BEL','BELGIUM'], ['BLZ','BELIZE'], ['BEN','BENIN'], 
		['BTN','BHUTAN'], ['BOL','BOLIVIA'], ['BIH','BOSNIA AND HERZEGOWINA'], ['BWA','BOTSWANA'], ['BVT','BOUVET ISLAND'], 
		['IOT','BRITISH INDIAN OCEAN TERRITORY'], ['BRN','BRUNEI DARUSSALAM'], ['BGR','BULGARIA'], ['BFA','BURKINA FASO'], ['BDI','BURUNDI'], 
		['CMR','CAMEROON'], ['CAN','CANADA'], ['CPV','CAPE VERDE'], ['CYM','CAYMAN ISLANDS'], ['CAF','CENTRAL AFRICAN REPUBLIC'], 
		['CHL','CHILE'], ['CHN','CHINA'], ['CXR','CHRISTMAS ISLAND'], ['CCK','COCOS (KEELING) ISLANDS'], ['COL','COLOMBIA'], 
		['COG','CONGO'], ['COD','CONGO, THE DRC'], ['COK','COOK ISLANDS'], ['CRI','COSTA RICA'], ['CIV','COTE D\'IVOIRE'], 
		['CUB','CUBA'], ['CYP','CYPRUS'], ['CZE','CZECH REPUBLIC'], ['DNK','DENMARK'], ['DJI','DJIBOUTI'], 
		['DOM','DOMINICAN REPUBLIC'], ['TMP','EAST TIMOR'], ['ECU','ECUADOR'], ['EGY','EGYPT'], ['SLV','EL SALVADOR'], 
		['ERI','ERITREA'], ['EST','ESTONIA'], ['ETH','ETHIOPIA'], ['FLK','FALKLAND ISLANDS (MALVINAS)'], ['FRO','FAROE ISLANDS'], 
		['FIN','FINLAND'], ['FRA','FRANCE'], ['FXX','FRANCE'], ['GUF','FRENCH GUIANA'], ['PYF','FRENCH POLYNESIA'], 
		['GAB','GABON'], ['GMB','GAMBIA'], ['GEO','GEORGIA'], ['DEU','GERMANY'], ['GHA','GHANA'], 
		['GRC','GREECE'], ['GRL','GREENLAND'], ['GRD','GRENADA'], ['GLP','GUADELOUPE'], ['GUM','GUAM'], 
		['GIN','GUINEA'], ['GNB','GUINEA-BISSAU'], ['GUY','GUYANA'], ['HTI','HAITI'], ['HMD','HEARD AND MC DONALD ISLANDS'], 
		['HND','HONDURAS'], ['HKG','HONG KONG'], ['HUN','HUNGARY'], ['ISL','ICELAND'], ['IND','INDIA'], 
		['IRN','IRAN'], ['IRQ','IRAQ'], ['IRL','IRELAND'], ['ISR','ISRAEL'], ['ITA','ITALY'], 
		['JPN','JAPAN'], ['JOR','JORDAN'], ['KAZ','KAZAKHSTAN'], ['KEN','KENYA'], ['KIR','KIRIBATI'], 
		['KOR','KOREA, REPUBLIC OF'], ['KWT','KUWAIT'], ['KGZ','KYRGYZSTAN'], ['LAO','LAOS'], ['LVA','LATVIA'], 
		['LSO','LESOTHO'], ['LBR','LIBERIA'], ['LBY','LIBYAN ARAB JAMAHIRIYA'], ['LIE','LIECHTENSTEIN'], ['LTU','LITHUANIA'], 
		['MAC','MACAU'], ['MKD','MACEDONIA'], ['MDG','MADAGASCAR'], ['MWI','MALAWI'], ['MYS','MALAYSIA'], 
		['MLI','MALI'], ['MLT','MALTA'], ['MHL','MARSHALL ISLANDS'], ['MTQ','MARTINIQUE'], ['MRT','MAURITANIA'], 
		['MYT','MAYOTTE'], ['MEX','MEXICO'], ['FSM','MICRONESIA, FEDERATED STATES OF'], ['MDA','MOLDOVA'], ['MCO','MONACO'], 
		['MSR','MONTSERRAT'], ['MAR','MOROCCO'], ['MOZ','MOZAMBIQUE'], ['MMR','BURMA (MYANMAR)'], ['NAM','NAMIBIA'], 
		['NPL','NEPAL'], ['NLD','NETHERLANDS'], ['ANT','NETHERLANDS ANTILLES'], ['NCL','NEW CALEDONIA'], ['NZL','NEW ZEALAND'], 
		['NER','NIGER'], ['NGA','NIGERIA'], ['NIU','NIUE'], ['NFK','NORFOLK ISLAND'], ['MNP','NORTHERN MARIANA ISLANDS'], 
		['OMN','OMAN'], ['PAK','PAKISTAN'], ['PLW','PALAU'], ['PAN','PANAMA'], ['PNG','PAPUA NEW GUINEA'], 
		['PER','PERU'], ['PHL','PHILIPPINES'], ['PCN','PITCAIRN'], ['POL','POLAND'], ['PRT','PORTUGAL'], 
		['QAT','QATAR'], ['REU','REUNION'], ['ROM','ROMANIA'], ['RUS','RUSSIA'], ['RWA','RWANDA'], 
		['LCA','SAINT LUCIA'], ['VCT','SAINT VINCENT & GRENADINES'], ['WSM','SAMOA'], ['SMR','SAN MARINO'], ['STP','SAO TOME AND PRINCIPE'], 
		['SEN','SENEGAL'], ['SYC','SEYCHELLES'], ['SLE','SIERRA LEONE'], ['SGP','SINGAPORE'], ['SVK','SLOVAKIA'], 
		['SLB','SOLOMON ISLANDS'], ['SOM','SOMALIA'], ['ZAF','SOUTH AFRICA'], ['SGS','GEORGIA'], ['ESP','SPAIN'], 
		['SHN','ST. HELENA'], ['SPM','ST. PIERRE AND MIQUELON'], ['SDN','SUDAN'], ['SUR','SURINAME'], ['SJM','SVALBARD AND JAN MAYEN ISLANDS'], 
		['SWE','SWEDEN'], ['CHE','SWITZERLAND'], ['SYR','SYRIA'], ['TWN','TAIWAN'], ['TJK','TAJIKISTAN'], 
		['THA','THAILAND'], ['TGO','TOGO'], ['TKL','TOKELAU'], ['TON','TONGA'], ['TTO','TRINIDAD & TOBAGO'], 
		['TUR','TURKEY'], ['TKM','TURKMENISTAN'], ['TCA','TURKS & CAICOS ISLANDS'], ['TUV','TUVALU'], ['UGA','UGANDA'], 
		['ARE','UNITED ARAB EMIRATES'], ['GBR','UNITED KINGDOM'], ['USA','UNITED STATES'], ['UMI','U.S. MINOR ISLANDS'], ['URY','URUGUAY'], 
		['VUT','VANUATU'], ['VEN','VENEZUELA'], ['VNM','VIETNAM'], ['VGB','BRITISH VIRGIN ISLANDS'], ['VIR','U.S. VIRGIN ISLANDS'], 
		['ESH','WESTERN SAHARA'], ['YEM','YEMEN'], ['YUG','YUGOSLAVIA (SERBIA AND MONTENEGRO)'], ['ZMB','ZAMBIA'], ['ZWE ','ZIMBABWE']
	];
	return countryValues;
}

function getCOCOMDropDownValues() {
	var cocomValues = [
		['AFRICOM', 'AFRICOM'], ['CENTCOM', 'CENTCOM'], ['EUCOM', 'EUCOM'], ['NORTHCOM', 'NORTHCOM'], ['PACOM', 'PACOM'], ['SOUTHCOM', 'SOUTHCOM']
	];
	return cocomValues;
}

function getClassificationDropDownValues() {
	var classificationValues = [
		['UNCLASSIFIED', 'UNCLASSIFIED'], ['SECRET', 'SECRET'], ['TOP SECRET', 'TOP SECRET']
	];
	return classificationValues;
}

function createTextField(fieldLabel, width, anchor) {
	var textField = new Ext.form.TextField({
		fieldLabel	: fieldLabel,
		width		: width,
		anchor 		: anchor
	});
	return textField;
}

function createDateField(fieldLabel, width, anchor) {
	var dateField = new Ext.form.DateField({
		fieldLabel	: fieldLabel,
		format 		: 'Y-m-d',
		width		: width,
		anchor 		: anchor
	});
	return dateField;
}

function createTextFieldDropDown(fieldLabel, labelStyle, width, selectFirst) {
	var comboBox = new Ext.form.ComboBox({
		store: new Ext.data.SimpleStore({
			fields	: ['searchType', 'value'],
			data	: [['Contains','Contains'], ['Extactly','Exactly']]
		}),
		autoSelect 		: true,
		triggerAction	: 'all',
		fieldLabel		: fieldLabel,
		labelStyle		: labelStyle,
		displayField	: 'value',
		valueField		: 'searchType',
		allowBlank		: false,
		editable		: false,
		mode			: 'local',
		width			: width
	});
	if (selectFirst) {
		comboBox.setValue(comboBox.store.collect('searchType', true)[0]);
	}
	
	return comboBox;
}

function createNumericDropDown(fieldLabel, labelStyle, width, selectFirst) {
	var comboBox = new Ext.form.ComboBox({
		store: new Ext.data.SimpleStore({
			fields	: ['searchType', 'value'],
			data	: [['Extactly','Exactly'],['Less Than','Less Than'],['Greater Than', 'Greater Than']]
		}),
		autoSelect 		: true,
		triggerAction	: 'all',
		fieldLabel		: fieldLabel,
		labelStyle		: labelStyle,
		displayField	: 'value',
		valueField		: 'searchType',
		allowBlank		: false,
		editable		: false,
		mode			: 'local',
		width			: width
	});
	if (selectFirst) {
		comboBox.setValue(comboBox.store.collect('searchType', true)[0]);
	}
	
	return comboBox;
}

function createDateFieldDropDown(fieldLabel, labelStyle, width, selectFirst) {
	var comboBox = new Ext.form.ComboBox({
		store: new Ext.data.SimpleStore({
			fields	: ['searchType', 'value'],
			data	: [['Exact Date','Exact Date'], ['Before/Up To','Before/Up To'], ['After/Starting From', 'After/Starting From']]
		}),
		autoSelect 		: true,
		triggerAction	: 'all',
		fieldLabel		: fieldLabel,
		labelStyle		: labelStyle,
		displayField	: 'value',
		valueField		: 'searchType',
		allowBlank		: false,
		editable		: false,
		mode			: 'local',
		width			: width
	});
	if (selectFirst) {
		comboBox.setValue(comboBox.store.collect('searchType', true)[0]);
	}
	
	return comboBox;
}

function createCustomDataDropDown(customDataValues, fieldLabel, labelStyle, width, selectFirst) {
	var comboBox = new Ext.form.ComboBox({
		store: new Ext.data.SimpleStore({
			fields	: ['searchType', 'value'],
			data	: customDataValues
		}),
		autoSelect 		: true,
		triggerAction	: 'all',
		fieldLabel		: fieldLabel,
		labelStyle		: labelStyle,
		displayField	: 'value',
		valueField		: 'searchType',
		editable		: false,
		mode			: 'local',
		width			: width
	});
	if (selectFirst) {
		comboBox.setValue(comboBox.store.collect('searchType', true)[0]);
	}
	return comboBox;
}

function createButton(buttonText, buttonWidth, handlerMethod) {
	var button = new Ext.Button({
		text    : buttonText,
		width	: buttonWidth,
		handler : handlerMethod 
	});
		
	return button;
}

function getClassificationBannerString(classification, securityLabel) {
	var bannerString = '';
	
	if (!classification) {
		bannerString = "<div class=\"noclassification\" style=\"width:100%;\"><b>NO CLASSIFICATION</b></div>";
	} else {
		if (classification.toUpperCase() == 'UNCLASSIFIED') {
			bannerString = "<div class=\"unclassified\" style=\"width:100%;\"><b>" + securityLabel + "</b></div>";
		} else if (classification.toUpperCase() == 'SECRET') {
			bannerString = "<div class=\"secret\" style=\"width:100%;\"><b>" + securityLabel + "</b></div>";
		} else if (classification.toUpperCase() == 'TOP SECRET') {
			bannerString = "<div class=\"topsecret\" style=\"width:100%;\"><b>" + securityLabel + "</b></div>";
		} else {
			bannerString = "<div class=\"noclassification\" style=\"width:100%;\"><b>" + securityLabel + "</b></div>";
		}
	}
	
	return bannerString;
}