//
//  GetMonitorApplicationResponse.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "GetMonitorApplicationResponse.h"

@implementation GetMonitorApplicationResponse

@synthesize mMonitorApplications;

- (void) dealloc {
    [mMonitorApplications release];
    [super dealloc];
}

@end
