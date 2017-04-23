//
//  NewRSACryptor.m
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/18/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "RSACryptor.h"

#if !TARGET_OS_IPHONE

#import <Security/SecItem.h>

extern const CFTypeRef kSecClassKey;

// CCryptography

#import "CCryptography.h"

#endif

const char *refString = "PhoenixRSACryptor";

@implementation RSACryptor

@synthesize bufferSize;
@synthesize cipherBufferSize;
@synthesize paddingType;

- (NSData *)encrypt:(NSData *)data withServerPublicKey:(NSData *)keyData {
	
#if TARGET_OS_IPHONE
	DLog(@"data %@ key %@", data, keyData);
	unsigned char *bytes = (unsigned char *)[keyData bytes];
	size_t bytesLength = [keyData length];

	size_t i = 0;
	if (bytes[i++] != 0x30)
		return nil;
	
	
	/* Skip size bytes */
	if (bytes[i] > 0x80)
		i += bytes[i] - 0x80 + 1;
	else
		i++;
	
	if (i >= bytesLength)
		return nil;
	
	if (bytes[i] != 0x30)
		return nil;
	
	/* Skip OID */
	i += 15;
	
	if (i >= bytesLength - 2)
		return nil;
	
	if (bytes[i++] != 0x03)
		return nil;
	
	/* Skip length and null */
	if (bytes[i] > 0x80)
		i += bytes[i] - 0x80 + 1;
	else
		i++;
	
	if (i >= bytesLength)
		return nil;
	
	if (bytes[i++] != 0x00)
		return nil;
	
	if (i >= bytesLength)
		return nil;
	
	/* Here we go! */
	NSData * extractedKey = [NSData dataWithBytes:&bytes[i] length:bytesLength - i];
	
	DLog(@"extractedKey = %@", extractedKey);
	
	OSStatus error = noErr;
	CFTypeRef persistPeer = NULL;
	
	NSData * refTag = [[NSData alloc] initWithBytes:refString length:strlen(refString)];
	NSMutableDictionary * keyAttr = [[NSMutableDictionary alloc] init];
	
	[keyAttr setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[keyAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[keyAttr setObject:refTag forKey:(id)kSecAttrApplicationTag]; 
	/* First we delete any current keys */
//	error = SecItemDelete((CFDictionaryRef) keyAttr);
	SecItemDelete((CFDictionaryRef) keyAttr);
	
	[keyAttr setObject:extractedKey forKey:(id)kSecValueData];
	[keyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnPersistentRef];

	/// !!!: tested on ios 6.1 (3gs), and 5.1.1 (4)	
#ifdef __IPHONE_4_0 // IOS 4 onward
	/// !!!: tested on ios 4.3.3(3gs), 6.1 (cdma), and 5.0.1 (4s)
	// This key is for determining when a keychain item should be readable 
	[keyAttr setObject:(id)kSecAttrAccessibleAlways forKey:(id)kSecAttrAccessible];	 // The data in the keychain item can always be accessed regardless of whether the device is locked
#endif
	
	error = SecItemAdd((CFDictionaryRef) keyAttr, (CFTypeRef *)&persistPeer);
	
	if (persistPeer == nil || ( error != noErr && error != errSecDuplicateItem)) {
		[refTag release];
		[keyAttr release];
		DLog(@"Problem adding public key to keychain, error = %ld", (long)SINT32_DLOG(error)); // Can be error = -25308 ? on Iphone 4, 4.2.1, reboot device help to ease the issue
		return nil;
	}
	CFRelease(persistPeer);
	
	SecKeyRef publicKeyRef = nil;
	
	/* Now we extract the real ref */
	[keyAttr removeAllObjects];
	/*
	 [keyAttr setObject:(id)persistPeer forKey:(id)kSecValuePersistentRef];
	 [keyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
	 */
	[keyAttr setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[keyAttr setObject:refTag forKey:(id)kSecAttrApplicationTag];
	[keyAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[keyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
	
	// Get the persistent key reference.
	error = SecItemCopyMatching((CFDictionaryRef)keyAttr, (CFTypeRef *)&publicKeyRef);    
	
	//[refTag release];
	[keyAttr release];
	
	if (publicKeyRef == nil || ( error != noErr && error != errSecDuplicateItem)) {
		DLog(@"Error retrieving public key reference from chain");
		[refTag release];
		return nil;
	}
	
	NSData *encryptedData=nil;
	encryptedData = [self encryptWithPublicKey:refTag inputData:data];
	[refTag release];
		
	free(publicKeyRef);
	DLog(@"encryptedData %@", encryptedData);
	return encryptedData;
    
#else
    NSData *encryptedData = nil;
	encryptedData = [CCryptography encrypt:data withServerPublicKey:keyData];
	DLog(@"encryptedData = %@", encryptedData);
    return (encryptedData);
#endif
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		bufferSize=64;
		cipherBufferSize=1024;
		paddingType=kSecPaddingPKCS1;
	}
	return self;
}

#pragma mark -
#pragma mark Custom Initializer
- (void)initWithBufferSize:(size_t)szBufferSize 
		  cipherBufferSize:(size_t)szCipherBufferSize
			   paddingType:(uint32_t)uiPaddingType {
	if(	(self=[super init])) {
		bufferSize=szBufferSize;
		cipherBufferSize=szCipherBufferSize;
		paddingType=uiPaddingType;
	}
}

#pragma mark -
#pragma mark Encrypt/Decrypt 

- (NSData *)encryptWithPublicKey:(NSData *)objPublicKeyIdentifier
					   inputData:(NSData *)objInputData{

	plainBuffer = (uint8_t *)calloc(bufferSize, sizeof(uint8_t));
	cipherBuffer = (uint8_t *)calloc(cipherBufferSize, sizeof(uint8_t));
	decryptedBuffer = (uint8_t *)calloc(bufferSize, sizeof(uint8_t));

	[objInputData getBytes:plainBuffer 
					length:[objInputData length]];

	[self encryptWithPublicKey:objPublicKeyIdentifier 
				   plainBuffer:plainBuffer 
				  cipherBuffer:cipherBuffer];

	NSData *objEncryptedData=[NSData dataWithBytes:cipherBuffer 
											length:cipherBufferSize];

	return objEncryptedData;

}

- (NSData *)decryptWithPrivateKey:(NSData *)objPrivateKeyIdentifier
					   cipherData:(NSData *)objCipherData {

	plainBuffer = (uint8_t *)calloc(bufferSize, sizeof(uint8_t));
	cipherBuffer = (uint8_t *)calloc(cipherBufferSize, sizeof(uint8_t));
	decryptedBuffer = (uint8_t *)calloc(bufferSize, sizeof(uint8_t));

	[objCipherData getBytes:cipherBuffer
					 length:[objCipherData length]];

	[self decryptWithPrivateKey:objPrivateKeyIdentifier
				   cipherBuffer:cipherBuffer
					plainBuffer:plainBuffer];
	size_t plainBufferSize= strlen((char *)plainBuffer);
	NSData *objDecryptedData=[NSData dataWithBytes:plainBuffer 
											length:plainBufferSize];

	return objDecryptedData;
}

//Custom Method
//encryptWithPublicKey:plainBuffer:cipherBuffer
//Encrypt the data with public key
- (void)encryptWithPublicKey:(NSData *)objPublicKeyIdentifier
				 plainBuffer:(uint8_t *)plainBufferInput 
				cipherBuffer:(uint8_t *)cipherBufferOutput {
	
	//DLog(@"== encryptWithPublicKey()");
	
	OSStatus status = noErr;
	
	//DLog(@"** original plain text 0: %s", plainBuffer);
	
	//Calculating the cipher buffer size
	size_t plainBufferSize = strlen((char *)plainBufferInput);
	
	// DLog(@"SecKeyGetBlockSize() public = %d", SecKeyGetBlockSize([self getPublicKeyRefForIdentifier:objPrivateKeyIdentifier]));
	// Error handling
	// Encrypt using the public.
	
	//Encrypting the data by passing public key
	//Padding method
	//input text and length
	//cipher text and legth
	
	SecKeyRef keyRef = [self getPublicKeyRefForIdentifier:objPublicKeyIdentifier];
    status = SecKeyEncrypt(keyRef,
                           paddingType,
                           plainBufferInput,
                           plainBufferSize,
                           &cipherBufferOutput[0],
                           &cipherBufferSize );
	//Now the cipher text will be stored in the cipher text array
	free(keyRef);
	DLog(@"encryption result code: %ld (size: %lu)", (long)SINT32_DLOG(status), cipherBufferSize);
	DLog(@"encrypted text: %s", cipherBuffer);
	
}

//Custom Method
//decryptWithPrivateKey:plainBuffer:cipherBuffer
//Decrypt the encrypted data with private key
- (void)decryptWithPrivateKey:(NSData *)objPrivateKeyIdentifier
				 cipherBuffer:(uint8_t *)cipherBufferInput 
				  plainBuffer:(uint8_t *)plainBufferOutput {
	//Initializing the osstatus variable
	//OSStatus status = noErr;
	
	//Calculating the cipherbuffersize
	cipherBufferSize = strlen((char *)cipherBufferInput);
	
	//DLog(@"decryptWithPrivateKey: length of buffer: %d", BUFFER_SIZE);
	//DLog(@"decryptWithPrivateKey: length of input: %d", cipherBufferSize);
	
	// DECRYPTION
	size_t plainBufferSize = bufferSize;
	
	//Decrypting the cipher text by passing privatekey having specified identifier
	//Padding method
	//Cipher buffer and its size
	//Plain buffer and its size
//	status = SecKeyDecrypt([self getPrivateKeyRefForIdentifier:objPrivateKeyIdentifier],
//                           paddingType,
//                           &cipherBufferInput[0],
//                           cipherBufferSize,
//                           &plainBufferOutput[0],
//                           &plainBufferSize
//                           );
	SecKeyDecrypt([self getPrivateKeyRefForIdentifier:objPrivateKeyIdentifier],
                           paddingType,
                           &cipherBufferInput[0],
                           cipherBufferSize,
                           &plainBufferOutput[0],
                           &plainBufferSize
                           );
	
	//Now the decrypted message will be stored in the plain buffer
	//DLog(@"decryption result code: %d (size: %d)", status, plainBufferSize);
	//DLog(@"FINAL decrypted text: %s", plainBuffer);
	
}

#pragma mark -
#pragma mark Public Key/Private Key Manipulation 

//Custom Method
//getPublicKeyRefForIdentifier:
//Fetching the public key from iPhone keychain by using the identifier passed
- (SecKeyRef)getPublicKeyRefForIdentifier:(NSData *)objPublicKeyIdentifier {
	
	OSStatus resultCode = noErr;
	SecKeyRef publicKeyReference = NULL;
	
	if(publicKey == NULL) {
		
		//Setting the public key tag
		publicTag = objPublicKeyIdentifier;
		
        NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
		
        // Set the public key query dictionary.
        [queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
        [queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
        [queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
        [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
		
        // Get the key.
        resultCode = SecItemCopyMatching((CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyReference);
		
        //DLog(@"getPublicKey: result code: %d", resultCode);
		
		if(resultCode != noErr) {
            publicKeyReference = NULL;
        }
		
        [queryPublicKey release];
		publicTag=NULL;
		
	} else {
		publicKeyReference = publicKey;
	}
	
	return publicKeyReference;
}

//Custom Method
//getPrivateKeyRefForIdentifier:
//Fetching the private key from iPhone keychain by using the identifier passed
- (SecKeyRef)getPrivateKeyRefForIdentifier:(NSData *)objPrivateKeyIdentifier {
    OSStatus resultCode = noErr;
    SecKeyRef privateKeyReference = NULL;
	
    if(privateKey == NULL) {
		
		privateTag = objPrivateKeyIdentifier;
		
        NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
		
        // Set the private key query dictionary.
        [queryPrivateKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
        [queryPrivateKey setObject:privateTag forKey:(id)kSecAttrApplicationTag];
        [queryPrivateKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
        [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
		
        // Get the key.
        resultCode = SecItemCopyMatching((CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKeyReference);
        //DLog(@"getPrivateKey: result code: %d", resultCode);
		
        if(resultCode != noErr) {
			privateKeyReference = NULL;
        }
		
        [queryPrivateKey release];
		privateTag=NULL;
	} else {
		privateKeyReference = privateKey;
	}
	
	return privateKeyReference;
}


- (void) dealloc
{
	free(plainBuffer);
	free(cipherBuffer);
	free(decryptedBuffer);
	[super dealloc];
}


@end
