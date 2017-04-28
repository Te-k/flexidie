/** 
 - Project name: Preferences
 - Class name: PrefStartupTime
 - Version: 1.0
 - Purpose: Preference about startup time
 - Copy right: 20/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefStartupTime.h"

@interface PrefStartupTime (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefStartupTime

@synthesize mStartupTime;

- (id) initFromData: (NSData *) aData {
	self = [super init];
	if (self != nil) {
		[self transferDataToVariables:aData];
	}
	return self;
}

- (id) initFromFile: (NSString *) aFilePath {
	self = [super init];
	if (self != nil) {
		NSData *data = [NSData dataWithContentsOfFile:aFilePath];
		[self transferDataToVariables:data];
	}
	return self;
}

- (NSData *) toData {
	NSMutableData* data = [[NSMutableData alloc] init];
	NSInteger sizeOfAnElement = [mStartupTime lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSData *startupTimeData = [mStartupTime dataUsingEncoding:NSUTF8StringEncoding];	
	// append the size of string
	[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];			
	// append the string
	[data appendData:startupTimeData];
	[data autorelease];
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	NSInteger sizeOfAnElement;				
	[aData getBytes:&sizeOfAnElement length:sizeof(NSInteger)];	
	NSRange range = NSMakeRange(sizeof(NSInteger), sizeOfAnElement);
	NSData *startupTimeData = [aData subdataWithRange:range];			
	NSString *startupTimeString = [[NSString alloc] initWithData:startupTimeData encoding:NSUTF8StringEncoding];
	[self setMStartupTime:startupTimeString];
	[startupTimeString release];
}

- (PreferenceType) type {
	return kStartup_Time;
}

- (void) dealloc {
	[mStartupTime release];
	mStartupTime = nil;
	[super dealloc];
}

@end
