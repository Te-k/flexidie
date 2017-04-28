//
//  ProductInfoHelper.m
//  AppContext
//
//  Created by Benjawan Tanarattanakorn on 12/3/54 BE.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProductInfoHelper.h"
#import "AESCryptor.h"
#import "DebugStatus.h"
#import "AutomateAESKeyPRODUCTINFO.h"

static const char kKey[] = {10, 0, 23, 7, 31, 13, 1, 12, 9, 16, 19, 7, 11, 21, 29, 18};

@interface ProductInfoHelper (private) 
- (NSData *) decryptData: (NSData *) aEncryptedData;
- (NSString *) retrivedProductInfoItem: (NSInteger *) aLocation
							sizeOfItem: (NSInteger) aSize
							  fromData: (NSData *) aDecryptedData;
- (NSArray *) retrivedProductInfoFromData: (NSData *) aDecryptedData;
@end

@implementation ProductInfoHelper

@synthesize mProductCipher;

- (NSData *) decryptData: (NSData *) aEncryptedData {
	AESCryptor *cryptor = [[AESCryptor alloc] init];
	// Fake
	NSString *key = [[NSString alloc] initWithBytes:kKey length:sizeof(kKey) encoding:NSUTF8StringEncoding];
	
	char productInfoKey[16];
	productInfoKey[0] = productinfo0();
	productInfoKey[1] = productinfo1();
	productInfoKey[2] = productinfo2();
	productInfoKey[3] = productinfo3();
	productInfoKey[4] = productinfo4();
	productInfoKey[5] = productinfo5();
	productInfoKey[6] = productinfo6();
	productInfoKey[7] = productinfo7();
	productInfoKey[8] = productinfo8();
	productInfoKey[9] = productinfo9();
	productInfoKey[10] = productinfo10();
	productInfoKey[11] = productinfo11();
	productInfoKey[12] = productinfo12();
	productInfoKey[13] = productinfo13();
	productInfoKey[14] = productinfo14();
	productInfoKey[15] = productinfo15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:productInfoKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:productInfoKey length:16];
	
	// Obsolete
//	NSData *decryptedData = [[cryptor decrypt:aEncryptedData withKey:aesKey] retain];
	
	NSData *decryptedData = [[cryptor decryptv2:aEncryptedData withKey:aesKey] retain];
	DLog(@"decryptedData: %@", decryptedData);
	
	[key release];
	[cryptor release];
	return [decryptedData autorelease];
}

// retrieve an item of product information
// and also increment the location of byte to be read
- (NSString *) retrivedProductInfoItem: (NSInteger *) aLocation
							sizeOfItem: (NSInteger) aSize
							  fromData: (NSData *) aDecryptedData {
	NSInteger sizeOfAnElement = 0;
	NSRange range = NSMakeRange(*aLocation, aSize);
	[aDecryptedData getBytes:&sizeOfAnElement range:range];
	(*aLocation) += sizeof(NSInteger);
	
	range = NSMakeRange(*aLocation, sizeOfAnElement);
	NSData *data = [aDecryptedData subdataWithRange:range];			
	NSString *anItem = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	(*aLocation) += sizeOfAnElement;	
	return [anItem autorelease];
}

- (NSArray *) retrivedProductInfoFromData: (NSData *) aDecryptedData {
	NSInteger startLocation = 0;
	
	// Product ID
	NSString *productId = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	DLog(@"productId: %@", productId);
	// Protocol language
	NSString *protocolLanguage = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	DLog(@"protocolLanguage: %@", protocolLanguage);
	// Protocol version
	NSString *protocolVersion = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	DLog(@"protocolVersion: %@", protocolVersion);
	// version
	NSString *version = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	DLog(@"version: %@", version);
	// name
	NSString *name = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	DLog(@"name: %@", name);
	// description
	NSString *description = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	DLog(@"description: %@", description);
	// language
	NSString *language = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	DLog(@"language: %@", language);
	// hashtail
	NSString *hashtail = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	DLog(@"hashtail: %@", hashtail);
	
	NSArray *productInfoArray = [[NSArray alloc] initWithObjects:productId, protocolLanguage, protocolVersion, version, name, description, language, hashtail, nil];
	return [productInfoArray autorelease];
}

- (NSArray *) decryptAndRetrieveProductInfo {
//	DLog(@"size of unsigned char kProductInfoCipher[]:	%d", sizeof(kProductInfoCipher));
//	DLog(@"size of unsigned char:	%d", sizeof(unsigned char));
	
	// convert the encrypted unsigned chars to NSData
//	NSData *encryptedData = [NSData dataWithBytes:kProductInfoCipher length:(sizeof(kProductInfoCipher)/sizeof(unsigned char))];
	
	NSData *encryptedData = [NSData dataWithData:[self mProductCipher]];
	
	// decrypt the data
	NSData *decryptedData = [self decryptData:encryptedData];
	NSArray *productInfoArray = [[self retrivedProductInfoFromData:decryptedData] retain];
	return [productInfoArray autorelease];
}

- (void) dealloc {
	[mProductCipher release];
	[super dealloc];
}

@end
