//
//  FxNetworkTrafficEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 10/16/15.
//
//

#import "FxNetworkTrafficEvent.h"

@implementation FxTraffic
@synthesize mTransportType,mPacketsIn,mPacketsOut;
@synthesize mFxProtocolType,mPortNumber, mOutgoingTrafficSize, mIncomingTrafficSize;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mTransportType       = [[aDecoder decodeObject] unsignedIntegerValue];
        self.mFxProtocolType      = [[aDecoder decodeObject] unsignedIntegerValue];
        self.mPortNumber          = [[aDecoder decodeObject] unsignedIntegerValue];
        self.mPacketsIn           = [[aDecoder decodeObject] unsignedIntegerValue];
        self.mIncomingTrafficSize = [[aDecoder decodeObject] unsignedIntegerValue];
        self.mPacketsOut          = [[aDecoder decodeObject] unsignedIntegerValue];
        self.mOutgoingTrafficSize = [[aDecoder decodeObject] unsignedIntegerValue];
    }
    return (self);
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.mTransportType]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.mFxProtocolType]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.mPortNumber]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.mPacketsIn]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.mIncomingTrafficSize]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.mPacketsOut]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.mOutgoingTrafficSize]];
}

@end

@implementation FxRemoteHost
@synthesize mIPv4,mIPv6, mHostName, mTraffics;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mIPv4 = [aDecoder decodeObject];
        self.mIPv6 = [aDecoder decodeObject];
        self.mHostName = [aDecoder decodeObject];
        self.mTraffics = [aDecoder decodeObject];
    }
    return (self);
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.mIPv4];
    [aCoder encodeObject:self.mIPv6];
    [aCoder encodeObject:self.mHostName];
    [aCoder encodeObject:self.mTraffics];
}

- (void) dealloc {
    self.mIPv4 = nil;
    self.mIPv6 = nil;
    self.mHostName = nil;
    self.mTraffics = nil;
    [super dealloc];
}

@end

@implementation FxNetworkInterface
@synthesize mNetworkType, mInterfaceName, mDescription, mIPv4, mIPv6, mRemoteHosts;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mNetworkType = (FxNetworkType)[[aDecoder decodeObject] integerValue];
        self.mInterfaceName = [aDecoder decodeObject];
        self.mDescription = [aDecoder decodeObject];
        self.mIPv4 = [aDecoder decodeObject];
        self.mIPv6 = [aDecoder decodeObject];
        self.mRemoteHosts = [aDecoder decodeObject];
    }
    return (self);
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mNetworkType]];
    [aCoder encodeObject:self.mInterfaceName];
    [aCoder encodeObject:self.mDescription];
    [aCoder encodeObject:self.mIPv4];
    [aCoder encodeObject:self.mIPv6];
    [aCoder encodeObject:self.mRemoteHosts];
}

- (void) dealloc {
    self.mInterfaceName = nil;
    self.mDescription = nil;
    self.mIPv4 = nil;
    self.mIPv6 = nil;
    self.mRemoteHosts = nil;
    [super dealloc];
}

@end

@implementation FxNetworkTrafficEvent
@synthesize mUserLogonName,mApplicationID,mApplicationName,mTitle;
@synthesize mStartTime, mEndTime, mNetworkInterfaces;

- (FxEventType) eventType {
    return kEventTypeNetworkTraffic;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    self.mStartTime = nil;
    self.mEndTime = nil;
    self.mNetworkInterfaces = nil;
    [super dealloc];
}

@end
