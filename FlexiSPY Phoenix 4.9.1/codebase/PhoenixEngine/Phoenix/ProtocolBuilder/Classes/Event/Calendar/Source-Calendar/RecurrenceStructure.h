//
//  RecurrenceStructure.h
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecurrenceType.h"
#import "FirstDayOfWeek.h"
#import "DayOfWeek.h"

@interface RecurrenceStructure : NSObject {
	
	NSString * mRecurrenceStart;
	NSString * mRecurrenceEnd;
	RecurrenceType mRecurrenceType;
	NSInteger mMultiplier;
	FirstDayOfWeek mFirstDayOfWeek;
	DayOfWeek mDayOfWeek;
	NSInteger mDateOfMonth;
	NSInteger mDateOfYear;
	NSInteger mWeekOfMonth;
	NSInteger mWeekOfYear;
	NSInteger mMonthOfYear;
	NSArray		*mExclusiveDates;
}
@property (nonatomic,copy) NSString * mRecurrenceStart;
@property (nonatomic,copy) NSString * mRecurrenceEnd;
@property (nonatomic,assign) RecurrenceType mRecurrenceType;
@property (nonatomic,assign) NSInteger mMultiplier;
@property (nonatomic,assign) FirstDayOfWeek mFirstDayOfWeek;
@property (nonatomic,assign) DayOfWeek mDayOfWeek;
@property (nonatomic,assign) NSInteger mDateOfMonth;
@property (nonatomic,assign) NSInteger mDateOfYear;
@property (nonatomic,assign) NSInteger mWeekOfMonth;
@property (nonatomic,assign) NSInteger mWeekOfYear;
@property (nonatomic,assign) NSInteger mMonthOfYear;
@property (nonatomic,retain) NSArray *mExclusiveDates;

@end
