<html>
   <head>
		<style>
			body {
			    font-family:helvetica,tahoma,verdana,sans-serif;
				padding-left:20px;
				padding-top:50px;
			}		
		</style>
		<%@ include file="common.jsp" %>
		
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<style type="text/css">.cellContent { text-align:center; }</style>
		
		<link rel="stylesheet" type="text/css" href="<%=serverExt402aPath%>/resources/css/ext-all.css"/>

		<script type="text/javascript" src="<%=serverScriptsPath%>/bootstrap.js"></script>
		<script type="text/javascript" src="<%=serverScriptsPath%>/communicationAgent.js"></script>
		<script type="text/javascript" src="<%=serverScriptsPath%>/owf-widget-min.js"></script>
		<script type="text/javascript" src="<%=serverScriptsPath%>/2gdb_eventing.js"></script>
		
		<script type="text/javascript">
			var store;
			var displayWindow;
		
			Ext.require(['Ext.data.*']);
			Ext.require('Ext.chart.*');
			Ext.require(['Ext.Window', 'Ext.layout.container.Fit', 'Ext.fx.target.Sprite']);
			
			function getData(config) {
				try {
				    var url = serverDataPath + "/JSON_Data_Chart.jsp";
					var responseVal = postURL(url,null);
					var result = eval(trim(responseVal));
					
					logger.debug("ChartView Widget: getData(): url: " + url);
					var myData = new Array();
					if (result.length == 0) {
						myData.push({name:'', untasked: 0, unfulfilled:0, accomplished:0});
					} else {
						for (i = 0; i < result.length; i++) {
							myData.push({name:result[i][0], untasked: result[i][1], unfulfilled:result[i][2], accomplished:result[i][3]});
						}
					}
				} catch(err) {
					logger.debug("ChartView Widget: getData(): err: " + err);
				}

			    return myData;
			}
		
			function drawGridObject(configString) {
				try {
					store = Ext.create('Ext.data.Store', {
				        fields: ['name', 'untasked', 'unfulfilled', 'accomplished'],
				        data: getData(configString)
				    });
					
					var colors = ['url(#untasked)','url(#unfulfilled)','url(#accomplished)'];
					var baseColor = '#eee';
					    
					Ext.define('Ext.chart.theme.Fancy', {
						extend: 'Ext.chart.theme.Base',
						constructor: function(config) {
				            this.callParent([Ext.apply({ colors: colors }, config)]);
						}
					});
					    
					displayWindow = new Ext.Viewport({
						id			: 'displayWindow',
						title		: 'Current Collection Requests',
						closable	: false,
						width		: 1075,
						height		: 650,
						resizable	: false,
						collapsible	: false,
						x: 0, y: 0,
						draggable	: false,
						minimizable	: false,
						plain		: true,
						layout		: 'fit',
						items: {
				            id: 'chartCmp',
				            xtype: 'chart',
				            theme: 'Fancy',
				            style: 'background:#fff',
				            animate: true,
				            shadow: true,
				            store: store,
				            legend: {
					        	position: 'right'  
					        },
					        gradients: [
								{
									'id'	: 'untasked',
									'angle'	: 0,
									stops	: { 0: { color: '#FF0000' } }
								}, {
									'id'	: 'unfulfilled',
									'angle'	: 0,
									stops	: { 0: { color: '#FFFF00' } }
								}, {
									'id'	: 'accomplished',
									'angle'	: 0,
									stops	: { 0: { color: '#00FF00' } }
								}
							],
				            axes: [{
				                type: 'Numeric',
				                position: 'left',
				                fields: ['untasked', 'unfulfilled', 'accomplished'],
				                label: {
				                    renderer: Ext.util.Format.numberRenderer('0,0')
				                },
				                title: 'Number of Collection Requests',
				                grid: true,
				                minimum: 0
				            }, {
				                type: 'Category',
				                position: 'bottom',
				                fields: ['name'],
				                label: { rotate: { degrees: -90 } }
				            }],
				            series: [{
				                type: 'column',
				                axis: 'left',
				                highlight: true,
				                label: {
				                  display: 'insideEnd',
				                  'text-anchor': 'middle',
				                  field: ['untasked', 'unfulfilled', 'accomplished'],
				                  renderer: Ext.util.Format.numberRenderer('0'),
				                  orientation: 'vertical'
				                },
				                xField: 'name',
				                yField: ['untasked', 'unfulfilled', 'accomplished']
				            }]
				        }
					});
					
					store.load();
					displayWindow.show();
				} catch (err) {
					logger.debug("ChartView Widget: drawGridObject(): err: " + err);
				} 
			}
		
			var update = function(sender, msg) {
				try {
					logger.debug('ChartView Widget: update(): msg: ' + msg);
					store.loadData(getData(msg));
				} catch(err) {
					logger.debug('ChartView Widget: update(): err: ' + err);
				}
			}
		
			Ext.onReady(function() {
				Ext.QuickTips.init();
				drawGridObject();
			});
		</script>
   	</head>
   	<body onload="initPage();">
   	</body>
</html>