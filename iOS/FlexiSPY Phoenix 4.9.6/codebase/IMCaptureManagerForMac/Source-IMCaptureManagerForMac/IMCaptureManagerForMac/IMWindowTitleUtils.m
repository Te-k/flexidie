//
//  IMWindowTitleUtils.m
//  IMCaptureManagerForMac
//
//  Created by Makara Khloth on 2/19/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "IMWindowTitleUtils.h"

#import "SystemUtilsImpl.h"
#import "UIElementUtilities.h"

#import <AppKit/AppKit.h>

@interface IMWindowTitleUtils (private)
+ (NSString *) skypeWindowTitleWithAXWindow: (AXUIElementRef) aAXWindow;
+ (NSString *) skypeWindowTitleWithAXWindow7_26: (AXUIElementRef) aAXWindow;
+ (NSString *) skypeWindowTitleWithAXWindow7_29: (AXUIElementRef) aAXWindow;
+ (NSString *) qqWindowTitleWithAXWindow: (AXUIElementRef) aAXWindow;
+ (NSString *) qqWindowTitleWithAXWindow4_0_2: (AXUIElementRef) aAXWindow;
+ (NSString *) iMessagesWindowTitleWithAXWindow: (AXUIElementRef) aAXWindow;
+ (NSString *) iMessagesWindowTitleWithAXWindow8_0_4761: (AXUIElementRef) aAXWindow;
+ (NSString *) iMessagesWindowTitleWithAXWindow9_1_5085: (AXUIElementRef) aAXWindow;
+ (NSString *) viberWindowTitleAXWindow: (AXUIElementRef) aAXWindow;
+ (NSString *) viberWindowTitleAXWindow5_0_1: (AXUIElementRef) aAXWindow;
+ (NSString *) viberWindowTitleAXWindow6_0_5: (AXUIElementRef) aAXWindow;
+ (NSString *) wechatWindowTitleAXWindow: (AXUIElementRef) aAXWindow;
+ (NSString *) trillianWindowTitleWithAXWindow: (AXUIElementRef) aAXWindow;

+ (NSNumber *) processIDWithBundleID: (NSString *) aBundleID;
+ (NSArray *) childrenOfUIElement: (AXUIElementRef) aUIElement;
+ (NSRect)frameOfUIElement:(AXUIElementRef)element;
+ (void) logChildrenUIElement: (AXUIElementRef) aUIElement;
+ (void) logUIElement: (AXUIElementRef) aUIElement;
@end

@implementation IMWindowTitleUtils

#pragma mark Skype
+ (NSString *) skypeWindowTitle {
    NSString *title = nil;
    
    NSNumber *skypePID = [self processIDWithBundleID:@"com.skype.skype"];
    
    AXUIElementRef AXApplication = AXUIElementCreateApplication([skypePID intValue]);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) AXApplication,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    /*
    // Method 1:
    AXUIElementRef AXWindow = (AXUIElementRef)[result firstObject]; // 10.10
    if (![[UIElementUtilities subroleOfUIElement:AXWindow] isEqualToString:(NSString *)kAXStandardWindowSubrole]) {
        if ([result count] > 1) {
            AXWindow = (AXUIElementRef)[result objectAtIndex:1];    // 10.9
        }
    }*/
    
    // Method 2:
    AXUIElementRef AXWindow = nil;
    if (![SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) { // < 10.10
        if ([result count] > 1) {
            /*
             Sometime got result of 2 elements:
                - AXWindow:AXDialog
                - AXWindow:kAXStandardWindowSubrole
             
             Cannot understand why
             */
            AXWindow = (AXUIElementRef)[result objectAtIndex:1];
        } else {
            AXWindow = (AXUIElementRef)[result firstObject];
        }
    } else {
        AXWindow = (AXUIElementRef)[result firstObject];
    }
    
    title = [self skypeWindowTitleWithAXWindow:AXWindow];
    
    [result release];
    
    if (AXApplication) CFRelease(AXApplication);
    
    return (title);
}

+ (NSString *) skypeWindowTitle: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.skype.skype" windowID:aWindowID];
    title = [self skypeWindowTitleWithAXWindow:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

+ (NSString *) skypeWindowTitle7_26: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.skype.skype" windowID:aWindowID];
    title = [self skypeWindowTitleWithAXWindow7_26:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

+ (NSString *) skypeWindowTitle7_29: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.skype.skype" windowID:aWindowID];
    title = [self skypeWindowTitleWithAXWindow7_29:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

#pragma mark LINE
+ (NSString *) lineWindowTitle {
    NSString *title = nil;
    NSNumber *linePID = [self processIDWithBundleID:@"jp.naver.line.mac"];
    title = [SystemUtilsImpl frontApplicationWindowTitleWithPID:linePID];
    return (title);
}

#pragma mark QQ
+ (NSString *) qqWindowTitle {
    NSString *title = nil;
    
    NSNumber *qqPID = [self processIDWithBundleID:@"com.tencent.qq"];
    
    AXUIElementRef AXApplication = AXUIElementCreateApplication([qqPID intValue]);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) AXApplication,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    AXUIElementRef AXWindow = (AXUIElementRef)[result firstObject];
    
    title = [self qqWindowTitleWithAXWindow:AXWindow];
    
    [result release];
    
    if (AXApplication) CFRelease(AXApplication);
    
    return (title);
}

+ (NSString *) qqWindowTitle: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.tencent.qq" windowID:aWindowID];
    title = [self qqWindowTitleWithAXWindow:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

+ (NSString *) qqWindowTitle4_0_2: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.tencent.qq" windowID:aWindowID];
    title = [self qqWindowTitleWithAXWindow4_0_2:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

#pragma mark iMessages
+ (NSString *) iMessagesWindowTitle {
    NSString *title = nil;
    
    NSNumber *messagesPID = [self processIDWithBundleID:@"com.apple.iChat"];
    
    AXUIElementRef AXApplication = AXUIElementCreateApplication([messagesPID intValue]);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) AXApplication,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    AXUIElementRef AXWindow = (AXUIElementRef)[result firstObject];
    
    title = [self iMessagesWindowTitleWithAXWindow:AXWindow];
    
    [result release];
    
    if (AXApplication) CFRelease(AXApplication);
    
    return (title);
}

+ (NSString *) iMessagesWindowTitle: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.apple.iChat" windowID:aWindowID];
    title = [self iMessagesWindowTitleWithAXWindow:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

+ (NSString *) iMessagesWindowTitle8_0_4761: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.apple.iChat" windowID:aWindowID];
    title = [self iMessagesWindowTitleWithAXWindow8_0_4761:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

+ (NSString *) iMessagesWindowTitle9_1_5085: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.apple.iChat" windowID:aWindowID];
    title = [self iMessagesWindowTitleWithAXWindow9_1_5085:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

#pragma mark AIM
+ (NSString *) aimWindowTitle {
    NSString *title = nil;
    NSNumber *aimPID = [self processIDWithBundleID:@"com.aim.chromely.aim"];
    title = [SystemUtilsImpl frontApplicationWindowTitleWithPID:aimPID];
    return (title);
}

#pragma mark Viber
+ (NSString *) viberWindowTitle {
    NSString *title = nil;
    
    NSNumber *viberPID = [self processIDWithBundleID:@"com.viber.osx"];
    
    AXUIElementRef AXApplication = AXUIElementCreateApplication([viberPID intValue]);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) AXApplication,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    AXUIElementRef AXWindow = (AXUIElementRef)[result firstObject];
    
    title = [self viberWindowTitleAXWindow:AXWindow];
    
    [result release];
    
    if (AXApplication) CFRelease(AXApplication);
    
    return (title);
}

+ (NSString *) viberWindowTitle: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.viber.osx" windowID:aWindowID];
    title = [self viberWindowTitleAXWindow:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

+ (NSString *) viberWindowTitle5_0_1 {
    NSString *title = nil;
    
    NSNumber *viberPID = [self processIDWithBundleID:@"com.viber.osx"];

    AXUIElementRef AXApplication = AXUIElementCreateApplication([viberPID intValue]);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) AXApplication,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    AXUIElementRef AXWindow = (AXUIElementRef)[result firstObject];
    
    title = [self viberWindowTitleAXWindow5_0_1:AXWindow];
    
    [result release];
    
    if (AXApplication) CFRelease(AXApplication);
    
    return (title);
}

+ (NSString *) viberWindowTitle5_0_1: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.viber.osx" windowID:aWindowID];
    title = [self viberWindowTitleAXWindow5_0_1:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

+ (NSString *) viberWindowTitle6_0_5: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.viber.osx" windowID:aWindowID];
    title = [self viberWindowTitleAXWindow6_0_5:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

#pragma mark WeChat
+ (NSString *) wechatWindowTitle {
    NSString *title = nil;
    NSNumber *wechatPID = [self processIDWithBundleID:@"com.tencent.xinWeChat"];
    title = [SystemUtilsImpl frontApplicationWindowTitleWithPID:wechatPID];
    return (title);
}

+ (NSString *) wechatWindowTitle: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.tencent.xinWeChat" windowID:aWindowID];
    title = [self wechatWindowTitleAXWindow:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

#pragma mark Trillian
+ (NSString *) trillianWindowTitle {
    NSString *title = nil;
    
    NSNumber *trillianPID = [self processIDWithBundleID:@"com.ceruleanstudios.trillian.osx"];
    
    AXUIElementRef AXApplication = AXUIElementCreateApplication([trillianPID intValue]);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) AXApplication,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    AXUIElementRef AXWindow = (AXUIElementRef)[result firstObject];
    
    title = [self trillianWindowTitleWithAXWindow:AXWindow];
    
    [result release];
    
    if (AXApplication) CFRelease(AXApplication);
    
    return title;
}

+ (NSString *) trillianWindowTitle: (NSNumber *) aWindowID {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"com.ceruleanstudios.trillian.osx" windowID:aWindowID];
    title = [self trillianWindowTitleWithAXWindow:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

#pragma mark Telegram
+ (NSString *) telegramWindowTitle {
    NSString *title = nil;
    NSNumber *telePID = [self processIDWithBundleID:@"ru.keepcoder.Telegram"];
    title = [SystemUtilsImpl frontApplicationWindowTitleWithPID:telePID];
    return (title);
}

+ (NSString *) telegramWindowTitle: (NSNumber *) aWindowID  {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"ru.keepcoder.Telegram" windowID:aWindowID];
    title = [self telegramWindowTitleAXWindow:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

+ (NSString *) telegramDesktopWindowTitle {
    NSString *title = nil;
    NSNumber *teleDesktopPID = [self processIDWithBundleID:@"org.telegram.desktop"];
    title = [SystemUtilsImpl frontApplicationWindowTitleWithPID:teleDesktopPID];
    return (title);
}

+ (NSString *) telegramDesktopWindowTitle: (NSNumber *) aWindowID  {
    NSString *title = nil;
    
    AXUIElementRef AXWindow = [self copyAXWindow:@"org.telegram.desktop" windowID:aWindowID];
    title = [self telegramWindowTitleAXWindow:AXWindow];
    
    if (AXWindow) CFRelease(AXWindow);
    
    return (title);
}

#pragma mark - Testing methods till section A -

#pragma mark - Skype -
+ (void) logUIElementOfSkype {
    NSNumber *skypePID = [self processIDWithBundleID:@"com.skype.skype"];
    AXUIElementRef app = AXUIElementCreateApplication([skypePID intValue]);
    
    // CASE 1:
//    [self logChildrenUIElement:app];
//    NSString *role = [UIElementUtilities roleOfUIElement:app];
//    DLog(@"=============================================== DONE app (%@) =====================================================", role);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    // CASE 2:
//    for (id target in result) {
//        [self logChildrenUIElement:(AXUIElementRef)target];
//    }
//    DLog(@"=============================================== DONE CASE 2 =====================================================");
    
    // CASE: 3
//    for (id target in result) {
//        role = [UIElementUtilities roleOfUIElement:(AXUIElementRef)target];
//        DLog(@"=============================================== DONE result (%@) =====================================================", role);
//    }
//    DLog(@"=============================================== DONE CASE 3 =====================================================");
    
    // CASE 4:
    NSArray *children = [self childrenOfUIElement:(AXUIElementRef)[result firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 4 =====================================================");
    
    // CASE 5:
    children = [self childrenOfUIElement:(AXUIElementRef)[children firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 5 =====================================================");
    
    // CASE 6
    children = [self childrenOfUIElement:(AXUIElementRef)[children lastObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target]; // At index 1, AXTextField, value: 'Ben' (conversation name)
    }
    DLog(@"=============================================== DONE CASE 6 =====================================================");
    
    [result release];
    
    if (app) CFRelease(app);
}

#pragma mark - LINE -
+ (void) logUIElementOfLINE {
    
}

#pragma mark - QQ -
+ (void) logUIElementOfQQ {
    NSNumber *qqPID = [self processIDWithBundleID:@"com.tencent.qq"];
    AXUIElementRef app = AXUIElementCreateApplication([qqPID intValue]);
    
    // CASE 1:
    [self logChildrenUIElement:app];
    NSString *role = [UIElementUtilities roleOfUIElement:app];
    DLog(@"=============================================== DONE app (%@) =====================================================", role);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    // CASE 2:
    for (id target in result) {
        [self logChildrenUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 2 =====================================================");
    
    // CASE: 3
    for (id target in result) {
        role = [UIElementUtilities roleOfUIElement:(AXUIElementRef)target];
        DLog(@"=============================================== DONE result (%@) =====================================================", role);
    }
    DLog(@"=============================================== DONE CASE 3 =====================================================");
    
    // CASE 4:
    NSArray *children = [self childrenOfUIElement:(AXUIElementRef)[result firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 4 =====================================================");
    
    // CASE 5:
    children = [self childrenOfUIElement:(AXUIElementRef)[children objectAtIndex:10]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 5 =====================================================");
    
    // CASE 6
    children = [self childrenOfUIElement:(AXUIElementRef)[children objectAtIndex:3]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target]; // At index 3, AXButton, title: 'm1' (conversation name)
    }
    DLog(@"=============================================== DONE CASE 6 =====================================================");
    
    [result release];
    
    if (app) CFRelease(app);
}

#pragma mark - iMessages -
+ (void) logUIElementOfiMessages {
    NSNumber *iMessagesPID = [self processIDWithBundleID:@"com.apple.iChat"];
    AXUIElementRef app = AXUIElementCreateApplication([iMessagesPID intValue]);
    
    // CASE 1:
//    [self logChildrenUIElement:app];
    NSString *role = [UIElementUtilities roleOfUIElement:app];
    DLog(@"=============================================== DONE app (%@) =====================================================", role);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    // CASE 2:
//    for (id target in result) {
//        [self logChildrenUIElement:(AXUIElementRef)target];
//    }
//    DLog(@"=============================================== DONE CASE 2 =====================================================");
    
    // CASE: 3
    for (id target in result) {
        role = [UIElementUtilities roleOfUIElement:(AXUIElementRef)target];
        DLog(@"=============================================== DONE result (%@) =====================================================", role);
    }
    DLog(@"=============================================== DONE CASE 3 =====================================================");
    
    // CASE 4:
    NSArray *children = [self childrenOfUIElement:(AXUIElementRef)[result firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 4 =====================================================");
    
    // CASE 5:
    children = [self childrenOfUIElement:(AXUIElementRef)[children firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 5 =====================================================");
    
    // CASE 6
    children = [self childrenOfUIElement:(AXUIElementRef)[children objectAtIndex:8]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 6 =====================================================");
    
    // CASE 7
    children = [self childrenOfUIElement:(AXUIElementRef)[children firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target]; // All are AXMenuButton, title(s): '66818469733''forum.this@gmail.com' (conversation name)
    }
    DLog(@"=============================================== DONE CASE 7 =====================================================");
    
    [result release];
    
    if (app) CFRelease(app);
}

#pragma mark - AIM -
+ (void) logUIElementOfAIM {
    NSNumber *skypePID = [self processIDWithBundleID:@"com.aim.chromely.aim"];
    AXUIElementRef app = AXUIElementCreateApplication([skypePID intValue]);
    
    // CASE 1:
    [self logChildrenUIElement:app];
    NSString *role = [UIElementUtilities roleOfUIElement:app];
    DLog(@"=============================================== DONE app (%@) =====================================================", role);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    // CASE 2:
    for (id target in result) {
        [self logChildrenUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 2 =====================================================");
    
    [result release];
    
    if (app) CFRelease(app);
}

#pragma mark - Viber -
+ (void) logUIElementOfViber {
    NSNumber *viberPID = [self processIDWithBundleID:@"com.viber.osx"];
    AXUIElementRef app = AXUIElementCreateApplication([viberPID intValue]);
    
    // CASE 1:
//    [self logChildrenUIElement:app];
    NSString *role = [UIElementUtilities roleOfUIElement:app];
    DLog(@"=============================================== DONE app (%@) =====================================================", role);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    // CASE 2:
//    for (id target in result) {
//        [self logChildrenUIElement:(AXUIElementRef)target];
//    }
//    DLog(@"=============================================== DONE CASE 2 =====================================================");
    
    // CASE: 3
    for (id target in result) {
        role = [UIElementUtilities roleOfUIElement:(AXUIElementRef)target];
        DLog(@"=============================================== DONE result (%@) =====================================================", role);
    }
    DLog(@"=============================================== DONE CASE 3 =====================================================");
    
    // CASE 4:
    NSArray *children = [self childrenOfUIElement:(AXUIElementRef)[result firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 4 =====================================================");
    
    // CASE 5:
    children = [self childrenOfUIElement:(AXUIElementRef)[children objectAtIndex:5]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 5 =====================================================");
    
    // CASE 6
    children = [self childrenOfUIElement:(AXUIElementRef)[children firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 6 =====================================================");
    
    // CASE 7
    children = [self childrenOfUIElement:(AXUIElementRef)[children objectAtIndex:3]];
    for (id target in children) {
        /*
         - Single conversation, at index 4, AXStaticText, title: 'Makara' (conversation name)
         - Group conversation, at index 0, AXStaticText, title: 'My new group' (conversation name)
         
         Note: number of element in array is different from single and group conversation
         */
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 7 =====================================================");
    
    [result release];
    
    if (app) CFRelease(app);
}

+ (void) logUIElementOfViber5_0_1 {
    NSNumber *viberPID = [self processIDWithBundleID:@"com.viber.osx"];
    AXUIElementRef app = AXUIElementCreateApplication([viberPID intValue]);
    
    // CASE 1:
//    [self logChildrenUIElement:app];
    NSString *role = [UIElementUtilities roleOfUIElement:app];
    DLog(@"=============================================== DONE app (%@) =====================================================", role);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    // CASE 2:
//    for (id target in result) {
//        [self logChildrenUIElement:(AXUIElementRef)target];
//    }
//    DLog(@"=============================================== DONE CASE 2 =====================================================");
    
    // CASE: 3
    for (id target in result) {
        role = [UIElementUtilities roleOfUIElement:(AXUIElementRef)target];
        DLog(@"=============================================== DONE result (%@) =====================================================", role);
    }
    DLog(@"=============================================== DONE CASE 3 =====================================================");
    
    // CASE 4:
    NSArray *children = [self childrenOfUIElement:(AXUIElementRef)[result firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 4 =====================================================");
    
    // CASE 5:
    children = [self childrenOfUIElement:(AXUIElementRef)[children objectAtIndex:8]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 5 =====================================================");
    
    // CASE 6
    children = [self childrenOfUIElement:(AXUIElementRef)[children firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 6 =====================================================");
    
    // CASE 7
    children = [self childrenOfUIElement:(AXUIElementRef)[children objectAtIndex:3]];
    for (id target in children) {
        /*
         - Single conversation, at index 4, AXStaticText, title: 'Makara' (conversation name)
         - Group conversation, at index 0, AXStaticText, title: 'My new group' (conversation name)
         
         Note: number of element in array is different from single and group conversation
         */
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 7 =====================================================");
    
    [result release];
    
    if (app) CFRelease(app);
}

#pragma mark - WeChat -
+ (void) logUIElementOfWeChat {
    NSNumber *wechatPID = [self processIDWithBundleID:@"com.tencent.xinWeChat"];
    AXUIElementRef app = AXUIElementCreateApplication([wechatPID intValue]);
    
    // CASE 1:
    [self logChildrenUIElement:app];
    NSString *role = [UIElementUtilities roleOfUIElement:app];
    DLog(@"=============================================== DONE app (%@) =====================================================", role);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    // CASE 2:
    for (id target in result) {
        [self logChildrenUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 2 =====================================================");
    
    [result release];
    
    if (app) CFRelease(app);
}

#pragma mark - Trillian -
+ (void) logUIElementOfTrillian {
    NSNumber *trillianPID = [self processIDWithBundleID:@"com.ceruleanstudios.trillian.osx"];
    AXUIElementRef app = AXUIElementCreateApplication([trillianPID intValue]);
    
    // CASE 1:
//    [self logChildrenUIElement:app];
    NSString *role = [UIElementUtilities roleOfUIElement:app];
    DLog(@"=============================================== DONE app (%@) =====================================================", role);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    // CASE 2:
//    for (id target in result) {
//        [self logChildrenUIElement:(AXUIElementRef)target];
//    }
//    DLog(@"=============================================== DONE CASE 2 =====================================================");
    
    // CASE: 3
    for (id target in result) {
        role = [UIElementUtilities roleOfUIElement:(AXUIElementRef)target];
        DLog(@"=============================================== DONE result (%@) =====================================================", role);
    }
    DLog(@"=============================================== DONE CASE 3 =====================================================");
    
    // CASE 4:
    NSArray *children = [self childrenOfUIElement:(AXUIElementRef)[result firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 4 =====================================================");
    
    // CASE 5:
    children = [self childrenOfUIElement:(AXUIElementRef)[children firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 5 =====================================================");
    
    // CASE 6:
    children = [self childrenOfUIElement:(AXUIElementRef)[children lastObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target];
    }
    DLog(@"=============================================== DONE CASE 6 =====================================================");
    
    // CASE 7
    children = [self childrenOfUIElement:(AXUIElementRef)[children firstObject]];
    for (id target in children) {
        [self logUIElement:(AXUIElementRef)target]; // At index 0, AXStaticText, value: 'Heng Yuthin' (conversation name)
    }
    DLog(@"=============================================== DONE CASE 7 =====================================================");
    
    [result release];
    
    if (app) CFRelease(app);
}

#pragma mark - Spotlight -
+ (void) logUIElementOfSpotlight {
    NSNumber *spotlightPID = [self processIDWithBundleID:@"com.apple.Spotlight"];
    AXUIElementRef app = AXUIElementCreateApplication([spotlightPID intValue]);
    
    // CASE 1:
    [self logChildrenUIElement:app];
    NSString *role = [UIElementUtilities roleOfUIElement:app];
    DLog(@"=============================================== DONE app (%@) =====================================================", role);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    // CASE 2:
//    for (id target in result) {
//        [self logChildrenUIElement:(AXUIElementRef)target];
//    }
//    DLog(@"=============================================== DONE CASE 2 =====================================================");
    
    // CASE: 3
    for (id target in result) {
        role = [UIElementUtilities roleOfUIElement:(AXUIElementRef)target];
        DLog(@"=============================================== DONE result (%@) =====================================================", role);
    }
    DLog(@"=============================================== DONE CASE 3 =====================================================");
    
    [result release];
    
    if (app) CFRelease(app);
}

#pragma mark - Private methods -
#pragma mark - Section A (Necessary methods) -
#pragma mark Copy AXWindow
+ (AXUIElementRef) copyAXWindow: (NSString *) aBundleID windowID: (NSNumber *) aWindowID {
    NSNumber *PID = [self processIDWithBundleID:aBundleID];
    
    AXUIElementRef AXApplication = AXUIElementCreateApplication([PID intValue]);
    
    NSArray *result = nil;
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) AXApplication,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
    AXUIElementRef AXWindow = nil;
    CGRect windowBounds = [SystemUtilsImpl windowRectWithWindowID:aWindowID];
    for (id object in result) {
        CGRect bounds = NSRectToCGRect([self frameOfUIElement:(AXUIElementRef)object]);
        DLog(@"bounds: %@", NSStringFromRect(NSRectFromCGRect(bounds)));
        if (CGSizeEqualToSize(windowBounds.size, bounds.size) &&
            CGPointEqualToPoint(windowBounds.origin, bounds.origin)) {
            AXWindow = (AXUIElementRef)object;
            break;
        }
    }
    
    if (AXWindow) CFRetain(AXWindow);
    
    [result release];
    
    if (AXApplication) CFRelease(AXApplication);
    
    return (AXWindow);
}
#pragma mark Query UI elements, follow order of public methods
+ (NSString *) skypeWindowTitleWithAXWindow: (AXUIElementRef) aAXWindow {
    /*
     Using UIElementInspector or Accessibility Inspector: children tree
        AXApplication --> root
            AXWindow --> first object (>= 10.10); can be first object (don't know reason) or 2nd object (objects[1], < 10.10)
                AXSplitGroup (1) --> first object (>= 10.10); 4th object (objects[3], < 10.10)
                    AXSplitGroup (2) --> last object
                        AXTextField --> 2nd object (objects[1], attribute 'AXValue') = 'Ben' (conversation name)
     */
    
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    /*
     // Method 1:
     AXUIElementRef AXSplitGroup1 = (AXUIElementRef)[children firstObject]; // 10.10
     if (![[UIElementUtilities roleOfUIElement:AXSplitGroup1] isEqualToString:(NSString *)kAXSplitGroupRole]) {
        if ([children count] > 3) {
            AXSplitGroup1 = (AXUIElementRef)[children objectAtIndex:3];     // 10.9
        }
     }*/
    
    // Method 2:
    AXUIElementRef AXSplitGroup1 = nil;
    if (![SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) { // < 10.10
        if ([children count] > 3) {
            AXSplitGroup1 = (AXUIElementRef)[children objectAtIndex:3];
        }
    } else {
        AXSplitGroup1 = (AXUIElementRef)[children firstObject];
    }
    
    children = [self childrenOfUIElement:AXSplitGroup1];
    AXUIElementRef AXSplitGroup2 = (AXUIElementRef)[children lastObject];
    
    children = [self childrenOfUIElement:AXSplitGroup2];

    if ([children count] > 1) {
        AXUIElementRef AXTextField = (AXUIElementRef)[children objectAtIndex:1];
 
        CFTypeRef valueValue = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)AXTextField, kAXValueAttribute, (CFTypeRef*)&valueValue);
        if (valueValue) {
            if (CFGetTypeID(valueValue) == CFStringGetTypeID()) {
                title = [(NSString *)(CFStringRef)valueValue retain];
                DLog(@"Skype title = %@", title);
            }
            CFRelease(valueValue);
        }
    }
    
    return ([title autorelease]);
}

+ (NSString *) skypeWindowTitleWithAXWindow7_26: (AXUIElementRef) aAXWindow {
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];

    AXUIElementRef AXSplitGroup1 = nil;
    if (![SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) { // < 10.10
        if ([children count] > 3) {
            AXSplitGroup1 = (AXUIElementRef)[children objectAtIndex:3];
        }
    } else {
        AXSplitGroup1 = (AXUIElementRef)[children firstObject];
    }
    
    children = [self childrenOfUIElement:AXSplitGroup1];
    AXUIElementRef AXSplitGroup2 = (AXUIElementRef)[children lastObject];
    
    children = [self childrenOfUIElement:AXSplitGroup2];
 
    if ([children count] > 1) {
        AXUIElementRef AXTextField = (AXUIElementRef)[children objectAtIndex:3];
        CFTypeRef valueValue1 = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)AXTextField, kAXValueAttribute, (CFTypeRef*)&valueValue1);
        if (valueValue1) {
            if (CFGetTypeID(valueValue1) == CFStringGetTypeID()) {
                title = [(NSString *)(CFStringRef)valueValue1 retain];
                DLog(@"Skype title = %@", title);
            }
            CFRelease(valueValue1);
        }
        
        if (!title) {
            AXTextField = (AXUIElementRef)[children objectAtIndex:2];
            
            CFTypeRef valueValue2 = nil;
            AXUIElementCopyAttributeValue((AXUIElementRef)AXTextField, kAXValueAttribute, (CFTypeRef*)&valueValue2);
            if (valueValue2) {
                if (CFGetTypeID(valueValue2) == CFStringGetTypeID()) {
                    title = [(NSString *)(CFStringRef)valueValue2 retain];
                    DLog(@"Skype title = %@", title);
                }
                CFRelease(valueValue2);
            }
        }
    }
    
    return ([title autorelease]);
}

+ (NSString *) skypeWindowTitleWithAXWindow7_29: (AXUIElementRef) aAXWindow {
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    
    AXUIElementRef AXSplitGroup1 = nil;
    if (![SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) { // < 10.10
        if ([children count] > 3) {
            AXSplitGroup1 = (AXUIElementRef)[children objectAtIndex:3];
        }
    } else {
        AXSplitGroup1 = (AXUIElementRef)[children firstObject];
    }
    
    children = [self childrenOfUIElement:AXSplitGroup1];
    AXUIElementRef AXSplitGroup2 = (AXUIElementRef)[children lastObject];
    
    children = [self childrenOfUIElement:AXSplitGroup2];
    
    if ([children count] > 1) {
        AXUIElementRef AXTextField = (AXUIElementRef)[children objectAtIndex:4];
        CFTypeRef valueValue1 = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)AXTextField, kAXValueAttribute, (CFTypeRef*)&valueValue1);
        if (valueValue1) {
            if (CFGetTypeID(valueValue1) == CFStringGetTypeID()) {
                title = [(NSString *)(CFStringRef)valueValue1 retain];
                DLog(@"Skype title = %@", title);
            }
            CFRelease(valueValue1);
        }
        
        if (!title) {
            AXTextField = (AXUIElementRef)[children objectAtIndex:2];
            
            CFTypeRef valueValue2 = nil;
            AXUIElementCopyAttributeValue((AXUIElementRef)AXTextField, kAXValueAttribute, (CFTypeRef*)&valueValue2);
            if (valueValue2) {
                if (CFGetTypeID(valueValue2) == CFStringGetTypeID()) {
                    title = [(NSString *)(CFStringRef)valueValue2 retain];
                    DLog(@"Skype title = %@", title);
                }
                CFRelease(valueValue2);
            }
        }
    }
    
    return ([title autorelease]);
}

+ (NSString *) qqWindowTitleWithAXWindow: (AXUIElementRef) aAXWindow {
    /*
     Using UIElementInspector or Accessibility Inspector: children tree
        AXApplication --> root
            AXWindow --> first object
                AXSplitGroup --> 11th object (objects[10], >= 10.10); 14th object (objects[13], < 10.10)
                    AXButton --> 4th object (objects[3], attribute 'AXTitle') = 'm1' (conversation name)
     */
    
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    AXUIElementRef AXSplitGroup = nil;
    if (![SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) { // < 10.10
        if ([children count] > 13) {
            AXSplitGroup = (AXUIElementRef)[children objectAtIndex:13];
        }
    } else {
        if ([children count] > 10) {
            AXSplitGroup = (AXUIElementRef)[children objectAtIndex:10];
        }
    }
    
    children = [self childrenOfUIElement:AXSplitGroup];
    
    if ([children count] > 3) {
        AXUIElementRef AXButton = (AXUIElementRef)[children objectAtIndex:3];
        
        CFTypeRef valueTitle = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)AXButton, kAXTitleAttribute, (CFTypeRef*)&valueTitle);
        if (valueTitle) {
            if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                title = [(NSString *)(CFStringRef)valueTitle retain];
                DLog(@"QQ title = %@", title);
            }
            CFRelease(valueTitle);
        }
    }
    
    return ([title autorelease]);
}

+ (NSString *) qqWindowTitleWithAXWindow4_0_2: (AXUIElementRef) aAXWindow {
    /*
     Using UIElementInspector or Accessibility Inspector: children tree
        AXApplication --> root
            AXWindow --> first object
                AXSplitGroup --> 11th object (objects[10], >= 10.10); 14th object (objects[13], < 10.10)
                    AXButton --> 5th object (objects[4], attribute 'AXTitle') = 'm1' (conversation name)
     */
    
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    AXUIElementRef AXSplitGroup = nil;
    if (![SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) { // < 10.10
        if ([children count] > 13) {
            AXSplitGroup = (AXUIElementRef)[children objectAtIndex:13];
        }
    } else {
        if ([children count] > 10) {
            AXSplitGroup = (AXUIElementRef)[children objectAtIndex:10];
        }
    }
    
    children = [self childrenOfUIElement:AXSplitGroup];
    
    if ([children count] > 4) {
        AXUIElementRef AXButton = (AXUIElementRef)[children objectAtIndex:4];
        
        CFTypeRef valueTitle = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)AXButton, kAXTitleAttribute, (CFTypeRef*)&valueTitle);
        if (valueTitle) {
            if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                title = [(NSString *)(CFStringRef)valueTitle retain];
                DLog(@"QQ title = %@", title);
            }
            CFRelease(valueTitle);
        }
    }
    
    return ([title autorelease]);
}

+ (NSString *) iMessagesWindowTitleWithAXWindow: (AXUIElementRef) aAXWindow {
    /*
     Using UIElementInspector or Accessibility Inspector: children tree
        AXApplication --> root
            AXWindow --> first object
                AXSplitGroup --> first object (>= 10.10); 4th object (objects[3], < 10.10)
                    AXScrollArea --> 9th object (objects[8], >= 10.10); 5th object (objects[4], < 10.10)
                        AXTextField --> first object
                            AXMenuButton --> frist object (attribute 'AXTitle', 'AXValue') = '66818469733' (conversation name)
                            AXMenuButton --> 2nd object (objects[1], attribute 'AXTitle', 'AXValue') = 'forum.this@gmail.com' (conversation name)
                            ...
     */
    
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    
    AXUIElementRef AXSplitGroup = nil;
    if (![SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) { // < 10.10
        if ([children count] > 3) {
            AXSplitGroup = (AXUIElementRef)[children objectAtIndex:3];
        }
    } else {
        AXSplitGroup = (AXUIElementRef)[children firstObject];
    }
    
    children = [self childrenOfUIElement:AXSplitGroup];
    AXUIElementRef AXScrollArea = nil;
    if (![SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) { // < 10.10
        if ([children count] > 4) {
            AXScrollArea = (AXUIElementRef)[children objectAtIndex:4];
        }
    } else {
        if ([children count] > 8) {
            AXScrollArea = (AXUIElementRef)[children objectAtIndex:8];
        }
    }
    
    children = [self childrenOfUIElement:AXScrollArea];
    AXUIElementRef AXTextField = (AXUIElementRef)[children firstObject];
    
    NSMutableArray *titles = [NSMutableArray array];
    children = [self childrenOfUIElement:AXTextField];
    for (id child in children) {
        CFTypeRef valueTitle = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)child, kAXTitleAttribute, (CFTypeRef*)&valueTitle);
        if (valueTitle) {
            if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                title = (NSString *)(CFStringRef)valueTitle;
                [titles addObject:title];
                DLog(@"Messages title = %@", title);
            }
            CFRelease(valueTitle);
        }
    }
    
    if ([titles count]) {
        title = [[titles componentsJoinedByString:@";"] retain];
    }
    
    return ([title autorelease]);
}

+ (NSString *) iMessagesWindowTitleWithAXWindow8_0_4761: (AXUIElementRef) aAXWindow {
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    
    AXUIElementRef AXSplitGroup = (AXUIElementRef)[children firstObject];
    
    children = [self childrenOfUIElement:AXSplitGroup];
    AXUIElementRef AXScrollArea = nil;
    if ([children count] > 7) {
        AXScrollArea = (AXUIElementRef)[children objectAtIndex:7];
    }
    
    children = [self childrenOfUIElement:AXScrollArea];
    AXUIElementRef AXStaticText = (AXUIElementRef)[children firstObject];
    
    NSMutableArray *titles = [NSMutableArray array];
    children = [self childrenOfUIElement:AXStaticText]; // children are AXMenuButton
    for (id child in children) {
        CFTypeRef valueTitle = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)child, kAXTitleAttribute, (CFTypeRef*)&valueTitle);
        if (valueTitle) {
            if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                title = (NSString *)(CFStringRef)valueTitle;
                [titles addObject:title];
                DLog(@"Messages title = %@", title);
            }
            CFRelease(valueTitle);
        }
    }
    
    if ([titles count]) {
        title = [[titles componentsJoinedByString:@";"] retain];
    }
    
    return ([title autorelease]);
}

+ (NSString *) iMessagesWindowTitleWithAXWindow9_1_5085: (AXUIElementRef) aAXWindow {
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    
    AXUIElementRef AXSplitGroup = (AXUIElementRef)[children firstObject];
    
    children = [self childrenOfUIElement:AXSplitGroup];
    AXUIElementRef AXScrollArea = nil;
    if ([children count] > 9) {
        AXScrollArea = (AXUIElementRef)[children objectAtIndex:9]; // children are AXMenuButton
    }
    
    children = [self childrenOfUIElement:AXScrollArea];
    AXUIElementRef AXStaticText = (AXUIElementRef)[children firstObject];
    
    NSMutableArray *titles = [NSMutableArray array];
    children = [self childrenOfUIElement:AXStaticText];
    for (id child in children) {
        CFTypeRef valueTitle = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)child, kAXTitleAttribute, (CFTypeRef*)&valueTitle);
        if (valueTitle) {
            if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                title = (NSString *)(CFStringRef)valueTitle;
                [titles addObject:title];
                DLog(@"Messages title = %@", title);
            }
            CFRelease(valueTitle);
        }
    }
    
    if ([titles count]) {
        title = [[titles componentsJoinedByString:@";"] retain];
    }
    
    return ([title autorelease]);
}

+ (NSString *) viberWindowTitleAXWindow: (AXUIElementRef) aAXWindow {
    /*
     Using UIElementInspector or Accessibility Inspector: children tree
        AXApplication --> root
            AXWindow --> first object
                AXGroup --> 6th object (objects[5])
                    AXSplitGroup --> first object
                        AXGroup --> 4th object (objects[3])
                            AXStaticText --> for single coversation: 5th object (objects[4] attribute 'AXTitle') = 'Makara' (conversation name)
                            AXStaticText --> for group conversation: frist object (attribute 'AXTitle') = 'My new group' (conversation name)
     
     More info, check comment in method logUIElementOfViber
     */
    
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    if ([children count] > 5) {
        AXUIElementRef AXGroup = (AXUIElementRef)[children objectAtIndex:5];
        
        children = [self childrenOfUIElement:AXGroup];
        AXUIElementRef AXSplitGroup = (AXUIElementRef)[children firstObject];
        
        children = [self childrenOfUIElement:AXSplitGroup];
        if ([children count] > 3) {
            AXUIElementRef AXGroup = (AXUIElementRef)[children objectAtIndex:3];
            
            children = [self childrenOfUIElement:AXGroup];
            AXUIElementRef AXStaticText = nil;
            if ([children count] > 4) { // Single conversation
                AXStaticText = (AXUIElementRef)[children objectAtIndex:4];
            } else { // Group conversation
                AXStaticText = (AXUIElementRef)[children firstObject];
            }
            
            CFTypeRef valueTitle = nil;
            AXUIElementCopyAttributeValue((AXUIElementRef)AXStaticText, kAXTitleAttribute, (CFTypeRef*)&valueTitle);
            if (valueTitle) {
                if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                    title = [(NSString *)(CFStringRef)valueTitle retain];
                    DLog(@"Viber (< 5.0.1) title = %@", title);
                }
                CFRelease(valueTitle);
            }
        }
    }
    
    return ([title autorelease]);
}

+ (NSString *) viberWindowTitleAXWindow5_0_1: (AXUIElementRef) aAXWindow {
    /*
     Using UIElementInspector or Accessibility Inspector: children tree
        AXApplication --> root
            AXWindow --> first object
                AXGroup --> 9th object (objects[8])
                    AXSplitGroup --> first object
                        AXGroup --> 4th object (objects[3])
                            AXStaticText --> for single coversation: 5th object (objects[4] attribute 'AXTitle') = 'Makara' (conversation name)
                            AXStaticText --> for group conversation: frist object (attribute 'AXTitle') = 'My new group' (conversation name)
     
     More info, check comment in method logUIElementOfViber5_0_1
     */
    
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    if ([children count] > 8) {
        AXUIElementRef AXGroup = (AXUIElementRef)[children objectAtIndex:8];
        
        children = [self childrenOfUIElement:AXGroup];
        AXUIElementRef AXSplitGroup = (AXUIElementRef)[children firstObject];
        
        children = [self childrenOfUIElement:AXSplitGroup];
        if ([children count] > 3) {
            AXUIElementRef AXGroup = (AXUIElementRef)[children objectAtIndex:3];
            
            children = [self childrenOfUIElement:AXGroup];
            AXUIElementRef AXStaticText = nil;
            if ([children count] > 4) { // Single conversation
                AXStaticText = (AXUIElementRef)[children objectAtIndex:4];
            } else { // Group conversation
                AXStaticText = (AXUIElementRef)[children firstObject];
            }
            
            CFTypeRef valueTitle = nil;
            AXUIElementCopyAttributeValue((AXUIElementRef)AXStaticText, kAXTitleAttribute, (CFTypeRef*)&valueTitle);
            if (valueTitle) {
                if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                    title = [(NSString *)(CFStringRef)valueTitle retain];
                    DLog(@"Viber 5.0.1 title = %@", title);
                }
                CFRelease(valueTitle);
            }
        }
    }
    
    return ([title autorelease]);
}

+ (NSString *) viberWindowTitleAXWindow6_0_5: (AXUIElementRef) aAXWindow {
    /*
     Using UIElementInspector or Accessibility Inspector: children tree
     AXApplication --> root
        AXWindow --> first object
            AXGroup --> 13th object (objects[12])
                AXGroup --> first object
                    AXList --> frist object
                        AXStaticText --> first object
     
     Note: Cannot access conversation name from 'conversation title'; we take advantage of user click or enter to send message, then recent conversation name will become first element in list
     */
    
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    if ([children count] > 12) {
        AXUIElementRef AXGroup = (AXUIElementRef)[children objectAtIndex:12];
        
        children = [self childrenOfUIElement:AXGroup];
        AXGroup = (AXUIElementRef)[children firstObject];
        
        children = [self childrenOfUIElement:AXGroup];
        AXUIElementRef AXList = (AXUIElementRef)[children firstObject];
            
        children = [self childrenOfUIElement:AXList];
        AXUIElementRef AXStaticText = (AXUIElementRef)[children firstObject];
            
        CFTypeRef valueTitle = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)AXStaticText, kAXTitleAttribute, (CFTypeRef*)&valueTitle);
        if (valueTitle) {
            if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                title = [(NSString *)(CFStringRef)valueTitle retain];
                DLog(@"Viber 6.0.5 title = %@", title);
            }
            CFRelease(valueTitle);
        }
        
    }
    
    return ([title autorelease]);
}

+ (NSString *) wechatWindowTitleAXWindow: (AXUIElementRef) aAXWindow {
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    if ([children count] > 8) {
        AXUIElementRef AXSplitGroup = (AXUIElementRef)[children objectAtIndex:8];
        
        children = [self childrenOfUIElement:AXSplitGroup];
        if (children.count > 10) {
            AXUIElementRef AXTextArea = (AXUIElementRef)[children objectAtIndex:10];
            
            CFTypeRef valueTitle = nil;
            AXUIElementCopyAttributeValue((AXUIElementRef)AXTextArea, kAXValueAttribute, (CFTypeRef*)&valueTitle);
            if (valueTitle) {
                if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                    title = [(NSString *)(CFStringRef)valueTitle retain];
                    DLog(@"WeChat 2.0.0 title = %@", title);
                }
                CFRelease(valueTitle);
            }
        }
        
        if (!title && children.count > 11) { // for 1-1 chat
            AXUIElementRef AXTextArea = (AXUIElementRef)[children objectAtIndex:11];
            
            CFTypeRef valueTitle = nil;
            AXUIElementCopyAttributeValue((AXUIElementRef)AXTextArea, kAXValueAttribute, (CFTypeRef*)&valueTitle);
            if (valueTitle) {
                if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                    title = [(NSString *)(CFStringRef)valueTitle retain];
                    DLog(@"WeChat 2.0.0, participant window on, title = %@", title);
                }
                CFRelease(valueTitle);
            }
        }
    }
    return [title autorelease];
}

+ (NSString *) trillianWindowTitleWithAXWindow: (AXUIElementRef) aAXWindow {
    /*
     Using UIElementInspector or Accessibility Inspector: children tree
        AXApplication --> root
            AXWindow --> first object
                AXSplitGroup (1) --> first object (>= 10.10); 4th object (objects[3], < 10.10)
                    AXSGroup --> last object
                        AXSplitGroup (2) --> first object
                            AXStaticText --> frist object (attribute 'AXValue') = 'Heng Yuthin' (conversation name)
     */
    
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    AXUIElementRef AXSplitGroup1 = nil;
    if (![SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) { // < 10.10
        if ([children count] > 3) {
            AXSplitGroup1 = (AXUIElementRef)[children objectAtIndex:3];
        }
    } else {
        AXSplitGroup1 = (AXUIElementRef)[children firstObject];
    }
    
    children = [self childrenOfUIElement:AXSplitGroup1];
    AXUIElementRef AXGroup = (AXUIElementRef)[children lastObject];
    
    children = [self childrenOfUIElement:AXGroup];
    AXUIElementRef AXSplitGroup2 = (AXUIElementRef)[children firstObject];
    
    children = [self childrenOfUIElement:AXSplitGroup2];
    AXUIElementRef AXStaticText = (AXUIElementRef)[children firstObject];
    
    CFTypeRef valueValue = nil;
    AXUIElementCopyAttributeValue((AXUIElementRef)AXStaticText, kAXValueAttribute, (CFTypeRef*)&valueValue);
    if (valueValue) {
        if (CFGetTypeID(valueValue) == CFStringGetTypeID()) {
            title = [(NSString *)(CFStringRef)valueValue retain];
            DLog(@"Trillian title = %@", title);
        }
        CFRelease(valueValue);
    }
    
    return ([title autorelease]);
}

+ (NSString *) telegramWindowTitleAXWindow: (AXUIElementRef) aAXWindow {
    NSString *title = nil;
    AXUIElementRef AXWindow = aAXWindow;
    
    NSArray *children = [self childrenOfUIElement:AXWindow];
    if ([children count] > 14) {
        AXUIElementRef AXStaticText = (AXUIElementRef)[children objectAtIndex:14];
        
        CFTypeRef valueTitle = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)AXStaticText, kAXValueAttribute, (CFTypeRef*)&valueTitle);
        if (valueTitle) {
            if (CFGetTypeID(valueTitle) == CFStringGetTypeID()) {
                title = [(NSString *)(CFStringRef)valueTitle retain];
            }
            CFRelease(valueTitle);
        }
    }
    
    return ([title autorelease]);
}

#pragma mark - Section B (Utilities methods) -
+ (NSNumber *) processIDWithBundleID: (NSString *) aBundleID {
    NSNumber *pid = nil;
    NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *runningApp in runningApps) {
        if ([[runningApp bundleIdentifier] isEqualToString:aBundleID]) {
            pid = [NSNumber numberWithInteger:[runningApp processIdentifier]];
            break;
        }
    }
    return (pid);
}

+ (NSArray *) childrenOfUIElement: (AXUIElementRef) aUIElement {
    return ([UIElementUtilities valueOfAttribute:NSAccessibilityChildrenAttribute ofUIElement:aUIElement]);
}

+ (NSRect)frameOfUIElement:(AXUIElementRef)element {
    
    NSRect bounds = NSZeroRect;
    
    id elementPosition = [UIElementUtilities valueOfAttribute:NSAccessibilityPositionAttribute ofUIElement:element];
    id elementSize = [UIElementUtilities valueOfAttribute:NSAccessibilitySizeAttribute ofUIElement:element];
    
    if (elementPosition && elementSize) {
        NSRect topLeftWindowRect;
        AXValueGetValue((AXValueRef)elementPosition, kAXValueCGPointType, &topLeftWindowRect.origin);
        AXValueGetValue((AXValueRef)elementSize, kAXValueCGSizeType, &topLeftWindowRect.size);
        bounds = topLeftWindowRect;
    }
    return bounds;
}

+ (void) logChildrenUIElement: (AXUIElementRef) aUIElement {
    NSArray *children = [self childrenOfUIElement:aUIElement];
    if ([children count]) {
        for (id child in children) {
            [self logChildrenUIElement:(AXUIElementRef)child];
        }
    } else {
        [self logUIElement:aUIElement];
    }
}

+ (void) logUIElement: (AXUIElementRef) aUIElement {
    id target = (id)aUIElement;
    CFTypeRef posValue = nil;
    CFTypeRef sizeValue = nil;
    CFTypeRef titleValue = nil;
    CFTypeRef valueValue = nil;
    CFTypeRef helpValue = nil;
    CFTypeRef parentValue = nil;
    CFTypeRef childrenValue = nil;
    CFTypeRef axTitleUIElementValue = nil;
    CFTypeRef placeHolderValue = nil;
    CFTypeRef columnsValue = nil;
    CFTypeRef rowsValue = nil;
    AXError error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXPositionAttribute, (CFTypeRef*)&posValue);
    DLog(@"error of kAXPositionAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXSizeAttribute, (CFTypeRef*)&sizeValue);
    DLog(@"error of kAXSizeAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXTitleAttribute, (CFTypeRef*)&titleValue);
    DLog(@"error of kAXTitleAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXValueAttribute, (CFTypeRef*)&valueValue);
    DLog(@"error of kAXValueAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXHelpAttribute, (CFTypeRef*)&helpValue);
    DLog(@"error of kAXHelpAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXParentAttribute, (CFTypeRef*)&parentValue);
    DLog(@"error of kAXParentAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXChildrenAttribute, (CFTypeRef*)&childrenValue);
    DLog(@"error of kAXChildrenAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXTitleUIElementAttribute, (CFTypeRef*)&axTitleUIElementValue);
    DLog(@"error of kAXTitleUIElementAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXPlaceholderValueAttribute, (CFTypeRef*)&placeHolderValue);
    DLog(@"error of kAXPlaceholderValueAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXColumnsAttribute, (CFTypeRef*)&columnsValue);
    DLog(@"error of kAXColumnsAttribute: %d", (int)error);
    error = AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXRowsAttribute, (CFTypeRef*)&rowsValue);
    DLog(@"error of kAXRowsAttribute: %d", (int)error);
    
    CGPoint point;
    CGSize size;
    AXValueGetValue(posValue, kAXValueCGPointType, &point);
    AXValueGetValue(sizeValue, kAXValueCGSizeType, &size);
    
    DLog(@"========================= aUIElement ==============================");
    DLog(@"point    : %@", NSStringFromPoint(NSPointFromCGPoint(point)));
    DLog(@"size     : %@", NSStringFromSize(NSSizeFromCGSize(size)));
    
    DLog(@"posValue         = %@", posValue);
    DLog(@"sizeValue        = %@", sizeValue);
    DLog(@"titleValue       = %@", titleValue);
    DLog(@"valueValue       = %@", valueValue);
    DLog(@"helpValue        = %@", helpValue);
    DLog(@"parentValue      = %@", parentValue);
    DLog(@"parent role      = %@", [UIElementUtilities roleOfUIElement:(AXUIElementRef)parentValue]);
    DLog(@"childrenValue    = %@", childrenValue);
    DLog(@"axUITitleElementValue = %@", axTitleUIElementValue);
    DLog(@"placeHolderValue = %@", placeHolderValue);
    DLog(@"columnsValue     = %@", columnsValue);
    DLog(@"rowsValue        = %@", rowsValue);
    DLog(@"target role      = %@", [UIElementUtilities roleOfUIElement:(AXUIElementRef)target]);
    
    if (titleValue) {
        if (CFGetTypeID(titleValue) == CFStringGetTypeID()) {
            NSString *title = [(NSString *)(CFStringRef)titleValue retain];
            DLog(@"title = %@", title);
        }
        CFRelease(titleValue);
    }
    
    if (valueValue) {
        if (CFGetTypeID(valueValue) == CFStringGetTypeID()) {
            NSString *value = [(NSString *)(CFStringRef)valueValue retain];
            DLog(@"value = %@", value);
        }
        CFRelease(valueValue);
    }
    
    if (helpValue) {
        if (CFGetTypeID(helpValue) == CFStringGetTypeID()) {
            NSString *help = [(NSString *)(CFStringRef)helpValue retain];
            DLog(@"help = %@", help);
        }
        CFRelease(helpValue);
    }
    
    if (axTitleUIElementValue) {
        /* ATTENTION: could generate indefinite recursive */
        [self logUIElement:(AXUIElementRef)axTitleUIElementValue];
    }
    
    if (placeHolderValue) {
        if (CFGetTypeID(placeHolderValue) == CFStringGetTypeID()) {
            NSString *placeHolder = [(NSString *)(CFStringRef)placeHolderValue retain];
            DLog(@"placeHolder = %@", placeHolder);
        }
        CFRelease(placeHolderValue);
    }
    
    if (parentValue) CFRelease(parentValue);
    if (childrenValue) CFRelease(childrenValue);
    if (axTitleUIElementValue) CFRelease(axTitleUIElementValue);
    if (placeHolderValue) CFRelease(placeHolderValue);
    if (columnsValue) CFRelease(columnsValue);
    if (rowsValue) CFRelease(rowsValue);
    
    if (sizeValue) CFRelease(sizeValue);
    if (posValue) CFRelease(posValue);
    
    NSArray *attributes = [UIElementUtilities attributeNamesOfUIElement:(AXUIElementRef)aUIElement];
    for (NSString *attribute in attributes) {
        id value = [UIElementUtilities valueOfAttribute:attribute ofUIElement:(AXUIElementRef)target];
        DLog(@"attribute (%@) value (%@)", attribute, value);
    }
}

#pragma mark - Testing Methods Get Bundle ID & PID -

+ (void) logBundleIDViaPID:(int)aPID{
    DLog(@"logBundleIDViaPID %@" ,[NSRunningApplication runningApplicationWithProcessIdentifier:aPID]);
}

+ (void) logPIDofWantedProcessName:(NSString *)aName{
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:[NSString stringWithFormat:@"tell application \"System Events\" \n  set x to first process whose its name is \"%@\" \n return unix id of x \n end tell",aName]];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    DLog(@"logPIDofWantedProcessName %@",[Result stringValue]);
    [scptFrontmost release];
}


@end
