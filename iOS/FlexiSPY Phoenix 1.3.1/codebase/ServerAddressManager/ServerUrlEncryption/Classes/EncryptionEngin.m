/** 
 - Project name: ServerUrlEncryption
 - Class name: EncryptionEngin
 - Version: 1.0
 - Purpose: Encrypt URLs and write them to a file
 - Copy right: 4/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "EncryptionEngin.h"
#import "AESCryptor.h"
#import "AutomateAESKeyURL.h"

static const char kKey[] = {10, 0, 23, 7, 31, 13, 1, 12, 9, 16, 19, 7, 11, 21, 29, 18};

// These three variables store encrypted values of the folowing texts
//		www.apple.com
//		www.google.com
//		www.gmail.com
//		www.hotmail.com
//		www.yahoo.com
//		www.something/something/something.com
unsigned char url01[] = {0xfc,0x94,0x88,0x48,0x5f,0xa4,0x9a,0xfb,0x6e,0xf8,0xcd,0x1,0x47,0x64,0x3,0xd0,0x1f,0xb8,0xa3,0x85,0x84,0xa9,0x4a,0xc4,0x9e,0xea,0x26,0x9,0x62,0x96,0x91,0xa6};
unsigned char url02[] = {0xa9,0xc5,0x9a,0xb3,0x9,0x38,0x15,0xb3,0x22,0xb3,0x7,0x21,0x3e,0x39,0x35,0xc6,0x69,0x6e,0xf3,0x64,0xb0,0xa,0x4c,0xcb,0x77,0xff,0x76,0x3c,0x37,0xf3,0x99,0x96};
unsigned char url03[] = {0x24,0x4d,0xc0,0x45,0xe0,0x50,0x1f,0x72,0xf,0xb0,0xcc,0xb9,0xc6,0x72,0xa9,0x5a,0xf3,0x5a,0xd9,0xe2,0xc3,0x44,0xd9,0x25,0xf3,0x12,0x6a,0xc,0x37,0x6a,0x3f,0xb6};
unsigned char url04[] = {0xd3,0x91,0x98,0xfd,0xcd,0x6e,0x1,0x44,0xfc,0xf7,0x5d,0x8,0xab,0xbc,0x43,0xab,0xd3,0x4a,0xd9,0x7,0xa7,0x8e,0xda,0xba,0xb5,0x8a,0x27,0xe1,0xc6,0x7a,0xfe,0xee};
unsigned char url05[] = {0x27,0x3b,0x57,0xcb,0xf4,0x27,0xc4,0xb4,0xfb,0x8b,0xe,0xfe,0x83,0x3,0x48,0x24,0xab,0x9c,0x32,0xfa,0x23,0x27,0x3f,0x9d,0xf9,0xd0,0x65,0x80,0x21,0xe8,0x8e,0xbc};
unsigned char url06[] = {0x48,0xae,0x20,0xa3,0x78,0x9e,0xf2,0x96,0x4e,0x3c,0xaf,0x71,0x2a,0x43,0x75,0xcc,0xbe,0xca,0xe2,0x97,0x3f,0x64,0xf2,0x4,0x2c,0x5,0x5f,0x8b,0x4f,0x6d,0x0,0xe8,0xf7,0x91,0x63,0x5b,0x75,0x37,0xa0,0x8c,0xd3,0x32,0xeb,0xa8,0x4d,0x3b,0x25,0xe1,0xb,0x31,0x9b,0x2b,0x28,0x33,0xe7,0xf8,0x63,0xc,0x60,0x87,0x1,0x5e,0xc8,0x14};
unsigned char kServerUrl[] = {0x8c,0xcb,0xd3,0x78,0xa3,0x1,0xb0,0x2b,0xe0,0x33,0xc7,0x3b,0x78,0x50,0xa0,0x84,0x3,
	0xb8,0xbc,0xb0,0x5c,0xc6,0x6d,0x3,0x74,0xa6,0xda,0x2e,0x4a,0xec,0xd6,0xed,0x55,0xeb,
	0xb3,0xc0,0x3c,0x7c,0x7f,0xbb,0x31,0xff,0x19,0xd9,0x96,0x7e,0x4a,0x9b};
unsigned char kServerUrl01[] = {0xfd,0x2,0x2e,0x5,0xb4,0x4a,0x82,0x5a,0xd1,0x9d,0xbf,0x31,0x5f,0x9c,0x9e,0x6b,0x71,0x94,
	0xb4,0x82,0x55,0x99,0x96,0x6e,0x55,0x49,0x89,0x52,0xe1,0xaa,0xc4,0x49,0xc9,0xb1,0xe8,
	0x76,0x42,0xf,0x86,0x4e,0x9e,0x9,0xf6,0x4d,0xc1,0x9a,0xc3,0x6e};

@interface EncryptionEngin (private)
// encryption
- (NSData *) encrypt: (NSData *) aUrlAndLengthData;
- (NSMutableString *) createURLStringForTwoDiArray: (NSArray *) aUrlArray maxSizeOfURL: (NSInteger) aMaxSize;
// decryption
- (NSString *) createURLString: (NSData *) aDecryptedData;
- (NSData *) decryptData: (NSData *) aUrlAndLengthData;
@end

@implementation EncryptionEngin

@synthesize  mURLs;

- (id) init {
	self = [super init];
	if (self != nil) {
		mURLs = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) addUrl: (NSString *) aUrl {
	[mURLs addObject:aUrl]; 
	NSLog(@"addUrl by EncryptionEngin: %@", [mURLs lastObject]);
	NSLog(@"In array %@", mURLs);
}


#pragma mark -
#pragma mark Encryption

- (NSData *) encrypt: (NSData *) aUrlAndLengthData {
	AESCryptor *cryptor = [[AESCryptor alloc] init];
	NSString *key = [[NSString alloc] initWithBytes:kKey length:sizeof(kKey) encoding:NSUTF8StringEncoding];
	
	char urlKey[16];
	urlKey[0] = url0();
	urlKey[1] = url1();
	urlKey[2] = url2();
	urlKey[3] = url3();
	urlKey[4] = url4();
	urlKey[5] = url5();
	urlKey[6] = url6();
	urlKey[7] = url7();
	urlKey[8] = url8();
	urlKey[9] = url9();
	urlKey[10] = url10();
	urlKey[11] = url11();
	urlKey[12] = url12();
	urlKey[13] = url13();
	urlKey[14] = url14();
	urlKey[15] = url15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:urlKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:urlKey length:16];
	
	// Obsolete
//	NSData *encryptedData = [[cryptor encrypt:aUrlAndLengthData withKey:aesKey] retain];
	
	NSData *encryptedData = [[cryptor encryptv2:aUrlAndLengthData withKey:aesKey] retain];
	
	[cryptor release];
	[key release];
	return	[encryptedData autorelease];
}

/**
 - Method name: encryptURLsAndWriteToFile
 - Purpose: Encrypt all urls and then write the encrypted urls to the file called "ServerUrl.h" in forms of
	an array as follows:
	"unsigned char url1[] = {0xfc,0x94,...};"
	"unsigned char url2[] = {0xa4,0x14,...};"
 - Argument list and description: No argument
 - Return description: No return
 */
- (void) encryptURLsAndWriteToFile {
	// Ensure that there is at lest one element in the array
	if ([mURLs lastObject]) {
		
		NSMutableString *urlString = [[NSMutableString alloc] init];
		
		for (int i = 0; i < [mURLs count] ; i++) {	
			// write size of URL
			NSInteger sizeOfUrl = [[mURLs objectAtIndex:i] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			NSMutableData *urlData = [[NSMutableData alloc] init];
			[urlData appendBytes:&sizeOfUrl length:sizeof(NSInteger)];
			// write string
			NSData *data = [[mURLs objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding];
			[urlData appendData:data];
			
			NSData *encryptedData = [self encrypt: urlData];
			[urlData release];
			
			// convert NSData to byte
			unsigned char *stringByte = (unsigned char *)[encryptedData bytes];
			
			// create url string
			[urlString appendString:@"unsigned char url"];
			[urlString appendFormat:@"%i", i+1];
			[urlString appendString:@"[] = {"];
			
		 	for (int j = 0; j < [encryptedData length]; j++) {
				[urlString appendString:@"0x"];
				[urlString appendFormat:@"%x", stringByte[j]]; 
				if (j < [encryptedData length]-1) {
					[urlString appendString:@","];
				}
			}
			[urlString appendString:@"};"];
			if (i < [mURLs count] - 1 ) {
				[urlString appendString:@"\n"];
			}
		}
		NSLog(@"url strings to be written to a file is: %@", urlString);
		[urlString writeToFile:@"/tmp/ServerUrl.h" atomically:YES encoding:NSUTF8StringEncoding error:nil];
		[urlString release];
	} else {
		NSLog(@"no url");
	}
}

- (NSMutableString *) createURLStringForTwoDiArray: (NSArray *) aUrlArray maxSizeOfURL: (NSInteger) aMaxSize {
	NSMutableString *urlArrayString = [[NSMutableString alloc] initWithString:@"unsigned char url[]["];
	[urlArrayString appendFormat:@"%d", aMaxSize];
	[urlArrayString appendString:@"] = {"];
	for (int i = 0; i < [aUrlArray count]; i++) {
		[urlArrayString appendFormat:@"%@", [aUrlArray objectAtIndex:i]];
		if (i < ([aUrlArray count] - 1)) {
			[urlArrayString appendString:@","];
		}
	}
	[urlArrayString appendString:@"};"];
	NSLog(@"url strings to be written to a file is: %@", urlArrayString);
	
	return [urlArrayString autorelease];
}

/**
 - Method name: encryptURLsAndWriteToFileWithTwoDiArray
 - Purpose: Encrypt all urls and then write the encrypted urls to the file called "ServerUrlTwoDimention.h"
	in form of 2 dimentional array as follows:
	unsigned char url[][48] = {
		{0xfc,0x94,...},
		{0xa9,0xc5,...},
		...,
		{0xfe,0x68,...}
	};
	And also write the size of each url to the file called "ServerUrlTwoDimentionSize.h"
 - Argument list and description: No argument
 - Return description: No return
 */
- (void) encryptURLsAndWriteToFileWithTwoDiArray {
	// Ensure that there is at lest one element in the array
	if ([mURLs lastObject]) {
		NSMutableArray *urlArray = [[NSMutableArray alloc] init];
		// store size of each url
		NSMutableString *urlSize = [NSMutableString stringWithString:@"NSInteger urlSize[] = {"];
		NSInteger maxSize = 0;
		NSInteger urlCount = [mURLs count];
		
		for (int i = 0; i < urlCount; i++) {	
			
			// write size of this URL to data
			NSInteger sizeOfUrl = [[mURLs objectAtIndex:i] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			NSMutableData *urlData = [[NSMutableData alloc] init];
			[urlData appendBytes:&sizeOfUrl length:sizeof(NSInteger)];
			
			// write URL to data
			NSData *data = [[mURLs objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding];
			[urlData appendData:data];
			
			// encryt url data
			NSData *encryptedData = [self encrypt: urlData];
			[urlData release];
			
			// convert encrypted url to byte
			unsigned char *stringByte = (unsigned char *)[encryptedData bytes];
	
			// find size of this encrypted url
			NSInteger sizeOfEncryptedUrl = [encryptedData length];
			
			[urlSize appendFormat:@"%d", sizeOfEncryptedUrl];
			if (i < (urlCount - 1)) {
				[urlSize appendString:@","];
			}
			//NSLog(@"size of encrypted url index %d, %d", i+1, sizeOfEncryptedUrl);
			
			// find the maximum size of url
			if (sizeOfEncryptedUrl > maxSize) {
				maxSize = sizeOfEncryptedUrl;
			}
			
			// create a url string
			NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"{"];
		 	for (int j = 0; j < sizeOfEncryptedUrl; j++) {
				[urlString appendString:@"0x"];
				[urlString appendFormat:@"%x", stringByte[j]]; 
				if (j < (sizeOfEncryptedUrl - 1)) {
					[urlString appendString:@","];
				}
			}
			[urlString appendString:@"}"];
			
			// add url string to array
			[urlArray addObject:urlString];
			[urlString release];
		}
		NSLog(@"urlArray %@", urlArray);

		// finalize url size
		[urlSize appendString:@"};"];
		NSLog(@"url size array %@", urlSize);
		[urlSize writeToFile:@"/tmp/ServerUrlTwoDimentionSize.h" atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		// create url array string
		NSMutableString *urlArrayString = [self createURLStringForTwoDiArray:urlArray maxSizeOfURL:maxSize];
		[urlArray release];
		[urlArrayString writeToFile:@"/tmp/ServerUrlTwoDimention.h" atomically:YES encoding:NSUTF8StringEncoding error:nil];
	} else {
		NSLog(@"no url");
	}
}


#pragma mark -
#pragma mark Decryption

/**
 - Method name: decryptURLs
 - Purpose: For testing the output created by encryptURLsAndWriteToFile.
	This method decrypts urls that was declared at the beginning of this class. These urls are stored in the file ServerUrl.h
	which is created in the method encryptURLsAndWriteToFile.
 - Argument list and description: No argument
 - Return description: No return
 */
- (void) decryptURLs {
	NSData *urlAndLengthData = [NSData dataWithBytes:url01 length:(sizeof(url01)/sizeof(unsigned char))];
	NSData *decryptedData = [self decryptData:urlAndLengthData];
	NSLog(@"decrypted data %@", decryptedData);
	NSString *urlString = [self createURLString:decryptedData];
	NSLog(@"URL string: %@", urlString);
	
	urlAndLengthData = [NSData dataWithBytes:url02 length:(sizeof(url02)/sizeof(unsigned char))];
	decryptedData =  [self decryptData:urlAndLengthData];
	NSLog(@"decrypted data %@", decryptedData);
	urlString = [self createURLString:decryptedData];
	NSLog(@"URL string: %@", urlString);
	
	urlAndLengthData = [NSData dataWithBytes:url03 length:(sizeof(url03)/sizeof(unsigned char))];
	decryptedData = [self decryptData:urlAndLengthData];
	NSLog(@"decrypted data %@", decryptedData);
	urlString = [self createURLString:decryptedData];
	NSLog(@"URL string: %@", urlString);
	
	urlAndLengthData = [NSData dataWithBytes:url04 length:(sizeof(url04)/sizeof(unsigned char))];
	decryptedData = [self decryptData:urlAndLengthData];
	NSLog(@"decrypted data %@", decryptedData);
	urlString = [self createURLString:decryptedData];
	NSLog(@"URL string: %@", urlString);
	
	urlAndLengthData = [NSData dataWithBytes:url05 length:(sizeof(url05)/sizeof(unsigned char))];
	decryptedData = [self decryptData:urlAndLengthData];
	NSLog(@"decrypted data %@", decryptedData);
	urlString = [self createURLString:decryptedData];
	NSLog(@"URL string: %@", urlString);
	
	urlAndLengthData = [NSData dataWithBytes:url06 length:(sizeof(url06)/sizeof(unsigned char))];
	decryptedData = [self decryptData:urlAndLengthData];
	NSLog(@"decrypted data %@", decryptedData);
	urlString = [self createURLString:decryptedData];
	NSLog(@"URL string: %@", urlString);
	
	urlAndLengthData = [NSData dataWithBytes:kServerUrl length:(sizeof(kServerUrl)/sizeof(unsigned char))];
	decryptedData = [self decryptData:urlAndLengthData];
	NSLog(@"decrypted data %@", decryptedData);
	urlString = [self createURLString:decryptedData];
	NSLog(@"URL string: %@", urlString);
	
	urlAndLengthData = [NSData dataWithBytes:kServerUrl01 length:(sizeof(kServerUrl01)/sizeof(unsigned char))];
	decryptedData = [self decryptData:urlAndLengthData];
	NSLog(@"decrypted data %@", decryptedData);
	urlString = [self createURLString:decryptedData];
	NSLog(@"URL string: %@", urlString);
}

- (NSData *) decryptData: (NSData *) aUrlAndLengthData {
	AESCryptor *cryptor = [[AESCryptor alloc] init];
	NSString *key = [[NSString alloc] initWithBytes:kKey length:sizeof(kKey) encoding:NSUTF8StringEncoding];
	
	char urlKey[16];
	urlKey[0] = url0();
	urlKey[1] = url1();
	urlKey[2] = url2();
	urlKey[3] = url3();
	urlKey[4] = url4();
	urlKey[5] = url5();
	urlKey[6] = url6();
	urlKey[7] = url7();
	urlKey[8] = url8();
	urlKey[9] = url9();
	urlKey[10] = url10();
	urlKey[11] = url11();
	urlKey[12] = url12();
	urlKey[13] = url13();
	urlKey[14] = url14();
	urlKey[15] = url15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:urlKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:urlKey length:16];
	
	// Obsolete
//	NSData *decryptedData = [[cryptor decrypt:aUrlAndLengthData withKey:aesKey] retain];
	
	NSData *decryptedData = [[cryptor decryptv2:aUrlAndLengthData withKey:aesKey] retain];
	[cryptor release];
	[key release];
	return [decryptedData autorelease];
}

- (NSString *) createURLString: (NSData *) aDecryptedData {
	NSInteger sizeOfUrl = 0;
	[aDecryptedData getBytes:&sizeOfUrl length:sizeof(NSInteger)];
	
	NSRange range = NSMakeRange(sizeof(NSInteger), sizeOfUrl);
	NSData *urlData = [aDecryptedData subdataWithRange:range];
	
	NSString *urlString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	return [urlString autorelease];
}


#pragma mark -

- (void) dealloc
{
	[mURLs release];
	[super dealloc];
}


@end
