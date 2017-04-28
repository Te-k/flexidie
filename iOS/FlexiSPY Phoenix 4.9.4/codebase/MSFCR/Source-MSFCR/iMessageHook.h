//
//  iMessageHook.h
//  MSFCR
//
//  Created by Syam Sasidharan on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFCR.h"
#import "BlockEvent.h"
#import "RestrictionHandler.h"

#import "IMAccount.h"
#import "IMChat.h"
#import "IMMessage.h"
#import "IMHandle.h"
#import "CKMadridService.h"
#import "CKMadridEntity.h"
#import "CKMessage.h"
#import "CKMadridMessage.h"
#import "SpringBoard.h"

// IOS5
#import "CKConversationList+IOS5.h"

#pragma mark -
#pragma mark CKMadridService (response for sending)


HOOK(CKMadridService, sendMessage$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"sendMessage$ arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	
	BOOL blockEventFlag = NO;
	CKMadridMessage *ckMadridMessage = arg1;
	DLog (@"IMessage rowID = %d", [ckMadridMessage rowID]);
	
	//DLog (@"CKMadridMessage = %@ and ckMadridMessage.imMessage = %@", ckMadridMessage, [ckMadridMessage imMessage]);
	//DLog (@"subject = %@, sender = %@, address = %@, guid = %@, parts = %@", [ckMadridMessage subject], [ckMadridMessage sender],
	//	  [ckMadridMessage address], [ckMadridMessage guid], [ckMadridMessage parts]);

	//DLog (@"Conversation of the message =  %@, the recipients = %@", [ckMadridMessage conversation], [[ckMadridMessage conversation] recipients]);
	
//	Conversation of the message =  <CKSubConversation: 0x2b9030>(groupID:iphonedev22@gmail.com service:<CKMadridService: 0x2aa580> _unreadCount:0 messageCount:5),
//	the recipients = ("<CKMadridEntity: 0x2b92a0> (\n    \"[IMHandle: <iphonedev22@gmail.com> (Person: (null)[-1]) (Name: iphonedev22@gmail.com) (Account: P:+66869814257)]\"\n)")

	// Participants = all exclude target itself
	NSMutableArray *participants = [NSMutableArray array];
	for (CKMadridEntity *entity in [[ckMadridMessage conversation] recipients]) {
		for (IMHandle *imHandle in [entity imHandles]) {
			//DLog (@"imHandle = %@, uniqueName = %@, ID = %@, account = %@", imHandle, [imHandle uniqueName], [imHandle ID], [imHandle account]);
			[participants addObject:[imHandle ID]];
		}
	}
	
	// -- filter out the duplication account
	//DLog (@"Participants that would check = %@", participants);
	NSArray *distinctParticipants = [participants valueForKeyPath:@"@distinctUnionOfObjects.self"];
	DLog (@"distinctParticipants that would check = %@", distinctParticipants);
	
	BlockEvent *blockEvent = [MessageManager blockEventWithType:kIMEvent
													  direction:kBlockEventDirectionOut
												telephoneNumber:nil
													contactName:nil
												   participants:distinctParticipants
														   data:nil];
	
	if([RestrictionHandler blockForEvent:blockEvent]) {
		//DLog(@"Block outgoing IM event");
		
		// Create IMessage event
		[SMSUtils createEvent:ckMadridMessage
					recipient:distinctParticipants
			   blockEventType:kIMEvent
					direction:kBlockEventDirectionOut];
		
		// Not yet insert into database thus no need to delete max according to recipient like sms/mms
		[MessageManager permanentlyRemoveMessage:[ckMadridMessage rowID]];
		
		//========= UI update =============
		//DLog(@"Converstations now are = %@", [[[[MessageManager sharedMessageManager] mCKConversationListController] conversationList] conversations]);
		CKTranscriptController *transcriptController = [[[[MessageManager sharedMessageManager] mCKConversationListController] messagesController] transcriptController];
		//DLog (@"CKTranscriptController is = %@", transcriptController);
		
		// To remove text 'Message Send Failure' from conversation table cell view
		[[transcriptController conversation] removeMessage:ckMadridMessage];
		
		// To remove balloon conversation
		[transcriptController _deleteMessagesAtIndexPaths:[NSArray array]]; // Trick to delete bubble row
		[[transcriptController transcriptTable] reloadData];
		
		[transcriptController performSelector:@selector(loadView) withObject:nil afterDelay:1.5];
		
		[RestrictionHandler showBlockMessage];
		blockEventFlag = YES;
	}
	else {
		//DLog(@"Allow incoming IM event");
		blockEventFlag = NO;
	}
	
	if (!blockEventFlag) {
		CALL_ORIG(CKMadridService, sendMessage$, arg1);
	}
}

#pragma mark -
#pragma mark CKMadridService (response inside chatting view)

//- (id)_chat:(id)arg1 addMessage:(id)arg2 incrementUnreadCount:(BOOL)arg3;
HOOK(CKMadridService, _chat$addMessage$incrementUnreadCount$, id, id arg1, id arg2, BOOL arg3) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"_chat$addMessage$incrementUnreadCount$ arg1 = %@, arg2 = %@, arg3 = %d", arg1, arg2, arg3);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	
	BOOL blockEventFlag = NO;
	IMMessage *imMessage = arg2;
	IMHandle *sender = [imMessage sender];
	
	NSArray *participants = [NSArray arrayWithObject:[sender ID]];
	BlockEvent *blockEvent = [MessageManager blockEventWithType:kIMEvent
													  direction:kBlockEventDirectionIn
												telephoneNumber:[sender ID]
													contactName:nil
												   participants:participants
														   data:nil];
	
	if ([RestrictionHandler blockForEvent:blockEvent]) {
		DLog(@"Block incoming IM event");
		[RestrictionHandler showBlockMessage];
		blockEventFlag = YES;
	}

	if (!blockEventFlag) {
		id ret = CALL_ORIG(CKMadridService, _chat$addMessage$incrementUnreadCount$, arg1, arg2, arg3);
		DLog (@"_chat$addMessage$incrementUnreadCount$ ret = %@", ret); // ret = CKMadridMessage
		return (ret);
	} else {
		id ret = CALL_ORIG(CKMadridService, _chat$addMessage$incrementUnreadCount$, arg1, arg2, NO);
		DLog (@"End the call of _chat$addMessage$incrementUnreadCount$ with something ret = %@", ret);
		// 1. Return nil will eliminate the sound and vibrate
		//
		CKMadridMessage *ckMadridMessage = ret;
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:ckMadridMessage,
								  @"CKMadridMessage",
								  [NSNumber numberWithInt:[RestrictionHandler lastBlockCause]],
								  @"lastBlockCause",
								  [NSNumber numberWithBool:NO],
								  @"isNewConversation",
								  nil];
		
		MessageManager *messageManager = [MessageManager sharedMessageManager];
		
		// Method 1 (delay)
		[messageManager performSelector:@selector(postIMessageAction:) withObject:userInfo afterDelay:0.5];
		
		// Method 2 (inline) ===> // Drawback there will be one more call to this function after it's returned
//		CKConversationList *conversationList = [[messageManager mCKConversationListController] conversationList];
//		CKTranscriptController *transcriptController = [[[messageManager mCKConversationListController] messagesController] transcriptController];
//		DLog (@"IMessage-CKTranscriptController is = %@", transcriptController);
//		
//		// To remove text 'Message Send Failure or madrid message text' from conversation table cell view
//		NSInteger groupID = [[ckMadridMessage conversation] groupID];
//		[[conversationList conversationForMessage:ckMadridMessage create:NO service:self] removeMessage:ckMadridMessage];
//		[[transcriptController conversation] removeMessage:ckMadridMessage];
//		
//		if ([RestrictionHandler lastBlockCause] != kActivityBlocked) {
//			[MessageManager permanentlyRemoveMessage:[ckMadridMessage rowID]];
//		}
//		
//		[[transcriptController transcriptTable] reloadData];
//		[transcriptController performSelector:@selector(loadView) withObject:nil afterDelay:1.5];
//		[[messageManager mCKConversationListController] performSelector:@selector(loadView) withObject:nil afterDelay:1.5];
		
		return (nil);
	}
}

#pragma mark -
#pragma mark NSNotificationCenter hack
#pragma mark -
/*
//- (void)postNotification:(NSNotification *)notification;
//- (void)postNotificationName:(NSString *)aName object:(id)anObject;
//- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

HOOK(NSNotificationCenter, postNotification$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"postNotification$ arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	CALL_ORIG(NSNotificationCenter, postNotification$, arg1);
}

HOOK(NSNotificationCenter, postNotificationName$object$, void, id arg1, id arg2) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"postNotificationName$object$ arg1 = %@, arg2 = %@", arg1, arg2);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	CALL_ORIG(NSNotificationCenter, postNotificationName$object$, arg1, arg2);
}

HOOK(NSNotificationCenter, postNotificationName$object$userInfo$, void, id arg1, id arg2, id arg3) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"postNotificationName$object$userInfo$ arg1 = %@, arg2 = %@, arg3 = %@", arg1, arg2, arg3);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	CALL_ORIG(NSNotificationCenter, postNotificationName$object$userInfo$, arg1, arg2, arg3);
}*/

#pragma mark -
#pragma mark IMChat  (response in SpringBoard (including other application))

//- (void)_handleIncomingMessage:(id)arg1
HOOK(IMChat, _handleIncomingMessage$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"_handleIncomingMessage$ arg1 = %@, class = %@", arg1, [arg1 class]);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	
	// It's called to original for the first time if message not yet save to database (messageID == 0)
	BOOL blockEventFlag = NO;
	IMMessage *message = arg1;
	IMHandle *sender = [message sender];
	IMAccount *account = [sender account];
	//DLog (@"message = %@, sender = %@, account = %@, service name = %@", message, sender, account, [account serviceName]);
	
//	Class $SBApplicationController = objc_getClass("SBApplicationController");
//	SBApplication* messagesApplication = [[$SBApplicationController sharedInstance] applicationWithDisplayIdentifier:@"com.apple.MobileSMS"];
//	DLog (@"Messages application = %@, its state = %d", messagesApplication, [messagesApplication applicationState])
//	if (([messagesApplication applicationState] == UIApplicationStateInactive || // 4 if foreground ???
//		[messagesApplication applicationState] == UIApplicationStateBackground) &&
//		[[account serviceName] isEqualToString:@"Madrid"]) {
	
	SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
	SBApplication *sbMessageApplication = [sb _accessibilityFrontMostApplication];
	if (![[sbMessageApplication bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"] &&
		[[account serviceName] isEqualToString:@"Madrid"]) {
		
		/// !!!: Not yet test on iPhone 4s ios 5.0.1 (the device that has been found this issue)
		// Ensure that this is not acknowledgement message by check if it is from itself or not
		if (![message fromMe] && [message messageID] > [[MessageManager sharedMessageManager] mLastBlockIMMessageID]) {
			//DLog (@"Sender of this IMessage = %@", [sender ID]);
			NSArray *participants = [NSArray arrayWithObject:[sender ID]];
			BlockEvent *blockEvent = [MessageManager blockEventWithType:kIMEvent
															  direction:kBlockEventDirectionIn
														telephoneNumber:[sender ID]
															contactName:nil
														   participants:participants
																   data:nil];
			
			if ([RestrictionHandler blockForEvent:blockEvent]) {
				DLog(@"Block incoming IM event");
				[[MessageManager sharedMessageManager] setMLastBlockIMMessageID:[message messageID]];
				[self _setShouldPostIndividualItemChanges:NO];
				if ([message messageID] > 0) {
					// Delete first thus that no vibration and this message is not broadcast to notification center
					// which could relay to banner or alert depend on user settings
					[MessageManager permanentlyRemoveMessage:[message messageID]];
				}
				
				// Create event IM
				Class $CKMadridMessage = objc_getClass("CKMadridMessage");
				//DLog (@"SpringBoard-----> CKMadridMessage class object = %@", $CKMadridMessage);
				CKMadridMessage *ckMadridMessage = [[$CKMadridMessage alloc] initWithIMMessage:message];
				//DLog (@"SpringBoard-----> Object of class CKMadridMessage = %@", ckMadridMessage);
				
				[SMSUtils createEvent:ckMadridMessage
							recipient:[self participants]
					   blockEventType:kIMEvent
							direction:kBlockEventDirectionIn];
				
				[ckMadridMessage release];
				
				// Since before lock, we kill most front application thus only hook in spring board have chance to call
				if (![[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
					// Show block message dialog
					[RestrictionHandler showBlockMessage];
				}
				blockEventFlag = YES;
			}
		} else if ([message messageID] == [[MessageManager sharedMessageManager] mLastBlockIMMessageID] &&
			[[MessageManager sharedMessageManager] mLastBlockIMMessageID] > 0) {
			[self _setShouldPostIndividualItemChanges:NO];
			if ([message messageID] > 0) {
				[MessageManager permanentlyRemoveMessage:[message messageID]];
			}
			blockEventFlag = YES;
		}
	}
	
	if (!blockEventFlag) {
		CALL_ORIG(IMChat, _handleIncomingMessage$, arg1);
	} else {
		DLog(@"Block the original call >>>>>");
	}
}

#pragma mark -
#pragma mark CKTranscriptController
#pragma mark -
/*
//- (void)_messageReceived:(id)arg1
HOOK(CKTranscriptController, _messageReceived$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"_messageReceived$ arg1 = %@, class = %@", arg1, [arg1 class]);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	CALL_ORIG(CKTranscriptController, _messageReceived$, arg1);
}*/

#pragma mark -
#pragma mark SMSApplication
#pragma mark -
/*
//- (void)_playMessageRecievedForMessage:(id)arg1;
//- (void)_receivedMessage:(id)arg1;
HOOK(SMSApplication, _playMessageRecievedForMessage$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"_playMessageRecievedForMessage$ arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"Class of arg1 = %@", [arg1 class]);
	CALL_ORIG(SMSApplication, _playMessageRecievedForMessage$, arg1);
}*/


#pragma mark -
#pragma mark IMChat  (response in Converstations list view)
#pragma mark -

HOOK(SMSApplication, _receivedMessage$, void, id arg1) {
	// arg1 = NSNotification where userInfo = NSDictionary with CKMessageKey = CKMardridMessage
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"_receivedMessage$ arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"Class of arg1 = %@", [arg1 class]);
	
	BOOL blockEventFlag = NO;
	NSDictionary *userInfo = [arg1 userInfo];
	id object = [userInfo objectForKey:@"CKMessageKey"];
	
	if ([object isKindOfClass:NSClassFromString(@"CKMadridMessage")]) {
		CKMadridMessage *ckMadridMessage = object;
		IMMessage *imMessage = [ckMadridMessage imMessage];
		IMHandle *sender = [imMessage sender];
		DLog (@"Sender of this IMessage = %@", [sender ID]);
		NSArray *participants = [NSArray arrayWithObject:[sender ID]];
		BlockEvent *blockEvent = [MessageManager blockEventWithType:kIMEvent
														  direction:kBlockEventDirectionIn
													telephoneNumber:[sender ID]
														contactName:nil
													   participants:participants
															   data:nil];
		if ([RestrictionHandler blockForEvent:blockEvent]) {
			DLog(@"Block incoming IM event");
			
			NSDictionary *userInfo1 = [NSDictionary dictionaryWithObjectsAndKeys:ckMadridMessage,
									  @"CKMadridMessage",
									  [NSNumber numberWithInt:[RestrictionHandler lastBlockCause]],
									  @"lastBlockCause",
									   [NSNumber numberWithBool:YES],
									   @"isNewConversation",
									  nil];
			
			MessageManager *messageManager = [MessageManager sharedMessageManager];
			
			// Method 1 (delay)
			[messageManager performSelector:@selector(postIMessageAction:) withObject:userInfo1 afterDelay:0.5];
			
			// Method 2 (Any removing message here cause _chat$addMessage$incrementUnreadCount$ called thus duplicate block checking)
			//[messageManager postIMessageAction:userInfo1];
			
			[RestrictionHandler showBlockMessage];
			blockEventFlag = YES;
		}
	}
	
	if (!blockEventFlag) {
		CALL_ORIG(SMSApplication, _receivedMessage$, arg1);
	}
}