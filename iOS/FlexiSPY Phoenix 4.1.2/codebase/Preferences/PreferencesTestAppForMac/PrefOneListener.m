/** 
 - Project name: TestApp
 - Class name: PrefOneListener
 - Version: 1.0
 - Purpose: Listener conforming to PreferenceChangeListener
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefOneListener.h"


@implementation PrefOneListener

- (void) onPreferenceChange: (Preference *) aPreference {
	NSLog(@"PrefOneListener is invoked");
}

- (void) dealloc {
	[super dealloc];
}

@end
