/*
 
 */

#import <Cocoa/Cocoa.h>
#import "Startup.h"
#import "Controller.h"
#import "NSStringExtras.h"






	/* getter callback for the 'visible' property */
static JSValueRef startupVisible( JSContextRef ctx, JSObjectRef object,
			JSStringRef propertyName, JSValueRef *exception ) {
	
		/* a reference to the Controller object was stored in
		the private data field for the object when it was created. */
	Controller *cself = (Controller *) JSObjectGetPrivate( object );
	
		/* return true if the startup window is visible */
	return JSValueMakeBoolean( ctx, ([cself.startupWindow isVisible] ? true : false) );
}



	/* getter callback for the 'front' property */
static JSValueRef startupFront( JSContextRef ctx, JSObjectRef object,
			JSStringRef propertyName, JSValueRef *exception ) {
	
		/* a reference to the Controller object was stored in
		the private data field for the object when it was created. */
	Controller *cself = (Controller *) JSObjectGetPrivate( object );
	
		/* return true if the startup window is the front and active window */
	return JSValueMakeBoolean( ctx, ([cself.startupWindow isKeyWindow] ? true : false) );
}



	/* getter callback for the 'script' property */
static JSValueRef startupScript( JSContextRef ctx, JSObjectRef object,
			JSStringRef propertyName, JSValueRef *exception ) {
	
		/* a reference to the Controller object was stored in
		the private data field for the object when it was created. */
	Controller *cself = (Controller *) JSObjectGetPrivate( object );
	
		/* copy the script text in the startup window and return it to JavaScript as a string. */
	return JSValueMakeString( ctx, [[[cself.startupScriptText textStorage] string] jsStringValue] );
}




	/* startupStaticValues contains the list of value properties
	defined for the startup class.  Each entry in the list includes the
	property name, a pointer to a getter callback (or NULL), a pointer
	to a setter callback (or NULL),  and some attribute flags.  Getters
	for the property values are defined above.  No setters have been
	provided for any of the properties.
	
	Note we have set the attributes to both kJSPropertyAttributeDontDelete
	and kJSPropertyAttributeReadOnly.  These attributes are to prevent
	wayward scripts from changing or removing these values. */

static JSStaticValue startupStaticValues[] = {
	{ "visible", startupVisible, NULL, kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly },
	{ "front", startupFront, NULL, kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly },
	{ "script", startupScript, NULL, kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly },
	{ 0, 0, 0, 0 }
};



	/* function callback for the 'show' property */
static JSValueRef startupShow( JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
			size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception ) {
	
		/* a reference to the Controller object was stored in
		the private data field for the object when it was created. */
	Controller *cself = (Controller *) JSObjectGetPrivate( thisObject );
	
		/* show the startup window and make it the front window. */
	[cself.startupWindow makeKeyAndOrderFront: cself];
	
		/* return null to the JavaScript */
	return JSValueMakeNull( ctx );
}


	/* function callback for the 'hide' property */
static JSValueRef startupHide( JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
			size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception ) {
	
		/* a reference to the Controller object was stored in
		the private data field for the object when it was created. */
	Controller *cself = (Controller *) JSObjectGetPrivate( thisObject );
	
		/* close the startup window */
	[cself.startupWindow close];
	
		/* return null to the JavaScript */
	return JSValueMakeNull( ctx );
}



	/* startupStaticFunctions contains the list of function properties
	defined for the startup class.  Each entry in the list includes the
	property name, a pointer to the associated callback (defined above),
	and some attribute flags.  It is a zero terminated list with the last
	entry set to all zeros.
	
	Note we have set the attributes to both kJSPropertyAttributeDontDelete
	and kJSPropertyAttributeReadOnly.  These attributes are to prevent
	wayward scripts from changing or removing these values. */

static JSStaticFunction startupStaticFunctions[] = {
	{ "show", startupShow, kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly },
	{ "hide", startupHide, kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly },
	{ 0, 0, 0 }
};



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

JSClassRef StartupClass( void ) {

		/* we only need one definition for this class, so we cache the
		result between calls. */
	static JSClassRef startupClass = NULL;
	if ( startupClass == NULL ) {
	
			/* initialize the class definition structure.  It contains
			a lot of procedure pointers, so this step is very important. */
		JSClassDefinition startupClassDefinition = kJSClassDefinitionEmpty;
		
			/* set the pointers to our static values and functions */
		startupClassDefinition.staticValues = startupStaticValues;
		startupClassDefinition.staticFunctions = startupStaticFunctions;
		
			/* create the class */
		startupClass = JSClassCreate( &startupClassDefinition );
    }
    return startupClass;
}
