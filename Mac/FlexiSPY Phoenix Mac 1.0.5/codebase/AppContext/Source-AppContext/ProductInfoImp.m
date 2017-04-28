//
//  ProductInfoImp.m
//  AppContext
//
//  Created by Dominique  Mayrand on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProductInfoImp.h"
#import "ProductInfoHelper.h"
#import "DebugStatus.h"
#import "VersionInfo.h"

#if TARGET_OS_IPHONE
#import "PhoneInfoImp.h"
#else
#import "MacInfoImp.h"
#endif

#import "CRC32.h"

@implementation ProductInfoImp

@synthesize mPhoneInfo;

-(id) initWithProductCipher: (NSData *) aProductCipher {
	self = [super init];
	productVersion = nil;
	productName = nil;
	productDescription = nil;
	productLanguage = nil;
	protocolHashTail = nil;
	
	if(self)
	{
		ProductInfoHelper *helper = [[ProductInfoHelper alloc] init];
		[helper setMProductCipher:aProductCipher];
		NSArray *productInfoArray = [helper decryptAndRetrieveProductInfo];
		[helper release];
		
		NSNumberFormatter* numberFormat = [[NSNumberFormatter alloc] init];
		NSNumber *number = [numberFormat numberFromString:[productInfoArray objectAtIndex:0]];
		productID = [number intValue];
		number = [numberFormat numberFromString:[productInfoArray objectAtIndex:1]];
		mLanguage = [number intValue];
		number = [numberFormat numberFromString:[productInfoArray objectAtIndex:2]];
		protocolVersion = [number intValue];
		[numberFormat release];
		
		productVersion = [[productInfoArray objectAtIndex:3] retain];
		productName = [[productInfoArray objectAtIndex:4] retain]; 
		productDescription = [[productInfoArray objectAtIndex:5] retain];
		productLanguage = [[productInfoArray objectAtIndex:6] retain];
		protocolHashTail = [[productInfoArray objectAtIndex:7] retain];
		
		VersionInfo *versionInfo = [[VersionInfo alloc] init];
		[productVersion release];
        
		productVersion = [[NSString alloc] initWithFormat:@"%@", [versionInfo version]];
        
		mBuildDate =  [[NSString alloc] initWithFormat:@"%@", [versionInfo mBuildDate]]; // Crash in Mac if we used initWithString method

		mProductFullVersion = [[NSString alloc] initWithFormat:@"%@.%@.%@", [versionInfo mMajor], [versionInfo mMinor], [versionInfo mBuild]];
		[versionInfo release];
        
        DLog(@"Product Id: %ld", (long)NSINTEGER_DLOG(productID))
		DLog(@"Protocol language: %ld", (long)NSINTEGER_DLOG(mLanguage))
		DLog(@"Protocol version: %ld", (long)NSINTEGER_DLOG(protocolVersion))
		DLog(@"product version: %@", productVersion);
		DLog(@"product name: %@", productName);
		DLog(@"product description: %@", productDescription);
		DLog(@"product language: %@", productLanguage);
		DLog(@"product hashtail: %@", protocolHashTail);
		DLog(@"Product full version: %@", mProductFullVersion);
	}
	return self;
}

- (void) dealloc {
	if(productVersion) [productVersion release];
	if(productName) [productName release];
	if(productDescription) [productDescription release];
	if(productLanguage) [productLanguage release];
	if(protocolHashTail) [protocolHashTail release];
	[mBuildDate release];
	[mProductFullVersion release];
	[super dealloc];
}

-(NSInteger) getProductID {
	return productID;
}

- (NSInteger) getLanguage {
	return (mLanguage);
}

-(NSString*) getProductVersion {
	return productVersion;
}

-(NSString*) getProductName {
	return productName;
}

-(NSString*) getProductDescription {
	return productDescription;
}

-(NSString*) getProductLanguage {
	return productLanguage;
}

-(NSInteger) getProtocolVersion {
	return protocolVersion;
}

-(NSString*) getProtocolHashTail {
	return protocolHashTail;
}

-(NSString*) getProductVersionDescription {
	VersionInfo *versionInfo = [[VersionInfo alloc] init];
	NSString *versionDescription = [[versionInfo versionDescription] retain];
	[versionInfo release];
	return [versionDescription autorelease];
}

- (NSString *) getBuildDate {
	return (mBuildDate);
}

- (NSString *) notificationStringForCommand: (NSInteger) aCommandID
						 withActivationCode: (NSString *) aActivationCode
									withArg: (id) aArg {
	// PX2UIZVPNO
	NSString *tails = [NSString stringWithFormat:@"%@", @"P"];
	tails = [tails stringByAppendingString:@"X"];
	tails = [tails stringByAppendingString:@"2"];
	tails = [tails stringByAppendingString:@"U"];
	tails = [tails stringByAppendingString:@"I"];
	tails = [tails stringByAppendingString:@"Z"];
	tails = [tails stringByAppendingString:@"V"];
	tails = [tails stringByAppendingString:@"P"];
	tails = [tails stringByAppendingString:@"N"];
	tails = [tails stringByAppendingString:@"O"];
	
	// CMD + IMEI + Activation code + tails
	NSString *str2crc32 = [NSString stringWithFormat:@"%d%@%@%@", aCommandID, [mPhoneInfo getIMEI], aActivationCode, tails];
	NSData *data2crc32 = [str2crc32 dataUsingEncoding:NSUTF8StringEncoding];
	uint32_t crc32 = [CRC32 crc32:data2crc32];
	NSString *crc32Str = [NSString stringWithFormat:@"%08X", crc32];
	NSString *noticationStr = nil;
	switch (aCommandID) {
		case kNotificationCallInprogressCommandID: {
			// <CMD><IMEI><CRC32><Phone number> // CRC32 must be hex format string with 8 digits
			noticationStr = [NSString stringWithFormat:@"<%d><%@><%@><%@>", aCommandID, [mPhoneInfo getIMEI], crc32Str, aArg];
		} break;
		case kNotificationSIMChangeCommandID: {
		case kNotificationReportPhoneNumberCommandID:
		case kNotificationRequestPhoneNumberCommandID:
			// <CMD><IMEI><CRC32> // CRC32 must be hex format string with 8 digits
			noticationStr = [NSString stringWithFormat:@"<%d><%@><%@>", aCommandID, [mPhoneInfo getIMEI], crc32Str];
		} break;
		default:
			break;
	}
	DLog (@"CMD = %ld, IMEI = %@, CRC32 = %@, format string = %@", (long)NSINTEGER_DLOG(aCommandID), [mPhoneInfo getIMEI], crc32Str, noticationStr);
	return (noticationStr);
}

- (NSString *) getProductFullVersion {
	return (mProductFullVersion);
}

@end
