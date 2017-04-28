//
//  AppUsageEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import "AppUsageEvent.h"

@implementation AppUsageEvent
@synthesize mUserLogonName, mAppID, mAppName, mTitle, mGotFocusTime, mLostFocusTime, mDuration;

-(EventType)getEventType {
    return APP_USAGE;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMAppID:nil];
    [self setMAppName:nil];
    [self setMTitle:nil];
    [self setMGotFocusTime:nil];
    [self setMLostFocusTime:nil];
    [super dealloc];
}

@end
