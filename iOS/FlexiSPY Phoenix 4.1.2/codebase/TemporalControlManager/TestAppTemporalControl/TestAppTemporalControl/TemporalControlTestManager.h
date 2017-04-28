//
//  TemporalControlTestManager.h
//  TestAppTemporalControl
//
//  Created by Benjawan Tanarattanakorn on 2/27/2558 BE.
//  Copyright (c) 2558 Benjawan Tanarattanakorn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemporalControlTestManager : NSObject

- (void) testTemporalControlManagerIncludeTimeInValidation;

- (void) testLoadUnloadMobileTimer;

- (void) testTemporalControlManager;

#pragma mark - Test Temporal Control DAO and TemporalControlDatabase

- (void) testCreateDatabase;

- (void) testInsert;

- (void) testInsertMultiple;

- (void) testSelectSpecific;

- (void) testDeleteSpecific;

#pragma mark - Test Temporal Control Store

- (void) testTemporalStore;

#pragma mark - Test NSDate+TemporalControl Category

- (void) testDateFromString;

- (void) testDiffInDays;

- (void) testDiffInMins;

- (void) testAdjustDateWithNumbersOfDay;

- (void) testGetComponentFromNSDate; // day of week, month, year, days in month

#pragma mark - Test Temporal Control Validator

- (void) testDailyRecurrent;

- (void) testWeeklyRecurrent;

- (void) testMonthlyRecurrent;

- (void) testYearlyRecurrent;

#pragma mark - 

- (NSString *) todayString;
- (NSString *) yesterdayString;
- (NSString *) tomorrowString;

@end
