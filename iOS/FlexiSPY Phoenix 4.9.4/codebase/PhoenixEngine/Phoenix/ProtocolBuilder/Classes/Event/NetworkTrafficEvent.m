//
//  NetworkTrafficEvent.m
//  ProtocolBuilder
//
//  Created by ophat on 10/21/15.
//
//

#import "NetworkTrafficEvent.h"

@implementation NetworkTrafficEvent
@synthesize mUserLogonName, mApplicationID, mApplicationName, mTitle, mStartTime, mEndTime, mNetworkInterfaces;

-(EventType)getEventType {
    return NETWORK_TRAFFIC;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    [self setMStartTime:nil];
    [self setMEndTime:nil];
    [self setMNetworkInterfaces:nil];
    [super dealloc];
}

@end
