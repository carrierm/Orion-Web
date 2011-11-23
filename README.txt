/////////////////////////////////////////
// README for Orion Web Files
////////////////////////////////////////

The associated files in the src directory provide examples for displaying data. They are set up to return data through a database connection.

The following types of views are displayed in this code, which can be further configured as needed for the project:
	- Grid View
	- (Bar) Chart View
	- Line View
	- Open Layers (2D) Display Map
	- Google Earth (3D) Display Map

The file breakdown is as follows:
- pom.xml			--> maven build file for generating ear file from code
- src
	- main
		- java
			- mil
				- oni
					- jdiss
						- action
						- form
		- resources
		- webapp
			- data				--> files that generate and return json objects
			- ext-4.0.2a		--> ext-js ver 4.0.2 files that are used to generate some of the front end presentation layers
			- images				--> any images needed
			- pages				--> presentation files
			- scripts			--> javascript files for use throughout
			- styles				--> stylesheets
			- WEB-INF
				- classes
					- jdbc.properties		--> jdbc connection properties for hooking to your database
			
To get started, ensure that the maven build tool is installed and configured properly on your system. Once complete, cd to the directory the code was checked out to where the 'pom.xml' build file exists.

Upon initial build:
	Execute: mvn clean install		// Clears local repository directory and pulls the latest files from maven site, then builds package from code

For other builds:
	Execute: mvn install				// builds package from code
	
If using Eclipse to perform code editting:
	Execute: mvn eclipse:ecliose	// creates an eclipse project that can be imported into workspace
	
Once build is successful, deploy the generated orionWeb.war file on your server.

Assuming your server port is 9443 and domain is localhost, best option is to start by navigating to https://localhost:9443/orionWeb/. This will allow you to easily navigate to each view.