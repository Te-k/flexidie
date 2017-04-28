//
//  NetworkAdapter.m
//  ProtocolBuilder
//
//  Created by ophat on 11/25/15.
//
//

#import "NetworkAdapter.h"

@implementation NetworkAdapter
@synthesize mUID,mNetworkType,mName,mDescription,mMACAddress;

-(void)dealloc{
    [mUID release];
    [mName release];
    [mDescription release];
    [mMACAddress release];
    [super dealloc];
}
@end
