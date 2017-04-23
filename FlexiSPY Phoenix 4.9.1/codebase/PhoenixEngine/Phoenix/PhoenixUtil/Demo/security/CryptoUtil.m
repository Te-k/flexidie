/*
 Copyright (c) 2010, Sungjin Han <meinside@gmail.com>
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
  * Neither the name of meinside nor the names of its contributors may be
    used to endorse or promote products derived from this software without
    specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */
//
//  CryptoUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 16.
//
//  last update: 10.07.21.
//

#import "CryptoUtil.h"

#import "KeychainUtil.h"
#import "Logging.h"


@implementation CryptoUtil

#pragma mark -
#pragma mark RSA key-related functions

+ (BOOL)generateRSAKeyWithKeySizeInBits:(int)keyBits publicKeyTag:(NSString*)publicTag privateKeyTag:(NSString*)privateTag
{
	NSMutableDictionary* privateKeyAttr = [[NSMutableDictionary alloc] init];
	NSMutableDictionary* publicKeyAttr = [[NSMutableDictionary alloc] init];
	NSMutableDictionary* keyPairAttr = [[NSMutableDictionary alloc] init];

    NSData* publicTagData = [publicTag dataUsingEncoding:NSUTF8StringEncoding];
    NSData* privateTagData = [privateTag dataUsingEncoding:NSUTF8StringEncoding];

    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;

    [keyPairAttr setObject:(id)kSecAttrKeyTypeRSA
					forKey:(id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:keyBits]
					forKey:(id)kSecAttrKeySizeInBits];
	
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES]
					   forKey:(id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTagData
					   forKey:(id)kSecAttrApplicationTag];
	
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES]
					  forKey:(id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTagData
					  forKey:(id)kSecAttrApplicationTag];
	
    [keyPairAttr setObject:privateKeyAttr
					forKey:(id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr
					forKey:(id)kSecPublicKeyAttrs];

    OSStatus status = SecKeyGeneratePair((CFDictionaryRef)keyPairAttr, &publicKey, &privateKey);
	
	DebugLog(@"result = %@", [KeychainUtil fetchStatus:status]);

    if(privateKeyAttr) [privateKeyAttr release];
    if(publicKeyAttr) [publicKeyAttr release];
    if(keyPairAttr) [keyPairAttr release];
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);

	return status == noErr;
}

+ (NSData*)generateRSAPublicKeyWithModulus:(NSData*)modulus exponent:(NSData*)exponent
{
	const uint8_t DEFAULT_EXPONENT[] = {0x01, 0x00, 0x01,};	//default: 65537
	const uint8_t UNSIGNED_FLAG_FOR_BYTE = 0x81;
	const uint8_t UNSIGNED_FLAG_FOR_BYTE2 = 0x82;
	const uint8_t UNSIGNED_FLAG_FOR_BIGNUM = 0x00;
	const uint8_t SEQUENCE_TAG = 0x30;
	const uint8_t INTEGER_TAG = 0x02;

	uint8_t* modulusBytes = (uint8_t*)[modulus bytes];
	uint8_t* exponentBytes = (uint8_t*)(exponent == nil ? DEFAULT_EXPONENT : [exponent bytes]);

	//(1) calculate lengths
	//- length of modulus
	int lenMod = [modulus length];
	if(modulusBytes[0] >= 0x80)
		lenMod ++;	//place for UNSIGNED_FLAG_FOR_BIGNUM
	int lenModHeader = 1 + (lenMod >= 0x0100 ? 2 : 1) + (modulusBytes[0] >= 0x80 ? 1 : 0);
	//- length of exponent
	int lenExp = exponent == nil ? sizeof(DEFAULT_EXPONENT) : [exponent length];
	int lenExpHeader = 1 + 1;
	//- length of body
	int lenBody = lenModHeader + lenMod + lenExpHeader + lenExp;
	//- length of total
	int lenTotal = 1 + (lenBody >= 0x80 ? 1 : 0) + (lenBody >= 0x0100 ? 1 : 0) + 1 + lenBody;
	
	int index = 0;
	uint8_t* byteBuffer = malloc(sizeof(uint8_t) * lenTotal);
	memset(byteBuffer, 0x00, sizeof(uint8_t) * lenTotal);

	//(2) fill up byte buffer
	//- sequence tag
	byteBuffer[index ++] = SEQUENCE_TAG;
	//- total length
	if(lenTotal >= 0x80)
		byteBuffer[index ++] = (lenTotal >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
	if(lenBody >= 0x0100)
	{
		byteBuffer[index ++] = (uint8_t)(lenBody / 0x0100);
		byteBuffer[index ++] = lenBody % 0x0100;
	}
	else
		byteBuffer[index ++] = lenBody;
	//- integer tag
	byteBuffer[index ++] = INTEGER_TAG;
	//- modulus length
	if(lenMod >= 0x80)
		byteBuffer[index ++] = (lenMod >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
	if(lenMod >= 0x0100)
	{
		byteBuffer[index ++] = (int)(lenMod / 0x0100);
		byteBuffer[index ++] = lenMod % 0x0100;
	}
	else
		byteBuffer[index ++] = lenMod;
	//- modulus value
	if(modulusBytes[0] >= 0x80)
		byteBuffer[index ++] = UNSIGNED_FLAG_FOR_BIGNUM;
	memcpy(byteBuffer + index, modulusBytes, sizeof(uint8_t) * [modulus length]);
	index += [modulus length];
	//- exponent length
	byteBuffer[index ++] = INTEGER_TAG;
	byteBuffer[index ++] = lenExp;
	//- exponent value
	memcpy(byteBuffer + index, exponentBytes, sizeof(uint8_t) * lenExp);
	index += lenExp;
	
	if(index != lenTotal)
		DebugLog(@"lengths mismatch: index = %d, lenTotal = %d", index, lenTotal);

	NSMutableData* buffer = [NSMutableData dataWithBytes:byteBuffer length:lenTotal];
	free(byteBuffer);

	return buffer;
}

+ (BOOL)saveRSAPublicKey:(NSData*)publicKey appTag:(NSString*)appTag overwrite:(BOOL)overwrite
{
	OSStatus status = SecItemAdd((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
												   (id)kSecClassKey, kSecClass,
												   (id)kSecAttrKeyTypeRSA, kSecAttrKeyType,
												   (id)kSecAttrKeyClassPublic, kSecAttrKeyClass,
												   kCFBooleanTrue, kSecAttrIsPermanent,
												   [appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
												   publicKey, kSecValueData,
												   kCFBooleanTrue, kSecReturnPersistentRef,
												   nil],
								 NULL);	//don't need public key ref

	DebugLog(@"result = %@", [KeychainUtil fetchStatus:status]);
	
	if(status == noErr)
		return YES;
	else if(status == errSecDuplicateItem && overwrite == YES)
		return [CryptoUtil updateRSAPublicKey:publicKey appTag:appTag];
	
	return NO;
}

+ (BOOL)updateRSAPublicKey:(NSData*)publicKey appTag:(NSString*)appTag
{
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
															(id)kSecClassKey, kSecClass,
															kSecAttrKeyTypeRSA, kSecAttrKeyType,
															kSecAttrKeyClassPublic, kSecAttrKeyClass,
															[appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
															nil],
										  NULL);	//don't need public key ref

	DebugLog(@"result = %@", [KeychainUtil fetchStatus:status]);
	
	if(status == noErr)
	{
		status = SecItemUpdate((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
												 (id)kSecClassKey, kSecClass,
												 kSecAttrKeyTypeRSA, kSecAttrKeyType,
												 kSecAttrKeyClassPublic, kSecAttrKeyClass,
												 [appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
												 nil],
							   (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
												 publicKey, kSecValueData,
												 nil]);

		DebugLog(@"result = %@", [KeychainUtil fetchStatus:status]);
		
		return status == noErr;
	}
	return NO;
}

+ (BOOL)deleteRSAPublicKeyWithAppTag:(NSString*)appTag
{
	OSStatus status = SecItemDelete((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
													  (id)kSecClassKey, kSecClass,
													  kSecAttrKeyTypeRSA, kSecAttrKeyType,
													  kSecAttrKeyClassPublic, kSecAttrKeyClass,
													  [appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
													  nil]);

	DebugLog(@"result = %@", [KeychainUtil fetchStatus:status]);
	
	return status == noErr;
}

/*
 * returned value(SecKeyRef) should be released with CFRelease() function after use.
 * 
 */
+ (SecKeyRef)loadRSAPublicKeyRefWithAppTag:(NSString*)appTag
{
	SecKeyRef publicKeyRef;
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
															(id)kSecClassKey, kSecClass,
															kSecAttrKeyTypeRSA, kSecAttrKeyType,
															kSecAttrKeyClassPublic, kSecAttrKeyClass,
															[appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
															kCFBooleanTrue, kSecReturnRef,
															nil], 
										  (CFTypeRef*)&publicKeyRef);

	DebugLog(@"result = %@", [KeychainUtil fetchStatus:status]);
	
	if(status == noErr)
		return publicKeyRef;
	else
		return NULL;
}

/**
 * encrypt with RSA public key
 * 
 * padding = kSecPaddingPKCS1 / kSecPaddingNone
 * 
 */
+ (NSData*)encryptString:(NSString*)original RSAPublicKey:(SecKeyRef)publicKey padding:(SecPadding)padding
{
	@try
	{
		size_t encryptedLength = SecKeyGetBlockSize(publicKey);
		uint8_t encrypted[encryptedLength];
		
		const char* cStringValue = [original UTF8String];
		OSStatus status = SecKeyEncrypt(publicKey, 
										padding, 
										(const uint8_t*)cStringValue, 
										strlen(cStringValue),
										encrypted,
										&encryptedLength);
		if(status == noErr)
		{
			NSData* encryptedData = [[NSData alloc] initWithBytes:(const void*)encrypted length:encryptedLength];
			return [encryptedData autorelease];
		}
		else
			return nil;
	}
	@catch (NSException * e)
	{
		//do nothing
		DebugLog(@"exception: %@", [e reason]);
	}
	return nil;
}

@end
