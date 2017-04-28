//
//  FxUSBConnectionEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import "FxUSBConnectionEvent.h"

@implementation FxUSBConnectionEvent
@synthesize mUserLogonName, mApplicationID, mApplicationName, mTitle, mAction, mDeviceType, mDriveName;

- (id) init {
    self = [super init];
    if (self) {
        [self setEventType:kEventTypeUsbConnection];
    }
    return (self);
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    [self setMDriveName:nil];
    [super dealloc];
}

@end
