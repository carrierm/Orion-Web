<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<%@ include file="common.jsp" %>
		
		<link rel="stylesheet" type="text/css" href="<%=serverExt402aPath%>/resources/css/ext-all.css"/>
		<link rel="stylesheet" type="text/css" href="<%=serverStylesPath%>/style-2gdb.css"/>
		<title>2nd Generation Data Broker - Grid View</title>
    	
		<script type="text/javascript" src="<%=serverScriptsPath%>/bootstrap.js"></script>
		<script type="text/javascript" src="<%=serverScriptsPath%>/communicationAgent.js"></script>
		<script type="text/javascript" src="<%=serverScriptsPath%>/owf-widget-min.js"></script>
		<script type="text/javascript" src="<%=serverScriptsPath%>/2gdb_eventing.js"></script>
		<script type="text/javascript" src="<%=serverScriptsPath%>/jsonDataListWidget.js"></script>
	</head>
	<body onload="initPage();">
	</body>
</html>