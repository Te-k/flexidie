//
//  FxNetworkConnectionMacOSEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 10/16/15.
//
//

#import "FxNetworkConnectionMacOSEvent.h"

@implementation FxNetworkAdapterStatus
@synthesize mState, mNetworkName, mIPv4, mIPv6, mSubnetMaskAddress, mDefaultGateway, mDHCP;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mState = (FxNetworkAdapterState)[[aDecoder decodeObject] integerValue];
        self.mNetworkName = [aDecoder decodeObject];
        self.mIPv4 = [aDecoder decodeObject];
        self.mIPv6 = [aDecoder decodeObject];
        self.mSubnetMaskAddress = [aDecoder decodeObject];
        self.mDefaultGateway = [aDecoder decodeObject];
        self.mDHCP = [[aDecoder decodeObject] integerValue];
    }
    return (self);
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mState]];
    [aCoder encodeObject:self.mNetworkName];
    [aCoder encodeObject:self.mIPv4];
    [aCoder encodeObject:self.mIPv6];
    [aCoder encodeObject:self.mSubnetMaskAddress];
    [aCoder encodeObject:self.mDefaultGateway];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mDHCP]];
}

- (void) dealloc {
    self.mNetworkName = nil;
    self.mIPv4 = nil;
    self.mIPv6 = nil;
    self.mSubnetMaskAddress = nil;
    self.mDefaultGateway = nil;
    [super dealloc];
}

@end

@implementation FxNetworkAdapter
@synthesize mUID, mNetworkType, mName, mDescription, mMACAddress;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mUID = [aDecoder decodeObject];
        self.mNetworkType = (FxNetworkType)[[aDecoder decodeObject] integerValue];
        self.mName = [aDecoder decodeObject];
        self.mDescription = [aDecoder decodeObject];
        self.mMACAddress = [aDecoder decodeObject];
    }
    return (self);
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.mUID];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mNetworkType]];
    [aCoder encodeObject:self.mName];
    [aCoder encodeObject:self.mDescription];
    [aCoder encodeObject:self.mMACAddress];
}

- (void) dealloc {
    self.mUID = nil;
    self.mName = nil;
    self.mDescription = nil;
    self.mMACAddress = nil;
    [super dealloc];
}

@end

@implementation FxNetworkConnectionMacOSEvent
@synthesize mUserLogonName,mApplicationID,mApplicationName,mTitle;
@synthesize mAdapter, mAdapterStatus;

- (FxEventType) eventType {
    return kEventTypeNetworkConnectionMacOS;
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    self.mAdapter = nil;
    self.mAdapterStatus = nil;
    [super dealloc];
}

@end
