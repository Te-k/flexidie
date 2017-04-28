/** 
 - Project name: Source_Preferences
 - Class name: PreferenceChangeListener
 - Version: 1.0
 - Purpose: 
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */
#import <Foundation/Foundation.h>

#import "Preference.h"

@protocol PreferenceChangeListener <NSObject>
@required
- (void) onPreferenceChange: (Preference *) aPreference;

@end
