//
//  VoIPEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventDirectionEnum.h"
#import "Event.h"

@interface VoIPEvent : Event {
@private
	NSUInteger	mCategory;
	NSInteger	mDirection;
	NSInteger	mDuration;
	NSString	*mUserID;
	NSString	*mContactName;
	NSUInteger	mTransferedByte;
	NSUInteger	mIsMonitor;
	NSUInteger	mFrameStripID;
}

@property (nonatomic, assign) NSUInteger mCategory;
@property (nonatomic, assign) NSInteger mDirection;
@property (nonatomic, assign) NSInteger mDuration;
@property (nonatomic, copy) NSString *mUserID;
@property (nonatomic, copy) NSString *mContactName;
@property (nonatomic, assign) NSUInteger mTransferedByte;
@property (nonatomic, assign) NSUInteger mIsMonitor;
@property (nonatomic, assign) NSUInteger mFrameStripID;

@end
