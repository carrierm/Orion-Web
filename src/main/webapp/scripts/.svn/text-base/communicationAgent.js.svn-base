//var xmlHttpRequst;

function commAgent()
{	
	/**
	* Method Common function to initialize XML Http Request object
	* @author	:	Praveen Kondaka
	* @date		:	05/10/2011
	*/
	function getHttpRequestObject()
	{
		// Define and initialize as false
		var xmlHttpRequst = false;
	 
		// Mozilla/Safari/Non-IE
		if (window.XMLHttpRequest)
		{
			xmlHttpRequst = new XMLHttpRequest();
		}
		// IE
		else if (window.ActiveXObject)
		{
			xmlHttpRequst = new ActiveXObject("Microsoft.XMLHTTP");
		}
		return xmlHttpRequst;
	}


	
	/**
	* Method for Generalized function to connect to any URL on same domain
	* @author	:	Praveen Kondaka
	* @date		:	05/10/2011
	*/
	function openURL(url)
	{
		// to make sure URL is always refreshed, add a random number at the end ...
		//var randomparam = "&" + Math.random();
		//url = url + randomparam;

		var http = getHttpRequestObject();

		http.open("POST", url, false);

		//now send the request
		http.send();

		// now get response text
		var resp = http.responseText;
		return resp;
	}
		

	
	/**
	* Method for Generalized method to POST to any url 
	* data should have format of "paramnam=value&paramname2=value2& ..."
	* @author	:	Praveen Kondaka
	* @date		:	05/10/2011
	*/
	function postURL(url, data)
	{
		var http = getHttpRequestObject();

		http.open("POST", url, false);

		//set the header to accept parameters thru POST method
		http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

		//now send the request
		http.send(data);

		// now get response text
		var resp = http.responseText;

		return resp;
	}


	/**
	* Method Does the AJAX call to URL specific with rest of the parameters
	* @author	:	Praveen Kondaka
	* @date		:	05/10/2011
	*/
	function doAjax(url, method, async, responseHandler, data)
	{
		// Set the variables
		url = url || "";
		method = method || "GET";
		async = async || true;
		data = data || null;
	 
		if(url == "")
		{
			alert("URL can not be null/blank");
			return false;
		}
		//var xmlHttpRequst = getHttpRequestObject();
		var xmlHttpRequst = getHttpRequestObject();
	 
		// If AJAX supported
		if(xmlHttpRequst != false)
		{
			// Open Http Request connection
			if(method == "GET")
			{
				url = url + "?" + data;
				data = null;
			}
			xmlHttpRequst.open(method, url, async);
			// Set request header (optional if GET method is used)
			if(method == "POST")
			{
				xmlHttpRequst.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			}
			// Assign (or define) response-handler/callback when ReadyState is changed.
			xmlHttpRequst.onreadystatechange = responseHandler;
			// Send data
			xmlHttpRequst.send(data);
		}
		else
		{
			alert("Please use browser with Ajax support.!");
		}
	}
	

	this.openURL = openURL;
	this.postURL = postURL;
}	

var iCommAgent = new commAgent();


/**
* Method Generalized function to connect to any URL on same domain
* @author	:	Praveen Kondaka
* @date		:	05/10/2011
*/
function openURL(url)
{
	return iCommAgent.openURL(url);
}


/**
* Method to Generalized method to POST to any url with data
* @author	:	Praveen Kondaka
* @date		:	05/10/2011
*/
function postURL(url, data)
{
	return iCommAgent.postURL(url,data);
}


/**
* Method LTRIM for javascript string
* @author	:	Praveen Kondaka
* @date		:	05/10/2011
*/
function ltrim(str) { 
	for(var k = 0; k < str.length && isWhitespace(str.charAt(k)); k++);
	return str.substring(k, str.length);
}

/**
* Method RTRIM for javascript string
* @author	:	Praveen Kondaka
* @date		:	05/10/2011
*/
function rtrim(str) {
	for(var j=str.length-1; j>=0 && isWhitespace(str.charAt(j)) ; j--) ;
	return str.substring(0,j+1);
}

/**
* Method TRIM for javascript string
* @author	:	Praveen Kondaka
* @date		:	05/10/2011
*/
function trim(str) {
	return ltrim(rtrim(str));
}

/**
* Method IsWhiteSpace for javascript string
* @author	:	Praveen Kondaka
* @date		:	05/10/2011
*/
function isWhitespace(charToCheck) {
	var whitespaceChars = " \t\n\r\f";
	return (whitespaceChars.indexOf(charToCheck) != -1);
}


