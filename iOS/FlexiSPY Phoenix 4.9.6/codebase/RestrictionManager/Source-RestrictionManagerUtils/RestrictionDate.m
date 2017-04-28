//
//  RestrictionDate.m
//  RestrictionManagerUtils
//
//  Created by Syam Sasidharan on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestrictionDate.h"
#import "CDCriteria.h"

#define kSUNDAYASSTRING @"Sunday"
#define kMONDAYASSTRING @"Monday"
#define kTUESDAYASSTRING @"Tuesday"
#define kWEDNESDAYASSTRING @"Wednesday"
#define kTHURSDAYASSTRING @"Thursday"
#define kFRIDAYASSTRING @"Friday"
#define kSATURDAYASSTRING @"Saturday"

#define kJANUARYASSTRING @"January"
#define kFEBRUARRYASSTRING @"February"
#define kMARCHASSTRING @"March"
#define kAPRILASSTRING @"April"
#define kMAYASSTRING @"May"
#define kJUNEASSTRING @"June"
#define kJULYASSTRING @"July"
#define kAUGUSTASSTRING @"August"
#define kSEPTEMBERASSTRING @"September"
#define kOCTOBERASSTRING @"October"
#define kNOVEMBERASSTRING @"November"
#define kDECEMBERASSTRING @"December"

@interface RestrictionDate (private)

- (NSInteger) getWeekDayNo: (NSInteger )aWeekDayNo ;
- (NSInteger) getWeekDayInProtocolCompatibleFormat: (NSInteger )aWeekDayNo;
- (NSString *) getMonthAsString : (NSInteger) aMonthNo;
- (NSString *) getWeekDayAsString : (NSInteger) aWeekDayNo;
- (void) getComponentsFromDate: (NSDate *)aDate;

@end


@implementation RestrictionDate

@synthesize mDayNo;
@synthesize mWeekDayNo;
@synthesize mMonthNo; 
@synthesize mYearNo; 
@synthesize mDay;
@synthesize mMonth;
@synthesize mDate;
@synthesize mNoOfDaysInMonth;
@synthesize mMonthNoBasedOnCurrentDate;
@synthesize mProtocolCompatibleDayNo;


- (id) init
{
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

- (id) initWithDate :(NSDate *) aDate {
    
    if (aDate) {
		if ((self = [super init])) {
			[self getComponentsFromDate:aDate];
		}
	}
	return (self);
}

- (NSString *) getMonthAsString : (NSInteger) aMonthNo {
    
    NSString *month = nil;
    
    switch (aMonthNo) {
        case kJanuary:			// 1
            month = kJANUARYASSTRING;
            break;
        case kFebruary:
            month = kFEBRUARRYASSTRING;
            break;
        case kMarch:
            month = kMARCHASSTRING;
            break;
        case kApril:
            month = kAPRILASSTRING;
            break;
        case kMay:
            month = kMAYASSTRING;
            break;
        case kJune:
            month = kJUNEASSTRING;
            break;
        case kJuly:
            month = kJULYASSTRING;
            break;
        case kAugust:
            month = kAUGUSTASSTRING;
            break;
        case kSeptember:
            month = kSEPTEMBERASSTRING;
            break;
        case kOctober:
            month = kOCTOBERASSTRING;
            break;
        case kNovember:
            month = kNOVEMBERASSTRING;
            break;
        case kDecember:
            month = kDECEMBERASSTRING;
            break;
        default:
            break;
    }
    
    return month;
}

- (NSString *) getWeekDayAsString : (NSInteger) aWeekDayNo {
 
    NSString *weekDay = nil;
    
    switch (aWeekDayNo) {
        case kSunday:				// 1
            weekDay = kSUNDAYASSTRING;
            break;
        case kMonday:
            weekDay = kMONDAYASSTRING;
            break;
        case kTuesday:
            weekDay = kTUESDAYASSTRING;
            break;
        case kWednesday:
            weekDay = kWEDNESDAYASSTRING;
            break;
        case kThursday:
            weekDay = kTHURSDAYASSTRING;
            break;
        case kFriday:
            weekDay = kFRIDAYASSTRING;
            break;
        case kSaturday:
            weekDay = kSATURDAYASSTRING;
            break;
        default:
            break;
    }
    
    return weekDay;
}

// The value follows the protocol
// get day of week in from of bit
- (NSInteger) getWeekDayInProtocolCompatibleFormat: (NSInteger )aWeekDayNo {
    
    NSInteger weekDay = 0;
    
    switch (aWeekDayNo) {
        case kSunday:
            weekDay = CDCriteriaSunday;		// 1
            break;
        case kMonday:
            weekDay = CDCriteriaMonday;		// 2
            break;
        case kTuesday:
            weekDay = CDCriteriaTuesday;	// 4
            break;
        case kWednesday:
            weekDay = CDCriteriaWednesday;	// 8
            break;
        case kThursday:
            weekDay = CDCriteriaThursday;	// 16
            break;
        case kFriday:
            weekDay = CDCriteriaFriday;		// 32
            break;
        case kSaturday:
            weekDay = CDCriteriaSaturday;	// 64
            break;
        default:
            break;
    }    
    return weekDay;
}

// get day of week
- (NSInteger) getWeekDayNo: (NSInteger )aWeekDayNo {
    
    NSInteger weekDay = 0;
    
    switch (aWeekDayNo) {
        case kMonday:
            weekDay = 1;
            break;
        case kTuesday:
            weekDay = 2;
            break;
        case kWednesday:
            weekDay = 3;
            break;
        case kThursday:
            weekDay = 4;
            break;
        case kFriday:
            weekDay = 5;
            break;
        case kSaturday:
            weekDay = 6;
            break;
        case kSunday:
            weekDay = 7;
            break;
        default:
            break;
    }
    
    return weekDay;
}

- (void) getComponentsFromDate: (NSDate *) aDate {
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [currentCalendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit 
													  fromDate:aDate];    
    [self setMDate:aDate];
    [self setMDayNo:[components day]];
    [self setMMonthNo:[components month]];
    [self setMYearNo:[components year]];
    [self setMDay:[self getWeekDayAsString:(NSInteger)[components weekday]]];
    [self setMMonth:[self getMonthAsString:(NSInteger)[components month]]];
    
    NSRange days = [currentCalendar rangeOfUnit:NSDayCalendarUnit											// day
                                         inUnit:NSMonthCalendarUnit											// of month
                                        forDate:aDate];						
    [self setMNoOfDaysInMonth:days.length];																	// day of month
    [self setMProtocolCompatibleDayNo:[self getWeekDayInProtocolCompatibleFormat:[components weekday]]];	// day of week (the value follow the protocol)
    [self setMWeekDayNo:[components weekday]];																// day of week 1-7
    
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    
    components = [currentCalendar components:unitFlags														// Get the difference between two supplied date
                                    fromDate:aDate
                                      toDate:[NSDate date] 
                                     options:0];
    
    NSInteger months = [components month];																	
    //NSInteger days = [components day];
    //DLog (@"months: %d", months)
    [self setMMonthNoBasedOnCurrentDate:months];															// month of year
	
}	

- (id) adjustDateBy: (NSInteger) aAdjustParam {
    
    NSDate *adjustedDate = nil;

    NSDateComponents *components= [[[NSDateComponents alloc] init] autorelease];
    [components setDay:aAdjustParam];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    adjustedDate = [calendar dateByAddingComponents:components toDate:[self mDate] options:0];
    
    DLog(@"Adjusted date %@",[adjustedDate description]);
    
    if (adjustedDate) {
        
        DLog(@"Current Date %@ Adjusted Date %@",[[self mDate] description],[adjustedDate description]);
        [self getComponentsFromDate:adjustedDate];
    }
    
    return self;
}

- (NSInteger) differenceInDaysWithDate:(NSDate *) aReferenceDate {
    
    DLog(@"differenceInDaysWithDate %@ %@",[aReferenceDate description],[[self mDate] description]);

    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit 
                startDate:&fromDate
                 interval:NULL 
                  forDate:aReferenceDate];
    
    [calendar rangeOfUnit:NSDayCalendarUnit 
                startDate:&toDate
                 interval:NULL 
                  forDate:[self mDate]];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate 
                                                 toDate:toDate 
                                                options:0];
    
    DLog(@"Difference in no of days %ld month %ld years %ld",[difference day],[difference month],[difference year]);

    return [difference day];
    
    
}

- (NSString *) description {
	return [NSString stringWithFormat:@"mDayNo: %d, mWeekDayNo: %d, mMonthNo: %d, mMonthNoBasedOnCurrentDate: %d, mYearNo: %d, mNoOfDaysInMonth: %d, mProtocolCompatibleDayNo: %d, mDay: %@, mMonth: %@,  mDate:%@",
										mDayNo, mWeekDayNo, mMonthNo, mMonthNoBasedOnCurrentDate, mYearNo, mNoOfDaysInMonth, mProtocolCompatibleDayNo, mDay, mMonth, mDate]; 
}
- (void) dealloc {
    
    [self setMDate:nil];
    [self setMDay:nil];
    [self setMMonth:nil];

    [super dealloc];
}


@end
