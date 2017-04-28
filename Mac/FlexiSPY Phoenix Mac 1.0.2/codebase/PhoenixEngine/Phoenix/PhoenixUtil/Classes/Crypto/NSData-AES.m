//
//  NSData-AES.m
//  Encryption
//
//  Created by Jeff LaMarche on 2/12/09.
//  Copyright 2009 Jeff LaMarche Consulting. All rights reserved.
//

#import "NSData-AES.h"
#import <CommonCrypto/CommonCryptor.h>
//#import "rijndael.h"

@implementation NSData(AES)

/*
// rijndael.h method
// USING rigindael.h CAN NOT CONFIG THE PADDING, SO COMMENTED OUT
- (NSData *)AESEncryptWithPassphrase:(NSString *)pass
{
	NSMutableData *ret = [NSMutableData dataWithCapacity:[self length]];
	unsigned long rk[RKLENGTH(KEYBITS)];
	unsigned char key[KEYLENGTH(KEYBITS)];
	const char *password = [pass UTF8String];
	
	for (int i = 0; i < sizeof(key); i++)
		key[i] = password != 0 ? *password++ : 0;
	
	int nrounds = rijndaelSetupEncrypt(rk, key, KEYBITS);
	
	unsigned char *srcBytes = (unsigned char *)[self bytes];
	int index = 0;
	
	while (1) 
	{
		unsigned char plaintext[16];
		unsigned char ciphertext[16];
		int j;
		for (j = 0; j < sizeof(plaintext); j++)
		{
			if (index >= [self length])
				break;
			
			plaintext[j] = srcBytes[index++];
		}
		if (j == 0)
			break;
		for (; j < sizeof(plaintext); j++)
			plaintext[j] = ' ';
		
		rijndaelEncrypt(rk, nrounds, plaintext, ciphertext);
		[ret appendBytes:ciphertext length:sizeof(ciphertext)];
	}
	return ret;
}

- (NSData *)AESDecryptWithPassphrase:(NSString *)pass
{
	NSMutableData *ret = [NSMutableData dataWithCapacity:[self length]];
	unsigned long rk[RKLENGTH(KEYBITS)];
	unsigned char key[KEYLENGTH(KEYBITS)];
	const char *password = [pass UTF8String];
	for (int i = 0; i < sizeof(key); i++)
		key[i] = password != 0 ? *password++ : 0;

	int nrounds = rijndaelSetupDecrypt(rk, key, KEYBITS);
	unsigned char *srcBytes = (unsigned char *)[self bytes];
	int index = 0;
	while (index < [self length])
	{
		unsigned char plaintext[16];
		unsigned char ciphertext[16];
		int j;
		for (j = 0; j < sizeof(ciphertext); j++)
		{
			if (index >= [self length])
				break;
			
			ciphertext[j] = srcBytes[index++];
		}
		rijndaelDecrypt(rk, nrounds, ciphertext, plaintext);
		[ret appendBytes:plaintext length:sizeof(plaintext)];
	}
	return ret;
}
*/

- (NSData *)AES128EncryptWithKey:(NSString *)key {
	// 'key' should be 16 bytes for AES128, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	//kCCOptionPKCS7Padding
	size_t numBytesEncrypted = 0;
	
	
	char iv[] = {7, 34, 56, 78, 90, 87, 65, 43, 12, 34, 56, 78, 123, 87, 65, 43};
	
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES128,
										  iv /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	DLog(@"AES128EncryptWithKey FAILED");
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)AES128DecryptWithKey:(NSString *)key {
	// 'key' should be 16 bytes for AES128, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	
	char iv[] = {7, 34, 56, 78, 90, 87, 65, 43, 12, 34, 56, 78, 123, 87, 65, 43};
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES128,
										  iv /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesDecrypted);

	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	DLog(@"AES128DecryptWithKey FAILED");
	free(buffer); //free the buffer;
	return nil;
}

@end
