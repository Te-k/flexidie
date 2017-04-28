//
//  ClientAlert.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "ClientAlert.h"

@implementation ClientAlert
@synthesize mClientAlertType, mClientAlertData;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMClientAlertType   :[[aDecoder decodeObject] integerValue]];
        [self setMClientAlertData   :[aDecoder decodeObject]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mClientAlertType]]];
    [aCoder encodeObject:[self mClientAlertData]];
}

-(void) dealloc {
    [mClientAlertData release];
    [super dealloc];
}
@end
