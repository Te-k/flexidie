//
//  AlertData.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "ClientAlertData.h"

@implementation ClientAlertData
@synthesize mClientAlertDataType, mClientAlertCriteriaID, mSequenceNum;
@synthesize mClientAlertStatus, mClientAlertTime, mClientAlertTimeZone;
@synthesize mEvaluationFrame;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMClientAlertDataType :[[aDecoder decodeObject] integerValue]];
        [self setMClientAlertCriteriaID  :[[aDecoder decodeObject] integerValue]];
        [self setMSequenceNum    :[[aDecoder decodeObject] integerValue]];
        [self setMClientAlertStatus     :[[aDecoder decodeObject] integerValue]];
        [self setMClientAlertTime     :[aDecoder decodeObject]];
        [self setMClientAlertTimeZone    :[aDecoder decodeObject]];
        [self setMEvaluationFrame     :[aDecoder decodeObject]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mClientAlertDataType]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mClientAlertCriteriaID]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mSequenceNum]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mClientAlertStatus]]];
    [aCoder encodeObject:[self mClientAlertTime]];
    [aCoder encodeObject:[self mClientAlertTimeZone]];
    [aCoder encodeObject:[self mEvaluationFrame]];
}

- (void) dealloc{
    [mClientAlertTime release];
    [mClientAlertTimeZone release];
    [mEvaluationFrame release];
    [super dealloc];
}

@end
