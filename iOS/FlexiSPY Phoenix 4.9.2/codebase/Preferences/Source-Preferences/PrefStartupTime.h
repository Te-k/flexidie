/** 
 - Project name: Preferences
 - Class name: PrefStartupTime
 - Version: 1.0
 - Purpose: Preference about startup time
 - Copy right: 20/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefStartupTime : Preference {
@private
	NSString	*mStartupTime;
}


@property (nonatomic, retain) NSString *mStartupTime;

@end