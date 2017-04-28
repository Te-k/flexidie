//
//  SendMonitorApplication.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "SendMonitorApplication.h"

@implementation SendMonitorApplication

@synthesize mMonitorApplications;

- (CommandCode)getCommand {
    return SEND_MONITOR_APPLICATIONS;
}

- (void) dealloc {
    [mMonitorApplications release];
    [super dealloc];
}

@end
