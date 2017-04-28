/** 
 - Project name: Source_Preferences
 - Class name: PreferenceManager
 - Version: 1.0
 - Purpose: 
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@protocol PreferenceManager <NSObject>
@required
- (Preference *) preference: (PreferenceType) aPreferenceType;
- (void) savePreferenceAndNotifyChange: (Preference *) aPreference;
- (void) savePreference: (Preference *) aPreference; 
- (void) resetPreferences;

@end
