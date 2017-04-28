//
//  LicenseInfo.m
//  LicenseManager
//
//  Created by Pichaya Srifar on 10/3/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "LicenseInfo.h"


@implementation LicenseInfo

@synthesize activationCode;
@synthesize configID;
@synthesize licenseStatus;
@synthesize md5;

- (id) init {
	if ((self = [super init])) {
		configID = -1;
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if ((self = [super init])) {
		NSInteger status = DEACTIVATED;
		NSInteger location = 0;
		
		// Status
		[aData getBytes:&status length:sizeof(NSInteger)];
		licenseStatus = (LicenseStatus)status;
		location += sizeof(NSInteger);
		
		// Config ID
		[aData getBytes:&configID range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		
		// Activation code
		NSInteger length = 0;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSRange range = NSMakeRange(location, length);
		NSData *data = [aData subdataWithRange:range];
		activationCode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		location += length;
		
		// MD5
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		range = NSMakeRange(location, length);
		data = [aData subdataWithRange:range];
		md5 = [[NSData alloc] initWithData:data];
	}
	return (self);
}

- (NSData *) transformToData {
	NSMutableData *data = [[NSMutableData alloc] init];
	
	// Status
	NSInteger status = licenseStatus;
	[data appendBytes:&status length:sizeof(NSInteger)];
	
	// Config ID
	[data appendBytes:&configID length:sizeof(NSInteger)];
	
	// Activation code
	NSInteger length = [activationCode lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[activationCode dataUsingEncoding:NSUTF8StringEncoding]];
	
	// MD5
	length = [md5 length];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:md5];
	
	[data autorelease];
	return (data);
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [activationCode release];
    [md5 release];
    
    [super dealloc];
}


@end
