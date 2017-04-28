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

+ (void) printDetail:(NSMutableArray *)aArray{
    if ([aArray count] == 0) {
        DLog(@"NoData For This Array");
    }else{
        for (int i = 0 ; i < [aArray count] ; i++) {
            NTPacket * temp = [aArray objectAtIndex:i];
            DLog(@"--------------------- %d",i);
            DLog(@"mTransportProtocol %d",(int)[temp mTransportProtocol]);
            DLog(@"mDirection %d",(int)[temp mDirection]);
            DLog(@"mInterface %d",(int)[temp mInterface]);
            DLog(@"mInterfaceName %@",[temp mInterfaceName]);
            DLog(@"mPort %d",(int)[temp mPort]);
            DLog(@"mSource %@",[temp mSource]);
            DLog(@"mDestination %@",[temp mDestination]);
            DLog(@"mSize %d",(int)[temp mSize]);
            DLog(@"mPacketCount %d",(int)[temp mPacketCount]);
            DLog(@"mHostname %@",[temp mHostname]);
        }
    }
}

- (void) dealloc {
    [mInterfaceName release];
    [mSource release];
    [mDestination release];
    [mHostname release];
    [super dealloc];
}

@end
