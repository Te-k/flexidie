//
//  ResponseUrlProfileProvider.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ResponseUrlProfileProvider.h"
#import "UrlProfileInfo.h"

enum {
	kAllowUrlParse,
	kDisAllowUrlParse
};

@interface ResponseUrlProfileProvider (private)
- (NSInteger) allowUrlCount;
- (NSInteger) disallowUrlCount;
- (void) removeFile;
@end

@implementation ResponseUrlProfileProvider

- (id) initWithFilePath: (NSString *) aFilePath offset: (NSInteger) aOffset {
	self = [super init];
	if (self) {
		mFilePath = [[NSString alloc] initWithString:aFilePath];
		mOffset = aOffset;
		mFileHandle = [[NSFileHandle fileHandleForReadingAtPath:mFilePath] retain];
		[mFileHandle seekToFileOffset:mOffset];
		mAllowUrlCount = [self allowUrlCount];
		mIndex = 0;
		mStep = kAllowUrlParse;
	}
	return (self);
}

- (id) getObject {
	DLog (@">>>> getObject")
	UrlProfileInfo *urlProfileInfo = [[UrlProfileInfo alloc] init];
	NSString *url = nil;
	NSString *browser = nil;
	uint16_t urlSize = 0;
	uint8_t browserSize = 0;
	
	// Url
	NSData *subData = [mFileHandle readDataOfLength:sizeof(uint16_t)];
	[subData getBytes:&urlSize length:sizeof(uint16_t)];
	urlSize = ntohs(urlSize);
	subData = [mFileHandle readDataOfLength:urlSize];
	url = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
	
	// Browser name
	subData = [mFileHandle readDataOfLength:sizeof(uint8_t)];
	[subData getBytes:&browserSize length:sizeof(uint8_t)];
	subData = [mFileHandle readDataOfLength:browserSize];
	browser = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
	
	[urlProfileInfo setMUrl:url];
	[urlProfileInfo setMBrowser:browser];
	
	[url release];
	[browser release];
	mIndex++;
	return ([urlProfileInfo autorelease]);
}

- (BOOL) hasNext {
	DLog (@">>>>> hasNext")
	BOOL hasNext = NO;
	if (mStep == kAllowUrlParse) {
		if (mIndex < mAllowUrlCount) {
			hasNext = YES;
		} else {
			mIndex = 0;
			mStep = kDisAllowUrlParse;
			mDisAllowUrlCount = [self disallowUrlCount];
//			if (mIndex < mDisAllowUrlCount) {
//				hasNext = YES;
//			} else {
//				hasNext = NO;
//			}
		}
	} else if (mStep == kDisAllowUrlParse) {
		if (mIndex < mDisAllowUrlCount) {
			hasNext = YES;
		}
	}
	return (hasNext);
}

- (NSInteger) allowUrlCount {
	uint16_t allowCount = 0;
	NSData *data = [mFileHandle readDataOfLength:sizeof(uint16_t)];
	[data getBytes:&allowCount length:sizeof(uint16_t)];
	allowCount = ntohs(allowCount);
	DLog(@"allowCount %d", allowCount)
	return (allowCount);
}

- (NSInteger) disallowUrlCount {
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
