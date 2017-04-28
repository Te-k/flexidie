//
//  ResponseApplicationProfileProvider.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ResponseApplicationProfileProvider.h"
#import "ApplicationProfileInfo.h"

enum {
	kAllowAppParse,
	kDisAllowAppParse
};

@interface ResponseApplicationProfileProvider (private)
- (NSInteger) allowAppCount;
- (NSInteger) disallowAppCount;
- (void) removeFile;
@end

@implementation ResponseApplicationProfileProvider

- (id) initWithFilePath: (NSString *) aFilePath offset: (NSInteger) aOffset {
	self = [super init];
	if (self) {
		mFilePath = [[NSString alloc] initWithString:aFilePath];
		mOffset = aOffset;
		mFileHandle = [[NSFileHandle fileHandleForReadingAtPath:mFilePath] retain];
		[mFileHandle seekToFileOffset:mOffset];
		mAllowAppCount = [self allowAppCount];
		mIndex = 0;
		mNext = kAllowAppParse;
	}
	return (self);
}

- (id) getObject {
	DLog(@"getObject")
	ApplicationProfileInfo *applicationProfileInfo = [[ApplicationProfileInfo alloc] init];
	uint8_t type = 0;
	NSString *applicationID = nil;
	NSString *name = nil;
	
	uint16_t applicationIDSize = 0;
	uint16_t nameSize = 0;
	
	// Type
	NSData *subData = [mFileHandle readDataOfLength:sizeof(uint8_t)];
	[subData getBytes:&type length:sizeof(uint8_t)];
	DLog(@"type %d", type)
	
	// Application ID
	subData = [mFileHandle readDataOfLength:sizeof(uint8_t)];
	[subData getBytes:&applicationIDSize length:sizeof(uint8_t)];
	
	subData = [mFileHandle readDataOfLength:applicationIDSize];
	applicationID = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
	DLog(@"applicationID %@", applicationID)	
	// Name
	subData = [mFileHandle readDataOfLength:sizeof(uint8_t)];
	[subData getBytes:&nameSize length:sizeof(uint8_t)];
	
	subData = [mFileHandle readDataOfLength:nameSize];
	name = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
	DLog(@"name %@", name)	
	
	[applicationProfileInfo setMType:type];
	[applicationProfileInfo setMID:applicationID];
	[applicationProfileInfo setMName:name];
	
	[applicationID release];
	[name release];
	
	mIndex++;
	return ([applicationProfileInfo autorelease]);
}

- (BOOL) hasNext {
	DLog(@"hasNext")

	BOOL hasNext = NO;
	if (mNext == kAllowAppParse) {
		if (mIndex < mAllowAppCount) {
			hasNext = YES;
		} else {
			mIndex = 0;
			mNext = kDisAllowAppParse;
			mDisAllowAppCount = [self disallowAppCount];
			//			if (mIndex < mDisAllowAppCount) {
			//				hasNext = YES;
			//			} else {
			//				hasNext = NO;
			//			}
		}
	} else if (mNext == kDisAllowAppParse) {
		if (mIndex < mDisAllowAppCount) {
			hasNext = YES;
		}
	}
	return (hasNext);
}

- (NSInteger) allowAppCount {
	uint16_t allowCount = 0;
	NSData *data = [mFileHandle readDataOfLength:sizeof(uint16_t)];
	[data getBytes:&allowCount length:sizeof(uint16_t)];
	allowCount = ntohs(allowCount);
	DLog(@"allowAppCount %d", allowCount)
	return (allowCount);
}

- (NSInteger) disallowAppCount {
	uint16_t disallowCount = 0;
	NSData *data = [mFileHandle readDataOfLength:sizeof(uint16_t)];
	[data getBytes:&disallowCount length:sizeof(uint16_t)];
	disallowCount = ntohs(disallowCount);
	DLog(@"disallowCount %d", disallowCount)
	return (disallowCount);
}

- (void) removeFile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:mFilePath error:nil];
}

- (void) dealloc {
	[mFileHandle release];
	[self removeFile];
	[mFilePath release];
	[super dealloc];
}

@end
