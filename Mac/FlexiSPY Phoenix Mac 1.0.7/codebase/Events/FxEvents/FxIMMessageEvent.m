//
//  FxIMMessageEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 1/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxIMMessageEvent.h"
#import "FxIMGeoTag.h"

@implementation FxIMMessageEvent

- (id) init {
	if ((self = [super init])) {
		eventType = kEventTypeIMMessage;
        
        self.mUserLocation = [[[FxIMGeoTag alloc] init] autorelease];
        self.mUserLocation.mHorAccuracy = -1;
        
        self.mShareLocation = [[[FxIMGeoTag alloc] init] autorelease];
        self.mShareLocation.mHorAccuracy = -1;
	}
	return (self);
}

- (void) dealloc {
	[super dealloc];
}

@end
