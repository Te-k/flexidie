//
//  NetworkInterface.h
//  ProtocolBuilder
//
//  Created by ophat on 10/21/15.
//
//

#import <Foundation/Foundation.h>

@interface NetworkInterface : NSObject {
    int             mNetworkType;
    NSString        *mInterfaceName;
    NSString        *mDescription;
    NSString        *mIPv4;
    NSString        *mIPv6;
    NSArray         *mRemoteHosts; // FxRemoteHost
}

@property (nonatomic, assign) int mNetworkType;
@property (nonatomic, copy) NSString *mInterfaceName;
@property (nonatomic, copy) NSString *mDescription;
@property (nonatomic, copy) NSString *mIPv4;
@property (nonatomic, copy) NSString *mIPv6;
@property (nonatomic, retain) NSArray  *mRemoteHosts; // FxRemoteHost
@end
