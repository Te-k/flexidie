//
//  Facebook.h
//  MSFSP
//
//  Created by Makara Khloth on 12/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FacebookUtils.h"
#import "FacebookUtilsV2.h"
#import "FacebookVoIPUtils.h"

#import "FBMThread.h"
#import	"ThreadMessage.h"
#import "BatchThreadCreator.h"
#import "ThreadsFetcher.h"
#import "FBMRequest.h"
#import "FBThreadListController.h"
#import "FBMThreadSet.h"
#import "JKArray.h"
#import "JKDictionary.h"
#import "JKDictionaryEnumerator.h"
#import "FBAuthenticationManagerImpl.h"
#import "FBMessengerModuleAuthenticationManager.h"
#import "FBSSOLoginController.h"
#import "FBAccountStore.h"
#import "ACAccount.h"
#import "ACAccount-FBFoundation.h"
#import "MQTTMessageSender.h"
#import "FBMStickerStoragePathManager.h"

#import "FBMThreadMessagesMerger.h"
#import "FBMThreadMessagesMerger+Facebook-13-0.h"
#import "FBMLocalThreadMessagesManipulator.h"
#import "FBMLocalThreadMessagesManipulator+Facebook-13-0.h"
#import "FBMMessage.h"
#import "FBMMessage+Messenger-9-1.h"
#import "PushedThreadMessage.h"

#import "FBMAuthenticationManagerImpl.h"
#import "FBMURLRequestFormatter.h"
#import "FBMThreadSendQueue.h"

#import "FBMCachedAttachmentURLFormatter.h"
#import "FBMBaseAttachmentURLFormatter.h"

#import "FBWebRTCMessageListener.h"
#import "FBWebRTCNotificationHandler.h"
#import "FBWebRTCHandlerImpl.h"
#import "UserSet.h"
#import "UserSet+Messenger-9-1.h"
#import "FBMMQTTSender.h"
#import "FBMThreadParticipantFilter.h"
#import "FBMThreadParticipantFilter+80.h"
#import "FBWebRTCViewController.h"

// Messenger 17.0
#import "MNAuthenticationManagerImpl.h"

#pragma mark -
#pragma mark ThreadJSONParser capture Offline ThreadMessage FB V.6.3 {Obsolete}
#pragma mark -

HOOK(FBMThreadMessagesMerger, mergeNewMessages$withOldMessages$thread$, id ,id arg1, id arg2,id arg3) {
	DLog (@"-----------------------------------------------------------------------------------------")
	DLog (@"------------------------------- FBMThreadMessagesMerger -----------------------------------");
	DLog (@"-----------------------------------------------------------------------------------------")
	id returnValue = CALL_ORIG(FBMThreadMessagesMerger, mergeNewMessages$withOldMessages$thread$,arg1,arg2,arg3);	

	NSMutableIndexSet *indexOfDuplicateElement = [NSMutableIndexSet indexSet];
	NSMutableIndexSet *indexOfReadElement = [NSMutableIndexSet indexSet];
	
	NSMutableArray * newThreadMS = [(NSArray*)arg1 mutableCopy];
	NSMutableArray * oldThreadMS = [(NSArray*)arg2 mutableCopy];
	
	FBMThread * fbmThread = arg3;
	
	DLog(@"============ count before check duplicate message %lu =============",(unsigned long)[newThreadMS count]);
	
	//check duplicate message
	for(int i=0;i<[oldThreadMS count];i++){
		for(int j=0;j<[newThreadMS count];j++){
			ThreadMessage * tempNewOld = [oldThreadMS objectAtIndex:i];
			ThreadMessage * tempNewOne = [newThreadMS objectAtIndex:j];
			
			if([[NSString stringWithFormat:@"%@",[tempNewOne messageId]] isEqualToString:[NSString stringWithFormat:@"%@",[tempNewOld messageId]]]){
				DLog(@"============ Add Remove DUPLICATE MS :%@ at index %d =============",[[newThreadMS objectAtIndex:j]text],j);
				//[indexOfDuplicateElement addObject:[NSString stringWithFormat:@"%d",j]];
				[indexOfDuplicateElement addIndex:j];
			}
		}
	}
	//========================= remove duplicate message
	[newThreadMS removeObjectsAtIndexes:indexOfDuplicateElement];
	
	DLog(@"============ count after delete duplicate message %lu =============",(unsigned long)[newThreadMS count]);

	//check read message
	for (int i = 0;i<[newThreadMS count];i++){
		ThreadMessage * tempNewOne = [newThreadMS objectAtIndex:i];
		DLog (@"------------------------------------")
		DLog (@"-- text %@", [tempNewOne text])
		DLog (@">> type %d, source %d, ", [tempNewOne type], [tempNewOne source]);
        if ([tempNewOne respondsToSelector:@selector(isNonUserGeneratedLogMessage)]) {
            DLog(@"isNonUserGeneratedLogMessage %d",	[tempNewOne isNonUserGeneratedLogMessage]);
        }
		DLog (@">> tags %@", [tempNewOne tags])
		//DLog(@"============ %d class  read :%@ =============",i,[tempNewOne tags]);
		for(int k =0; k<[[tempNewOne tags]count];k++){
			if([[[tempNewOne tags]objectAtIndex:k]isEqualToString:@"read"]){
				DLog(@"============ Add Remove READ MS :%@ at index %d =============",[[newThreadMS objectAtIndex:i]text],i);
				//[indexOfReadElement addObject:[NSString stringWithFormat:@"%d",i]];
				[indexOfReadElement addIndex:i];
			}
		}
	}
	//========================= remove read message
	[newThreadMS removeObjectsAtIndexes:indexOfReadElement];
	
	DLog(@"============ count after delete read message %lu =============",(unsigned long)[newThreadMS count]);

	if([newThreadMS count]==0){
		DLog(@"=========== NoNewMessage");
	}else{
		DLog(@"=========== Only NewThreadMessage is %@",newThreadMS);

		for(int i=(int)([newThreadMS count]-1);i>=0;i--){
			[NSThread sleepForTimeInterval:0.1];
			ThreadMessage * tempNewOne = [newThreadMS objectAtIndex:i];
			FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
			if ([tempNewOne offlineThreadingId] &&  ![[tempNewOne offlineThreadingId] isEqualToString:@""] ){
				// -- Check duplication
				if (![[fbUtils mofflineThreadingId] isEqualToString:[tempNewOne offlineThreadingId]]) {
					// Since we capture attachment which cause this method call more than one time thus we use offlineThreadingId
					// to filter the same message
					[fbUtils setMofflineThreadingId:[tempNewOne offlineThreadingId]];
					[fbUtils setMMessageID:[tempNewOne messageId]];
					[FacebookUtils captureFacebookMessage:fbmThread message:tempNewOne];
				}
			}
			// Outgoing sent from other devices
			else {
				DLog (@"!!!!!!!!!!!!!! NO OFFLINE THREADING ID !!!!!!!!!!!!!!!!!!")
				// -- Check duplication
				if (![[fbUtils mMessageID] isEqualToString:[tempNewOne messageId]]) {
					[fbUtils setMMessageID:[tempNewOne messageId]];
					[FacebookUtils captureFacebookMessage:fbmThread message:tempNewOne];
				}
			}
		}
	}
	[newThreadMS release];
	[oldThreadMS release];
	
	return returnValue;
}

#pragma mark Messenger 2.7
HOOK(FBMThreadMessagesMerger, mergeNewMessages$withOldMessages$thread$threadSendQueue$addedNewMessages$, id, id arg1, id arg2, id arg3, id arg4, char *arg5) {
	DLog (@"-----------------------------------------------------------------------------------------")
	DLog (@"---------------------- FBMThreadMessagesMerger Messenger 2.7-----------------------------")
	DLog (@"-----------------------------------------------------------------------------------------")
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2)
	DLog (@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3)
	DLog (@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4)
	if (arg5) {
		DLog (@"arg5 = %s", arg5)
	}
	id retValue = CALL_ORIG(FBMThreadMessagesMerger, mergeNewMessages$withOldMessages$thread$threadSendQueue$addedNewMessages$, arg1, arg2, arg3, arg4, arg5);
	if (arg5) {
		DLog (@"arg5 = %s", arg5)
	}
	DLog (@"[retValue class] = %@, retValue = %@", [retValue class], retValue)
	
	FBMThread *thread		= arg3;	
	NSArray *oldMessages	= arg2;
	NSArray *newMessages1	= arg1;
	NSMutableArray *newMessages2 = [NSMutableArray array];
	for (ThreadMessage *newMessage in newMessages1) {
		BOOL equal = NO;
		for (ThreadMessage *oldMessage in oldMessages) {
			if ([newMessage isEquivalentToMessage:oldMessage]) {
				equal = YES;
				break;
			}
		}
		if (!equal) {
			DLog (@"------------------------------------")
			DLog (@">> tags %@", [newMessage tags])
			DLog (@"-- text %@", [newMessage text])
			DLog (@">> type %d, source %d", [newMessage type], [newMessage source]);
			if ([newMessage respondsToSelector:@selector(isNonUserGeneratedLogMessage)]) {
                DLog(@"isNonUserGeneratedLogMessage %d", [newMessage isNonUserGeneratedLogMessage])
            }
			
			BOOL unread = YES;
			for (int k = 0; k < [[newMessage tags] count]; k++) {
				if ([[[newMessage tags] objectAtIndex:k] isEqualToString:@"read"]) {
					unread = NO;
					break;
				}
			}
			
			if (unread) {
				[newMessages2 addObject:newMessage];
			}
		}
	}
	
	ThreadMessage *tMessage = nil;
	NSEnumerator *enumerator = [newMessages2 reverseObjectEnumerator];
	while (tMessage = [enumerator nextObject]) {
		// -- Check duplication ---
		FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
		if ([tMessage offlineThreadingId] != nil				&&
			![[tMessage offlineThreadingId] isEqualToString:@""]) {
			if (![[fbUtils mofflineThreadingId] isEqualToString:[tMessage offlineThreadingId]]) {
				[fbUtils setMofflineThreadingId:[tMessage offlineThreadingId]];
				[fbUtils setMMessageID:[tMessage messageId]];
				[FacebookUtils captureFacebookMessage:thread message:tMessage];
			}
		} else {
			DLog (@"############# Offline threading ID is nil or nothing ##############")
			if (![[fbUtils mMessageID] isEqualToString:[tMessage messageId]]) {
				[fbUtils setMMessageID:[tMessage messageId]];
				[FacebookUtils captureFacebookMessage:thread message:tMessage];
			}
		}
	}
	
	return retValue;
}

#pragma mark Facebook 6.7.2
HOOK(FBMThreadMessagesMerger, mergeNewMessages$withOldMessages$threadSendQueue$addedNewMessages$, id, id arg1, id arg2, id arg3, char *arg4) {
	DLog (@"-----------------------------------------------------------------------------------------")
	DLog (@"---------------------- FBMThreadMessagesMerger Facebook 6.2.x-----------------------------")
	DLog (@"-----------------------------------------------------------------------------------------")
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2)
	DLog (@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3)
	
	id retValue = CALL_ORIG(FBMThreadMessagesMerger, mergeNewMessages$withOldMessages$threadSendQueue$addedNewMessages$, arg1, arg2, arg3, arg4);
	
	if (arg4) {
		DLog (@"arg4 = %s", arg4)
	}
	DLog (@"[retValue class] = %@, retValue = %@", [retValue class], retValue)
	
	NSArray *newerMessages	= arg1;
	NSArray *olderMessages	= arg2;
	FBMThreadSendQueue *threadSendQueue = arg3;
	
	DLog (@"threadId = %@", [threadSendQueue threadId])
	
	FBMThread *thread = nil;
	object_getInstanceVariable(threadSendQueue, "_thread", (void **)&thread);
	DLog (@"Instance variable of FBMThreadSendQueue, thread = %@", thread)
	
	[FacebookUtils mergeNewerMessages:newerMessages
					withOlderMessages:olderMessages
						   intoThread:thread];
	
	return retValue;
}

#pragma mark - Facebook 13.0
HOOK(FBMThreadMessagesMerger, addFromMessagesJson$actionsJson$max$thread$threadSendQueue$, BOOL, id arg1, id arg2, int arg3, id arg4, id arg5) {
    DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2)
	DLog (@"arg3 = %d", arg3)
    DLog (@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4)
	DLog (@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5)
    
    BOOL ret = CALL_ORIG(FBMThreadMessagesMerger, addFromMessagesJson$actionsJson$max$thread$threadSendQueue$, arg1, arg2, arg3, arg4, arg5);
    DLog (@"ret = %d", ret);
    
    return ret;
}

HOOK(FBMThreadMessagesMerger, messagesFromMessagesJson$actionsJson$max$thread$, id, id arg1, id arg2, int arg3, id arg4) {
    DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2)
	DLog (@"arg3 = %d", arg3)
    DLog (@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4)
    
    id ret = CALL_ORIG(FBMThreadMessagesMerger, messagesFromMessagesJson$actionsJson$max$thread$, arg1, arg2, arg3, arg4);
    DLog (@"ret = %@", ret);
    
    unsigned long long lastSendTimestamp = [[FacebookUtilsV2 sharedFacebookUtilsV2] mLastMessageSendTimestamp];
    
    NSEnumerator *enumerator = [(NSArray *)ret reverseObjectEnumerator];
    while (FBMMessage *fbMessage = [enumerator nextObject]) {
        
        long long sendTimestamp = [fbMessage sendTimestamp];
        if ([FacebookUtilsV2 isOutgoing:fbMessage]) {
            DLog(@"Outgoing send time stamp = %lld", sendTimestamp)
            continue;
        } else {
            sendTimestamp = [FacebookUtilsV2 sendTimestamp:fbMessage];
            DLog(@"Incoming send time stamp = %lld", sendTimestamp)
        }
        
        if (sendTimestamp <= lastSendTimestamp) {
            DLog(@"{INCOMING} sendTimestamp: %lld <= lastSendTimestamp: %llu", sendTimestamp, lastSendTimestamp)
            continue;
        } else {
            BOOL capture = NO;
            FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
            
            if ([[fbMessage offlineThreadingId] length]) {
                if (![[fbUtils mofflineThreadingId] isEqualToString:[fbMessage offlineThreadingId]]) {
                    [fbUtils setMofflineThreadingId:[fbMessage offlineThreadingId]];
                    [fbUtils setMMessageID:[fbMessage messageId]];
                    capture = YES;
                }
            } else {
                if (![[fbUtils mMessageID] isEqualToString:[fbMessage messageId]]) {
                    [fbUtils setMMessageID:[fbMessage messageId]];
                    capture = YES;
                }
            }
            
            if (capture) {
                lastSendTimestamp = sendTimestamp;
                FBMThread *thread = arg4;
                if (![FacebookUtils isVoIPMessage:(ThreadMessage *)fbMessage withThread:thread]) {
                    // Facebook 13.0 (note this method is hooked only in Facebook)
                    [FacebookUtilsV2 captureFacebookIMEventWithFBThread:thread fbMessage:fbMessage];
                }
            }
        }
    }
    
    return ret;
}

#pragma mark - UserSet get all user of Messenger and Facebook -

HOOK(UserSet, initWithProviderMapData$, id, id arg1) {
    DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1)
    id ret = CALL_ORIG(UserSet, initWithProviderMapData$, arg1);
    
    [[FacebookUtilsV2 sharedFacebookUtilsV2] setMUserSet:ret];
    return ret;
}

#pragma mark -
#pragma mark FBSSOLoginController capture target account (does not work) {Not use}
#pragma mark -

HOOK(FBSSOLoginController, account, id) {
	ACAccount *account = CALL_ORIG(FBSSOLoginController, account);
	DLog (@"------------------------------- account -----------------------------------");
	DLog (@"identifier = %@", [(ACAccount *)account identifier]);
	DLog (@"accountDescription = %@", [account accountDescription]);
	DLog (@"username = %@", [(ACAccount *)account username]);
	DLog (@"------------------------------- account -----------------------------------");
	return account;
}

HOOK(FBSSOLoginController, accountStore, id) {
	FBAccountStore *accountStore = CALL_ORIG(FBSSOLoginController, accountStore);
	DLog (@"------------------------------- accountStore -----------------------------------");
	DLog (@"appID = %@", [accountStore appID]);
	DLog (@"accounts = %@", [accountStore accounts]);
	DLog (@"------------------------------- accountStore -----------------------------------");
	return accountStore;
}

#pragma mark -
#pragma mark FBMStickerStoragePathManager use to get sticker path for Messenger 5.6,...,9.1 - Facebook ...,13.0
#pragma mark -

HOOK(FBMStickerStoragePathManager, initWithProviderMapData$, id, id arg1) {
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	id result = CALL_ORIG(FBMStickerStoragePathManager, initWithProviderMapData$, arg1);
	DLog (@"[result class] = %@, result = %@", [arg1 class], result);
	
	[[FacebookUtils shareFacebookUtils] setMFBMStickerStoragePathManager:result];
	return result;
}

HOOK(FBMStickerStoragePathManager, initWithUserSettings$, id, id arg1) {
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	id result = CALL_ORIG(FBMStickerStoragePathManager, initWithUserSettings$, arg1);
	DLog (@"[result class] = %@, result = %@", [arg1 class], result);
	
	[[FacebookUtils shareFacebookUtils] setMFBMStickerStoragePathManager:result];
	return result;
}

#pragma mark -
#pragma mark FBAuthenticationManagerImpl (Messenger) capture target account {Obsolete}
#pragma mark -

HOOK (FBAuthenticationManagerImpl, initWithProviderMapData$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@", [arg1 class]);
	DLog (@"arg1 = %@", arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	FBAuthenticationManagerImpl *fbAuthenManagerImpl = CALL_ORIG(FBAuthenticationManagerImpl, initWithProviderMapData$, arg1);
	[[FacebookUtils shareFacebookUtils] setMFBAuthenManagerImpl:fbAuthenManagerImpl];
	
	DLog(@"------- FBAuthenticationManagerImpl -----------");
	DLog (@"fbAuthenManagerImpl = %@", fbAuthenManagerImpl);
	//DLog (@"meUser = %@", [fbAuthenManagerImpl meUser]); // Likely to renmae to mailboxViewer
	DLog (@"users = %@", [fbAuthenManagerImpl users]);
	DLog (@"defaults = %@", [fbAuthenManagerImpl defaults]);
	DLog(@"------- FBAuthenticationManagerImpl -----------");
	
	return fbAuthenManagerImpl;
}

HOOK (FBAuthenticationManagerImpl, initWithUsers$keychainProvider$userDefaults$, id, id arg1, id arg2, id arg3) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	DLog (@"------------------------------- argument -----------------------------------");
	FBAuthenticationManagerImpl *fbAuthenManagerImpl = CALL_ORIG(FBAuthenticationManagerImpl, initWithUsers$keychainProvider$userDefaults$, arg1, arg2, arg3);
	[[FacebookUtils shareFacebookUtils] setMFBAuthenManagerImpl:fbAuthenManagerImpl];
	
	DLog(@"------- FBAuthenticationManagerImpl -----------");
	DLog (@"fbAuthenManagerImpl = %@", fbAuthenManagerImpl);
	//DLog (@"meUser = %@", [fbAuthenManagerImpl meUser]); // Likely to renmae to mailboxViewer
	DLog (@"users = %@", [fbAuthenManagerImpl users]);
	DLog (@"defaults = %@", [fbAuthenManagerImpl defaults]);
	DLog(@"------- FBAuthenticationManagerImpl -----------");
	
	return fbAuthenManagerImpl;
}

#pragma mark -
#pragma mark FBMessengerModuleAuthenticationManager (Facebook class method) capture target account {Obsolete}
#pragma mark -

HOOK(FBMessengerModuleAuthenticationManager, authenticationManagerWithSessionStore$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	FBMessengerModuleAuthenticationManager *fbMessengerModuleAuthManager = CALL_ORIG(FBMessengerModuleAuthenticationManager, authenticationManagerWithSessionStore$, arg1);
	[[FacebookUtils shareFacebookUtils] setMFBMessengerModuleAuthManager:fbMessengerModuleAuthManager];
	
	DLog(@"------- FBMessengerModuleAuthenticationManager -----------");
	DLog (@"fbMessengerModuleAuthManager = %@", fbMessengerModuleAuthManager);
	//DLog (@"hasMeUser = %d", [fbMessengerModuleAuthManager hasMeUser]);  // There is no method of hasMeUser in 6.0 onward
	//DLog (@"meUser = %@", [fbMessengerModuleAuthManager meUser]);  // There is no method of meUser in 6.0 onward replaced by mailboxViewer
	
	// ------- For Facebook 6.0.1, 6.0.2 and assume onward --------- 
	// When debug is log for these below lines cause user loss authentication with facebook server (session store is clear) when user logout then login back
	// and result in user cannot use chat service in Facebook application (Facebook application always there is problem with internet connection)
	
	//DLog (@"hasFacebookCredentials = %d", [fbMessengerModuleAuthManager hasFacebookCredentials]);
	//DLog (@"facebookCredentials = %@", [fbMessengerModuleAuthManager facebookCredentials]);
	DLog(@"------- FBMessengerModuleAuthenticationManager -----------");
	
	return fbMessengerModuleAuthManager;
}

#pragma mark -
#pragma mark FBMAuthenticationManagerImpl to capture target account for Messenger ...,9.1 - Facebook 6.7 upward..., 13.0
#pragma mark -

HOOK(FBMAuthenticationManagerImpl, initWithProviderMapData$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	
	FBMAuthenticationManagerImpl *fbmAuthenticationManagerImpl = CALL_ORIG(FBMAuthenticationManagerImpl, initWithProviderMapData$, arg1);
	DLog (@"[fbmAuthenticationManagerImpl class] = %@, fbmAuthenticationManagerImpl = %@", [fbmAuthenticationManagerImpl class], fbmAuthenticationManagerImpl)
    [[FacebookUtils shareFacebookUtils] setMMeUserID:nil];
	[[FacebookUtils shareFacebookUtils] setMFBMAuthenticationManagerImpl:fbmAuthenticationManagerImpl];
	return (fbmAuthenticationManagerImpl);
}

HOOK(FBMAuthenticationManagerImpl, initWithApiSessionStore$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	
	FBMAuthenticationManagerImpl *fbmAuthenticationManagerImpl = CALL_ORIG(FBMAuthenticationManagerImpl, initWithApiSessionStore$, arg1);
	DLog (@"[fbmAuthenticationManagerImpl class] = %@, fbmAuthenticationManagerImpl = %@", [fbmAuthenticationManagerImpl class], fbmAuthenticationManagerImpl)
    [[FacebookUtils shareFacebookUtils] setMMeUserID:nil];
	[[FacebookUtils shareFacebookUtils] setMFBMAuthenticationManagerImpl:fbmAuthenticationManagerImpl];
	return (fbmAuthenticationManagerImpl);
}

#pragma mark - MNAuthenticationManagerImpl to capture target account for Messenger 17.0 -

HOOK(MNAuthenticationManagerImpl, initWithProviderMapData$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	
	MNAuthenticationManagerImpl *mnAuthenticationManagerImpl = CALL_ORIG(MNAuthenticationManagerImpl, initWithProviderMapData$, arg1);
	DLog (@"[mnAuthenticationManagerImpl class] = %@, mnAuthenticationManagerImpl = %@", [mnAuthenticationManagerImpl class], mnAuthenticationManagerImpl)
    [[FacebookUtils shareFacebookUtils] setMMeUserID:[mnAuthenticationManagerImpl mailboxViewerUserID]];
	[[FacebookUtilsV2 sharedFacebookUtilsV2] setMMNAuthenticationManagerImpl:mnAuthenticationManagerImpl];
	return (mnAuthenticationManagerImpl);
}

HOOK(MNAuthenticationManagerImpl, initWithApiSessionStore$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	
	MNAuthenticationManagerImpl *mnAuthenticationManagerImpl = CALL_ORIG(MNAuthenticationManagerImpl, initWithApiSessionStore$, arg1);
	DLog (@"[mnAuthenticationManagerImpl class] = %@, mnAuthenticationManagerImpl = %@", [mnAuthenticationManagerImpl class], mnAuthenticationManagerImpl)
    [[FacebookUtils shareFacebookUtils] setMMeUserID:[mnAuthenticationManagerImpl mailboxViewerUserID]];
	[[FacebookUtilsV2 sharedFacebookUtilsV2] setMMNAuthenticationManagerImpl:mnAuthenticationManagerImpl];
	return (mnAuthenticationManagerImpl);
}

#pragma mark -
#pragma mark FBMURLRequestFormatter helper to format the url (Facebook 6.7 up) {Obsolete}
#pragma mark -

HOOK(FBMURLRequestFormatter, initWithUserAgentFormatter$localeMap$apiSessionStore$, id, id arg1, id arg2, id arg3) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	DLog (@"------------------------------- argument -----------------------------------");
	
	FBMURLRequestFormatter *fbmURLRequestFormatter = CALL_ORIG(FBMURLRequestFormatter, initWithUserAgentFormatter$localeMap$apiSessionStore$, arg1, arg2, arg3);
	DLog (@"[fbmURLRequestFormatter class] = %@, fbmURLRequestFormatter = %@", [fbmURLRequestFormatter class], fbmURLRequestFormatter)
	[[FacebookUtils shareFacebookUtils] setMFBMURLRequestFormatter:fbmURLRequestFormatter];
	return (fbmURLRequestFormatter);
}

#pragma mark -
#pragma mark FBMThreadSet capture thread set {Obsolete}
#pragma mark -

HOOK(FBMThreadSet, initWithProviderMapData$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	
	FBMThreadSet *fbmThreadSet = CALL_ORIG(FBMThreadSet, initWithProviderMapData$, arg1);
	DLog (@"[fbmThreadSet class] = %@, fbmThreadSet = %@", [fbmThreadSet class], fbmThreadSet)
	[[FacebookUtils shareFacebookUtils] setMFBMThreadSet:fbmThreadSet];
	return (fbmThreadSet);
}

HOOK(FBMThreadSet, initWithThreadParticipantFilter$activeThreads$, id, id arg1, id arg2) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"------------------------------- argument -----------------------------------");
	
	FBMThreadSet *fbmThreadSet = CALL_ORIG(FBMThreadSet, initWithThreadParticipantFilter$activeThreads$, arg1, arg2);
	DLog (@"[fbmThreadSet class] = %@, fbmThreadSet = %@", [fbmThreadSet class], fbmThreadSet)
	[[FacebookUtils shareFacebookUtils] setMFBMThreadSet:fbmThreadSet];
	return (fbmThreadSet);
}

HOOK(FBMThreadSet, initWithThreadParticipantFilter$authenticationManagerProvider$, id, id arg1, id arg2) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"------------------------------- argument -----------------------------------");
	
	FBMThreadSet *fbmThreadSet = CALL_ORIG(FBMThreadSet, initWithThreadParticipantFilter$authenticationManagerProvider$, arg1, arg2);
	DLog (@"[fbmThreadSet class] = %@, fbmThreadSet = %@", [fbmThreadSet class], fbmThreadSet)
	[[FacebookUtils shareFacebookUtils] setMFBMThreadSet:fbmThreadSet];
	return (fbmThreadSet);
}

#pragma mark -
#pragma mark FBMCacheAttachmentURLFormatter capture url of audio attachment, Messenger 3.1,...9.1 - Facebook ...,13.0
#pragma mark -

HOOK(FBMCachedAttachmentURLFormatter, initWithProviderMapData$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	
	id attachmentUrlFormatter = CALL_ORIG(FBMCachedAttachmentURLFormatter, initWithProviderMapData$, arg1);
	[[FacebookUtils shareFacebookUtils] setMFBMCachedAttachmentURLFormatter:attachmentUrlFormatter];
	DLog (@"[attachmentUrlFormatter class] = %@, attachmentUrlFormatter = %@", [attachmentUrlFormatter class], attachmentUrlFormatter)
	return (attachmentUrlFormatter);
}

#pragma mark FBMBaseAttachmentURLFormatter

HOOK(FBMBaseAttachmentURLFormatter, initWithProviderMapData$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	
	id attachmentUrlFormatter = CALL_ORIG(FBMBaseAttachmentURLFormatter, initWithProviderMapData$, arg1);
	[[FacebookUtils shareFacebookUtils] setMFBMBaseAttachmentURLFormatter:attachmentUrlFormatter];
	DLog (@"[attachmentUrlFormatter class] = %@, attachmentUrlFormatter = %@", [attachmentUrlFormatter class], attachmentUrlFormatter)
	return (attachmentUrlFormatter);
}

HOOK(FBMBaseAttachmentURLFormatter, initWithUrlRequestFormatter$, id, id arg1) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"------------------------------- argument -----------------------------------");
	
	id attachmentUrlFormatter = CALL_ORIG(FBMBaseAttachmentURLFormatter, initWithUrlRequestFormatter$, arg1);
	[[FacebookUtils shareFacebookUtils] setMFBMBaseAttachmentURLFormatter:attachmentUrlFormatter];
	DLog (@"[attachmentUrlFormatter class] = %@, attachmentUrlFormatter = %@", [attachmentUrlFormatter class], attachmentUrlFormatter)
	return (attachmentUrlFormatter);
}

#pragma mark -
#pragma mark FBMThread, capture incoming/outgoing Facebook message for existing thread {Obsolete}
#pragma mark -

HOOK(FBMThread, addNewerMessage$, void, id msg) {

	DLog(@"*********** CONGRAT HOOKING FOR function: FBMThread addNewerMessage$ ************");
	CALL_ORIG(FBMThread, addNewerMessage$, msg);
	DLog (@"------------------------------- FBMThread -----------------------------------");
	DLog (@"threadId = %@", [self threadId]);
	DLog (@"name = %@", [self name]);
	DLog (@"numMessages = %d", [self numMessages]);
	DLog (@"picUrl = %@", [self picUrl]);
	DLog (@"picHash = %@", [self picHash]);
	DLog (@"------------------------------- FBMThread -----------------------------------");
	
	DLog (@"------------------------------- ThreadMessage -----------------------------------");
	DLog (@"threadId = %@", [msg threadId]);
	DLog (@"messageId = %@", [(ThreadMessage*)msg messageId]);
	DLog (@"text = %@", [msg text]);
	DLog (@"adminText = %@", [msg adminText]);
	DLog (@"offlineThreadingId = %@", [msg offlineThreadingId]);
	DLog (@"logMessage = %@", [msg logMessage]);
	DLog (@"coordinates = %@", [msg coordinates]);
	DLog (@"outgoingAttachments = %@", [msg outgoingAttachments]);
    if ([msg respondsToSelector:@selector(shareMap)]) {
        DLog (@"shareMap = %@", [msg shareMap]);
    }
	DLog (@"attachmentMap = %@", [msg attachmentMap]);
	DLog (@"tags = %@", [msg tags]);
	DLog (@"------------------------------- ThreadMessage -----------------------------------");
	
	ThreadMessage *threadMsg = msg;
	DLog (@">> type %d, source %d",
		  [(ThreadMessage*)msg type], [msg source]);
    if ([msg respondsToSelector:@selector(isNonUserGeneratedLogMessage)]) {
        DLog(@"isNonUserGeneratedLogMessage %d", [msg isNonUserGeneratedLogMessage])
    }
	DLog (@">> isSnippetMessage %d adminSnippet %@", [msg isSnippetMessage], [msg adminSnippet])
	DLog (@">> actionId %lld", [msg actionId])
	
	// CASE 1: VoIP message
	if ([FacebookUtils isVoIPMessage:threadMsg withThread:self]) {
		DLog (@"... Process Facebook VoIP message V1")
#pragma mark VOIP
		FxVoIPEvent *voIPEvent = [FacebookUtils createFacebookVoIPEventFBMThread:self
                                                                   threadMessage:threadMsg];
		DLog (@">>>> Facebook VoIP Event %@", voIPEvent);
		[FacebookUtils sendFacebookVoIPEvent:voIPEvent];
	} 
	// CASE 2: IM message
	else {
		DLog (@"... Process Facebook IM message V1")	
		
		FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
		
		if ([threadMsg offlineThreadingId]							&& 
			![[threadMsg offlineThreadingId] isEqualToString:@""]	){
			// -- Check duplication
			if (![[fbUtils mofflineThreadingId] isEqualToString:[threadMsg offlineThreadingId]]) {
				// Since we capture attachment which cause this method call more than one time thus we use offlineThreadingId
				// to filter the same message
				[fbUtils setMofflineThreadingId:[threadMsg offlineThreadingId]];
				[fbUtils setMMessageID:[threadMsg messageId]];
				
				[FacebookUtils captureFacebookMessage:self message:msg];
			}
		}
		// Outgoing sent from other devices
		else {
			DLog (@"!!!!!!!!!!!!!! NO OFFLINE THREADING ID !!!!!!!!!!!!!!!!!!")
			// -- Check duplication
			if (![[fbUtils mMessageID] isEqualToString:[threadMsg messageId]]) {
				[fbUtils setMMessageID:[threadMsg messageId]];
				[FacebookUtils captureFacebookMessage:self message:msg];
			}
		}
	}

	DLog (@"------------------------------- END add new -----------------------------------");
}

#pragma mark -
#pragma mark -
#pragma mark ******* THIS IS ACTIVE METHOD *******
#pragma mark FBMLocalThreadMessagesManipulator capture IM of Messenger 2.7,3.0.1,...,8.0,9.0,9.1,...,29.1 - Facebook 6.7,8.0,..,12.1,13.0
#pragma mark -

// Note: If user send outgoing picture/sticker this method is called and the method [MQTTMessageSender thread$didSendMessage$] is also called
// thus we need to filter by offline threading id or message id

/*************************************************************************************************************************************************************************
 KNOWN ISSUE:
        This method will be called to add old messages if application's previous launch crashes for serval times; the situation where application crashes e.g:
    with selector not found then we launch again and again, after the selector not found get fixed, then this method will get called with old messsages
    making hooking to capture duplicate events.
 *************************************************************************************************************************************************************************/

HOOK(FBMLocalThreadMessagesManipulator, addNewerMessage$toThread$, void, id arg1, id arg2) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"------------------------------- argument -----------------------------------");
	CALL_ORIG(FBMLocalThreadMessagesManipulator, addNewerMessage$toThread$, arg1, arg2);
	
	PushedThreadMessage *pushThreadMessage = arg1;
	FBMThread *thread = arg2;
	
	// -- Check duplication
	FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
	if ([pushThreadMessage offlineThreadingId] != nil				&&
		![[pushThreadMessage offlineThreadingId] isEqualToString:@""]) {
		if (![[fbUtils mofflineThreadingId] isEqualToString:[pushThreadMessage offlineThreadingId]]) {
			[fbUtils setMofflineThreadingId:[pushThreadMessage offlineThreadingId]];
			[fbUtils setMMessageID:[pushThreadMessage messageId]];
			
			// CASE 1: VoIP message
			if ([FacebookUtils isVoIPMessage:pushThreadMessage withThread:thread]) {
				DLog (@"... Process Facebook VoIP message with offline threading ID")
#pragma mark VoIP CASE 1
                
                /*
                    Capture VoIP only event in this method only
                    1) Called from Messenger application
                    2) Messenger version is equal or greater than 13.0
                    3) Incoming/Miss direction
                 */
                
                NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
                if ([identifier isEqualToString:@"com.facebook.Messenger"]          &&
                    [IMShareUtils isCurrentVersionGreaterOrEqual:@"13.0"]           &&
                    ![FacebookUtilsV2 isOutgoing:(FBMMessage *)pushThreadMessage])  {
                    
                    DLog(@"In/Miss VoIP sent from Facebook Messenger 13.0 up")
                    FxVoIPEvent *voIPEvent = [FacebookUtils createFacebookVoIPEventFBMThread:thread
                                                                               threadMessage:pushThreadMessage];
                    DLog (@">>>> Facebook VoIP Event %@", voIPEvent);
                    [FacebookUtils sendFacebookVoIPEvent:voIPEvent];
                } else {
                    DLog(@"Unexpected case: in case of Outgoing VoIP for Facebook Messenger 13.0 up, we expect to capture"
                         "VoIP via notification")
                }
			}
			// CASE 2: IM message
			else {
				if ([pushThreadMessage respondsToSelector:@selector(attachmentMap)]) {
                    [FacebookUtils captureFacebookMessage:thread message:pushThreadMessage];
                } else { // Messenger 9.0, 9.1,...,29.1 - Facebook 13.0
                    [FacebookUtilsV2 captureFacebookIMEventWithFBThread:thread fbMessage:pushThreadMessage];
                }
			}
		}
	} else {
		DLog (@"Offline threading ID is nil or nothing")
		if (![[fbUtils mMessageID] isEqualToString:[pushThreadMessage messageId]]) {
			[fbUtils setMMessageID:[pushThreadMessage messageId]];
#pragma mark VoIP CASE 2
			// CASE 1: VoIP message
			if ([FacebookUtils isVoIPMessage:pushThreadMessage withThread:thread]) {
				DLog (@"... Process Facebook VoIP message without offline threading ID")
				
                /*
                 Capture VoIP only event in this method only
                 1) Called from Messenger application
                 2) Messenger version is equal or greater than 13.0
                 3) Incoming/Miss direction
                 */
                
                NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
                
                BOOL isExpectedMessengerVersion = [IMShareUtils isCurrentVersionGreaterOrEqual:@"13.0"] || [IMShareUtils isCurrentVersionEqual:@"6.1"];
                
                if ([identifier isEqualToString:@"com.facebook.Messenger"]          &&
                    isExpectedMessengerVersion                                      &&
                    ![FacebookUtilsV2 isOutgoing:(FBMMessage *)pushThreadMessage]   ){
                    
                    DLog(@"In/Miss VoIP sent from Facebook Messenger 13.0 up or equal 6.1")
                    FxVoIPEvent *voIPEvent = [FacebookUtils createFacebookVoIPEventFBMThread:thread
                                                                               threadMessage:pushThreadMessage];
                    DLog (@">>>> Facebook VoIP Event %@", voIPEvent);
                    [FacebookUtils sendFacebookVoIPEvent:voIPEvent];
                }
                else {
                    DLog(@"Unexpected case: in case of Outgoing VoIP for Facebook Messenger 13.0 up, we expect to capture"
                         "VoIP via notification");
                }
			}
			// CASE 2: IM message
			else {
				if ([pushThreadMessage respondsToSelector:@selector(attachmentMap)]) {
                    [FacebookUtils captureFacebookMessage:thread message:pushThreadMessage];
                } else { // Messenger 9.0, 9.1 - Facebook 13.0
                    [FacebookUtilsV2 captureFacebookIMEventWithFBThread:thread fbMessage:pushThreadMessage];
                }
			}
		}
	}
}

//HOOK(FBMLocalThreadMessagesManipulator, addOlderMessage$toThread$, void, id arg1, id arg2) {
//	DLog (@"------------------------------- argument -----------------------------------");
//	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
//	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
//	DLog (@"------------------------------- argument -----------------------------------");
//	CALL_ORIG(FBMLocalThreadMessagesManipulator, addOlderMessage$toThread$, arg1, arg2);
//}

// Calling order (Messenger observation)
//	- addPush....
//	- addNewer...
//	- addNewer... return
//	- addPush... return

// Call two time for incoming from Messenger to Facebook (observation)
HOOK(FBMLocalThreadMessagesManipulator, addPushMessage$toThread$, void, id arg1, id arg2) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"------------------------------- argument -----------------------------------");
	CALL_ORIG(FBMLocalThreadMessagesManipulator, addPushMessage$toThread$, arg1, arg2);
	
	PushedThreadMessage *pushThreadMessage = arg1;
	FBMThread *thread = arg2;
	
	DLog (@"tags = %@", [pushThreadMessage tags])
	
	// -- Check duplication
	FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
	if ([pushThreadMessage offlineThreadingId] != nil				&&
		![[pushThreadMessage offlineThreadingId] isEqualToString:@""]) {
		if (![[fbUtils mofflineThreadingId] isEqualToString:[pushThreadMessage offlineThreadingId]]) {
			[fbUtils setMofflineThreadingId:[pushThreadMessage offlineThreadingId]];
			[fbUtils setMMessageID:[pushThreadMessage messageId]];
			
			// CASE 1: VoIP message
			if ([FacebookUtils isVoIPMessage:pushThreadMessage withThread:thread]) {
				DLog (@"... Process Facebook VoIP message with offline threading ID (VoIP case 1)")
#pragma mark VoIP CASE 1
                
                /* 
                    Capture VoIP only event in this method only
                    1) Called from Messenger application
                    2) Messenger version is equal or greater than 13.0
                    3) Incoming/Miss direction
                 */
                
                 NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
                if ([identifier isEqualToString:@"com.facebook.Messenger"]          &&
                    [IMShareUtils isCurrentVersionGreaterOrEqual:@"13.0"]           &&
                    ![FacebookUtilsV2 isOutgoing:(FBMMessage *)pushThreadMessage])  {
                    
                    DLog(@"In/Miss VoIP sent from Facebook Messenger 13.0 up")
                    FxVoIPEvent *voIPEvent = [FacebookUtils createFacebookVoIPEventFBMThread:thread
                                                                               threadMessage:pushThreadMessage];
                    DLog (@">>>> Facebook VoIP Event %@", voIPEvent);
                    [FacebookUtils sendFacebookVoIPEvent:voIPEvent];
                } else {
                    DLog(@"Unexpected case: in case of Outgoing VoIP for Facebook Messenger 13.0 up, we expect to capture"
                         "VoIP via notification");
                }
			}
			// CASE 2: IM message
			else {
				
				if ([pushThreadMessage respondsToSelector:@selector(attachmentMap)]) {
                    [FacebookUtils captureFacebookMessage:thread message:pushThreadMessage];
                } else { // Messenger 9.0, 9.1 - Facebook 13.0
                    [FacebookUtilsV2 captureFacebookIMEventWithFBThread:thread fbMessage:pushThreadMessage];
                }
			}
		}
	} else {
		DLog (@"Offline threading ID is nil or nothing")
		if (![[fbUtils mMessageID] isEqualToString:[pushThreadMessage messageId]]) {
			[fbUtils setMMessageID:[pushThreadMessage messageId]];
			
			// CASE 1: VoIP message
			if ([FacebookUtils isVoIPMessage:pushThreadMessage withThread:thread]) {
				DLog (@"... Process Facebook VoIP message without offline threading ID (VoIP case 2)")
#pragma mark VoIP CASE 2
                
                /*
                 Capture VoIP only event in this method only
                 1) Called from Messenger application
                 2) Messenger version is equal or greater than 13.0
                 3) Incoming/Miss direction
                 */
                
                NSString *identifier        = [[NSBundle mainBundle] bundleIdentifier];
                
                BOOL isExpectedMessengerVersion = [IMShareUtils isCurrentVersionGreaterOrEqual:@"13.0"] || [IMShareUtils isCurrentVersionEqual:@"6.1"];
                                                                                                          
                if ([identifier isEqualToString:@"com.facebook.Messenger"]          &&
                    isExpectedMessengerVersion                                      &&
                    ![FacebookUtilsV2 isOutgoing:(FBMMessage *)pushThreadMessage]   ){
                    
                    DLog(@"In/Miss VoIP sent from Facebook Messenger 13.0 up or equal 6.1")
                    FxVoIPEvent *voIPEvent = [FacebookUtils createFacebookVoIPEventFBMThread:thread
                                                                               threadMessage:pushThreadMessage];
                    DLog (@">>>> Facebook VoIP Event %@", voIPEvent);
                    [FacebookUtils sendFacebookVoIPEvent:voIPEvent];
                }
                else {
                    DLog(@"Unexpected case: in case of Outgoing VoIP for Facebook Messenger 13.0 up, we expect to capture"
                         "VoIP via notification")
                }
			}
			// CASE 2: IM message
			else {
				
				if ([pushThreadMessage respondsToSelector:@selector(attachmentMap)]) {
                    [FacebookUtils captureFacebookMessage:thread message:pushThreadMessage];
				} else { // Messenger 9.0, 9.1 - Facebook 13.0
                    [FacebookUtilsV2 captureFacebookIMEventWithFBThread:thread fbMessage:pushThreadMessage];
                }
			}
		}
	}
}

//HOOK(FBMLocalThreadMessagesManipulator, restoreMessages$forThread$, void, id arg1, id arg2) {
//	DLog (@"------------------------------- argument -----------------------------------");
//	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
//	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
//	DLog (@"------------------------------- argument -----------------------------------");
//	CALL_ORIG(FBMLocalThreadMessagesManipulator, restoreMessages$forThread$, arg1, arg2);
//}
//
//HOOK(FBMLocalThreadMessagesManipulator, setMessages$forThread$, void, id arg1, id arg2) {
//	DLog (@"------------------------------- argument -----------------------------------");
//	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
//	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
//	DLog (@"------------------------------- argument -----------------------------------");
//	CALL_ORIG(FBMLocalThreadMessagesManipulator, setMessages$forThread$, arg1, arg2);
//}
//
//HOOK(FBMLocalThreadMessagesManipulator, _addMessage$toThread$searchOption$, void, id arg1, id arg2) {
//	DLog (@"------------------------------- argument -----------------------------------");
//	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
//	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
//	DLog (@"------------------------------- argument -----------------------------------");
//	CALL_ORIG(FBMLocalThreadMessagesManipulator, _addMessage$toThread$searchOption$, arg1, arg2);
//}

#pragma mark -
#pragma mark FBWebRTCMessageListener capture VoIP Messenger 3.2.1, Facebook 7.0, 8.0 (RTC = Real Time Communication) {Obsolete}
#pragma mark -

HOOK(FBWebRTCMessageListener, onDidReceiveWebRTCMessage$, void, id arg1) {
    DLog (@"@@@@@@@@@ [arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
    CALL_ORIG(FBWebRTCMessageListener, onDidReceiveWebRTCMessage$, arg1);
    
    NSNotification *notification = arg1;
    if ([[notification name] isEqualToString:@"OrcaAppReceivedWebRTCMessage"]) {
        NSDictionary *userInfo = [notification userInfo];
        NSNumber *thirdPartyUserId = [userInfo objectForKey:@"from"];
        DLog(@"Third party user id from WebRTCMessage, %@", thirdPartyUserId);
        
        [[FacebookVoIPUtils sharedFacebookVoIPUtils] setThirdPartyUserId:[thirdPartyUserId description]];
    }
}

#pragma mark FBWebRTCNotificationHandler

HOOK(FBWebRTCNotificationHandler, didViewIncomingCall$, void, id arg1) {
    DLog (@"@@@@@@@@@ [arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
    CALL_ORIG(FBWebRTCNotificationHandler, didViewIncomingCall$, arg1);
}

HOOK(FBWebRTCNotificationHandler, didReceiveOutgoingCall$, void, id arg1) {
    DLog (@"@@@@@@@@@ [arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
    CALL_ORIG(FBWebRTCNotificationHandler, didReceiveOutgoingCall$, arg1);
    
    NSNotification *notification = arg1;
    if ([[notification name] isEqualToString:@"OrcaAppSentVOIPCall"]) {
        NSDictionary *userInfo = [notification userInfo];
        NSNumber *thirdPartyUserId = [userInfo objectForKey:@"user_id"];    // In case if user dial then disconnect immediately before onDidReceiveWebRTCMessage is called
        [[FacebookVoIPUtils sharedFacebookVoIPUtils] setMIsOutgoingCall:YES];
        [[FacebookVoIPUtils sharedFacebookVoIPUtils] setThirdPartyUserId:[thirdPartyUserId description]];
    }
}

#pragma mark FBWebTRCHandlerImpl

HOOK(FBWebRTCHandlerImpl, isInACall, BOOL) {
    BOOL ret = CALL_ORIG(FBWebRTCHandlerImpl, isInACall);
    DLog (@"isInCall, %d", ret);
    return ret;
}

HOOK(FBWebRTCHandlerImpl, callDidEnd$, void, unsigned int arg1) {
    DLog (@"@@@@@@@@@ arg1 = %d", arg1);    // call id
    
    UserSet *userSet = nil;
    object_getInstanceVariable(self, "_userSet", (void **)&userSet);
    DLog (@"@@@@@@@@@ userSet = %@", userSet);
    DLog (@"@@@@@@@@@ users = %@", [userSet users]);
    
    // There is no instance variable _userSet in Facebook 8.0 (tested)
    if (userSet == nil) {
        FBMMQTTSender *mqttSender = nil;
        object_getInstanceVariable(self, "_mqttSender", (void **)&mqttSender);
        DLog (@"@@@@@@@@@ mqttSender = %@", mqttSender);
        
        FBMThreadParticipantFilter *participantFilter = nil;
        object_getInstanceVariable(mqttSender, "_participantFilter", (void **)&participantFilter);
        DLog (@"@@@@@@@@@ participantFilter = %@", participantFilter);
        
        userSet = [participantFilter userSet];
        DLog (@"@@@@@@@@@ users = %@", [userSet users]);
    }
    
    Ivar iv	= object_getInstanceVariable(self, "_uiWrapper", NULL);
    ptrdiff_t offset		= ivar_getOffset(iv);
    FBWebRTCUIWrapper fbWebRTCUIWrapper = *(FBWebRTCUIWrapper *)((char *)self + offset);
    DLog (@"@@@@@@@@@ _field3    = %@", fbWebRTCUIWrapper._field3);     // <WebRTCLazyEngine: 0x15535fd0>
    DLog (@"@@@@@@@@@ _field4    = %@", fbWebRTCUIWrapper._field4);     // <FBMMQTTSender: 0x156e7cd0>
    DLog (@"@@@@@@@@@ _field5    = %@", fbWebRTCUIWrapper._field5);     // <UserSet: 0x156e7240>
    DLog (@"@@@@@@@@@ _field6    = %@", fbWebRTCUIWrapper._field6);     // <CFNotificationCenter 0x1569ed20 [0x3ac9bad0]>
    DLog (@"@@@@@@@@@ _field7    = %@", fbWebRTCUIWrapper._field7);     // <FBMAuthenticationManagerImpl: 0x155e1270>
    DLog (@"@@@@@@@@@ _field8    = %@", fbWebRTCUIWrapper._field8);     // <CroppedImageCache: 0x1565ae40>
    DLog (@"@@@@@@@@@ _field9    = %@", fbWebRTCUIWrapper._field9);     // <FBAnalytics: 0x1555c180>
    DLog (@"@@@@@@@@@ _field10   = %@", fbWebRTCUIWrapper._field10);    // <FBSyncStore: 0x156eabd0>
    DLog (@"@@@@@@@@@ _field11   = %@", fbWebRTCUIWrapper._field11);    // <VOIPConfigurationChecker: 0x1565d880>
    //DLog (@"@@@@@@@@@ _field12._field1   = %@", *((struct FBWebRTCLogWrapper *)(fbWebRTCUIWrapper._field12)->_field1)); // FBMGatekeeperChecker
    //DLog (@"@@@@@@@@@ _field12._field2   = %d", ((struct FBWebRTCLogWrapper *)(fbWebRTCUIWrapper._field12)->_field2));  // 0
    DLog (@"@@@@@@@@@ _field13   = %@", fbWebRTCUIWrapper._field13);    // <OrcaAppProperties: 0x156e5f60>
    DLog (@"@@@@@@@@@ _field14   = %@", fbWebRTCUIWrapper._field14);    // <UserSettings: 0x155d4820>
    //DLog (@"@@@@@@@@@ _field15._field2   = %@", ((struct FBWebRTCConfigWrapper *)(fbWebRTCUIWrapper._field15)->_field2));   // <SCNetworkReachability 0x146b9a40 [0x39705ad0]> {address = 0.0.0.0, flags = 0x00010002, if_index = 9} (crash segmentation fault 11 in Facebook 8.0)
    //DLog (@"@@@@@@@@@ _field15._field3   = %d", ((struct FBWebRTCConfigWrapper *)(fbWebRTCUIWrapper._field15)->_field3));   // 0
    //DLog (@"@@@@@@@@@ _field15._field4   = %@", ((struct FBWebRTCConfigWrapper *)(fbWebRTCUIWrapper._field15)->_field4)); // crash, segmentation fault 11
    DLog (@"@@@@@@@@@ _field16   = %@", fbWebRTCUIWrapper._field16);    // <FBProviderMapData: 0x156dd1e0>
    DLog (@"@@@@@@@@@ _field17   = %@", fbWebRTCUIWrapper._field17);    // <FBExperimentManager: 0x15659f30>
    DLog (@"@@@@@@@@@ _field18   = %c", fbWebRTCUIWrapper._field18);    // (nothing)
    
    
    // - Method 1: crash, segmentation fault 11
    //Ivar iv	= object_getInstanceVariable(self, "_messageWrapper", NULL);
    //ptrdiff_t offset		= ivar_getOffset(iv);
    //FBWebRTCMessageWrapper *fbWebRTCMessageWrapper = (FBWebRTCMessageWrapper *)((char *)self + offset);
    
    // - Method 2
    FBWebRTCMessageWrapper *fbWebRTCMessageWrapper = nil;
    object_getInstanceVariable(self, "_messageWrapper", (void **)&fbWebRTCMessageWrapper);
    if (fbWebRTCMessageWrapper != nil) {
        FBWebRTCMessageWrapper fbWebRTCMessageWrapper2 = *fbWebRTCMessageWrapper;
        DLog (@"@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@");
        //DLog (@"@@@@@@@@@ _field1    = %@", *(fbWebRTCMessageWrapper2._field1));  // crash, segmentation fault 11
        DLog (@"@@@@@@@@@ _field2    = %@", fbWebRTCMessageWrapper2._field2);       // <FBMMQTTSender: 0x156e7cd0>
        DLog (@"@@@@@@@@@ _field3    = %@", fbWebRTCMessageWrapper2._field3);       // <FBWebRTCMessageListener: 0x15536ff0>
        DLog (@"@@@@@@@@@ _field5    = %@", fbWebRTCMessageWrapper2._field5);       // 100001235909222 (alway target user id)
        DLog (@"@@@@@@@@@ _field6    = %@", fbWebRTCMessageWrapper2._field6);       // <CFNotificationCenter 0x1569ed20 [0x3ac9bad0]>
    }
    
    FBWebRTCCallMonitor *fbWebRTCCallMonitor = nil;
    object_getInstanceVariable(self, "_callMonitor", (void **)&fbWebRTCCallMonitor);
    if (fbWebRTCCallMonitor != nil) {
        DLog (@"@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@");
        //DLog (@"@@@@@@@@@ _field1    = %@", *(fbWebRTCCallMonitor->_field1)); // crash, segmentation fault 11
        DLog (@"@@@@@@@@@ _field2    = %@", fbWebRTCCallMonitor->_field2);      // <FBWebRTCHandlerImpl: 0x146ded20>
    }
    
    FacebookVoIPUtils *fbVoIPUtils = [FacebookVoIPUtils sharedFacebookVoIPUtils];
    FxVoIPEvent *event = [fbVoIPUtils VoIPEventWithUserSet:userSet];
    [FacebookUtils sendFacebookVoIPEvent:event];
    [fbVoIPUtils discardCall];
    
    DLog(@"Capture Facebook VoIP event, %@", event);
    
    CALL_ORIG(FBWebRTCHandlerImpl, callDidEnd$, arg1);
}

HOOK(FBWebRTCHandlerImpl, callDidStart$, void, unsigned int arg1) {
    DLog (@"@@@@@@@@@ --- callDidStart, arg1 = %d", arg1);
    CALL_ORIG(FBWebRTCHandlerImpl, callDidStart$, arg1);
}

#pragma mark FBWebRTCViewController get duration VoIP call

// This getCallDuration must called before [FBWebRTCHandlerImpl callDidEnd:] otherwise logic to detect missed call will break
HOOK(FBWebRTCViewController, getCallDuration, id) {
    NSNumber *duration = CALL_ORIG(FBWebRTCViewController, getCallDuration);
    DLog (@"@@@@@@@@@ --- getCallDuration, duration = %@", duration);
    FacebookVoIPUtils *fbVoIPUtils = [FacebookVoIPUtils sharedFacebookVoIPUtils];
    [fbVoIPUtils setMCallDuration:duration];
    return duration;
}

/*
HOOK(NSNotificationCenter, postNotification$, void, NSNotification *notification) {
    DLog (@"@@@@@@@@@ notification    = %@", notification);
    CALL_ORIG(NSNotificationCenter, postNotification$, notification);
}

HOOK(NSNotificationCenter, postNotificationName$object$, void, NSString *aName, id anObject) {
    DLog (@"@@@@@@@@@ aName    = %@", aName);
    DLog (@"@@@@@@@@@ anObject    = %@", anObject);
    CALL_ORIG(NSNotificationCenter, postNotificationName$object$, aName, anObject);
}

HOOK(NSNotificationCenter, postNotificationName$object$userInfo$, void, NSString *aName, id anObject, NSDictionary *aUserInfo) {
    DLog (@"@@@@@@@@@ aName    = %@", aName);
    DLog (@"@@@@@@@@@ anObject    = %@", anObject);
    DLog (@"@@@@@@@@@ aUserInfo    = %@", aUserInfo);
    CALL_ORIG(NSNotificationCenter, postNotificationName$object$userInfo$, aName, anObject, aUserInfo);
}*/

#pragma mark -
#pragma mark -
#pragma mark ******* THIS IS ACTIVE METHOD *******
#pragma mark MQTTMessageSender for capturing IM in case of bad connection, ... Messenger 8.0,9.0,9.1 - Facebook ...,12.1,13.0
#pragma mark -

//---------------------------------------------------------------------------------------------
// Alway called but callback of success would go to either
// addNewerMessage$/thread$didSendMessage$ depend on network connection bad/good (observation)
//---------------------------------------------------------------------------------------------

HOOK(MQTTMessageSender, sendMessage$thread$delegate$, void, id arg1, id arg2, id arg3) {
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	DLog (@"------------------------------- argument -----------------------------------");
	CALL_ORIG(MQTTMessageSender, sendMessage$thread$delegate$, arg1, arg2, arg3);
}

HOOK(MQTTMessageSender, thread$didSendMessage$, void, id arg1, id arg2) {
	DLog(@"*********** CONGRAT HOOKING FOR function: MQTTMessageSender thread$didSendMessage$ ************");
	DLog (@"------------------------------- argument -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"------------------------------- argument -----------------------------------");
	CALL_ORIG(MQTTMessageSender, thread$didSendMessage$, arg1, arg2);
	
	FBMThread *thread =  arg1;
	ThreadMessage *msg = arg2;
	DLog (@">> type %d", [msg type])
    if ([msg respondsToSelector:@selector(isSnippetMessage)]) {
        DLog (@">> isSnippetMessage %d", [msg isSnippetMessage])
    }
	DLog (@">> actionId %lld", [msg actionId])
	DLog (@">> adminSnippet %@", [msg adminSnippet])
	DLog (@">> logMessage %@", [msg logMessage])	
	DLog (@">> source %d", [msg source])		
	if ([msg respondsToSelector:@selector(isNonUserGeneratedLogMessage)]) {
        DLog (@">> isNonUserGeneratedLogMessage %d", [msg isNonUserGeneratedLogMessage])
    }
	
	// CASE 1: VoIP message
	if ([FacebookUtils isVoIPMessage:msg withThread:thread]) {
		DLog (@"... Process Facebook VoIP message ALTERNATIVE 2")
		
		FxVoIPEvent *voIPEvent = [FacebookUtils createFacebookVoIPEventFBMThread:thread
																			threadMessage:msg];
		DLog (@">>>> Facebook VoIP Event %@", voIPEvent);
		[FacebookUtils sendFacebookVoIPEvent:voIPEvent];
	} 
	// CASE 2: IM message
	else {
		DLog (@"... Process Facebook IM message ALTERNATIVE 2")
		FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
		if ([msg offlineThreadingId] != nil				&&
			![[msg offlineThreadingId] isEqualToString:@""]) {
			if (![[fbUtils mofflineThreadingId] isEqualToString:[msg offlineThreadingId]]) {
				[fbUtils setMofflineThreadingId:[msg offlineThreadingId]];
				[fbUtils setMMessageID:[msg messageId]];
				
				if ([msg respondsToSelector:@selector(attachmentMap)]) {
                    [FacebookUtils captureFacebookMessage:thread message:msg];
                } else { // Messenger 9.0, 9.1 - Facebook 13.0
                    [FacebookUtilsV2 captureFacebookIMEventWithFBThread:thread fbMessage:msg];
                }
			}
		} else {
			DLog (@"Offline threading ID is nill or nothing ALTERNATIVE 2")
			if (![[fbUtils mMessageID] isEqualToString:[msg messageId]]) {
				[fbUtils setMMessageID:[msg messageId]];
				
                if ([msg respondsToSelector:@selector(attachmentMap)]) {
                    [FacebookUtils captureFacebookMessage:thread message:msg];}
                else { // Messenger 9.0, 9.1 - Facebook 13.0
                    [FacebookUtilsV2 captureFacebookIMEventWithFBThread:thread fbMessage:msg];
                }
			}
		}
	}
}

#pragma mark -
#pragma mark BatchThreadCreator to capture outgoing Facebook message for newly created thread; FB Messenger 4.0, 4.1 forward message to newly created thread {Obsolete}
#pragma mark -

HOOK(BatchThreadCreator, request$didLoad$, void, id arg1, id arg2) {
	DLog(@"*********** CONGRAT HOOKING FOR function: BatchThreadCreator request$didLoad$ ************");
	/*
	 DLog (@"------------------------------- arguments -----------------------------------");
	 DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1); // FBMRequest
	 DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2); // JKArray (something JSON is get involved)
	 DLog (@"------------------------------- arguments -----------------------------------");
	 */
	CALL_ORIG(BatchThreadCreator, request$didLoad$, arg1, arg2); // To create thread with threadId from the facebook server
	
	
	// Get thread object
	FBMThread *newThread = nil;
	object_getInstanceVariable(self, "_newThread", (void **)&newThread);
	
	// Get message object (it should be only one message inside the newly created thread)
	ThreadMessage *message = nil;
	object_getInstanceVariable(self, "_message", (void **)&message);
	
	DLog (@"------------------ thread message ---------------");
	DLog (@"message = %@", message);
	DLog (@"newThread = %@", newThread);
	DLog (@"------------------ thread message ---------------");
	
    FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
    
    BOOL duplicate = YES;
    if ([[message offlineThreadingId] length] > 0) {
        if (![[fbUtils mofflineThreadingId] isEqualToString:[message offlineThreadingId]]) {
            [fbUtils setMofflineThreadingId:[message offlineThreadingId]];
            duplicate = NO;
        }
    } else if ([[message messageId] length] > 0) {
        if (![[fbUtils mMessageID] isEqualToString:[message messageId]]) {
            [fbUtils setMMessageID:[message messageId]];
            duplicate = NO;
        }
    }
    
	if (newThread && message && !duplicate) {
		Class $ThreadMessage = object_getClass(message);
		message = [$ThreadMessage messageFromMessage:message];
		[message setSendState:3]; // Because of message's _sendState is 0 thus we need to overide to 3 for 'outgoing' direction
		[FacebookUtils captureFacebookMessage:newThread message:message];
	}
}

#pragma mark -
#pragma mark ThreadsFetcher to capture incoming Facebook message for newly created thread {Obsolete}
#pragma mark -

HOOK(ThreadsFetcher, request$didLoad$, void, id arg1, id arg2) {
	DLog(@"*********** CONGRAT HOOKING FOR function: ThreadsFetcher request$didLoad$ ************");
	DLog (@"------------------------------- arguments -----------------------------------");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1); // FBMRequest
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2); // Messenger and Facebook version below 5.6 is JKArray; 5.6 up is JKDictionary (something JSON is get involved)
	DLog (@"------------------------------- arguments -----------------------------------");
	
	//	FBMRequest *fbmReq = arg1;
	
	Class $JKArray = objc_getClass("JKArray");
	Class $JKDictionary = objc_getClass("JKDictionary");
	
	id obj = nil;
	if ([arg2 isKindOfClass:$JKArray]) {
		JKArray *jka = arg2;
		if ([jka count]) {
			obj = [jka objectAtIndex:0];
		}
	}
	
	DLog (@"------------------------------- thread request -----------------------------------");
	//	DLog (@"params = %@", [fbmReq params]);
	//	DLog (@"delegate = %@", [fbmReq delegate]);
	DLog (@"[obj class] = %@,", [obj class]);
	DLog (@"obj = %@", obj);
	DLog (@"------------------------------- thread request -----------------------------------");
	
	if ([arg2 isKindOfClass:$JKArray]) { // Facebook version below 5.6 and Messenger
		JKArray *jka = arg2;
		for (JKDictionary *jkd in jka) {
			if ([[jkd objectForKey:@"name"] isEqualToString:@"threads"]) {
				JKArray *fql_result_set = [jkd objectForKey:@"fql_result_set"];
				if ([fql_result_set count]) {
					[[FacebookUtils shareFacebookUtils] setMNumFetchThread:[fql_result_set count]];
				}
				break;
			}
		}
	} else if ([arg2 isKindOfClass:$JKDictionary]) { // Facebook version 5.6 onward
		JKDictionary *jkd = arg2;
		JKArray *jka = [jkd objectForKey:@"data"];
		
		DLog (@"All keys of JKDictionary = %@", [jkd allKeys]);
		
		for (JKDictionary *jkd1 in jka) {
			if ([[jkd1 objectForKey:@"name"] isEqualToString:@"threads"]) {
				JKArray *fql_result_set = [jkd1 objectForKey:@"fql_result_set"];
				if ([fql_result_set count]) {
					[[FacebookUtils shareFacebookUtils] setMNumFetchThread:[fql_result_set count]];
				}
			}
		}
	}
	
	CALL_ORIG(ThreadsFetcher, request$didLoad$, arg1, arg2);
	
	//========================== check all thread fetch for offline thread ======================
	
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	NSString *path = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
//    path = [path stringByAppendingPathComponent:@"FacebookMID.plist"]; 
//	if ([fileManager fileExistsAtPath: path]){
//		NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
//		FBMThreadSet * threadset = nil;
//		object_getInstanceVariable(self, "_threads", (void **)&threadset);
//		
//		NSMutableDictionary * threadByUserId = [threadset threadByUserId];
//		DLog(@"***** plist %@",data);
//		
//		for (int i=0; i < [[threadByUserId allKeys]count]; i++) {
//			FBMThread * threadOfEachUser = [threadset getThreadByUserId:[[threadByUserId allKeys]objectAtIndex:i]];
//			NSArray * messagesOfEachUser = [threadOfEachUser messages];
//			
//			for(int j=0;j<[messagesOfEachUser count];j++ ){
//				BOOL found = NO;
//				ThreadMessage *  threadMessageOfEachUser = [messagesOfEachUser objectAtIndex:j];
//				for(int k=0;k<[[data allKeys]count];k++ ){
//					
//					NSString * tmpoffline =  [data objectForKey:[NSString stringWithFormat:@"%d",k]];
//					if([tmpoffline isEqualToString:[threadMessageOfEachUser offlineThreadingId]]){
//						found =YES;
//						DLog(@"*********************************** BingGo Found");
//					}
//				}
//				if(!found){
//					DLog(@"*********************************** Capture Offline Thread %@",threadMessageOfEachUser);
//					int index = 0;
//
//					NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
//
//					index = [[data objectForKey:@"currentindex"]intValue];
//					if(index == 100){
//						index = 1;
//						[data setObject:[NSString stringWithFormat:@"%d",index] forKey:@"currentindex"];
//						[data setObject:[threadMessageOfEachUser offlineThreadingId] forKey:[NSString stringWithFormat:@"%d",index]];
//						DLog(@"data: %@",data);
//						[data writeToFile: path atomically:YES];
//					}else{
//						index = index + 1;
//						[data setObject:[NSString stringWithFormat:@"%d",index] forKey:@"currentindex"];
//						[data setObject:[threadMessageOfEachUser offlineThreadingId] forKey:[NSString stringWithFormat:@"%d",index]];
//						DLog(@"data: %@",data);
//						[data writeToFile: path atomically:YES];
//					}
//					
//					[data release];
//
//					[FacebookUtils captureFacebookMessage:threadOfEachUser message:threadMessageOfEachUser];
//				}
//			}
//		}
//	
//	}
	
//	FBMThreadSet * threadset = nil;
//	object_getInstanceVariable(self, "_threads", (void **)&threadset);
//	
//	NSMutableDictionary * threadByUserId = [threadset threadByUserId];
//	//DLog(@"***** threadByUserId %@",threadByUserId);
//	
//	for (int i=0; i < [[threadByUserId allKeys]count]; i++) {
//		FBMThread * threadOfEachUser = [threadset getThreadByUserId:[[threadByUserId allKeys]objectAtIndex:i]];
//		NSArray * messagesOfEachUser = [threadOfEachUser messages];
//		DLog(@"USER %@",[[threadByUserId allKeys]objectAtIndex:i]);
//		for(int j=0;j<[messagesOfEachUser count];j++ ){
//
//			ThreadMessage *  threadMessageOfEachUser = [messagesOfEachUser objectAtIndex:j];
//			DLog(@"threadMessageOfEachUser: %@",[threadMessageOfEachUser text]);
//			DLog(@"tags : %@",[threadMessageOfEachUser tags]);
//			
//
//		}
//	}
}

#pragma mark -
#pragma mark FBThreadListController, work with request$didLoad$ above {Obsolete}
#pragma mark -

HOOK(FBThreadListController, didFetchThreads$, void, id arg1) {
	DLog(@"*********** CONGRAT HOOKING FOR function: FBThreadListController didFetchThreads ************");
	/*
	 DLog (@"------------------------------- arguments -----------------------------------");
	 DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	 DLog (@"------------------------------- arguments -----------------------------------");
	 */
	CALL_ORIG(FBThreadListController, didFetchThreads$, arg1);
	
	FBMThreadSet *threads = arg1;
	
	if ([threads numThreads] && [[FacebookUtils shareFacebookUtils] mNumFetchThread]) {
		[[FacebookUtils shareFacebookUtils] setMNumFetchThread:0];
		id unseenThreads = [threads unseenThreadsList];
		for (FBMThread *thread in unseenThreads) {
			if ([thread numMessages] == 1 && [thread unread]) { // New thread for incoming message
				ThreadMessage *msgObj = [thread newestMessage];
				if (!msgObj) msgObj = [thread newestCompleteMessage];
				DLog (@"1- msgObj = %@", msgObj);
				if (msgObj) { // Other message would send via addNewerMessage$ method
					Class $ThreadMessage = object_getClass(msgObj);
					msgObj = [$ThreadMessage messageFromMessage:msgObj];
					[msgObj setSendState:0]; // Overide send state
					DLog (@"2- msgObj = %@", msgObj);
					[FacebookUtils captureFacebookMessage:thread message:msgObj];
				}
			}
		}
	}
}

