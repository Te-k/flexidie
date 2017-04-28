//
//  AddressBarValueNotifier.m
//  PageVisitedCaptureManager
//
//  Created by Makara Khloth on 11/22/16.
//
//

#import "AddressBarValueNotifier.h"
#import "PageInfo.h"
#import "PageVisitedDelegate.h"

#import "UIElementUtilities.h"
#import "SystemUtilsImpl.h"

@implementation AddressBarValueNotifier

@synthesize mDelegate;
@synthesize mCurrentPID, mCurrentBundleID;

- (instancetype) initWithDelegate: (id <PageVisitedDelegate>) aDelegate {
    self = [super init];
    if (self) {
        self.mDelegate = aDelegate;
    }
    return self;
}

- (void) startNotify {
    [self stopNotify];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(targetDidActive:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
    
    [self startMonitorFocusedWindow];
    [self startMonitorAddressBar:nil];
}

- (void) stopNotify {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    
    [self stopMonitorAddressBar];
    [self stopMonitorFocusedWindow];
    
    self.mCurrentPID = -1;
    self.mCurrentBundleID = nil;
}

- (void) startMonitorFocusedWindow {
    pid_t pid = -1;
    NSArray *browsers = [NSArray arrayWithObjects:@"com.google.Chrome", @"com.apple.Safari", nil];
    NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    
    if ([browsers containsObject:frontmostApp.bundleIdentifier]) {
        pid = frontmostApp.processIdentifier;
        self.mCurrentBundleID = frontmostApp.bundleIdentifier;
    }
    else {
        for (NSString *bundleID in browsers) {
            for (NSRunningApplication *browserApp in [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleID]) {
                pid = browserApp.processIdentifier;
                self.mCurrentBundleID = browserApp.bundleIdentifier;
                break;
            }
            if (pid != -1) {
                break;
            }
        }
    }
    DLog(@"Target pid = %d", pid);
    
    if (pid != -1 && pid != 0) {
        self.mCurrentPID = pid;
        mBrowserProcess = AXUIElementCreateApplication(pid);
        AXObserverCreate(pid, focusedWindowChanged, &mBrowserObserver);
        AXObserverAddNotification(mBrowserObserver, mBrowserProcess, kAXFocusedWindowChangedNotification, self);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mBrowserObserver), kCFRunLoopDefaultMode);
    }
}

- (void) stopMonitorFocusedWindow {
    if (mBrowserProcess != nil && mBrowserObserver != nil) {
        AXObserverRemoveNotification(mBrowserObserver, mBrowserProcess, kAXFocusedWindowChangedNotification);
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mBrowserObserver), kCFRunLoopDefaultMode);
        
        if (mBrowserObserver) CFRelease(mBrowserObserver);
        if (mBrowserProcess) CFRelease(mBrowserProcess);
        
        mBrowserObserver = nil;
        mBrowserProcess = nil;
    }
}

- (void) startMonitorAddressBar: (AXUIElementRef) aFocusedWindow {
    DLog(@"Start monitor address bar");
    if (mBrowserProcess != nil) {
        mAddressBar = [self copyAddressBar:aFocusedWindow];
        if (mAddressBar != nil) {
            AXObserverCreate(mCurrentPID, addressBarChanged, &mAddressBarObserver);
            AXObserverAddNotification(mAddressBarObserver, mAddressBar, kAXValueChangedNotification, self);
            CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mAddressBarObserver), kCFRunLoopDefaultMode);
        }
    }
}

- (void) stopMonitorAddressBar {
    DLog(@"Stop monitor address bar");
    if (mAddressBarObserver != nil && mAddressBar != nil) {
        AXObserverRemoveNotification(mAddressBarObserver, mAddressBar, kAXValueChangedNotification);
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mAddressBarObserver), kCFRunLoopDefaultMode);
        
        if (mAddressBar) CFRelease(mAddressBar);
        if (mAddressBarObserver) CFRelease(mAddressBarObserver);
        
        mAddressBar = nil;
        mAddressBarObserver = nil;
    }
}

- (void) targetDidActive:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningApp = [userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString * appBundleIdentifier = runningApp.bundleIdentifier;
    if ([appBundleIdentifier isEqualToString:@"com.google.Chrome"] ||
        [appBundleIdentifier isEqualToString:@"com.apple.Safari"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startNotify]; // re-register
        });
    }
    
}

static void focusedWindowChanged(AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData) {
    AddressBarValueNotifier *myself = (AddressBarValueNotifier *)contextData;
    DLog(@"Focused window changed : %@, title : %@", myself.mCurrentBundleID, [UIElementUtilities titleOfUIElement:element]);
    
    [myself stopMonitorAddressBar];
    [myself startMonitorAddressBar:element];
    
    [myself urlSearchBarValueChanged:nil]; // Make call once when focused window change
}

static void addressBarChanged(AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData) {
    AddressBarValueNotifier *myself = (AddressBarValueNotifier *)contextData;
    //DLog(@"Address bar changed : %@", myself.mCurrentBundleID);
    
    [myself urlSearchBarValueChanged:element];
}

- (AXUIElementRef) copyAddressBar: (AXUIElementRef) aFocusedWindow {
    AXUIElementRef addressbar = nil;
    
    //AXUIElementRef focusedWindow = aFocusedWindow;
    AXUIElementRef focusedWindow = nil;
    if (!focusedWindow) {
        AXError err = AXUIElementCopyAttributeValue(mBrowserProcess, kAXFocusedWindowAttribute, (CFTypeRef *)&focusedWindow);
        if (err != kAXErrorSuccess) {
            DLog(@"Cannot copy focused window, err : %d", (int)err);
        }
        
        if (err != kAXErrorSuccess) {
            NSArray *result = nil;
            err = AXUIElementCopyAttributeValues((AXUIElementRef)mBrowserProcess,
                                                 kAXWindowsAttribute,
                                                 0,
                                                 99999,
                                                 (CFArrayRef *) &result);
            if (err != kAXErrorSuccess) {
                DLog(@"Cannot copy windows, err : %d", (int)err);
            } else {
                for (id window in result) {
                    focusedWindow = (AXUIElementRef)[window retain];
                    break;
                }
            }
            [result release];
        }
        
        if (focusedWindow) CFAutorelease(focusedWindow);
    }
    
    if (!focusedWindow) {
        DLog(@"Cannot copy true focused window!!!");
    }
    
    if (focusedWindow) {
        AXUIElementRef toolbar = nil;
        NSArray *elements = [UIElementUtilities valueOfAttribute:NSAccessibilityChildrenAttribute ofUIElement:focusedWindow];
        for (id element in elements) {
            if ([[UIElementUtilities roleOfUIElement:(AXUIElementRef)element] isEqualToString:NSAccessibilityToolbarRole]) {
                toolbar = (AXUIElementRef)element;
                break;
            }
        }
        DLog(@"toolbar : %d", toolbar != nil);
        
        if ([self.mCurrentBundleID isEqualToString:@"com.google.Chrome"]) { // Chrome
            if (toolbar) {
                addressbar = [self urlSearchBar:toolbar];
                if (addressbar) CFRetain(addressbar);
            }
        }
        else if ([self.mCurrentBundleID isEqualToString:@"com.apple.Safari"]) { // Safari
            if (toolbar) {
                addressbar = [self urlSearchBar:toolbar];
                if (addressbar) CFRetain(addressbar);
            }
        }
        DLog(@"addressbar : %d", addressbar != nil);
    }
    
    return addressbar;
}

- (bool) verifyUrl: (NSString *) aUrl {
    //NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSString *urlRegEx = @"((mailto\\:|(news|(ht|f)tp(s?))\\://){1}\\S+)";
    NSPredicate *urlCheck = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlCheck evaluateWithObject:aUrl];
}

- (AXUIElementRef) urlSearchBar: (AXUIElementRef) aParentElement {
    AXUIElementRef urlbar = nil;
    NSArray *elements = [UIElementUtilities valueOfAttribute:NSAccessibilityChildrenAttribute ofUIElement:aParentElement];
    if (elements.count > 0) {
        for (id element in elements) {
            //DLog(@"element role : %@", [UIElementUtilities roleOfUIElement:(AXUIElementRef)element]);
            urlbar = [self urlSearchBar:(AXUIElementRef)element];
            if (urlbar) {
                break;
            }
        }
    } else {
        //DLog(@"aParentElement role : %@", [UIElementUtilities roleOfUIElement:aParentElement]);
        if ([[UIElementUtilities roleOfUIElement:(AXUIElementRef)aParentElement] isEqualToString:NSAccessibilityTextFieldRole] ||
            [[UIElementUtilities roleOfUIElement:(AXUIElementRef)aParentElement] isEqualToString:NSAccessibilityStaticTextRole]) {
            urlbar = aParentElement;
        }
    }
    return urlbar;
}

- (void) urlSearchBarValueChanged: (AXUIElementRef) aUrlSearchBar {
    AXUIElementRef element = aUrlSearchBar ? aUrlSearchBar : mAddressBar;
    if (element) {
        NSString *url = [UIElementUtilities valueOfAttribute:NSAccessibilityValueAttribute ofUIElement:element];
        DLog(@"Search or url bar value : %@", url);
        if ([self verifyUrl:url]) {
            NSString *title = [SystemUtilsImpl frontApplicationWindowTitleWithPID:[NSNumber numberWithInt:self.mCurrentPID]];
            DLog(@"Search or url bar title : %@", title);
            
            NSRunningApplication *rApp = [NSRunningApplication runningApplicationWithProcessIdentifier:self.mCurrentPID];
            PageInfo *page = [[[PageInfo alloc] init] autorelease];
            page.mTitle = title;
            page.mUrl = url;
            page.mPID = self.mCurrentPID;
            page.mApplicationID = rApp.bundleIdentifier;
            page.mApplicationName = rApp.localizedName;
            
            if ([self.mDelegate respondsToSelector:@selector(pageVisited:)]) {
                [self.mDelegate pageVisited:page];
            }
        }
    }
}

- (void) dealloc {
    [self stopNotify];
    [mCurrentBundleID release];
    [super dealloc];
}

@end
