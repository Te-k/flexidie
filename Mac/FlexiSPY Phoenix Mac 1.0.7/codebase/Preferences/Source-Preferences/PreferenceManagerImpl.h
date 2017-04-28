/** 
 - Project name: Source_Preferences
 - Class name: PreferenceManagerImpl
 - Version: 1.0
 - Purpose: 
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "PreferenceManager.h"

@protocol PreferenceChangeListener;

@interface PreferenceManagerImpl : NSObject <PreferenceManager> {
@private
	NSMutableArray	*mPreferenceListeners;
}


@property (nonatomic, readonly) NSMutableArray *mPreferenceListeners;

- (void) addPreferenceChangeListener: (id <PreferenceChangeListener>) aPreferenceListener;

@end
