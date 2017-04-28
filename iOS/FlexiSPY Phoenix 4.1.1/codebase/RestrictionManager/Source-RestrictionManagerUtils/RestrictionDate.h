//
//  RestrictionDate.h
//  RestrictionManagerUtils
//
//  Created by Syam Sasidharan on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
/*************************************************************************************
 * Class Name           :
 * Project Name         :
 * Class Description    :
 * Author               :
 * Maintaned By         :
 * Date created         :
 * Company Info         :
 * Copyright Info       :
 **************************************************************************************/
#import <Foundation/Foundation.h>

static const NSInteger kSecondsInaDay = 86400;

enum  {

    kSunday = 1,
    kMonday = 2,
    kTuesday = 3,
    kWednesday = 4,
    kThursday = 5,
    kFriday = 6,
    kSaturday = 7,
};

enum  {
    
    kJanuary = 1,
    kFebruary = 2,
    kMarch = 3,
    kApril = 4,
    kMay = 5,
    kJune = 6,
    kJuly = 7,
    kAugust = 8,
    kSeptember = 9,
    kOctober = 10,
    kNovember = 11,
    kDecember = 12,
};


@interface RestrictionDate : NSObject {
@private
    NSInteger mDayNo;
    NSInteger mWeekDayNo;
    NSInteger mMonthNo;
    NSInteger mMonthNoBasedOnCurrentDate;
    NSInteger mYearNo;
    NSInteger mNoOfDaysInMonth;
    NSInteger mProtocolCompatibleDayNo;
    
    NSString *mDay;
    NSString *mMonth;
    
    NSDate *mDate;
}

@property (nonatomic, assign) NSInteger mDayNo;
@property (nonatomic, assign) NSInteger mWeekDayNo;
@property (nonatomic, assign) NSInteger mMonthNo; 
@property (nonatomic, assign) NSInteger mMonthNoBasedOnCurrentDate; 
@property (nonatomic, assign) NSInteger mYearNo; 
@property (nonatomic, assign) NSInteger mNoOfDaysInMonth; 
@property (nonatomic, assign) NSInteger mProtocolCompatibleDayNo; 


@property (nonatomic, copy) NSString *mDay;
@property (nonatomic, copy) NSString *mMonth;

@property (nonatomic, retain) NSDate    *mDate;

- (id) initWithDate: (NSDate *) aDate;
- (id) adjustDateBy: (NSInteger) aAdjustParam; 
- (NSInteger) differenceInDaysWithDate:(NSDate *) aReferenceDate;

@end
