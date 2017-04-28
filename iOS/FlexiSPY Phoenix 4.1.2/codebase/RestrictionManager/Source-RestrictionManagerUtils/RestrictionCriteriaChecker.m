//
//  RestrictionPeriodChecker.m
//  RestrictionManagerUtils
//
//  Created by Syam Sasidharan on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestrictionCriteriaChecker.h"
#import "RestrictionManagerUtils.h"
#import "RestrictionDate.h"
#import "BlockEvent.h"
#import "CD.h"
#import "CDCriteria.h"
#import "SyncTime.h"


@interface RestrictionCriteriaChecker (private) 
- (BOOL)		checkBlockEventActionWithCD: (CD *) aCD;
+ (NSString *)	getBitStringForInt:(int)value;
- (BOOL)		checkBlockEventDirection: (BlockEvent *) aBlockEvent withCD: (CD *) aCD;
- (BOOL)	isPointOfTimeInIntervalForCurrentHour: (NSInteger) aCurrentHour		// current time
									currentMin: (NSInteger) aCurrentMin
									 startHour: (NSInteger) aStartHour		// begin time
									  startMin: (NSInteger) aStartMin
									   endHour: (NSInteger) aEndHour			// end time
										endMin: (NSInteger) aEndMin;
- (BOOL)	isInDiscreateIntervalForCurrentHour: (NSInteger) aCurrentHour			// current time
								  currentMin: (NSInteger) aCurrentMin
						   criteriaStartHour: (NSInteger) aCriteriaStartHour	// begin time
							criteriaStartMin: (NSInteger) aCriteriaStartMin
							 criteriaEndHour: (NSInteger) aCriteriaEndHour		// end time
							  criteriaEndMin: (NSInteger) aCriteriaEndMin;
- (BOOL)		checkBlockEventTime: (BlockEvent *) aBlockEvent 
					  withStartTime: (RestrictionDate *) aStartDate 
							endTime: (RestrictionDate *) aEndDate;
- (BOOL)		checkYearlyRecurrence: (RestrictionDate *) aStartDate : (RestrictionDate *) aEndDate : (RestrictionDate *) aCurrentDate : (CD *) aCD;
- (BOOL)		checkMonthlyRecurrence: (RestrictionDate *) aStartDate : (RestrictionDate *) aEndDate : (RestrictionDate *) aCurrentDate : (CD *) aCD;
- (BOOL)		checkWeeklyRecurrence: (RestrictionDate *) aStartDate : (RestrictionDate *) aEndDate : (RestrictionDate *) aCurrentDate : (CD *) aCD;
- (BOOL)		checkDailyRecurrence: (RestrictionDate *) aStartDate : (RestrictionDate *) aEndDate : (RestrictionDate *) aCurrentDate : (CD *) aCD;
@end


@implementation RestrictionCriteriaChecker


#pragma mark -
#pragma mark Initialization
#pragma mark -


- (id) init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

- (id) initWithWebUserSyncTime: (id) aWebUserSyncTime {    
    if (aWebUserSyncTime) {
		if ((self = [super init])) {
            mWebUserSyncTime = aWebUserSyncTime;
            [mWebUserSyncTime retain];
		}
	}
	return (self);
}

#pragma mark -
#pragma mark Checking block event with Communication Directive
#pragma mark -


- (BOOL) checkBlockEventActionWithCD: (CD *) aCD {    
    DLog(@"Checking block event action with communication directive action");
    BOOL blockAction = NO;
    if ([aCD mAction] == kCDActionDisAllow) {        
        DLog(@"Block action!!!");
        blockAction = YES;
    }
    else {
        DLog(@"Allow action!!!");
    }
    
    return blockAction;
}

+ (NSString *) getBitStringForInt: (int) value {	
    NSString *bits = @"";	
    for(int i = 0; i < 8; i ++) {
        bits = [NSString stringWithFormat:@"%i%@", value & (1 << i) ? 1 : 0, bits];
    }	
    return bits;
}

- (BOOL) checkBlockEventDirection: (BlockEvent *) aBlockEvent withCD: (CD *) aCD {    
    DLog(@"Checking block event type & direction with communication directive event direction");
    BOOL blockDirection = NO;
	DLog (@"mBlockEvent: %d", [aCD mBlockEvents])
	DLog (@"mBlockEvent: %@", [RestrictionCriteriaChecker getBitStringForInt:[aCD mBlockEvents]])
    if ([aBlockEvent mType] & [aCD mBlockEvents]) {				// check block event type     
        DLog(@"Block event type matches with the communication directive type");
        
        if ([aCD mDirection] == kCDDirectionALL) {				// check if block all direction ?
            DLog(@"Block events from all direction");
            blockDirection = YES;
        }
        else {            
            if ([aBlockEvent mDirection] == [aCD mDirection]) {	// check if block in or out direction ?
                DLog(@"Block event direction matches with the communication directive direction");
                blockDirection = YES;
            } else {
				DLog (@"Not match direction")
			}
        }
    }
    return blockDirection;
}

- (BOOL) isPointOfTimeInIntervalForCurrentHour: (NSInteger) aCurrentHour	// current time
									currentMin: (NSInteger) aCurrentMin
									 startHour: (NSInteger) aStartHour		// begin time
									  startMin: (NSInteger) aStartMin
									   endHour: (NSInteger) aEndHour		// end time
										endMin: (NSInteger) aEndMin {
	BOOL blockTime = NO;
	
	// current time is equal to or later than criteria start time
	if ((aCurrentHour > aStartHour) && (aCurrentHour < aEndHour)) {			// between START and END	
		DLog(@"pass time: cond 1 (between START and END)")	
		blockTime = YES;
	} else if ((aCurrentHour == aStartHour)) {								// equal to START hour
		DLog (@"aCurrentMin: %d", aCurrentMin)
		DLog (@"aStartMin: %d", aStartMin)
		if (aStartHour == aEndHour) {
			if ((aCurrentMin >= aStartMin) && (aCurrentMin <= aEndMin)) {	   
				DLog(@"pass time: cond 2 (equal to START hour [case start and end hour is SAME])")
				blockTime = YES;
			}
		} else {
			if ((aCurrentMin >= aStartMin)) {	   
				DLog(@"pass time: cond 2 (equal to START hour [case start and end hour is DIFFERENT])")
				blockTime = YES;
			}
		}			
	} else if ((aCurrentHour == aEndHour)) {								// equal to END hour
		if (aCurrentMin <= aEndMin) {
			DLog(@"pass time: cond 3 (equal to END hour)")
			blockTime = YES; 
		}
	}
	return blockTime;
}

- (BOOL) isInDiscreateIntervalForCurrentHour: (NSInteger) aCurrentHour				// current time
								  currentMin: (NSInteger) aCurrentMin
						   criteriaStartHour: (NSInteger) aCriteriaStartHour		// begin time
							criteriaStartMin: (NSInteger) aCriteriaStartMin
							 criteriaEndHour: (NSInteger) aCriteriaEndHour			// end time
							  criteriaEndMin: (NSInteger) aCriteriaEndMin {			
	NSInteger kStartHourOfTheDay	= 0;
	NSInteger kStartMinOfTheDay		= 01;
	// end time of the day is 23.59 
	NSInteger kEndHourOfTheDay		= 23;	
	NSInteger kEndMinOfTheDay		= 59;			
	
	/***********************************************	
	 *	  begin interval		 end interval
	 *	   <-------->        <--------->
	 *   (0.01)   END     START     (23.59)
	 **********************************************/			
	
	// step 1: Check if it is between 0.01 and criteria end or not
	// step 2: If it is not in the previous interval, check if it is between criteria start and 23.59
	
	// -- step 1
	BOOL blockTime = [self isPointOfTimeInIntervalForCurrentHour:aCurrentHour
													  currentMin:aCurrentMin 
													   startHour:kStartHourOfTheDay
														startMin:kStartMinOfTheDay 
														 endHour:aCriteriaEndHour  
														  endMin:aCriteriaEndMin];				
	/// -- step 2
	if (!blockTime) {
		// check end interval
		blockTime = [self isPointOfTimeInIntervalForCurrentHour:aCurrentHour
													 currentMin:aCurrentMin 
													  startHour:aCriteriaStartHour
													   startMin:aCriteriaStartMin 
														endHour:kEndHourOfTheDay 
														 endMin:kEndMinOfTheDay];
		if (blockTime) {DLog (@"Match end interval")}								
	} else {
		DLog (@"Match begin interval")
	}

	return blockTime;
}

// Note that aStartDate and aEndDate are converted time
- (BOOL) checkBlockEventTime: (BlockEvent *) aBlockEvent 
			   withStartTime: (RestrictionDate *) aStartDate 
					 endTime: (RestrictionDate *) aEndDate		{
    DLog(@"Checking block event TIME");
		
    BOOL blockTime = NO;
		
	// -- initialize 'current' time value
	NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *currentComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit
													  fromDate:[aBlockEvent mDate]];  
	NSInteger currentHour = [currentComponents hour];
	NSInteger currentMinute = [currentComponents minute];
	DLog (@"currentHour:currentMinute %d:%d", currentHour, currentMinute)

	// -- initialize 'criteria' time value
	NSDate* startDate = [aStartDate mDate];
	NSDate* endDate = [aEndDate mDate];
	NSDateComponents *criteriaStartTimeComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit
																fromDate:startDate];
	NSDateComponents *criteriaEndTimeComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit
															  fromDate:endDate];
	NSInteger criteriaStartHour = [criteriaStartTimeComponents hour];
	NSInteger criteriaStartMin	= [criteriaStartTimeComponents minute];
	NSInteger criteriaEndHour	= [criteriaEndTimeComponents hour];
	NSInteger criteriaEndMin	= [criteriaEndTimeComponents minute];	
	DLog (@"criteria start %d:%d", criteriaStartHour, criteriaStartMin)
	DLog (@"criteria end %d:%d", criteriaEndHour, criteriaEndMin)
			
	// time of the day can be 0.01 - 23.59
	BOOL isContinuosInterval = NO;
	BOOL isOneDayInterval = NO;
	
	// -- check if it is 'continuous' or 'discontinuous' interval
	if (criteriaStartHour < criteriaEndHour) {				// START Hour < END Hour
		isContinuosInterval = YES;
	} else if (criteriaStartHour == criteriaEndHour) {		// START Hour = END Hour
		if (criteriaStartMin < criteriaEndMin)				// START Min <= END Min 
			isContinuosInterval = YES;						
		else if (criteriaStartMin == criteriaEndMin) 
			isOneDayInterval = YES;
	} else if (criteriaStartHour > criteriaEndHour) {		// START Hour > END Hour
		isContinuosInterval = NO;
	}
	
	// -- Checking step
	// 1st condition: Check if it is one day interval e.g, from 7 - 7, from 20 - 20   (time unit is 0 - 23)
	// 2nd condition: If it's not one day interval, check if it is continuous or discontinuous interval
	
	if (isOneDayInterval) {			
		DLog (@"One day interval")
		blockTime = YES;
	} else {						
		// -- check if the current time should be blocked or not
		if (isContinuosInterval) {
			DLog (@"continuous interval")
			blockTime = [self isPointOfTimeInIntervalForCurrentHour:currentHour
														 currentMin:currentMinute 
														  startHour:criteriaStartHour
														   startMin:criteriaStartMin 
															endHour:criteriaEndHour 
															 endMin:criteriaEndMin];	
		} else {
			DLog (@"discontinuous interval")	
			blockTime = [self isInDiscreateIntervalForCurrentHour:currentHour 
													   currentMin:currentMinute 
												criteriaStartHour:criteriaStartHour 
												 criteriaStartMin:criteriaStartMin
												  criteriaEndHour:criteriaEndHour 
												   criteriaEndMin:criteriaEndMin];
	
		
		}
	}
	return blockTime;
}

- (BOOL) checkYearlyRecurrence: (RestrictionDate *) aStartDate : (RestrictionDate *) aEndDate : (RestrictionDate *) aCurrentDate : (CD *) aCD {    
    //DLog(@"Checking yearly recurrence Eveny Day No = %d CD Day of Month = %d Event Month No = %d CD Month of Year = %d",[aCurrentDate mDayNo],[[aCD mCDCriteria] mDayOfMonth],[aCurrentDate mMonthNo],[[aCD mCDCriteria] mMonthOfYear]);
//	DLog (@"day of month (criteria) %d", [[aCD mCDCriteria] mDayOfMonth])
//	DLog (@"day of month (current) %d", [aCurrentDate mDayNo])
//	DLog (@"month of year (criteria) %d", [[aCD mCDCriteria] mMonthOfYear])
//	DLog (@"month of year (current) %d", [aCurrentDate mMonthNo])
//	DLog (@"condition 1 %d", [aCurrentDate mNoOfDaysInMonth] >=  [[aCD mCDCriteria] mDayOfMonth])
//	DLog (@"condition 2 %d", [aCurrentDate mDayNo] >= 1)
//	DLog (@"condition 3 %d", [aCurrentDate mDayNo] == [[aCD mCDCriteria] mDayOfMonth])
//	DLog (@"condition 4 %d", [aCurrentDate mMonthNo] == [[aCD mCDCriteria] mMonthOfYear])
	
	BOOL blockYearly = NO;
   	
	// -- Condition 1: Ensure that DAY OF MONTH and MONTH OF YEAR is matched		
    if (([aCurrentDate mNoOfDaysInMonth] >=  [[aCD mCDCriteria] mDayOfMonth])	&&	// cond. 1.1 the number of days in current month is equal or greather than the day of month in criteria
		([aCurrentDate mDayNo] >= 1)											&&	// cond. 1.2 the day of month (current) is equal or greater than 1
		([aCurrentDate mDayNo] == [[aCD mCDCriteria] mDayOfMonth])				&&	// cond. 1.3 the day of month (current) is equal to the one of criteria
		[aCurrentDate mMonthNo] == [[aCD mCDCriteria] mMonthOfYear]) {				// cond. 1.4 the month of year (current) is equal to the one of criteria
        
        NSInteger differenceInYears = [aCurrentDate mYearNo] - [aStartDate mYearNo];
        
        DLog(@"Difference in Years %ld",differenceInYears);
        //DLog(@"Calculate Difference in years %ld %% Multiplier %ld  => %ld ",differenceInYears,[[aCD mCDCriteria] mMultiplier],differenceInYears % [[aCD mCDCriteria] mMultiplier]);

		// -- Condition 2: Check multiplier
		NSInteger  multiplier = [[aCD mCDCriteria] mMultiplier];

		if (multiplier != 0) {												//	CASE 1: multiplier is NOT zero
			DLog(@"mul is NOT ZERO")
			// -- Condition 3: Check recurrence
			if (differenceInYears % multiplier == 0) {		
				DLog(@"####################### Yearly recurrence condition satisfied #######################");
				blockYearly = YES;	
			}
		} else {															//	CASE 2: multiplier is zero	
			NSInteger todayMonth	= [aCurrentDate mMonthNo];
			NSInteger startMonth	= [aStartDate mMonthNo];
			NSInteger todayDate		= [aCurrentDate mDayNo];
			NSInteger startDate		= [aStartDate mDayNo];
			NSInteger todayYear		= [aCurrentDate mYearNo];
			NSInteger startYear		= [aStartDate mYearNo];

			BOOL isTodayLaterMonth	= NO;					
			BOOL isSameMonthWithlaterOrEqualDate = NO;
			BOOL isSameYear			= NO;
			BOOL isNextYear			= NO;
			
			// 1) check month
			// 2) in case of equal month, check date (day of month)
			if (todayMonth > startMonth) {							
				isTodayLaterMonth = YES;
			} else if (todayMonth == startMonth) {
				if (todayDate >= startDate) {
					isSameMonthWithlaterOrEqualDate = YES;					
				}
			}
			if (todayYear == startYear)
				isSameYear = YES;
			if (todayYear == startYear + 1)
				isNextYear = YES;
				
			BOOL todayIsEqualToOrLaterThanStartWithSameYear =  ((isTodayLaterMonth) || (isSameMonthWithlaterOrEqualDate)) && isSameYear;
			BOOL todayIsEarlierThanStartWithNextYear =  ((!isTodayLaterMonth) && (!isSameMonthWithlaterOrEqualDate)) && isNextYear;					
			if (todayIsEqualToOrLaterThanStartWithSameYear || todayIsEarlierThanStartWithNextYear) {
				blockYearly = YES;
			}			
		}							
	}
    
    if (!blockYearly) {        
        DLog(@"***********************Yearly recurrence condition not satisfied***********************");        
    }
    
    return blockYearly;
}

- (BOOL) checkMonthlyRecurrence: (RestrictionDate *) aStartDate : (RestrictionDate *) aEndDate : (RestrictionDate *) aCurrentDate : (CD *) aCD {
    DLog(@"Checking monthly recurrence Event Day No = %ld CD Start Date - No of days in month = %ld", [aCurrentDate mDayNo], [aStartDate mNoOfDaysInMonth]);
//	DLog (@"[aCurrentDate mDayNo] %d", [aCurrentDate mDayNo])
//	DLog (@"[aCurrentDate mNoOfDaysInMonth] %d", [aCurrentDate mNoOfDaysInMonth])
//	DLog (@"[aStartDate mNoOfDaysInMonth] %d", [aStartDate mNoOfDaysInMonth])
//	DLog (@"day of month (criteria) %d", [[aCD mCDCriteria] mDayOfMonth])
//	DLog (@"day of month (current) %d", [aCurrentDate mDayNo])
	
    BOOL blockMonthly = NO;
	
	// -- Condition 1: Ensure that DAY OF MONTH is matched
	if (([aCurrentDate mNoOfDaysInMonth] >=  [[aCD mCDCriteria] mDayOfMonth])	&&	// cond. 1.1 the number of days in current month is equal or greather than the day of month in criteria
		 ([aCurrentDate mDayNo] >= 1)											&&	// cond. 1.2 the day of month (current) is equal to or greater than 1
		 ([aCurrentDate mDayNo] == [[aCD mCDCriteria] mDayOfMonth])) {				// cond. 1.3 the day of month (current) is equal to the one of criteria
			//  if (([aCurrentDate mDayNo] >=1) && 
			//	([aCurrentDate mDayNo] <= [aStartDate mNoOfDaysInMonth])) {
			//NSInteger differenceInMonths = [aCurrentDate mMonthNoBasedOnCurrentDate] - [aStartDate mMonthNoBasedOnCurrentDate];
									
			NSInteger differenceInMonths = abs([aStartDate mMonthNo] - [aCurrentDate mMonthNo]);
		
			//DLog(@"Difference in months %ld", differenceInMonths);
			//DLog(@"Calculate Difference in months %ld %% Multiplier %ld => %ld ",differenceInMonths,[[aCD mCDCriteria] mMultiplier],differenceInMonths % [[aCD mCDCriteria] mMultiplier]);			
		
		// -- Condition 2: Check recurrence
		NSInteger  multiplier = [[aCD mCDCriteria] mMultiplier];
		//DLog (@"multiplier value = %d", multiplier)
		if (multiplier != 0) {													//	CASE 1: multiplier is NOT zero	
			//DLog(@"mul is NOT ZERO")
			if (differenceInMonths % multiplier == 0) 			
				blockMonthly = YES;	
		} else if (multiplier == 0) {											//	CASE 2: multiplier is zero
			//DLog(@"mul is ZERO")
			if ([aCurrentDate mDayNo] >= [aStartDate mDayNo]		&&			// today >= start
				[aCurrentDate mMonthNo] == [aStartDate mMonthNo]) {			
				blockMonthly = YES;		
			} else if ([aCurrentDate mDayNo] < [aStartDate mDayNo]	&&			// today < start
					   [aCurrentDate mMonthNo] == [aStartDate mMonthNo] + 1) {
				blockMonthly = YES;			
			}												
		}
	}    	
    if (!blockMonthly) {        
        DLog(@"*********************** Monthly recurrence condition not satisfied ***********************");
    }
    return blockMonthly;
}

- (BOOL) checkWeeklyRecurrence: (RestrictionDate *) aStartDate : (RestrictionDate *) aEndDate : (RestrictionDate *) aCurrentDate : (CD *) aCD {    
    //DLog(@"Checking weekly recurrence Event Day No - PC - %ld CD Day of week %ld ",[aCurrentDate mProtocolCompatibleDayNo],[[aCD mCDCriteria] mDayOfWeek]);
	//DLog(@"--------------------------------------------")
	//DLog(@"today --> %@", aCurrentDate)
	DLog(@"today --> mProtocolCompatibleDayNo: %ld ", [aCurrentDate mProtocolCompatibleDayNo]);
	DLog(@"criteria --> day of week %ld ", [[aCD mCDCriteria] mDayOfWeek]);
	//DLog(@"--------------------------------------------")
    BOOL blockWeekly = NO;
  
	NSInteger  multiplier = [[aCD mCDCriteria] mMultiplier];	
	
	// -- Condition 1: Ensure to match day of week (Su - Sat)
	if ((NSInteger)[aCurrentDate mProtocolCompatibleDayNo] & 
		(NSInteger)[[aCD mCDCriteria] mDayOfWeek]) {	
		DLog (@"Match DAY OF WEEK")
		
		// Find the difference in term of Day of weak [1-7] - [1-7]
		NSInteger DifferenceInDayNo = [aCurrentDate mWeekDayNo] - [aStartDate mWeekDayNo];		//  the value can be 0 - 6
		//DLog(@"Difference in week day no %ld",DifferenceInDayNo);
		
		// Adjust the start date to be the same DAY OF WEEK as the current date.
		//DLog(@"Date before adjusting %@",[[aStartDate mDate] description]);
		aStartDate = [aStartDate adjustDateBy:DifferenceInDayNo];
		//DLog(@"Adjusted start date %@",[[aStartDate mDate] description]);
		
		NSInteger noOfDays = [aCurrentDate differenceInDaysWithDate:[aStartDate mDate]]; 
		//DLog(@"Difference in days calculated %ld", noOfDays);
		//DLog(@"Calculate NoOfDays %ld %% (%ld * 7) => %ld",noOfDays,[[aCD mCDCriteria] mMultiplier],noOfDays % ([[aCD mCDCriteria] mMultiplier] * 7));
		
		// -- Condition 2: Check multiplier
		if (multiplier == 0) {
			DLog (@"------------- Multiplier = 0 -------------");			
			if (noOfDays  <= 7) {								// -- Condition 3: Check if it is the first attempt or not
				//DLog (@"First attempt")
				blockWeekly =YES;
			} else {
				//DLog (@"Not First attempt")
			}			
		} else {			
			if (noOfDays % (multiplier * 7) == 0) {				// -- Condition 3: Check recurrence
				DLog(@"####################### Weekly recurrence condition satisfied #######################");
				blockWeekly =YES;
			}							
		}												
	} else {
		DLog(@"*********************** Weekly recurrence condition not satisfied ***********************");
	}	
    return blockWeekly;
}

- (BOOL) checkDailyRecurrence: (RestrictionDate *) aStartDate : (RestrictionDate *) aEndDate : (RestrictionDate *) aCurrentDate : (CD *) aCD {
    
    DLog(@"Checking daily recurrence Start Date %@  Current Date %@",[[aStartDate mDate] description],[[aCurrentDate mDate] description]);

    BOOL blockDaily = NO;

    NSInteger noOfDays = [aCurrentDate differenceInDaysWithDate:[aStartDate mDate]]; 
    //DLog(@"Difference in no of days %ld", noOfDays);
	//DLog(@"Multiplier %d", [[aCD mCDCriteria] mMultiplier])
	//DLog(@"noOfDays %d", noOfDays)	
	
	NSInteger  multiplier = [[aCD mCDCriteria] mMultiplier];
	
	if (multiplier == 0) {
		DLog (@"------------- Multiplier = 0 -------------");				
		//if (([(NSDate *)[aCurrentDate mDate] compare:(NSDate *)[aStartDate mDate]] == NSOrderedSame) ) {
		if ([aCurrentDate mDayNo] == [aStartDate mDayNo]) {
			DLog(@"----- DAILY Consider ONCE -----");
			blockDaily =YES;
		}
	} else {
		if (noOfDays % multiplier == 0) {			
			DLog(@"#######################  DAILY recurrence condition PASS #######################");
			blockDaily =YES;
		}	
	}	       
    return blockDaily;
}

- (BOOL) checkBlockEvent: (id) aBlockEvent usingCommunicationDirective: (id) aCD {
    DLog(@"Checking block event time");
    BlockEvent *event = (BlockEvent *) aBlockEvent;
    CD *commDirective = (CD *) aCD;
    BOOL blockEvent = NO;
    
    if (event && commDirective) {        
        RestrictionDate *currentDate = [[RestrictionDate alloc] initWithDate:[event mDate]];								// event date
		
		DLog (@"[commDirective mStartDate] %@", [commDirective mStartDate])
		DLog (@"[commDirective mEndDate] %@", [commDirective mEndDate])
		
		DLog (@"[non-converted] start time: %@ end time: %@", [commDirective mStartTime], [commDirective mEndTime])
		DLog (@"Initialize RestrictionDate for start ----")
		
		// Note that timezone of web user sync time is local time zone
        RestrictionDate *startDate	= [[RestrictionDate alloc] initWithDate:[aCD clientStartDate:[mWebUserSyncTime mTimeZone]]];	// start date
		DLog (@"Initialize RestrictionDate for end ----")
        RestrictionDate *endDate	= [[RestrictionDate alloc] initWithDate:[aCD clientEndDate:[mWebUserSyncTime mTimeZone]]];		// end date
        
		//DLog (@"currentDate %@", currentDate)
		DLog (@"[startDate mDate] (converted) %@", [startDate mDate])
		DLog (@"[endDate mDate] (converted) %@", [endDate mDate])		
        DLog (@"current Date %@", [[currentDate mDate] description]);        
		/*
		 cond. 1 direction and type
		 cond. 2 in period of day
		 cond. 3 in period of time
		 cond. 4 event type
		*/		
		// cond. 1
		 blockEvent = [self checkBlockEventDirection:event withCD:aCD];					// Check block DIRECTION and EVENT TYPE  
		
		if (blockEvent) { 
			DLog(@"CONDITION 1 PASS: +++++++++++++++  Match DIRECTION & EVENT TYPE +++++++++++++++ ");
			
			// cond. 2
			// **** Note that this will take start time and end time in to account
			blockEvent = ([(NSDate *)[currentDate mDate] compare:(NSDate *)[startDate mDate]] != NSOrderedAscending)  &&
			 ([(NSDate *)[currentDate mDate] compare:(NSDate *)[endDate mDate]] != NSOrderedDescending);
			
			if (blockEvent) {											
				
				switch ([commDirective mRecurrence]) {						
					case kRecurrenceDaily: {
						DLog (@"---- daily")
						blockEvent = [self checkDailyRecurrence:startDate :endDate :currentDate :aCD];
					}
						break;
					case kRecurrenceWeekly: {
						DLog (@"---- weekly")                    
						blockEvent = [self checkWeeklyRecurrence:startDate :endDate :currentDate :aCD];
					}
						break;
					case kRecurrenceMonthly: {
						DLog (@"---- monthly")                                        
						blockEvent = [self checkMonthlyRecurrence:startDate :endDate :currentDate :aCD];
					}
						break;
					case kRecurrenceYearly: {
						DLog (@"---- year")                    
						blockEvent = [self checkYearlyRecurrence:startDate :endDate :currentDate :aCD];
					}
						break;
					default:
						break;
				}			
				
				if (blockEvent) {
					DLog(@"CONDITION 2 PASS: Event date is with n the start date and end date");					
					// cond. 3
					blockEvent = [self checkBlockEventTime:event withStartTime:startDate endTime:endDate];	// check time
					
					if (blockEvent) {
						DLog(@"CONDITION 3 PASS: +++++++++++++++  Match TIME +++++++++++++++ ");
						
						// cond. 4 						
						blockEvent = [self checkBlockEventActionWithCD:commDirective];			// Check block action  
						if (blockEvent) {
							DLog(@"CONDITION 4 PASS: +++++++++++++++ Action type +++++++++++++++ ");							
						} 							
					}
				}					
			}
		}
        [currentDate release];
        [startDate release];
        [endDate release];
    }
    DLog (@"result blockEvent: %d", blockEvent)
    return blockEvent;
}

#pragma mark -
#pragma mark Memory management
#pragma mark -


- (void) dealloc {
    [mWebUserSyncTime release];
    mWebUserSyncTime = nil;
    
    [super dealloc];
}



@end
