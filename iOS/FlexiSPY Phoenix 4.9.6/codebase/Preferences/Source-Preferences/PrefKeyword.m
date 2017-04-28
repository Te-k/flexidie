/** 
 - Project name: Preferences
 - Class name: PrefKeyword
 - Version: 1.0
 - Purpose: Preference about keyword
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefKeyword.h"
#import "AESCryptor.h"

@interface PrefKeyword (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefKeyword

@synthesize mKeywords;

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
	
	// append a number of array elements, size of each element and each element to the data
	NSInteger numberOfElements = [mKeywords count];
	[data appendBytes:&numberOfElements length:sizeof(NSInteger)];			
	
	// append the size of each element and element itself
	for (NSString *anElement in mKeywords) {
		NSInteger sizeOfAnElement = [anElement lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];			
		
		NSData *elementData = [anElement dataUsingEncoding:NSUTF8StringEncoding];
		[data appendData:elementData];											
	}
	[data autorelease];
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	// get a number of elements in array
	NSInteger numberOfElements = 0;
	[aData getBytes:&numberOfElements length:sizeof(NSInteger)];		
	NSInteger location = sizeof(NSInteger);	
	
	NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < numberOfElements; i++) {
		NSRange range = NSMakeRange(location, sizeof(NSInteger));		
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
    [self setMKeywords:array];
}

- (PreferenceType) type {
	return kKeyword;
}

- (void) reset {
	[self setMKeywords:[NSArray array]];
}

- (void) dealloc {
    [mKeywords release];
	mKeywords = nil;
	[super dealloc];
}

@end
