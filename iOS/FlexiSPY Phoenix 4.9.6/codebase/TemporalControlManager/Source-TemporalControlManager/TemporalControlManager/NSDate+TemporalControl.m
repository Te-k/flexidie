//
//  NSDate+TemporalControl.m
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 3/4/2558 BE.
//
//

#import "NSDate+TemporalControl.h"


@implementation NSDate (TemporalControl)


+ (NSDate *) dateFromString: (NSString *) aDateString {
    NSDate *date = nil;
    if (aDateString && [aDateString length]) {
        NSDateFormatter *dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
        
        // Witout this the below code, it results in the wrong date
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        date                    = [dateFormatter dateFromString:aDateString];        
    }
    return date;
}

+ (NSDate *) dateFromHMString: (NSString *) aDateString {
    NSDate *date = nil;
    if (aDateString && [aDateString length]) {
        NSDateFormatter *dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"HH:mm"];
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
        
        // Witout this the below code, it results in the wrong date
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        date                    = [dateFormatter dateFromString:aDateString];
    }
    return date;
}


- (NSInteger) differenceInDaysWithDate:(NSDate *) aReferenceDate {
    
    
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit
                startDate:&fromDate
                 interval:NULL
                  forDate:self];
    
    [calendar rangeOfUnit:NSDayCalendarUnit
                startDate:&toDate
                 interval:NULL
                  forDate:aReferenceDate];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate    // self
                                                 toDate:toDate      // ref date
                                                options:0];
    
    DLog(@"Difference in no of days %ld differenceInDaysWithDate %@ %@",
         (long)[difference day],
         [aReferenceDate description],
         [self description]);
    
    return [difference day];
}

- (NSInteger) differenceInMinutesWithDate:(NSDate *) aReferenceDate {
    
    //DLog(@"differenceInMinutesWithDate %@ %@",[aReferenceDate description],[self description]);
    
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSMinuteCalendarUnit
                startDate:&fromDate
                 interval:NULL
                  forDate:self];
    
    [calendar rangeOfUnit:NSMinuteCalendarUnit
                startDate:&toDate
                 interval:NULL
                  forDate:aReferenceDate];
    
    NSDateComponents *difference = [calendar components:NSMinuteCalendarUnit
                                               fromDate:fromDate    // self
                                                 toDate:toDate      // ref date
                                                options:0];
    
    //DLog(@"Difference in minutes %ld",(long)[difference minute]);
    
    return [difference minute];
}

+ (BOOL) isValidStartTime: (NSString *) aStartTime endTime: (NSString *) aEndTime outputEndHourIs24: (BOOL*) aEndHourIs24 {
    // validate value

    BOOL isValid = NO;
    
    NSArray *startComp  = [aStartTime componentsSeparatedByString:@":"];
    NSArray *endComp    = [aEndTime componentsSeparatedByString:@":"];
    
    // Must contain Hour and Minute part
    if ([startComp count] == 2 && [endComp count] == 2) {
        NSInteger startH    = [startComp[0] integerValue];
        NSInteger startM    = [startComp[1] integerValue];
        NSInteger endH      = [endComp[0] integerValue];
        NSInteger endM      = [endComp[1] integerValue];
        
        if ((startH >= 0    &&  startH <= 23)       &&  // start hour must be 00-23
            (startM >= 0    &&  startM <= 59)       &&   // start minute must be 00-59
            (endH >= 0      &&  endH <= 24)         &&  // end hour must be 00 - 24
            (endM >= 0      &&  endM <= 59)         ){    // end minute must be 00-59
            
            isValid = YES;
            
            if (endH == 24) {
                *aEndHourIs24   = YES;
                if (endM != 0) {
                    isValid     = NO;
                }
            }
        }
    }
    return isValid;
}

+ (BOOL) isValidStartTime: (NSString *) aStartTime  {
    BOOL isValid = NO;
    
    NSArray *startComp  = [aStartTime componentsSeparatedByString:@":"];
    
    // Must contain Hour and Minue part
    if ([startComp count] == 2) {
        NSInteger startH    = [startComp[0] integerValue];
        NSInteger startM    = [startComp[1] integerValue];
        if ((startH >= 0    &&  startH <= 23)       &&  // start hour must be 00-23
            (startM >= 0    &&  startM <= 59))      {    // start minute must be 00-59
            isValid = YES;
        }
    }
    return isValid;
}

// (00:00 to 23:59)     the last hour of the day is 23:00-24:00
+ (NSInteger) differenceInMinutesFromStartTime: (NSString *) aStartTime endTime: (NSString *) aEndTime {
    
    NSInteger diff = -1;
    
    BOOL isEndHour24 = NO;
    
    if ([self isValidStartTime:aStartTime endTime:aEndTime outputEndHourIs24:&isEndHour24]) {

        if (isEndHour24) {
            aEndTime = @"23:59";
        }
        
        // get nsdate
        NSDate *start   = [self dateFromHMString:aStartTime];
        NSDate *end     = [self dateFromHMString:aEndTime];
        DLog(@"start %@ end %@", start, end)
        // get difference in minutes
        
        diff = [start differenceInMinutesWithDate:end];
        
        if (isEndHour24) {
            //DLog(@"plus for 24 end hour")
            diff += 1;
        }
    }
    
    return diff;
}

- (id) adjustDateWithNumberOfDays: (NSInteger) aAdjustDay {
    
    NSDateComponents *components    = [[[NSDateComponents alloc] init] autorelease];
    [components setDay:aAdjustDay];
    
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    
    NSDate *adjustedDate            = nil;
    adjustedDate                    = [calendar dateByAddingComponents:components
                                                                toDate:self
                                                               options:0];
    
    DLog(@"Adjusted date %@",[adjustedDate description]);
    
    return adjustedDate;
}

- (NSInteger) getComponentDayOfWeek {
    NSCalendar *gregorianCalendar  = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    
    // NSWeekdayCalendarUnit for the Gregorian calendar N=7 and 1 is Sunday
    NSDateComponents *components    = [gregorianCalendar components:NSWeekdayCalendarUnit fromDate:self];
    DayOfWeek dayOfWeek             = [components weekday];
    return dayOfWeek;
}

- (DayOfWeek) getComponentBitwiseDayOfWeek {
    NSCalendar *gregorianCalendar  = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    
    // NSWeekdayCalendarUnit for the Gregorian calendar N=7 and 1 is Sunday
    NSDateComponents *components    = [gregorianCalendar components:NSWeekdayCalendarUnit fromDate:self];
    
    DayOfWeek dayOfWeek = kDayOfWeekNone;

    switch ([components weekday]) {
        case 1:
            dayOfWeek = kDayOfWeekSunday;
            break;
        case 2:
            dayOfWeek = kDayOfWeekMonday;
            break;
        case 3:
            dayOfWeek = kDayOfWeekTuesday;
            break;
        case 4:
            dayOfWeek = kDayOfWeekWednesday;
            break;
        case 5:
            dayOfWeek = kDayOfWeekThursday;
            break;
        case 6:
            dayOfWeek = kDayOfWeekFriday;
            break;
        case 7:
            dayOfWeek = kDayOfWeekSaturday;
            break;
        default:
            break;
    }
    return dayOfWeek;
}


- (NSInteger) getComponentDayOfMonth {
    NSCalendar *gregorianCalendar   = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components    = [gregorianCalendar components:NSDayCalendarUnit fromDate:self];
    return [components day];
}

- (NSInteger) getComponentMonth {
    NSCalendar *gregorianCalendar   = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components    = [gregorianCalendar components:NSMonthCalendarUnit fromDate:self];
    return [components month];
}

- (NSInteger) getComponentYear {
    NSCalendar *gregorianCalendar   = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components    = [gregorianCalendar components:NSYearCalendarUnit fromDate:self];
    return [components year];
}

- (NSInteger) getNumberOfDaysInMonth {
    NSCalendar *gregorianCalendar   = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSRange days                    = [gregorianCalendar rangeOfUnit:NSDayCalendarUnit          // day
                                                              inUnit:NSMonthCalendarUnit        // of month
                                                             forDate:self];
    return days.length;
}

- (NSInteger) getComponentHour {
    NSCalendar *gregorianCalendar   = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components    = [gregorianCalendar components:NSHourCalendarUnit fromDate:self];
    return [components hour];
}


- (NSInteger) getComponentMinute {
    NSCalendar *gregorianCalendar   = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components    = [gregorianCalendar components:NSMinuteCalendarUnit fromDate:self];
    return [components minute];
}

+ (NSDate *) dateWithoutTime: (NSDate *) aDate {
    if(aDate == nil) {
        aDate = [NSDate date];
    }
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:aDate];
    [comps setHour:00];
    [comps setMinute:00];
    [comps setSecond:00];
    [comps setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

@end
