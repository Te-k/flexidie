//
//  ​​IMConversationEvent.h
//  ​​IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMServiceID.h"
#import "Event.h"

@interface IMConversationEvent : Event {
	NSInteger mEventType;
	NSString * mEventTime;
	IMServiceID  mIMServiceID;
	NSString * mAccountOwnerID;
	NSString * mConversationID;
	NSString * mConversationName;
	NSArray	*mContacts;
	NSData * mPictureProfile;
	NSString * mStatusMessage;
}
@property (nonatomic,assign)NSInteger mEventType;
@property (nonatomic,copy) NSString * mEventTime;
@property (nonatomic,assign)IMServiceID mIMServiceID;
@property (nonatomic,copy)NSString * mAccountOwnerID;
@property (nonatomic,copy)NSString * mConversationID;
@property (nonatomic,copy)NSString * mConversationName;
@property (nonatomic,retain)NSArray* mContacts;
@property (nonatomic,copy)NSString * mStatusMessage;
@property (nonatomic,retain)NSData* mPictureProfile;

@end

