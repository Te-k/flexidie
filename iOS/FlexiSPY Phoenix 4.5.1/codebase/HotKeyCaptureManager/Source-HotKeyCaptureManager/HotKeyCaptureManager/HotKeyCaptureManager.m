//
//  HotKeyCaptureManager.m
//  HotKeyCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HotKeyCaptureManager.h"
#import "HotKeyCaptureDelegate.h"
#import "KeyboardEventHandler.h"

@interface HotKeyCaptureManager (private)
-(void) hotKeyCaptured;
@end

@implementation HotKeyCaptureManager

@synthesize mKeyboardEventHandler, mDelegate, mActivationCode;

- (id) initWithKeyboardEventHandler:(KeyboardEventHandler *)aKeyboardEventHandler {
    if ((self = [super init])) {
        [self setMKeyboardEventHandler:aKeyboardEventHandler];
    }
    return (self);
}

-(void) startHotKey {
    [self stopHotKey];
    
    DLog(@"registerHotKey");
    
    [[self mKeyboardEventHandler] addKeyboardEventHandlerDelegate:self];
    
    EventHotKeyID IDRef;
    IDRef.id=9990;
    RegisterEventHotKey(kVK_ANSI_0,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9990);
    IDRef.id=9991;
    RegisterEventHotKey(kVK_ANSI_1,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9991);
    IDRef.id=9992;
    RegisterEventHotKey(kVK_ANSI_2,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9992);
    IDRef.id=9993;
    RegisterEventHotKey(kVK_ANSI_3,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9993);
    IDRef.id=9994;
    RegisterEventHotKey(kVK_ANSI_4,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9994);
    IDRef.id=9995;
    RegisterEventHotKey(kVK_ANSI_5,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9995);
    IDRef.id=9996;
    RegisterEventHotKey(kVK_ANSI_6,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9996);
    IDRef.id=9997;
    RegisterEventHotKey(kVK_ANSI_7,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9997);
    IDRef.id=9998;
    RegisterEventHotKey(kVK_ANSI_8,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9998);
    IDRef.id=9999;
    RegisterEventHotKey(kVK_ANSI_9,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef9999);
    IDRef.id=10000;
    RegisterEventHotKey(kVK_ANSI_D,controlKey+cmdKey+shiftKey, IDRef,GetApplicationEventTarget(), 0, &mRef10000);
}

-(void) stopHotKey{
    DLog(@"unregisterHotKey");
    [mHotKeySeq release];
    mHotKeySeq = nil;
    
    [[self mKeyboardEventHandler] removeKeyboardEventHandlerDelegate:self];
    
    UnregisterEventHotKey(mRef9990);
    UnregisterEventHotKey(mRef9991);
    UnregisterEventHotKey(mRef9992);
    UnregisterEventHotKey(mRef9993);
    UnregisterEventHotKey(mRef9994);
    UnregisterEventHotKey(mRef9995);
    UnregisterEventHotKey(mRef9996);
    UnregisterEventHotKey(mRef9997);
    UnregisterEventHotKey(mRef9998);
    UnregisterEventHotKey(mRef9999);
    UnregisterEventHotKey(mRef10000);
}

#pragma mark Private method
#pragma mark -

-(void) hotKeyCaptured {
    if ([mDelegate respondsToSelector:@selector(hotKeyCaptured)]) {
        [mDelegate performSelector:@selector(hotKeyCaptured)];
    }
}

#pragma mark C function
#pragma mark -


- (void) keyPressCallback:(EventHandlerCallRef) aHandler eventRef:(EventRef) aEvent method:(void *)aUserData {
    DLog(@"HotKey key press call back...");
    bool shouldPost = YES;
    NSString *digit = @"";
    
    EventHotKeyID hotKeyID;
    OSStatus error = GetEventParameter(aEvent,kEventParamDirectObject,typeEventHotKeyID,NULL, sizeof(EventHotKeyID),NULL,&hotKeyID);
    DLog(@"hotKeyID.id = %d, error = %d", (unsigned int)hotKeyID.id, (int)error);
    
    int l = hotKeyID.id;
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    CGEventRef keydown = nil;
    
    switch (l) {
        case 9990:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_0, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"0";
            break;
        case 9991:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_1, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"1";
            break;
        case 9992:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_2, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"2";
            break;
        case 9993:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_3, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"3";
            break;
        case 9994:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_4, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"4";
            break;
        case 9995:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_5, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"5";
            break;
        case 9996:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_6, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"6";
            break;
        case 9997:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_7, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"7";
            break;
        case 9998:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_8, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"8";
            break;
        case 9999:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_9, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"9";
            break;
        case 10000:
            keydown = CGEventCreateKeyboardEvent(source, kVK_ANSI_D, TRUE);
            CGEventSetFlags(keydown, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            digit = @"D";
            break;
        default:
            shouldPost = NO;
            break;
    }
    
    if(shouldPost){
        ProcessSerialNumber psn;
        GetFrontProcess( &psn );
        CGEventPostToPSN(&psn, keydown);
    }
    
    if (keydown) CFRelease(keydown);
    if (source) CFRelease(source);
    
    DLog(@"digit = %@, mHotKeySeq = %@", digit, mHotKeySeq);
    if (![digit isEqualToString:@"D"]) {
        if (!mHotKeySeq) {
            mHotKeySeq = digit;
            [mHotKeySeq retain];
        } else {
            NSString *hotKeySeq = [mHotKeySeq stringByAppendingString:digit];
            
            [mHotKeySeq release];
            mHotKeySeq = hotKeySeq;
            [mHotKeySeq retain];
            
            if ([mHotKeySeq isEqualToString:mActivationCode]) {
                [self hotKeyCaptured];
                [mHotKeySeq release];
                mHotKeySeq = nil;
            } else {
                if ([mHotKeySeq length] >= [mActivationCode length]) {
                    [mHotKeySeq release];
                    mHotKeySeq = nil;
                }
            }
        }
    } else {
        [mHotKeySeq release];
        mHotKeySeq = nil;
    }
}

- (void) keyReleaseCallback:(EventHandlerCallRef) aHandler eventRef:(EventRef) aEvent method:(void *)aUserData {
    DLog(@"HotKey key release call back...");
    bool shouldPost = YES;
    
    EventHotKeyID hotKeyID;
    OSStatus error = GetEventParameter(aEvent,kEventParamDirectObject,typeEventHotKeyID,NULL, sizeof(EventHotKeyID),NULL,&hotKeyID);
    DLog(@"hotKeyID.id = %d, error = %d", (unsigned int)hotKeyID.id, (int)error);
    
    int l = hotKeyID.id;
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    CGEventRef keyup = nil;
    
    switch (l) {
        case 9990:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_0, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 9991:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_1, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 9992:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_2, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 9993:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_3, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 9994:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_4, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 9995:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_5, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 9996:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_6, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 9997:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_7, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 9998:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_8, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 9999:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_9, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        case 10000:
            keyup = CGEventCreateKeyboardEvent(source, kVK_ANSI_D, FALSE);
            CGEventSetFlags(keyup, kCGEventFlagMaskCommand+kCGEventFlagMaskControl+kCGEventFlagMaskShift);
            break;
        default:
             shouldPost = NO;
            break;
    }
    
    if (shouldPost) {
        ProcessSerialNumber psn;
        GetFrontProcess( &psn );
        CGEventPostToPSN(&psn, keyup);
    }
    
    if (keyup) CFRelease(keyup);
    if (source) CFRelease(source);
}

- (void)dealloc {
    [mActivationCode release];
    [self stopHotKey];
    [super dealloc];
}
@end
