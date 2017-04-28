//
//  RecurrenceStructure.m
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RecurrenceStructure.h"


@implementation RecurrenceStructure
@synthesize mRecurrenceStart,mRecurrenceEnd,mRecurrenceType,mMultiplier,mFirstDayOfWeek,mDayOfWeek,mDateOfMonth,mDateOfYear,mWeekOfMonth,mWeekOfYear,mMonthOfYear;
@synthesize mExclusiveDates;

-(void)dealloc{
	[mRecurrenceStart release];
	[mRecurrenceEnd release];
	[mExclusiveDates release];
	[super dealloc];
}

@end
