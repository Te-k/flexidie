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

- (void) start{
    DLog(@"registerNotificationForActivityMonitor");
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(didFinishLaunch:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
}

- (void) stop{
   [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
}

- (void) didFinishLaunch:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    //DLog(@"NSApplicationBundleIdentifier %@",[userInfo objectForKey:@"NSApplicationBundleIdentifier"]);
    if ([[userInfo objectForKey:@"NSApplicationBundleIdentifier"]isEqualToString:kActivityMonitor]) {
        [blbldUtils hideActivityMonitor];
    }
}

-(void) dealloc {
    [super dealloc];
}
@end
