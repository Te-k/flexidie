//
//  blbldUtils.h
//  blbld
//
//  Created by Makara Khloth on 2/18/15.
//
//

#import <Foundation/Foundation.h>

static NSString* const kRunningProcessIDTag     = @"ProcessID";
static NSString* const kRunningProcessNameTag   = @"ProcessName";

@interface blbldUtils : NSObject
+ (NSArray *) getRunnigProcesses;
+ (NSString *) pathOfPID: (int) aPID;
+ (void) reboot;
+ (void) shutdown;
+ (BOOL) isActivityMonitorIsRunning;
+ (void) hideActivityMonitor;
@end
