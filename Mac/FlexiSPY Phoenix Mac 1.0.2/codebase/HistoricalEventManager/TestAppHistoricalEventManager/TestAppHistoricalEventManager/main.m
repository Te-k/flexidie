//
//  main.m
//  TestAppHistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/4/2557 BE.
//  Copyright (c) 2557 Benjawan Tanarattanakorn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "HistoricalEventManagerImpl.h"
#import "Tester.h"

#import "EventCenter.h"

int main(int argc, char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
//    NSString *dateString    = @"1983-12-16 03:12:35";
    
//    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
//    NSString *formatString          = @"yyyy-MM-dd HH:mm:ss";
//    [dateFormatter setDateFormat:formatString];
//    NSDate *dateFromString          = [[NSDate alloc] init];
//    dateFromString                  = [dateFormatter dateFromString:dateString];
//    
//    
    
//    DLog(@">>> date from string 1983-12-16 03:12:35 %@", dateFromString);
//    DLog(@">>> date from string 1983-12-16 03:12:35 %f", [dateFromString timeIntervalSinceNow]);
//    DLog(@">>> date from string 1983-12-16 03:12:35 %f", [dateFromString timeIntervalSince1970]);
//    
//    
//    NSDate *newdate = [dateFromString dateByAddingTimeInterval:NSTimeIntervalSince1970];
//    
//    DLog(@"##### date by adding NSTimeIntervalSince1970 %@", newdate)
//    
//    NSString *dateString2           = @"2014-12-16 03:12:35";
//    NSDate *dateFromString2         = [[NSDate alloc] init];
//    dateFromString2                 = [dateFormatter dateFromString:dateString2];
//    
//    
//    DLog(@">>> date from string 2014-12-16 03:12:35 %@", dateFromString2)
//    DLog(@">>> date from string 1983-12-16 03:12:35 %f", [dateFromString2 timeIntervalSinceNow]);
//    DLog(@">>> date from string 1983-12-16 03:12:35 %f", [dateFromString2 timeIntervalSince1970]);
//
//    

    Tester *tester  = [[Tester alloc] init];
   
    [tester startTestingWithEventCount:3 eventLoop:2 eventType:kHistoricalEventTypeCameraImage | kHistoricalEventTypeVideoFile |  kHistoricalEventTypeAudioRecording];
    
    CFRunLoopRun();
    
    [tester release];
	[pool release];
    return 0;

    
}
