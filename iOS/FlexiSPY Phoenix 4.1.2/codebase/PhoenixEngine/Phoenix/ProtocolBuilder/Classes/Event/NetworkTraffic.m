//
//  Traffic.m
//  ProtocolBuilder
//
//  Created by ophat on 10/21/15.
//
//

#import "NetworkTraffic.h"

@implementation NetworkTraffic
@synthesize mTransportType,mPacketsIn,mPacketsOut;
@synthesize mFxProtocolType, mPortNumber, mOutgoingTrafficSize, mIncomingTrafficSize;

-(void) dealloc {
    [super dealloc];
}
@end
