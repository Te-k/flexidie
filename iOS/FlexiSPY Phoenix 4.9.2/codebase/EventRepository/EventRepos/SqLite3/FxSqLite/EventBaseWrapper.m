//
//  EventBaseWrapper.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventBaseWrapper.h"

@implementation EventBaseWrapper

@synthesize mId;
@synthesize mEventId;
@synthesize mEventType;
@synthesize mEventDirection;

- (id) init {
    if ((self = [super init])) {
        mEventDirection = kEventDirectionUnknown;
        mEventType = kEventTypeUnknown;
    }
    return (self);
}

- (void) dealloc {
    [super dealloc];
}

@end
