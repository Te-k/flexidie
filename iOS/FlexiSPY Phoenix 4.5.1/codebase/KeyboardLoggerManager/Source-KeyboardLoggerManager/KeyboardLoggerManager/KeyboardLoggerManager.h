//
//  KeyboardLoggerManager.h
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 2/6/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeyboardLoggerDelegate.h"
#import "ApplicationLifeCycleDelegate.h"

@protocol KeyboardLoggerManagerDelegate;
@class KeyboardLogger, ApplicationLifeCycleNotifier, KeyboardEventHandler;

@interface KeyboardLoggerManager : NSObject <KeyboardLoggerDelegate, ApplicationLifeCycleDelegate> {
    KeyboardLogger *mKeyboardLogger;
    ApplicationLifeCycleNotifier *mALCNotifier;
    
    NSMutableArray *mObservers;
    NSMutableArray *mEmbeddedApps;
}

- (id) initWithKeyboardEventHandler: (KeyboardEventHandler *) aKeyboardEventHandler;

- (void) startKeyboardLogger;
- (void) stopKeyboardLogger;

- (void) addObserver: (id <KeyboardLoggerManagerDelegate>) aObserver;
- (void) removeObserver: (id <KeyboardLoggerManagerDelegate>) aObserver;

@end
