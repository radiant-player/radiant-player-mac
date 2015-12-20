/***************************************************************************//**
	NSXReturnThrowError.h
		Copyright (c) 2007 Jonathan 'Wolf' Rentzsch: <http://rentzsch.com>
		Some rights reserved: <http://opensource.org/licenses/mit-license.php>
	
	@section Overview

		NSXReturnThrowError does two things:

		1. Eases wrapping error codes into NSError objects.

		2. Enhances NSError by adding origin information to the error instance.
		   Origin information includes the actual line of code that returned
		   the error, as well as the file+line+function/method name.

		A big NSXReturnThrowError feature is that it deduces the correct NSError
		error domain based on the wrapped code's return type+value. Bonus: it
		does so without requiring ObjC++, relying on \@encode acrobatics
		instead.

		NSXReturnThrowError was coded against 10.4, but should be compatible
		with 10.3 as well. However that's currently untested.

	@section Usage

		NSXReturnThrowError handles both types of error handling: explicit
		returning of NSError objects and raising NSExceptions.

		Use NSXReturnError() if you're returning NSError objects explicitly:

		@code
		- (id)demoReturnError:(NSError**)error_ {
			id result = nil;
			NSError *error = nil;
			
			NSXReturnError(SomeCarbonFunction());
			if (!error)
				NSXReturnError(someposixfunction());
			if (!error)
				NSXReturnError(some_mach_function());
			if (!error)
				NSXReturnError([SomeCocoaClass sharedInstance]);
			
			if (error_) *error_ = error;
			return result;
		}
		@endcode

		Use NSXThrowError() if you'd prefer to raise NSException objects:

		@code
		- (id)demo {
			id result = nil;
			
			NSXThrowError(SomeCarbonFunction());
			NSXThrowError(someposixfunction());
			NSXThrowError(some_mach_function());
			NSXThrowError([SomeCocoaClass newObject]);
			
			return result;
		}
		@endcode
		
		The current structure of the raised NSException object is that it's a
		normal NSException whose name is "NSError". The actual error object is
		hung off the exception's userInfo dictionary with the key of @"error".

	@mainpage	NSXReturnThrowError
	@todo		Add a compile-time flag for whether to stuff __FILE__+friends
				info into the generated NSError or not.
	

	***************************************************************************/

#import <Foundation/Foundation.h>

extern NSString *NSXErrorExceptionName;
extern NSString *NULLPointerErrorDomain;
extern NSString *BOOLErrorDomain;

void NSXMakeErrorImp(const char *objCType_, intptr_t result_, const char *file_, unsigned line_, const char *function_, const char *code_, NSError **error_);

#define	NSXMakeError(ERROR, CODE)	\
	do{	\
		typeof(CODE) codeResult = (CODE);	\
		NSXMakeErrorImp(@encode(typeof(CODE)), (intptr_t)codeResult, __FILE__, __LINE__, __PRETTY_FUNCTION__, #CODE, &ERROR);	\
	}while(0)

#define	NSXReturnError(CODE)	NSXMakeError(error, CODE)
 
#define NSXRaiseError(ERROR) \
    [[NSException exceptionWithName:NSXErrorExceptionName	\
                             reason:[error description]	\
                           userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]] raise];

#define NSXThrowError(CODE) \
	do{	\
		NSError *error = nil;	\
		NSXReturnError(CODE);	\
		if (error) {	\
			NSXRaiseError(ERROR);	\
		}	\
	}while(0)
