/** 
 - Project name: Preferences
 - Class name: PrefLocation
 - Version: 1.0
 - Purpose: Preference about location
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefLocation : Preference {
@private
	BOOL		mEnableLocation;
	
	NSInteger	mLocationInterval;
}


@property (nonatomic, assign) BOOL mEnableLocation;
@property (nonatomic, assign) NSInteger mLocationInterval;

@end
