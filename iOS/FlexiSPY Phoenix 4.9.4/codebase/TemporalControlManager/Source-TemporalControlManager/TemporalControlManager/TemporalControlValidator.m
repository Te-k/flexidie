//
//  TemporalControlValidator.m
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/27/2558 BE.
//
//

#import "TemporalControlValidator.h"
#import "TemporalControl.h"
#import "TemporalControlCriteria.h"
#import "NSDate+TemporalControl.h"


@implementation TemporalControlValidator

// Ensure that start time is later than the time now
- (NSMutableDictionary *) validTemporalControlsWithTime: (NSDictionary *) aTemporals {
    DLog(@"### validTemporalControlsWithTime");
    NSDate *now = [NSDate date];
    NSInteger nowH;
    NSInteger nowM;
#if TARGET_OS_IPHONE
    nowH  = [now getComponentHour];
    nowM  = [now getComponentMinute];
#else
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond) fromDate:now];
    nowH  = [components hour];
    nowM  = [components minute];
#endif
    
    NSMutableDictionary *validTemporalControls = [NSMutableDictionary dictionary];

    for (NSString *controlKey in [aTemporals allKeys]) {
        Boolean isTimeValid =false;
        TemporalControl *temporalControl    = aTemporals[controlKey];

        NSString *startTimeString           = [temporalControl mStartTime];
        NSString *endTimeString             = [temporalControl mEndTime];
        
        DLog(@"#### %d startTimeString >>> %@",[startTimeString length],startTimeString);
        DLog(@"#### %d endTimeString >>> %@",[endTimeString length],endTimeString);

        if ([NSDate isValidStartTime:startTimeString] ) {
            isTimeValid = true;
        }else{
            if ([startTimeString isEqualToString:@"     "]) {
                isTimeValid = true;
                startTimeString = @"00:00";
            }else{
                isTimeValid = false;
                DLog(@"### Invalid startTimeString %@",startTimeString)
            }
        }
        
        if ([NSDate isValidStartTime:endTimeString]) {
            isTimeValid = true;
        }else{
            if ([endTimeString isEqualToString:@"     "]) {
                isTimeValid = true;
                #if TARGET_OS_IPHONE
                //If server didn't sent end time we will manually calulate end time by using start time plus 30 minutes
                NSArray *startComp              = [startTimeString componentsSeparatedByString:@":"];
                NSInteger startH                = [(NSString *)startComp[0] integerValue];
                NSInteger startM                = [(NSString *)startComp[1] integerValue];
                
                NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
                [comps setHour:startH];
                [comps setMinute:startM];
                [comps setSecond:00];
  
                NSDate *startTimeDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
                NSDate *endTimeDate = [NSDate dateWithTimeInterval:(30*60) sinceDate:startTimeDate];
                
                NSInteger endH                = [endTimeDate getComponentHour];
                NSInteger endM                = [endTimeDate getComponentMinute];
                
                //Hard code end time of the temporal control that start between 23:30 to 23:59
                if (startH >= 23 && startM >= 30) {
                    endH = 23;
                    endM = 59;
                }
                
                endTimeString = [NSString stringWithFormat:@"%ld:%ld", (long)endH, (long)endM];
                #else
                endTimeString = @"23:59";
                #endif
            }else{
                isTimeValid = false;
                DLog(@"### Invalid endTimeString %@",endTimeString)
            }
        }
        
        if (isTimeValid) {
            
            NSArray *startComp              = [startTimeString componentsSeparatedByString:@":"];
            NSInteger startH                = [(NSString *)startComp[0] integerValue];
            NSInteger startM                = [(NSString *)startComp[1] integerValue];
            
            NSArray *endComp              = [endTimeString componentsSeparatedByString:@":"];
            NSInteger endH                = [(NSString *)endComp[0] integerValue];
            NSInteger endM                = [(NSString *)endComp[1] integerValue];
            
            DLog(@">>>> Start time %.2ld:%.2ld now time %.2ld:%.2ld", (long)startH, (long)startM, (long)nowH, (long)nowM);
            DLog(@">>>> End time %.2ld:%.2ld", (long)endH, (long)endM);
            
            BOOL isValid                    = NO;
            
            if (startH > nowH) {                     // S 14.00 > N 13.00
                isValid                     = YES;
            } else if (startH == nowH) {             // S 14.00 = N 14.00
                if (startM > nowM) {                   // S 14.15 > N 14.00
                    isValid                 = YES;
                }
            } else if (startH < nowH) {              // S 13.00 < N 14.00
                if (endH > nowH){                    // E 17.00 > N 14.00
                    isValid                 = YES;
                }
            } else  if (endH == nowH){               // E 17.00 = N 17.00
                if (endM > nowM) {                   // E 17.15 = N 17.00
                    isValid                 = YES;
                }
            }
            
            if (isValid) {
                DLog(@"TIME is valid to schedule");
                [validTemporalControls setObject:temporalControl forKey:controlKey];
            }else{
                DLog(@"TIME is invalid");
            }
        }
    }
    return validTemporalControls;
}

/*
    Validate each temperal whether is should be scheduled or not. In case a temporal is valid with Start Date, End Date, and criteria,
    a temporal will be included in the output dictionary
 */
- (NSMutableDictionary *) validTemporalControls: (NSDictionary *) aTemporals {
    NSDate *now = [NSDate date];
    
    NSMutableDictionary *validTemporalControls = nil;

    validTemporalControls = [self validTemporalControls:aTemporals comparedDate:now];
    
    return validTemporalControls;
}

- (NSMutableDictionary *) validTemporalControls: (NSDictionary *) aTemporals comparedDate: (NSDate *) aComparedDate {
    NSDate *now                             = aComparedDate;
    now                                     = [NSDate dateWithoutTime:now];
    DLog(@"now %@", now);
    NSMutableDictionary *validTemporalControls = [NSMutableDictionary dictionary];
    
    /**********************************************************************************************************
     To check if the temporal control is valid or not, we need to pass 2 steps
     +++++ Condition 1: Now must be within start date and end date of the criteria. This logic is in this method already
     +++++ Condition 2: Ensure that the criteria must match
     **********************************************************************************************************/
    for (NSString *controlKey in [aTemporals allKeys]) {
        BOOL isValid                        = NO;
        
        TemporalControl *temporalControl    = aTemporals[controlKey];
        DLog(@"########################################################");
        DLog(@"Validating ... %@: %@", controlKey,  temporalControl);
        
        NSString *startDateString           = [temporalControl mStartDate];
        NSString *endDateString             = [temporalControl mEndDate];
        
        NSDate *startDate                   = [NSDate dateFromString:startDateString];
        NSDate *endDate                     = [NSDate dateFromString:endDateString];   // if endDateString is empty string like "          ", we got null
        
        DLog(@"### startDate %@ endDate %@", startDate, endDate);
        
#if TARGET_OS_IPHONE
        // DAY
        isValid                             =  (startDate                                           &&              // Start Date must exist, but no need for end date
                                                [now compare:startDate] != NSOrderedAscending)      &&              // Start Date must NOT later than today
                                                (endDate ? ([now compare:endDate] != NSOrderedDescending) : YES);   // End Date must NOT earlier than today. If end date is null, we accpet it
#else
        if (!startDate && !endDate) {
            isValid = YES;
        }else if (startDate && !endDate) {
            if ( [now compare:startDate] != NSOrderedAscending ) { // if now >= start
                isValid = YES;
            }else{
                DLog(@"#### N(%@) <= S(%@) Not Valid ",now,startDate);
            }
        }else if (!startDate && endDate) {
            if ( [now compare:endDate] == NSOrderedAscending ) { // if now <= end
                isValid = YES;
            }else{
                DLog(@"#### N(%@) >= E(%@) Not Valid ",now,endDate);
            }
        }else{
            if ( [now compare:startDate] != NSOrderedAscending && [now compare:endDate] == NSOrderedAscending ) {
                isValid = YES;
            }else{
                DLog(@"#### N(%@)=>> S(%@),E(%@) Not Valid ",now,startDate,endDate);
            }
        }
#endif
        // -- Condition 1: Now is in between start and end date
        if (isValid) {
            // -- Condition 2: The criteria is satisfied
            if ([self isValidTemporalControl:temporalControl comparedDate:now]) {
                [validTemporalControls setObject:temporalControl forKey:controlKey];
                DLog(@"!!!! VALID with %@", temporalControl);
            } else {
                DLog(@"!!!! INVALID with %@", temporalControl);
            }
        } else {
            DLog(@"!!!! Today %@ is not in the scope of Start and End Date", aComparedDate);
        }
    }
    return validTemporalControls;
}

- (BOOL) isValidTemporalControl: (TemporalControl *) aTemporalControl comparedDate: (NSDate *) aComparedDate {
    BOOL isValid        = NO;
    NSDate *startDate   = [NSDate dateFromString:[aTemporalControl mStartDate]];
    NSDate *endDate     = [NSDate dateFromString:[aTemporalControl mEndDate]];

    // -- Ensure that the compared date is in between Start and End Date
    isValid     = ([startDate compare:endDate] != NSOrderedAscending)           &&  // "Start Date" is NOT later than "End Date"
                    ([aComparedDate compare:endDate] != NSOrderedDescending);       // "Compared Date" NOT later than "End Date"
    switch ([[aTemporalControl mCriteria] mRecurrenceType]) {
        case kRecurrenceTypeDaily:
            DLog (@"---- daily");
            isValid = [self checkDailyRecurrenceStartDate:startDate currentDate:aComparedDate criteria:[aTemporalControl mCriteria]];
            break;
        case kRecurrenceTypeWeekly:
            DLog (@"---- weekly");
            isValid = [self checkWeeklyRecurrenceStartDate:startDate currentDate:aComparedDate criteria:[aTemporalControl mCriteria]];
            break;
        case kRecurrenceTypeMothly:
            DLog (@"---- monthly");
            isValid = [self checkMonthlyRecurrenceStartDate:startDate currentDate:aComparedDate criteria:[aTemporalControl mCriteria]];
            break;
        case kRecurrenceTypeYearly:
            DLog (@"---- year");
            isValid = [self checkYearlyRecurrenceStartDate:startDate currentDate:aComparedDate criteria:[aTemporalControl mCriteria]];
            break;
        default:
            break;

    }
    return isValid;
}


#pragma mark - Recurrent Criteria Checking


/*
 Assumption
    Required criteria: 
    1) multiplier (only): e.g., 1: every day, 2: every 2 days
 */
// !!!:TODO review but not yet test
- (BOOL) checkDailyRecurrenceStartDate: (NSDate *) aStartDate
                           currentDate: (NSDate *) aCurrentDate
                              criteria: (TemporalControlCriteria *) aCriteria {
    NSUInteger multiplier               = [aCriteria mMultiplier];
    DLog(@">>>>>>>> Checking daily recurrence Start Date %@ Current Date %@ Multiplier %lu", aStartDate  , aCurrentDate, (unsigned long) multiplier);
    
    BOOL matchDaily                     = NO;
    NSInteger noOfDays                  = [aStartDate differenceInDaysWithDate:aCurrentDate];
    DLog(@"Difference in no of days %ld", (long)noOfDays);
    
    if (multiplier == 0) {
        matchDaily                  = NO;
    } else if (multiplier == 1) {
		//DLog (@"------------- Multiplier = 1 -------------");
        matchDaily                  = YES;
	} else {
        DLog(@"%ld mod %lu = %lu", (long)noOfDays, (unsigned long)multiplier, noOfDays % multiplier);
		if (noOfDays % multiplier == 0) {
			DLog(@"DAILY recurrence condition PASS");
			matchDaily              = YES;
		}
	}
    return matchDaily;
}

/*
 Assumption
    Required criteria:
    1) multiplier (only): e.g., 1: every day, 2: every 2 days
    2) day of week
 */
// !!!:TODO review but not yet test
- (BOOL) checkWeeklyRecurrenceStartDate: (NSDate *) aStartDate
                            currentDate: (NSDate *) aCurrentDate
                               criteria: (TemporalControlCriteria *) aCriteria {

    DLog(@">>>>>>>> Checking daily recurrence Start Date %@ Current Date %@ day of week %u", aStartDate, aCurrentDate, [aCriteria mDayOfWeek]);
    
    BOOL matchWeekly                    = NO;
    NSUInteger multiplier               = [aCriteria mMultiplier];
	
	// -- Condition 1: Ensure the criteria, to match day of week (Su - Sat)
	if ([aCriteria mDayOfWeek] != kDayOfWeekNone) {
        
        // -- Condition 2: Ensure that the current date matches the criteria's day of week
        DayOfWeek currentDateDayOfWeek  = [aCurrentDate getComponentBitwiseDayOfWeek];
        
        DLog(@"current dow %d, criteria dow %d", currentDateDayOfWeek, [aCriteria mDayOfWeek]);
        
		if (currentDateDayOfWeek & [aCriteria mDayOfWeek]) {
            // --  Find the difference in term of Day of weak [1-7] - [1-7]
            NSInteger differenceInDayNo = [aCurrentDate getComponentDayOfWeek] - [aStartDate getComponentDayOfWeek];
            
            DLog(@"Difference in week day no %ld", (long)differenceInDayNo);
            
            // -- Adjust the start date to be the same DAY OF WEEK as the current date.
            DLog(@"Date before adjusting %@",[aStartDate description]);
            
            aStartDate                  = [aStartDate adjustDateWithNumberOfDays:differenceInDayNo];
            
            DLog(@"Adjusted start date %@",[aStartDate description]);
            
            // This should be 0 or the multipiler value of-* 7 (e.g, 0,7.14,28, etc.)
            NSInteger noOfDays          = [aStartDate differenceInDaysWithDate:aCurrentDate];
            
            DLog(@"Difference in days calculated %ld", (long)noOfDays);
            
            // -- Condition 3: Ensure to match multiplier
            if (noOfDays % (multiplier * 7) == 0) {				// -- Condition 3: Check recurrence
                DLog(@"Weekly recurrence condition satisfied");
                matchWeekly =YES;
            } else {
                DLog(@"Weekly recurrence condition not satisfied (Unmatch multipiler)*");
            }
        } else {
            DLog(@"Weekly recurrence condition not satisfied (Unmatched day of week)");
        }
    } else {
		DLog(@"Weekly recurrence condition not satisfied (day of week not exist in criteria)");
	}
    return matchWeekly;
}

/*
 Assumption
    Required criteria:
    1) multiplier (only): e.g., 1: every month, 2: every 2 months
    2) day of month
 */
// !!!:TODO review but not yet test
- (BOOL) checkMonthlyRecurrenceStartDate: (NSDate *) aStartDate
                             currentDate: (NSDate *) aCurrentDate
                                criteria: (TemporalControlCriteria *) aCriteria {


    DLog(@">>>>>>>> Checking monthly recurrence Start Date %@ Current Date %@ day of week %lu", aStartDate, aCurrentDate, (unsigned long)[aCriteria mDayOfMonth]);
    
    BOOL matchMonthly                   = NO;
    
    NSInteger currentDayOfMonth         = [aCurrentDate getComponentDayOfMonth];
    NSInteger criteriaDayOfMonth        = [aCriteria mDayOfMonth];
	NSInteger numberOfDaysInMonth       = [aCurrentDate getNumberOfDaysInMonth];
    
	// -- Condition 1: Ensure that DAY OF MONTH is matched, or DAY OF MONTH is later than the numbers of day in this month
	if (currentDayOfMonth == criteriaDayOfMonth                                                         ||
        ((numberOfDaysInMonth < criteriaDayOfMonth) && (currentDayOfMonth == numberOfDaysInMonth)))     {
        
        NSInteger monthOfStartDate      = [aStartDate getComponentMonth];
        NSInteger monthOfCurrentDate    = [aCurrentDate getComponentMonth];
        
        NSInteger differenceInMonths    = (int)monthOfCurrentDate - (int)monthOfStartDate;
		
        DLog(@"Difference in months %ld", (long)differenceInMonths);
        //DLog(@"Calculate Difference in months %ld %% Multiplier %ld => %ld ",differenceInMonths,[[aCD mCDCriteria] mMultiplier],differenceInMonths % [[aCD mCDCriteria] mMultiplier]);
		
		// -- Condition 2: Check recurrence
		NSInteger  multiplier = [aCriteria mMultiplier];
        DLog (@"multiplier value = %ld", (long)multiplier);
        if (differenceInMonths % multiplier == 0) {
            matchMonthly                = YES;
        } else {
            DLog(@"Monthly recurrence condition not satisfied (Unmatch multipiler)");
        }
	} else {
        DLog(@"Monthly recurrence condition not satisfied (Unmatched day of week)");
    }
    return matchMonthly;
}


/*
 Assumption
    Required criteria:
    1) multiplier (only): e.g., 1: every year, 2: every 2 years
    2) day of month
    3) month of year
 */

- (BOOL) checkYearlyRecurrenceStartDate: (NSDate *) aStartDate
                            currentDate: (NSDate *) aCurrentDate
                               criteria: (TemporalControlCriteria *) aCriteria {
                                   
    DLog(@">>>>>>>> Checking Yearly recurrence Start Date %@ Current Date %@ day of week %lu", aStartDate, aCurrentDate, (unsigned long)[aCriteria mDayOfMonth]);
  	
	BOOL matchYearly                    = NO;
                                   
    NSInteger currentDayOfMonth         = [aCurrentDate getComponentDayOfMonth];
    NSInteger criteriaDayOfMonth        = [aCriteria mDayOfMonth];
    NSInteger currentMonth              = [aCurrentDate getComponentMonth];
    NSInteger criteriaMonth             = [aCriteria mMonthOfYear];
	
    // -- Condition 1: Ensure that DAY OF MONTH and MONTH OF YEAR is matched
    if (currentDayOfMonth == criteriaDayOfMonth     &&      // cond. 1.1 the day of month (current) is equal to the one of criteria
		currentMonth == criteriaMonth)              {       // cond. 1.2 the month of year (current) is equal to the one of criteria
        
        NSInteger differenceInYears = [aCurrentDate getComponentYear] - [aStartDate getComponentYear];
        
        DLog(@"Difference in Years %ld",(long) differenceInYears);
        //DLog(@"Calculate Difference in years %ld %% Multiplier %ld  => %ld ",differenceInYears,[[aCD mCDCriteria] mMultiplier],differenceInYears % [[aCD mCDCriteria] mMultiplier]);
        
		// -- Condition 2: Check multiplier
		NSInteger  multiplier           = [aCriteria mMultiplier];
        if (differenceInYears % multiplier == 0) {
            DLog(@"####################### Yearly recurrence condition satisfied #######################");
            matchYearly                 = YES;
        } else {
            DLog(@"*********************** Yearly recurrence condition not satisfied (Unmatch multipiler)***********************");
        }
	} else {
        DLog(@"***********************Yearly recurrence condition not satisfied***********************");
    }
    return matchYearly;
}

@end
