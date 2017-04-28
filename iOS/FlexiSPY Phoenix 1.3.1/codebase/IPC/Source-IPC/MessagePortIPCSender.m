//
//  MessaPortIPCSender.m
//  IPC
//
//  Created by Dominique  Mayrand on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessagePortIPCSender.h"


@implementation MessagePortIPCSender

@synthesize mReturnData;

/*
 int returnCode=0;
 
 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
 CFMessagePortRef remote = CFMessagePortCreateRemote(NULL, CFSTR("MyPort"));
 char *message = "Hello, world!";
 CFDataRef data, returnData = NULL;
 data = CFDataCreate(NULL, message, strlen(message)+1);
 
 if (kCFMessagePortSuccess == CFMessagePortSendRequest(remote, 0, data, 1, 1, kCFRunLoopDefaultMode, &returnData) && NULL != returnData) {
 
 NSString *message = [NSString stringWithCString:CFDataGetBytePtr(returnData)];
 
 DLog(@"Successfully sent and recive data from MS >> %@",message);
 CFRelease(returnData);
 }
 CFRelease(data);
 CFRelease(remote);
 
 [pool release];
 return returnCode;
 
 */

- (id) initWithPortName: (NSString*) aPortName{
	self = [super init];
	if(self){
		mPortName = aPortName;
		[mPortName retain];
		
	}
	return self;
}

- (BOOL) writeDataToPort: (NSData*) aRawData{
	//DLog(@"aRawData: --->%@<---", aRawData)
	CFDataRef data = (CFDataRef) aRawData; 
	CFDataRef returnData = NULL;
	BOOL retVal = NO;
	mMessagePortRef = CFMessagePortCreateRemote(NULL, (CFStringRef)mPortName);
	if(mMessagePortRef){
		SInt32 error = CFMessagePortSendRequest(mMessagePortRef, 0, data, 1, 1, kCFRunLoopDefaultMode, &returnData);
		DLog(@"error = %d", error)
		if (kCFMessagePortSuccess == error || kCFMessagePortReceiveTimeout == error) {
			retVal = YES;
		}
		if (returnData) {
			[self setMReturnData:(NSData *)returnData];
			CFRelease(returnData);
		}
		CFRelease(mMessagePortRef);
	}
	//DLog(@"retVal: %d", retVal)
	return retVal;
}

- (void) dealloc{
	[mReturnData release];
	[mPortName release];
	if(mMessagePortRef){
		
	}
	[super dealloc];
}


@end
