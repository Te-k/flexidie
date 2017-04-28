//
//  FxIMConversationEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 1/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxIMEvent.h"

@interface FxIMConversationEvent : FxEvent {
@private
	FxIMServiceID	mServiceID;
	NSString		*mAccountID;
	NSString		*mID;
	NSString		*mName;
	NSArray			*mContactIDs;
	NSData			*mPicture;
	NSString		*mStatusMessage;
}

@property (nonatomic, assign) FxIMServiceID mServiceID;
@property (nonatomic, copy) NSString *mAccountID;
@property (nonatomic, copy) NSString *mID;
@property (nonatomic, copy) NSString *mName;
@property (nonatomic, retain) NSArray *mContactIDs;
@property (nonatomic, retain) NSData *mPicture;
@property (nonatomic, copy) NSString *mStatusMessage;

@end
