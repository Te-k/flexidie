//
//  Traffic.h
//  ProtocolBuilder
//
//  Created by ophat on 10/21/15.
//
//

#import <Foundation/Foundation.h>

@interface NetworkTraffic : NSObject {
    
    NSUInteger      mTransportType;
    int             mFxProtocolType;
    NSUInteger      mPortNumber;
    NSUInteger      mPacketsIn;
    NSUInteger      mIncomingTrafficSize;
    NSUInteger      mPacketsOut;
    NSUInteger      mOutgoingTrafficSize;
    
}
@property (nonatomic, assign) NSUInteger mTransportType;
@property (nonatomic, assign) int        mFxProtocolType;
@property (nonatomic, assign) NSUInteger mPortNumber;
@property (nonatomic, assign) NSUInteger mPacketsIn;
@property (nonatomic, assign) NSUInteger mIncomingTrafficSize;
@property (nonatomic, assign) NSUInteger mPacketsOut;
@property (nonatomic, assign) NSUInteger mOutgoingTrafficSize;


@end
