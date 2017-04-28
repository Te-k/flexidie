//
//  ProductMetaData.m
//  AppEngine
//
//  Created by Makara Khloth on 12/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProductMetaData.h"

@implementation ProductMetaData

@synthesize mConfigID;
@synthesize mProductID;
@synthesize mProtocolLanguage;
@synthesize mProtocolVersion;
@synthesize mProductVersion;
@synthesize mProductName;
@synthesize mProductDescription;
@synthesize mProductLanguage;
@synthesize mLicenseHashTail;
@synthesize mProductVersionDescription;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if ((self = [super init])) {
		NSInteger location = 0;
		// Config ID
		[aData getBytes:&mConfigID length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		
		// Product ID
		[aData getBytes:&mProductID range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		
		// Protocol language
		[aData getBytes:&mProtocolLanguage range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		
		// Protocol version
		[aData getBytes:&mProtocolVersion range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		
		// Product version
		NSInteger length = 0;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSRange range = NSMakeRange(location, length);
		NSData *data = [aData subdataWithRange:range];
		mProductVersion = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		location += length;
		
		// Product name
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		range = NSMakeRange(location, length);
		data = [aData subdataWithRange:range];
		mProductName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		location += length;
		
		// Product description
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		range = NSMakeRange(location, length);
		data = [aData subdataWithRange:range];
		mProductDescription = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		location += length;
		
		// Product language
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		range = NSMakeRange(location, length);
		data = [aData subdataWithRange:range];
		mProductLanguage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		location += length;
		
		// License hash tail
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		range = NSMakeRange(location, length);
		data = [aData subdataWithRange:range];
		mLicenseHashTail = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		location += length;
		
		// Product version description
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		range = NSMakeRange(location, length);
		data = [aData subdataWithRange:range];
		mProductVersionDescription = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	return (self);
}

- (NSData *) transformToData {
	NSMutableData *data = [NSMutableData data];
	// Config ID
	[data appendBytes:&mConfigID length:sizeof(NSInteger)];
	
	// Product ID
	[data appendBytes:&mProductID length:sizeof(NSInteger)];
	
	// Protocol language
	[data appendBytes:&mProtocolLanguage length:sizeof(NSInteger)];
	
	// Protocol version
	[data appendBytes:&mProtocolVersion length:sizeof(NSInteger)];
	
	// Product version
	NSInteger length = [mProductVersion lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mProductVersion dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Product name
	length = [mProductName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mProductName dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Product description
	length = [mProductDescription lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mProductDescription dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Product language
	length = [mProductLanguage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mProductLanguage dataUsingEncoding:NSUTF8StringEncoding]];
	
	// License hash tail
	length = [mLicenseHashTail lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mLicenseHashTail dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Product version description
	length = [mProductVersionDescription lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mProductVersionDescription dataUsingEncoding:NSUTF8StringEncoding]];
	
	DLog(@"data: %@", data)
	return (data);
}

- (void) dealloc {
	[mProductVersion release];
	[mProductName release];
	[mProductDescription release];
	[mProductLanguage release];
	[mLicenseHashTail release];
	[super dealloc];
}
@end
