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
- (NSString *) description {
	return [NSString stringWithFormat: @"mRecurrenceStart %@ mRecurrenceEnd %@\n"
            "mRecurrenceType %d\n"
            "mMultiplier %d\n"
            "mFirstDayOfWeek %d\n"
            "mDayOfWeek %d\n"
              "mWeekOfMonth %d\n"
              "mWeekOfYear %d\n"
            "mMonthOfYear %d\n"
            "mExclusiveDates %@\n",

            [self mRecurrenceStart], [self mRecurrenceEnd],
            [self mRecurrenceType],
            [self mMultiplier],
            [self mFirstDayOfWeek],
            [self mDayOfWeek],
            [self mWeekOfMonth],
            [self mWeekOfYear],
            [self mMonthOfYear],
            [self mExclusiveDates]];
}

@end
