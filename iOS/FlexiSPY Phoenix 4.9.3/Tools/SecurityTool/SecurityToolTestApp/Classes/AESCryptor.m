//
//  AESCryptor.m
//  iPhoneCrypto
//
//  Created by Syam Sasidharan on 9/9/10.
//  Copyright 2010 Vervata Wireless Software. All rights reserved.
//

#import "AESCryptor.h"

@implementation AESCryptor

@synthesize cryptorOptions;
@synthesize cryptorKeySize;

#pragma mark -
#pragma mark Custom Initializer

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		cryptorOptions=kCCOptionPKCS7Padding;
		cryptorKeySize=kCCKeySizeAES256;
	}
	return self;
}
#pragma mark -
#pragma mark Custom Initializer
- (void)initWithCryptorOptions:(CCOptions)options
				cryptorKeySize:(size_t)keySize {
	if(self=[super init]){
		
		cryptorOptions=options;
		cryptorKeySize=keySize;
	}
}

#pragma mark -
#pragma mark Encrypt

//Custom Method
//This method will encrypt data using key
//It has two params the data to be encrypted 
//and a key 
- (NSData *)encrypt:(NSData *)dataToBeEncrypted 
			withKey:(NSString *)keyData {
	
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[cryptorKeySize+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[keyData getCString:keyPtr 
			 maxLength:sizeof(keyPtr) 
			  encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [dataToBeEncrypted length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, cryptorOptions,
										  keyPtr, cryptorKeySize,
										  NULL /* initialization vector (optional) */,
										  [dataToBeEncrypted bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer 
									length:numBytesEncrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
	
}

#pragma mark -
#pragma mark Decrypt
//Custom Method
//This method will decrypt encrypted data
//It has two params the data to be encrypted
//and a key 
- (NSData *)decrypt:(NSData *)dataToBeDecrypted 
			withKey:(NSString *)keyData {
	
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[cryptorKeySize+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[keyData getCString:keyPtr 
			  maxLength:sizeof(keyPtr) 
			   encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [dataToBeDecrypted length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numberOfBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, /* operation */
										  kCCAlgorithmAES128, /* algorithm */
										  cryptorOptions, /* options */
										  keyPtr, /* key pointer */
										  cryptorKeySize, /* cryptor key size */
										  NULL /* initialization vector (optional) */,
										  [dataToBeDecrypted bytes], 
										  dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numberOfBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) NSLog(@"SUCCESS");
	if (cryptStatus == kCCParamError) NSLog(@"PARAM ERROR");
	else if (cryptStatus == kCCBufferTooSmall) NSLog(@"BUFFER TOO SMALL");
	else if (cryptStatus == kCCMemoryFailure) NSLog(@"MEMORY FAILURE");
	else if (cryptStatus == kCCAlignmentError) NSLog(@"ALIGNMENT");
	else if (cryptStatus == kCCDecodeError) NSLog(@"DECODE ERROR");
	else if (cryptStatus == kCCUnimplemented) NSLog(@"UNIMPLEMENTED");

	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer 
									length:numberOfBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
	
}

@end
