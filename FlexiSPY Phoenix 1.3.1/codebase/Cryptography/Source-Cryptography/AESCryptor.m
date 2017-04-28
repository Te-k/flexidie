//
//  AESCryptor.m
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/13/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AESCryptor.h"
#import "NSData-AES.h"

@implementation AESCryptor

@synthesize cryptorOptions;
@synthesize cryptorKeySize;

#pragma mark -
#pragma mark Custom Initializer
- (id) init {
	self = [super init];
	if (self != nil) {
		cryptorOptions=0;
		cryptorKeySize=kCCKeySizeAES128;
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
			withKey:(NSString *)key {
	return [dataToBeEncrypted AES128EncryptWithKey:key];
}

- (NSData *)encryptv1:(NSData *)objDataToBeEncrypted 
			  withKey:(NSString *)key {
	// 'key' should be 16 bytes for AES128, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [objDataToBeEncrypted length];
	
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
										  [objDataToBeEncrypted bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	DLog(@"Encrypt v1 AES128EncryptWithKey FAILED ----------------------");
	free(buffer); //free the buffer;
	return nil;	
}

- (NSData *)encryptv2:(NSData *)objDataToBeEncrypted 
			  withKey:(NSData *)key {
	
	NSUInteger dataLength = [objDataToBeEncrypted length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	//kCCOptionPKCS7Padding
	size_t numBytesEncrypted = 0;
	
	
	char iv[] = {7, 34, 56, 78, 90, 87, 65, 43, 12, 34, 56, 78, 123, 87, 65, 43};
	
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  [key bytes], kCCKeySizeAES128,
										  iv /* initialization vector (optional) */,
										  [objDataToBeEncrypted bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	DLog(@"Encrypt v2 AES128EncryptWithKey FAILED ----------------------");
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
			withKey:(NSString *)key {
	return [dataToBeDecrypted AES128DecryptWithKey:key];
}

- (NSData *)decryptv1:(NSData *)objDataToBeDecrypted 
			  withKey:(NSString *)key {
	// 'key' should be 16 bytes for AES128, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [objDataToBeDecrypted length];
	
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
										  [objDataToBeDecrypted bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	DLog(@"Decrypt v1 FAILED ----------------------");
	free(buffer); //free the buffer;
	return nil;	
}

- (NSData *)decryptv2:(NSData *)objDataToBeDecrypted 
			  withKey:(NSData *)key {
	
	NSUInteger dataLength = [objDataToBeDecrypted length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	
	char iv[] = {7, 34, 56, 78, 90, 87, 65, 43, 12, 34, 56, 78, 123, 87, 65, 43};
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  [key bytes], kCCKeySizeAES128,
										  iv /* initialization vector (optional) */,
										  [objDataToBeDecrypted bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	DLog(@"Decrypt v2 FAILED ----------------------");
	free(buffer); //free the buffer;
	return nil;	
}

//return payload size
- (uint32_t)encryptFile:(NSString *)filePath withKey:(NSString *)key toPath:(NSString *)desPath {
	// 'key' should be 16 bytes for AES128, will be null-padded otherwise
	char keyPtr[cryptorKeySize+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	NSError *error = nil;
	NSData *dataToBeEncrypted = [NSData dataWithContentsOfFile:filePath
											options:0
											error:&error];

	if (!error) {
		// fetch key data
		[key getCString:keyPtr 
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
			
			//if dest file exist, try to delete
			if ([self deleteFileAtPath:desPath]) {
				NSData *result =  [NSData dataWithBytesNoCopy:buffer 
													   length:numBytesEncrypted];
				if ([result writeToFile:desPath atomically:YES]) {
					free(buffer);
					return YES;
				} else {
					free(buffer);
					DLog(@"can not write file to dest part");
					return NO;
				}
			} else {
				free(buffer);
				DLog(@"problem on deleting file");
				return NO;
			}
		}
		free(buffer); //free the buffer;
		DLog(@"Failed to encrypt");
		return NO;
	}
	DLog(@"failed to get data from file");
	return NO;
}

//return payload size
- (uint32_t)decryptFile:(NSString *)filePath withKey:(NSString *)key toPath:(NSString *)desPath {
	// 'key' should be 16 bytes for AES128, will be null-padded otherwise
	char keyPtr[cryptorKeySize+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	NSError *error = nil;
	NSData *dataToBeDecrypted = [NSData dataWithContentsOfFile:filePath
													   options:0
														 error:&error];
	
	if (!error) {
		// fetch key data
		[key getCString:keyPtr 
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
		if (cryptStatus == kCCSuccess) {
			if ([self deleteFileAtPath:desPath]) {
				NSData *result =  [NSData dataWithBytesNoCopy:buffer 
													   length:numberOfBytesDecrypted];
				if ([result writeToFile:desPath atomically:YES]) {
					free(buffer);
					return YES;
				} else {
					DLog(@"can not write file to dest part");
					free(buffer);
					return NO;
				}
			} else {
				DLog(@"problem on deleting file");
				free(buffer);
				return NO;
			}
		}
		DLog(@"Failed to decrypt");
		free(buffer); //free the buffer;
		return NO;
	}
	DLog(@"failed to get data from file");
	return NO;
}

- (BOOL)deleteFileAtPath:(NSString *)path {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		if ([fileManager isDeletableFileAtPath:path]) {
			if ([fileManager removeItemAtPath:path error:nil]) {
				DLog(@"remove exist dest file success");
				return YES;
			} else {
				DLog(@"can not remove dest file");
				return NO;
			}
		} else {
			DLog(@"dest path have undeletable file");
			return NO;					
		}
	}
	DLog(@"no file to delete");
	return YES;
}

#pragma mark -
#pragma mark Encrypt 256

//Custom Method
//This method will encrypt data using key
//It has two params the data to be encrypted 
//and a key 
- (NSData *)encryptKey256:(NSData *)dataToBeEncrypted 
				  withKey:(NSString *)keyData {
	
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
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
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [dataToBeEncrypted bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer 
									length:numBytesEncrypted];
	}
	DLog(@"Failed to encrypt")
	free(buffer); //free the buffer;
	return nil;
	
}

#pragma mark -
#pragma mark Decrypt 256
//Custom Method
//This method will decrypt encrypted data
//It has two params the data to be encrypted
//and a key 
- (NSData *)decryptKey256:(NSData *)dataToBeDecrypted 
				  withKey:(NSString *)keyData {
	
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
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
										  kCCOptionPKCS7Padding, /* options */
										  keyPtr, /* key pointer */
										  kCCKeySizeAES256, /* cryptor key size */
										  NULL /* initialization vector (optional) */,
										  [dataToBeDecrypted bytes], 
										  dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numberOfBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		DLog(@"success to decrypt")
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer 
									length:numberOfBytesDecrypted];
	}
	DLog(@"Failed to decrypt")
	free(buffer); //free the buffer;
	return nil;
	
}

@end
