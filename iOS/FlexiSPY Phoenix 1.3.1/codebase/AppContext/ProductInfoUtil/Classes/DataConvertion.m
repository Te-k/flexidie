/** 
 - Project name: ProductInfoUtil
 - Class name: DataConvertion
 - Version: 1.0
 - Purpose: Provide UI to retrieve product information, encrypt product information and write it to a file
 - Copy right: 3/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "DataConvertion.h"
#import "AESCryptor.h"

#import "AutomateAESKeyPRODUCTINFO.h"

static const char kKey[] = {10, 0, 23, 7, 31, 13, 1, 12, 9, 16, 19, 7, 11, 21, 29, 18};
//unsigned char kProductInfoCipher[] = {0xf3,0x73,0x46,0x96,0x65,0x79,0xa7,0xf7,0x7e,0x56,0x19,0x29,0xd,0x4c,0xd1,0xfb,0x1e,0xf9,0x80,0xd7,0x52,0xb9,0xf2,0xdb,0xcf,0xbb,0x1b,0x2a,0xe8,0xe0,0x99,0xa2,0x22,0xe2,0x70,0xf5,0x9b,0xd2,0x49,
//	0xca,0xca,0x9f,0x2d,0xe8,0xbd,0x24,0xde,0xb0,0xb6,0x9b,0xfb,0x1f,0xad,0x3e,0x2c,0x53,0xa1,0xcb,0x61,0x9c,0x35,0xdf,0xc4,0xaa};


// Encrypted with initial implementation key
/*
 Product Id			: 4100
 Protocol Language	: 1
 Protocol Version	: 1
 Product Version	: 1.0.0
 Product Name		: FlexiSPY
 Product Description: FlexiSPY Polymorphic Client
 Language			: English
 Hash Tail			: 1FD0EDB9EA
 */
/*
unsigned char kProductInfoCipher[] = {0xda,0x22,0xb0,0xc0,0x4c,0x1c,0xb2,0x15,
									  0x34,0xf6,0xf4,0x3d,0x63,0xf0,0x2,0xe5,
									  0x94,0xba,0xdc,0x48,0xe,0xd5,0xb5,0xdd,
									  0x54,0x75,0x20,0xcf,0xaa,0xd,0x82,0xf3,
									  0x4,0x96,0x9e,0x61,0xf7,0xa0,0xa6,0xb9,
									  0xb1,0xae,0xf5,0xe9,0x55,0x6f,0xc0,0xf5,
									  0x4a,0xeb,0xfc,0x51,0xb6,0x21,0x80,0x6d,
									  0x9b,0x1b,0x62,0x3b,0xb0,0x39,0xe4,0xfc,
									  0xc3,0xcf,0xca,0x4b,0xa8,0xd6,0x30,0x91,
									  0x31,0xa9,0xf1,0xe1,0x9a,0xb,0xa5,0x2c,
									  0x91,0xdb,0xd8,0x79,0x2d,0x86,0xe0,0xba,
									  0x33,0x54,0xae,0xfe,0x1f,0x9e,0xd2,0xfd};
*/

// Encryption used distributed keys
/*
 Product Id			: 4401
 Protocol Language	: 1
 Protocol Version	: 3
 Product Version	: 2.1.1
 Product Name		: FeelSecure
 Product Description: FeelSecure Polymorphic Client
 Language			: English
 Hash Tail			: 1FD0EDB9EA
 */
//unsigned char kProductInfoCipher[] = {0x55,0x3,0x8a,0xdd,0x3,0x39,0xe4,0x55,0x5b,
//										0x5d,0x99,0xa0,0x36,0xc,0xf4,0x8b,0x91,0x87,
//										0xb,0x75,0x94,0xd5,0x7f,0x7,0x3a,0xf7,0x8a,
//										0xdb,0x15,0xf7,0x11,0x39,0xfc,0x5e,0x38,0x6d,
//										0xa0,0xc0,0x19,0x95,0xdb,0x8f,0x84,0x40,0x44,
//										0x1e,0xbb,0xed,0x9a,0x66,0xc5,0xd0,0xc7,0xcb,
//										0x46,0x59,0x64,0x13,0xdc,0x71,0x15,0xcf,0xe3,
//										0xf6,0x84,0x30,0x75,0x1e,0xbd,0x17,0xe9,0x2e,
//										0x5a,0x56,0x25,0x35,0x93,0xeb,0xce,0xf6,0x8d,
//										0x7,0x93,0x53,0x5d,0xde,0xee,0xfd,0xb3,0x4,0x27,
//										0xa8,0xc2,0xfc,0xb0,0xf0,0x96,0x90,0xd6,0x59,0xa2,
//										0x6d,0xe1,0x3d,0xf0,0xc3,0x2a,0xb8,0xe,0xb9,0x28,0xa2};

unsigned char kProductInfoCipher[] = {0x73,0x26,0x8f,0x45,0xc5,0x2f,0xe3,0x95,0x1b,0x49,0xe7,0xb0,0xc0,0x4c,0x4a,0x3,0xbf,0x9a,0xe5,0x51,0xf7,0xe0,0xf6,0xd,0x4c,0x98,0x5c,0x33,0x1e,0xd2,0xee,0xe5,0xa9,0x7a,0x87,0xa3,0x1d,0x46,0xb9,0x20,0x7,0x15,0xc8,0x90,0x81,0x63,0xdb,0xd3,0xad,0x7f,0x7a,0xe5,0xbc,0xe0,0x7c,0x2d,0xd4,0x20,0xe3,0x44,0xd5,0x64,0x6a,0xce,0x7e,0x23,0x39,0x28,0xa7,0x34,0xf,0xac,0x9f,0x99,0x58,0x5c,0x4e,0x41,0x9a,0x2d,0x3a,0x4e,0xac,0xbf,0x12,0x92,0x25,0x86,0x41,0xd3,0x6e,0x4d,0x74,0xcb,0x6c,0x80,0x18,0x4e,0xdb,0xd2,0x6f,0x40,0xb3,0x3e,0x86,0x66,0x2c,0xa9,0x8d,0x2a,0xc7,0x3e,0xb1,0x53,0xe3,0x2a,0xaa,0x3b,0x9c,0xeb,0x9,0xd3,0x63,0x41,0xf5,0x5,0x28,0x1e};

@interface DataConvertion (private) 
- (void) convertToData;
- (void) encryptData;
- (NSString *) createStatementStringFromByte;
- (NSData *) decryptData: (NSData *) aEncryptedData;
- (NSString *) retrivedProductInfoItem: (NSInteger *) aLocation
							sizeOfItem: (NSInteger) aSize
							  fromData: (NSData *) aDecryptedData;
- (void) retrivedProductInfoFromData: (NSData *) aDecryptedData;
@end

@implementation DataConvertion

@synthesize mProductId;
@synthesize mProtocolLanguage;
@synthesize mProtocolVersion;
@synthesize mVersion;
@synthesize mName;
@synthesize mDescription;
@synthesize mLanguage;
@synthesize mHashtail;
@synthesize mProductData;
@synthesize mEncryptedProductData;

- (id) initWithProductInfoVersion: (NSString *) aVersion
							 name: (NSString *) aName
					  description: (NSString *) aDescription
						 language: (NSString *) aLanguage
						 hashtail: (NSString *) aHashtail {
	self = [super init];
	if (self != nil) {
		[self setMVersion:aVersion];
		[self setMName:aName];
		[self setMDescription:aDescription];
		[self setMLanguage:aLanguage];
		[self setMHashtail:aHashtail];
	}
	return self;
}

#pragma mark -
#pragma mark Encryption

// convert product info string to a bunch of NSData
- (void) convertToData {
	NSMutableData* data = [[NSMutableData alloc] init];
	
	// Product ID
	NSInteger size = [mProductId lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&size length:sizeof(NSInteger)];
	NSData *itemData = [mProductId dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:itemData];
	
	// Protocol language
	size = [mProtocolLanguage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&size length:sizeof(NSInteger)];
	itemData = [mProtocolLanguage dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:itemData];
	
	// Protocol version
	size = [mProtocolVersion lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&size length:sizeof(NSInteger)];
	itemData = [mProtocolVersion dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:itemData];
	
	// version
	size = [mVersion lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&size length:sizeof(NSInteger)];
	itemData = [mVersion dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:itemData];
	
	// name
	size = [mName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&size length:sizeof(NSInteger)];
	itemData = [mName dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:itemData];
	
	// description
	size = [mDescription lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&size length:sizeof(NSInteger)];
	itemData = [mDescription dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:itemData];
	
	// language
	size = [mLanguage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&size length:sizeof(NSInteger)];
	itemData = [mLanguage dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:itemData];
	
	// hashtail
	size = [mHashtail lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&size length:sizeof(NSInteger)];
	itemData = [mHashtail dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:itemData];
	
	NSLog(@"\n\nPlain NSData:	%@", data);
	[self setMProductData:data];
	[data release];
}

// encrypt product information data
- (void) encryptData {
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
	NSLog(@"Encryption, aesKey = %@", aesKey);
	
	NSData *encryptedData = [cryptor encryptv2:[self mProductData] withKey:aesKey];
	
	[key release];
	[cryptor release];
	[self setMEncryptedProductData:encryptedData];
}

// create a string statement from encrypted data
- (NSString *) createStatementStringFromByte {
	// convert data to byte
	unsigned char *encryptedDataByte = (unsigned char *)[[self mEncryptedProductData] bytes];
	
	NSLog(@"\n\nencryptedDataByte	:	%s", encryptedDataByte);

	NSMutableString *statement = [[NSMutableString stringWithString:@"unsigned char kProductInfoCipher[] = {"] retain];
	
	for (int i = 0; i < [mEncryptedProductData length]; i++) {
		[statement appendFormat:@"%@", @"0x"];
		printf("char %d	hex:%x dec:%d	char:%c \n", i, encryptedDataByte[i], encryptedDataByte[i], encryptedDataByte[i]);
		[statement appendFormat:@"%x", encryptedDataByte[i]];
		if (i < [mEncryptedProductData length] - 1) {
			[statement appendFormat:@"%@", @","];
		}
	}
	[statement appendFormat:@"%@", @"};"];
	return [statement autorelease];
}

- (void) encryptAndWriteToFile {
	[self convertToData];
	[self encryptData];
	NSString *statementString = [self createStatementStringFromByte];
	NSLog(@"\n\nstatement string	:	%@", statementString);
	[statementString writeToFile:@"/tmp/ProductInfo.dat" atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark -
#pragma mark Decryption

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
	
	// Bad thing is that aesKey is nil
//	NSString *aesKey = [[[NSString alloc] initWithBytes:productInfoKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:productInfoKey length:16];
	NSLog(@"Decryption, aesKey = %@", aesKey);
	
	NSData *decryptedData = [[cryptor decryptv2:aEncryptedData withKey:aesKey] retain];
	NSLog(@"\n\ndecryptedData %@", decryptedData);
	
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

- (void) retrivedProductInfoFromData: (NSData *) aDecryptedData {
	NSInteger startLocation = 0;
	
	// Product ID
	NSString *productId = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	NSLog(@"productId: %@", productId);
	
	// Protocol language
	NSString *protocolLanguage = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	NSLog(@"protocolLanguage: %@", protocolLanguage);
	
	// Protocol version
	NSString *protocolVersion = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	NSLog(@"protocolVersion: %@", protocolVersion);
	
	// version
	NSString *version = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	NSLog(@"version: %@", version);
	
	// name
	NSString *name = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	NSLog(@"name: %@", name);
	
	// description
	NSString *description = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	NSLog(@"description: %@", description);
	
	// language
	NSString *location = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	NSLog(@"location: %@", location);
	
	// hashtail
	NSString *hashtail = [self retrivedProductInfoItem:&startLocation sizeOfItem:sizeof(NSInteger) fromData:aDecryptedData];
	NSLog(@"hashtail: %@", hashtail);
}

- (void) decryptAndRetrieveProductInfo {
	NSLog(@"\n\nsize of unsigned char kProductInfoCipher[]:	%d", sizeof(kProductInfoCipher));
	NSLog(@"\n\nsize of unsigned char:	%d", sizeof(unsigned char));
	
	// convert the encrypted unsigned chars to NSData
	NSData *encryptedData = [NSData dataWithBytes:kProductInfoCipher length:(sizeof(kProductInfoCipher)/sizeof(unsigned char))];
	
	// decrypt the data
	NSData *decryptedData = [self decryptData:encryptedData];
	[self retrivedProductInfoFromData:decryptedData];	
}

- (void)dealloc {
	[mProductId release];
	[mProtocolLanguage release];
	[mProtocolVersion release];
    [mVersion release];
	[mName release];
	[mDescription release];
	[mLanguage release];
	[mHashtail release];
	[mProductData release];
	[mEncryptedProductData release];
    [super dealloc];
}


@end
