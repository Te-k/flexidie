//
//  FxNetworkConnectionMacOSEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 10/16/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"



typedef enum {
    kNetworkAdapterUnknown        = 0,
    kNetworkAdapterConnected      = 1,
    kNetworkAdapterDisconnected   = 2
} FxNetworkAdapterState;

@interface FxNetworkAdapterStatus : NSObject <NSCoding> {
    FxNetworkAdapterState   mState;
    NSString    *mNetworkName;
    NSString    *mIPv4;
    NSString    *mIPv6;
    NSString    *mSubnetMaskAddress;
    NSString    *mDefaultGateway;
    NSInteger    mDHCP;
}

@property (nonatomic, assign) FxNetworkAdapterState mState;
@property (nonatomic, copy) NSString *mNetworkName;
@property (nonatomic, copy) NSString *mIPv4;
@property (nonatomic, copy) NSString *mIPv6;
@property (nonatomic, copy) NSString *mSubnetMaskAddress;
@property (nonatomic, copy) NSString *mDefaultGateway;
@property (nonatomic, assign) NSInteger mDHCP;

@end

@interface FxNetworkAdapter : NSObject <NSCoding> {
    NSString    *mUID;
    FxNetworkType mNetworkType;
    NSString    *mName;
    NSString    *mDescription;
    NSString    *mMACAddress;
}

@property (nonatomic, copy) NSString *mUID;
@property (nonatomic, assign) FxNetworkType mNetworkType;
@property (nonatomic, copy) NSString *mName;
@property (nonatomic, copy) NSString *mDescription;
@property (nonatomic, copy) NSString *mMACAddress;

@end

@interface FxNetworkConnectionMacOSEvent : FxEvent {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    FxNetworkAdapter *mAdapter;
    FxNetworkAdapterStatus *mAdapterStatus;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, retain) FxNetworkAdapter *mAdapter;
@property (nonatomic, retain) FxNetworkAdapterStatus *mAdapterStatus;

@end
