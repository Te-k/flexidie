//
//  GetTemporalControlResponse.m
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import "GetTemporalControlResponse.h"

@implementation GetTemporalControlResponse

@synthesize mTemporalControls;

- (void) dealloc {
    [mTemporalControls release];
    [super dealloc];
}

@end
