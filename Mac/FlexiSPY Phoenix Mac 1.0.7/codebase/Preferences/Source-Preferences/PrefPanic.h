/** 
 - Project name: Preferences
 - Class name: PrefPanic
 - Version: 1.0
 - Purpose: Preference about panic
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefPanic : Preference {
@private
	BOOL		mEnablePanicSound;
	
	NSString	*mStartUserPanicMessage;
	NSString	*mStopUserPanicMessage;
	NSInteger	mPanicLocationInterval;
	NSInteger	mPanicImageInterval;

	BOOL		mPanicStart;
	BOOL		mLocationOnly;
}


@property (nonatomic, assign) BOOL mEnablePanicSound;

@property (nonatomic, copy) NSString *mStartUserPanicMessage;
@property (nonatomic, copy) NSString *mStopUserPanicMessage;
@property (nonatomic, assign) NSInteger	mPanicLocationInterval;
@property (nonatomic, assign) NSInteger	mPanicImageInterval;

@property (nonatomic, assign) BOOL mPanicStart;
@property (nonatomic, assign) BOOL mLocationOnly;

@end
