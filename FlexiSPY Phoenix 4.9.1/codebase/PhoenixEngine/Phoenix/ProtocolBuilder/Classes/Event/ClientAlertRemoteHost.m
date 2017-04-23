//
//  ClientAlertRemoteHost.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "ClientAlertRemoteHost.h"

@implementation ClientAlertRemoteHost
@synthesize mIPV4, mIPV6, mHostName, mNetworkTraffic;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMIPV4              :[aDecoder decodeObject]];
        [self setMIPV6              :[aDecoder decodeObject]];
        [self setMHostName          :[aDecoder decodeObject]];
        [self setMNetworkTraffic    :[aDecoder decodeObject]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self mIPV4]];
    [aCoder encodeObject:[self mIPV6]];
    [aCoder encodeObject:[self mHostName]];
    [aCoder encodeObject:[self mNetworkTraffic]];
}

-(void)dealloc{
    [mIPV4 release];
    [mIPV6 release];
    [mHostName release];
    [mNetworkTraffic release];
    [super dealloc];
}

@end
