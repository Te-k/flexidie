/** 
 - Project name: TestApp
 - Class name: PrefThreeListener
 - Version: 1.0
 - Purpose: Listener conforming to PreferenceChangeListener
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */


#import "PrefThreeListener.h"


@implementation PrefThreeListener

- (void) onPreferenceChange: (Preference *) aPreference {
	NSLog(@"PrefThreeListener is invoked");
}

- (void) dealloc {
	[super dealloc];
}

@end
