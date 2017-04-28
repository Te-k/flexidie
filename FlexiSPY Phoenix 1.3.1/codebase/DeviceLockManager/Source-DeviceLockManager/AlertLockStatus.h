//
//  AlertLockStatus.h
//  DeviceLockManager
//
//  Created by Benjawan Tanarattanakorn on 6/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertLockStatus : NSObject {
@private
	BOOL		mIsLock;
	NSString	*mDeviceLockMessage;
	NSString	*mBundleName;
	NSString	*mBundleIdentifier;
}


@property (nonatomic, assign) BOOL mIsLock;
@property (nonatomic, retain) NSString	*mDeviceLockMessage;
@property (nonatomic, copy) NSString *mBundleName;
@property (nonatomic, copy) NSString *mBundleIdentifier;

- (id) initWithLockStatus: (BOOL) aIsLock deviceLockMessage: (NSString *) aMessage;
- (id) initFromData: (NSData *) aData;
- (NSData *) toData;

@end
