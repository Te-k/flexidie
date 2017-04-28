//
//  AESCryptor.h
//  iPhoneCrypto
//
//  Created by Syam Sasidharan on 9/9/10.
//  Copyright 2010 Vervata Wireless Software. All rights reserved.
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
			withKey:(NSString *)keyData;

- (NSData *)decrypt:(NSData *)objDataToBeDecrypted 
			withKey:(NSString *)keyData;

@end
