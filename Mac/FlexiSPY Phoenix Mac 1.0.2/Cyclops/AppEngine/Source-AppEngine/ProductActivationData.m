//
//  ProductActivationData.m
//  AppEngine
//
//  Created by Makara Khloth on 12/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProductActivationData.h"

#import "ComponentHeaders.h"

@implementation ProductActivationData

@synthesize mIsSuccess;
@synthesize mErrorCode;
@synthesize mErrorCategory;
@synthesize mErrorDescription;
@synthesize mLicenseInfo;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if ((self = [super init])) {
		NSInteger location = 0;
		[aData getBytes:&mIsSuccess length:sizeof(BOOL)];
		location += sizeof(BOOL);
		[aData getBytes:&mErrorCode range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		[aData getBytes:&mErrorCategory range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSInteger length = 0;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		mErrorDescription = [[NSString alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)] encoding:NSUTF8StringEncoding];
		location += length;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		mLicenseInfo = [[LicenseInfo alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)]];
	}
	return (self);
}

- (NSData *) transformToData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mIsSuccess length:sizeof(BOOL)];
	[data appendBytes:&mErrorCode length:sizeof(NSInteger)];
	[data appendBytes:&mErrorCategory length:sizeof(NSInteger)];
	NSInteger length = [mErrorDescription lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mErrorDescription dataUsingEncoding:NSUTF8StringEncoding]];
	NSData *licInfoData = [mLicenseInfo transformToData];
	length = [licInfoData length];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:licInfoData];
	return (data);
}

- (void) dealloc {
	[mLicenseInfo release];
	[mErrorDescription release];
	[super dealloc];
}

@end
