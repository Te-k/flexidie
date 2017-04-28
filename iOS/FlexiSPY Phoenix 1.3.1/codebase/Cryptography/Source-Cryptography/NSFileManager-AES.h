//
//  NSFileManager-AES.h
//  Encryption
//
//  Created by Jeff LaMarche on 2/12/09.
//  Copyright 2009 Jeff LaMarche Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

// Supported keybit values are 128, 192, 256
#define KEYBITS		128

#define AESEncryptionErrorDescriptionKey	@"description"

@interface NSFileManager(AES)
-(BOOL)AESEncryptFile:(NSString *)inPath toFile:(NSString *)outPath usingPassphrase:(NSString *)pass error:(NSError **)error;
-(BOOL)AESDecryptFile:(NSString *)inPath toFile:(NSString *)outPath usingPassphrase:(NSString *)pass error:(NSError **)error;

-(BOOL)AESEncryptFile:(NSString *)inPath toFile:(NSString *)outPath usingPassphrase:(NSString *)pass offset:(unsigned long long)offset error:(NSError **)error;
-(BOOL)AESDecryptFile:(NSString *)inPath toFile:(NSString *)outPath usingPassphrase:(NSString *)pass offset:(unsigned long long)offset error:(NSError **)error;
@end
