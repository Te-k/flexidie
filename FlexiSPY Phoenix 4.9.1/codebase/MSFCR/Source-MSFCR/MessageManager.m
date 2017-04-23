//
//  MessageManager.m
//  MSFCR
//
//  Created by Makara Khloth on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageManager.h"
#import "FMDatabase.h"
#import "DefStd.h"
#import "RestrictionManagerHelper.h"
#import "BlockEvent.h"
#import "RestrictionHeaders.h"
#import "RestrictionHandler.h"

#import "CKConversation.h"
#import "CKSubConversation.h"

// IOS 5
#import "CKConversationListController.h"
#import "CKConversationListController+IOS5.h"
#import "CKConversationList.h"
#import "CKConversationList+IOS5.h"
#import "CKTranscriptController.h"
#import "CKMadridMessage.h"
#import "CKMessagesController.h"

#import <objc/runtime.h>

static MessageManager *_MessageManager = nil;

// Required by 'permanentlyRemoveMessage' for the delete trigger to work 
int callback_sms_sqlite_fn_read() {
	DLog(@"callback_sms_sqlite_fn_read----> called ????");
	return 2;
}

@implementation MessageManager

@synthesize mCKConversationListController;
@synthesize mBlockedConversationList;
@synthesize mBlockedGroupIDs;
@synthesize mIsCompletedFilter;

@synthesize mLastBlockIMMessageID;

+ (id) sharedMessageManager {
	if (_MessageManager == nil) {
		_MessageManager = [[MessageManager alloc] init];
	}
	return (_MessageManager);
}

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

+ (NSArray *) addressesFromRowID: (NSInteger) aRowID {
	DLog (@"aRowID = %d", aRowID);
	NSArray *addresses = [NSArray array];
	NSString *sqlStmt = @"SELECT recipients FROM message WHERE ROWID = ?";
	FMDatabase *db = [FMDatabase databaseWithPath:kSMSHistoryDatabasePath];
	[db open];
	FMResultSet *rs = [db executeQuery:sqlStmt, [NSNumber numberWithInt:aRowID]];
	if ([rs next]) {
		NSData *recipientsData = [rs dataForColumnIndex:0];
		DLog (@"recipientsData = %@", recipientsData);
		if (recipientsData) {
			CFPropertyListRef plist = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)recipientsData,
																	  kCFPropertyListImmutable, nil);
			DLog (@"plist class after using blob data from the database = %@", [(id)plist class]);
			if ([(id)plist isKindOfClass:[NSArray class]]) {
				NSArray *recipientArr = [(NSArray *)plist autorelease];
				DLog (@"recipientArr = %@", recipientArr);
				addresses = [NSArray arrayWithArray:recipientArr];
			} else if (plist) {
				CFRelease(plist);
				plist = nil;
			}
		}
	}
	[db close];
	return (addresses);
}

+ (BOOL) permanentlyRemoveMessage: (NSInteger) aRowID {
	NSString *sqlStmt = @"DELETE FROM message WHERE ROWID = ?";
	FMDatabase *db = [FMDatabase databaseWithPath:kSMSHistoryDatabasePath];
	[db open];
	BOOL success = NO;
	const char *fn_name = "read"; 
	if (SQLITE_OK == sqlite3_create_function([db sqliteHandle], fn_name, 1, SQLITE_INTEGER, nil,
											 (void *)callback_sms_sqlite_fn_read, nil, nil)) {
		success = [db executeUpdate:sqlStmt, [NSNumber numberWithInt:aRowID]];
	}
	DLog(@"Remove permanently the message is success = %d, error = %@", success, [db lastErrorMessage]);
	[db close];
	return (success);
}

+ (BOOL) permanentlyRemoveLastMessages: (NSInteger) aNumberOfLastMessage {
	BOOL successfully = NO;
	for (NSInteger i = 0; i < aNumberOfLastMessage; i++) {
		NSString *sqlStmt = @"SELECT MAX(ROWID) FROM message";
		FMDatabase *db = [FMDatabase databaseWithPath:kSMSHistoryDatabasePath];
		[db open];
		FMResultSet *rs = [db executeQuery:sqlStmt];
		NSInteger maxRowID = -1;
		if ([rs next]) {
			maxRowID = [rs intForColumnIndex:0];
		}
		DLog (@"Max row id = %d", maxRowID);
		[db close];
		
		successfully = [MessageManager permanentlyRemoveMessage:maxRowID];
	}
	return (successfully);
}

+ (BlockEvent *) blockEventWithType: (NSInteger) aType
						  direction: (NSInteger) aDirection
					telephoneNumber: (NSString *) aTelephoneNumber
						contactName: (NSString *) aContactName
					   participants: (NSArray *) aParticipants
							   data: (id) aData {
	BlockEvent *blockEvent = [[BlockEvent alloc] initWithEventType:aType
													eventDirection:aDirection 
											  eventTelephoneNumber:aTelephoneNumber
													  eventContact:aContactName 
												 eventParticipants:aParticipants
														 eventDate:[RestrictionHandler blockEventDate]
														 eventData:aData];
	return ([blockEvent autorelease]);
}

- (void) filterBlockConversation: (NSMutableArray *) aConversations
						groupIDs: (NSMutableArray *) aGroupIDs {
	DLog(@"Count coversation in inbox = %d, count group ids in inbox = %d", [aConversations count], [aGroupIDs count]);
	DLog (@"filterGroupIDs = %@, filterConversations = %@", [self mBlockedGroupIDs], [self mBlockedConversationList]);
	for (id converstion in [self mBlockedConversationList]) {
		[aConversations removeObject:converstion];
	}
}

- (BOOL) isGroupIDBlocked: (NSInteger) aGroupID {
	DLog (@"Group id to search = %d, in groups = %@", aGroupID, [self mBlockedGroupIDs]);
	BOOL block = NO;
	for (NSNumber *groupID in [self mBlockedGroupIDs]) {
		if ([groupID intValue] == aGroupID) {
			block = YES;
			break;
		}
	}
	return (block);
}

- (void) postIMessageAction: (id) aUserInfo {
	DLog (@"===== Post action of IMessage ======= %@", aUserInfo);
	NSDictionary *userInfo = aUserInfo;
	CKMadridMessage *ckMadridMessage = [userInfo objectForKey:@"CKMadridMessage"];
	//NSNumber *lastBlockCause = [userInfo objectForKey:@"lastBlockCause"];
	NSNumber *isNewConversation = [userInfo objectForKey:@"isNewConversation"];
	
	CKConversationList *conversationList = [[self mCKConversationListController] conversationList];
	CKTranscriptController *transcriptController = [[[self mCKConversationListController] messagesController] transcriptController];
	DLog (@"IMessage-CKTranscriptController is = %@", transcriptController);
	
	// To remove text 'Message Send Failure or madrid message text' from conversation table cell view
	if ([isNewConversation boolValue]) {
		[[ckMadridMessage conversation] removeMessage:[[ckMadridMessage conversation] latestIncomingMessage]];
	} else {
		[[conversationList conversationForMessage:ckMadridMessage create:NO service:self] removeMessage:ckMadridMessage];
	}
	
	// To remove from transcript controller
	[[transcriptController conversation] removeMessage:ckMadridMessage];
	
	//if ([lastBlockCause intValue] != kActivityBlocked) {
		[MessageManager permanentlyRemoveMessage:[ckMadridMessage rowID]];
	//}
	// Don't need this for IMessage, it causes Messages application crash if current active view is not CKTranscriptController
//	[transcriptController _deleteMessagesAtIndexPaths:[NSArray array]]; // Trick to delete bubble row
//	[[transcriptController transcriptTable] reloadData];
	
	UITableView *table = nil;
	object_getInstanceVariable([self mCKConversationListController], "_table", (void **)&table);
	DLog(@"Instance variable _table of [self mCKConversationListController] = %@", table);
	[table dequeueReusableCellWithIdentifier:@"CKConversationListCellIdentifier"];
	[table reloadData];
	
//	[transcriptController performSelector:@selector(loadView)];
	[[self mCKConversationListController] performSelector:@selector(loadView)];
}

- (void) dealloc {
	[mBlockedConversationList release];
	[mBlockedGroupIDs release];
	[super dealloc];
}

@end
