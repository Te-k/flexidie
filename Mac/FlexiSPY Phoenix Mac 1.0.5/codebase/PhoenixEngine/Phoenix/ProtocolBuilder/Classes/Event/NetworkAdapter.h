//
//  NetworkAdapter.h
//  ProtocolBuilder
//
//  Created by ophat on 11/25/15.
//
//

#import <Foundation/Foundation.h>

@interface NetworkAdapter : NSObject {
    NSString    *mUID;
    int          mNetworkType;
    NSString    *mName;
    NSString    *mDescription;
    NSString    *mMACAddress;
}

@property (nonatomic, copy) NSString *mUID;
@property (nonatomic, assign) int mNetworkType;
@property (nonatomic, copy) NSString *mName;
@property (nonatomic, copy) NSString *mDescription;
@property (nonatomic, copy) NSString *mMACAddress;
@end
