/** 
 - Project name: TestApp
 - Class name: PrefTwoListener
 - Version: 1.0
 - Purpose: Listener conforming to PreferenceChangeListener
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefTwoListener.h"


@implementation PrefTwoListener

- (void) onPreferenceChange: (Preference *) aPreference {
	NSLog(@"PrefTwoListener is invoked");
}

- (void) dealloc {
	[super dealloc];
}

@end
