//
//  NetworkAdapterStatus.m
//  ProtocolBuilder
//
//  Created by ophat on 11/25/15.
//
//

#import "NetworkAdapterStatus.h"

@implementation NetworkAdapterStatus
@synthesize mState,mNetworkName,mIPv4,mIPv6,mSubnetMaskAddress,mDefaultGateway,mDHCP;

-(void)dealloc{
    [mNetworkName release];
    [mIPv4 release];
    [mIPv6 release];
    [mSubnetMaskAddress release];
    [mDefaultGateway release];
    [super dealloc];
}
@end
