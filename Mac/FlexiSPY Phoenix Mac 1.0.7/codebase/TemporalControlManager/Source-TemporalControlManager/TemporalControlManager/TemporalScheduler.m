//
//  TemporalScheduler.m
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/18/2558 BE.
//
//

#import <objc/runtime.h>
#include <dlfcn.h>		// Dynamically loading

#import "DefStd.h"

#import "TemporalScheduler.h"
#import "TemporalControl.h"
#import "Alarm.h"
#import "AlarmManager.h"

#if TARGET_OS_IPHONE
#import "PCPersistentTimer.h"
#import "PCSimpleTimer.h"
#endif

static void *_MobileTimeHandle              = NULL;

@implementation TemporalScheduler

@synthesize mTarget, mSelector;


- (void) startScheduling: (NSDictionary *) aTemporalControls {

    for (NSNumber *controlID in aTemporalControls) {

        TemporalControl *temporalTemporal   = aTemporalControls[controlID];
        NSString *startTime                 = [temporalTemporal mStartTime];
        NSArray *startTimeComponent         = [startTime componentsSeparatedByString:@":"];
        
        NSString *hour                      = startTimeComponent[0];
        NSString *min                       = startTimeComponent[1];
        
        [self scheduleAlarmAtHour:hour minutes:min temporalControlID:controlID];
    }
}

- (void) stopScheduling {
    
}

- (void) loadMobileTimerApplication {
	/**************************************************
	 Dynamically LOAD MobileTimer Application
	 **************************************************/
	if (_MobileTimeHandle == NULL) {
        DLog (@">>>>>>>>>>>>>>>>>>>>> Dynamically Load MobileTimer application >>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        /*
            This path works on iPhone 5
            _MobileTimeHandle = dlopen("/Applications/MobileTimer.app/MobileTimer", RTLD_LAZY);
        */
        
        /*
            This path works on iPhone 5S
         */
        _MobileTimeHandle = dlopen("/System/Library/Assistant/Plugins/MobileTimer.assistantBundle/MobileTimer", RTLD_LAZY);
        
        DLog(@">>>>>>>>>>>>>>>>>>>>> Dynamically Load MobileTimer application error, %s >>>>>>>>>>>>>>>>>>>>>>>>>>>>>", dlerror());
	}
}

- (void) unloadMobileTimerApplication {
 	/**************************************************
	 Dynamically CLOSE MobilePhone Application//
	 **************************************************/
    DLog (@"Dynamically Unload MobileTimer application");
    int error           = 0;
	if (_MobileTimeHandle != NULL) {
        error               = dlclose(_MobileTimeHandle);
        _MobileTimeHandle   = NULL;
        DLog(@">>>>>>>>>>>>>>>>>>>>> Dynamically Unload MobileTimer application last error, %d >>>>>>>>>>>>>>>>>>>>>>>>>>>>>", error);
    }
}

- (void) scheduleAlarmAtHour: (NSString *) aHour minutes: (NSString *) aMin temporalControlID: (NSNumber *) aTemporalControlID {
    
    DLog(@"Schedule for hour %lu min %lu", (long)[aHour integerValue], (long)[aMin integerValue]);

#if TARGET_OS_IPHONE
//    Class $AlarmManager                 = objc_getClass("AlarmManager");
//    Class $Alarm                        = objc_getClass("Alarm");
//    
//    AlarmManager *sharedAlarmManager    = [$AlarmManager sharedManager];
//    DLog(@"sharedAlarmManager %@", sharedAlarmManager)
//    
//    Alarm * alarm                       = [[$Alarm alloc] initWithDefaultValues];
//    DLog(@"default alarm %@", alarm)
//    
//    // <*#FSCOMMAND>,%@,%@:%@ -->  <*#FSCOMMAND>,2,03:59
//    NSString *command                   = [NSString stringWithFormat:kTemporalControlApplicationCommandFormat, aTemporalControlID, aHour, aMin];
//    DLog(@"Scheduled Command %@", command)
//    [alarm setTitle:command];
//    [alarm setSound:nil ofType:0];
//    alarm.hour                          = (unsigned int)[aHour integerValue];
//    alarm.minute                        = (unsigned int)[aMin integerValue];
//    
//    [sharedAlarmManager addAlarm:alarm active:YES];
//    DLog(@"Customized alarm after %@", alarm)
//    
//    [alarm release];
//    alarm = nil;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aTemporalControlID forKey:@"temporalControlID"];
    int waitInMin = [self calculaeTimeToScheduleForMac:aHour minutes:aMin];
    
    void *handle = dlopen("/System/Library/PrivateFrameworks/PersistentConnection.framework/PersistentConnection", RTLD_NOW);
    if (handle) {
        Class $PCSimpleTimer = objc_getClass("PCSimpleTimer");
        if ($PCSimpleTimer) {
            DLog(@"#### schedule for %d", waitInMin);
            PCSimpleTimer *loop = [[[$PCSimpleTimer alloc] initWithTimeInterval:( waitInMin * 60 ) serviceIdentifier:@"" target:self.mTarget selector:self.mSelector userInfo:userInfo] autorelease];
            DLog(@"#### timer %@", loop);
            [loop scheduleInRunLoop:[NSRunLoop currentRunLoop]];
            DLog(@"#### scheduleAlarmAtHour");
        }
        dlclose(handle);
    }

#else
    DLog(@"#### Mac Calculate");
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aTemporalControlID forKey:@"temporalControlID"];
    int waitInMin = [self calculaeTimeToScheduleForMac:aHour minutes:aMin];

    NSTimer * loop = [NSTimer scheduledTimerWithTimeInterval:( waitInMin * 60 ) target:self.mTarget selector:self.mSelector userInfo:userInfo repeats:NO];
    [[NSRunLoop currentRunLoop]addTimer:loop forMode:NSRunLoopCommonModes];

    DLog(@"#### scheduleAlarmAtHour");
    
#endif
}

-(int)calculaeTimeToScheduleForMac:(NSString *) aHour minutes: (NSString *) aMin{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond) fromDate:[NSDate date]];
    int nowH  = (int)[components hour];
    int nowM  = (int)[components minute];
    int totalMin = 0;
    if ( nowH <= [aHour intValue] ) {
        int totalhour = [aHour intValue] - nowH;
        for (int i=0; i<totalhour; i++) {
            totalMin += 60;
        }
        if (totalhour == 0 && [aMin intValue] >= nowM ) {
            totalMin = [aMin intValue] - nowM;
        }
        if (totalhour != 0) {
            if ([aMin intValue] > nowM) {
                totalMin = totalMin + ([aMin intValue] - nowM);
            }else{
                totalMin = totalMin - (nowM - [aMin intValue]);
            }
        }
    }
    if (totalMin >= 60) {
        DLog(@"#### N(%d:%d):=>D(%@:%@) Wait For %.0lf hours %.0lf Mins To Execute Schedule",nowH,nowM,aHour,aMin, (float)roundf((totalMin/60)), (float) (totalMin - (roundf((totalMin/60))*60)) );
    }else{
        DLog(@"#### N(%d:%d):=>D(%@:%@) Wait For %d Mins To Execute Schedule",nowH,nowM,aHour,aMin,totalMin);
    }
    return totalMin;
}
@end
