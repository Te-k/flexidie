/** 
 - Project name: Preferences
 - Class name: Preference
 - Version: 1.0
 - Purpose: Base class of preferences
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "Preference.h"

@implementation Preference

@synthesize mType;

- (id) initFromData: (NSData *) aData {
	self = [super init];
	if (self != nil) {
	
	}
	return self;
}

- (id) initFromFile: (NSString *) aFilePath; {
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

- (NSData *) toData {
	return [NSData data];
}

- (void) reset {
}

- (void) dealloc {
	[super dealloc];
}

- (PreferenceType) type {
	return kPrefUnknown;
}

@end
