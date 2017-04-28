//
//  NSMutableArray+NTRawPacket.m
//  NetworkTrafficAlertManager
//
//  Created by Makara Khloth on 9/14/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "NSMutableArray+NTRawPacket.h"
#import "NTRawPacket.h"

@implementation NSMutableArray (NTRawPacket)

- (void) descriptionNTRawPacket {
    if ([self count] == 0) {
        DLog(@"No Data For This Array");
    }else{
        for (int i = 0 ; i < [self count] ; i++) {
            NTRawPacket * temp = [self objectAtIndex:i];
            DLog(@"--------------------- %d",i);
            DLog(@"mTransportProtocol %d",(int)[temp mTransportProtocol]);
            DLog(@"mDirection %d",[temp mDirection]);
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
