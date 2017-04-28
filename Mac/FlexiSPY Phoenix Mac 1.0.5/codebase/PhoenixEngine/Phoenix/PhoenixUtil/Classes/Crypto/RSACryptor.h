//
//  NewRSACryptor.h
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/18/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

size_t encodeLength(unsigned char * buf, size_t length);

@interface RSACryptor : NSObject {
	SecKeyRef publicKey;
	SecKeyRef privateKey;
	NSData *publicTag;
	NSData *privateTag;
	
	uint8_t *plainBuffer;
	uint8_t *cipherBuffer;
	uint8_t *decryptedBuffer;
	
	size_t bufferSize;
	size_t cipherBufferSize;
	uint32_t paddingType;
}

@property (nonatomic,assign) size_t bufferSize;
@property (nonatomic,assign) size_t cipherBufferSize;
@property (nonatomic,assign) uint32_t paddingType;

- (void)initWithBufferSize:(size_t)szBufferSize 
		  cipherBufferSize:(size_t)szCipherBufferSize
			   paddingType:(uint32_t)uiPaddingType;

- (NSData *)encryptWithPublicKey:(NSData *)objPublicKeyIdentifier
					   inputData:(NSData *)objInputData;

- (void)encryptWithPublicKey:(NSData *)objPublicKeyIdentifier
				 plainBuffer:(uint8_t *)plainBuffer 
				cipherBuffer:(uint8_t *)cipherBuffer;

- (NSData *)decryptWithPrivateKey:(NSData *)objPrivateKeyIdentifier
					   cipherData:(NSData *)objCipherData;
- (void)decryptWithPrivateKey:(NSData *)objPrivateKeyIdentifier
				 cipherBuffer:(uint8_t *)cipherBuffer 
				  plainBuffer:(uint8_t *)plainBuffer;

- (SecKeyRef)getPrivateKeyRefForIdentifier:(NSData *)objPrivateKeyIdentifier;
- (SecKeyRef)getPublicKeyRefForIdentifier:(NSData *)objPublicKeyIdentifier;

- (NSData *)encrypt:(NSData *)data withServerPublicKey:(NSData *)keyData;

@end
