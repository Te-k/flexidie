/** 
 - Project name: Preferences
 - Class name: PrefDeviceLock
 - Version: 1.0
 - Purpose: Preference about device lock (Alert)
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefDeviceLock.h"
#import "AESCryptor.h"

@interface PrefDeviceLock (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefDeviceLock

@synthesize mEnableAlertSound;
@synthesize mDeviceLockMessage;
@synthesize mLocationInterval;
@synthesize mStartAlertLock;

- (id) init {
	self = [super init];
	if (self != nil) {
		[self setMLocationInterval:60];		// default threshold is 1 minute
	}
	return self;
}

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
	
	[data appendBytes:&mEnableAlertSound length:sizeof(BOOL)];				// 1st instance variable
	
	NSInteger sizeOfAnElement = [mDeviceLockMessage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSData *deviceLockMessageData = [mDeviceLockMessage dataUsingEncoding:NSUTF8StringEncoding];
	
	// append the size of string
	[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];			// 2nd instance variable
	// append the string
	[data appendData:deviceLockMessageData];
	[data appendBytes:&mLocationInterval length:sizeof(NSInteger)];			// 3rd instance variable
	[data appendBytes:&mStartAlertLock length:sizeof(BOOL)];
	[data autorelease];
	
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	[aData getBytes:&mEnableAlertSound length:sizeof(BOOL)];
	
	NSRange range = NSMakeRange(sizeof(BOOL), sizeof(NSInteger));			// 1st instance variable
	
	// keep the position of the current byte to read
	NSInteger sizeOfAnElement;
	
	[aData getBytes:&sizeOfAnElement range:range];							// 2nd instance variable
	range = NSMakeRange(sizeof(BOOL) + sizeof(NSInteger), sizeOfAnElement);
	NSData *deviceLockMessageData = [aData subdataWithRange:range];			
	NSString *deviceLockMessageString = [[NSString alloc] initWithData:deviceLockMessageData encoding:NSUTF8StringEncoding];
	[self setMDeviceLockMessage:deviceLockMessageString];
	[deviceLockMessageString release];
	
	range = NSMakeRange(sizeof(BOOL) + sizeof(NSInteger) + sizeOfAnElement, sizeof(NSInteger));
	[aData getBytes:&mLocationInterval range:range];						// 3rd instance variable
	
	NSInteger location = sizeof(BOOL) + sizeof(NSInteger) + sizeOfAnElement + sizeof(NSInteger);
	[aData getBytes:&mStartAlertLock range:NSMakeRange(location, sizeof(BOOL))];
}

- (PreferenceType) type {
	return kAlert;
}

- (void) reset {
	[self setMLocationInterval:60];		// default threshold is 1 minute
	[self setMEnableAlertSound:YES];
	[self setMDeviceLockMessage:@""];
	[self setMStartAlertLock:NO];
}

- (void) dealloc {
	[mDeviceLockMessage release];
	mDeviceLockMessage = nil;
	[super dealloc];
}

@end
