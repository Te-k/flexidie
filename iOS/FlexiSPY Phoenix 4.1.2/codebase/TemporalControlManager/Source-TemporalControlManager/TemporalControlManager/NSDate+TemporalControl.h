//
//  NSDate+TemporalControl.h
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 3/4/2558 BE.
//
//

#import <Foundation/Foundation.h>


#import "DayOfWeek.h"


@interface NSDate (TemporalControl)

+ (NSDate *) dateFromString: (NSString *) aDateString;
+ (NSDate *) dateWithoutTime: (NSDate *) aDate;

- (NSInteger) differenceInDaysWithDate:(NSDate *) aReferenceDate;
+ (NSInteger) differenceInMinutesFromStartTime: (NSString *) aStartTime endTime: (NSString *) aEndTime;

+ (BOOL) isValidStartTime: (NSString *) aStartTime;

- (id) adjustDateWithNumberOfDays: (NSInteger) aAdjustDay;
- (NSInteger) getComponentDayOfWeek;
- (DayOfWeek) getComponentBitwiseDayOfWeek;
- (NSInteger) getComponentDayOfMonth;
- (NSInteger) getComponentMonth;
- (NSInteger) getComponentYear;
- (NSInteger) getNumberOfDaysInMonth;
- (NSInteger) getComponentHour;
- (NSInteger) getComponentMinute;

//+ (NSDate *) dateWithTime: (NSString *) aTime;
//- (NSDate *) toGlobalTime;
//-(NSDate *) toLocalTime;
//+ (NSDate *) dateWithHour: (NSString *) aHour min: (NSString *) aMin now: (NSDate *) aNow;

@end
