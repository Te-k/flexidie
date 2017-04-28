//
//  FxScreenshotEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import "FxScreenshotEvent.h"

@implementation FxScreenshotEvent
@synthesize mUserLogonName, mApplicationID, mApplicationName, mTitle, mCallingModule,mFrameID, mScreenshotFilePath;

- (id) init {
    self = [super init];
    if (self) {
        [self setEventType:kEventTypeScreenRecordSnapshot];
    }
    return (self);
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    [self setMScreenshotFilePath:nil];
    [super dealloc];
}

@end
