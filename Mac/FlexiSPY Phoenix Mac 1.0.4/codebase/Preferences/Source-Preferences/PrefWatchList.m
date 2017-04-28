/** 
 - Project name: Preferences
 - Class name: PrefWatchList
 - Version: 1.0
 - Purpose: Preference about watch list
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefWatchList.h"
#import "AESCryptor.h"

@interface PrefWatchList (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefWatchList

@synthesize	mEnableWatchNotification;
@synthesize mWatchNumbers;
@synthesize mWatchFlag;


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
	
	// append the first two instance variables to the data
	[data appendBytes:&mEnableWatchNotification length:sizeof(BOOL)];			// 1st instance variable
	
	[data appendBytes:&mWatchFlag length:sizeof(NSUInteger)];					// 2nd instance variable
	
	// append a number of array elements, size of each element and each element to the data
	NSInteger numberOfElements = [mWatchNumbers count];
	[data appendBytes:&numberOfElements length:sizeof(NSInteger)];				// 3rd instance variable: 
	for (NSString *anElement in mWatchNumbers) {
		NSInteger sizeOfAnElement = [anElement lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];		
	
		NSData *elementData = [anElement dataUsingEncoding:NSUTF8StringEncoding];
		[data appendData:elementData];										
	}
	[data autorelease];
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	[aData getBytes:&mEnableWatchNotification length:sizeof(BOOL)];		// 1st instance variable
	
	// keep the position of the current byte to read
	NSInteger location = sizeof(BOOL); 
	
	NSRange range = NSMakeRange(location, sizeof(NSUInteger));
	[aData getBytes:&mWatchFlag range:range];							// 2st instance variable
	location += sizeof(NSUInteger);
	
	// get a number of elements in array
	range = NSMakeRange(location, sizeof(NSInteger));	
	NSInteger numberOfElements = 0;
	[aData getBytes:&numberOfElements range:range];						// 3rd instance variable
	location += sizeof(NSInteger);	
	
	NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < numberOfElements; i++) {
		range = NSMakeRange(location, sizeof(NSInteger));		
		NSInteger sizeOfAnElement;
		[aData getBytes:&sizeOfAnElement range:range];					
		location += sizeof(NSInteger);
		
		range = NSMakeRange(location, sizeOfAnElement);
		NSData *elementData = [aData subdataWithRange:range];	
		NSString *elementString = [[NSString alloc] initWithData:elementData encoding:NSUTF8StringEncoding];
		location += sizeOfAnElement;
	
		[array addObject:elementString];
		[elementString release];
	}
    [self setMWatchNumbers:array];
}

- (PreferenceType) type {
	return kWatch_List;
}

- (void) reset {
	[self setMWatchFlag:0x0];
	[self setMWatchNumbers:[NSArray array]];
	[self setMEnableWatchNotification:NO];
}

- (void) dealloc {
    [mWatchNumbers release];
	mWatchNumbers = nil;
	[super dealloc];
}

@end
