//
//  TemporalControlTestManager.m
//  TestAppTemporalControl
//
//  Created by Benjawan Tanarattanakorn on 2/27/2558 BE.
//  Copyright (c) 2558 Benjawan Tanarattanakorn. All rights reserved.
//

#import "TemporalControlTestManager.h"

#import "TemporalControlDAO.h"
#import "TemporalControl.h"
#import "TemporalActionParams.h"
#import "TemporalControlCriteria.h"
#import "TemporalControlDatabase.h"
#import "TemporalStore.h"

#import "DayOfWeek.h"
#import "RecurrenceType.h"

#import "DaemonPrivateHome.h"

#import "NSDate+TemporalControl.h"

#import "TemporalControlValidator.h"
#import "TemporalControlManagerImpl.h"

#import "DeliveryResponse.h"
#import "GetTemporalControlResponse.h"

#import "AmbientRecordingManagerImpl.h"

#import "DaemonPrivateHome.h"

#import "TemporalControlManagerImpl.h"


@interface TemporalControlTestManager ()

@property (nonatomic, retain) TemporalControlDatabase *mTempDB;
@property (nonatomic, retain) TemporalControlManagerImpl *mTempContMgr;
@property (nonatomic, retain) AmbientRecordingManagerImpl  *mAmbientRecordManager;
@end


@implementation TemporalControlTestManager


#pragma mark -

- (void) testTemporalControlManagerIncludeTimeInValidation {
    
    NSString* mediaCapturePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/capture/"];
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:mediaCapturePath];
    
    self.mAmbientRecordManager = [[AmbientRecordingManagerImpl alloc] initWithEventDelegate:nil outputPath:mediaCapturePath];
    
    self.mTempContMgr = [[TemporalControlManagerImpl alloc] initWithDDM:nil];
    self.mTempContMgr.mAmbientRecordingManager = self.mAmbientRecordManager;
    
    [self.mTempContMgr startTemporalControl];
    
    DeliveryResponse *response = [[[DeliveryResponse alloc] init] autorelease];
    response.mSuccess = YES;
    response.mEDPType = kEDPTypeGetTemporalControl;
    
    NSMutableArray *tempCtlArray = [[[NSMutableArray alloc] init] autorelease];
    
    TemporalControl *control = [[TemporalControl alloc] init];
    [control setMAction:kTemporalActionControlRecordAudioAmbient];      // 1
    [control setMActionParams:[self defaultTemporalActionParams]];
    [control setMCriteria:[self defaultControlCriteria]];
    
    [control setMStartDate:@"2015-03-10"];    // date
    [control setMEndDate:@"          "];

    [control setMStartTime:@"01:10"];       // start time
    [control setMEndTime:@"01:20"];
    [tempCtlArray addObject:control];
    [control release];
    
    TemporalControl *control1 = [self defaultTemporalControl];
    [control1 setMStartTime:@"04:10"];       // start time
    [control1 setMEndTime:@"04:20"];
    [tempCtlArray addObject:control1];
    
    TemporalControl *control2 = [self defaultTemporalControl];
    [control2 setMStartTime:@"05:10"];       // start time
    [control2 setMEndTime:@"05:20"];
    [tempCtlArray addObject:control2];

    TemporalControl *control3 =  [self defaultTemporalControl];
    [control3 setMStartTime:@"12:10"];       // start time
    [control3 setMEndTime:@"12:20"];
    [tempCtlArray addObject:control3];
    
    TemporalControl * control8 = [self defaultTemporalControl];
    [control8 setMStartTime:@"13:59"];       // start time
    [control8 setMEndTime:@"13:00"];       // start time
    [tempCtlArray addObject:control8];

     TemporalControl *control4 = [self defaultTemporalControl];
    [control4 setMStartTime:@"23:10"];       // start time
    [control4 setMEndTime:@"23:20"];
    [tempCtlArray addObject:control4];
    
    TemporalControl * control5 = [self defaultTemporalControl];
    [control5 setMStartTime:@"24:00"];       // start time
    [control5 setMEndTime:@"24:10"];
    [tempCtlArray addObject:control5];

    TemporalControl * control6 = [self defaultTemporalControl];
    [control6 setMStartTime:@"24:10"];       // start time
    [control6 setMEndTime:@"24:20"];       // start time
    [tempCtlArray addObject:control6];
    
    TemporalControl * control7 = [self defaultTemporalControl];
    [control7 setMStartTime:@"07:59"];       // start time
    [control7 setMEndTime:@"08:00"];       // start time
    [tempCtlArray addObject:control7];
    
    GetTemporalControlResponse *getTempCtlResponse = [[GetTemporalControlResponse alloc] init];
    [getTempCtlResponse setMTemporalControls:tempCtlArray];
    
    [response setMCSMReponse:getTempCtlResponse];
    
    [self.mTempContMgr requestFinished:response];
}

- (void) testLoadUnloadMobileTimer {
    int i = 0;
    while (i < 20) {
        DLog(@".... round %d", i)
        TemporalControlManagerImpl *mgr = [[TemporalControlManagerImpl alloc] initWithDDM:nil];
        [mgr startTemporalControl];
        [mgr stopTemporalControl];
        [mgr release];
        i++;
    }
}

- (void) testTemporalControlManager {
       
    NSString* mediaCapturePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/capture/"];
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:mediaCapturePath];

    self.mAmbientRecordManager = [[AmbientRecordingManagerImpl alloc] initWithEventDelegate:nil outputPath:mediaCapturePath];
    
    self.mTempContMgr = [[TemporalControlManagerImpl alloc] initWithDDM:nil];
    self.mTempContMgr.mAmbientRecordingManager = self.mAmbientRecordManager;
    
    [self.mTempContMgr startTemporalControl];
    
    DeliveryResponse *response = [[[DeliveryResponse alloc] init] autorelease];
    response.mSuccess = YES;
    response.mEDPType = kEDPTypeGetTemporalControl;
    
    NSMutableArray *tempCtlArray = [[[NSMutableArray alloc] init] autorelease];
    
    TemporalControl *control = [[TemporalControl alloc] init];
    [control setMAction:kTemporalActionControlRecordAudioAmbient];      // 1
    [control setMActionParams:[self defaultTemporalActionParams]];
    [control setMCriteria:[self defaultControlCriteria]];
    
    [control setMEndDate:@"2015-03-15"];
    [control setMStartDate:@"2015-03-13"];
    
    [control setMStartTime:@"18:52"];       // time
    [control setMEndTime:@"18:53"];
    
    [tempCtlArray addObject:control];

    [control release];
    
    GetTemporalControlResponse *getTempCtlResponse = [[GetTemporalControlResponse alloc] init];
    [getTempCtlResponse setMTemporalControls:tempCtlArray];
    
    [response setMCSMReponse:getTempCtlResponse];
    
    [self.mTempContMgr requestFinished:response];
}

#pragma mark - Utilities

- (TemporalActionParams *) defaultTemporalActionParams {
    TemporalActionParams *param         = [[TemporalActionParams alloc] init];
    [param setMInterval:10];
    return [param autorelease];
}

- (TemporalControlCriteria *) defaultControlCriteria {
    TemporalControlCriteria *criteria   = [[TemporalControlCriteria alloc] init];
    [criteria setMDayOfMonth:4];
    [criteria setMDayOfWeek:kDayOfWeekTuesday];     // 4
    [criteria setMMonthOfYear:4];
    [criteria setMMultiplier:1];
    [criteria setMRecurrenceType:kRecurrenceTypeDaily];
    return [criteria autorelease];
}

- (TemporalControl *) defaultTemporalControl {
    TemporalControl *control            = [[TemporalControl alloc] init];
    [control setMAction:kTemporalActionControlRecordAudioAmbient];      // 1
    [control setMActionParams:[self defaultTemporalActionParams]];
    [control setMCriteria:[self defaultControlCriteria]];
    
    [control setMEndDate:@"2015-03-30"];    // date
    [control setMStartDate:@"2015-03-10"];
    
    [control setMStartTime:@"11:00"];       // time
    [control setMEndTime:@"11:10"];

    return [control autorelease];
}

- (NSArray *) temporalControlMock {
    TemporalControl *control1    = [self defaultTemporalControl];
    
    TemporalControl *control2    = [self defaultTemporalControl];
    
    [control2 setMEndDate:@"2015-04-10"];    // date
    [control2 setMStartDate:@"2015-04-20"];
    
    [control2 setMStartTime:@"22:00"];       // time
    [control2 setMEndTime:@"22:10"];
    
    TemporalControl *control3    = [self defaultTemporalControl];
    [control3 setMEndDate:@"2015-05-10"];    // date
    [control3 setMStartDate:@"2015-05-20"];
    
    [control3 setMStartTime:@"23:00"];       // time
    [control3 setMEndTime:@"23:10"];

    NSArray *controlMock = [[NSArray alloc] initWithObjects:control1, control2, control3, nil];
    return  [controlMock autorelease];
}

- (void) checkAssertionBetween: (TemporalControl *) aExpected testedControl: (TemporalControl *) aTested {
    
    NSAssert([aTested mAction] == [aExpected mAction],
             @"Wrong Action Control");
    NSAssert([[aTested mActionParams] mInterval] == [[aExpected mActionParams] mInterval],
             @"Wrong Action Param");
    NSAssert([[aTested mCriteria] mRecurrenceType] == [[aExpected mCriteria] mRecurrenceType],
             @"Wrong mRecurrenceType");
    NSAssert([[aTested mCriteria] mMultiplier] == [[aExpected mCriteria] mMultiplier],
             @"Wrong mMultiplier");
    NSAssert([[aTested mCriteria] mDayOfWeek] == [[aExpected mCriteria] mDayOfWeek],
             @"Wrong mDayOfWeek");
    NSAssert([[aTested mCriteria] mDayOfMonth] == [[aExpected mCriteria] mDayOfMonth],
             @"Wrong mDayOfMonth");
    NSAssert([[aTested mCriteria] mMonthOfYear] == [[aExpected mCriteria] mMonthOfYear],
             @"Wrong mMonthOfYear");
    
    NSAssert([[aTested mStartDate] isEqualToString:[aExpected mStartDate]],
             @"Wrong start date");
    NSAssert([[aTested mEndDate] isEqualToString:[aExpected mEndDate]],
             @"Wrong end date");
    
    NSAssert([[aTested mStartTime] isEqualToString:[aExpected mStartTime]],
             @"Wrong start time");
    NSAssert([[aTested mEndTime] isEqualToString:[aExpected mEndTime]],
             @"Wrong end date");
    
}


#pragma mark - Test Temporal Control DAO and TemporalControlDatabase


// Getter
- (TemporalControlDatabase *) mTempDB {
    if (!_mTempDB) {
        
        _mTempDB = [[TemporalControlDatabase alloc] init];
    }
    return _mTempDB;
}

- (void) testCreateDatabase {
    DLog(@"============ Test create database")
    
    _mTempDB = [[TemporalControlDatabase alloc] init];
    
    NSString *path = [NSString stringWithFormat:@"%@tempcl/", [DaemonPrivateHome daemonPrivateHome]];
    DLog(@"path of database %@", path)
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
	path            = [path stringByAppendingFormat:@"tempcontrol.db"];
	NSFileManager* fileManager  = [NSFileManager defaultManager];
	
    
    if (![fileManager fileExistsAtPath:path]) {
        
        NSAssert([fileManager fileExistsAtPath:path],
                 @"database file doesn't exist at the path %@",
                 path);
    }
}

- (void) testInsert {
    DLog(@"============ Test Insert")
    TemporalControl *control    = [self defaultTemporalControl];
    DLog(@"Insert into database %@", control)
    TemporalControlDAO *dao     = [[TemporalControlDAO alloc] initWithDatabase:[self.mTempDB mDatabase]];

    // -- Delete all
    [dao deleteAll];
    
    // -- Insert
    [dao insert:control];
   
    
    // -- Select
    NSArray *selectResults = [dao select];
    DLog(@"select result %@", selectResults)
    TemporalControl *selectedRecord = [selectResults lastObject];

    NSAssert([selectResults count] == 1,
             @"Expect 1 record");
    
    [self checkAssertionBetween:control testedControl:selectedRecord];
    [dao release];
}

- (void) testInsertMultiple {
    
    DLog(@"============ Test Insert Multiple")
    
    TemporalControlDAO *dao     = [[TemporalControlDAO alloc] initWithDatabase:[self.mTempDB mDatabase]];

    // -- Delete all
    [dao deleteAll];
    
    // -- Insert
    NSArray *insertedControl = [self temporalControlMock];
    DLog(@"Insert into database %@", insertedControl)
    [dao insertControls:insertedControl];
    
    // -- Select
    NSArray *selectResults = [dao select];
    
    [dao release];
    
    TemporalControl *selectedRecord1 = [selectResults objectAtIndex:0];
    TemporalControl *selectedRecord2 = [selectResults objectAtIndex:1];
    TemporalControl *selectedRecord3 = [selectResults objectAtIndex:2];
    
    NSAssert([selectResults count] == 3, @"Expect 1 record");
    
    [self checkAssertionBetween:insertedControl[0] testedControl:selectedRecord1];
    [self checkAssertionBetween:insertedControl[1] testedControl:selectedRecord2];
    [self checkAssertionBetween:insertedControl[2] testedControl:selectedRecord3];
    
}

- (void) testSelectSpecific {
    DLog(@"============ Test Select Specific")
    
    TemporalControlDAO *dao     = [[TemporalControlDAO alloc] initWithDatabase:[self.mTempDB mDatabase]];
    // -- Delete all
    [dao deleteAll];
    
    // -- Insert
    NSArray *insertedControl = [self temporalControlMock];
    DLog(@"Insert into database %@", insertedControl)
    
    NSAssert([dao insertControls:insertedControl], @"Select Specific: Insert fail");
    
    TemporalControl* selectedRecord1 = [dao selectWithControlID:1];
    TemporalControl* selectedRecord2 = [dao selectWithControlID:2];
    TemporalControl* selectedRecord3 = [dao selectWithControlID:3];
    
    [self checkAssertionBetween:insertedControl[0] testedControl:selectedRecord1];
    [self checkAssertionBetween:insertedControl[1] testedControl:selectedRecord2];
    [self checkAssertionBetween:insertedControl[2] testedControl:selectedRecord3];
    
    
    [dao release];
}

- (void) testDeleteSpecific {
    DLog(@"============ Test Delete Specific")
    
    TemporalControl *control1    = [self defaultTemporalControl];
    
    TemporalControl *control2    = [self defaultTemporalControl];
    
    [control2 setMEndDate:@"2015-04-10"];    // date
    [control2 setMStartDate:@"2015-04-20"];
    
    [control2 setMStartTime:@"22:00"];       // time
    [control2 setMEndTime:@"22:10"];
    
    TemporalControl *control3    = [self defaultTemporalControl];
    [control3 setMEndDate:@"2015-05-10"];    // date
    [control3 setMStartDate:@"2015-05-20"];
    
    [control3 setMStartTime:@"23:00"];       // time
    [control3 setMEndTime:@"23:10"];
    
    TemporalControlDAO *dao     = [[TemporalControlDAO alloc] initWithDatabase:[self.mTempDB mDatabase]];
    // -- Delete all
    [dao deleteAll];
    
    // -- Insert
    NSArray *insertedControl = [[NSArray alloc] initWithObjects:control1, control2, control3, nil];
    DLog(@"Insert into database %@", insertedControl)
    [dao insertControls:insertedControl];
    [insertedControl release];
    [dao deleteControl:1];
    
    // -- Select
    NSArray *selectResults = [dao select];
    DLog(@"selectResults %@", selectResults)
    
    TemporalControl *selectedRecord1 = selectResults[0];
    TemporalControl *selectedRecord2 = selectResults[1];
    
    [self checkAssertionBetween:control2 testedControl:selectedRecord1];
    [self checkAssertionBetween:control3 testedControl:selectedRecord2];
    
    
    [dao release];
}


#pragma mark - Test Temporal Control


- (void) testTemporalStore {
//    TemporalControlDAO *dao     = [[TemporalControlDAO alloc] initWithDatabase:[self.mTempDB mDatabase]];
//    NSInteger existingRecord    = [dao count];
    
    TemporalStore *store        = [[TemporalStore alloc] init];
    NSArray *storedTemporals    = [self temporalControlMock];
    DLog(@"Stored temporal %@", storedTemporals)
    [store storeTemporals:storedTemporals];
    
    NSDictionary *queriedTemporalControl = [store temporals];
    DLog(@"Queries temporal %@", queriedTemporalControl)
    [store release];
//    NSAssert([storedTemporals count] + existingRecord == [queriedTemporalControl count], @"Unmatched count between the stored temporal and the quried temporal");
    
}

#pragma mark - Test NSDate+TemporalControl Category

// PASS UNIT TEST
- (void) testDateFromString {
    DLog(@">>>>> UNIT TEST test date from string\n\n")
    NSString *dateStr1 = @"2015-03-01";
    NSString *dateStr2 = @"2015-12-02";
    NSString *dateStr3 = @"2016-01-31";
    NSString *dateStr4 = @"2014-01-31";
    
    NSDate *date1 = [NSDate dateFromString:dateStr1];  // yyyy-MM-dd
    NSDate *date2 = [NSDate dateFromString:dateStr2];
    NSDate *date3 = [NSDate dateFromString:dateStr3];
    NSDate *date4 = [NSDate dateFromString:dateStr4];
    
    NSCalendar *gregorianCalendar   = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSCalendarUnit unit = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents *components1    = [gregorianCalendar components:unit fromDate:date1];
    NSDateComponents *components2    = [gregorianCalendar components:unit fromDate:date2];
    NSDateComponents *components3    = [gregorianCalendar components:unit fromDate:date3];
    NSDateComponents *components4    = [gregorianCalendar components:unit fromDate:date4];
    
    DLog(@"date 1 %@ --> %@", dateStr1, date1)
    DLog(@"date 2 %@ --> %@", dateStr2, date2)
    DLog(@"date 3 %@ --> %@",dateStr3,  date3)
    DLog(@"date 4 %@ --> %@",dateStr4,  date4)
    
    // ******************************* ASSERTION *********************************
    // case 1
    NSAssert(components1.year == 2015,  @"case1 wrong year");
    NSAssert(components1.month == 3,    @"case1 wrong month");
    NSAssert(components1.day== 1,       @"case1 wrong day");
    // case 2
    NSAssert(components2.year == 2015,  @"case2 wrong year");
    NSAssert(components2.month == 12,   @"case2 wrong month");
    NSAssert(components2.day== 2,       @"case2 wrong day");
    // case 3
    NSAssert(components3.year == 2016,  @"case3 wrong year");
    NSAssert(components3.month == 1,    @"case3 wrong month");
    NSAssert(components3.day== 31,      @"case3 wrong day");
    // case 4
    NSAssert(components4.year == 2014,  @"case4 wrong year");
    NSAssert(components4.month == 1,    @"case4 wrong month");
    NSAssert(components4.day== 31,      @"case4 wrong day");
}

// PASS UNIT TEST
- (void) testDiffInDays {
    DLog(@">>>>> UNIT TEST test diff in days\n\n")
    NSDate *today = [NSDate date];
    
    NSDateComponents* deltaComps = [[[NSDateComponents alloc] init] autorelease];
    [deltaComps setDay:1];
    
    NSDate *tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps
                                                                     toDate:[NSDate date] options:0];
    [deltaComps setDay:-1];
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps
                                                                     toDate:[NSDate date] options:0];

    DLog(@"tomorrow %@", tomorrow)
    DLog(@"yesterday %@", yesterday)

    // ******************************* ASSERTION *********************************
    NSAssert([today differenceInDaysWithDate:tomorrow] == 1, @"Wrong difference in days");
    NSAssert([tomorrow differenceInDaysWithDate:today] == -1, @"Wrong difference in days");
    NSAssert([today differenceInDaysWithDate:yesterday] == -1, @"Wrong difference in days");
    NSAssert([tomorrow differenceInDaysWithDate:yesterday] == -2, @"Wrong difference in days");
    NSAssert([yesterday differenceInDaysWithDate:tomorrow] == 2, @"Wrong difference in days");
    
    [deltaComps setDay:45];
    NSDate *next45Days = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps toDate:[NSDate date] options:0];
    NSAssert([today differenceInDaysWithDate:next45Days] == 45, @"Wrong difference in days");
    NSAssert([next45Days differenceInDaysWithDate:today] == -45, @"Wrong difference in days");
    
    [deltaComps setDay:-12];
    NSDate *last12days = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps toDate:[NSDate date] options:0];
    NSAssert([today differenceInDaysWithDate:last12days] == -12, @"Wrong difference in days");
    NSAssert([last12days differenceInDaysWithDate:today] == 12, @"Wrong difference in days");
    
    // date 30 month 2 and date 2 month 3

    NSDate *firstDate = [NSDate dateFromString:@"2015-02-27"];
    NSDate *secondDate = [NSDate dateFromString:@"2015-03-01"];
    NSAssert([firstDate differenceInDaysWithDate:secondDate] == 2, @"Wrong difference in days");

    firstDate = [NSDate dateFromString:@"2015-02-28"];
    secondDate = [NSDate dateFromString:@"2015-03-01"];
    NSAssert([firstDate differenceInDaysWithDate:secondDate] == 1, @"Wrong difference in days");
    
    firstDate = [NSDate dateFromString:@"2015-03-28"];
    secondDate = [NSDate dateFromString:@"2015-04-01"];
    NSAssert([firstDate differenceInDaysWithDate:secondDate] == 4, @"Wrong difference in days");
}

- (void) testDiffInMins {
    
    NSInteger diff = [NSDate differenceInMinutesFromStartTime:@"00:01" endTime:@"00:02"];
    //DLog(@"diff 1 --> %ld",  (long)diff)
    NSAssert(diff == 1, @"Wrong difference in min");
    
    diff = [NSDate differenceInMinutesFromStartTime:@"00:01" endTime:@"00:59"];
//    DLog(@"diff %d --> %ld", 59-1 ,(long)diff)
    NSAssert(diff == 58, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"00:00" endTime:@"01:00"];
//    DLog(@"diff %d --> %ld", 60 ,(long)diff)
    NSAssert(diff == 60, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"01:00" endTime:@"01:01"];
//    DLog(@"diff %d --> %ld", 1 ,(long)diff)
    NSAssert(diff == 1, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"20:00" endTime:@"21:01"];
//    DLog(@"diff %d --> %ld", 61 ,(long)diff)
    NSAssert(diff == 61, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"23:58" endTime:@"23:59"];
//    DLog(@"diff %d --> %ld", 1 ,(long)diff)
    NSAssert(diff == 1, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"23:00" endTime:@"23:59"];
//    DLog(@"diff %d --> %ld", 59 ,(long)diff)
    NSAssert(diff == 59, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"23:00" endTime:@"24:00"];
//    DLog(@"diff %d --> %ld", 60 ,(long)diff)
    NSAssert(diff == 60, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"00:00" endTime:@"24:00"];
//    DLog(@"diff %d --> %ld", 1440 ,(long)diff)
    NSAssert(diff == 1440, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"15:01" endTime:@"24:00"];
//    DLog(@"diff %d --> %ld", 539 ,(long)diff)
    NSAssert(diff == 539, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"15:01" endTime:@"23:59"];
//    DLog(@"diff %d --> %ld", 538 ,(long)diff)
    NSAssert(diff == 538, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"15:01" endTime:@"24:01"];
//    DLog(@"diff %d --> %ld", -1 ,(long)diff)
    NSAssert(diff == -1, @"Wrong difference in min");
    diff = [NSDate differenceInMinutesFromStartTime:@"24:00" endTime:@"24:00"];
//    DLog(@"diff %d --> %ld", -1 ,(long)diff)
    NSAssert(diff == -1, @"Wrong difference in min");
}
// PASS UNIT TEST
- (void) testAdjustDateWithNumbersOfDay {
    DLog(@">>>>> UNIT TEST test adjust Date with numbers\n\n")
    
    NSDate *today = [NSDate date];
    
    NSDate *tomorrow    = [today adjustDateWithNumberOfDays:1];
    NSDate *yesterday   = [today adjustDateWithNumberOfDays:-1];
    NSDate *next10Days  = [today adjustDateWithNumberOfDays:10];
    NSDate *last60Days  = [today adjustDateWithNumberOfDays:-60];
    
    NSInteger oneDayTimeInterval      = 60 * 60 * 24;
    
    DLog(@"tomorrow %@", tomorrow)
    DLog(@"yesterday %@", yesterday)
    DLog(@"next10Days %@", next10Days)
    DLog(@"last60Days %@", last60Days)
    
    // ******************************* ASSERTION *********************************
    
    NSAssert([tomorrow isEqualToDate:[today dateByAddingTimeInterval:oneDayTimeInterval]], @"Wrong adjusted date");
    NSAssert([yesterday isEqualToDate:[today dateByAddingTimeInterval:-oneDayTimeInterval]], @"Wrong adjusted date");
    NSAssert([next10Days isEqualToDate:[today dateByAddingTimeInterval: 10 * oneDayTimeInterval]], @"Wrong adjusted date");
    NSAssert([last60Days isEqualToDate:[today dateByAddingTimeInterval:-60 * oneDayTimeInterval]], @"Wrong adjusted date");
}

- (void) testGetComponentFromNSDate {
    DLog(@">>>>> UNIT TEST test get component from NSDate\n\n")
    
    // -- get day of week
    [self subTestDayOfWeek];
    
    // -- get date
    [self subTestDate];
    
    // -- get month
    [self subTestMonth];
    
    // -- get year
    [self subTestYear];
    
    // -- get number of days in month
    [self subTestNumberOfDayInMonth];
}


#pragma mark - Sub Test Get Component From NSDate


- (void) subTestDayOfWeek {
    DLog(@">>>>> SUB UNIT TEST test day of week")
    NSDateFormatter *dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    // Witout this the below code, it results in the wrong date
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *sunday                    = [dateFormatter dateFromString:@"2015-03-01"];
    NSDate *monday                    = [dateFormatter dateFromString:@"2015-03-02"];
    NSDate *tuesday                   = [dateFormatter dateFromString:@"2015-03-03"];
    NSDate *wednesday                 = [dateFormatter dateFromString:@"2015-03-04"];
    NSDate *thursday                  = [dateFormatter dateFromString:@"2015-03-05"];
    NSDate *friday                    = [dateFormatter dateFromString:@"2015-03-06"];
    NSDate *saturday                   = [dateFormatter dateFromString:@"2015-03-07"];
    
    DayOfWeek dayOfWeekForSun           = [sunday getComponentDayOfWeek];
    DayOfWeek dayOfWeekForMon           = [monday getComponentDayOfWeek];
     DayOfWeek dayOfWeekForTue           = [tuesday getComponentDayOfWeek];
     DayOfWeek dayOfWeekForWed           = [wednesday getComponentDayOfWeek];
     DayOfWeek dayOfWeekForThur           = [thursday getComponentDayOfWeek];
     DayOfWeek dayOfWeekForFri           = [friday getComponentDayOfWeek];
     DayOfWeek dayOfWeekForSat           = [saturday getComponentDayOfWeek];
    
    
    DLog(@"sun %d, mon %d, tu %d, wed %d, thur %d, fri %d, sat %d", dayOfWeekForSun, dayOfWeekForMon, dayOfWeekForTue, dayOfWeekForWed, dayOfWeekForWed, dayOfWeekForFri, dayOfWeekForSat);
    
    // ******************************* ASSERTION *********************************
    
//    NSAssert(dayOfWeekForSun & kDayOfWeekSunday, @"wrong day of week s");
//    NSAssert(dayOfWeekForMon & kDayOfWeekMonday, @"wrong day of week m");
//    NSAssert(dayOfWeekForTue & kDayOfWeekTuesday, @"wrong day of week t");
//    NSAssert(dayOfWeekForWed & kDayOfWeekWednesday, @"wrong day of week w");
//    NSAssert(dayOfWeekForThur & kDayOfWeekThursday, @"wrong day of week th");
//    NSAssert(dayOfWeekForFri & kDayOfWeekFriday, @"wrong day of week f");
//    NSAssert(dayOfWeekForSat & kDayOfWeekSaturday, @"wrong day of week sa");
    NSAssert(dayOfWeekForSun == 1, @"wrong day of week s");
    NSAssert(dayOfWeekForMon == 2, @"wrong day of week m");
    NSAssert(dayOfWeekForTue == 3, @"wrong day of week t");
    NSAssert(dayOfWeekForWed == 4, @"wrong day of week w");
    NSAssert(dayOfWeekForThur == 5, @"wrong day of week th");
    NSAssert(dayOfWeekForFri == 6, @"wrong day of week f");
    NSAssert(dayOfWeekForSat == 7, @"wrong day of week sa");
}

- (void) subTestDate {
    DLog(@">>>>> SUB UNIT TEST test date")
    NSDateFormatter *dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    // Witout this the below code, it results in the wrong date
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *sunday                    = [dateFormatter dateFromString:@"2015-03-01"];
    NSDate *monday                    = [dateFormatter dateFromString:@"2015-03-02"];
    NSDate *tuesday                   = [dateFormatter dateFromString:@"2015-03-03"];
    NSDate *wednesday                 = [dateFormatter dateFromString:@"2015-03-04"];
    NSDate *thursday                  = [dateFormatter dateFromString:@"2015-03-05"];
    NSDate *friday                    = [dateFormatter dateFromString:@"2015-03-06"];
    NSDate *saturday                   = [dateFormatter dateFromString:@"2015-03-07"];
    
    NSInteger date1                     = [sunday getComponentDayOfMonth];
    NSInteger date2                 = [monday getComponentDayOfMonth];
     NSInteger date3                 = [tuesday getComponentDayOfMonth];
     NSInteger date4                 = [wednesday getComponentDayOfMonth];
     NSInteger date5                 = [thursday getComponentDayOfMonth];
     NSInteger date6                 = [friday getComponentDayOfMonth];
     NSInteger date7                 = [saturday getComponentDayOfMonth];
    
        // ******************************* ASSERTION *********************************
    NSAssert(date1 == 1, @"wrong day of month 1");
    NSAssert(date2 == 2, @"wrong day of month 2");
    NSAssert(date3 == 3, @"wrong day of month 3");
    NSAssert(date4 == 4, @"wrong day of month 4");
    NSAssert(date5 == 5, @"wrong day of month 5");
    NSAssert(date6 == 6, @"wrong day of month 6");
    NSAssert(date7 == 7, @"wrong day of month 7");
}

- (void) subTestMonth {
    DLog(@">>>>> SUB UNIT TEST test Month")
    NSDateFormatter *dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    // Witout this the below code, it results in the wrong date
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *dateOfMonth1                    = [dateFormatter dateFromString:@"2015-01-01"];
    NSDate *dateOfMonth2                    = [dateFormatter dateFromString:@"2015-02-01"];
    NSDate *dateOfMonth3                    = [dateFormatter dateFromString:@"2015-03-01"];
    NSDate *dateOfMonth4                    = [dateFormatter dateFromString:@"2015-04-01"];
    NSDate *dateOfMonth5                    = [dateFormatter dateFromString:@"2015-05-01"];
    NSDate *dateOfMonth6                    = [dateFormatter dateFromString:@"2015-06-01"];
    NSDate *dateOfMonth7                    = [dateFormatter dateFromString:@"2015-07-01"];
    NSDate *dateOfMonth8                    = [dateFormatter dateFromString:@"2015-08-01"];
    NSDate *dateOfMonth9                    = [dateFormatter dateFromString:@"2015-09-01"];
    NSDate *dateOfMonth10                   = [dateFormatter dateFromString:@"2015-10-01"];
    NSDate *dateOfMonth11                   = [dateFormatter dateFromString:@"2015-11-01"];
    NSDate *dateOfMonth12                   = [dateFormatter dateFromString:@"2015-12-01"];

    NSInteger month1                        = [dateOfMonth1 getComponentMonth];
    NSInteger month2                        = [dateOfMonth2 getComponentMonth];
    NSInteger month3                        = [dateOfMonth3 getComponentMonth];
    NSInteger month4                        = [dateOfMonth4 getComponentMonth];
    NSInteger month5                        = [dateOfMonth5 getComponentMonth];
    NSInteger month6                        = [dateOfMonth6 getComponentMonth];
    NSInteger month7                        = [dateOfMonth7 getComponentMonth];
    NSInteger month8                        = [dateOfMonth8 getComponentMonth];
    NSInteger month9                        = [dateOfMonth9 getComponentMonth];
    NSInteger month10                       = [dateOfMonth10 getComponentMonth];
    NSInteger month11                       = [dateOfMonth11 getComponentMonth];
    NSInteger month12                       = [dateOfMonth12 getComponentMonth];


    // ******************************* ASSERTION *********************************
    NSAssert(month1 == 1, @"wrong month 1");
    NSAssert(month2 == 2, @"wrong month 2");
    NSAssert(month3 == 3, @"wrong month 3");
    NSAssert(month4 == 4, @"wrong month 4");
    NSAssert(month5 == 5, @"wrong month 5");
    NSAssert(month6 == 6, @"wrong month 6");
    NSAssert(month7 == 7, @"wrong month 7");
    NSAssert(month8 == 8, @"wrong month 8");
    NSAssert(month9 == 9, @"wrong month 9");
    NSAssert(month10 == 10, @"wrong month 10");
    NSAssert(month11 == 11, @"wrong month 11");
    NSAssert(month12 == 12, @"wrong month 12");
    
}

- (void) subTestYear {
    DLog(@">>>>> SUB UNIT TEST test Year")
    NSDateFormatter *dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    // Witout this the below code, it results in the wrong date
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *dateOfYear2013                      = [dateFormatter dateFromString:@"2013-01-01"];
    NSDate *dateOfYear2014                      = [dateFormatter dateFromString:@"2014-02-01"];
    NSDate *dateOfYear2015                      = [dateFormatter dateFromString:@"2015-03-01"];
    NSDate *dateOfYear2020                      = [dateFormatter dateFromString:@"2020-04-01"];

    
    NSInteger year2013                          = [dateOfYear2013 getComponentYear];
    NSInteger year2014                          = [dateOfYear2014 getComponentYear];
    NSInteger year2015                          = [dateOfYear2015 getComponentYear];
    NSInteger year2020                          = [dateOfYear2020 getComponentYear];

    
    // ******************************* ASSERTION *********************************
    NSAssert(year2013 == 2013, @"wrong year 2013");
    NSAssert(year2014 == 2014, @"wrong year 2014");
    NSAssert(year2015 == 2015, @"wrong year 2015");
    NSAssert(year2020 == 2020, @"wrong year 2020");
}

- (void) subTestNumberOfDayInMonth {
    DLog(@">>>>> SUB UNIT TEST test number of days in month")
    
    NSDateFormatter *dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    // Witout this the below code, it results in the wrong date
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *dateOfMonth1                    = [dateFormatter dateFromString:@"2015-01-01"];     // Jan 21
    NSDate *dateOfMonth2                    = [dateFormatter dateFromString:@"2015-02-01"];     // Feb 28 (2013)
    NSDate *dateOfMonth3                    = [dateFormatter dateFromString:@"2015-03-01"];     // Mar 31
    NSDate *dateOfMonth4                    = [dateFormatter dateFromString:@"2015-04-01"];     // Apri 30
    NSDate *dateOfMonth5                    = [dateFormatter dateFromString:@"2015-05-01"];     // May  31
    NSDate *dateOfMonth6                    = [dateFormatter dateFromString:@"2015-06-01"];     // Jun  30
    NSDate *dateOfMonth7                    = [dateFormatter dateFromString:@"2015-07-01"];     // July 31
    NSDate *dateOfMonth8                    = [dateFormatter dateFromString:@"2015-08-01"];     // Aug  31
    NSDate *dateOfMonth9                    = [dateFormatter dateFromString:@"2015-09-01"];     // Sep  30
    NSDate *dateOfMonth10                   = [dateFormatter dateFromString:@"2015-10-01"];     // Oct 31
    NSDate *dateOfMonth11                   = [dateFormatter dateFromString:@"2015-11-01"];     // Nov 30
    NSDate *dateOfMonth12                   = [dateFormatter dateFromString:@"2015-12-01"];     // Dec 31
    
    NSInteger numOfDayOfM1                        = [dateOfMonth1 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM2                        = [dateOfMonth2 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM3                        = [dateOfMonth3 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM4                        = [dateOfMonth4 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM5                        = [dateOfMonth5 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM6                        = [dateOfMonth6 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM7                        = [dateOfMonth7 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM8                        = [dateOfMonth8 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM9                        = [dateOfMonth9 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM10                       = [dateOfMonth10 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM11                       = [dateOfMonth11 getNumberOfDaysInMonth];
    NSInteger numOfDayOfM12                       = [dateOfMonth12 getNumberOfDaysInMonth];
    
    // ******************************* ASSERTION *********************************
    NSAssert(numOfDayOfM1 == 31, @"wrong number of year for month 1");
    NSAssert(numOfDayOfM2 == 28, @"wrong number of year for month 2");
    NSAssert(numOfDayOfM3 == 31, @"wrong number of year for month 3");
    NSAssert(numOfDayOfM4 == 30, @"wrong number of year for month 4");
    NSAssert(numOfDayOfM5 == 31, @"wrong number of year for month 5");
    NSAssert(numOfDayOfM6 == 30, @"wrong number of year for month 6");
    NSAssert(numOfDayOfM7 == 31, @"wrong number of year for month 7");
    NSAssert(numOfDayOfM8 == 31, @"wrong number of year for month 8");
    NSAssert(numOfDayOfM9 == 30, @"wrong number of year for month 9");
    NSAssert(numOfDayOfM10 ==31, @"wrong number of year for month 10");
    NSAssert(numOfDayOfM11 == 30, @"wrong number of year for month 11");
    NSAssert(numOfDayOfM12 == 31, @"wrong number of year for month 12");
}

- (TemporalControl *) createTemporalControlRecurrentType: (RecurrenceType) aRecType
                                               startDate: (NSString *) aStartDate       // YYYY-MM-DD
                                                 endDate: (NSString *) aEndDate         // YYYY-MM-DD
                                              multiplier: (NSInteger) aMultiplier
                                                     dow: (DayOfWeek) aDOWeek
                                                     dom: (NSUInteger) aDOMonth
                                                     moy: (NSUInteger) aMOYear {
    // Temporal Param
    TemporalActionParams *param         = [[[TemporalActionParams alloc] init] autorelease];
    [param setMInterval:0];
    
    // Temporal Criteria
    TemporalControlCriteria *criteria   = [[[TemporalControlCriteria alloc] init] autorelease];
    
    [criteria setMDayOfWeek:aDOWeek];
    [criteria setMDayOfMonth:aDOMonth];
    [criteria setMMonthOfYear:aMOYear];
    [criteria setMMultiplier:aMultiplier];                            // m = 1
    [criteria setMRecurrenceType:aRecType];     // Daily
    
    TemporalControl *control            = [[TemporalControl alloc] init];
    [control setMAction:kTemporalActionControlRecordAudioAmbient];      // hardcode action
    [control setMActionParams:param];
    [control setMCriteria:criteria];
     [control setMStartTime:@"11:00"];       // hardcode time
     [control setMEndTime:@"11:30"];         // hardcode time
     
     [control setMStartDate:aStartDate];  // 6 - 11
     [control setMEndDate:aEndDate];
    
    return [control autorelease];
}


#pragma mark - Recurrent


- (void) testDailyRecurrent {
    
    DLog(@">>>>> UNIT TEST Daily Recurrent\n\n")

    TemporalControlValidator *validator = [[TemporalControlValidator alloc] init];
    
    //NSString *todayString       = @"2015-03-06";
    NSString *todayString       = [self todayString];
//    NSString *yesterdayString   = @"2015-03-05";
        NSString *yesterdayString   = [self yesterdayString];
    
//    NSString *tomorrowString    = @"2015-03-07";
    NSString *tomorrowString    = [self tomorrowString];
    
    NSString *endDateString     = @"2015-03-11";
    
    /// !!!: Change variable to the date of today when testing
    NSDate *today = [NSDate dateFromString:todayString];
    //NSDate *tomorrow = [NSDate dateFromString:tomorrowString];
    DLog(@"Today is %@", today)
    
    
#pragma mark Daily [m = 1]
    /*********************************************************************************************
        m = 1
     *********************************************************************************************/
    

    // CASE 1: multiplier = 1
    // 1.1 start date is today (PASS)
    TemporalControl *control1 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:todayString endDate:endDateString multiplier:1 dow:0 dom:0 moy:0];
    
    // 1.2 start date is yesterday (PASS)
    TemporalControl *control2 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:yesterdayString endDate:endDateString multiplier:1 dow:0 dom:0 moy:0];
    
    // 1.3 start date is tomorrow (FAIL)
    TemporalControl *control3 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:tomorrowString endDate:endDateString multiplier:1 dow:0 dom:0 moy:0];
    
    // 1.4 end date has been passed (FAIL)
    TemporalControl *control4 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:@"2015-03-01" endDate:@"2015-03-04" multiplier:1 dow:0 dom:0 moy:0];
    
    // 1.5 start date, end date, and current date are the same day
    TemporalControl *control10 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:todayString endDate:todayString multiplier:1 dow:0 dom:0 moy:0];
    
    NSMutableDictionary *tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control1 forKey:@1];
    [tempControlDict setObject:control2 forKey:@2];
    [tempControlDict setObject:control3 forKey:@3];
    [tempControlDict setObject:control4 forKey:@4];
    [tempControlDict setObject:control10 forKey:@10];
    // This is the testing method
    NSDictionary *resultForComparedWithToday = [validator validTemporalControls:tempControlDict comparedDate:today];    // 2015-03-06

    // Print Result
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    
    // ******************************* ASSERTION *********************************
    NSArray *allKey = [resultForComparedWithToday allKeys];
    NSAssert([allKey containsObject:@1], @"start day is today. Matches!");
    NSAssert([allKey containsObject:@2], @"start day is yesterday. Matches!");
    NSAssert(![allKey containsObject:@3], @"Daily Fail: Not yet arrive start");
    NSAssert(![allKey containsObject:@4], @"Daily Fail: End date has been passed");
    NSAssert([allKey containsObject:@10], @"start, end, current is the same day. Matches!");
    // ******************************* END ASSERTION *********************************
    
    
    
#pragma mark Daily [m = 2]
    
    /*********************************************************************************************
        m = 2
     *********************************************************************************************/
    

    
    // CASE 2: multiplier = 2
    // 1.4 every two days (PASS)
    //  S              E
    //  .  .  .  .  .  .
    //  |     |     |
    //  6     8     10
    
    // If today is 6, it must PASS
    TemporalControl *control5   = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:todayString endDate:@"2015-03-11" multiplier:2 dow:0 dom:0 moy:0];
    tempControlDict             = nil;
    tempControlDict             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control5 forKey:@5];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:today];    // current date is today
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Daily Fail: m = 2 must be satisfied");
    
    // If today is 7, it must FAIL
    TemporalControl *control6   = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:todayString endDate:@"2015-03-11" multiplier:2 dow:0 dom:0 moy:0];
    tempControlDict             = nil;
    tempControlDict             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control6 forKey:@6];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-07"]];    // current date is today
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Daily Fail: m = 2 must not be satisfied");
    
    // If today is 8, it must PASS
    TemporalControl *control7 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:@"2015-03-08" endDate:@"2015-03-11" multiplier:2 dow:0 dom:0 moy:0];
    tempControlDict             = nil;
    tempControlDict             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control7 forKey:@7];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-08"]];    // current date is today
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Daily Fail: m = 2 must be satisfied");
    
    // If today is 10, it must PASS
    TemporalControl *control8 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:@"2015-03-08" endDate:@"2015-03-11" multiplier:2 dow:0 dom:0 moy:0];
    tempControlDict             = nil;
    tempControlDict             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control8 forKey:@8];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-10"]];    // current date is today
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Daily Fail: m = 2 must be satisfied");

    // If today is 12, it must FAIL because it's after end date
    TemporalControl *control9 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:@"2015-03-08" endDate:@"2015-03-11" multiplier:2 dow:0 dom:0 moy:0];
    tempControlDict             = nil;
    tempControlDict             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control9 forKey:@9];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-12"]];    // current date is today
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Daily Fail: m = 2 must be satisfied");
    
    
    
#pragma mark Daily [m = 5]
    
    /*********************************************************************************************
     m = 5
     *********************************************************************************************/
    

    // CASE 1: multiplier = 5
    //     S           E
    //  .  .  .  .  .  .  .
    //  |     |     |     |
    //  6     8     10    12
    //     X  o  o  o  o  X  every 5 days
    DLog(@"\n\nTest Multiplier = 5")
    
    TemporalControl *control11 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:@"2015-03-07" endDate:@"2015-03-11" multiplier:5 dow:0 dom:0 moy:0];
    tempControlDict             = nil;
    tempControlDict             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control11 forKey:@11];
    
    // if today is 6, not arrive the start date yet
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-06"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 5 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Daily Fail: m = 5 must not be satisfied");
    
    // if today is 7, this is the start date, and then match
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-07"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 5 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Daily Fail: m = 5 must be satisfied");
    
    // if today is 8, 9, 10, 11, not match criteria m = 5
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-08"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 5 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Daily Fail: m = 5 must not be satisfied for date 8");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-09"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 5 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Daily Fail: m = 5 must not be satisfied for date 9");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-10"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 5 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Daily Fail: m = 5 must not be satisfied for date 10");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-11"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 5 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Daily Fail: m = 5 must not be satisfied for date 11");
    
    // if today is 12, it's later than end date even it matches the multiplier
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-12"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 5 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Daily Fail: m = 5 must not be satisfied for date 12");

    
#pragma mark Daily [m = 0]
    
    /*********************************************************************************************
     m = 0
     *********************************************************************************************/
    TemporalControl *control12 = [self createTemporalControlRecurrentType:kRecurrenceTypeDaily startDate:todayString endDate:todayString multiplier:0 dow:0 dom:0 moy:0];
    tempControlDict             = nil;
    tempControlDict             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control12 forKey:@12];
    
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:today];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 0 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"multiplier = 0 must be satisfied");
}






- (void) testWeeklyRecurrent {
  DLog(@">>>>> UNIT TEST Weekly Recurrent\n\n")
    
    TemporalControlValidator *validator = [[TemporalControlValidator alloc] init];
    
    NSString *todayString       = [self todayString];       // 2015-03-06  YYYY-MM-dd
    //NSString *yesterdayString   = [self yesterdayString];
    //NSString *tomorrowString    = [self tomorrowString];
    
    NSString *endDateString     = @"2015-04-11";
    
    /// !!!: Change variable to the date of today when testing
    NSDate *today               = [NSDate dateFromString:todayString];
    //NSDate *tomorrow            = [NSDate dateFromString:tomorrowString];
    
    DLog(@"Today is %@", today)
    
 
#pragma mark Weekly [m = 1]
    
    /*********************************************************************************************
     m = 1
     *********************************************************************************************/
    
   
    
    // CASE 1: multiplier = 1
    
    // 1.1 Not send day of week (FAIL)                               2015-03-06 FRI      2015-04-11 SAT
    TemporalControl *control1 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly startDate:todayString endDate:endDateString multiplier:1 dow:0 dom:0 moy:0];
    NSMutableDictionary *tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control1 forKey:@1];
    NSDictionary *resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:todayString]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: not specify day of week");
    
    // 1.2 send day of week as dow of start date (PASS)                            2015-03-06 FRI      2015-04-11 SAT
    TemporalControl *control2 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly startDate:todayString endDate:endDateString multiplier:1 dow:kDayOfWeekFriday dom:0 moy:0];
    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control2 forKey:@2];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:todayString]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: not specify day of week");
    
    // 1.3 day of week belongs to next week (PASS)                           2015-03-06 FRI      2015-04-11 SAT
    TemporalControl *control3 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly startDate:todayString endDate:endDateString multiplier:1 dow:kDayOfWeekFriday dom:0 moy:0];
    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control3 forKey:@3];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-13"]];  // Friday of next week
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: not specify day of week");
    
    // 1.4 day of week unmatch (FAIL)                           2015-03-06 FRI      2015-04-11 SAT                                                 // Friday
    TemporalControl *control4 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly startDate:todayString endDate:endDateString multiplier:1 dow:kDayOfWeekFriday dom:0 moy:0];
    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control4 forKey:@4];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-07"]];  // coming SAT
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-08"]];  // coming SU
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-09"]];  // coming Mon
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-10"]];  // coming Tu
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-11"]];  // coming Wed
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-12"]];  // coming Thu
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    

    // 1.5 day of week MON and TU                           2015-03-06 FRI      2015-04-11 SAT                                                 // Mon and Tue
    TemporalControl *control5 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly startDate:todayString endDate:endDateString multiplier:1 dow:kDayOfWeekMonday | kDayOfWeekTuesday dom:0 moy:0];
    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control5 forKey:@5];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-07"]];  // coming SAT
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-08"]];  // coming SU
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-09"]];  // coming Mon  , Match
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-10"]];  // coming Tu, Match
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-11"]];  // coming Wed
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-12"]];  // coming Thu
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-13"]];  // coming Fri
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    
    // 1.6 before start                           2015-03-06 FRI      2015-04-11 SAT                                                    // Mon and Tue
    TemporalControl *control6 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly startDate:todayString endDate:endDateString multiplier:1
                                                                     dow:(kDayOfWeekMonday | kDayOfWeekTuesday | kDayOfWeekWednesday | kDayOfWeekThursday | kDayOfWeekFriday | kDayOfWeekSaturday | kDayOfWeekSunday)
                                                                     dom:0 moy:0];
    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control6 forKey:@6];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-02-02"]];  // coming SAT
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: before start");

    // 1.7  after end
    TemporalControl *control7 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly startDate:todayString endDate:endDateString multiplier:1
                                                                     dow:(kDayOfWeekMonday | kDayOfWeekTuesday | kDayOfWeekWednesday | kDayOfWeekThursday | kDayOfWeekFriday | kDayOfWeekSaturday | kDayOfWeekSunday)
                                                                     dom:0 moy:0];

    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control7 forKey:@7];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-05-02"]];  // coming SAT
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: after end");

    // 1.8 match all                           2015-03-06 FRI      2015-04-11 SAT                                                 // Mon and Tue
    TemporalControl *control8 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly startDate:todayString endDate:@"2015-03-13" multiplier:1
                                                                     dow:(kDayOfWeekMonday | kDayOfWeekTuesday | kDayOfWeekWednesday | kDayOfWeekThursday | kDayOfWeekFriday | kDayOfWeekSaturday | kDayOfWeekSunday)
                                                                     dom:0 moy:0];
    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control8 forKey:@8];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-07"]];  // coming SAT
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-08"]];  // coming SU
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-09"]];  // coming Mon  , Match
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-10"]];  // coming Tu, Match
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-11"]];  // coming Wed
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-12"]];  // coming Thu
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-13"]];  // coming Fri
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
 
    
#pragma mark Weekly [m = 2]
    
    /*********************************************************************************************
     m = 2
     *********************************************************************************************/
    
    // 1.9 monday and tuesday for every 2 week
    TemporalControl *control9 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly
                                                               startDate:todayString    //  2015-03-06 FRI
                                                                 endDate:endDateString  //  2015-04-11 SAT
                                                              multiplier:2
                                                                     dow:(kDayOfWeekMonday | kDayOfWeekTuesday)  // Mon and Tue
                                                                     dom:0 moy:0];
    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control9 forKey:@9];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-07"]];  // coming SAT
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-08"]];  // coming SU
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-09"]];  // coming Mon  ,   Unmatch
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-10"]];  // coming Tu,      Unmatch
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-11"]];  // coming Wed
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-12"]];  // coming Thu
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-13"]];  // coming Fri
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-14"]];  // coming SAT
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-15"]];  // coming SU
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-16"]];  // coming Mon  ,  Match
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-17"]];  // coming Tu,   Match
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-18"]];  // coming Wed
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-19"]];  // coming Thu
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-23"]];  // coming Mon ,Unmatch
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-24"]];  // coming Tu, Unmatch
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Weekly Fail: unmatch day of week");
   
    // 1.9 monday and tuesday for every 2 week
    TemporalControl *control10 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly
                                                               startDate:todayString    //  2015-03-06 FRI
                                                                 endDate:@"2015-04-30"  //  2015-04-11 SAT
                                                              multiplier:2
                                                                     dow:(kDayOfWeekMonday | kDayOfWeekTuesday)  // Mon and Tue
                                                                     dom:0 moy:0];
    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control10 forKey:@10];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-16"]];  // Mon
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-17"]];  // Tu
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-30"]];  // Mon
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-04-13"]];  // Mon
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-04-14"]];  // Tu
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    
    
#pragma mark Weekly [m = 3]
    
    /*********************************************************************************************
     m = 3
     *********************************************************************************************/

    TemporalControl *control11 = [self createTemporalControlRecurrentType:kRecurrenceTypeWeekly
                                                                startDate:todayString    //  2015-03-06 FRI
                                                                  endDate:@"2015-04-30"  //  2015-04-11 SAT
                                                               multiplier:3
                                                                      dow:(kDayOfWeekFriday)  // Mon and Tue
                                                                      dom:0 moy:0];
    tempControlDict = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control11 forKey:@11];
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-06"]];  // Fri
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 3 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
    
    
    resultForComparedWithToday  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-27"]];  // Fri
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 3 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Weekly Fail: unmatch day of week");
}

- (void) testMonthlyRecurrent {
  DLog(@">>>>> UNIT TEST Monthly Recurrent\n\n")
    
    
    TemporalControlValidator *validator = [[[TemporalControlValidator alloc] init] autorelease];
    
    NSString *todayString               = [self todayString];       // 2015-03-06  YYYY-MM-dd

    //NSString *tomorrowString            = [self tomorrowString];
    
    NSString *endDateString     = @"2015-04-11";
    
    /// !!!: Change variable to the date of today when testing
    NSDate *today               = [NSDate dateFromString:todayString];
    //NSDate *tomorrow            = [NSDate dateFromString:tomorrowString];
    
    DLog(@"Today is %@", today)
    
    
#pragma mark Monthly [m = 1]
    
    /*********************************************************************************************
     m = 1
     *********************************************************************************************/

  
    
    // 1.1 Not send day of month (FAIL)                               2015-03-06 FRI      2015-04-11 SAT
    TemporalControl *control1                   = [self createTemporalControlRecurrentType:kRecurrenceTypeMothly startDate:todayString endDate:endDateString multiplier:1 dow:0 dom:0 moy:0];
    NSMutableDictionary *tempControlDict        = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control1 forKey:@1];
    NSDictionary *resultForComparedWithToday    = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:todayString]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");
    
    TemporalControl *control2                   = [self createTemporalControlRecurrentType:kRecurrenceTypeMothly
                                                                                 startDate:todayString
                                                                                   endDate:endDateString
                                                                                multiplier:1
                                                                                       dow:0
                                                                                       dom:6
                                                                                       moy:0];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control2 forKey:@2];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-06"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Monthly Fail: not specify day of week");
    
    TemporalControl *control3                   = [self createTemporalControlRecurrentType:kRecurrenceTypeMothly
                                                                                 startDate:todayString
                                                                                   endDate:endDateString
                                                                                multiplier:1
                                                                                       dow:0
                                                                                       dom:7
                                                                                       moy:0];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control3 forKey:@3];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-06"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");

    TemporalControl *control7                   = [self createTemporalControlRecurrentType:kRecurrenceTypeMothly
                                                                                 startDate:@"2015-01-01"
                                                                                   endDate:@"2015-12-12"
                                                                                multiplier:1
                                                                                       dow:0
                                                                                       dom:31
                                                                                       moy:0];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control7 forKey:@7];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-02-28"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-31"]]; // Match day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-04-30"]]; // Match day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-04-29"]]; // Unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");

    
#pragma mark Monthly [m = 2]
    
    /*********************************************************************************************
     m = 2
     *********************************************************************************************/
    
    TemporalControl *control4                   = [self createTemporalControlRecurrentType:kRecurrenceTypeMothly
                                                                                 startDate:todayString
                                                                                   endDate:@"2015-12-12"
                                                                                multiplier:2
                                                                                       dow:0
                                                                                       dom:6
                                                                                       moy:0];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control4 forKey:@4];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-06"]]; // Match day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-04-06"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-05-06"]]; // Match day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-06-06"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");
    
    TemporalControl *control6                   = [self createTemporalControlRecurrentType:kRecurrenceTypeMothly
                                                                                 startDate:todayString
                                                                                   endDate:@"2015-12-12"
                                                                                multiplier:2
                                                                                       dow:0
                                                                                       dom:5
                                                                                       moy:0];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control6 forKey:@6];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-05"]]; // Match day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-04-05"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-05-05"]]; // Match day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-06-05"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 2 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");

#pragma mark Monthly [m = 3]
    
    /*********************************************************************************************
     m = 2
     *********************************************************************************************/
    
    TemporalControl *control5                   = [self createTemporalControlRecurrentType:kRecurrenceTypeMothly
                                                                                 startDate:todayString
                                                                                   endDate:@"2015-12-12"
                                                                                multiplier:3
                                                                                       dow:0
                                                                                       dom:2
                                                                                       moy:0];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control5 forKey:@4];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-02"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-04-02"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-05-02"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Monthly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-06-02"]]; // Match day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Monthly Fail: not specify day of week");
}

- (void) testYearlyRecurrent {
  DLog(@">>>>> UNIT TEST yearly Recurrent\n\n")
    
    TemporalControlValidator *validator = [[[TemporalControlValidator alloc] init] autorelease];
    
    NSString *todayString               = [self todayString];       // 2015-03-06  YYYY-MM-dd
    
    NSString *endDateString     = @"2015-04-11";
    
    /// !!!: Change variable to the date of today when testing
    NSDate *today               = [NSDate dateFromString:todayString];
    //NSDate *tomorrow            = [NSDate dateFromString:tomorrowString];
    
    DLog(@"Today is %@", today)
    
    
#pragma mark Monthly [m = 1]
    
    /*********************************************************************************************
     m = 1
     *********************************************************************************************/
    
    
    
    // 1.1 Not send day of month (FAIL)                               2015-03-06 FRI      2015-04-11 SAT
    TemporalControl *control1                   = [self createTemporalControlRecurrentType:kRecurrenceTypeYearly startDate:todayString endDate:endDateString multiplier:1 dow:0 dom:0 moy:0];
    NSMutableDictionary *tempControlDict        = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control1 forKey:@1];
    NSDictionary *resultForComparedWithToday    = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:todayString]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Yearly Fail: not specify day of week");
    
    TemporalControl *control2                   = [self createTemporalControlRecurrentType:kRecurrenceTypeYearly
                                                                                 startDate:todayString
                                                                                   endDate:@"2020-01-01"
                                                                                multiplier:1
                                                                                       dow:0
                                                                                       dom:5
                                                                                       moy:2];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control2 forKey:@2];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-02-05"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2016-02-05"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Yearly Fail: not specify day of week");

    
    TemporalControl *control3                   = [self createTemporalControlRecurrentType:kRecurrenceTypeYearly
                                                                                 startDate:todayString
                                                                                   endDate:@"2020-01-01"
                                                                                multiplier:1
                                                                                       dow:0
                                                                                       dom:6
                                                                                       moy:3];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control3 forKey:@3];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-06"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2016-03-06"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Yearly Fail: not specify day of week");
    
    
#pragma mark Monthly [m = 2]
    
    /*********************************************************************************************
     m = 2
     *********************************************************************************************/
    
    TemporalControl *control4                   = [self createTemporalControlRecurrentType:kRecurrenceTypeYearly
                                                                                 startDate:todayString
                                                                                   endDate:@"2020-01-01"
                                                                                multiplier:2
                                                                                       dow:0
                                                                                       dom:5
                                                                                       moy:2];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control4 forKey:@4];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-02-05"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2016-02-05"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2017-02-05"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2018-02-05"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Yearly Fail: not specify day of week");
    

    TemporalControl *control6                 = [self createTemporalControlRecurrentType:kRecurrenceTypeYearly
                                                                               startDate:todayString
                                                                                 endDate:@"2020-01-01"
                                                                              multiplier:1
                                                                                     dow:0
                                                                                     dom:6
                                                                                     moy:3];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control6 forKey:@6];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-03-06"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2016-03-06"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2017-03-06"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Yearly Fail: not specify day of week");
    
    
#pragma mark Monthly [m = 3]
    
    /*********************************************************************************************
     m = 3
     *********************************************************************************************/
    
    TemporalControl *control5                     = [self createTemporalControlRecurrentType:kRecurrenceTypeYearly
                                                                                   startDate:todayString
                                                                                     endDate:@"2020-01-01"
                                                                                  multiplier:3
                                                                                         dow:0
                                                                                         dom:5
                                                                                         moy:2];
    tempControlDict                             = [[[NSMutableDictionary alloc] init] autorelease];
    [tempControlDict setObject:control5 forKey:@5];
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2015-02-05"]];
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2016-02-05"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2017-02-05"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 0, @"Yearly Fail: not specify day of week");
    resultForComparedWithToday                  = [validator validTemporalControls:tempControlDict comparedDate:[NSDate dateFromString:@"2018-02-05"]]; // unmatch day of month
    DLog(@"\n\n VALID TEMPORAL CONTROL for m = 1 %@", resultForComparedWithToday)
    NSAssert ([resultForComparedWithToday count] == 1, @"Yearly Fail: not specify day of week");
    
}

- (NSString *) todayString {
    NSString *todayString       = @"2015-03-06";
    return todayString;
}

- (NSString *) yesterdayString {
    NSString *todayString = [self todayString];
    NSDate *today = [NSDate dateFromString:todayString];
    NSDate *yesterday = [today adjustDateWithNumberOfDays:-1];
    
    
    NSCalendar *gregorianCalendar   = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSCalendarUnit unit             = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *components    = [gregorianCalendar components:unit fromDate:yesterday];
    NSString *yesterdayString       = [NSString stringWithFormat:@"%d-%02d-%02d", [components year], [components month], [components day]];
    
    return yesterdayString;
}

- (NSString *) tomorrowString {
    NSString *todayString = [self todayString];
    NSDate *today = [NSDate dateFromString:todayString];
    NSDate *tomorrow = [today adjustDateWithNumberOfDays:1];
    
    NSCalendar *gregorianCalendar   = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unit             = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *components    = [gregorianCalendar components:unit fromDate:tomorrow];
    NSString *tomorrowString       = [NSString stringWithFormat:@"%d-%02d-%02d", [components year], [components month], [components day]];
    return tomorrowString;
}

NSString *endDateString     = @"2015-03-11";

#pragma mark - 

- (void)dealloc
{
    self.mTempDB = nil;
    self.mTempContMgr = nil;
    self.mAmbientRecordManager = nil;
    [super dealloc];
}



@end
