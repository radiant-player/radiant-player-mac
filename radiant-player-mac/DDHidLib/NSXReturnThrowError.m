/*******************************************************************************
	NSXReturnThrowError.m
		Copyright (c) 2007 Jonathan 'Wolf' Rentzsch: <http://rentzsch.com>
		Some rights reserved: <http://opensource.org/licenses/mit-license.php>

	***************************************************************************/

#import "NSXReturnThrowError.h"

NSString *NSXErrorExceptionName = @"NSXError";
NSString *NULLPointerErrorDomain = @"NULLPointerErrorDomain";
NSString *BOOLErrorDomain = @"BOOLErrorDomain";

typedef	enum {
	NSXErrorCodeType_Unknown,
	NSXErrorCodeType_Cocoa,			//	"@"
	NSXErrorCodeType_PosixOrMach,	//	"i" (-1 == posix+errno, otherwise mach)
	NSXErrorCodeType_Carbon,		//	"s" || "l"
	NSXErrorCodeType_ptr,			//	"r*" || "*" || "^"
	NSXErrorCodeType_BOOL			//	"c"
}	NSXErrorCodeType;

static NSXErrorCodeType NSXErrorCodeTypeFromObjCType(const char *objCType) {
	switch (objCType[0]) {
		case 's':
		case 'l':
			return NSXErrorCodeType_Carbon;
		case 'i':
			return NSXErrorCodeType_PosixOrMach;
		case '@':
			return NSXErrorCodeType_Cocoa;
		case '^':
		case '*':
			return NSXErrorCodeType_ptr;
		case 'r':
			return '*' == objCType[1] ? NSXErrorCodeType_ptr : NSXErrorCodeType_Unknown;
		case 'c':
			return NSXErrorCodeType_BOOL;
		default:
			return NSXErrorCodeType_Unknown;
	}
}

void NSXMakeErrorImp(const char *objCType_, intptr_t result_, const char *file_, unsigned line_, const char *function_, const char *code_, NSError **error_) {
	NSString *errorDomain = nil;
	int errorCode = (int)result_;
	
	switch (NSXErrorCodeTypeFromObjCType(objCType_)) {
		case NSXErrorCodeType_Cocoa:
			//	codeResult's type is an id/NSObject* pointer. 0 == nil == failure.
			if (0 == result_) {
				errorDomain = @"NSCocoaErrorDomain"; // Could use NSCocoaErrorDomain symbol, but that would force us to 10.4.
				errorCode = -1;
			}
			break;
		case NSXErrorCodeType_Carbon:
			//	codeResult's type is OSErr (short) or OSStatus (long). 0 == noErr == success.
			if (0 != result_) {
				errorDomain = NSOSStatusErrorDomain;
			}
			break;
		case NSXErrorCodeType_PosixOrMach:
			//	codeResult's type is int, which is used for both posix error codes and mach_error_t/kern_return_t.
			//	0 means success for both, and we can differentiate posix error codes since they're always -1 (the
			//	actual posix code stored in errno).
			if (0 != result_) {
				if (-1 == result_) {
					//	Posix error code.
					errorDomain = NSPOSIXErrorDomain;
					errorCode = errno;
				} else {
					//	Mach error code.
					errorDomain = NSMachErrorDomain;
				}
			}
			break;
		case NSXErrorCodeType_ptr:
			//	codeResult's type is some sort of non-id/non-NSObject* pointer. 0 == NULL == failure.
			if (0 == result_) {
				errorDomain = NULLPointerErrorDomain;
				errorCode = -1;
			}
			break;
		case NSXErrorCodeType_BOOL:
			//	codeResult's type is a BOOL. 0 == NO == failure.
			if (0 == result_) {
				errorDomain = BOOLErrorDomain;
				errorCode = -1;
			}
			break;
		default:
			NSCAssert1(NO, @"NSXErrorCodeType_Unknown: \"%s\"", objCType_);
			break;
	}

	if (errorDomain && error_) {
		*error_ = [NSError errorWithDomain:errorDomain
									  code:errorCode
								  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithUTF8String:file_],   @"reportingFile",
									  [NSNumber numberWithInt:line_],   @"reportingLine",
									  [NSString stringWithUTF8String:function_], @"reportingMethod",
									  [NSString stringWithUTF8String:code_], @"origin",
									  nil]];
	}
}
