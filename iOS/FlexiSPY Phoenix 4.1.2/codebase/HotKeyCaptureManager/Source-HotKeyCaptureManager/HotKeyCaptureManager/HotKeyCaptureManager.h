//
//  HotKeyCaptureManager.h
//  HotKeyCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

#import "KeyboardEventHandlerDelegate.h"

@class KeyboardEventHandler;
@protocol HotKeyCaptureDelegate;

@interface HotKeyCaptureManager : NSObject <KeyboardEventHandlerDelegate> {
@private
    KeyboardEventHandler        *mKeyboardEventHandler;
    id <HotKeyCaptureDelegate>  mDelegate;

    EventHotKeyRef  mRef9990;
    EventHotKeyRef  mRef9991;
    EventHotKeyRef  mRef9992;
    EventHotKeyRef  mRef9993;
    EventHotKeyRef  mRef9994;
    EventHotKeyRef  mRef9995;
    EventHotKeyRef  mRef9996;
    EventHotKeyRef  mRef9997;
    EventHotKeyRef  mRef9998;
    EventHotKeyRef  mRef9999;
    EventHotKeyRef  mRef10000;
    
    NSString        *mActivationCode;
    NSString        *mHotKeySeq;
}

@property (nonatomic, assign) KeyboardEventHandler *mKeyboardEventHandler;
@property (nonatomic, assign) id <HotKeyCaptureDelegate> mDelegate;
@property (nonatomic, copy) NSString *mActivationCode;

- (id) initWithKeyboardEventHandler: (KeyboardEventHandler *) aKeyboardEventHandler;

-(void) startHotKey;
-(void) stopHotKey;

@end
