//
//  AESCryptor.h
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/13/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface AESCryptor : NSObject {
	CCOptions cryptorOptions;
	size_t cryptorKeySize;
}

@property (nonatomic) CCOptions cryptorOptions;
@property (nonatomic) size_t cryptorKeySize;

- (void)initWithCryptorOptions:(CCOptions)options
				cryptorKeySize:(size_t)keySize;

- (NSData *)encrypt:(NSData *)objDataToBeEncrypted 
			withKey:(NSString *)key;

- (NSData *)decrypt:(NSData *)objDataToBeDecrypted 
			withKey:(NSString *)key;

- (uint32_t)encryptFile:(NSString *)filePath withKey:(NSString *)key toPath:(NSString *)desPath;
- (uint32_t)decryptFile:(NSString *)filePath withKey:(NSString *)key toPath:(NSString *)desPath;

- (BOOL)deleteFileAtPath:(NSString *)path;
@end
