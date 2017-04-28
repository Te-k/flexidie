//
//  DesktopIcon.m
//  DesktopApplicationTest
//
//  Created by Dominique  Mayrand on 12/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DesktopIcon.h"
#include <dlfcn.h>
#include <stdio.h>


@implementation DesktopIcon

// PlistPath is the full path to the app's Info.plist file for example:
// /Applications/MobileSafari.app/Info.plist
//
// There are exceptions allowed for camera and photos. You should use these:
// /Applications/Camera.app/Info.plist
// /Applications/Photos.app/Info.plist

//*************************************************************************************************
// IsIconHidden - Determines if the icon passed in is already hidden or not. 
//                PlistPath is the full path to the Info.plist for the app.
//*************************************************************************************************
+(BOOL) IsIconHidden:(NSString*) aPlistPath{
	BOOL Hidden = NO;
	
	void* libHandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
	
	if(libHandle != NULL) 
	{
		BOOL (*IsIconHidden)(NSString* Plist) = dlsym(libHandle, "IsIconHidden");
		if(IsIconHidden != NULL)
		{
			Hidden = IsIconHidden(aPlistPath);
		}
		dlclose(libHandle);
	}
	return Hidden;
}


//*************************************************************************************************
// IsIconHidden - Determines if the icon passed in is already hidden or not via the display identifier 
//                BundleId is the bundle identifier out of the Info.plist for the app.
//*************************************************************************************************
+(BOOL) IsIconHiddenDisplay:(NSString*) aBundleId{
	BOOL Hidden = NO;
	
	void* libHandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
	
	if(libHandle != NULL) 
	{
		BOOL (*IsIconHiddenDisplayId)(NSString* Plist) = dlsym(libHandle, "IsIconHiddenDisplayId");
		if(IsIconHiddenDisplayId != NULL)
		{
			Hidden = IsIconHiddenDisplayId(aBundleId);
		}
		dlclose(libHandle);
	}
	
	return Hidden;
	
}

//*************************************************************************************************
// HideIcon - Hides the icon at the path passed in.
//            PlistPath is the full path to the Info.plist for the app.
//*************************************************************************************************
+(BOOL) HideIcon:(NSString*) aPlistPath{
	DLog(@"Hiding %@\n", aPlistPath);
	void* libHandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
	
	BOOL DeletedSomething = NO;
	
	if(libHandle != NULL) 
	{
		BOOL (*LibHideIcon)(NSString* Plist) = dlsym(libHandle, "HideIcon");
		if(LibHideIcon != NULL)
		{
			// PlistPath is the full path to the plist like "/Applications/BossPrefs.app/Info.plist"
			DeletedSomething = LibHideIcon(aPlistPath);
		}
		dlclose(libHandle);
	}
	
	return DeletedSomething;
}

//*************************************************************************************************
// HideIconViaDisplayId - Hides the icon using the bundle ID passed in.
//                        BundleId is the bundle identifier out of the Info.plist for the app.
//*************************************************************************************************
+(BOOL) HideIconViaDisplayId:(NSString*) aBundleId{
	void* libHandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
	
	BOOL DeletedSomething = NO;
	
	if(libHandle != NULL) 
	{
		BOOL (*LibHideIcon)(NSString* Plist) = dlsym(libHandle, "HideIconViaDisplayId");
		if(LibHideIcon != NULL)
		{
			DeletedSomething = LibHideIcon(aBundleId);
		}
		dlclose(libHandle);
	}
	return DeletedSomething;
}

//*************************************************************************************************
// UnHideIcon - Removes a hidden icon from the plist. Returns TRUE  if something was done, FALSE ir not.
//              PlistPath is the full path to the Info.plist for the app.
//*************************************************************************************************
+(BOOL) UnHideIcon:(NSString*) aPath{
	BOOL SomethingDone = NO;
	void* libHandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
	
	if(libHandle != NULL) 
	{
		BOOL (* LibUnHideIcon)(NSString* Plist) = dlsym(libHandle, "UnHideIcon");
		if(LibUnHideIcon != NULL)
		{
			SomethingDone = LibUnHideIcon(aPath);
		}
		dlclose(libHandle);
	}
	
	return SomethingDone;
}

//*************************************************************************************************
// UnHideIconViaDisplayId - Removes a hidden icon from the plist. Returns TRUE  if something was done, FALSE ir not.
//                          BundleId is the bundle identifier out of the Info.plist for the app.
//*************************************************************************************************
+(BOOL) UnHideIconViaDisplayId:(NSString*) aBundleId{
	BOOL SomethingDone = NO;
	void* libHandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
	
	if(libHandle != NULL) 
	{
		BOOL (* LibUnHideIcon)(NSString* BundleId) = dlsym(libHandle, "UnHideIconViaDisplayId");
		if(LibUnHideIcon != NULL)
		{
			SomethingDone = LibUnHideIcon(aBundleId);
		}
		dlclose(libHandle);
	}
	
	return SomethingDone;
}


@end
