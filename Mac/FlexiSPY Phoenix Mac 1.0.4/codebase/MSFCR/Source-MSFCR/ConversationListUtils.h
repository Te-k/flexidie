//
//  ConversationListUtils.h
//  SMSUITestApp
//
//  Created by Makara Khloth on 7/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RestrictionManagerHelper.h"

@class CKConversation;

@interface ConversationListUtils : NSObject {

}

/*
 Block events are:
	 - SMS
	 - MMS
	 - Email
	 - iMessage
 */

+ (void) dumpBlockConversation: (NSMutableArray *) aConversations
					  groupIDs: (NSMutableArray *) aGroupIDs;

+ (BOOL) isBlockConversation: (id) aConversation;

+ (NSInteger) conversationBlockCause;

@end
