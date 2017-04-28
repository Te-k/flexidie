//
//  SendDeviceSettings.m
//  ProtocolBuilder
//
//  Created by Makara on 3/4/14.
//
//

#import "SendDeviceSettings.h"

@implementation SendDeviceSettings

@synthesize mDeviceSettings;

- (CommandCode)getCommand {
    return SEND_DEVICE_SETTINGS;
}

- (void) dealloc {
    [self setMDeviceSettings:nil];
    [super dealloc];
}

@end
