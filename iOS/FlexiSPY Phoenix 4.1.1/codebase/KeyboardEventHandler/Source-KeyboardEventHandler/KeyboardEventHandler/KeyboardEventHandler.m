//
//  KeyboardEventHandler.m
//  KeyboardEventHandler
//
//  Created by Ophat Phuetkasickonphasutha on 10/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyboardEventHandler.h"
#import "KeyboardEventHandlerDelegate.h"


OSStatus globalEventPress(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData);
OSStatus globalEventRelease(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData);

@implementation KeyboardEventHandler

@synthesize mDelegates;

- (id)init
{
    self = [super init];
    if (self) {
        mDelegates = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) registerToGlobalEventHandler{
  
    EventTypeSpec eventTypeP;
    eventTypeP.eventClass=kEventClassKeyboard;
    eventTypeP.eventKind=kEventHotKeyPressed;
    
    EventTypeSpec eventTypeR;
    eventTypeR.eventClass=kEventClassKeyboard;
    eventTypeR.eventKind=kEventHotKeyReleased;
    
    InstallApplicationEventHandler(&globalEventPress,1,&eventTypeP,(void *)self,&mEventHandlerRefKeyPress);
    InstallApplicationEventHandler(&globalEventRelease,1,&eventTypeR,(void *)self,&mEventHandlerRefKeyRelease);
}

- (void) unregisterToGlobalEventHandler {
    RemoveEventHandler(mEventHandlerRefKeyPress);
    RemoveEventHandler(mEventHandlerRefKeyRelease);
}

- (void) addKeyboardEventHandlerDelegate: (id <KeyboardEventHandlerDelegate>) aDelegate {
    [mDelegates addObject:aDelegate];
}

- (void) removeKeyboardEventHandlerDelegate: (id <KeyboardEventHandlerDelegate>) aDelegate {
    for (id <KeyboardEventHandlerDelegate> delegate in mDelegates) {
        if (delegate == aDelegate) {
            [mDelegates removeObject:delegate];
            break;
        }
    }
}

OSStatus globalEventPress(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData){
    KeyboardEventHandler *mySelf = (KeyboardEventHandler *)userData;
    for (id <KeyboardEventHandlerDelegate> delegate in [mySelf mDelegates]) {
        if ([delegate respondsToSelector:@selector(keyPressCallback:eventRef:method:)]) {
            [delegate keyPressCallback:nextHandler eventRef:theEvent method:userData];
        }
    }
    
    return noErr;
}

OSStatus globalEventRelease(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData){
    KeyboardEventHandler *mySelf = (KeyboardEventHandler *)userData;
    for (id <KeyboardEventHandlerDelegate> delegate in [mySelf mDelegates]) {
        if ([delegate respondsToSelector:@selector(keyPressCallback:eventRef:method:)]) {
            [delegate keyReleaseCallback:nextHandler eventRef:theEvent method:userData];
        }
    }
    
    return noErr;
}


- (void)dealloc
{
    [mDelegates release];
    [self unregisterToGlobalEventHandler];
    [super dealloc];
}

@end
