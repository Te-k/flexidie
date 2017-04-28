//
//  FeelSecureSettingsController.m
//  FeelSecureSettings
//
//  Created by Makara Khloth on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeelSecureSettingsController.h"
#import <Preferences/PSSpecifier.h>
#import "PreferencesSettingsKeys.h"

#import "PreferenceManagerUtils.h"
#import "PrefPanic.h"
#import "PrefEmergencyNumber.h"
#import "DefStd.h"
#import "AppEngineUICmd.h"
#import "MessagePortIPCSender.h"
#import "SpringBoardServices.h"
#import "SharedFileIPC.h"

#define SIREN_SOUND_ID			@"SirenSound"
#define PANIC_MODE_ID			@"PanicMode"
#define EMERGENCY_MESSAGE_ID	@"EmergencyMessage"
#define VERSION_ID				@"Version"

#define PREFS_PATH @"/var/mobile/Library/Preferences/"

@interface FeelSecureSettingsController (private)
- (void) requestSettings;
- (void) saveSettings;
- (id)dictionaryWithFile:(NSString *)plistPath asMutable:(BOOL)asMutable;
@end


@implementation FeelSecureSettingsController

#pragma mark -
#pragma mark Getter/Setter for specifier
#pragma mark -

- (id)getValueForSpecifier:(PSSpecifier*)specifier
{
	//DLog (@"Get value for specifier ------- specifier = %@", specifier)
	id value = nil;
	
	NSDictionary *specifierProperties = [specifier properties];
	//DLog(@"Specifier properties = %@", specifierProperties)
	NSString *specifierIdentifier = [specifierProperties objectForKey:PREFS_KEYNAME_ID];
	//DLog(@"Specifier identifier = %@", specifierIdentifier)
	
	PreferenceManagerUtils *preferenceManagerUtils = [PreferenceManagerUtils sharedPreferenceManagerUtils];
	PrefPanic *prefPanic = [preferenceManagerUtils mPrefPanic];
	//DLog(@"Preference manager utils = %@, panic = %@", preferenceManagerUtils, prefPanic)
	
	// get 'value' with code only
	if ([specifierIdentifier isEqualToString:SIREN_SOUND_ID])
	{
		if (prefPanic) {
			value = [NSNumber numberWithBool:[prefPanic mEnablePanicSound]];
		} else {
			value = [NSNumber numberWithBool:TRUE];
		}
	}
	else if ([specifierIdentifier isEqualToString:PANIC_MODE_ID])
	{
		if (prefPanic) {
			// 1 - Location plus camera image
			// 2 - Location only
			if ([prefPanic mLocationOnly]) {
				value = @"2";
			} else {
				value = @"1";
			}

		} else {
			// Default value in plist is 2 which is 'Location plus camera image'
			NSString *defaults = [specifierProperties objectForKey:PREFS_KEYNAME_DEFAULTS];
			NSString *path = [NSString stringWithFormat:@"%@%@", PREFS_PATH, defaults];
			NSDictionary *dict = [self dictionaryWithFile:path asMutable:NO];
			value = [dict objectForKey:@"mode"];
		}

	}
	else if ([specifierIdentifier isEqualToString:EMERGENCY_MESSAGE_ID])
	{
		if (prefPanic && [[prefPanic mStartUserPanicMessage] length]) {
			value = [prefPanic mStartUserPanicMessage];
		} else {
			value = [specifierProperties objectForKey:PREFS_KEYNAME_DEFAULT];
		}
	}
	else if ([specifierIdentifier isEqualToString:VERSION_ID])
	{
		if ([preferenceManagerUtils mVersion]) {
			value = [preferenceManagerUtils mVersion];
		} else {
			value = @"";
		}
	}
	
	return value;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;
{
	//DLog (@"Set value ------- value = %@, class of value = %@, specifier = %@", value, [value class], specifier)
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierIdentifier = [specifierProperties objectForKey:PREFS_KEYNAME_ID];
	
	PreferenceManagerUtils *preferenceManagerUtils = [PreferenceManagerUtils sharedPreferenceManagerUtils];
	PrefPanic *prefPanic = [preferenceManagerUtils mPrefPanic];
	
	// use 'value' with code only
	if ([specifierIdentifier isEqualToString:SIREN_SOUND_ID])
	{
		NSNumber *boolValue = value;
		[prefPanic setMEnablePanicSound:[boolValue boolValue]];
	}
	else if ([specifierIdentifier isEqualToString:PANIC_MODE_ID]) {
		// 1 - Location plus camera image
		// 2 - Location only
		if ([value isEqualToString:@"2"]) {
			[prefPanic setMLocationOnly:YES];
		} else if ([value isEqualToString:@"1"]) {
			[prefPanic setMLocationOnly:NO];
		}
		
		// Leave the job to daemon to update defaults settings to this bundle in [self saveSettings]
//		NSString *defaults = [specifierProperties objectForKey:PREFS_KEYNAME_DEFAULTS];
//		NSString *path = [NSString stringWithFormat:@"%@%@", PREFS_PATH, defaults];
//		NSMutableDictionary *dict = [self dictionaryWithFile:path asMutable:YES];
//		[dict setObject:value forKey:@"mode"];
//		[dict writeToFile:path atomically:YES];
	}

	else if ([specifierIdentifier isEqualToString:EMERGENCY_MESSAGE_ID])
	{
		[prefPanic setMStartUserPanicMessage:value];
	}
	
	[self saveSettings];
}

#pragma mark -
#pragma mark PSViewController methods
#pragma mark -


- (void)advancedButtonPressed:(PSSpecifier *)specifier
{
	//DLog (@"Advanced button pressed ------- specifier = %@", specifier)
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
	
	// Bring ssmp to foreground
	NSString* bundleID = @"com.app.ssmp";
	//DLog(@"ssmp bundleID: %@", bundleID)
	NSInteger error = SBSLaunchApplicationWithIdentifier((CFStringRef)bundleID, NO);
	//DLog(@"Launch ssmp with error: %d", error);
	if (error) {
		CFStringRef errorStr = SBSApplicationLaunchingErrorString(error);
		//DLog(@"Convert ssmp error to string errorStr: %@", (NSString *)errorStr);
		CFRelease(errorStr);
	} else {
//		[NSThread sleepForTimeInterval:2.0];
//		// Post notification
//		CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(),
//											  (CFStringRef) @"com.app.ssmp.FeelSecureSettings.AdvancedButtonClicked",
//											  nil,
//											  nil,
//											  false);
//		DLog (@"Posted darwin notification to ssmp---------------------------");
		
		BOOL launch = YES;
		NSData *launchData = [NSData dataWithBytes:&launch length:sizeof(BOOL)];
		SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate]; // File is created in daemon
		[shareFileIPC writeData:launchData withID:kSharedFileFeelSecureSettingsBundleLaunchID];
		[shareFileIPC release];
	}
}

- (id)specifiers
{
	if (_specifiers == nil)
		_specifiers = [[self loadSpecifiersFromPlistName:@"FeelSecureSettings" target:self] retain];
	//DLog (@"Feelsecure settings controller specifiers ------- _specifiers = %@", _specifiers)
	return _specifiers;
}

- (id)init
{
	if ((self = [super init]))
	{
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kSettingBundleMsgPort
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
		
		//[self requestSettings];
	}
	//DLog (@"Feelsecure settings controller init ------- self = %@", self)
	return self;
}

- (void) viewWillAppear:(BOOL)animated {
	//DLog(@"PSViewController is a sub-class of UIViewController....")
	[super viewWillAppear:animated];
	[self requestSettings];
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void)dealloc
{
	DLog(@"FeelSecure settings controller is deallocated...")
	[mMessagePortReader stop];
	[mMessagePortReader release];
	[super dealloc];
}

#pragma mark -
#pragma mark IPC mesage port
#pragma mark -

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	//DLog (@"Feelsecure setting view controller got some preference data from daemon = %@", aRawData)
	NSInteger echoCommand = kAppUI2EngineUnknownCmd;
	NSInteger location, length;
	location = length = 0;
	[aRawData getBytes:&echoCommand length:sizeof(NSInteger)];
	location += sizeof(NSInteger);
	
	PreferenceManagerUtils *preferenceManagerUtils = [PreferenceManagerUtils sharedPreferenceManagerUtils];
	if (echoCommand == kSettingsBundle2EngineGetSettingsCmd) {
		
		// Panic preference
		[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSData *subData = [aRawData subdataWithRange:NSMakeRange(location, length)];
		PrefPanic *prefPanic = [[PrefPanic alloc] initFromData:subData];
		[preferenceManagerUtils setMPrefPanic:prefPanic];
		[prefPanic release];
		location += length;
		
		// Emergency numbers preference
		[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		subData = [aRawData subdataWithRange:NSMakeRange(location, length)];
		PrefEmergencyNumber *prefEmergencyNumbers = [[PrefEmergencyNumber alloc] initFromData:subData];
		[preferenceManagerUtils setMPrefEmergencyNumbers:prefEmergencyNumbers];
		[prefEmergencyNumbers release];
		location += length;
		
		// Version number
		[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		subData = [aRawData subdataWithRange:NSMakeRange(location, length)];
		NSString *version = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
		[preferenceManagerUtils setMVersion:version];
		[version release];
	}
	
	//DLog (@"Preference manager utils = %@, panic = %@, emergency = %@", preferenceManagerUtils,
	//	  [preferenceManagerUtils mPrefPanic], [preferenceManagerUtils mPrefEmergencyNumbers])
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) requestSettings {
	NSInteger command = kSettingsBundle2EngineGetSettingsCmd;
	NSData *commandData = [NSData dataWithBytes:&command length:sizeof(NSInteger)];
	MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kAppUISendMessagePort];
	[sender writeDataToPort:commandData];
	[sender release];
}

- (void) saveSettings {
	//DLog(@"Save preference settings in Feelsecure setting view controller to daemon....")
	PreferenceManagerUtils *preferenceManagerUtils = [PreferenceManagerUtils sharedPreferenceManagerUtils];
	PrefPanic *prefPanic = [preferenceManagerUtils mPrefPanic];
	PrefEmergencyNumber *prefEmergencyNumbers = [preferenceManagerUtils mPrefEmergencyNumbers];
	
	NSInteger command = kSettingsBundle2EngineSaveSettingsCmd;
	NSMutableData *commandData = [NSMutableData dataWithBytes:&command length:sizeof(NSInteger)];
	NSData *prefData = [prefPanic toData];
	NSInteger length = [prefData length];
	[commandData appendBytes:&length length:sizeof(NSInteger)];
	[commandData appendData:prefData];
	prefData = [prefEmergencyNumbers toData];
	length = [prefData length];
	[commandData appendBytes:&length length:sizeof(NSInteger)];
	[commandData appendData:prefData];
	
	MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kAppUISendMessagePort];
	[sender writeDataToPort:commandData];
	[sender release];
}

- (id)dictionaryWithFile:(NSString *)plistPath asMutable:(BOOL)asMutable
{
	
	Class class;
	if (asMutable)
		class = [NSMutableDictionary class];
	else
		class = [NSDictionary class];
	
	id dict;	
	if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
		dict = [[class alloc] initWithContentsOfFile:plistPath];	
	else
		dict = [[class alloc] init];
	
	return [dict autorelease];
}

@end