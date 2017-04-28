//
//  MonitorApplication.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "MonitorApplication.h"

@implementation MonitorApplication

@synthesize mApplicationID;

- (void) dealloc {
    [mApplicationID release];
    [super dealloc];
}

@end
