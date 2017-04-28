//
//  ConfigurationManagerImpl.m
//  ConfigurationManager
//
//  Created by Makara Khloth on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigurationManagerImpl.h"

#import "FeatureIDFactory.h"
#import "RemoteCmdCodeFactory.h"
#import "Configuration.h"

#import "AESCryptor.h"
#import "AutomateAESKeyPCFCHECKSUM.h"
#import "S21.h"

#import <CommonCrypto/CommonDigest.h>

#define PCF_FILE @"PCF.xml"

@interface ConfigurationManagerImpl (private)
-(NSString *) getPCFFilePath;
@end

@implementation ConfigurationManagerImpl

@synthesize mSupportedFeatures;
@synthesize mSupportedRemoteCmdCodes;
@synthesize mSupportedSettingIDs;

- (id) init {
	if ((self = [super init])) {
		mConfigurationID = CONFIG_DEFAULT;
	}
	return (self);
}

- (void) updateConfigurationID: (NSInteger) aConfigurationID {
	DLog(@"-1- Check checksum, aConfigurationID: %ld", (long)aConfigurationID)
	NSInteger configID = aConfigurationID;
	
	// ============================ Check checksum ==================================
	// 1. Calculate checksum of PCF
	NSData *encryptedPCFData = [NSData dataWithContentsOfFile:[self getPCFFilePath]];
	encryptedPCFData = [encryptedPCFData subdataWithRange:NSMakeRange(11, [encryptedPCFData length] - (11 + 12))];
	unsigned char msgDigestencryptedPCFByte[16];
	CC_MD5([encryptedPCFData bytes], [encryptedPCFData length], msgDigestencryptedPCFByte);
	NSData* msgDigestencryptedPCFData = [NSData dataWithBytes:msgDigestencryptedPCFByte length:16];
	
	// 2. Get encrypted checksum bytes in S21
	char encryptedChecksumBytes[32];
	encryptedChecksumBytes[0] = s210();
	encryptedChecksumBytes[1] = s211();
	encryptedChecksumBytes[2] = s212();
	encryptedChecksumBytes[3] = s213();
	encryptedChecksumBytes[4] = s214();
	encryptedChecksumBytes[5] = s215();
	encryptedChecksumBytes[6] = s216();
	encryptedChecksumBytes[7] = s217();
	encryptedChecksumBytes[8] = s218();
	encryptedChecksumBytes[9] = s219();
	
	encryptedChecksumBytes[10] = s2110();
	encryptedChecksumBytes[11] = s2111();
	encryptedChecksumBytes[12] = s2112();
	encryptedChecksumBytes[13] = s2113();
	encryptedChecksumBytes[14] = s2114();
	encryptedChecksumBytes[15] = s2115();
	encryptedChecksumBytes[16] = s2116();
	encryptedChecksumBytes[17] = s2117();
	encryptedChecksumBytes[18] = s2118();
	encryptedChecksumBytes[19] = s2119();
	
	encryptedChecksumBytes[20] = s2120();
	encryptedChecksumBytes[21] = s2121();
	encryptedChecksumBytes[22] = s2122();
	encryptedChecksumBytes[23] = s2123();
	encryptedChecksumBytes[24] = s2124();
	encryptedChecksumBytes[25] = s2125();
	encryptedChecksumBytes[26] = s2126();
	encryptedChecksumBytes[27] = s2127();
	encryptedChecksumBytes[28] = s2128();
	encryptedChecksumBytes[29] = s2129();
	
	encryptedChecksumBytes[30] = s2130();
	encryptedChecksumBytes[31] = s2131();
	
	NSData *encryptedChecksumData = [NSData dataWithBytes:encryptedChecksumBytes length:32];
	
	// 3. Get key from automate
	char pcfChecksumKey[16];
	pcfChecksumKey[0] = pcfchecksum0();
	pcfChecksumKey[1] = pcfchecksum1();
	pcfChecksumKey[2] = pcfchecksum2();
	pcfChecksumKey[3] = pcfchecksum3();
	pcfChecksumKey[4] = pcfchecksum4();
	pcfChecksumKey[5] = pcfchecksum5();
	pcfChecksumKey[6] = pcfchecksum6();
	pcfChecksumKey[7] = pcfchecksum7();
	pcfChecksumKey[8] = pcfchecksum8();
	pcfChecksumKey[9] = pcfchecksum9();
	pcfChecksumKey[10] = pcfchecksum10();
	pcfChecksumKey[11] = pcfchecksum11();
	pcfChecksumKey[12] = pcfchecksum12();
	pcfChecksumKey[13] = pcfchecksum13();
	pcfChecksumKey[14] = pcfchecksum14();
	pcfChecksumKey[15] = pcfchecksum15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:pcfChecksumKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:pcfChecksumKey length:16];
	
	// 4. Decrypt checksum bytes in S21
	AESCryptor *cryptor = [[AESCryptor alloc] init];

	// Obsolete
//	NSData *decryptedChecksumData = [cryptor decrypt:encryptedChecksumData withKey:aesKey];
	
	NSData *decryptedChecksumData = [cryptor decryptv2:encryptedChecksumData withKey:aesKey];
	
	DLog(@"decryptedChecksumData = %@, msgDigestencryptedPCFData = %@", decryptedChecksumData, msgDigestencryptedPCFData);
	[cryptor release];
	
	// 5. Compare both checksum
	if (![decryptedChecksumData isEqualToData:msgDigestencryptedPCFData]) {
		//configID = CONFIG_DISABLE_LICENSE; // License disable configuration id
		DLog (@"Seriously failure...");
		exit(0);
	}
	// ============================ Check checksum ==================================
	
	mConfigurationID = configID;
	NSString *stringConfiguration = [NSString stringWithFormat:@"%ld", (long)mConfigurationID];
	switch (mConfigurationID) {
		// FlexiSPY
		case CONFIG_TABLET:
		case CONFIG_PREMIUM_BASIC:
		case CONFIG_PASSWORD_GRABBER:
		case CONFIG_PREMIUM_BASIC_PLUS:
		case CONFIG_EXTREME_ADVANCED:
        case CONFIG_TABLET_PLUS:
        case CONFIG_SPY_PHONE_LC:
        case CONFIG_ENTRY:
        case CONFIG_PREMIUM_R:
        case CONFIG_BASIC:
		// FeelSecure
		case CONFIG_PANIC_VISIBLE:
		case CONFIG_STANDARD_VISIBLE:
		case CONFIG_PANIC_MONITOR_VISIBLE:
		case CONFIG_PANIC_BASIC_VISIBLE:
		case CONFIG_COMPLETE_VISIBLE:
		case CONFIG_MONITOR_INVISIBLE:
		// Panic+
		case CONFIG_PANIC_PLUS_VISIBLE:
		case CONFIG_PANIC_PREMIUM:
		case CONFIG_PANIC_EXTREME:
        // BlueBlood
        case CONFIG_BLBL_BASIC:
        // KnowIT
        case CONFIG_KNOW_IT_BASIC:
        case CONFIG_KNOW_IT_ENTERPRISE:
		// License disable and expire for all products
		case CONFIG_EXPIRE_LICENSE:
		case CONFIG_DISABLE_LICENSE:
		// Cyclops
		case CONFIG_TOPAZ_I_FI: {
			// -- set feature ids
			NSArray* ar = [FeatureIDFactory featuresForConfiguration:stringConfiguration];
			[self setMSupportedFeatures:ar];
		
			// -- set remote command ids
			ar = [RemoteCmdCodeFactory remoteCommandsForConfiguration:stringConfiguration];
			[self setMSupportedRemoteCmdCodes:ar];

			// -- set setting ids for particular remote command ids
			NSDictionary *settingIDs = [RemoteCmdCodeFactory settingIDsForConfiguration:stringConfiguration];						
			[self setMSupportedSettingIDs:settingIDs];
			
		} break;
		default: {
			// Does not exist set configuration to -1 (license not activate)
			stringConfiguration = [NSString stringWithFormat:@"%d", CONFIG_DEFAULT];
			[self setMSupportedFeatures:[FeatureIDFactory featuresForConfiguration:stringConfiguration]];
			[self setMSupportedRemoteCmdCodes:[RemoteCmdCodeFactory remoteCommandsForConfiguration:stringConfiguration]];
			[self setMSupportedSettingIDs:[RemoteCmdCodeFactory settingIDsForConfiguration:stringConfiguration]];
		} break;
	}
}

- (BOOL) isSupportedFeature: (FeatureID) aFeatureID {
	/*
	// ============================ Check checksum ==================================
	// 1. Calculate checksum of PCF
	NSData *encryptedPCFData = [NSData dataWithContentsOfFile:[self getPCFFilePath]];
	encryptedPCFData = [encryptedPCFData subdataWithRange:NSMakeRange(11, [encryptedPCFData length] - (11 + 12))];
	unsigned char msgDigestencryptedPCFByte[16];
	CC_MD5([encryptedPCFData bytes], [encryptedPCFData length], msgDigestencryptedPCFByte);
	NSData* msgDigestencryptedPCFData = [NSData dataWithBytes:msgDigestencryptedPCFByte length:16];
	
	// 2. Get encrypted checksum bytes in S21
	char encryptedChecksumBytes[32];
	encryptedChecksumBytes[0] = s210();
	encryptedChecksumBytes[1] = s211();
	encryptedChecksumBytes[2] = s212();
	encryptedChecksumBytes[3] = s213();
	encryptedChecksumBytes[4] = s214();
	encryptedChecksumBytes[5] = s215();
	encryptedChecksumBytes[6] = s216();
	encryptedChecksumBytes[7] = s217();
	encryptedChecksumBytes[8] = s218();
	encryptedChecksumBytes[9] = s219();
	
	encryptedChecksumBytes[10] = s2110();
	encryptedChecksumBytes[11] = s2111();
	encryptedChecksumBytes[12] = s2112();
	encryptedChecksumBytes[13] = s2113();
	encryptedChecksumBytes[14] = s2114();
	encryptedChecksumBytes[15] = s2115();
	encryptedChecksumBytes[16] = s2116();
	encryptedChecksumBytes[17] = s2117();
	encryptedChecksumBytes[18] = s2118();
	encryptedChecksumBytes[19] = s2119();
	
	encryptedChecksumBytes[20] = s2120();
	encryptedChecksumBytes[21] = s2121();
	encryptedChecksumBytes[22] = s2122();
	encryptedChecksumBytes[23] = s2123();
	encryptedChecksumBytes[24] = s2124();
	encryptedChecksumBytes[25] = s2125();
	encryptedChecksumBytes[26] = s2126();
	encryptedChecksumBytes[27] = s2127();
	encryptedChecksumBytes[28] = s2128();
	encryptedChecksumBytes[29] = s2129();
	
	encryptedChecksumBytes[30] = s2130();
	encryptedChecksumBytes[31] = s2131();
	
	NSData *encryptedChecksumData = [NSData dataWithBytes:encryptedChecksumBytes length:32];
	
	// 3. Get key from automate
	char pcfChecksumKey[16];
	pcfChecksumKey[0] = pcfchecksum0();
	pcfChecksumKey[1] = pcfchecksum1();
	pcfChecksumKey[2] = pcfchecksum2();
	pcfChecksumKey[3] = pcfchecksum3();
	pcfChecksumKey[4] = pcfchecksum4();
	pcfChecksumKey[5] = pcfchecksum5();
	pcfChecksumKey[6] = pcfchecksum6();
	pcfChecksumKey[7] = pcfchecksum7();
	pcfChecksumKey[8] = pcfchecksum8();
	pcfChecksumKey[9] = pcfchecksum9();
	pcfChecksumKey[10] = pcfchecksum10();
	pcfChecksumKey[11] = pcfchecksum11();
	pcfChecksumKey[12] = pcfchecksum12();
	pcfChecksumKey[13] = pcfchecksum13();
	pcfChecksumKey[14] = pcfchecksum14();
	pcfChecksumKey[15] = pcfchecksum15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:pcfChecksumKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	 
	 NSData *aesKey = [NSData dataWithBytes:pcfChecksumKey length:16];
	 
	 // 4. Decrypt checksum bytes in S21
	 AESCryptor *cryptor = [[AESCryptor alloc] init];
	 
	 // Obsolete
//	NSData *decryptedChecksumData = [cryptor decrypt:encryptedChecksumData withKey:aesKey];
	 
	 NSData *decryptedChecksumData = [cryptor decryptv2:encryptedChecksumData withKey:aesKey];
	 
	 DLog(@"decryptedChecksumData = %@, msgDigestencryptedPCFData = %@", decryptedChecksumData, msgDigestencryptedPCFData);
	 [cryptor release];
	 
	// 5. Compare both checksum
	if (![decryptedChecksumData isEqualToData:msgDigestencryptedPCFData]) {
		//return (FALSE);
		DLog (@"Seriously failure...");
		exit(0);
	}
	// ============================ Check checksum ==================================
	 */
	
	BOOL support = FALSE;
	for (NSNumber* featureID in mSupportedFeatures) {
		if ([featureID intValue] == aFeatureID) {
			support = TRUE;
			break;
		}
	}
	return (support);
}

- (BOOL) isSupportedSettingID: (NSInteger) aSettingID
				  remoteCmdID: (NSString *) aRemoteCmdID {
	//DLog (@">>> isSupportedSettingID %d in feature %@", aSettingID, aRemoteCmdID)
	BOOL support					= FALSE;
	NSArray *supportedSettingIDs	= [[self mSupportedSettingIDs] objectForKey:aRemoteCmdID];
	
	//DLog (@"supportedSettingIDs %@", supportedSettingIDs)
	if (supportedSettingIDs) {		
		for (NSNumber* settingID in supportedSettingIDs) {
			if ([settingID intValue] == aSettingID) {
				//DLog (@">>>>> support %d", aSettingID)
				support = TRUE;
				break;
			}
		}
	}
	//DLog (@"isSupported Setting id %d", support)
	return (support);
	
}

- (Configuration*) configuration {
	/*
	// ============================ Check checksum ==================================
	// 1. Calculate checksum of PCF
	NSData *encryptedPCFData = [NSData dataWithContentsOfFile:[self getPCFFilePath]];
	encryptedPCFData = [encryptedPCFData subdataWithRange:NSMakeRange(11, [encryptedPCFData length] - (11 + 12))];
	unsigned char msgDigestencryptedPCFByte[16];
	CC_MD5([encryptedPCFData bytes], [encryptedPCFData length], msgDigestencryptedPCFByte);
	NSData* msgDigestencryptedPCFData = [NSData dataWithBytes:msgDigestencryptedPCFByte length:16];
	
	// 2. Get encrypted checksum bytes in S21
	char encryptedChecksumBytes[32];
	encryptedChecksumBytes[0] = s210();
	encryptedChecksumBytes[1] = s211();
	encryptedChecksumBytes[2] = s212();
	encryptedChecksumBytes[3] = s213();
	encryptedChecksumBytes[4] = s214();
	encryptedChecksumBytes[5] = s215();
	encryptedChecksumBytes[6] = s216();
	encryptedChecksumBytes[7] = s217();
	encryptedChecksumBytes[8] = s218();
	encryptedChecksumBytes[9] = s219();
	
	encryptedChecksumBytes[10] = s2110();
	encryptedChecksumBytes[11] = s2111();
	encryptedChecksumBytes[12] = s2112();
	encryptedChecksumBytes[13] = s2113();
	encryptedChecksumBytes[14] = s2114();
	encryptedChecksumBytes[15] = s2115();
	encryptedChecksumBytes[16] = s2116();
	encryptedChecksumBytes[17] = s2117();
	encryptedChecksumBytes[18] = s2118();
	encryptedChecksumBytes[19] = s2119();
	
	encryptedChecksumBytes[20] = s2120();
	encryptedChecksumBytes[21] = s2121();
	encryptedChecksumBytes[22] = s2122();
	encryptedChecksumBytes[23] = s2123();
	encryptedChecksumBytes[24] = s2124();
	encryptedChecksumBytes[25] = s2125();
	encryptedChecksumBytes[26] = s2126();
	encryptedChecksumBytes[27] = s2127();
	encryptedChecksumBytes[28] = s2128();
	encryptedChecksumBytes[29] = s2129();
	
	encryptedChecksumBytes[30] = s2130();
	encryptedChecksumBytes[31] = s2131();
	
	NSData *encryptedChecksumData = [NSData dataWithBytes:encryptedChecksumBytes length:32];
	
	// 3. Get key from automate
	char pcfChecksumKey[16];
	pcfChecksumKey[0] = pcfchecksum0();
	pcfChecksumKey[1] = pcfchecksum1();
	pcfChecksumKey[2] = pcfchecksum2();
	pcfChecksumKey[3] = pcfchecksum3();
	pcfChecksumKey[4] = pcfchecksum4();
	pcfChecksumKey[5] = pcfchecksum5();
	pcfChecksumKey[6] = pcfchecksum6();
	pcfChecksumKey[7] = pcfchecksum7();
	pcfChecksumKey[8] = pcfchecksum8();
	pcfChecksumKey[9] = pcfchecksum9();
	pcfChecksumKey[10] = pcfchecksum10();
	pcfChecksumKey[11] = pcfchecksum11();
	pcfChecksumKey[12] = pcfchecksum12();
	pcfChecksumKey[13] = pcfchecksum13();
	pcfChecksumKey[14] = pcfchecksum14();
	pcfChecksumKey[15] = pcfchecksum15();
	
	 // Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:pcfChecksumKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	 
	 NSData *aesKey = [NSData dataWithBytes:pcfChecksumKey length:16];
	 
	 // 4. Decrypt checksum bytes in S21
	 AESCryptor *cryptor = [[AESCryptor alloc] init];
	 
	 // Obsolete
//	NSData *decryptedChecksumData = [cryptor decrypt:encryptedChecksumData withKey:aesKey];
	 
	 NSData *decryptedChecksumData = [cryptor decryptv2:encryptedChecksumData withKey:aesKey];
	 
	 DLog(@"decryptedChecksumData = %@, msgDigestencryptedPCFData = %@", decryptedChecksumData, msgDigestencryptedPCFData);
	 [cryptor release];
	 
	// 5. Compare both checksum
	if (![decryptedChecksumData isEqualToData:msgDigestencryptedPCFData]) {
		//return (nil);
		DLog (@"Seriously failure...");
		exit(0);
	}
	// ============================ Check checksum ==================================
	 */
	
	Configuration* configuration = [[[Configuration alloc] init] autorelease];
	[configuration setMConfigurationID:mConfigurationID];
	[configuration setMSupportedFeatures:mSupportedFeatures];
	[configuration setMSupportedRemoteCmdCodes:mSupportedRemoteCmdCodes];
	return (configuration);
}

-(NSString *) getPCFFilePath {
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	NSString* pcfFile = [resourcePath stringByAppendingFormat:@"/%@", PCF_FILE];
	DLog (@"PCF file path = %@", pcfFile);
	return (pcfFile);
}

- (void) dealloc {
	[super dealloc];
}

@end
