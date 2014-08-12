/*
     File: Browser.h
 Abstract: Browser JavaScript class.  This
 file contains only one function that returns a reference to the JavaScript
 class definition for the browser object.  The browser object allows
 JavaScripts running in either the WebView's JavaScript context or in
 the Controller's JavaScript context to access the main browser
 window and items it contains.  This class also allows scripts
 running in either context to run JavaScripts in the main WebView's
 JavaScript JavaScript Context.
  Version: 1.1
 
 
 */

#import <JavaScriptCore/JavaScriptCore.h>

	/* BrowserClass returns a JavaScriptCore class reference that you can use
	for creating objects manipulating the browser window.  This class also
	contains methods for executing scripts in the WebView's JavaScript
	context.
	
	Objects defined by this class have the following properties
	and methods that can be accessed from JavaScripts in both the
	Controller's JavaScript and from inside of scripts running
	in the WebView displayed in the browser window.
	
	properties:

		progress (boolean, read/write) - set to true to display the animated progress bar
		loading (boolean, read only) - true while loading a page
		message (string, read/write) - status message displayed at the bottom of the window
		title (string, read/write) - the window's title
		url (string, read/write) - the contents of the url field
		backlink (string or null, read only) - url from the history to the next page back (if there is one)
		forwardlink (string, read only) - url from the history to the next page forward (if there is one)

	methods:
	
		load( url ) - load the url in the WebView
		back() - if there is a back link in the history, go to that link.
		forward() - if there is a forward link in the history, go to that link.
		eval( string ) - evaluate the javascript in the string in the
				WebView's JavaScript context.    Returns the value
				returned by the script (strings, numbers, and booleans only).
	*/

JSClassRef BrowserClass( void );



