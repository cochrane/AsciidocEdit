/*
     File: Console.h
 Abstract: Console javascript class.  This
 file contains only one function that returns a reference to the JavaScript
 class definition for the console object.  The console object allows
 JavaScripts running in either the WebView's JavaScript context or in
 the Controller's JavaScript context to access the window displaying
 the console log.  This class also allows scripts running in either context
 to run JavaScripts in the main Controller's JavaScript Context.
  Version: 1.1
 
 
 */

#import <JavaScriptCore/JavaScriptCore.h>

	/* ConsoleClass returns a JavaScriptCore class reference that you can use
	for creating objects manipulating the console window.  This class also
	contains methods for executing scripts in the main Controller's JavaScript
	context.
	
	Objects defined by this class have the following properties
	and methods that can be accessed from JavaScripts in both the
	Controller's JavaScript and from inside of scripts running
	in the WebView displayed in the browser window.
	
	properties:

		visible (read only) - true if the pageload window is visible
		front (read only) - true if the pageload window is the front window
		script (read/write) - the console log text displayed in the window
		script (read/write) - the script text displayed in the window

	methods:
	
		show() - display the pageload script window and make it the front window.
		hide() - hide the pageload script window.
		log( string(s) ) - add the strings to the console text as
					a single new line.
		eval( string ) - evaluate the javascript in the string in the
				main Controller's JavaScript context.  Returns the value
				returned by the script (strings, numbers, and booleans only).

	*/
JSClassRef ConsoleClass( void );
