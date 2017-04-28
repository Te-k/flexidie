//
//  BrowserUploadFilePanelMonitor.m
//  InternetFileTransferManager
//
//  Created by Makara Khloth on 10/20/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "BrowserUploadFilePanelMonitor.h"

#import "UIElementUtilities.h"

@implementation BrowserUploadFilePanelMonitor

@synthesize mDelegate, mSelector;
@synthesize mIsPanelAppear, mDraggedEventMonitor, mPBCountOfRecentChange;
@synthesize mTargetBundleIdentifier;

- (id)initWithTargetBundleIdentifier:(NSString *)aBundleIdentifier {
    self = [super init];
    if (self) {
        self.mTargetBundleIdentifier = aBundleIdentifier;
    }
    
    return self;
}

- (void) startMonitor {
    DLog(@"startMonitor browser upload panel");
    [self stopWorkspaceObserver];
    [self startWorkspaceObserver];
    
    [self stopAXObserver];
    [self startAXObserver];
    
    [self startDraggedEventObserver];
}

- (void) stopMonitor {
    DLog(@"stopMonitor browser upload panel");
    [self stopWorkspaceObserver];
    [self stopAXObserver];
    [self stopDraggedEventObserver];
}

- (void) startWorkspaceObserver {
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(targetDidActive:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
}

- (void) stopWorkspaceObserver {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
}

- (void) startAXObserver {
    pid_t pid = -1;
    for (NSRunningApplication *browser in [NSRunningApplication runningApplicationsWithBundleIdentifier:self.mTargetBundleIdentifier]) {
        if (browser.isActive) {
            pid = browser.processIdentifier;
        }
    }
    if (pid == -1) {
        // No browser process instance is active
        NSRunningApplication *browser = [[NSRunningApplication runningApplicationsWithBundleIdentifier:self.mTargetBundleIdentifier] firstObject];
        pid = browser.processIdentifier;
    }
    DLog(@"Target pid = %d", pid);
    
    if (pid != -1 && pid != 0) {
        mBrowserProcess = AXUIElementCreateApplication(pid);
        AXObserverCreate(pid, openPanelAXCallback, &mBrowserObserver);
        AXObserverAddNotification(mBrowserObserver, mBrowserProcess, kAXFocusedWindowChangedNotification, self);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mBrowserObserver), kCFRunLoopDefaultMode);
    }
}

- (void) stopAXObserver {
    if (mBrowserProcess != nil && mBrowserObserver != nil) {
        AXObserverRemoveNotification(mBrowserObserver, mBrowserProcess, kAXFocusedWindowChangedNotification);
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mBrowserObserver), kCFRunLoopDefaultMode);
        
        if (mBrowserObserver) CFRelease(mBrowserObserver);
        if (mBrowserProcess) CFRelease(mBrowserProcess);
        
        mBrowserObserver = nil;
        mBrowserProcess = nil;
    }
}

- (void) targetDidActive:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningApp = [userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString * appBundleIdentifier = runningApp.bundleIdentifier;
    DLog(@"Did active : %@", appBundleIdentifier);
    DLog(@"self.mTargetBundleIdentifier : %@", self.mTargetBundleIdentifier);
    if ([appBundleIdentifier isEqualToString:self.mTargetBundleIdentifier]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // For firefox can launch multiple profiles, we need to observe only the one that active
            [self startMonitor]; // re-register
        });
    }
    
}

- (void) startDraggedEventObserver {
    if (!self.mDraggedEventMonitor) {
        NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
        self.mDraggedEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask
                                                                           handler:^(NSEvent *event) {
                                                                               if (event.clickCount == 0) { // Drag files or select files,text... by dragging will meet this condition
                                                                                   DLog(@"Dragging ended...");
                                                                                   
                                                                                   if (pb.changeCount != self.mPBCountOfRecentChange) {
                                                                                       self.mPBCountOfRecentChange = pb.changeCount;
                                                                                       [self fileDragged];
                                                                                       
                                                                                       NSData* data = [pb dataForType:NSFilenamesPboardType];
                                                                                       if (data) {
                                                                                           NSError* error = nil;
                                                                                           NSArray* filenames = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:&error];
                                                                                           
                                                                                           for (id filename in filenames) {
                                                                                               DLog(@"filename: %@", filename);
                                                                                           }
                                                                                       }
                                                                                   } else {
                                                                                       DLog(@"Pasteboard did not change");
                                                                                   }
                                                                               }
                                                                           }];
        self.mPBCountOfRecentChange = pb.changeCount;
        DLog(@"mDraggdEventMonitor : %@, pb : %@", self.mDraggedEventMonitor, pb);
    }
}

- (void) stopDraggedEventObserver {
    if (self.mDraggedEventMonitor) {
        [NSEvent removeMonitor:self.mDraggedEventMonitor];
        self.mDraggedEventMonitor = nil;
    }
    self.mPBCountOfRecentChange = 0;
}
         
static void openPanelAXCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData) {
    BrowserUploadFilePanelMonitor *myself = (BrowserUploadFilePanelMonitor *)contextData;
    DLog(@"Focused window changed with BundleIdentifier %@", myself.mTargetBundleIdentifier);
    
    NSString *role = [UIElementUtilities roleOfUIElement:element];
    NSString *subrole = [UIElementUtilities subroleOfUIElement:element];
    NSString *title = [UIElementUtilities titleOfUIElement:element];
    NSString *description = [UIElementUtilities descriptionOfUIElement:element];
    
    DLog(@"role %@", role);
    DLog(@"subrole %@",subrole);
    DLog(@"title %@", title);
    DLog(@"description %@", description);
    
    //Separate focused window changed detection logic by browser
    if ([myself.mTargetBundleIdentifier isEqualToString:@"org.mozilla.firefox"]) {//FireFox
        if ([role isEqualToString:(NSString*)kAXWindowRole] &&
            [subrole isEqualToString:(NSString *)kAXDialogSubrole]) {
            if ([title isEqualToString:@"File Upload"]) { // Can fail if localization change to language that is not English
                myself.mIsPanelAppear = YES;
            }
        } else {
            if (myself.mIsPanelAppear) {
                [myself uploadFilePanelLoseFocus];
            }
            myself.mIsPanelAppear = NO;
        }
    }
    else if ([myself.mTargetBundleIdentifier isEqualToString:@"com.google.Chrome"]){//Chrome
        if ([role isEqualToString:(NSString*)kAXSheetRole]) {
            if ([description isEqualToString:@"open"]) { // Can fail if localization change to language that is not English
                myself.mIsPanelAppear = YES;
            }
        } else {
            if (myself.mIsPanelAppear) {
                DLog(@"LOST FOCUS (Chrome)");
                [myself uploadFilePanelLoseFocus];
            }
            myself.mIsPanelAppear = NO;
        }
    }
    else if ([myself.mTargetBundleIdentifier isEqualToString:@"com.apple.Safari"]){//Safari
        if ([role isEqualToString:(NSString*)kAXSheetRole]) {
            if ([description isEqualToString:@"open"]) { // Can fail if localization change to language that is not English
                myself.mIsPanelAppear = YES;
            }
        } else {
            if (myself.mIsPanelAppear) {
                DLog(@"LOST FOCUS (Safari)");
                [myself uploadFilePanelLoseFocus];
            }
            myself.mIsPanelAppear = NO;
        }
    }
}


- (void) uploadFilePanelLoseFocus {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.uploadpanel"), (void *)self, nil, kCFNotificationDeliverImmediately);
}

- (void) fileDragged {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.filedragged"), (void *)self, nil, kCFNotificationDeliverImmediately);
}

- (void) dealloc {
    [self stopMonitor];
    self.mTargetBundleIdentifier = nil;
    [super dealloc];
}

@end
