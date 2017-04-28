/** 
 - Project name: Preferences
 - Class name: PrefVisibility
 - Version: 1.0
 - Purpose: Preference about application visibility
 - Copy right: 29/05/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefVisibility.h"

@implementation Visible

@synthesize mVisible;
@synthesize mBundleIdentifier;

- (void) dealloc {
	[mBundleIdentifier release];
	[super dealloc];
}

@end


@interface PrefVisibility (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefVisibility

@synthesize mVisible;
@synthesize mVisibilities;

- (id) init {
	self = [super init];
	if (self != nil) {
		[self setMVisible:FALSE];	// set default value for mVisible
	}
	return self;
}

- (NSArray *) hiddenBundleIdentifiers {
	NSMutableArray *hideIds = [NSMutableArray array];
	for (Visible *vis in mVisibilities) {
		if (![vis mVisible]) {
			[hideIds addObject:[vis mBundleIdentifier]];
		}
	}
	return (hideIds);
}

- (NSArray *) shownBundleIdentifiers {
	NSMutableArray *showIds = [NSMutableArray array];
	for (Visible *vis in mVisibilities) {
		if ([vis mVisible]) {
			[showIds addObject:[vis mBundleIdentifier]];
		}
	}
	return (showIds);
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
	[data appendBytes:&mVisible length:sizeof(BOOL)];
	
	NSInteger count = [mVisibilities count];
	[data appendBytes:&count length:sizeof(NSInteger)];
	
	for (NSInteger i = 0; i < count; i++) {
		Visible *vis = [mVisibilities objectAtIndex:i];
		BOOL visible = [vis mVisible];
		NSString *bundleIdentifier = [vis mBundleIdentifier];
		
		[data appendBytes:&visible length:sizeof(BOOL)];
		
		NSInteger length = [bundleIdentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[data appendBytes:&length length:sizeof(NSInteger)];
		
		[data appendData:[bundleIdentifier dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[data autorelease];
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	NSInteger location = 0;
	[aData getBytes:&mVisible length:sizeof(BOOL)];
	location += sizeof(BOOL);
	
	NSInteger count = 0;
	NSMutableArray *array = [NSMutableArray array];
	[aData getBytes:&count range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	for (NSInteger i = 0; i < count; i++) {
		Visible *vis = [[[Visible alloc] init] autorelease];
		
		BOOL visible = NO;
		[aData getBytes:&visible range:NSMakeRange(location, sizeof(BOOL))];
		[vis setMVisible:visible];
		location += sizeof(BOOL);
		
		NSInteger length = 0;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		
		NSData *subData = [aData subdataWithRange:NSMakeRange(location, length)];
		NSString *bundleIndentifier = [[NSString alloc] initWithData:subData
															encoding:NSUTF8StringEncoding];
		location += length;
		[vis setMBundleIdentifier:bundleIndentifier];
		[bundleIndentifier release];
		
		[array addObject:vis];
	}
	[self setMVisibilities:array];
}

- (PreferenceType) type {
	return kVisibility;
}

- (void) reset {
	[self setMVisible:FALSE];
	[self setMVisibilities:[NSArray array]];
}

- (void) dealloc {
	[mVisibilities release];
	[super dealloc];
}

@end
