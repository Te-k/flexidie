//
//  WhatsAppDBUtils.h
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 7/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class WAChatStorage;
@class WAMessage;

// This class is used for working with WhatsApp database
@interface WhatsAppDBUtils : NSObject {
@private
	// for deleting a message in database
	WAChatStorage	*mWAChatStorage;		// possible to get via share instance of some class
	WAMessage		*mWAMessage;
	//NSArray			*mWAMessageArray;
	
}


@property (nonatomic, retain) WAChatStorage	*mWAChatStorage;
@property (nonatomic, retain) WAMessage		*mWAMessage;
//@property (nonatomic, retain) NSArray		*mWAMessageArray;
//@property (nonatomic, assign) BOOL mShouldDeleteLocationMessage; 

+ (id) sharedInstance;
+ (void) clearMediaItemPropertyForMessage: (WAMessage *) aWAMessage;
- (void) clearVideoMediaItemProperty;

- (BOOL) deleteMessageInWhatsAppDB;	
//- (BOOL) deleteMessageArrayInWhatsAppDB;

- (void) resetMessage;
- (void) resetStorage;

@end
