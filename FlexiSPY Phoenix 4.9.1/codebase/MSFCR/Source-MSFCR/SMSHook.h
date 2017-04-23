//
//  SMSHook.h
//  MSFCR
//
//  Created by Makara Khloth on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIKit.h>

#import "MSFCR.h"
#import "SMSUtils.h"
#import "RestrictionHandler.h"
#import "BlockEvent.h"
#import "ConversationListUtils.h"
#import "MessageManager.h"
#import "SMSUtils.h"
#import "DeviceLockManagerUtils.h"
#import "AlertLockStatus.h"

#import "CKService.h"
#import "CKSMSService.h"
#import "CKSMSMessage.h"
#import "CKMessagePart.h"
#import "CKConversationListController.h"
#import "CKConversationList.h"
#import "CKConversation.h"
#import "CKSMSEntity.h"

#import "CKTranscriptController.h"
#import "CKTranscriptTableView.h"
#import "CKTranscriptBubbleData.h"
#import "CKConversationSearcher.h"
#import "CKConversationListCell.h"
#import "CKMessageCell.h"
#import "CKBalloonView.h"

#import "SMSApplication.h"
#import "SBSMSManager.h"

// IOS 5
#import "CKConversationListController+IOS5.h"
#import "CKMessagesController.h"
#import "CKTranscriptController+IOS5.h"
#import "CKSMSService+IOS5.h"
#import "CKSMSMessage+IOS5.h"

#import "SMSPluginManager.h"
#import "SBPluginManager.h"
#import "SBApplicationController.h"
#import "SBApplication.h"
#import "SpringBoard.h"

#pragma mark -
#pragma mark CKConversationListController
#pragma mark -
/*
//- (id)searcherContentsController:(id)arg1;
//- (id)searcher:(id)arg1 conversationForGroupRowID:(int)arg2;
//- (void)searcher:(id)arg1 userDidSelectConversationGroupID:(int)arg2 messageRowID:(int)arg3 partRowID:(int)arg4;

HOOK(CKConversationListController, searcherContentsController$, id, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"searcherContentsController$ arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	id ret = CALL_ORIG(CKConversationListController, searcherContentsController$, arg1);
	DLog(@"searcherContentsController$ ret = %@", ret);
	return (ret);
}

HOOK(CKConversationListController, searcher$conversationForGroupRowID$, id, id arg1, int arg2) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"searcher$conversationForGroupRowID$ arg1 = %@, arg2 = %d", arg1, arg2); // arg1 = CKConversationSearcher, arg2 = GroupRowID as integer e.g: 45, 51,... 
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	
	id ret = CALL_ORIG(CKConversationListController, searcher$conversationForGroupRowID$, arg1, arg2); // ret = CKConversation
	DLog(@"searcher$conversationForGroupRowID$ ret = %@", ret);
	
//	if ([ConversationListUtils isBlockConversation:ret] && // Not scalable
//		[ConversationListUtils conversationBlockCause] == kActivityBlocked) { // Two slow when there are more conversation
	
	// No need to check if already filter since search can only happen when filter is completed
	if ([[MessageManager sharedMessageManager] isGroupIDBlocked:arg2]) {
		
		[[[self conversationList] conversations] removeObject:ret];
		
		ret = nil;
		
		// To prevent crash of array out of bound
		UITableView *table = nil;
		object_getInstanceVariable(self, "_table", (void **)&table);
		DLog(@"Instance variable _table of self = %@", table);
		[table reloadData];
	}
	
	return (ret);
}

HOOK(CKConversationListController, searcher$userDidSelectConversationGroupID$messageRowID$partRowID$, void, id arg1, int arg2, int arg3, int arg4) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"searcher$userDidSelectConversationGroupID$messageRowID$partRowID$ arg1 = %@, arg2 = %d, arg3 = %d, arg4 = %d", arg1, arg2, arg3, arg4);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	CALL_ORIG(CKConversationListController, searcher$userDidSelectConversationGroupID$messageRowID$partRowID$, arg1, arg2, arg3, arg4);
}

//- (int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2;
HOOK(CKConversationListController, tableView$numberOfRowsInSection$, int, id arg1, int arg2) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"tableView$numberOfRowsInSection$ arg1 = %@, arg2 = %d", arg1, arg2);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	CKConversationList *conversationList = [self conversationList]; // To call the hook version of conversationList property
	int numberOfRowsInSection = [[conversationList conversations] count];
	DLog(@"tableView$numberOfRowsInSection$ numberOfRowsInSection = %d", numberOfRowsInSection);
	return (numberOfRowsInSection);
}

//@property(nonatomic) CKConversationList *conversationList;
HOOK(CKConversationListController, conversationList, id) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"conversationList");
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	id conversationList = CALL_ORIG(CKConversationListController, conversationList);
	if ([SMSUtils isIOS4]) {
		if (![[MessageManager sharedMessageManager] mIsCompletedFilter]) {
			[ConversationListUtils dumpBlockConversation:[conversationList conversations]	groupIDs:nil];
			[[MessageManager sharedMessageManager] setMIsCompletedFilter:YES];
		} else {
			[[MessageManager sharedMessageManager] filterBlockConversation:[conversationList conversations]
																  groupIDs:nil];
		}
	} else if ([SMSUtils isIOS5]) { // Scalability since always the same conversation list
		if (![[MessageManager sharedMessageManager] mIsCompletedFilter]) {
			[ConversationListUtils dumpBlockConversation:[conversationList conversations]	groupIDs:nil];
			[[MessageManager sharedMessageManager] setMIsCompletedFilter:YES];
		}
	}
	return (conversationList);
}*/

// IOS 4.2.1
HOOK(CKConversationListController, initWithNavigationController$service$, id, id arg1, id arg2) {
	id ret = CALL_ORIG(CKConversationListController, initWithNavigationController$service$, arg1, arg2);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"initWithNavigationController$service$ ret = %@, arg1 = %@, arg2 = %@", ret, arg1, arg2);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	// This log cause blocked list of conversation in MessageManager is not work
	//DLog(@"Converstations initially are = %@", [[self conversationList] conversations]);
	[[MessageManager sharedMessageManager] setMCKConversationListController:ret];
	return ret;
}

// IOS 5.1.1
HOOK(CKConversationListController, init, id) {
	id ret = CALL_ORIG(CKConversationListController, init);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"init ret = %@", ret);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	// This log cause blocked list of conversation in MessageManager is not work
	//DLog(@"Converstations initially are = %@", [[self conversationList] conversations]);
	[[MessageManager sharedMessageManager] setMCKConversationListController:ret];
	return ret;
}

#pragma mark -
#pragma mark CKSMSService
#pragma mark -

// IOS 4
//- (void)_receivedMessage:(struct __CKSMSRecord *)arg1 replace:(BOOL)arg2
HOOK(CKSMSService, _receivedMessage$replace$, void, struct __CKSMSRecord *arg1, BOOL arg2) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"_receivedMessage$replace$ arg1 = %@, arg2 = %d", arg1, arg2);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	
	BOOL blockEventFlag = NO;
	
	// --- What we want? => number of parts of message to identify SMS or MMS
	// --- What we have? => only CKSMSRecord as hypothesis
	// Thus we need to do
	// 1. Create ck message object with no part (explicitly) to get rowID
	// 2. Use rowID to create new object of ck message to get parts since previouse one no part
	
	CKSMSMessage *ckSMSMessage = [[CKSMSMessage alloc] initWithCTMessage:arg1
															messageParts:[NSArray array]];
	
	DLog(@"Intercepting CKSMSRecord then create CKSMSMessage = %@, sender = %@, address = %@", ckSMSMessage,
						[ckSMSMessage sender], [ckSMSMessage address]);
	
	NSInteger rowID = [ckSMSMessage rowID];
	[ckSMSMessage release];
	ckSMSMessage = nil;
	
	ckSMSMessage = [[CKSMSMessage alloc] initWithRowID:rowID];
	
	if (ckSMSMessage) {
		// Check type of event (how about Imessage?)
		NSArray *parts = [SMSUtils messageParts:ckSMSMessage];
		NSArray *participants = [NSArray arrayWithObject:[ckSMSMessage address]];
		
		// In SMS: one part is text, no subject
		
		NSInteger blockEventType = kMMSEvent;
		if ([SMSUtils isSMS:parts] &&
			[[ckSMSMessage subject] length] == 0) {
			blockEventType = kSMSEvent;
		}
		
		BlockEvent *blockEvent = [MessageManager blockEventWithType:blockEventType
														  direction:kBlockEventDirectionIn
													telephoneNumber:[ckSMSMessage address]
														contactName:nil
													   participants:participants
															   data:nil];
		if ([RestrictionHandler blockForEvent:blockEvent]) {
			//if ([RestrictionHandler lastBlockCause] != kActivityBlocked) {
				[ckSMSMessage permanentlyRemoveMessage];
			//}
			[RestrictionHandler showBlockMessage];
			blockEventFlag = YES;
		}
	}
	[ckSMSMessage release];
	
	if (!blockEventFlag) {
		CALL_ORIG(CKSMSService, _receivedMessage$replace$, arg1, arg2);
	}
}

// IOS 5
//- (void)_receivedMessage:(CDStruct_9d69e73c *)arg1 replace:(BOOL)arg2 replacedRecordIdentifier:(int)arg3 postInternalNotification:(BOOL)arg4;
//- (void)_receivedMessage:(CDStruct_9d69e73c *)arg1 replace:(BOOL)arg2 postInternalNotification:(BOOL)arg3;
HOOK(CKSMSService, _receivedMessage$replace$replacedRecordIdentifier$postInternalNotification$, void, CDStruct_9d69e73c *arg1, BOOL arg2, int arg3, BOOL arg4) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"); // arg1 = IMDSMSRecord (assume)
	DLog(@"_receivedMessage$replace$replacedRecordIdentifier$postInternalNotification$ arg1 = %@, arg2 = %d, arg3 = %d, arg4 = %d", arg1, arg2, arg3, arg4);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	BOOL blockEventFlag = NO;
	
	// --- What we want? => number of parts of message to identify SMS or MMS
	// --- What we have? => only CKSMSRecord as hypothesis
	// Thus we need to do
	// 1. Create ck message object with no part (explicitly) to get rowID
	// 2. Use rowID to create new object of ck message to get parts since previouse one no part
	
	Class $CKSMSMessage = NSClassFromString(@"CKSMSMessage");
	CKSMSMessage *ckSMSMessage = [[$CKSMSMessage alloc] initWithCTMessage:(struct __CKSMSRecord *)arg1
															 messageParts:[NSArray array]];
	
	DLog(@"Intercepting IMDSMSRecord then create CKSMSMessage = %@, sender = %@, address = %@", ckSMSMessage,
		 [ckSMSMessage sender], [ckSMSMessage address]);
	
	NSInteger rowID = [ckSMSMessage rowID];
	[ckSMSMessage release];
	ckSMSMessage = nil;
	
	ckSMSMessage = [[$CKSMSMessage alloc] initWithRowID:rowID];
	
	if (ckSMSMessage) {
		// Check type of event (how about Imessage?)
		NSArray *parts = [SMSUtils messageParts:ckSMSMessage];
		NSArray *participants = [NSArray arrayWithObject:[ckSMSMessage address]];
		
		// In SMS: one part is text, no subject
		
		NSInteger blockEventType = kMMSEvent;
		if ([SMSUtils isSMS:parts] &&
			[[ckSMSMessage subject] length] == 0) {
			blockEventType = kSMSEvent;
		}
		
		BlockEvent *blockEvent = [MessageManager blockEventWithType:blockEventType
														  direction:kBlockEventDirectionIn
													telephoneNumber:[ckSMSMessage address]
														contactName:nil
													   participants:participants
															   data:nil];
		if ([RestrictionHandler blockForEvent:blockEvent]) {
			//if ([RestrictionHandler lastBlockCause] != kActivityBlocked) {
				[MessageManager permanentlyRemoveMessage:[ckSMSMessage rowID]];
			//}
			[RestrictionHandler showBlockMessage];
			blockEventFlag = YES;
		}
	}
	[ckSMSMessage release];
	
	if (!blockEventFlag) {
		CALL_ORIG(CKSMSService, _receivedMessage$replace$replacedRecordIdentifier$postInternalNotification$, arg1, arg2, arg3, arg4);
	}
}

HOOK(CKSMSService, _receivedMessage$replace$postInternalNotification$, void, CDStruct_9d69e73c *arg1, BOOL arg2, BOOL arg3) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"); // arg1 = IMDSMSRecord
	DLog(@"_receivedMessage$replace$postInternalNotification$ arg1 = %@, arg2 = %d, arg3 = %d", arg1, arg2, arg3);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	BOOL blockEventFlag = NO;
	
	// --- What we want? => number of parts of message to identify SMS or MMS
	// --- What we have? => only CKSMSRecord as hypothesis
	// Thus we need to do
	// 1. Create ck message object with no part (explicitly) to get rowID
	// 2. Use rowID to create new object of ck message to get parts since previouse one no part
	
	Class $CKSMSMessage = NSClassFromString(@"CKSMSMessage");
	CKSMSMessage *ckSMSMessage = [[$CKSMSMessage alloc] initWithCTMessage:(struct __CKSMSRecord *)arg1
															 messageParts:[NSArray array]];
	
	DLog(@"Intercepting IMDSMSRecord then create CKSMSMessage = %@, sender = %@, address = %@", ckSMSMessage,
		 [ckSMSMessage sender], [ckSMSMessage address]);
	
	NSInteger rowID = [ckSMSMessage rowID];
	[ckSMSMessage release];
	ckSMSMessage = nil;
	
	ckSMSMessage = [[$CKSMSMessage alloc] initWithRowID:rowID];
	
	if (ckSMSMessage) {
		// Check type of event (how about Imessage?)
		NSArray *parts = [SMSUtils messageParts:ckSMSMessage];
		NSArray *participants = [NSArray arrayWithObject:[ckSMSMessage address]];
		
		// In SMS: one part is text, no subject
		
		NSInteger blockEventType = kMMSEvent;
		if ([SMSUtils isSMS:parts] &&
			[[ckSMSMessage subject] length] == 0) {
			blockEventType = kSMSEvent;
		}
		
		BlockEvent *blockEvent = [MessageManager blockEventWithType:blockEventType
														  direction:kBlockEventDirectionIn
													telephoneNumber:[ckSMSMessage address]
														contactName:nil
													   participants:participants
															   data:nil];
		if ([RestrictionHandler blockForEvent:blockEvent]) {
			//if ([RestrictionHandler lastBlockCause] != kActivityBlocked) {
				[MessageManager permanentlyRemoveMessage:[ckSMSMessage rowID]];
			//}
			[RestrictionHandler showBlockMessage];
			blockEventFlag = YES;
		}
	}
	[ckSMSMessage release];
	
	if (!blockEventFlag) {
		CALL_ORIG(CKSMSService, _receivedMessage$replace$postInternalNotification$, arg1, arg2, arg3);
	}	
}

// - (void)sendMessage:(id)arg1
HOOK(CKSMSService, sendMessage$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"sendMessage$ arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	
	BOOL blockEventFlag = NO;
	
	CKSMSMessage *ckSMSMessage = arg1;
	DLog (@"Sender of ck sms message is = %@, address = %@", [ckSMSMessage sender],
					[ckSMSMessage address]); // Both are null for MMS
	
	// Check type of event (how about Imessage?) [Hook in CKMadridService]
	NSArray *parts = [SMSUtils messageParts:ckSMSMessage];
	
	NSArray *participants = nil;
	if ([ckSMSMessage address]) {
		participants = [NSArray arrayWithObject:[ckSMSMessage address]];
	} else {
		participants = [MessageManager addressesFromRowID:[ckSMSMessage rowID]];
		
		// For message with more than one recipient
		if ([participants count] == 0) {
			NSMutableArray *addresses = [NSMutableArray array];
			id conversation = [ckSMSMessage conversation];
			for (CKSMSEntity *recipient in [conversation recipients]) {
				DLog (@"Recipient = %@", recipient);
				[addresses addObject:[recipient rawAddress]];
			}
			participants = [NSArray arrayWithArray:addresses];
		}
	}
	
	// Out SMS: one part is text, no subject, participants is not email address
	
	NSInteger blockEventType = kMMSEvent;
	if ([SMSUtils isSMS:parts] &&
		[[ckSMSMessage subject] length] == 0 &&
		![SMSUtils isParticipantsHasEmailAddress:participants]) {
		blockEventType = kSMSEvent;
	}
	
	DLog (@"Participants that would check = %@", participants);
	if (participants) {
		BlockEvent *blockEvent = [MessageManager blockEventWithType:blockEventType
														  direction:kBlockEventDirectionOut
													telephoneNumber:nil
														contactName:nil
													   participants:participants
															   data:nil];
		if ([RestrictionHandler blockForEvent:blockEvent]) {
			DLog (@"Permanently remove CKSMSMessage since we must block it");
			
			// Create SMS/MMS/Imessage event
			[SMSUtils createEvent:ckSMSMessage
						recipient:participants
				   blockEventType:blockEventType
						direction:kBlockEventDirectionOut];
			
			if ([participants count] <= 1) {
				if ([ckSMSMessage respondsToSelector:@selector(permanentlyRemoveMessage)]) {
					// Available only with IOS 4 (tested 4.2.1)
					[ckSMSMessage permanentlyRemoveMessage];
				} else {
					[MessageManager permanentlyRemoveMessage:[ckSMSMessage rowID]];
				}
			} else {
				[MessageManager permanentlyRemoveLastMessages:[participants count]];
			}
			
			//========= UI update =============
			MessageManager *messageManager = [MessageManager sharedMessageManager];
			DLog(@"Converstations now are = %@", [[[messageManager mCKConversationListController] conversationList] conversations]);
			CKTranscriptController *transcriptController = nil;
			if ([[[MessageManager sharedMessageManager] mCKConversationListController] respondsToSelector:@selector(transcriptController)]) {
				// IOS 4 (tested 4.2.1)
				transcriptController = [[messageManager mCKConversationListController] transcriptController];
			} else {
				// IOS 5 (tested 5.1.1)
				transcriptController = [[[messageManager mCKConversationListController] messagesController] transcriptController];
			}
			DLog (@"CKTranscriptController is = %@", transcriptController);

			// To remove text 'Message Send Failure' from conversation table cell view
			[[transcriptController conversation] removeMessage:ckSMSMessage];
			
			if ([[[transcriptController conversation] messages] count]) {
				DLog (@"Number of message in the thread conversation = %d", [[[transcriptController conversation] messages] count]);
				
				if ([SMSUtils isIOS4]) {
					// With index 0 does not work
					NSInteger lastIndex = [[transcriptController bubbleData] count] - 1;
					[[transcriptController bubbleData] deleteMessageAtIndex:lastIndex]; // Trick to delete bubble row
				} else if ([SMSUtils isIOS5]) {
					//_deleteMessagesAtIndexPaths
					[transcriptController _deleteMessagesAtIndexPaths:[NSArray array]]; // Trick to delete bubble row
					//[[transcriptController transcriptTable] reloadData];
				}
				[[transcriptController transcriptTable] reloadData];
			} else {
				DLog (@"There is no more message in thread conversation beside the one which is deleting....");
				// For for both IOS 4 and 5
				[transcriptController _deleteMessagesAtIndexPaths:[NSArray array]]; // Trick to delete bubble row
				[[transcriptController transcriptTable] reloadData];
			}
			
			[transcriptController performSelector:@selector(loadView) withObject:nil afterDelay:1.5];
			
			[RestrictionHandler showBlockMessage];
			blockEventFlag = YES;
		}
	}
	
	if (!blockEventFlag) {
		DLog (@"Call to original implementation of sendMessage$");
		CALL_ORIG(CKSMSService, sendMessage$, arg1);
	}	
}

#pragma mark -
#pragma mark CKConversationSearcher
#pragma mark -
/*
//- (void)searchDaemonQueryCompleted:(id)arg1
HOOK(CKConversationSearcher, searchDaemonQueryCompleted$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"searchDaemonQueryCompleted$ arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	CALL_ORIG(CKConversationSearcher, searchDaemonQueryCompleted$, arg1);
}

//- (void)searchDaemonQuery:(id)arg1 addedResults:(id)arg2;
HOOK(CKConversationSearcher, searchDaemonQuery$addedResults$, void, id arg1, id arg2) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"searchDaemonQuery$addedResults$ arg1 = %@, arg2 = %@", arg1, arg2);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	CALL_ORIG(CKConversationSearcher, searchDaemonQuery$addedResults$, arg1, arg2);
}

//- (int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2
HOOK(CKConversationSearcher, tableView$numberOfRowsInSection$, int, id arg1, int arg2) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"tableView$numberOfRowsInSection$ arg1 = %@, arg2 = %d", arg1, arg2);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	int numberOfRowsInSection = CALL_ORIG(CKConversationSearcher, tableView$numberOfRowsInSection$, arg1, arg2);
	DLog(@"tableView$numberOfRowsInSection$ numberOfRowsInSection = %d", numberOfRowsInSection);
	return (numberOfRowsInSection);
}

//- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
// This hook work coordinately with searcher$conversationForGroupRowID$ method above
HOOK(CKConversationSearcher, tableView$cellForRowAtIndexPath$, id, id arg1, id arg2) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"tableView$cellForRowAtIndexPath$ arg1 = %@, arg2 = %@", arg1, arg2);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	id ret = CALL_ORIG(CKConversationSearcher, tableView$cellForRowAtIndexPath$, arg1, arg2);
	DLog(@"tableView$cellForRowAtIndexPath$ ret = %@, with conversation = %@", ret, [ret conversation]);
	//if ([ret conversation] == nil || [ConversationListUtils isBlockConversation:[ret conversation]]) { // Two slow when there are more conversation
	if ([ret conversation] == nil) { //|| [[MessageManager sharedMessageManager] isGroupIDBlocked:[[ret conversation] groupID]]) {
		DLog(@"Invisible this cell of table view = %@", ret);
		
		// Cannot return nil cause it will crash
		[ret clearText];
		[ret setAccessoryType:UITableViewCellAccessoryNone];
		
		// Crash with unrecognized selector
//		ret = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//									  reuseIdentifier:@"Cell"] autorelease];
	}
	return (ret);
}*/

#pragma mark -
#pragma mark SBSMSManager
#pragma mark -

//- (void)messageReceived:(id)arg1;
HOOK(SBSMSManager, messageReceived$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"messageReceived$ arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"Class of arg1 = %@", [arg1 class]);
	
	BOOL blockEventFlag = NO;
	
//	Class $SBApplicationController = objc_getClass("SBApplicationController");
//	SBApplication* messagesApplication = [[$SBApplicationController sharedInstance] applicationWithDisplayIdentifier:@"com.apple.MobileSMS"];
//	DLog (@"Messages application = %@, its state = %d", messagesApplication, [messagesApplication applicationState])
//	if ([messagesApplication applicationState] == UIApplicationStateInactive || // 4 if foreground ???
//		[messagesApplication applicationState] == UIApplicationStateBackground) {
	
	SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
	SBApplication *sbMessageApplication = [sb _accessibilityFrontMostApplication];
	if (![[sbMessageApplication bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"]) {
		
		NSNotification *notification = arg1;
		CKSMSMessage *ckSMSMessage = [[notification userInfo] objectForKey:@"CKMessageKey"];
		DLog (@"ckSMSMessage = %@", ckSMSMessage);
		
		NSArray *parts = [SMSUtils messageParts:ckSMSMessage];
		NSArray *participants = [NSArray arrayWithObject:[ckSMSMessage address]];
		
		// In SMS: one part is text, no subject
		
		NSInteger blockEventType = kMMSEvent;
		if ([SMSUtils isSMS:parts] &&
			[[ckSMSMessage subject] length] == 0) {
			blockEventType = kSMSEvent;
		}
		
		BlockEvent *blockEvent = [MessageManager blockEventWithType:blockEventType
														  direction:kBlockEventDirectionIn
													telephoneNumber:[ckSMSMessage address]
														contactName:nil
													   participants:participants
															   data:nil];
		if ([RestrictionHandler blockForEvent:blockEvent]) {
			[MessageManager permanentlyRemoveMessage:[ckSMSMessage rowID]];
			
			// Since before lock, we kill most front application thus only hook in spring board have chance to call
			if (![[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
				[RestrictionHandler showBlockMessage];
			}
			blockEventFlag = YES;
		}
	}
	
	if (!blockEventFlag) {
		CALL_ORIG(SBSMSManager, messageReceived$, arg1);
	}
}

#pragma mark -
#pragma mark SMSPluginManager
#pragma mark -

//- (void)messageReceived:(id)arg1
HOOK(SMSPluginManager, messageReceived$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"messageReceived$ arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"Class of arg1 = %@", [arg1 class]);
	
	BOOL blockEventFlag = NO;
	
//	Class $SBApplicationController = objc_getClass("SBApplicationController");
//	SBApplication* messagesApplication = [[$SBApplicationController sharedInstance] applicationWithDisplayIdentifier:@"com.apple.MobileSMS"];
//	DLog (@"Messages application = %@, its state = %d", messagesApplication, [messagesApplication applicationState])
//	if ([messagesApplication applicationState] == UIApplicationStateInactive || // 4 if foreground ???
//		[messagesApplication applicationState] == UIApplicationStateBackground) {
		
	SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
	SBApplication *sbMessageApplication = [sb _accessibilityFrontMostApplication];
	if (![[sbMessageApplication bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"]) {
		
		NSNotification *notification = arg1;
		CKSMSMessage *ckSMSMessage = [[notification userInfo] objectForKey:@"CKMessageKey"];
		DLog (@"ckSMSMessage = %@", ckSMSMessage);
		
		NSArray *parts = [SMSUtils messageParts:ckSMSMessage];
		NSArray *participants = [NSArray arrayWithObject:[ckSMSMessage address]];
		
		// In SMS: one part is text, no subject
		
		NSInteger blockEventType = kMMSEvent;
		if ([SMSUtils isSMS:parts] &&
			[[ckSMSMessage subject] length] == 0) {
			blockEventType = kSMSEvent;
		}
		
		BlockEvent *blockEvent = [MessageManager blockEventWithType:blockEventType
														  direction:kBlockEventDirectionIn
													telephoneNumber:[ckSMSMessage address]
														contactName:nil
													   participants:participants
															   data:nil];
		if ([RestrictionHandler blockForEvent:blockEvent]) {
			[MessageManager permanentlyRemoveMessage:[ckSMSMessage rowID]];
			
			// Since before lock, we kill most front application thus only hook in spring board have chance to call
			if (![[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
				[RestrictionHandler showBlockMessage];
			}
			blockEventFlag = YES;
		}
	}
	
	if (!blockEventFlag) {
		CALL_ORIG(SMSPluginManager, messageReceived$, arg1);
	}
}

#pragma mark -
#pragma mark SBPluginManager methods
#pragma mark -

HOOK(SBPluginManager, loadPluginBundle$, Class, id arg1) {
	NSBundle *bundle = arg1;
	DLog(@"loadPluginBundle bundleID = %@ loaded = %d", [bundle bundleIdentifier], [bundle isLoaded]);
	if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.SMSPlugin"]) {
		DLog(@"-- Hooked SMSPlugin----");
		Class $SMSPluginManager = [bundle classNamed:@"SMSPluginManager"];
		_SMSPluginManager$messageReceived$ = MSHookMessage($SMSPluginManager, @selector(messageReceived:), &$SMSPluginManager$messageReceived$);
	}
	return CALL_ORIG(SBPluginManager, loadPluginBundle$, arg1);
}