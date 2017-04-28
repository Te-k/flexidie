/** 
 - Project name: Source_Preferences
 - Class name: PreferenceStore
 - Version: 1.0
 - Purpose: 
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "PreferenceChangeListener.h"

@class Preference;

@interface PreferenceStore : NSObject {

}


- (void) savePreference: (Preference *) aPreference;
- (Preference *) loadPreference: (PreferenceType) aPrefType;

@end
