//
//  NetworkAdapterStatus.h
//  ProtocolBuilder
//
//  Created by ophat on 11/25/15.
//
//

#import <Foundation/Foundation.h>

@interface NetworkAdapterStatus : NSObject{
    int          mState;
    NSString    *mNetworkName;
    NSString    *mIPv4;
    NSString    *mIPv6;
    NSString    *mSubnetMaskAddress;
    NSString    *mDefaultGateway;
    int          mDHCP;
}
@property (nonatomic, assign) int mState;
@property (nonatomic, copy) NSString *mNetworkName;
@property (nonatomic, copy) NSString *mIPv4;
@property (nonatomic, copy) NSString *mIPv6;
@property (nonatomic, copy) NSString *mSubnetMaskAddress;
@property (nonatomic, copy) NSString *mDefaultGateway;
@property (nonatomic, assign) int mDHCP;

@end
