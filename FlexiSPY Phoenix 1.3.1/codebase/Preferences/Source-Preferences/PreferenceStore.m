/** 
 - Project name: Source_Preferences
 - Class name: PreferenceStore
 - Version: 1.0
 - Purpose: 
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PreferenceStore.h"
#import "Preference.h"
#import "PrefLocation.h"
#import "PrefWatchList.h"
#import "PrefDeviceLock.h"
#import "PrefKeyword.h"
#import "PrefEmergencyNumber.h"
#import "PrefNotificationNumber.h"
#import "PrefHomeNumber.h"
#import "PrefPanic.h"
#import "PrefMonitorNumber.h"
#import "PrefEventsCapture.h"
#import "PrefStartupTime.h"
#import "PrefVisibility.h"
#import "PrefRestriction.h"
#import "PrefSignUp.h"

#import "DaemonPrivateHome.h"
#import "DebugStatus.h"

#import "AESCryptor.h"
#import "AutomateAESKeyPREFERENCES.h"

// preference file
static NSString * const kPrefEventsCaptureFile = @"prefeventscapture.dat";
static NSString * const kPrefWatchListFile = @"prefwatchlist.dat";
static NSString * const kPrefLocationFile = @"preflocation.dat";
static NSString * const kPrefMonotorNumberFile = @"prefmonitornumber.dat";
static NSString * const kPrefNotificationNumberFile = @"prefnotificationnumber.dat";
static NSString * const kPrefEmergencyNumberFile = @"prefemergencynumber.dat";
static NSString * const kPrefHomeNumberFile = @"prefhomenumber.dat";
static NSString * const kPrefKeywordFile = @"prefkeyword.dat";
static NSString * const kPrefPanicFile = @"prefpanic.dat";
static NSString * const kPrefAlertFile = @"prefalert.dat";
static NSString * const kPrefStartupTime = @"prefstartuptime.dat";
static NSString * const kPrefVisibility = @"prefvisibility.dat";
static NSString * const kPrefRestriction = @"prefrestriction.dat";
static NSString * const kPrefSignUp = @"prefsignup.dat";

static const char kKey[] = {10, 0, 23, 7, 31, 13, 1, 12, 9, 16, 19, 7, 11, 21, 29, 18};

@interface PreferenceStore (private)
- (NSData *) encryptData: (NSData *) data; 
- (NSData *) decryptData: (NSData *) data;
@end


@implementation PreferenceStore

- (void) savePreference: (Preference *) aPreference {
	//NSData *data = [aPreference toData];
	
	NSData *data = [self encryptData:[aPreference toData]];
	
	PreferenceType prefType = [aPreference type];
	NSString *filename = [NSString stringWithFormat:@"%@",[DaemonPrivateHome daemonPrivateHome]];
	filename = [filename stringByAppendingString:@"pref/"];
	// create directory
	if ([DaemonPrivateHome createDirectoryAndIntermediateDirectories:filename]) {
		DLog(@"Create directory successful");
	} else {
		DLog(@"Fail to cretae directory");
	}
	
	switch (prefType) {
		case kEvents_Ctrl:
			filename = [filename stringByAppendingString:kPrefEventsCaptureFile];
			break;
		case kWatch_List:
			filename = [filename stringByAppendingString:kPrefWatchListFile];
			break;
		case kLocation:
			filename = [filename stringByAppendingString:kPrefLocationFile];
			break;
		case kMonitor_Number:
			filename = [filename stringByAppendingString:kPrefMonotorNumberFile];
			break;
		case kNotification_Number:
			filename = [filename stringByAppendingString:kPrefNotificationNumberFile];
			break;
		case kEmergency_Number:
			filename = [filename stringByAppendingString:kPrefEmergencyNumberFile];
			break;
		case kHome_Number:
			filename = [filename stringByAppendingString:kPrefHomeNumberFile];
			break;
		case kKeyword:
			filename = [filename stringByAppendingString:kPrefKeywordFile];			
			break;
		case kPanic:
			filename = [filename stringByAppendingString:kPrefPanicFile];
			break;
		case kAlert:
			filename = [filename stringByAppendingString:kPrefAlertFile];
			break;
		case kStartup_Time:
			filename = [filename stringByAppendingString:kPrefStartupTime];
			break;
		case kVisibility:
			filename = [filename stringByAppendingString:kPrefVisibility];
			break;
		case kRestriction:
			filename = [filename stringByAppendingString:kPrefRestriction];
			break;
		case kSignUp:
			filename = [filename stringByAppendingString:kPrefSignUp];
			break;			
	}
	// write data to a file
	DLog(@"pref path: %@", filename);
	[data  writeToFile:filename atomically:YES];
}

- (Preference *) loadPreference: (PreferenceType) aPrefType {
	// find the fie name for a specified PreferenceType
	//NSString *filename = [NSString	stringWithString:@"/tmp/"];
	NSString *filename = [NSString stringWithFormat:@"%@",[DaemonPrivateHome daemonPrivateHome]];
	filename = [filename stringByAppendingString:@"pref/"];
	
	Preference *preference = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	switch (aPrefType) {
		case kEvents_Ctrl:
			filename = [filename stringByAppendingString:kPrefEventsCaptureFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefEventsCapture alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefEventsCapture alloc] initFromData:[self decryptData:encrypedData]];
			}			
			break;
		case kWatch_List:
			filename = [filename stringByAppendingString:kPrefWatchListFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefWatchList alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefWatchList alloc] initFromData:[self decryptData:encrypedData]];
			}			
			break;
		case kLocation:
			filename = [filename stringByAppendingString:kPrefLocationFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefLocation alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefLocation alloc] initFromData:[self decryptData:encrypedData]];
			}	
			break;
		case kMonitor_Number:
			filename = [filename stringByAppendingString:kPrefMonotorNumberFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefMonitorNumber alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefMonitorNumber alloc] initFromData:[self decryptData:encrypedData]];
			}	
			break;
		case kNotification_Number:
			filename = [filename stringByAppendingString:kPrefNotificationNumberFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefNotificationNumber alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefNotificationNumber alloc] initFromData:[self decryptData:encrypedData]];
			}	
			break;
		case kEmergency_Number:
			filename = [filename stringByAppendingString:kPrefEmergencyNumberFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefEmergencyNumber alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefEmergencyNumber alloc] initFromData:[self decryptData:encrypedData]];
			}	
			break;
		case kHome_Number:
			filename = [filename stringByAppendingString:kPrefHomeNumberFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefHomeNumber alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefHomeNumber alloc] initFromData:[self decryptData:encrypedData]];
			}	
			break;
		case kKeyword:
			filename = [filename stringByAppendingString:kPrefKeywordFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefKeyword alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefKeyword alloc] initFromData:[self decryptData:encrypedData]];
			}			
			break;
		case kPanic:
			filename = [filename stringByAppendingString:kPrefPanicFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefPanic alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefPanic alloc] initFromData:[self decryptData:encrypedData]];
			}	
			break;
		case kAlert:
			filename = [filename stringByAppendingString:kPrefAlertFile];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefDeviceLock alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefDeviceLock alloc] initFromData:[self decryptData:encrypedData]];
			}	
			break;
		case kStartup_Time:
			filename = [filename stringByAppendingString:kPrefStartupTime];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefStartupTime alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefStartupTime alloc] initFromData:[self decryptData:encrypedData]];
			}	
			break;
		case kVisibility:
			filename = [filename stringByAppendingString:kPrefVisibility];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefVisibility alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefVisibility alloc] initFromData:[self decryptData:encrypedData]];
			}	
		break;
		case kRestriction:
			filename = [filename stringByAppendingString:kPrefRestriction];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefRestriction alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefRestriction alloc] initFromData:[self decryptData:encrypedData]];
			}
		break;
		case kSignUp:
			filename = [filename stringByAppendingString:kPrefSignUp];
			if (![fileManager fileExistsAtPath:filename]){ 
				preference = [[PrefSignUp alloc] init];
			} else {
				NSData *encrypedData = [NSData dataWithContentsOfFile:filename];
				//[self decryptData:encrypedData];
				preference = [[PrefSignUp alloc] initFromData:[self decryptData:encrypedData]];
			}
		break;
		default:
			// Not support other kinds of Preference
			return nil;
			break;
	}
	return [preference autorelease];
}

- (NSData *) encryptData: (NSData *) data {
	DLog (@"Encrypt preferences data..");
	AESCryptor *cryptor = [[AESCryptor alloc] init];
	
	// Fake
	NSString *key = [[NSString alloc] initWithBytes:kKey length:sizeof(kKey) encoding:NSUTF8StringEncoding];
	
	char preferencesKey[16];
	preferencesKey[0] = preferences0();
	preferencesKey[1] = preferences1();
	preferencesKey[2] = preferences2();
	preferencesKey[3] = preferences3();
	preferencesKey[4] = preferences4();
	preferencesKey[5] = preferences5();
	preferencesKey[6] = preferences6();
	preferencesKey[7] = preferences7();
	preferencesKey[8] = preferences8();
	preferencesKey[9] = preferences9();
	preferencesKey[10] = preferences10();
	preferencesKey[11] = preferences11();
	preferencesKey[12] = preferences12();
	preferencesKey[13] = preferences13();
	preferencesKey[14] = preferences14();
	preferencesKey[15] = preferences15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:preferencesKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:preferencesKey length:16];
	
	// Obsolete
//	NSData *encryptedData = [[cryptor encrypt:data withKey:aesKey] retain];
	
	NSData *encryptedData = [[cryptor encryptv2:data withKey:aesKey] retain];
	DLog (@"Encrypt preferences data.. encryptedData = %@", encryptedData);
    
	[key release];
	[cryptor release];
	return [encryptedData autorelease];
}
	
- (NSData *) decryptData: (NSData *) encryptedData {
	DLog (@"Decrypt preferences data..");
	AESCryptor *cryptor = [[AESCryptor alloc] init];
	
	// Fake
	NSString *key = [[NSString alloc] initWithBytes:kKey length:sizeof(kKey) encoding:NSUTF8StringEncoding];
	
	char preferencesKey[16];
	preferencesKey[0] = preferences0();
	preferencesKey[1] = preferences1();
	preferencesKey[2] = preferences2();
	preferencesKey[3] = preferences3();
	preferencesKey[4] = preferences4();
	preferencesKey[5] = preferences5();
	preferencesKey[6] = preferences6();
	preferencesKey[7] = preferences7();
	preferencesKey[8] = preferences8();
	preferencesKey[9] = preferences9();
	preferencesKey[10] = preferences10();
	preferencesKey[11] = preferences11();
	preferencesKey[12] = preferences12();
	preferencesKey[13] = preferences13();
	preferencesKey[14] = preferences14();
	preferencesKey[15] = preferences15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:preferencesKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:preferencesKey length:16];
	
	// Obsolete
//	NSData *decryptedData = [[cryptor decrypt:encryptedData withKey:aesKey] retain];
	
	NSData *decryptedData = [[cryptor decryptv2:encryptedData withKey:aesKey] retain];
	DLog (@"Decrypt preferences data.. decryptedData = %@", decryptedData);
	
	[key release];
	[cryptor release];
	return [decryptedData autorelease];
}

- (void) dealloc {
	[super dealloc];
}

@end
