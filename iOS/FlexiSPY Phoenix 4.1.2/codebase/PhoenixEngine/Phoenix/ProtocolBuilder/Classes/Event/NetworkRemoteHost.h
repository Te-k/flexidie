//
//  RemoteHost.h
//  ProtocolBuilder
//
//  Created by ophat on 10/21/15.
//
//

#import <Foundation/Foundation.h>

@interface NetworkRemoteHost : NSObject {
    NSString    *mIPv4;
    NSString    *mIPv6;
    NSString    *mHostName;
    NSArray     *mTraffics; // FxTraffic
}

@property (nonatomic, copy) NSString *mIPv4;
@property (nonatomic, copy) NSString *mIPv6;
@property (nonatomic, copy) NSString *mHostName;
@property (nonatomic, retain) NSArray *mTraffics;

@end
