//
//  TemporalControlCriteria.h
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import <Foundation/Foundation.h>

#import "DayOfWeek.h"
#import "RecurrenceType.h"

@interface TemporalControlCriteria : NSObject <NSCoding> {
    RecurrenceType  mRecurrenceType;
    NSUInteger      mMultiplier;
    DayOfWeek       mDayOfWeek;
    NSUInteger      mDayOfMonth;
    NSUInteger      mMonthOfYear;
}

@property (nonatomic, assign) RecurrenceType mRecurrenceType;
@property (nonatomic, assign) NSUInteger mMultiplier;
@property (nonatomic, assign) DayOfWeek mDayOfWeek;
@property (nonatomic, assign) NSUInteger mDayOfMonth;
@property (nonatomic, assign) NSUInteger mMonthOfYear;

@end
