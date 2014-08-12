/*
     File: Startup.h
 Abstract: Startup javascript class.  This
 file contains only one function that returns a reference to the JavaScript
 class definition for the startup object.  The startup object allows
 JavaScripts running in either the WebView's JavaScript context or in
 the Controller's JavaScript context to access the window displaying
 the startup script.
  Version: 1.1
 
  
 */


#import <JavaScriptCore/JavaScriptCore.h>

	/* StartupClass returns a JavaScriptCore class reference that you can use
	for creating objects manipulating the startup script window.
	
	Objects defined by this class have the following properties
	and methods that can be accessed from JavaScripts in both the
	Controller's JavaScript and from inside of scripts running
	in the WebView displayed in the browser window.
	
	properties:
	
		visible (read only) - true if the pageload window is visible
		front (read only) - true if the pageload window is the front window
		script (read only) - the page load script text

	methods:
	
		show() - display the pageload script window and make it the front window.
		hide() - hide the pageload script window.

	*/
JSClassRef StartupClass( void );
