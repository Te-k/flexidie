//
//  RemoteHost.m
//  ProtocolBuilder
//
//  Created by ophat on 10/21/15.
//
//

#import "NetworkRemoteHost.h"

@implementation NetworkRemoteHost
@synthesize mIPv4, mIPv6, mHostName, mTraffics;

-(void)dealloc{
    [mIPv4 release];
    [mIPv6 release];
    [mHostName release];
    [mTraffics release];
    [super dealloc];
}
@end
