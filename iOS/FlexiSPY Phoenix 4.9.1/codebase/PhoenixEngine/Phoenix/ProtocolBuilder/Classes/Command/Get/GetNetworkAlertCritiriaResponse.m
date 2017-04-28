//
//  GetNetworkAlertCritiriaResponse.m
//  ProtocolBuilder
//
//  Created by ophat on 1/11/16.
//
//

#import "GetNetworkAlertCritiriaResponse.h"

@implementation GetNetworkAlertCritiriaResponse
@synthesize mCriteria;

- (void) dealloc {
    [mCriteria release];
    [super dealloc];
}
@end
