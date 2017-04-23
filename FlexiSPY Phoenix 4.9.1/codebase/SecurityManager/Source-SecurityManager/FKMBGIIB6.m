//
//  SecurityManager.m
//  MobileFonex
//
//  Created by iPhoneFlexiSPY on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FKMBGIIB6.h"
#import "hashKey.h"
#import "confKey.h"
#import "KDMWhiteHouse.h"
#import "FileMD5Hash.h"

#import "NSData-AES.h"
#import "AESCryptor.h"

#define CONFIG_FILE_NAME @"config.dat"

@interface FKMBGIIB6 ()

- (BOOL)vfetl0:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue;
- (BOOL)vfetl1:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue;
- (BOOL)vfetl2:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue;
- (BOOL)vfetl3:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
			cfi:(int)indexValue;
- (BOOL)vfetl4:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue;
- (BOOL)vfetl5:(NSString *)configFilePath // verifyExecutable:hashKeyText:configKeyText:binaryFilePath:configIndex:
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue;

- (BOOL)icffes0000:(NSString *)configFilePath; // Fake
- (BOOL)icffes0001:(NSString *)configFilePath; // Fake
- (BOOL)icffes0002:(NSString *)configFilePath; // Fake
- (BOOL)icffes0003:(NSString *)configFilePath; // Fake
- (BOOL)icffes0004:(NSString *)configFilePath; // ifConfigFileExists:
- (BOOL)icffes0005:(NSString *)configFilePath; // Fake
- (BOOL)icffes0006:(NSString *)configFilePath; // Fake
- (BOOL)icffes0007:(NSString *)configFilePath; // Fake
- (BOOL)icffes0008:(NSString *)configFilePath; // Fake
- (BOOL)icffes0009:(NSString *)configFilePath; // Fake

@end

@implementation FKMBGIIB6

@synthesize cffos0;
@synthesize cffos1;
@synthesize cffos2;
@synthesize cffos3;
@synthesize cffos4;
@synthesize cffos5;

@synthesize cffms0;
@synthesize cffms1;
@synthesize cffms2;
@synthesize cffms3;
@synthesize cffms4;
@synthesize cffms5;

- (BOOL)vetl0:(NSString *)filePath // Fake
		  cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)vetl1:(NSString *)filePath // Fake
		  cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)vetl2:(NSString *)filePath // Fake
		  cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)vetl3:(NSString *)filePath 
		  cfi:(int)indexValue {
    char *hashKeyKey = getkeyKey_hash();
    char *hashEncryptedKey = getEncryptedKey_hash();
    char *hashEncryptedChecksum = getEncryptedUrlChecksum_hash();
    // convert to data to NSString
    NSString *hashKeyKeyString = [NSString stringWithCString:hashKeyKey encoding:NSUTF8StringEncoding]; // key of key
    NSData *hashEncryptedKeyData = [NSData dataWithBytes:hashEncryptedKey length:32]; // encrypted key
    NSData *hashChecksumKeyData = [hashEncryptedKeyData AES128DecryptWithKey:hashKeyKeyString]; // decrypt key
    NSString *hashUrlChecksumKeyString = [[[NSString alloc] initWithData:hashChecksumKeyData encoding:NSUTF8StringEncoding] autorelease]; // get key string
    NSData *hashEncryptedChecksumData = [NSData dataWithBytes:hashEncryptedChecksum length:48];
    NSData *hashChecksumData = [hashEncryptedChecksumData AES128DecryptWithKey:hashUrlChecksumKeyString]; // decrypt cksum
    NSString *hashChecksum = [[[NSString alloc] initWithData:hashChecksumData encoding:NSUTF8StringEncoding] autorelease]; // get cksum string
    
	DLog(@"hashKey = %@", hashChecksum);
    char *confKeyKey = getkeyKey_conf();
    char *confEncryptedKey = getEncryptedKey_conf();
    char *confEncryptedChecksum = getEncryptedUrlChecksum_conf();
    // convert to data to NSString
    NSString *confKeyKeyString = [NSString stringWithCString:confKeyKey encoding:NSUTF8StringEncoding]; // key of key
    NSData *confEncryptedKeyData = [NSData dataWithBytes:confEncryptedKey length:32]; // encrypted key
    NSData *confChecksumKeyData = [confEncryptedKeyData AES128DecryptWithKey:confKeyKeyString]; // decrypt key
    NSString *confUrlChecksumKeyString = [[[NSString alloc] initWithData:confChecksumKeyData encoding:NSUTF8StringEncoding] autorelease]; // get key string
    NSData *confEncryptedChecksumData = [NSData dataWithBytes:confEncryptedChecksum length:48];
    NSData *confChecksumData = [confEncryptedChecksumData AES128DecryptWithKey:confUrlChecksumKeyString]; // decrypt cksum
    NSString *confChecksum = [[[NSString alloc] initWithData:confChecksumData encoding:NSUTF8StringEncoding] autorelease]; // get cksum string
	
	DLog(@"configKey = %@", confChecksum);
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *fileName = @"";
    
#if TARGET_OS_IPHONE
    fileName = [NSString stringWithFormat:@"%@/%@",resPath, CONFIG_FILE_NAME];
#else
    fileName = [NSString stringWithFormat:@"%@/Contents/_CodeSignature/%@",[[NSBundle mainBundle] bundlePath], CONFIG_FILE_NAME];
#endif
    
    return [self vfetl5:fileName
					hkt:hashChecksum
				   cftf:confChecksum
					bfp:filePath
					cfi:indexValue];
}

- (BOOL)vetl4:(NSString *)filePath // Fake
		  cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)vetl5:(NSString *)filePath // Fake
		  cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)fcffe0 { // Fake
	return (arc4random() % 255);
}

- (BOOL)fcffe1 { // Fake
	return (arc4random() % 255);
}

- (BOOL)fcffe2 { // Fake
	return (arc4random() % 255);
}

- (BOOL)fcffe3 {
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *fileName = @"";
#if TARGET_OS_IPHONE
    fileName = [NSString stringWithFormat:@"%@/%@",resPath, CONFIG_FILE_NAME];
#else
    fileName = [NSString stringWithFormat:@"%@/Contents/_CodeSignature/%@",[[NSBundle mainBundle] bundlePath], CONFIG_FILE_NAME];
#endif
    return [self icffes0004:fileName];
}

- (BOOL)fcffe4 { // Fake
	return (arc4random() % 255);
}

- (BOOL)fcffe5 { // Fake
	return (arc4random() % 255);
}

#pragma mark -
#pragma mark Config file exists or not

- (BOOL)icffes0000:(NSString *)configFilePath { // Fake
	return (arc4random() % 255);
}

- (BOOL)icffes0001:(NSString *)configFilePath { // Fake
	return (arc4random() % 255);
}

- (BOOL)icffes0002:(NSString *)configFilePath { // Fake
	return (arc4random() % 255);
}

- (BOOL)icffes0003:(NSString *)configFilePath { // Fake
	return (arc4random() % 255);
}

- (BOOL)icffes0004:(NSString *)configFilePath {
    //Check whether the config file exists at path
    if (! [[NSFileManager defaultManager] fileExistsAtPath:configFilePath]){
        return NO;
    }
    return YES;
}

- (BOOL)icffes0005:(NSString *)configFilePath { // Fake
	return (arc4random() % 255);
}

- (BOOL)icffes0006:(NSString *)configFilePath { // Fake
	return (arc4random() % 255);
}

- (BOOL)icffes0007:(NSString *)configFilePath { // Fake
	return (arc4random() % 255);
}

- (BOOL)icffes0008:(NSString *)configFilePath { // Fake
	return (arc4random() % 255);
}

- (BOOL)icffes0009:(NSString *)configFilePath { // Fake
	return (arc4random() % 255);
}

#pragma mark -
#pragma mark Verifying the executable checksum

- (BOOL)vfetl0:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)vfetl1:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)vfetl2:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)vfetl3:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)vfetl4:(NSString *)configFilePath // Fake
		   hkt:(NSString *)hashKey
		  cftf:(NSString *)configKey
		   bfp:(NSString *)currentBinaryFilePath
		   cfi:(int)indexValue {
	return (arc4random() % 255);
}

- (BOOL)vfetl5:(NSString *)configFilePath
             hkt:(NSString *)hashKey
           cftf:(NSString *)configKey
          bfp:(NSString *)currentBinaryFilePath
             cfi:(int)indexValue{

	char binaryCheckSum[33];
	char binaryCheckSumFromConfigFile[49];
	char binaryDecryptedCheckSumFromConfigFile[33];
	
	char configCheckSum[33];
	char configCheckSumFromConfigFile[49];
	char decryptedConfigCheckSumFromConfigFile[33];
	
	char configData[512];
	char *configFile;
	
	int indexFile[96];

	BOOL isSuccess;

	//Fecthing the index file
    KDMWhiteHouse *dataManager;
	dataManager = [[KDMWhiteHouse alloc] init];
	NSMutableArray *indexofChecksum=[dataManager gkdffai2:indexValue];	
	for (int i=0; i<96; i++) {
		NSNumber *indexValue=[indexofChecksum objectAtIndex:i];
		indexFile[i]=(int)[indexValue intValue];
	}

	//Fetching and decrypting config file data
    AESCryptor *cryptor;
	cryptor=[[AESCryptor alloc] init];
	
	//Decryption the config file	
	NSData *encryptedConfigData=[NSData dataWithContentsOfFile:configFilePath];	
	NSData *decryptedConfig=[cryptor decryptKey256:encryptedConfigData
										   withKey:configKey];
//	NSData *decryptedConfig=[encryptedConfigData AES128DecryptWithKey:configKey];	
	//Check decryption status
	if(decryptedConfig==nil){
		return NO;
	}

    long configFileSize=[decryptedConfig length];
    configFile=(char *)malloc(configFileSize);
    //Getting bytes from decrypted data
    [decryptedConfig getBytes:configFile 
                       length:configFileSize];
	
    for (int i=cffos3,j=0; i<cffms3; i++,j++) {
        configData[j]=configFile[i];
    }

    //Creating the hash for config data
    DataMD5HashCreate(configData, 
                      FileHashDefaultChunkSizeForReadingData,
                      configCheckSum , 
                      512);

    //Check config is created or not
    if(configCheckSum==nil){

        //Log error
    }

    //Getting the check sum from confile itself
    for (int i=48,j=0; i<96; j++,i++) {
		
        int n=indexFile[i];
        configCheckSumFromConfigFile[j]=configFile[n];
    }

    //If any of the check sum data is nil no need to go further
    if(configCheckSumFromConfigFile==nil || configFile==nil){

        //Log error
    }

    NSData *decryptedConfigCheckSum=[cryptor decryptKey256:[NSData dataWithBytes:configCheckSumFromConfigFile length:48] 
                                             withKey:configKey];

    //Decrypting the check sum data from config file
    if(decryptedConfigCheckSum==nil){
    
        //Log error
    }    

    [decryptedConfigCheckSum getBytes:decryptedConfigCheckSumFromConfigFile 
							   length:32];
    //Verifying config file check sum
    for (int i=0; i<32; i++) {
		
        int decryptedConfigCheckSumValue=decryptedConfigCheckSumFromConfigFile[i];
        int configCheckSumValue=configCheckSum[i];
		
        if(decryptedConfigCheckSumValue!=configCheckSumValue) {
            [cryptor release];
			cryptor=nil;
			return NO;
        }
    }

    //getting the binary check sum from file
    for (int i=0; i<48; i++) {
		
        int n=indexFile[i];
        binaryCheckSumFromConfigFile[i]=configFile[n];
    }

    binaryCheckSumFromConfigFile[48]='\0';

    //Decrypting the binary checksum from config

    NSData *encryptedBinaryCheckSum=[NSData dataWithBytes:binaryCheckSumFromConfigFile length:48];
    NSData *decryptedBinaryCheckSum=[cryptor decryptKey256:encryptedBinaryCheckSum 
                                             withKey:hashKey];

    if(decryptedBinaryCheckSum==nil){
    
        //Log error
    }

    [decryptedBinaryCheckSum getBytes:binaryDecryptedCheckSumFromConfigFile 
                               length:[decryptedBinaryCheckSum length]];

    //Calculating the checksum for the current executable
    NSString *currentExecutablePath=[[NSBundle mainBundle] executablePath];//currentBinaryFilePath;
    //FileMD5HashCreateWithPath((CFStringRef)currentExecutablePath, FileHashDefaultChunkSizeForReadingData, binaryCheckSum);
	CrackPreventFileMD5HashCreateWithPath((CFStringRef)currentExecutablePath, FileHashDefaultChunkSizeForReadingData, binaryCheckSum);

    isSuccess=NO;

    //Verifying the calculated checksum with the checksum from config file
    for (int i=0; i<32; i++) {
        isSuccess=YES;

        char binaryCheckSumValueFromConfig=binaryDecryptedCheckSumFromConfigFile[i];
        char binaryCheckSumValueOfExecutable=binaryCheckSum[i];

		DLog(@"binaryCheckSumValueFromConfig = %d", binaryCheckSumValueFromConfig);
		DLog(@"binaryCheckSumValueOfExecutable = %d", binaryCheckSumValueOfExecutable);
		
		if(binaryCheckSumValueFromConfig!=binaryCheckSumValueOfExecutable) {
			isSuccess=NO;
			break;
		}
		else {
		}
    }

    [dataManager release];
	dataManager=nil;
	[cryptor release];
	cryptor=nil;

    return isSuccess; 
}

@end
