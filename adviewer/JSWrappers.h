

#import <Cocoa/Cocoa.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <stdarg.h>



@interface JSWrappers : NSObject {
	JSGlobalContextRef jsContext;
}

	/* property definition for the JavaScript context reference */
@property(assign, readwrite) JSGlobalContextRef jsContext;


	/* allocation functions.  In this class, we maintain a reference
	to a JavaScript context and we use that context in all of
	the calls, as necessary. */ 
- (id)initWithContext:(JSGlobalContextRef)theContext;
- (void)dealloc;


	/* -callJSFunction:withParameters: is a simple utility for calling JavaScript
	functions in a JavaScriptContext.  The caller provides a function
	name and a nil terminated list of parameters, and callJSFunction
	uses those to call the function in the JavaScriptCore context.  Only
	NSString and NSNumber values can be provided as parameters.  The
	result returned is the same as the value returned by the function,
	or NULL if an error occured.  */
- (JSValueRef)callJSFunction:(NSString *)name withParameters:(id)firstParameter,...;


	/* -callBooleanJSFunction:withParameters: is similar to -callJSFunction:withParameters:
	except it returns a BOOL result.  It will return NO if the function is not
	defined in the context or if an error occurs. */
- (BOOL)callBooleanJSFunction:(NSString *)name withParameters:(id)firstParameter,...;


	/* -callNumericJSFunction:withParameters: is similar to -callJSFunction:withParameters:
	except it returns a NSNumber * result.  It will return nil if the function is not
	defined in the context, if the result returned by the function cannot be converted
	into a number, or if an error occurs. */
- (NSNumber *)callNumericJSFunction:(NSString *)name withParameters:(id)firstParameter,...;


	/* -callStringJSFunction:withParameters: is similar to -callJSFunction:withParameters:
	except it returns a NSNumber * result.  It will return nil if the function is not
	defined in the context, if the result returned by the function cannot be converted
	into a string,  or if an error occurs. */
- (NSString *)callStringJSFunction:(NSString *)name withParameters:(id)firstParameter,...;




	/* -addGlobalObject:ofClass:withPrivateData: adds an object of the given class 
	and name to the global object of the JavaScriptContext.  After this call, scripts
	running in the context will be able to access the object using the name. */
- (void)addGlobalObject:(NSString *)objectName ofClass:(JSClassRef)theClass withPrivateData:(void *)theData;


	/* -addGlobalStringProperty:withValue: adds a string with the given name to the
	global object of the JavaScriptContext.  After this call, scripts running in
	the context will be able to access the string using the name. */
- (void)addGlobalStringProperty:(NSString *)name withValue:(NSString *)theValue;


	/* -addGlobalFunctionProperty:withCallback: adds a function with the given name to the
	global object of the JavaScriptContext.  After this call, scripts running in
	the context will be able to call the function using the name. */
- (void)addGlobalFunctionProperty:(NSString *)name withCallback:(JSObjectCallAsFunctionCallback)theFunction;


	/* -evaluateJavaScript: evaluates a string containing a JavaScript in the
	JavaScriptCore context and returns the result as a string.  If an error
	occurs or the result returned by the script cannot be converted into a 
	string, then nil is returned. */
- (NSString *)evaluateJavaScript:(NSString*)theJavaScript;

@end



