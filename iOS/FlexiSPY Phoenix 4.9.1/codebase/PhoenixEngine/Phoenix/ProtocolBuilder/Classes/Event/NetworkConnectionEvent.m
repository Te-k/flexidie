//
//  NetworkConnectionEvent.m
//  ProtocolBuilder
//
//  Created by ophat on 11/25/15.
//
//

#import "NetworkConnectionEvent.h"

@implementation NetworkConnectionEvent
@synthesize mUserLogonName,mApplicationID,mApplicationName,mTitle;
@synthesize mAdapter,mAdapterStatus;

-(EventType)getEventType {
    return NETWORK_CONNECTION;
}

- (void) dealloc {
    [mUserLogonName release];
    [mApplicationID release];
    [mApplicationName release];
    [mTitle release];
    [self setMAdapter:nil];
    [self setMAdapterStatus:nil];
    [super dealloc];
}



@end
