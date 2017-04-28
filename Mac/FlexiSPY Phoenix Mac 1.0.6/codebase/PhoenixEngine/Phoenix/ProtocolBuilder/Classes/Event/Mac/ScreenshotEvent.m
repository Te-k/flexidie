//
//  ScreenshotEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import "ScreenshotEvent.h"

@implementation ScreenshotEvent
@synthesize mUserLogonName, mAppID, mAppName, mTitle, mCallingModule, mFrameID, mMediaType, mScreenshotData;

-(EventType)getEventType {
    return SCREEN_RECORDING;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMAppID:nil];
    [self setMAppName:nil];
    [self setMTitle:nil];
    [self setMScreenshotData:nil];
    [super dealloc];
}

@end
