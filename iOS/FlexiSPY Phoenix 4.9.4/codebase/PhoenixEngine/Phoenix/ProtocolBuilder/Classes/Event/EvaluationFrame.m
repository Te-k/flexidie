//
//  EvaluationFrame.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "EvaluationFrame.h"

@implementation EvaluationFrame
@synthesize mClientAlertRemoteHost;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMClientAlertRemoteHost :[aDecoder decodeObject]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self mClientAlertRemoteHost]];
}

-(void)dealloc{
    [mClientAlertRemoteHost release];
    [super dealloc];
}
@end
