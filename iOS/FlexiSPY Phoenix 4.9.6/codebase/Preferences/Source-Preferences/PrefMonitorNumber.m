/** 
 - Project name: Preferences
 - Class name: PrefMonitorNumber
 - Version: 1.0
 - Purpose: Preference about monitor number
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefMonitorNumber.h"
#import "PrefUtils.h"
#import "AESCryptor.h"

@interface PrefMonitorNumber (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefMonitorNumber

@synthesize mEnableMonitor;
@synthesize mMonitorNumbers;
@synthesize mEnableCallConference;

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
	[data appendBytes:&mEnableMonitor length:sizeof(BOOL)];			
	
	// append a number of array elements, size of each element and each element to the data
	NSInteger numberOfElements = [mMonitorNumbers count];
	[data appendBytes:&numberOfElements length:sizeof(NSInteger)];			
	for (NSString *anElement in mMonitorNumbers) {
		NSInteger sizeOfAnElement = [anElement lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];			
		
		NSData *elementData = [anElement dataUsingEncoding:NSUTF8StringEncoding];
		[data appendData:elementData];
	}
    
    [data appendBytes:&mEnableCallConference length:sizeof(BOOL)];
	[data autorelease];
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	[aData getBytes:&mEnableMonitor length:sizeof(BOOL)];
	
	// keep the position of the current byte to read
	NSInteger location = sizeof(BOOL); 
	
	// get a number of element in array
	NSRange range = NSMakeRange(location, sizeof(NSInteger));	
	NSInteger numberOfElements = 0;
	[aData getBytes:&numberOfElements range:range];						
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
    
    BOOL notExceedLength = YES;
    
    // -- Get mEnableCallConference
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnableCallConference range:range];
        location += sizeof(BOOL);
        DLog (@"location (1), mEnableCallConference %d", (int)location);
    }
    
    [self setMMonitorNumbers:array];
}

- (PreferenceType) type {
	return kMonitor_Number;
}

- (void) reset {
	[self setMMonitorNumbers:[NSArray array]];
	[self setMEnableMonitor:NO];
    self.mEnableCallConference = NO;
}

- (void) dealloc {
	[mMonitorNumbers release];
	mMonitorNumbers = nil;
	[super dealloc];
}

@end
