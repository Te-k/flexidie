//
//  LicenseManager.m
//  LicenseManager
//
//  Created by Pichaya Srifar on 10/3/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "LicenseManager.h"
#import "LicenseInfo.h"
#import "NSData-LCMAES.h"

@implementation LicenseManager

@synthesize mListenerList;
@synthesize mCurrentLicenseInfo;
@synthesize mFilePath;


#pragma mark - singleton declaration

- (id)init {
	if ((self = [super init])) {        
		if (mFilePath == nil) {
#if TARGET_IPHONE_SIMULATOR	
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docPath = [paths objectAtIndex:0];
			NSString *filePath = [docPath stringByAppendingPathComponent:@"i.os"];
			[self setMFilePath:filePath];
			DLog(@"filePath %@", [self mFilePath]);
#else
			
#endif
		}
		[self setMListenerList:[NSMutableArray array]];
        
		LicenseInfo *licenseInfo = [[LicenseInfo alloc] init];
        
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		if ([fileMgr fileExistsAtPath:mFilePath]) {
			@try {
			// generate key from uuid 8 bytes and hard code 8 byets
			NSMutableString *aesKey = [NSMutableString stringWithCapacity:16];
			NSString *uuid = [[UIDevice currentDevice] uniqueIdentifier];
			[aesKey appendString:[uuid substringToIndex:8]];
			[aesKey appendString:@"6b3JjabP"];

			NSData *fileData = [NSData dataWithContentsOfFile:mFilePath];
			DLog(@"fileData %@", fileData);
			NSData *decryptedData = [fileData AES128DecryptWithKey:aesKey];
			DLog(@"decryptedData %@", decryptedData);
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
				DLog(@"licenseStatus %d", licenseStatus);
				[decryptedData getBytes:&configID range:NSMakeRange(offset, sizeof(configID))];
				offset+=sizeof(configID);
				DLog(@"setConfigID %d", configID);
				md5 = [decryptedData subdataWithRange:NSMakeRange(offset, 16)];
				offset+=16;
				DLog(@"md5 %@", md5);
				DLog(@"offset %d", offset);
				
				[decryptedData getBytes:&activationCodeSize range:NSMakeRange(offset, sizeof(activationCodeSize))];
				offset+=sizeof(activationCodeSize);
				DLog(@"activationCode size %d %d", activationCodeSize, sizeof(activationCodeSize));
				activationCode = [[NSString alloc] initWithData:[decryptedData subdataWithRange:NSMakeRange(offset, activationCodeSize)] encoding:NSUTF8StringEncoding];
				
				[licenseInfo setLicenseStatus:licenseStatus];
				[licenseInfo setConfigID:configID];
				[licenseInfo setMd5:md5];
				[licenseInfo setActivationCode:activationCode];

				[activationCode release];

				} else {
					DLog(@"check size failed");
					[licenseInfo setLicenseStatus:DEACTIVATED];
				}
			}
			@catch (NSException *exception) {
				DLog(@"exception %@", exception);
				[licenseInfo setLicenseStatus:DEACTIVATED];
			}
			@finally {
				
			}                
		} else {
			// file is not exists
			[licenseInfo setLicenseStatus:DEACTIVATED];
		}
		[self setMCurrentLicenseInfo:licenseInfo];
		[licenseInfo release];
	}
	DLog(@"licenseStatus %d", [[self mCurrentLicenseInfo] licenseStatus]);
	DLog(@"setConfigID %d", [[self mCurrentLicenseInfo] configID]);
	DLog(@"md5 %@", [[self mCurrentLicenseInfo] md5]);
	DLog(@"activationCode %@", [[self mCurrentLicenseInfo] activationCode]);
	return self;
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
	if (![fileMgr isWritableFileAtPath:mFilePath]) {
		DLog(@"DEBUG isWritableFileAtPath %@", mFilePath);
		return NO;
	}
    
	if ([licenseInfo licenseStatus] == DEACTIVATED) {
		[licenseInfo setActivationCode:@"9999999999"];
		[licenseInfo setMd5:[@"PPPPPPPPPPPPPPPP" dataUsingEncoding:NSUTF8StringEncoding]];
		[licenseInfo setConfigID:1];
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

	// generate key from uuid 8 bytes and hard code 8 byets
	NSMutableString *aesKey = [NSMutableString stringWithCapacity:16];
	NSString *uuid = [[UIDevice currentDevice] uniqueIdentifier];
	[aesKey appendString:[uuid substringToIndex:8]];
	[aesKey appendString:@"6b3JjabP"];

	DLog(@"licenseData %@", licenseData);
	NSData *encrypted = [licenseData AES128EncryptWithKey:aesKey];
	DLog(@"encrypted %@", encrypted);

	
	NSError *error = nil;
	
	if ([fileMgr fileExistsAtPath:mFilePath]) {
		[fileMgr removeItemAtPath:mFilePath error:&error];
		if (error) {
			DLog(@"DEBUG Can not removeItemAtPath %@", mFilePath);
			return NO;
		}
	}

	[encrypted writeToFile:mFilePath atomically:YES];
	//[encrypted writeToFile:mFilePath options:0 error:&error];
	
	if (error) {
		DLog(@"DEBUG can not write file %@", mFilePath);
		return NO;
	} else {
		[self setMCurrentLicenseInfo:licenseInfo];
		for (id<LicenseChangeListener> listener in mListenerList) {
			[listener onLicenseChanged:licenseInfo];
		}
		return YES;
	}
}

- (NSString *)getActivationCode {
    if (mCurrentLicenseInfo != nil) {
        return [mCurrentLicenseInfo activationCode];
    }
    return nil;
}

- (NSInteger)getConfiguration {
    if (mCurrentLicenseInfo != nil) {
        return [mCurrentLicenseInfo configID];
    }
    return 0;
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
    return nil;
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
	DLog(@"ENTER addLicenseChangeListener %@", listener);
	[mListenerList addObject:listener];
}

- (void)removeLicenseChangeListener:(id<LicenseChangeListener>)listener {
	[mListenerList removeObject:listener];
}

- (void)removeAllLicenseChangeListener {
	[mListenerList removeAllObjects];
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [mListenerList release];
    [mCurrentLicenseInfo release];
    [mFilePath release];
    
    [super dealloc];
}


@end
