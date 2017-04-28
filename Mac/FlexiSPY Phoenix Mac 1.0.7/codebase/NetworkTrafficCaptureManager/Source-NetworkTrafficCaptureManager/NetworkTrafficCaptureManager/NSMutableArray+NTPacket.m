//
//  NSMutableArray+NTPacket.m
//  NetworkTrafficCaptureManager
//
//  Created by Makara Khloth on 9/13/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "NSMutableArray+NTPacket.h"
#import "NTPacket.h"

@implementation NSMutableArray (NTPacket)

- (void) descriptionNTPackets {
    if ([self count] == 0) {
        DLog(@"No Data For This Array");
    }else{
        for (int i = 0 ; i < [self count] ; i++) {
            NTPacket * temp = [self objectAtIndex:i];
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

@end
