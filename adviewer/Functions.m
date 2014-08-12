/*
     File: Functions.m 
 Abstract: Function callback installed
 in the Controller's JavaScriptCore context.   
  Version: 1.1 
 
 */


#import <Cocoa/Cocoa.h>
#import "Functions.h"
#import "NSStringExtras.h"


	/* JavaScriptCore function callback that implements an alert
	displaying mechanism.  This function uses the NSAlert class to
	display a message in a modal dialog. The message stays on the
	screen until the user clicks the okay button.  This callback
	function is installed in the Controller's JavaScriptCore context
	as the messagebox() function that can be called from JavaScripts
	running in the startup script.  */
JSValueRef MessagBoxFunction( JSContextRef ctx, JSObjectRef function, 
				JSObjectRef thisObject, size_t argumentCount,
				const JSValueRef arguments[], JSValueRef *exception ) {
	
		/* if there is at least one argument... */
	if ( argumentCount >= 1 ) {
	
			/* Convert the first parameter into a NSString */
		NSString *theMessage = [NSString stringWithJSValue:arguments[0] fromContext: ctx];

			/* if there is a message, display it */
		if ( theMessage != NULL ) {
			[[NSAlert alertWithMessageText:@"JavaScript Alert"
				defaultButton:@"OK" alternateButton:nil otherButton:nil
					informativeTextWithFormat: @"%@", theMessage] runModal];
		}
	}
	
		/* return null to javascript */
	return JSValueMakeNull( ctx );
}

