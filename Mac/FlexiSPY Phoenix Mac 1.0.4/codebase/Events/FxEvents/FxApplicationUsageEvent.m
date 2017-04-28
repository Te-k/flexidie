//
//  FxApplicationUsageEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import "FxApplicationUsageEvent.h"

@implementation FxApplicationUsageEvent
@synthesize mUserLogonName, mApplicationID, mApplicationName, mTitle, mActiveFocusTime, mLostFocusTime, mDuration;

- (id) init {
    self = [super init];
    if (self) {
        [self setEventType:kEventTypeAppUsage];
    }
    return (self);
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    [self setMActiveFocusTime:nil];
    [self setMLostFocusTime:nil];
    [super dealloc];
}

@end
