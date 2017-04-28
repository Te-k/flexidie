/** 
 - Project name: Preferences
 - Class name: PrefPanic
 - Version: 1.0
 - Purpose: Preference about panic
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefPanic.h"
#import "AESCryptor.h"

@interface PrefPanic (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefPanic

@synthesize mEnablePanicSound;

@synthesize mStartUserPanicMessage;
@synthesize mStopUserPanicMessage;
@synthesize mPanicLocationInterval;
@synthesize mPanicImageInterval;

@synthesize mPanicStart;
@synthesize mLocationOnly;

- (id) init {
	self = [super init];
	if (self != nil) {
		[self setMPanicImageInterval:4];
		[self setMPanicLocationInterval:60];
		[self setMEnablePanicSound:YES];
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

- (id) initFromFile: (NSString *) aFilePath
{
	self = [super init];
	if (self != nil) {
		NSData *data = [NSData dataWithContentsOfFile:aFilePath];
		[self transferDataToVariables:data];
	}
	return self;
}

- (NSData *) toData {
	NSMutableData* data = [[NSMutableData alloc] init];
	
	[data appendBytes:&mEnablePanicSound length:sizeof(BOOL)];
	
	NSInteger sizeOfAnElement = [mStartUserPanicMessage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSData *panicMessageData = [mStartUserPanicMessage dataUsingEncoding:NSUTF8StringEncoding];
	
	// append the size of string
	[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];
	// append the string
	[data appendData:panicMessageData];
	
	sizeOfAnElement = [mStopUserPanicMessage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	panicMessageData = [mStopUserPanicMessage dataUsingEncoding:NSUTF8StringEncoding];
	// append the size of string
	[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];
	// append the string
	[data appendData:panicMessageData];
	
	[data appendBytes:&mPanicLocationInterval length:sizeof(NSInteger)];
	[data appendBytes:&mPanicImageInterval length:sizeof(NSInteger)];
	[data appendBytes:&mPanicStart length:sizeof(BOOL)];
	[data appendBytes:&mLocationOnly length:sizeof(BOOL)];
	[data autorelease];
	
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	[aData getBytes:&mEnablePanicSound length:sizeof(BOOL)];
	NSRange range = NSMakeRange(sizeof(BOOL), sizeof(NSInteger));
	
	// get size of the string
	NSInteger sizeOfAnElement;
	[aData getBytes:&sizeOfAnElement range:range];					// 3rd instance variable: size of an element
	
	range = NSMakeRange(sizeof(BOOL) + sizeof(NSInteger), sizeOfAnElement);
	NSData *panicMessageData = [aData subdataWithRange:range];			// 3rd instance variable: element
	// convert NSData to NSString with encoding
	NSString *panicMessageString = [[NSString alloc] initWithData:panicMessageData encoding:NSUTF8StringEncoding];
	[self setMStartUserPanicMessage:panicMessageString];
	[panicMessageString release];
	panicMessageString = nil;
	
	NSInteger location = sizeof(BOOL) + sizeof(NSInteger) + sizeOfAnElement;
	range = NSMakeRange(location, sizeof(NSInteger));
	[aData getBytes:&sizeOfAnElement range:range];
	location += sizeof(NSInteger);
	range = NSMakeRange(location, sizeOfAnElement);
	panicMessageData = [aData subdataWithRange:range];
	panicMessageString = [[NSString alloc] initWithData:panicMessageData encoding:NSUTF8StringEncoding];
	[self setMStopUserPanicMessage:panicMessageString];
	[panicMessageString release];
	panicMessageString = nil;
	location += sizeOfAnElement;
	
	range = NSMakeRange(location, sizeof(NSInteger));
	[aData getBytes:&mPanicLocationInterval range:range];
	location += sizeof(NSInteger);
	range = NSMakeRange(location , sizeof(NSInteger));
	[aData getBytes:&mPanicImageInterval range:range];
	location += sizeof(NSInteger);
	[aData getBytes:&mPanicStart range:NSMakeRange(location, sizeof(BOOL))];
	location += sizeof(BOOL);
	[aData getBytes:&mLocationOnly range:NSMakeRange(location, sizeof(BOOL))];
}

- (PreferenceType) type {
	return kPanic;
}

- (void) reset {
	[self setMPanicImageInterval:4];
	[self setMPanicLocationInterval:60];
	[self setMEnablePanicSound:YES];
	[self setMPanicStart:NO];
	[self setMLocationOnly:NO];
	[self setMStartUserPanicMessage:@""];
	[self setMStopUserPanicMessage:@""];
}

- (void) dealloc {
	[mStartUserPanicMessage release];
	mStartUserPanicMessage = nil;
	[mStopUserPanicMessage release];
	mStopUserPanicMessage = nil;
	[super dealloc];
}

@end
