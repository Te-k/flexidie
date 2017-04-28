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

@interface IMContactEvent : Event {
	NSInteger mEventType;
	NSString * mEventTime;
	IMServiceID  mIMServiceID;
	NSString * mAccountOwnerID;
	NSString * mContactID;
	NSString * mContactDisplayName;
	NSString * mContactStatusMessage;
	NSData * mContactPictureProfile;
}
@property (nonatomic,assign)NSInteger mEventType;
@property (nonatomic,copy) NSString * mEventTime;
@property (nonatomic,assign)IMServiceID mIMServiceID;
@property (nonatomic,copy)NSString * mAccountOwnerID;
@property (nonatomic,copy)NSString * mContactID;
@property (nonatomic,copy)NSString * mContactDisplayName;
@property (nonatomic,copy)NSString * mContactStatusMessage;
@property (nonatomic,retain)NSData* mContactPictureProfile;
@end

