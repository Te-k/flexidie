//
//  EmergencyNumberController.m
//  FeelSecureSettings
//
//  Created by Makara Khloth on 8/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EmergencyNumberController.h"
#import "PreferenceManagerUtils.h"
#import "PreferencesSettingsKeys.h"

#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "PrefPanic.h"
#import "PrefEmergencyNumber.h"
#import "AppEngineUICmd.h"

#define EM1_ID		@"n1"
#define EM2_ID		@"n2"
#define EM3_ID		@"n3"
#define EM4_ID		@"n4"
#define EM5_ID		@"n5"

@interface EmergencyNumberController (private)
- (void) saveSettings;
- (BOOL) isEmergencyValid: (NSSet *) aEmergencyNumbers;
- (void) requestSettings;
@end


@implementation EmergencyNumberController

- (id)specifiers
{
	if (_specifiers == nil)
		_specifiers = [[self loadSpecifiersFromPlistName:@"EmergencyNumberSettings" target:self] retain];
	//DLog (@"Emergency numbers specifiers ------- _specifiers = %@", _specifiers)
	return _specifiers;
}

#pragma mark -
#pragma mark Memory allocation & deallocation
#pragma mark -

- (id)init
{
	if ((self = [super init]))
	{
	}
	//DLog (@"Emergency number init ------- self = %@", self)
	return self;
}

- (void)dealloc
{
	DLog(@"Emergency number controller is deallocated...")
	[super dealloc];
}

#pragma mark -
#pragma mark Getter/Setter method
#pragma mark -

- (id)getValueForSpecifier:(PSSpecifier*)specifier {
	//DLog (@"Get value ------- specifier = %@", specifier)
	
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierIdentifier = [specifierProperties objectForKey:PREFS_KEYNAME_ID];
	
	PreferenceManagerUtils *preferenceManagerUtils = [PreferenceManagerUtils sharedPreferenceManagerUtils];
	PrefEmergencyNumber *prefEmergencyNumbers = [preferenceManagerUtils mPrefEmergencyNumbers];
	//DLog (@"Preference manager utils = %@, emergency numbers = %@", preferenceManagerUtils, prefEmergencyNumbers)
	
	// use 'value' with code only
	id value = nil;
	if ([specifierIdentifier isEqualToString:EM1_ID])
	{
		if ([[prefEmergencyNumbers mEmergencyNumbers] count]) {
			value = [[prefEmergencyNumbers mEmergencyNumbers] objectAtIndex:0];
		}
	}
	else if ([specifierIdentifier isEqualToString:EM2_ID]) {
		if ([[prefEmergencyNumbers mEmergencyNumbers] count] > 1) {
			value = [[prefEmergencyNumbers mEmergencyNumbers] objectAtIndex:1];;
		}
	}
	else if ([specifierIdentifier isEqualToString:EM3_ID])
	{
		if ([[prefEmergencyNumbers mEmergencyNumbers] count] > 2) {
			value = [[prefEmergencyNumbers mEmergencyNumbers] objectAtIndex:2];
		}
	}
	else if ([specifierIdentifier isEqualToString:EM4_ID])
	{
		if ([[prefEmergencyNumbers mEmergencyNumbers] count] > 3) {
			value = [[prefEmergencyNumbers mEmergencyNumbers] objectAtIndex:3];
		}
	}
	else if ([specifierIdentifier isEqualToString:EM5_ID])
	{
		if ([[prefEmergencyNumbers mEmergencyNumbers] count] > 4) {
			value = [[prefEmergencyNumbers mEmergencyNumbers] objectAtIndex:4];
		}
	}
	
	return (value);
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier {
	//DLog (@"Set value ------- value = %@, class of value = %@, specifier = %@", value, [value class], specifier)
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierIdentifier = [specifierProperties objectForKey:PREFS_KEYNAME_ID];
	
	PreferenceManagerUtils *preferenceManagerUtils = [PreferenceManagerUtils sharedPreferenceManagerUtils];
	PrefEmergencyNumber *prefEmergencyNumbers = [preferenceManagerUtils mPrefEmergencyNumbers];
	NSMutableArray *ens = [NSMutableArray arrayWithArray:[prefEmergencyNumbers mEmergencyNumbers]];
	
	// use 'value' with code only
	NSString *number = value;
	BOOL valid = NO;
	NSInteger emergencyIndex = 0;
	if ([specifierIdentifier isEqualToString:EM1_ID])
	{
//		if ([ens count] > 0) {
//			[ens replaceObjectAtIndex:0 withObject:number];
//		} else {
//			[ens addObject:number];
//		}
		emergencyIndex = 0;
	}
	else if ([specifierIdentifier isEqualToString:EM2_ID]) {
//		if ([ens count] > 1) {
//			[ens replaceObjectAtIndex:1 withObject:number];
//		} else {
//			[ens addObject:number];
//		}
		emergencyIndex = 1;
	}
	else if ([specifierIdentifier isEqualToString:EM3_ID])
	{
//		if ([ens count] > 2) {
//			[ens replaceObjectAtIndex:2 withObject:number];
//		} else {
//			[ens addObject:number];
//		}
		emergencyIndex = 2;
	}
	else if ([specifierIdentifier isEqualToString:EM4_ID])
	{
//		if ([ens count] > 3) {
//			[ens replaceObjectAtIndex:3 withObject:number];
//		} else {
//			[ens addObject:number];
//		}
		emergencyIndex = 3;
	}
	else if ([specifierIdentifier isEqualToString:EM5_ID])
	{
//		if ([ens count] > 4) {
//			[ens replaceObjectAtIndex:4 withObject:number];
//		} else {
//			[ens addObject:number];
//		}
		emergencyIndex = 4;
	}
	//DLog(@"Emergency numbers = %@, emergencyIndex = %d", ens, emergencyIndex)
	if ([number length]) { // Reset the existing number or add new number
		if ([ens count] > emergencyIndex) {
			NSMutableArray *array = [NSMutableArray arrayWithArray:ens];
			[array replaceObjectAtIndex:emergencyIndex withObject:number];
			NSSet *set = [NSSet setWithArray:array];
			if (valid = [self isEmergencyValid:set]) {
				[ens replaceObjectAtIndex:emergencyIndex withObject:number];
			}
		} else {
			NSMutableArray *array = [NSMutableArray arrayWithArray:ens];
			[array addObject:number];
			NSSet *set = [NSSet setWithArray:array];
			if (valid = [self isEmergencyValid:set]) {
				[ens addObject:number];
			}
		}
	} else { // 0 lenth is equal to user reset
		valid = YES;
		if ([ens count] > emergencyIndex) {
			[ens removeObjectAtIndex:emergencyIndex];
		}
	}
	//DLog(@"Emergency numbers after checking = %@", ens)
	//DLog (@"The number that have entered is valid = %d, number = %@", valid, number);
	if (valid) {
		NSSet *set = [NSSet setWithArray:ens]; // Filter out the duplicate numbers
		[prefEmergencyNumbers setMEmergencyNumbers:[set allObjects]];
	} else {
		// Show alert dialog box
		NSString *title = [specifierProperties objectForKey:PREFS_KEYNAME_TITLE];
		NSString *text = [specifierProperties objectForKey:PREFS_KEYNAME_DEFAULT];
		NSString *button = [specifierProperties objectForKey:PREFS_KEYNAME_BUTTON];
		//DLog(@"title = %@, text = %@, button = %@", title, text, button)
		
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:title];
		[alert setMessage:text];
		//[alert setDelegate:self];
		[alert addButtonWithTitle:button];
		[alert show];
		[alert release];
	}

	[self saveSettings];
}

#pragma mark -
#pragma mark UIViewController
#pragma mark -

- (void) viewWillAppear:(BOOL)animated {
	//DLog(@"PSViewController emergency number is a sub-class of UIViewController....")
	[super viewWillAppear:animated];
	
	PreferenceManagerUtils *preferenceManagerUtils = [PreferenceManagerUtils sharedPreferenceManagerUtils];
	PrefEmergencyNumber *prefEmergencyNumbers = [preferenceManagerUtils mPrefEmergencyNumbers];
	if (prefEmergencyNumbers == nil) {
		DLog (@"Preference emergency numbers is nil thus request from daemon")
		[self requestSettings]; // This will handle in FeelSecureSettingsController since it did not deallocate (TESTED)
	}
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) saveSettings {
	//DLog(@"Save preference settings in Emergency number view controller to daemon....")
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

- (BOOL) isEmergencyValid: (NSSet *) aEmergencyNumbers {
	DLog(@"Emergency number set = %@", aEmergencyNumbers)
	BOOL pass = [aEmergencyNumbers count] ? YES : NO;
	if (pass) {
		//DLog (@"Pass check count element of set")
		NSArray *allObjects = [aEmergencyNumbers allObjects];
		for (NSInteger i = 0; i < [allObjects count]; i++) {
			NSString *numberi = [allObjects objectAtIndex:i];
			if ([numberi length] >= 0 && [numberi length] < 5) {
				pass = NO;
				break;
			}
			//DLog (@"Pass check length of element %d", i)
			for (NSInteger j = i + 1; j < [allObjects count]; j++) {
				NSString *numberj = [allObjects objectAtIndex:j];
				if ([numberi isEqualToString:numberj]) {
					pass = NO;
					break;
				}
			}
			if (!pass) {
				break;
			}
		}
	}
	DLog (@"Final result after serveral checks validity of element of set = %d", pass)
	return (pass);
}

- (void) requestSettings {
	NSInteger command = kSettingsBundle2EngineGetSettingsCmd;
	NSData *commandData = [NSData dataWithBytes:&command length:sizeof(NSInteger)];
	MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kAppUISendMessagePort];
	[sender writeDataToPort:commandData];
	[sender release];
}

@end
