//
//  RestrictionMangerUtilsTestAppViewController.m
//  RestrictionMangerUtilsTestApp
//
//  Created by Syam Sasidharan on 6/18/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "RestrictionMangerUtilsTestAppViewController.h"
#import "RestrictionCriteriaChecker.h"
#import "SyncTime.h"
#import "SyncTimeUtils.h"
#import "BlockEvent.h"
#import "CD.h"
#import "CDCriteria.h"

@interface RestrictionMangerUtilsTestAppViewController (private)
- (void) testRestrictionManagerUtils;
- (void) testSyncTime;
- (void) testOthers;
@end


@implementation RestrictionMangerUtilsTestAppViewController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)testRestrictionManagerUtils {
    //CDCriteria
    //Daily => Multiplier
    //Weekly => Multiplier & Days of week
    //Monthly => Nultiplier & Day of month
    //Yearly => Multiplier & Day of month & Month of year
	
	[self testSyncTime];
}



- (void) testSyncTime {
	/*
    SyncTime *syncTime = [[[SyncTime alloc] init] autorelease];
	//2012-06-12 08:16:18 +0000
	[syncTime setMTime:@"2012-06-12 09:49:18"]; // Server time
	//[syncTime setMTimeZone:@"-00:45"];
	//[syncTime setMTimeZone:@"Asia/Bangkok"];
	[syncTime setMTimeZone:@"Asia/Kolkata"];
	[syncTime setMTimeZoneRep:1];
	NSLog (@"New server time after sync = %@", syncTime);
	syncTime = [SyncTimeUtils clientSyncTime:syncTime];
	NSLog (@"New client time after sync = %@", syncTime);
	
	NSLog (@"Sync time now = %@", [SyncTimeUtils now]);
	 */	
	
	SyncTime *syncTime = [[[SyncTime alloc] init] autorelease];
	//2012-06-12 08:16:18 +0000
	[syncTime setMTime:@"2012-06-12 09:49:18"];					// Server time
	[syncTime setMTimeZone:@"Asia/Kolkata"];					// +05:30
	[syncTime setMTimeZoneRep:1];								// 1 --> kRepTimeZoneRegional
	NSLog (@"server time (Asia/Kolkata) = %@", syncTime);
	syncTime = [SyncTimeUtils clientSyncTime:syncTime];
	NSLog (@"client time = %@", syncTime);
	NSLog(@"--------------------------------------------------------------------");
	
	[syncTime setMTime:@"2012-06-12 09:49:18"];			
	[syncTime setMTimeZone:@"Pacific/Auckland"];				// +12
	NSLog (@"server time (Pacific/Auckland) = %@", syncTime);
	syncTime = [SyncTimeUtils clientSyncTime:syncTime];
	NSLog (@"client time = %@", syncTime);						//  2012-06-12 09:49:18
	NSLog(@"--------------------------------------------------------------------");
	
	[syncTime setMTime:@"2012-06-12 01:10:08"];			
	[syncTime setMTimeZone:@"Pacific/Auckland"];				// +12
	NSLog (@"server time (Pacific/Auckland) = %@", syncTime);
	syncTime = [SyncTimeUtils clientSyncTime:syncTime];
	NSLog (@"client time = %@", syncTime);						//  2012-06-11 20:10:08
	NSLog(@"--------------------------------------------------------------------");
	
	[syncTime setMTime:@"2012-06-12 01:10:08"];			
	[syncTime setMTimeZone:@"+12:00"];				// +12
	NSLog (@"server time (Pacific/Auckland) = %@", syncTime);
	[syncTime setMTimeZoneRep:kRepTimeZoneTimeSpan];			// 2 --> kRepTimeZoneTimeSpan
	syncTime = [SyncTimeUtils clientSyncTime:syncTime];
	NSLog (@"client time = %@", syncTime);						//  2012-06-11 20:10:08
	NSLog(@"--------------------------------------------------------------------");
}

- (void) testStartEnd: (BlockEvent *) event 
		 dateFormatter: (NSDateFormatter *) dated 
					cd: (CD *) notInRangeCommunicationDirective 
			   checker: (RestrictionCriteriaChecker *) restrictionChecker{
	// case 1: current is before start 
	[event setMDate:[dated dateFromString:@"2011-06-17 10:00:00"]];		// BEFORE start date		
	[restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];
	
	
	// case 2: current is after end	
	[event setMDate:[dated dateFromString:@"2012-07-21 10:00:00"]];		// AFTER start date		
	[restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	
	// case 3: current is in the range	
	[event setMDate:[dated dateFromString:@"2012-06-18 10:00:00"]];		// AFTER start date		
	[restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
}



- (void) testDirection: (BlockEvent *) event 
		dateFormatter: (NSDateFormatter *) dated 
				   cd: (CD *) notInRangeCommunicationDirective 
			  checker: (RestrictionCriteriaChecker *) restrictionChecker {
	// case 4:  current is in the range + direction match
	[notInRangeCommunicationDirective setMDirection:kCDDirectionALL];
	[notInRangeCommunicationDirective setMEndDate:@"2012-07-20"];
	[notInRangeCommunicationDirective setMRecurrence:kRecurrenceDaily];
	
	[event setMDate:[dated dateFromString:@"2012-06-18 10:00:00"]];
	[event setMDirection:kBlockEventDirectionIn];
	
	BOOL isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!!");
	NSLog(@"------------------------------------------------------------------------------------");
	
	[event setMDirection:kBlockEventDirectionOut];
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!!");
	NSLog(@"------------------------------------------------------------------------------------");
	
    // case 5:  current is in the range + direction does NOT match (IN)
	[notInRangeCommunicationDirective setMDirection:kCDDirectionIN];		// block in only
	[event setMDirection:kBlockEventDirectionOut];
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!!");
	NSLog(@"------------------------------------------------------------------------------------");
	
    // case 6:  current is in the range + direction does NOT match (OUT)
	[notInRangeCommunicationDirective setMDirection:kCDDirectionOUT];		// block out only
	[event setMDirection:kBlockEventDirectionIn];
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!!");
	NSLog(@"------------------------------------------------------------------------------------");
}


- (void) testEventType: (BlockEvent *) event 
		dateFormatter: (NSDateFormatter *) dated 
				   cd: (CD *) notInRangeCommunicationDirective 
			  checker: (RestrictionCriteriaChecker *) restrictionChecker{
	// case 7: event type match 
	[notInRangeCommunicationDirective setMDirection:kCDDirectionALL];		// block all direction
	[event setMDirection:kBlockEventDirectionIn];
	[event setMType:kCallEvent];						
	[notInRangeCommunicationDirective setMBlockEvents:1];	//   block call event only
	BOOL isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!!");
	NSLog(@"------------------------------------------------------------------------------------");
	
	// case 8: event type does NOT match 	
	[notInRangeCommunicationDirective setMDirection:kCDDirectionALL];		// block all direction
	[event setMDirection:kBlockEventDirectionIn];
	[event setMType:kMMSEvent];						
	[notInRangeCommunicationDirective setMBlockEvents:1];	//   block call event only
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!!");
	NSLog(@"------------------------------------------------------------------------------------");
	
}


- (void) testDailyRecurrence: (BlockEvent *) event 
			   dateFormatter: (NSDateFormatter *) dated 
						  cd: (CD *) notInRangeCommunicationDirective 
					 checker: (RestrictionCriteriaChecker *) restrictionChecker
					criteria: (CDCriteria *) criteria {
	[event setMType:kCallEvent];						
	[notInRangeCommunicationDirective setMBlockEvents:31];
	
	NSLog(@"==============	Recurrence Daily TESTING: multipiler ==============");
	
	[notInRangeCommunicationDirective setMEndDate:@"2012-07-20"];	
	
	// case 9:  multiplier is 0, TODAY = START_DATE
	[criteria setMMultiplier:0];
	[notInRangeCommunicationDirective setMStartDate:@"2012-06-18"];
	[event setMDate:[dated dateFromString:@"2012-06-18 10:00:00"]];  	
	[notInRangeCommunicationDirective setMCDCriteria:criteria];
	[notInRangeCommunicationDirective setMDirection:kCDDirectionALL];		// block all direction
	[event setMDirection:kBlockEventDirectionIn];
	BOOL isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! d1");
	NSLog(@"------------------------------------------------------------------------------------");
	
	// case 10:  multiplier is 0, TODAY != START_DATE
	[criteria setMMultiplier:0];
	[notInRangeCommunicationDirective setMStartDate:@"2012-06-18"];
	[event setMDate:[dated dateFromString:@"2012-06-19 10:00:00"]];  	
	[notInRangeCommunicationDirective setMCDCriteria:criteria];
	[notInRangeCommunicationDirective setMDirection:kCDDirectionALL];		// block all direction
	[event setMDirection:kBlockEventDirectionIn];
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! d2");
	NSLog(@"------------------------------------------------------------------------------------");
	
	// case 11:  multiplier is 1	
	[criteria setMMultiplier:1];
	[notInRangeCommunicationDirective setMStartDate:@"2012-06-01"];
	[event setMDate:[dated dateFromString:@"2012-06-02 10:00:00"]];			// one day after start date	
	[notInRangeCommunicationDirective setMCDCriteria:criteria];
	[notInRangeCommunicationDirective setMDirection:kCDDirectionALL];		// block all direction
	[event setMDirection:kBlockEventDirectionIn];
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! d3");
	NSLog(@"------------------------------------------------------------------------------------");
	
	// case 12:  multiplier is 2, UNBLOCK (recurrent: 01, 03, 05, 07, ....) 
	[criteria setMMultiplier:2];
	[notInRangeCommunicationDirective setMStartDate:@"2012-06-01"];
	[event setMDate:[dated dateFromString:@"2012-06-02 10:00:00"]];			// 1 day after start date, so should not block
	[notInRangeCommunicationDirective setMCDCriteria:criteria];
	[notInRangeCommunicationDirective setMDirection:kCDDirectionALL];		// block all direction
	[event setMDirection:kBlockEventDirectionIn];
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! d4");
	
	// case 13:  multiplier is 2, BLOCK (recurrent: 01, 03, 05, 07, ....)
	[criteria setMMultiplier:2];
	[notInRangeCommunicationDirective setMStartDate:@"2012-06-01"];
	[event setMDate:[dated dateFromString:@"2012-06-03 10:00:00"]];			// 2 days after start date, so should not block
	[notInRangeCommunicationDirective setMCDCriteria:criteria];
	[notInRangeCommunicationDirective setMDirection:kCDDirectionALL];		// block all direction
	[event setMDirection:kBlockEventDirectionIn];
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:notInRangeCommunicationDirective];	
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! d5");
	
	
	
	
}


- (void) testWeeklyRecurrence: (BlockEvent *) event 
				dateFormatter: (NSDateFormatter *) dated 
					  checker: (RestrictionCriteriaChecker *) restrictionChecker {
	CD *weeklyCommunicationDirective = [[CD alloc] init];
    [weeklyCommunicationDirective setMAction:kCDActionDisAllow];
    [weeklyCommunicationDirective setMBlockEvents:31];
    
    CDCriteria *weeklyCriteria  = [[CDCriteria alloc] init];
    [weeklyCriteria setMDayOfMonth:18];		// not used for weekly recurrence
    [weeklyCriteria setMDayOfWeek:2];		// MON
    [weeklyCriteria setMMonthOfYear:6];		// not used for weekly recurrence
    [weeklyCriteria setMMultiplier:1];	
    
    [weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMDirection:kCDDirectionALL];
	
    [weeklyCommunicationDirective setMEndDate:@"2013-07-20"];
    [weeklyCommunicationDirective setMEndTime:@"16:00"];
	
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
    [weeklyCommunicationDirective setMStartTime:@"10:00"];
	
    [weeklyCommunicationDirective setMRecurrence:kRecurrenceWeekly];
    
    [event setMContacts:[NSArray arrayWithObjects:@"Test",nil]];
    [event setMData:nil];
    [event setMDate:[dated dateFromString:@"2012-07-03 10:00:00"]];		// today: Tuesday
    [event setMDirection:kBlockEventDirectionIn];
    [event setMParticipants:[NSArray arrayWithObjects:@"0826478302",nil]];
    [event setMTelephoneNumber:@"0826478302"];
    [event setMType:kCallEvent];
    
	// case 14: day of week doesn't match
    BOOL isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w1");
	NSLog(@"------------------------------------------------------------------------------------");
	
	// case 15: day of week  match + modular = 1	
	[weeklyCriteria setMDayOfWeek:1];									// SUN		note that day of week is bitwise
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-08 11:30:00"]];		// today: next Sunday
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w2");
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMDayOfWeek:4];									// TUE
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-10 11:30:00"]];		// today: next Tuesday
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w3");
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMDayOfWeek:7];									// Sun, Mon, Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];	
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday  
	[event setMDate:[dated dateFromString:@"2012-07-10 11:30:00"]];		// today: next Tuesday
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w4");
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMDayOfWeek:5];									// Sun, Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-17 11:30:00"]];		// today: next 2 Tuesday
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w5");	
	NSLog(@"------------------------------------------------------------------------------------");
	
	
	// case 16: day of week  match + multiplier = 0
	[weeklyCriteria setMMultiplier:0];
	[weeklyCriteria setMDayOfWeek:1];									// SUN		note that day of week is bitwise
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-08 11:30:00"]];		// today: next Sunday
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w6");
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMDayOfWeek:4];									// TUE
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-03 11:30:00"]];		// today: this Tuesday
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w7");
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMDayOfWeek:4];									// TUE
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-10 11:30:00"]];		// today: next Tuesday
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w8");
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMDayOfWeek:7];									// Sun, Mon, Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];	
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday  
	[event setMDate:[dated dateFromString:@"2012-07-10 11:30:00"]];		// today: next Tuesday
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w9");
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMDayOfWeek:5];									// Sun, Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-17 11:30:00"]];		// today: next 2 Tuesday
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w10");	
	NSLog(@"------------------------------------------------------------------------------------");
	
	
	// case 17: day of week  match + multiplier = 2 (week 1 (03/07), week 3(17/7), week 5(31/7), week 6(7/8), week 7(14/8))
	[weeklyCriteria setMMultiplier:2];
	[weeklyCriteria setMDayOfWeek:4];									// TUE
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-03 11:30:00"]];		// today: week 1
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w11");
	NSLog(@"------------------------------------------------------------------------------------");
	
	
	[weeklyCriteria setMMultiplier:2];
	[weeklyCriteria setMDayOfWeek:4];									// Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];	
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday  
	[event setMDate:[dated dateFromString:@"2012-07-10 11:30:00"]];		// today: week 2
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w12");
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMMultiplier:2];		
	[weeklyCriteria setMDayOfWeek:5];									// Sun, Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-17 11:30:00"]];		// today: week 3
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w13 ");	
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMMultiplier:2];		
	[weeklyCriteria setMDayOfWeek:5];									// Sun, Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-24 11:30:00"]];		// today: next week 4
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w14");	
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMMultiplier:2];		
	[weeklyCriteria setMDayOfWeek:5];									// Sun, Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-07-31 11:30:00"]];		// today: week 5
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w15");	
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMMultiplier:2];		
	[weeklyCriteria setMDayOfWeek:5];									// Sun, Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-08-07 11:30:00"]];		// today: week 6
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w16");	
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCriteria setMMultiplier:2];		
	[weeklyCriteria setMDayOfWeek:5];									// Sun, Tue
	[weeklyCommunicationDirective setMCDCriteria:weeklyCriteria];
    [weeklyCommunicationDirective setMStartDate:@"2012-07-01"];			// start date: Sunday 
	[event setMDate:[dated dateFromString:@"2012-08-14 11:30:00"]];		// today: week 7
	isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:weeklyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! w17");	
	NSLog(@"------------------------------------------------------------------------------------");
	
	[weeklyCommunicationDirective release];
	[weeklyCriteria release];
}
	


- (void) testMonthlyRecurrence: (BlockEvent *) event 
				dateFormatter: (NSDateFormatter *) dated 
					   checker: (RestrictionCriteriaChecker *) restrictionChecker  {
	CD *monthlyCommunicationDirective = [[CD alloc] init];
    [monthlyCommunicationDirective setMAction:kCDActionDisAllow];
    [monthlyCommunicationDirective setMBlockEvents:31];
    
    CDCriteria *monthlyCriteria  = [[CDCriteria alloc] init];
    [monthlyCriteria setMDayOfMonth:20];	
    [monthlyCriteria setMDayOfWeek:0];			// not used for weekly recurrence
    [monthlyCriteria setMMonthOfYear:6];		// not used for weekly recurrence
    [monthlyCriteria setMMultiplier:1];
    
    [monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
    [monthlyCommunicationDirective setMDirection:kCDDirectionALL];
    [monthlyCommunicationDirective setMEndDate:@"2013-06-20"];
    [monthlyCommunicationDirective setMEndTime:@"16:00"];
	
    [monthlyCommunicationDirective setMStartDate:@"2012-05-18"];			// start date: month 5 date 18
    [monthlyCommunicationDirective setMStartTime:@"08:30"];				
    [monthlyCommunicationDirective setMRecurrence:kRecurrenceMonthly];
	
    [event setMContacts:[NSArray arrayWithObjects:@"Test",nil]];
    [event setMData:nil];
    [event setMDate:[dated dateFromString:@"2012-08-20 10:00:00"]];			// today: month 8	date 20
    [event setMDirection:kBlockEventDirectionIn];
    [event setMParticipants:[NSArray arrayWithObjects:@"0826478302",nil]];
    [event setMTelephoneNumber:@"0826478302"];
    [event setMType:kCallEvent];
	
	// case 18: (day of month match) + (multiplier = 1) + (criterial is in this month)
	
	[monthlyCriteria setMMultiplier:1];		
	[monthlyCriteria setMDayOfMonth:20];								
	[monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
	[monthlyCommunicationDirective setMStartDate:@"2012-05-18"];			// start date:	month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-08-20 10:00:00"]];			// today:		month 8	date 20
    BOOL isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:monthlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! debug 6");	
	
	// case 19: (day of month match) + (multiplier = 1) + (criterial is NOT in this month)
	[monthlyCriteria setMMultiplier:1];		
	[monthlyCriteria setMDayOfMonth:31];
	[monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
	[monthlyCommunicationDirective setMStartDate:@"2012-01-18"];			// start date:	month 1 date 18
	[event setMDate:[dated dateFromString:@"2012-02-20 10:00:00"]];			// today:		month 8	date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:monthlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! debug 7");	
	
	// case 20: (day of month match) + (multiplier = 0) + not first recurrence
	[monthlyCriteria setMMultiplier:0];		
	[monthlyCriteria setMDayOfMonth:20];								
	[monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
	[monthlyCommunicationDirective setMStartDate:@"2012-05-18"];			// start date:	month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-08-20 10:00:00"]];			// today:		month 8	date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:monthlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! debug 8");	
	
	// case 21: (day of month match) + (multiplier = 0) + not first recurrence
	[monthlyCriteria setMMultiplier:0];		
	[monthlyCriteria setMDayOfMonth:20];								
	[monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
	[monthlyCommunicationDirective setMStartDate:@"2012-05-18"];			// start date:	month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-07-20 10:00:00"]];			// today:		month 7	date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:monthlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! debug 9");	
	
	
	// case 22: (day of month match) + (multiplier = 0) + (criterial is in this month and not passed) + first recurrence
	[monthlyCriteria setMMultiplier:0];		
	[monthlyCriteria setMDayOfMonth:20];								
	[monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
	[monthlyCommunicationDirective setMStartDate:@"2012-05-18"];			// start date:	month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-05-20 10:00:00"]];			// today:		month 5	date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:monthlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! 1");	
	
	// case 23: (day of month match) + (multiplier = 0) + (criterial is in this month and not passed) +  NOT first recurrence
	[monthlyCriteria setMMultiplier:0];		
	[monthlyCriteria setMDayOfMonth:20];								
	[monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
	[monthlyCommunicationDirective setMStartDate:@"2012-05-18"];			// start date:	month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-06-20 10:00:00"]];			// today:		month 6	date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:monthlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! 2");	
	
	// case 24: (day of month match) + (multiplier = 0) + (criterial is today) +  first recurrence
	[monthlyCriteria setMMultiplier:0];		
	[monthlyCriteria setMDayOfMonth:3];								
	[monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
	[monthlyCommunicationDirective setMStartDate:@"2012-05-18"];			// start date:	month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-06-03 10:00:00"]];			// today:		month 6	date 3
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:monthlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! 3");	
	
	// case 25: (day of month match) + (multiplier = 0) + (criteria is today) + not  first recurrence
	[monthlyCriteria setMMultiplier:0];		
	[monthlyCriteria setMDayOfMonth:3];								
	[monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
	[monthlyCommunicationDirective setMStartDate:@"2012-05-18"];			// start date:	month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-07-03 10:00:00"]];			// today:		month 7	date 3
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:monthlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! 4");	
	
	// case 26: (day of month match) + (multiplier = 0) + (criterial is in this month and passed)
	[monthlyCriteria setMMultiplier:0];		
	[monthlyCriteria setMDayOfMonth:3];								
	[monthlyCommunicationDirective setMCDCriteria:monthlyCriteria];
	[monthlyCommunicationDirective setMStartDate:@"2012-05-18"];			// start date:	month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-05-20 10:00:00"]];			// today:		month 5	date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:monthlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! 5");	
	
	[monthlyCommunicationDirective release];
	[monthlyCriteria release];
}

- (void) testYearlyRecurrence: (BlockEvent *) event 
				dateFormatter: (NSDateFormatter *) dated 
					  checker: (RestrictionCriteriaChecker *) restrictionChecker {
	
    CD *yearlyCommunicationDirective = [[CD alloc] init];
    [yearlyCommunicationDirective setMAction:kCDActionDisAllow];
    [yearlyCommunicationDirective setMBlockEvents:31];
    
    CDCriteria *yearlyCriteria  = [[CDCriteria alloc] init];
    [yearlyCriteria setMDayOfMonth:18];
    [yearlyCriteria setMDayOfWeek:0];
    [yearlyCriteria setMMonthOfYear:6];
    [yearlyCriteria setMMultiplier:1];
	
    [yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
    [yearlyCommunicationDirective setMDirection:kCDDirectionALL];
    [yearlyCommunicationDirective setMEndDate:@"2020-06-20"];
    [yearlyCommunicationDirective setMEndTime:@"20:00"];
	
    [yearlyCommunicationDirective setMStartDate:@"2010-06-12"];
    [yearlyCommunicationDirective setMStartTime:@"01:00"];
    [yearlyCommunicationDirective setMRecurrence:kRecurrenceYearly];
    
    [event setMContacts:[NSArray arrayWithObjects:@"Test",nil]];
    [event setMData:nil];
    [event setMDate:[NSDate date]];
    [event setMDirection:kBlockEventDirectionIn];
    [event setMParticipants:[NSArray arrayWithObjects:@"0826478302",nil]];
    [event setMTelephoneNumber:@"0826478302"];
    [event setMType:kCallEvent];
    
    
	// case 27: (day of month/year match) + (multiplier = 1) + (criterial is in this month)
	[yearlyCriteria setMMultiplier:1];		
	[yearlyCriteria setMDayOfMonth:20];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-05-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-08-20 10:04:00"]];			// today:		2012 month 8	date 20
    BOOL isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y1");	
	
	// case 28: (day of month/year match) + (multiplier = 1) + (criterial is in this month)
	[yearlyCriteria setMMultiplier:1];		
	[yearlyCriteria setMDayOfMonth:20];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-05-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2013-08-20 10:00:00"]];			// today:		2013 month 8	date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y2");	
	
	// case 29: (day of month/year match) + (multiplier = 2) + (criterial is in this month)   (block 2012, 2014, 2016)
	[yearlyCriteria setMMultiplier:2];		
	[yearlyCriteria setMDayOfMonth:20];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-05-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-08-20 10:00:00"]];			// today:		2012 month 8 date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y3");	
	
	[yearlyCriteria setMMultiplier:2];		
	[yearlyCriteria setMDayOfMonth:20];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-05-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2013-08-20 10:00:00"]];			// today:		2013 month 8	date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y4");	
	
	[yearlyCriteria setMMultiplier:2];		
	[yearlyCriteria setMDayOfMonth:20];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-05-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2014-08-20 10:00:00"]];			// today:		2014 month 8 date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y5");	
	
	// case 30: (month of year match) + (day of month NOT match)+ (multiplier = 1) + (criterial is in this month)   (block 2012, 2014, 2016)
	[yearlyCriteria setMMultiplier:1];		
	[yearlyCriteria setMDayOfMonth:20];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-05-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-08-21 10:00:00"]];			// today:		2012 month 8 date 20
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y6");	
	
	// case 31: (month of year match) + (day of month match)+ (multiplier = 0) + (today = start) + first occurence
	[yearlyCriteria setMMultiplier:0];		
	[yearlyCriteria setMDayOfMonth:21];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-08-21"];				// start date:	2012 month 8 date 21
	[event setMDate:[dated dateFromString:@"2012-08-21 10:00:00"]];			// today:		2012 month 8 date 21
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y7");	
	
	// case 32: (month of year match) + (day of month match)+ (multiplier = 0) + (today > start) + first occurence
	[yearlyCriteria setMMultiplier:0];		
	[yearlyCriteria setMDayOfMonth:21];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-05-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-08-21 10:00:00"]];			// today:		2012 month 8 date 21
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y8");	
	
	// case 33: (month of year match) + (day of month match)+ (multiplier = 0) + (today < start) + + first occurence
	[yearlyCriteria setMMultiplier:0];		
	[yearlyCriteria setMDayOfMonth:21];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-09-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2013-08-21 10:00:00"]];			// today:		2013 month 8 date 21
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y9");	
	
	// case 34: (month of year match) + (day of month match)+ (multiplier = 0) + (today = start, diff year) +  NOT first occurence
	[yearlyCriteria setMMultiplier:0];		
	[yearlyCriteria setMDayOfMonth:21];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-08-21"];				// start date:	2012 month 8 date 21
	[event setMDate:[dated dateFromString:@"2013-08-21 10:00:00"]];			// today:		2013 month 8 date 21
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y10");	
	
	// case 35: (month of year match) + (day of month match)+ (multiplier = 0) + (today = start, diff year) +  NOT first occurence
	[yearlyCriteria setMMultiplier:0];		
	[yearlyCriteria setMDayOfMonth:21];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-08-21"];				// start date:	2012 month 8 date 21
	[event setMDate:[dated dateFromString:@"2014-08-21 10:00:00"]];			// today:		2014 month 8 date 21
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y11");	
	
	// case 36: (month of year match) + (day of month match)+ (multiplier = 0) + (today > start, diff year) + NOT first occurence
	[yearlyCriteria setMMultiplier:0];		
	[yearlyCriteria setMDayOfMonth:21];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-05-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2013-08-21 10:00:00"]];			// today:		2013 month 8 date 21
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y12");	
	
	// case 37: (month of year match) + (day of month match)+ (multiplier = 0) + (today > start, diff year) + NOT first occurence	
	[yearlyCriteria setMMultiplier:0];		
	[yearlyCriteria setMDayOfMonth:21];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-05-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2014-08-21 10:00:00"]];			// today:		2014 month 8 date 21
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y13");	
	
	// case 38: (month of year match) + (day of month match)+ (multiplier = 0) + (today < start, this year) + NOT first occurence
	[yearlyCriteria setMMultiplier:0];		
	[yearlyCriteria setMDayOfMonth:21];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-09-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2012-08-21 10:00:00"]];			// today:		2012 month 8 date 21
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y14");	
	
	// case 39: (month of year match) + (day of month match)+ (multiplier = 0) + (today < start, next two year) + NOT first occurence
	[yearlyCriteria setMMultiplier:0];		
	[yearlyCriteria setMDayOfMonth:21];	
	[yearlyCriteria setMMonthOfYear:8];
	[yearlyCommunicationDirective setMCDCriteria:yearlyCriteria];
	[yearlyCommunicationDirective setMStartDate:@"2012-09-18"];				// start date:	2012 month 5 date 18
	[event setMDate:[dated dateFromString:@"2014-08-21 10:00:00"]];			// today:		2014 month 8 date 21
    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:yearlyCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! y15");	
	
	[yearlyCommunicationDirective release];
	[yearlyCriteria release];	
}

// 71 test cases for test "checkBlockEvent:usingCommunicationDirective:" method in RestrictionCriteriaChecker
- (void) testOthers {
	SyncTime *serverSyncTime = [[[SyncTime alloc] init] autorelease];
	//2012-06-12 08:16:18 +0000
	[serverSyncTime setMTime:@"2012-06-12 09:49:18"];	// Server time
	//[serverSyncTime setMTimeZone:@"-00:45"];
	//[serverSyncTime setMTimeZone:@"Asia/Bangkok"];
	[serverSyncTime setMTimeZone:@"Asia/Kolkata"];		// GMT+05:30
	/* 
	 mTimeZoneRep
	 kRepTimeZoneRegional	= 1,
	 kRepTimeZoneTimeSpan	= 2
	 */
	[serverSyncTime setMTimeZoneRep:1];
	NSLog (@"syncTime (Before convert) = %@", serverSyncTime);
	SyncTime *syncTime = [SyncTimeUtils clientSyncTime:serverSyncTime];	
	
	NSLog (@"syncTime (After convert) %@", syncTime);
	RestrictionCriteriaChecker *restrictionChecker = [[RestrictionCriteriaChecker alloc] initWithSyncTime:serverSyncTime];
	
	NSDateFormatter *dated = [[NSDateFormatter alloc] init];
	[dated setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	// -- initialize CD 
	/*
	 kCDBlockCall	= 1,
	 kCDBlockSMS	= kCDBlockCall << 1,
	 kCDBlockMMS	= kCDBlockCall << 2,
	 kCDBlockEmail	= kCDBlockCall << 3,
	 kCDBlockIM		= kCDBlockCall << 4
	 */
	CD *notInRangeCommunicationDirective = [[CD alloc] init];
    [notInRangeCommunicationDirective setMAction:kCDActionDisAllow];
    //[dailyCommunicationDirective setMBlockEvents:65];
    [notInRangeCommunicationDirective setMBlockEvents:31]; //  block all 11111 
	
	// -- initialize CDCriteria 	
	CDCriteria *criteria  = [[CDCriteria alloc] init];
    [criteria setMDayOfMonth:0];		// not used for daily recurrence
    [criteria setMDayOfWeek:0];			// not used for daily recurrence
    [criteria setMMonthOfYear:0];		// not used for daily recurrence
    [criteria setMMultiplier:1];	
	[notInRangeCommunicationDirective setMCDCriteria:criteria];				// Criteria
	[notInRangeCommunicationDirective setMDirection:kCDDirectionALL];		// Direction
	[notInRangeCommunicationDirective setMStartDate:@"2011-06-18"];			// Start
	[notInRangeCommunicationDirective setMStartTime:@"01:00"];	
	[notInRangeCommunicationDirective setMEndDate:@"2012-07-20"];			// End	(yyyy-mm-dd)
	[notInRangeCommunicationDirective setMEndTime:@"16:00"];			
	[notInRangeCommunicationDirective setMRecurrence:kRecurrenceWeekly];	// Recurrent
	
	BlockEvent *event = [[BlockEvent alloc] init];
	[event setMContacts:[NSArray arrayWithObjects:@"Test",nil]];
	[event setMData:nil];
	
	[event setMDirection:kBlockEventDirectionIn];
	[event setMParticipants:[NSArray arrayWithObjects:@"0826478302",nil]];
	[event setMTelephoneNumber:@"0826478302"];
	[event setMType:kCallEvent];
	
	BOOL isBlock;

	
#pragma mark 1) START/END TESTING
	
    
	NSLog(@"************************************************************************************");
   	NSLog(@"*************************	START/END TESTING	************************************");
	NSLog(@"************************************************************************************");
	
//	[self testStartEnd:event
//		 dateFormatter:dated
//					cd:notInRangeCommunicationDirective 
//			   checker:restrictionChecker];
	
#pragma mark 2) DIRECTION TESTING
	
	NSLog(@"************************************************************************************");
	NSLog(@"*************************	DIRECTION TESTING	************************************");
	NSLog(@"************************************************************************************");
//	
//	[self testDirection:event
//		  dateFormatter:dated 
//					 cd:notInRangeCommunicationDirective 
//				checker:restrictionChecker];

#pragma mark 3) EVENT TYPE TESTING
	
	NSLog(@"************************************************************************************");
	NSLog(@"*************************	EVENT TYPE TESTING	************************************");
	NSLog(@"************************************************************************************");
	
//	[self testEventType:event
//		  dateFormatter:dated
//					 cd:notInRangeCommunicationDirective
//				checker:restrictionChecker];
	

#pragma mark 4) Recurrence Daily TESTING

	NSLog(@"************************************************************************************");
	NSLog(@"*************************	Recurrence Daily TESTING	****************************");
    NSLog(@"************************************************************************************");
	
//	[self testDailyRecurrence:event 
//				dateFormatter:dated 
//						   cd:notInRangeCommunicationDirective
//					  checker:restrictionChecker
//					 criteria:criteria];
			
    
#pragma mark 5) Recurrence Weekly TESTING
	
	NSLog(@"************************************************************************************");
	NSLog(@"*************************	Recurrence Weekly TESTING	****************************");
    NSLog(@"************************************************************************************");
	
//	[self testWeeklyRecurrence:event dateFormatter:dated checker:restrictionChecker];
	
	
#pragma mark 6) Recurrence Monthly TESTING
	
	NSLog(@"************************************************************************************");
	NSLog(@"*************************	Recurrence Monthly TESTING	****************************");
    NSLog(@"************************************************************************************");

//	[self testMonthlyRecurrence:event dateFormatter:dated checker:restrictionChecker];
		

#pragma mark 7) Recurrence Yearly TESTING
	
	NSLog(@"************************************************************************************");
	NSLog(@"*************************	Recurrence Yearly TESTING	****************************");
    NSLog(@"************************************************************************************");
//	[self testYearlyRecurrence:event dateFormatter:dated checker:restrictionChecker];
	
	
#pragma mark 8) Time TESTING
	
	NSLog(@"************************************************************************************");
	NSLog(@"*************************	Time TESTING	****************************");
    NSLog(@"************************************************************************************");
	
	
    CD *timeCommunicationDirective = [[CD alloc] init];
    [timeCommunicationDirective setMAction:kCDActionDisAllow];
    [timeCommunicationDirective setMBlockEvents:31];
    
    CDCriteria *timeCriteria  = [[CDCriteria alloc] init];
    [timeCriteria setMDayOfWeek:0];
    [timeCriteria setMMultiplier:1];
	[timeCriteria setMDayOfMonth:20];	
	[timeCriteria setMMonthOfYear:8];
	
    [timeCommunicationDirective setMCDCriteria:timeCriteria];
    [timeCommunicationDirective setMDirection:kCDDirectionALL];
    [timeCommunicationDirective setMEndDate:@"2020-06-20"];
    [timeCommunicationDirective setMEndTime:@"20:00"];	
    [timeCommunicationDirective setMStartDate:@"2010-06-12"];
    [timeCommunicationDirective setMStartTime:@"01:00"];
    [timeCommunicationDirective setMRecurrence:kRecurrenceYearly];
    
    [event setMContacts:[NSArray arrayWithObjects:@"Test",nil]];
    [event setMData:nil];
    [event setMDirection:kBlockEventDirectionIn];
    [event setMParticipants:[NSArray arrayWithObjects:@"0826478302",nil]];
    [event setMTelephoneNumber:@"0826478302"];
    [event setMType:kCallEvent];
        
//	// case 40: (day of month/year match) + (multiplier = 1) + (criterial is in this month) + equal to start time
//	[timeCriteria setMMultiplier:1];	
//	[timeCommunicationDirective setMCDCriteria:timeCriteria];
//	[timeCommunicationDirective setMStartTime:@"01:10"];	// in server timezone --> 2.40 in client time zone
//    [timeCommunicationDirective setMEndTime:@"23:00"];
//	[event setMDate:[dated dateFromString:@"2014-08-20 2:40:00"]];			
//    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:timeCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! t1");	
//	
//	// case 41: (day of month/year match) + (multiplier = 1) + (criterial is in this month) + equal to end time
//	[timeCriteria setMMultiplier:1];		
//	[timeCriteria setMDayOfMonth:20];	
//	[timeCriteria setMMonthOfYear:8];
//	[timeCommunicationDirective setMCDCriteria:timeCriteria];
//	[timeCommunicationDirective setMStartTime:@"01:00"];	// in server timezone --> 2.40 in client time zone
//    [timeCommunicationDirective setMEndTime:@"23:01"];	
//	[event setMDate:[dated dateFromString:@"2014-08-20 23:01:00"]];		
//    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:timeCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! t2");	
//	
//	// case 42: (day of month/year match) + (multiplier = 1) + (criterial is in this month) + before start time
//	[timeCriteria setMMultiplier:1];		
//	[timeCriteria setMDayOfMonth:20];	
//	[timeCriteria setMMonthOfYear:8];
//	[timeCommunicationDirective setMCDCriteria:timeCriteria];	
//	[timeCommunicationDirective setMStartTime:@"02:00"];
//    [timeCommunicationDirective setMEndTime:@"23:01"];	
//	[event setMDate:[dated dateFromString:@"2014-08-20 1:59:00"]];		
//    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:timeCommunicationDirective];
//	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! t3");	
//	
//	// case 43: (day of month/year match) + (multiplier = 1) + (criterial is in this month) + after end time
//	[timeCriteria setMMultiplier:1];		
//	[timeCriteria setMDayOfMonth:20];	
//	[timeCriteria setMMonthOfYear:8];
//	[timeCommunicationDirective setMCDCriteria:timeCriteria];
//	[timeCommunicationDirective setMStartTime:@"01:00"]; // in server timezone --> 2.40 in client time zone
//    [timeCommunicationDirective setMEndTime:@"23:00"];	 // in server timezone --> 0:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 0:31:00"]];		
//    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:timeCommunicationDirective];
//	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! t4");	
//	
//	// case 44: (day of month/year match) + (multiplier = 1) + (criterial is in this month) + within start and end time
//	[timeCriteria setMMultiplier:1];		
//	[timeCriteria setMDayOfMonth:20];	
//	[timeCriteria setMMonthOfYear:8];
//	[timeCommunicationDirective setMCDCriteria:timeCriteria];
//	[timeCommunicationDirective setMStartTime:@"01:00"];	// in server timezone --> 2.40 in client time zone
//    [timeCommunicationDirective setMEndTime:@"23:00"];	
//	[event setMDate:[dated dateFromString:@"2014-08-20 02:41:00"]];		
//    isBlock = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:timeCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! t5");	
//	
//	
//#pragma mark 9) Timezone TESTING
//	NSLog(@"************************************************************************************");
//	NSLog(@"*************************	Timezone TESTING	****************************");
//    NSLog(@"************************************************************************************");
//	
	CD *tzCommunicationDirective = [[CD alloc] init];
    [tzCommunicationDirective setMAction:kCDActionDisAllow];
    [tzCommunicationDirective setMBlockEvents:31];
    
    CDCriteria *tzCriteria  = [[CDCriteria alloc] init];
    [tzCriteria setMDayOfWeek:0];
    [tzCriteria setMMultiplier:1];
	[tzCriteria setMDayOfMonth:20];	
	[tzCriteria setMMonthOfYear:8];
	
    [tzCommunicationDirective setMCDCriteria:tzCriteria];
    [tzCommunicationDirective setMDirection:kCDDirectionALL];
	
	// start
	[tzCommunicationDirective setMStartDate:@"2010-06-12"];
    [tzCommunicationDirective setMStartTime:@"01:00"];
	// end
    [tzCommunicationDirective setMEndDate:@"2020-06-20"];
    [tzCommunicationDirective setMEndTime:@"23:00"];	
		
    [tzCommunicationDirective setMRecurrence:kRecurrenceDaily];
    
    [event setMContacts:[NSArray arrayWithObjects:@"Test",nil]];
    [event setMData:nil];
    [event setMDirection:kBlockEventDirectionIn];
    [event setMParticipants:[NSArray arrayWithObjects:@"0826478302",nil]];
    [event setMTelephoneNumber:@"0826478302"];
    [event setMType:kCallEvent];
	
	SyncTime *testedSyncTime = [[[SyncTime alloc] init] autorelease];
	//2012-06-12 08:16:18 +0000
	[testedSyncTime setMTime:@"2012-06-12 09:49:18"];					// Server time
	//[testedSyncTime setMTimeZone:@"Asia/Kolkata"];					// +05:30
	[testedSyncTime setMTimeZone:@"+05:30"];						
	[testedSyncTime setMTimeZoneRep:kRepTimeZoneTimeSpan];				// 1 --> kRepTimeZoneRegional, 2 --> kRepTimeZoneTimeSpan
	//NSLog (@"server time (Asia/Kolkata) = %@", testedSyncTime);
	//testedSyncTime = [SyncTimeUtils clientSyncTime:testedSyncTime];
	//NSLog (@"client time = %@", testedSyncTime);
	
	RestrictionCriteriaChecker *restrictionChecker2 = [[RestrictionCriteriaChecker alloc] initWithSyncTime:testedSyncTime];
	
	/*
	  Example case
	 <------->     <----------------------------------------->
	 0.01  0.30    2.40									23.59
	 */
	
	// case 45: (day of month/year match) + (multiplier = 1) + (discontinuous interval) + not match time 
	[tzCriteria setMMultiplier:1];	
	[tzCommunicationDirective setMCDCriteria:tzCriteria];
	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
    [tzCommunicationDirective setMEndTime:@"23:00"];		// in server timezone --> 0:30 in client time zone
	[event setMDate:[dated dateFromString:@"2014-08-20 01:10:00"]];		// 1:10 is NOT in blocked period	
    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz1");	
	
//	// case 46: (day of month/year match) + (multiplier = 1) +  (discontinuous interval) + match end interval
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"23:00"];		// in server timezone --> 0:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 05:10:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz2 match end interval" );	
//	
//	// case 46: (day of month/year match) + (multiplier = 1) +  (discontinuous interval) + match begin interval
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"23:00"];		// in server timezone --> 0:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 00:10:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz3 match begin interval");
//	
//	// case 47: (day of month/year match) + (multiplier = 1) +  (discontinuous interval) + begin interval [0.01]
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"23:00"];		// in server timezone --> 0:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 00:01:00"]];		
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz4 begin interval [0.01]");
//	
//	// case 48: (day of month/year match) + (multiplier = 1) +  (discontinuous interval) + end interval [23.59]
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"23:00"];		// in server timezone --> 0:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 23:59:00"]];		
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz5");	
//	
//	// case 49: (day of month/year match) + (multiplier = 1) +  (discontinuous interval) + begin interval [criteria end]
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"23:00"];		// in server timezone --> 0:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 00:30:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz6");	
//	
//	// case 50: (day of month/year match) + (multiplier = 1) +  (discontinuous interval) + end interval [criteria start]
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"23:00"];		// in server timezone --> 0:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 02:40:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz7");	
//	
//	// case 51: (day of month/year match) + (multiplier = 1) +  (discontinuous interval) + not match
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"23:00"];		// in server timezone --> 0:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 00:31:00"]];		
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz8");	
//	
//	// case 52: (day of month/year match) + (multiplier = 1) +  (discontinuous interval) + not match
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"23:00"];		// in server timezone --> 0:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 02:39:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz9");	
//	
//	
//	/*
//	 Example case
//	            <----------------------------------------->
//		0.01   2.40										21:30   23.59
//	 */
//	
//	
//	// case 53: (day of month/year match) + (multiplier = 1) +  (continuous interval) + not match
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"20:00"];		// in server timezone --> 21:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 02:39:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz10");	
//	
//	// case 54: (day of month/year match) + (multiplier = 1) +  (continuous interval) + not match
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"20:00"];		// in server timezone --> 21:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 21:31:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz11");	
//	
//	// case 55: (day of month/year match) + (multiplier = 1) +  (continuous interval) + match (match start)
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"20:00"];		// in server timezone --> 21:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 2:40:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz12");
//	
//	// case 56: (day of month/year match) + (multiplier = 1) +  (continuous interval) + match (match end)
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"20:00"];		// in server timezone --> 21:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 21:30:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz13");
//	
//	// case 57: (day of month/year match) + (multiplier = 1) +  (continuous interval) + match (match end)
//	[tzCriteria setMMultiplier:1];	
//	[tzCommunicationDirective setMCDCriteria:tzCriteria];
//	[tzCommunicationDirective setMStartTime:@"01:10"];		// in server timezone --> 2.40 in client time zone
//    [tzCommunicationDirective setMEndTime:@"20:00"];		// in server timezone --> 21:30 in client time zone
//	[event setMDate:[dated dateFromString:@"2014-08-20 2:41:00"]];			
//    isBlock = [restrictionChecker2 checkBlockEvent:event usingCommunicationDirective:tzCommunicationDirective];
//	if (!isBlock) NSLog(@"!!!!!!!!!!!          FAIL			!!!!!!!!!!!! tz14");
	
#pragma mark Release
	
	NSLog(@"Prepare to release...");
	// ------ release variable ---------
	[notInRangeCommunicationDirective release];
	[timeCommunicationDirective release];
//	[tzCommunicationDirective release];
	
	[event release];
	
	[criteria release];
	[timeCriteria release];
//	[tzCriteria release];
	
	[dated release];
	
	[restrictionChecker release];
//	[restrictionChecker2 release];
	NSLog(@"Done Release");
	// ---------------------------------

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TestApp" 
//                                                    message:@"Please turn on the log to see the results Command+Shift+R" 
//                                                   delegate:nil 
//                                          cancelButtonTitle:@"OK" 
//                                          otherButtonTitles:nil];
//    [alert show];
//    [alert release];
    //[self testRestrictionManagerUtils];
	NSLog(@"knownTimeZoneNames %@", [NSTimeZone knownTimeZoneNames]);
	NSLog(@"abbreviationDictionary %@", [NSTimeZone abbreviationDictionary]);
	[self testSyncTime];
	NSLog(@"**************************");
	NSLog(@"**************************");
	NSLog(@"**************************");
	[self testOthers];
	NSString *date = @"2112-08-10 24:00:00 +0000";
	NSString *endOfDay			= @" 24:";
	NSString *adjustedEndOfDay	= @" 00:";
	BOOL isNotFound = NSEqualRanges([date rangeOfString:endOfDay], NSMakeRange(NSNotFound, 0));
	if (!isNotFound) {
		date = [date stringByReplacingOccurrencesOfString:endOfDay 
																	   withString:adjustedEndOfDay
																		  options:0 
																			range:NSMakeRange(10, 4)];
		NSLog (@"Adjust end of day for server date to %@", date);
	}
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Syam's version 
// this code is moved to backup.m


#pragma mark -

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
