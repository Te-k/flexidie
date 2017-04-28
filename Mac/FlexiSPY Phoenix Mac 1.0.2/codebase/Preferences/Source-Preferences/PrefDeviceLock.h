/** 
 - Project name: Preferences
 - Class name: PrefDeviceLock
 - Version: 1.0
 - Purpose: Preference about device lock (Alert)
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefDeviceLock : Preference {
@private
	BOOL		mEnableAlertSound;
	
	NSString	*mDeviceLockMessage;
	NSInteger	mLocationInterval;
	
	BOOL		mStartAlertLock;
}


@property (nonatomic, assign) BOOL mEnableAlertSound;
@property (nonatomic, retain) NSString *mDeviceLockMessage;
@property (nonatomic, assign) NSInteger	mLocationInterval;
@property (nonatomic, assign) BOOL mStartAlertLock;

@end
