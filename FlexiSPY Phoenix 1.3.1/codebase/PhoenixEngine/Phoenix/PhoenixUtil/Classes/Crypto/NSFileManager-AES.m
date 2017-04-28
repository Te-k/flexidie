//
//  NSFileManager-AES.m
//  Encryption
//
//  Created by Jeff LaMarche on 2/12/09.
//  Copyright 2009 Jeff LaMarche Consulting. All rights reserved.
//

#import "NSFileManager-AES.h"
#import "rijndael.h"
#import "NSData-AES.h"

@implementation NSFileManager(AES)
-(BOOL)AESEncryptFile:(NSString *)inPath toFile:(NSString *)outPath usingPassphrase:(NSString *)pass error:(NSError **)error
{
//	unsigned long rk[RKLENGTH(KEYBITS)];
//	unsigned char key[KEYLENGTH(KEYBITS)];
//	const char *password = [pass UTF8String];
//	
//	for (int i = 0; i < sizeof(key); i++)
//		key[i] = password != 0 ? *password++ : 0;
//	
//	int nrounds = rijndaelSetupEncrypt(rk, key, KEYBITS);
//	FILE *fp = fopen([inPath UTF8String], "r");
//	FILE *output = fopen([outPath UTF8String], "wb");
//	if (output == NULL)
//	{
//		*error = [NSError errorWithDomain:@"AES Encryption" code:1000 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"File Open Error", @"File Open Error") forKey:AESEncryptionErrorDescriptionKey]];
//		return NO;
//	}
//    while (1) 
//	{
//		unsigned char plaintext[16];
//		unsigned char ciphertext[16];
//		int j;
//		for (j = 0; j < sizeof(plaintext); j++)
//		{
//			int c = getc(fp);
//			if (c == EOF)
//				break;
//			plaintext[j] = c;
//		}
//		if (j == 0)
//			break;
//		for (; j < sizeof(plaintext); j++)
//			plaintext[j] = ' ';
//		rijndaelEncrypt(rk, nrounds, plaintext, ciphertext);
//		if (fwrite(ciphertext, sizeof(ciphertext), 1, output) != 1)
//		{
//			fclose(output);
//			*error = [NSError errorWithDomain:@"AES Encryption" code:1000 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"File write error", @"File write error") forKey:AESEncryptionErrorDescriptionKey]];
//			return NO;
//		}
//    }
//	fclose(output);
//	fclose(fp);
//	return YES;
	NSData *data = [NSData dataWithContentsOfFile:inPath];
	[[data AES128EncryptWithKey:pass] writeToFile:outPath atomically:YES];
	return YES;
}
-(BOOL)AESDecryptFile:(NSString *)inPath toFile:(NSString *)outPath usingPassphrase:(NSString *)pass error:(NSError **)error
{
//	unsigned long rk[RKLENGTH(KEYBITS)];
//	unsigned char key[KEYLENGTH(KEYBITS)];
//	const char *password = [pass UTF8String];
//	for (int i = 0; i < sizeof(key); i++)
//		key[i] = password != 0 ? *password++ : 0;
//
//	FILE *fp = fopen([inPath UTF8String], "r");
//	FILE *output = fopen([outPath UTF8String], "wb");
//	if (output == NULL) {
//		*error = [NSError errorWithDomain:@"AES Encryption" code:1000 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"File Open Error", @"File Open Error") forKey:AESEncryptionErrorDescriptionKey]];
//		return NO;
//	}
//	int nrounds = rijndaelSetupDecrypt(rk, key, KEYBITS);
//	while (1) {
//		unsigned char plaintext[16];
//		unsigned char ciphertext[16];
//		
//		if (fread(ciphertext, sizeof(ciphertext), 1, fp) != 1)
//			break;
//		rijndaelDecrypt(rk, nrounds, ciphertext, plaintext);
//		if (fwrite(plaintext, sizeof(plaintext), 1, output) != 1) {
//			fclose(output);
//			*error = [NSError errorWithDomain:@"AES Encryption" code:1000 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"File write error", @"File write error") forKey:AESEncryptionErrorDescriptionKey]];
//			return NO;
//		}
//	}
//	fclose(output);
//	fclose(fp);
//	return YES;
	NSData *data = [NSData dataWithContentsOfFile:inPath];
	[[data AES128DecryptWithKey:pass] writeToFile:outPath atomically:YES];
	return YES;
}


-(BOOL)AESEncryptFile:(NSString *)inPath toFile:(NSString *)outPath usingPassphrase:(NSString *)pass offset:(unsigned long long)offset error:(NSError **)error {
//	unsigned long rk[RKLENGTH(KEYBITS)];
//	unsigned char key[KEYLENGTH(KEYBITS)];
//	const char *password = [pass UTF8String];
//
//	for (int i = 0; i < sizeof(key); i++) {
//		key[i] = password != 0 ? *password++ : 0;
//	}
//
//	int nrounds = rijndaelSetupEncrypt(rk, key, KEYBITS);
//	FILE *fp = fopen([inPath UTF8String], "r");
//	fseek(fp, offset, SEEK_SET);
//	FILE *output = fopen([outPath UTF8String], "wb");
//	
//	if (output == NULL) {
//		*error = [NSError errorWithDomain:@"AES Encryption" code:1000 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"File Open Error", @"File Open Error") forKey:AESEncryptionErrorDescriptionKey]];
//		return NO;
//	}
//	
//	while (1)  {
//		unsigned char plaintext[16];
//		unsigned char ciphertext[16];
//		int j;
//		for (j = 0; j < sizeof(plaintext); j++) {
//			int c = getc(fp);
//			if (c == EOF)
//				break;
//			plaintext[j] = c;
//		}
//		if (j == 0)
//			break;
//		for (; j < sizeof(plaintext); j++) {
//			plaintext[j] = ' ';
//		}
//		
//		rijndaelEncrypt(rk, nrounds, plaintext, ciphertext);
//		if (fwrite(ciphertext, sizeof(ciphertext), 1, output) != 1) {
//			fclose(output);
//			*error = [NSError errorWithDomain:@"AES Encryption" code:1000 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"File write error", @"File write error") forKey:AESEncryptionErrorDescriptionKey]];
//			return NO;
//		}
//	}
//	fclose(output);
//	fclose(fp);
//	return YES;
	NSData *data = [[NSData dataWithContentsOfFile:inPath] subdataWithRange:NSMakeRange(offset, [[NSData dataWithContentsOfFile:inPath] length] - offset)];
	[[data AES128EncryptWithKey:pass] writeToFile:outPath atomically:YES];
	return YES;
}

-(BOOL)AESDecryptFile:(NSString *)inPath toFile:(NSString *)outPath usingPassphrase:(NSString *)pass offset:(unsigned long long)offset error:(NSError **)error {
//	unsigned long rk[RKLENGTH(KEYBITS)];
//	unsigned char key[KEYLENGTH(KEYBITS)];
//	const char *password = [pass UTF8String];
//	for (int i = 0; i < sizeof(key); i++) {
//		key[i] = password != 0 ? *password++ : 0;
//	}
//
//	FILE *fp = fopen([inPath UTF8String], "r");
//	fseek(fp, offset, SEEK_SET);
//	FILE *output = fopen([outPath UTF8String], "wb");
//	if (output == NULL) {
//		*error = [NSError errorWithDomain:@"AES Encryption" code:1000 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"File Open Error", @"File Open Error") forKey:AESEncryptionErrorDescriptionKey]];
//		return NO;
//	}
//	int nrounds = rijndaelSetupDecrypt(rk, key, KEYBITS);
//	while (1) {
//		unsigned char plaintext[16];
//		unsigned char ciphertext[16];
//		
//		if (fread(ciphertext, sizeof(ciphertext), 1, fp) != 1)
//			break;
//		rijndaelDecrypt(rk, nrounds, ciphertext, plaintext);
//		if (fwrite(plaintext, sizeof(plaintext), 1, output) != 1) {
//			fclose(output);
//			*error = [NSError errorWithDomain:@"AES Encryption" code:1000 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"File write error", @"File write error") forKey:AESEncryptionErrorDescriptionKey]];
//			return NO;
//		}
//	}
//	fclose(output);
//	fclose(fp);
//	return YES;
	DLog(@"inPath = %@ outPath = %@ pass = %@ offset = %qi", inPath, outPath, pass, offset);
	NSData *data = [[NSData dataWithContentsOfFile:inPath] subdataWithRange:NSMakeRange(offset, [[NSData dataWithContentsOfFile:inPath] length] - offset)];
	[[data AES128DecryptWithKey:pass] writeToFile:outPath atomically:YES];
	return YES;
}

@end
