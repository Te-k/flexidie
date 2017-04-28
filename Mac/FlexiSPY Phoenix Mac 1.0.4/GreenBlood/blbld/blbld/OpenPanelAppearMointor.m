//
//  OpenPanelAppearMointor.m
//  blbld
//
//  Created by Makara Khloth on 10/19/16.
//
//

#import "OpenPanelAppearMointor.h"

#import <ApplicationServices/ApplicationServices.h>

@implementation OpenPanelAppearMointor

@synthesize mPanelDisappearAt, mDraggedEventMonitor, mPBCountOfRecentChange;
@synthesize mDelegate, mSelector;

- (void) startMonitor {
    [self stopAXObserver];
    [self startAXObserver];
    
    [self startCabonHandler];
    
    [self stopDarwinObserver];
    [self startDarwinObserver];
    
    [self startDraggedEventObserver];
}

- (void) stopMonitor {
    [self stopAXObserver];
    [self stopCabonHandler];
    [self stopDarwinObserver];
    [self stopDraggedEventObserver];
}

- (void) startAXObserver {
    // Cannot configure to work in root process
    NSRunningApplication *firefox = [[NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.mozilla.firefox"] firstObject];
    pid_t pid = firefox.processIdentifier;
    DLog(@"Firefox pid = %d", pid);
    if (pid != 0) {
        mFirefoxProcess = AXUIElementCreateApplication(pid);
        AXObserverCreate(pid, openPanelAXCallback, &mFirefoxObserver);
        AXObserverAddNotification(mFirefoxObserver, mFirefoxProcess, kAXFocusedWindowChangedNotification, self);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mFirefoxObserver), kCFRunLoopDefaultMode);
    }
}

-(void) stopAXObserver {
    if (mFirefoxProcess != nil && mFirefoxObserver != nil) {
        AXObserverRemoveNotification(mFirefoxObserver, mFirefoxProcess, kAXFocusedWindowChangedNotification);
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mFirefoxObserver), kCFRunLoopDefaultMode);
        
        if (mFirefoxObserver) CFRelease(mFirefoxObserver);
        if (mFirefoxProcess) CFRelease(mFirefoxProcess);
        
        mFirefoxObserver = nil;
        mFirefoxProcess = nil;
    }
}

- (void) startCabonHandler {
    EventHandlerRef sCarbonEventsRef = mCarbonEventsRef;
    EventTypeSpec kEvents[] = {
        { kEventClassApplication, kEventAppLaunched },
        { kEventClassApplication, kEventAppTerminated },
        { kEventClassApplication, kEventAppQuit },
        { kEventClassApplication, kEventAppHidden },
        { kEventClassApplication, kEventAppShown }
    };
    
    if (sCarbonEventsRef == NULL) {
        (void) InstallEventHandler(
                                   GetApplicationEventTarget(),
                                   (EventHandlerUPP) CarbonEventHandler,
                                   GetEventTypeCount(kEvents),
                                   kEvents,
                                   self,
                                   &sCarbonEventsRef
                                   );
        mCarbonEventsRef = sCarbonEventsRef;
    }
}

- (void) stopCabonHandler {
    if (mCarbonEventsRef) {
        RemoveEventHandler(mCarbonEventsRef);
        mCarbonEventsRef = NULL;
    }
}

- (void) startDarwinObserver {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, openPanelDarwinCallback, CFSTR("com.applle.blblu.uploadpanel"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, fileDragCallback, CFSTR("com.applle.blblu.filedragged"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void) stopDarwinObserver {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.blblu.uploadpanel"), nil);
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.blblu.filedragged"), nil);
}

- (void) startDraggedEventObserver {
    if (!self.mDraggedEventMonitor) {
        __block bool isDragging = false;
        NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
        self.mDraggedEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask
                                                                           handler:^(NSEvent *event) {
                                                                               switch (event.type) {
                                                                                   case NSLeftMouseDragged: {
                                                                                       //DLog(@"Dragging...");
                                                                                       isDragging = true;
                                                                                   }
                                                                                       break;
                                                                                   case NSLeftMouseUp: {
                                                                                       if (isDragging && event.clickCount == 0) {
                                                                                           DLog(@"Dragging ended...(drop)");
                                                                                           
                                                                                           if (pb.changeCount != self.mPBCountOfRecentChange) {
                                                                                               self.mPanelDisappearAt = [[NSDate date] timeIntervalSince1970];
                                                                                               
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
                                                                                       isDragging = false;
                                                                                   }
                                                                                       break;
                                                                                   default:
                                                                                       break;
                                                                               }
                                                                           }];
        self.mPBCountOfRecentChange = pb.changeCount;
        DLog(@"mDraggdEventMonitor : %@, pb : %@", self.mDraggedEventMonitor, pb); // pb nil in root process
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
    DLog(@"Focused window changed");
}

static OSStatus CarbonEventHandler(  EventHandlerCallRef inHandlerCallRef,
                                   EventRef            inEvent,
                                   void *              inUserData ){
    DLog(@"CarbonEventHandler...");
    ProcessSerialNumber psn = {0, 0};
    
    //OpenPanelAppearMointor *myself = (OpenPanelAppearMointor *)inUserData;
    
    (void) GetEventParameter(
                             inEvent,
                             kEventParamProcessID,
                             typeProcessSerialNumber,
                             NULL,
                             sizeof(psn),
                             NULL,
                             &psn
                             );
    
    CFStringRef processName = nil;
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (CopyProcessName(&psn, &processName) == noErr) {
        int event = GetEventKind(inEvent);
        DLog(@"event = %d, processName = %@", event, processName);
        if ([(NSString *)processName isEqualToString:@"firefox"]) {
            pid_t pid = 0;
            GetProcessPID(&psn, &pid);
#pragma GCC diagnostic pop
            
            if (event == kEventAppLaunched) {
                // Firefox relaunch
                //[myself startMonitor];
            }
        }
    } else {
        // macOS 10.11 cannot copy process name in case event is 'kEventAppTerminated'
        int event = GetEventKind(inEvent);
        DLog(@"Cabon event = %d", event);
        
        if (event == kEventAppTerminated) {
            
        }
    }
    
    if (processName) CFRelease(processName);
    
    return noErr;
}

void openPanelDarwinCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"Focused window changed (upload panel loses focus) from Darwin");
    OpenPanelAppearMointor *myself = (OpenPanelAppearMointor *)observer;
    myself.mPanelDisappearAt = [[NSDate date] timeIntervalSince1970];
}

void fileDragCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"File drag from Darwin");
    OpenPanelAppearMointor *myself = (OpenPanelAppearMointor *)observer;
    myself.mPanelDisappearAt = [[NSDate date] timeIntervalSince1970];
}

- (void) dealloc {
    [self stopMonitor];
    [super dealloc];
}

@end
