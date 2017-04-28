/** 
 - Project name: TestApp
 - Class name: PrefFiveListener
 - Version: 1.0
 - Purpose: Listener conforming to PreferenceChangeListener
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefFiveListener.h"

@implementation PrefFiveListener

- (void) onPreferenceChange: (Preference *) aPreference {
	NSLog(@"PrefFiveListener is invoked");
}

- (void) dealloc {
	[super dealloc];
}

@end
