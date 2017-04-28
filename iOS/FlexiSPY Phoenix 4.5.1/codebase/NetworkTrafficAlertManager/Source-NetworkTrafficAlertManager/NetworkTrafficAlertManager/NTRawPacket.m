//
//  NTPacket.m
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/13/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "NTRawPacket.h"

@implementation NTRawPacket

#define kDirectionTypeDownload      0
#define kDirectionTypeUpload        1

@synthesize mDirection, mPort, mSource, mDestination, mSize, mHostname,mTransportProtocol,mPacketCount;

+ (BOOL) comparePacket: (NTRawPacket *) aPackage1 with:(NTRawPacket *) aPackage2  {
    if ([aPackage1 mTransportProtocol] == [aPackage2 mTransportProtocol] &&
        [aPackage1 mDirection] == [aPackage2 mDirection] &&
        [aPackage1 mPort] == [aPackage2 mPort] &&
        [[aPackage1 mSource] isEqualToString: [aPackage2 mSource]] &&
        [[aPackage1 mDestination] isEqualToString: [aPackage2 mDestination]] ){
        return true;
    }
    return false;
}

+ (void) printDetail: (NSMutableArray *) aArray {
    if ([aArray count] == 0) {
        NSLog(@"NoData For This Array");
    }else{
        for (int i = 0 ; i < [aArray count] ; i++) {
            NTRawPacket * temp = [aArray objectAtIndex:i];
            NSLog(@"--------------------- %d",i);
            NSLog(@"mTransportProtocol %d",(int)[temp mTransportProtocol]);
            NSLog(@"mDirection %d",[temp mDirection]);
            NSLog(@"mPort %d",(int)[temp mPort]);
            NSLog(@"mSource %@",[temp mSource]);
            NSLog(@"mDestination %@",[temp mDestination]);
            NSLog(@"mSize %d",(int)[temp mSize]);
            NSLog(@"mPacketCount %d",(int)[temp mPacketCount]);
            NSLog(@"mHostname %@",[temp mHostname]);
        }
    }
}

- (void) dealloc {
    [mSource release];
    [mDestination release];
    [mHostname release];
    [super dealloc];
}

@end
