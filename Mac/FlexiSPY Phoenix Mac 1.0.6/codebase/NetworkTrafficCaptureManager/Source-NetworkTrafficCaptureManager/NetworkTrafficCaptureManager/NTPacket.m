//
//  NTPacket.m
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/13/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "NTPacket.h"

@implementation NTPacket

@synthesize mDirection, mInterface, mInterfaceName, mPort, mSource, mDestination, mSize, mHostname,mTransportProtocol,mPacketCount;

+ (BOOL) comparePacket: (NTPacket *) aPackage1 with:(NTPacket *) aPackage2  {
    if ([aPackage1 mTransportProtocol] == [aPackage2 mTransportProtocol] &&
        [aPackage1 mDirection] == [aPackage2 mDirection] &&
        [aPackage1 mInterface] == [aPackage2 mInterface] &&
        [[aPackage1 mInterfaceName] isEqualToString:[aPackage2 mInterfaceName]] &&
        [aPackage1 mPort] == [aPackage2 mPort] &&
        [[aPackage1 mSource] isEqualToString: [aPackage2 mSource]] &&
        [[aPackage1 mDestination] isEqualToString: [aPackage2 mDestination]] ){
        return true;
    }
    return false;
}

- (void) dealloc {
    [mInterfaceName release];
    [mSource release];
    [mDestination release];
    [mHostname release];
    [super dealloc];
}

@end
