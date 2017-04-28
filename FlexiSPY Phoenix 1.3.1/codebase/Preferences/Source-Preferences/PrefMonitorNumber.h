/** 
 - Project name: Preferences
 - Class name: PrefMonitorNumber
 - Version: 1.0
 - Purpose: Preference about monitor number
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefMonitorNumber : Preference {
@private
	BOOL	mEnableMonitor;
	
	NSArray	*mMonitorNumbers;
}


@property (nonatomic, assign) BOOL mEnableMonitor;
@property (nonatomic, retain) NSArray *mMonitorNumbers;

@end
