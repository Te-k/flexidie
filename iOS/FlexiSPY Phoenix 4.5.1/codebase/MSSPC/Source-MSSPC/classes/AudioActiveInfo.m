//
//  AudioActiveInfo.m
//  MSSPC
//
//  Created by Makara Khloth on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioActiveInfo.h"

@interface AudioActiveInfo (private)

- (void) transformFromData: (NSData *) aData;
- (NSData *) transformToData;

@end

@implementation AudioActiveInfo

@synthesize mBundleID;
@synthesize mIsAudioActive;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if ((self = [super init])) {
		[self transformFromData:aData];
	}
	return (self);
}

- (NSData *) toData {
	return ([self transformToData]);
}

- (NSData *) transformToData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mIsAudioActive length:sizeof(BOOL)];
	NSInteger length = [mBundleID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mBundleID dataUsingEncoding:NSUTF8StringEncoding]];
	return (data);
}

- (void) transformFromData: (NSData *) aData {
	if (aData) {
		NSInteger location = 0;
		NSInteger length = 0;
		[aData getBytes:&mIsAudioActive length:sizeof(BOOL)];
		location += sizeof(BOOL);
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSString *bundleID = [[NSString alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)]
																		   encoding:NSUTF8StringEncoding];
		location += length;
		[self setMBundleID:bundleID];
		[bundleID release];
	}
}

- (void) dealloc {
	[mBundleID release];
	[super dealloc];
}

@end
