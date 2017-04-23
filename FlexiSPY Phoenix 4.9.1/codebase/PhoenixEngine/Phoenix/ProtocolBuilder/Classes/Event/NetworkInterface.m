//
//  NetworkInterface.m
//  ProtocolBuilder
//
//  Created by ophat on 10/21/15.
//
//

#import "NetworkInterface.h"

@implementation NetworkInterface
@synthesize mInterfaceName, mDescription, mIPv4, mIPv6, mRemoteHosts; 

-(void)dealloc{
    [mInterfaceName release];
    [mDescription release];
    [mIPv4 release];
    [mIPv6 release];
    [mRemoteHosts release];
    [super dealloc];
}
@end
