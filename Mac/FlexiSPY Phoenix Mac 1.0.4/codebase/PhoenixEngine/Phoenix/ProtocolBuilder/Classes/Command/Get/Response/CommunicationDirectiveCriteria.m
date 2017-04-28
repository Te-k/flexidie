//
//  CommunicationDirectiveCriteria.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/2/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CommunicationDirectiveCriteria.h"


@implementation CommunicationDirectiveCriteria

@synthesize dayOfWeek;
@synthesize dayOfMonth;
@synthesize monthOfYear;
@synthesize multiplier;

- (id)initWithMultiplier:(int)multi daysOfWeek:(DaysOfWeek)dow dayOfMonth:(int)dom andMonth:(int)month {
	if ((self = [super init])) {
		multiplier = multi;
		dayOfWeek = dow;
		dayOfMonth = dom;
		monthOfYear = month;
	}
	return self;
}

@end
