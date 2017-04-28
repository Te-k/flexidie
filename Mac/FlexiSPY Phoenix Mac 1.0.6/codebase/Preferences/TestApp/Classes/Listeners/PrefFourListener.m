/** 
 - Project name: TestApp
 - Class name: PrefFourListener
 - Version: 1.0
 - Purpose: Listener conforming to PreferenceChangeListener
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefFourListener.h"

@implementation PrefFourListener

- (void) onPreferenceChange: (Preference *) aPreference {
	NSLog(@"PrefFourListener is invoked");
}

- (void) dealloc {
	[super dealloc];
}

@end
