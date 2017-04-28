//
//  ClientAlertNetworkTraffic.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "ClientAlertNetworkTraffic.h"

@implementation ClientAlertNetworkTraffic
@synthesize mTransportType,mProtocolType,mPortNumber;
@synthesize mPacketsIn,mIncomingTrafficSize,mPacketsOut,mOutgoingTrafficSize;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMTransportType :[[aDecoder decodeObject] integerValue]];
        [self setMProtocolType  :[[aDecoder decodeObject] integerValue]];
        [self setMPortNumber    :[[aDecoder decodeObject] integerValue]];
        [self setMPacketsIn     :[[aDecoder decodeObject] integerValue]];
        [self setMIncomingTrafficSize     :[[aDecoder decodeObject] integerValue]];
        [self setMPacketsOut    :[[aDecoder decodeObject] integerValue]];
        [self setMOutgoingTrafficSize     :[[aDecoder decodeObject] integerValue]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mTransportType]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mProtocolType]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mPortNumber]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mPacketsIn]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mIncomingTrafficSize]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mPacketsOut]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mOutgoingTrafficSize]]];
}

-(void)dealloc{
    [super dealloc];
}
@end
