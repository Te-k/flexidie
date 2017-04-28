//
//  FxVoIPEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 7/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

typedef enum {
	kVoIPCategoryUnknown		= 0,
	kVoIPCategoryGoogleTalk		= 1,
	kVoIPCategoryYahoo			= 2,
	kVoIPCategorySkype			= 3,
	kVoIPCategoryLINE			= 4,
	kVoIPCategoryFaceTime		= 5,
	kVoIPCategoryFacebook		= 6,
	kVoIPCategoryViber			= 7,
	kVoIPCategoryWeChat			= 8,
    kVoIPCategoryWhatsApp       = 9,
    kVoIPCategoryTango          = 10
} FxVoIPCategory;

typedef enum {
	kFxVoIPMonitorNO		= 0,
	kFxVoIPMonitorYES		= 1
} FxVoIPMonitor;
	
@interface FxVoIPEvent : FxEvent <NSCoding, NSCopying> {
@private
	FxVoIPCategory		mCategory;
	FxEventDirection	mDirection;
	NSUInteger			mDuration;
	NSString			*mUserID;
	NSString			*mContactName;
	NSUInteger			mTransferedByte;
	FxVoIPMonitor		mVoIPMonitor;
	NSUInteger			mFrameStripID;
}

@property (nonatomic, assign) FxVoIPCategory mCategory;
@property (nonatomic, assign) FxEventDirection mDirection;
@property (nonatomic, assign) NSUInteger mDuration;
@property (nonatomic, copy) NSString *mUserID;
@property (nonatomic, copy) NSString *mContactName;
@property (nonatomic, assign) NSUInteger mTransferedByte;
@property (nonatomic, assign) FxVoIPMonitor mVoIPMonitor;
@property (nonatomic, assign) NSUInteger mFrameStripID;

@end
