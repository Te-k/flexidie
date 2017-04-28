//
//  ConversationListUtils.m
//  SMSUITestApp
//
//  Created by Makara Khloth on 7/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationListUtils.h"
#import "BlockEvent.h"
#import "RestrictionHandler.h"
#import "SMSUtils.h"
#import "MessageManager.h"

#import "CKConversation.h"
#import "CKSMSEntity.h"
#import "CKSMSMessage.h"

// IOS 5
#import "_CKConversation.h"
#import "CKSubConversation.h"
#import "CKMadridMessage.h"

@implementation ConversationListUtils

/**
 - Method name: dumpBlockConversation:groupIDs
 - Purpose: This method is used to dump out block SMS, MMS, Imessage in inbox when restriction is enable
 - Argument list and description: aConversations (NSMutableArray *) array of (CKConversation * in IOS 4 or CKSubConversation * in IOS 5)
								  aGroupIDs (NSMutableArray *) array of NSInteger which are conversation's group id
 - Return description: Not return type
 */

+ (void) dumpBlockConversation: (NSMutableArray *) aConversations
					  groupIDs: (NSMutableArray *) aGroupIDs {
	//DLog(@"Count coversation in inbox = %d, count group ids in inbox = %d", [aConversations count], [aGroupIDs count]);
	NSMutableArray *dumpConverstaions = [NSMutableArray array];
	NSMutableArray *dumpGroupIDs = [NSMutableArray array];
	
	for (id converstion in aConversations) {
		if ([ConversationListUtils isBlockConversation:converstion] &&
			[ConversationListUtils conversationBlockCause] == kActivityBlocked) {
			NSNumber* groupID = [NSNumber numberWithInt:[converstion groupID]];
			[dumpGroupIDs addObject:groupID];
			[dumpConverstaions addObject:converstion];
		}
	}
	
	[[MessageManager sharedMessageManager] setMBlockedConversationList:dumpConverstaions];
	[[MessageManager sharedMessageManager] setMBlockedGroupIDs:dumpGroupIDs];
	//DLog (@"dumpGroupIDs = %@, dumpConverstaions = %@", dumpGroupIDs, dumpConverstaions);
	
	for (CKConversation *converstion in dumpConverstaions) {
		[aConversations removeObject:converstion];
	}
	
	for (NSNumber *groupID in dumpGroupIDs) {
		[aGroupIDs removeObject:groupID];
	}
}

/**
 - Method name: isBlockConversation:
 - Purpose: This method is used to used to check whether conversation is block when restriction is enable
 - Argument list and description: aConversation (id which could be CKConversation * in IOS 4 or CKSubConversation * in IOS 5)
 - Return description: Boolean trun is block otherwise false
 */

+ (BOOL) isBlockConversation: (id) aConversation {
//	DLog(@"Conversation that have to check = %@, recipient = %@", aConversation, [aConversation recipient]);
//	DLog(@"Recipient list of the conversation = %@", [aConversation recipients]);
//	DLog(@"Message count in conversation is = %d", [[aConversation messages] count]);
	BOOL block = NO;
	
	for (id message in [aConversation messages]) {
		//DLog (@"Class of message that have to check = %@", message);
		if ([message isKindOfClass:NSClassFromString(@"CKSMSMessage")] ||
			[message isKindOfClass:NSClassFromString(@"CKMadridMessage")]) {
			
			NSInteger blockEventType = kSMSEvent;
			if ([message isKindOfClass:NSClassFromString(@"CKMadridMessage")]) {
				blockEventType = kIMEvent;
			} else {
				NSArray *parts = [SMSUtils messageParts:message];
				blockEventType = ([SMSUtils isSMS:parts]) ? kSMSEvent : kMMSEvent;
			}
			
			NSInteger direction = [message isOutgoing] ? kBlockEventDirectionOut : kBlockEventDirectionIn;
			
			//DLog (@"Message's sender = %@, as well as address = %@", [message sender], [message address]);
			NSString *address = [message address];
			if (!address && direction == kBlockEventDirectionOut) {
				CKSMSEntity *smsEntity = [message sender];
				address = [smsEntity rawAddress];
			}
			//DLog (@"This block message's address = %@", address);
			
			NSArray *participants = [NSArray arrayWithObject:address] ;
			BlockEvent *blockEvent = [MessageManager blockEventWithType:blockEventType
															  direction:direction 
														telephoneNumber:nil
															contactName:nil
														   participants:participants
																   data:nil];
			if ([RestrictionHandler blockForEvent:blockEvent]) {
				//DLog(@"Block message event as hold conversation");
				block = YES;
				break;
			}
		}
	}
	return (block);
}

+ (NSInteger) conversationBlockCause {
	return ([RestrictionHandler lastBlockCause]);
}

@end
