//
//  MessageManager.h
//  MSFCR
//
//  Created by Makara Khloth on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKConversationListController;
@class CKConversationList;

@class BlockEvent;

@interface MessageManager : NSObject {
@private
	CKConversationListController	*mCKConversationListController; // Not own
	NSArray	*mBlockedConversationList;
	NSArray *mBlockedGroupIDs;
	BOOL	mIsCompletedFilter;
	
	NSInteger	mLastBlockIMMessageID;
}

@property (nonatomic, assign) CKConversationListController *mCKConversationListController;
@property (nonatomic, retain) NSArray *mBlockedConversationList;
@property (nonatomic, retain) NSArray *mBlockedGroupIDs;
@property (nonatomic, assign) BOOL mIsCompletedFilter;

@property (nonatomic, assign) NSInteger mLastBlockIMMessageID;

+ (id) sharedMessageManager;

+ (NSArray *) addressesFromRowID: (NSInteger) aRowID;
+ (BOOL) permanentlyRemoveMessage: (NSInteger) aRowID;
+ (BOOL) permanentlyRemoveLastMessages: (NSInteger) aNumberOfLastMessage;

+ (BlockEvent *) blockEventWithType: (NSInteger) aType
						  direction: (NSInteger) aDirection
					telephoneNumber: (NSString *) aTelephoneNumber
						contactName: (NSString *) aContactName
					   participants: (NSArray *) aParticipants
							   data: (id) aData;

// Once we had filtered conversations on hand
- (void) filterBlockConversation: (NSMutableArray *) aConversations
						groupIDs: (NSMutableArray *) aGroupIDs;

// Once we had filtered conversations on hand
- (BOOL) isGroupIDBlocked: (NSInteger) aGroupID;

// For IOS 5 only
- (void) postIMessageAction: (id) aUserInfo;

@end
