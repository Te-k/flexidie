/** 
 - Project name: Preferences
 - Class name: PrefLocation
 - Version: 1.0
 - Purpose: Preference about location
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefLocation.h"
#import "AESCryptor.h"

@interface PrefLocation (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefLocation

@synthesize mEnableLocation;
@synthesize mLocationInterval;

- (id) initFromData: (NSData *) aData {
	 self = [self init];
	 if (self != nil) {
		 [self transferDataToVariables:aData];
	 }
	 return self;
}

- (id) initFromFile: (NSString *) aFilePath
{
	self = [self init];
	if (self != nil) {
		NSData *data = [NSData dataWithContentsOfFile:aFilePath];
		[self transferDataToVariables:data];
	}
	return self;
}

- (NSData *) toData {
	NSMutableData* data = [[NSMutableData alloc] init];
	[data appendBytes:&mEnableLocation length:sizeof(BOOL)];
	[data appendBytes:&mLocationInterval length:sizeof(NSInteger)];
	[data autorelease];
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	[aData getBytes:&mEnableLocation length:sizeof(BOOL)];
	NSRange range = NSMakeRange(sizeof(BOOL), sizeof(NSInteger));
	[aData getBytes:&mLocationInterval range:range];
}
	
- (PreferenceType) type {
	return kLocation;
}

- (void) reset {
	[self setMLocationInterval:300];
	[self setMEnableLocation:NO];
}

- (void) dealloc {
	[super dealloc];
}

@end
