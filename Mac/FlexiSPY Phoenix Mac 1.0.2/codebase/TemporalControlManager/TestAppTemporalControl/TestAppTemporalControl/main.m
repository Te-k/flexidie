//
//  main.m
//  TestAppTemporalControl
//
//  Created by Benjawan Tanarattanakorn on 2/26/2558 BE.
//  Copyright (c) 2558 Benjawan Tanarattanakorn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "TemporalControlDAO.h"
#import "TemporalControl.h"
#import "TemporalActionParams.h"
#import "TemporalControlCriteria.h"
#import "TemporalControlDatabase.h"

#import "DayOfWeek.h"
#import "RecurrenceType.h"

#import "TemporalControlTestManager.h"

#import "DaemonPrivateHome.h"


#import "NSDate+TemporalControl.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        //return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
        
//        NSDate *now = [[NSDate alloc] init];
//        
//        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
//        [timeFormat setDateFormat:@"HH:mm"];
//        [timeFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//        
//        NSString *theTime = [timeFormat stringFromDate:now];
//        DLog(@"now time %@", theTime)
//        
//        // (00:00 to 23:59)     the last hour of the day is 23:00-24:00
//        NSDate *d1 = [NSDate dateFromHMString:@"01:00"];
//        DLog(@"now time %@ %@", d1, [timeFormat stringFromDate:d1])
    
        NSString *path = [NSString stringWithFormat:@"%@tempcl/", [DaemonPrivateHome daemonPrivateHome]];
        DLog(@"path of database %@", path)
        [DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
        path            = [path stringByAppendingFormat:@"tempcontrol.db"];
        NSFileManager* fileManager  = [NSFileManager defaultManager];
        
        
        if ([fileManager fileExistsAtPath:path])
            [fileManager removeItemAtPath:path error:NULL];

        TemporalControlTestManager *mgr = [[TemporalControlTestManager alloc] init];
        [mgr testTemporalControlManagerIncludeTimeInValidation];
//        [mgr testLoadUnloadMobileTimer];
        
//        [mgr testTemporalControlManager];
//
//        [mgr testCreateDatabase];
//        [mgr testSelectSpecific];
//        [mgr testInsert];
//        [mgr testInsertMultiple];
//        //[mgr testDeleteSpecific];     // This relates to the order of testing method, so it's commented here
//        [mgr testTemporalStore];
// 
//        
//        // Test NSDate Category
//        [mgr testDateFromString];
//        [mgr testDiffInDays];
//        [mgr testDiffInMins];
//        [mgr testAdjustDateWithNumbersOfDay];
//        [mgr testGetComponentFromNSDate];
//        
//        // Test recurrent
//        [mgr testDailyRecurrent];
//        [mgr testWeeklyRecurrent];
//        [mgr testMonthlyRecurrent];
//        [mgr testYearlyRecurrent];
//        
//        DLog(@"today %@", [mgr todayString])
//        DLog(@"yesterday %@", [mgr yesterdayString])
//        DLog(@"tomorrow %@", [mgr tomorrowString])
        [mgr release];
        
        
    
    
     
        CFRunLoopRun();
        
    }
    
    
    

}
