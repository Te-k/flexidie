//
//  MessagePortIPCReader.m
//  IPC
//
//  Created by Dominique  Mayrand on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessagePortIPCReader.h"


@implementation MessagePortIPCReader

-(void) callDelegate:(CFDataRef) aData{
	if(mDelegate){
		[mDelegate dataDidReceivedFromMessagePort:(NSData*)aData];
	}
}

- (NSData *) getReturnData: (CFDataRef) aRawData {
	NSData *rData = nil;
	if ([mDelegate respondsToSelector:@selector(messagePortReturnData:)]) {
		rData = [mDelegate messagePortReturnData:(NSData*)aRawData];
	}
	return (rData);
}

CFDataRef myCallBack(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info) {
    char *message = "OK!";
    CFDataRef returnData = (CFDataRef) CFDataCreate(NULL, (UInt8*) message, strlen(message)+1);
    
    DLog(@"MYPORT CALL BACK FIRED");
    
    MessagePortIPCReader *listener = (MessagePortIPCReader *)info;
    [listener callDelegate:data];
    
	NSData *rData = [listener getReturnData:data];
	if (rData) {
		CFRelease(returnData);
		returnData = nil;
		returnData = (CFDataRef)rData;
		CFRetain(returnData);
	}
	
    return returnData;
}

- (id) initWithPortName:(NSString*) aPortName withMessagePortIPCDelegate: (id <MessagePortIPCDelegate>) aDelegate{
	mDelegate = nil;
	mPortName = nil;
	mStarted = NO;

	self = [super init];
	if(self){
		mDelegate = aDelegate;
#ifdef IOS_ENTERPRISE
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        mPortName = [NSString stringWithFormat:@"group.%@.%@", bundleIdentifier , aPortName];
#else
        mPortName = aPortName;
#endif
		[mPortName retain];
		
	}
	
	return self;
}

- (void)start{
	if(mStarted == NO){
		CFMessagePortContext messagePortContext = { 0 };
		messagePortContext.info =(MessagePortIPCReader *)self;
		mMessagePortRef = CFMessagePortCreateLocal(NULL,(CFStringRef)mPortName, myCallBack, &messagePortContext, false);
		mLoopsource = CFMessagePortCreateRunLoopSource(NULL,mMessagePortRef, 0);
		CFRunLoopAddSource(CFRunLoopGetCurrent(), mLoopsource,
					   kCFRunLoopDefaultMode);
		mStarted = YES;
	}
}

-(void)stop{
	if(mStarted == YES){
		CFMessagePortInvalidate(mMessagePortRef);
		CFRelease(mLoopsource);
		CFRelease(mMessagePortRef);
		mStarted = NO;
	}
	
}

- (void) dealloc{
	[self stop];
	[super dealloc];
}

@end
