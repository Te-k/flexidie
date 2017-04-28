//
//  UrlsProfile.m
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UrlsProfile.h"

@interface UrlsProfile (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation UrlsProfile

@synthesize mDBID;
@synthesize mUrl;
@synthesize mBrowser;
@synthesize mAllow;

- (id) initFromData: (NSData *) aData {
	if ((self = [super init])) {
		if (aData) {
			[self parseFromData:aData];
		}
	}
	return (self);
}

- (id) init {
	if ((self = [super init])) {
		mAllow = YES;
	}
	return (self);
}

- (NSData *) toData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mDBID length:sizeof(NSInteger)];
	NSInteger length = [mUrl lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mUrl dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mBrowser lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mBrowser dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendBytes:&mAllow length:sizeof(BOOL)];
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	[aData getBytes:&mDBID length:sizeof(NSInteger)];
	location += sizeof(NSInteger);
	NSInteger length = 0;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSData *someData = [aData subdataWithRange:NSMakeRange(location, length)];
	mUrl = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
	location += length;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	someData = [aData subdataWithRange:NSMakeRange(location, length)];
	mBrowser = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
	location += length;
	[aData getBytes:&mAllow range:NSMakeRange(location, sizeof(BOOL))];
}

/*
 NSInteger	mDBID;
 NSString	*mUrl;
 NSString	*mBrowser;
 BOOL		mAllow;
 */
- (NSString *) description {
	return [NSString stringWithFormat:@"DBID: %d--mUrl: %@--mBrowser: %@--mAllow %d", mDBID, mUrl, mBrowser, mAllow];
}

- (void) dealloc {
	[mUrl release];
	[mBrowser release];
	[super dealloc];
}

@end
