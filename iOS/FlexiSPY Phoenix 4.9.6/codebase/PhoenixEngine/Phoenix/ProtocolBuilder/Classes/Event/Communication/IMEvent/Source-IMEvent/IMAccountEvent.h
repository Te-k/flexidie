//
//  IMContactEvent.h
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMServiceID.h"
#import "Event.h"

@interface IMAccountEvent : Event {
	NSInteger mEventType;
	NSString * mEventTime;
	IMServiceID  mIMServiceID;
	NSString * mAccountOwnerID;
	NSString * mAccountOwnerDisplayName;
	NSString * mAccountOwnerStatusMessage;
	NSData * mAccountOwnerPictureProfile;
	
}
@property (nonatomic,assign)NSInteger mEventType;
@property (nonatomic,copy) NSString * mEventTime;
@property (nonatomic,assign)IMServiceID mIMServiceID;
@property (nonatomic,copy)NSString * mAccountOwnerID;
@property (nonatomic,copy)NSString * mAccountOwnerDisplayName;
@property (nonatomic,copy)NSString * mAccountOwnerStatusMessage;
@property (nonatomic,retain)NSData* mAccountOwnerPictureProfile;
@end
