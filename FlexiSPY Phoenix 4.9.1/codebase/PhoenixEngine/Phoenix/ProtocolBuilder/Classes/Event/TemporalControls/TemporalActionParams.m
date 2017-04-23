//
//  TemporalActionParams.m
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import "TemporalActionParams.h"


@implementation TemporalActionParams

@synthesize mInterval;


- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:[NSNumber numberWithUnsignedInt:[self mInterval]]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMInterval:[[aDecoder decodeObject] unsignedIntValue]];
    }
    return self;
}

@end
