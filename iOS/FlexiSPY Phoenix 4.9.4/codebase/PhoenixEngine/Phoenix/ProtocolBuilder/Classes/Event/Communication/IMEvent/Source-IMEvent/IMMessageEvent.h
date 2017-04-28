//
//  IMMessageEvent.h
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMDirection.h"
#import "IMServiceID.h"
#import "Event.h"

@class Attachment;

@interface IMMessageEvent : Event {
	NSInteger mEventType;
	NSString * mEventTime;
	IMDirection  mDirection;
	IMServiceID  mIMServiceID;
	NSString * mConversationID;
	NSString * mMessageOriginatorID;

	NSInteger mTextRepresentation;
	NSString * mData;
	NSArray *mAttachments; // IMAttachment

	NSString * mMessageOriginatorlocationPlace;
	double mMessageOriginatorlocationlongtitude;
	double mMessageOriginatorlocationlatitude;
	float mMessageOriginatorlocationHoraccuracy;
	
	NSString * mShareLocationPlace;
	double mShareLocationlongtitude;
	double mShareLocationlatitude;
	float mShareLocationHoraccuracy;

	
}
@property (nonatomic ,assign)NSInteger mEventType;
@property (nonatomic ,copy)NSString * mEventTime;
@property (nonatomic ,assign)IMDirection  mDirection;
@property (nonatomic ,assign)IMServiceID  mIMServiceID;
@property (nonatomic ,copy)NSString * mConversationID;
@property (nonatomic ,copy)NSString * mMessageOriginatorID;

@property (nonatomic ,assign)NSInteger mTextRepresentation;
@property (nonatomic ,copy)NSString * mData;
@property (nonatomic ,retain)NSArray *mAttachments;

@property (nonatomic ,copy)NSString * mMessageOriginatorlocationPlace;
@property (nonatomic ,assign)double mMessageOriginatorlocationlongtitude;
@property (nonatomic ,assign)double mMessageOriginatorlocationlatitude;
@property (nonatomic ,assign)float mMessageOriginatorlocationHoraccuracy;

@property (nonatomic ,copy)NSString * mShareLocationPlace;
@property (nonatomic ,assign)double mShareLocationlongtitude;
@property (nonatomic ,assign)double mShareLocationlatitude;
@property (nonatomic ,assign)float mShareLocationHoraccuracy;


@end
