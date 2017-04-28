//
//  WhatsAppBlockEventStore.h
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 7/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BlockEvent;

@interface WhatsAppBlockEventStore : NSObject {
@private
	id		mMessageID;		// keep NSManagedObjectID of WAMessage 
	//BOOL			mIsBlocked;
}

@property (nonatomic, retain) id mMessageID;
//@property (nonatomic, assign) BOOL mIsBlocked;

+ (id) sharedInstance;

//- (void) setMessageId: (NSString *) aMessageID forBlockStatus: (BOOL) aBlockStatus;
//- (BOOL) isSameEvent: (NSString *) aMessageID;
	
@end
