//
//  DeviceLockManagerUtils.h
//  MSLOCK
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MessagePortIPCReader.h"


@class MessagePortIPCReader;
@class AlertLockStatus;
@class SBApplication;


@interface DeviceLockManagerUtils : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader;
	BOOL					mIsDeviceLockNow;		
	UIView					*mLockView;
	AlertLockStatus			*mAlertLockStatus;
	NSString				*mLatestActivatedApplicationName;
	
	UILabel					*mLabel;					// retain
}


@property (nonatomic, retain) AlertLockStatus	*mAlertLockStatus;
@property (nonatomic, retain) UIView			*mLockView;

+ (id) sharedDeviceLockManagerUtils;
- (void) lock;
- (void) unlock;

- (void) startMessagePortReader;
- (void) stopMessagePortReader;

- (void) checkPreviousLockStateAndKeepLockOrUnlockDevice;

//- (void) setLatestActivatedApplication: (SBApplication *) aSbApp;		// not used
//- (void) bringLockViewToFront;										// not used


@end
