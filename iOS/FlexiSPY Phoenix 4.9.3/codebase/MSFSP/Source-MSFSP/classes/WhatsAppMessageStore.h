//
//  WhatsAppMessageStore.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 1/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WhatsAppMessageStore : NSObject {
@private
	NSMutableArray	*mIncomingMessageArray;
	NSMutableArray	*mOutgoingMessageArray;
}

@property(retain) NSMutableArray *mIncomingMessageArray;
@property(retain) NSMutableArray *mOutgoingMessageArray;


+ (WhatsAppMessageStore *) shareWhatsAppMessageStore;

- (BOOL) isIncomingMessageDuplicate: (id) aMessageID;
- (BOOL) isOutgoingMessageDuplicate: (id) aMessageID;


@end
