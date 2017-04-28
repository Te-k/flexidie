//
//  KeyboardEventHandler.h
//  KeyboardEventHandler
//
//  Created by Ophat Phuetkasickonphasutha on 10/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@protocol KeyboardEventHandlerDelegate;

@interface KeyboardEventHandler : NSObject {
@private
    EventHandlerRef mEventHandlerRefKeyPress;   // Not own
    EventHandlerRef mEventHandlerRefKeyRelease; // Not own
    
    NSMutableArray  *mDelegates;
}

@property (nonatomic, readonly) NSMutableArray *mDelegates;

- (void) registerToGlobalEventHandler;
- (void) unregisterToGlobalEventHandler;

- (void) addKeyboardEventHandlerDelegate: (id <KeyboardEventHandlerDelegate>) aDelegate;
- (void) removeKeyboardEventHandlerDelegate: (id <KeyboardEventHandlerDelegate>) aDelegate;

@end
