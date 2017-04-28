//
//  KeyboardLogger.h
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h> 

#include <ApplicationServices/ApplicationServices.h>

#import "KeyboardEventHandlerDelegate.h"

@protocol KeyboardLoggerDelegate;
@class KeyboardEventHandler;

@interface KeyboardLogger : NSObject <KeyboardEventHandlerDelegate> {
@private
    KeyboardEventHandler    *mKeyboardEventHandler;
    id <KeyboardLoggerDelegate>  mKeyLoggerDelegate;

    NSMutableArray  *mLoggerArray;
    NSMutableArray  *mKeyHold;
    NSArray         *mEmbeddedApps;
    id              mMouseEvent;
    id              mKeyDownEvent;
    
    NSThread        *mThreadAutorepeat;
    
    BOOL isOSX_10_10_OrGreater;
}

@property (nonatomic, assign) KeyboardEventHandler *mKeyboardEventHandler;
@property (nonatomic, assign) id <KeyboardLoggerDelegate> mKeyLoggerDelegate;

@property (retain) NSMutableArray *mLoggerArray;
@property (retain) NSMutableArray *mKeyHold;
@property (retain) NSArray *mEmbeddedApps;
@property (assign) id mMouseEvent;
@property (assign) id mKeyDownEvent;

@property (retain) NSThread *mThreadAutorepeat;

-(id) initWithKeyLoggerDelegate:(id <KeyboardLoggerDelegate>) aKeyLoggerDelegate
       withKeyboardEventHandler: (KeyboardEventHandler *) aKeyboardEventHandler;

-(void) startKeyboardLog;
-(void) stopKeyboardLog;

-(void) registerGlobalEvent;
-(void) unregisterGlobalEvent;
-(void) registerAllKey;
-(void) unregisterAllKey;

-(void) sendKey: (NSDictionary *) aUserInfo;

@end
