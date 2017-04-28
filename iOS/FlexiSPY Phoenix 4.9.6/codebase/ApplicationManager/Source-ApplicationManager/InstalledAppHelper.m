//
//  InstalledAppHelper.m
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InstalledAppHelper.h"
#import "InstalledApplication.h"
#import "DateTimeFormat.h"
#import "MediaTypeEnum.h"
#import "SystemUtilsImpl.h"

#import "IconUtils.h"

#import "SpringBoardServices+IOS8.h"

static NSString* const kApplicationPlistPath                    = @"/User/Library/Caches/com.apple.mobile.installation.plist";
static NSString* const kApplicationPlistPathiOS7                = @"/private/var/mobile/Library/Caches/com.apple.mobile.installation.plist";

static NSString* const kSystemApplicationPathiOS8               = @"/Applications/";
static NSString* const kUserApplicationPathiOS8                 = @"/var/mobile/Containers/Bundle/Application/";

static NSString* const kUserApplicationPathiOS9_2                = @"/var/containers/Bundle/Application/";

static NSString* const kApplicationOwnerKey                     = @"kApplicationTypeKey";
static NSString* const kApplicationIDKey                        = @"kApplicationIDKey";
static NSString* const kApplicationPathKey                      = @"kApplicationPathKey";

@interface InstalledAppHelper (private)

+ (BOOL) isIOS8Onward;
+ (NSArray *) createInstalledApplicationMetadataArrayPriorToIOS8;
+ (NSArray *) createInstalledApplicationMetadataArrayiOS8;

+ (InstalledApplication *) getInstalledApplicationForAppMetadataInfoPriorToIOS8: (NSDictionary *) aAppMetadataInfo;
+ (InstalledApplication *) getInstalledApplicationForAppMetadataInfoIOS8: (NSDictionary *) aAppMetadataInfo;

+ (BOOL) isApplicationPathExist: (NSDictionary *) aAppInfo
                       appOwner: (ApplicationOwner) aOwner;

+ (InstalledApplication *)	createInstalledApplicationObjectFromAppInfoPriorToIOS8: (NSDictionary *) aAppInfo
                                                                         appOwner: (ApplicationOwner) aOwner;
+ (InstalledApplication *)	createInstalledApplicationObjectFromAppInfoiOS8: (NSDictionary *) aAppInfo
                                                                  appOwner: (ApplicationOwner) aOwner
                                                           applicationPath: (NSString *) aApplicationPath;

+ (BOOL) isPNGExist: (NSString *) aFilename;
@end


@implementation InstalledAppHelper

/*
+ (NSArray *) createInstalledApplicationArray {	
	DLog(@"Create installed application list from plist");

	NSString *installedAppPlistPath		= [[NSFileManager defaultManager] fileExistsAtPath:kApplicationPlistPath] ? kApplicationPlistPath : kApplicationPlistPathiOS7;
	NSMutableDictionary *plistContent	= [[NSMutableDictionary alloc] initWithContentsOfFile:installedAppPlistPath];
	
	NSDictionary *userInstalledApp		= [[NSDictionary alloc] initWithDictionary:[plistContent objectForKey:@"User"]];
	NSDictionary *systemInstalledApp	= [[NSDictionary alloc] initWithDictionary:[plistContent objectForKey:@"System"]];
	
	[plistContent release];
	plistContent = nil;
	
	//DLog(@"userInstalledApp: %@", userInstalledApp);
	//DLog(@"systemInstalledApp: %@", systemInstalledApp);
	
	NSMutableArray *applicationArray	= [NSMutableArray array];	
	NSString* bundleID					= [[NSBundle mainBundle] bundleIdentifier];
	
	// -- User application
	for (NSString* appKey in [userInstalledApp allKeys]) {	
		NSAutoreleasePool *pool1	= [[NSAutoreleasePool alloc] init];
		
		NSDictionary *appInfo		= [userInstalledApp objectForKey:appKey];		
		NSString *bundleIdentifier	= [appInfo objectForKey:@"CFBundleIdentifier"];
		
		if (![bundleID isEqualToString:bundleIdentifier]) {
			InstalledApplication *installedApp = [InstalledAppHelper createInstalledApplicationObjectFromAppInfo:appInfo 
																										appOwner:kApplicationOwnerUser];
			if ([installedApp mSize] != 0) {		// Ensure that the application exists
				//DLog (@"add user app %@", [installedApp mName])
				[applicationArray addObject:installedApp];
			} else {
				DLog (@"Application not exist")
			}

		}
		
		[pool1 drain];
	}
	
	[userInstalledApp release];
	userInstalledApp = nil;
	
	// -- System application
	for (NSString* appKey in [systemInstalledApp allKeys]) {
		NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
		NSDictionary *appInfo = [systemInstalledApp objectForKey:appKey];
		
		NSString *bundleIdentifier = [appInfo objectForKey:@"CFBundleIdentifier"];
		if (![bundleID isEqualToString:bundleIdentifier]) {
			InstalledApplication *installedApp = [InstalledAppHelper createInstalledApplicationObjectFromAppInfo:appInfo
																										appOwner:kApplicationOwnerSystem];						
			if ([installedApp mSize] != 0) {		// Ensure that the application exists
				//DLog (@"add system app %@", [installedApp mName])
				[applicationArray addObject:installedApp];
			} else {
				DLog (@"Application not exist")
			}					
		}
		
		[pool2 drain];
	}
	
	[systemInstalledApp release];
	systemInstalledApp = nil;
	
	DLog(@"app array: %@", applicationArray);	
	
	return [NSArray arrayWithArray:applicationArray];
}
*/

+ (BOOL) isIOS8Onward {
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) return YES;
    else return NO;
}


#pragma mark - (Public) Prepare metadata


+ (NSArray *) createInstalledApplicationMetadataArray {
    NSArray *metadata = nil;
    if ([self isIOS8Onward]) {
        metadata = [self createInstalledApplicationMetadataArrayiOS8];
    } else {
        metadata = [self createInstalledApplicationMetadataArrayPriorToIOS8];
    }
    return metadata;
}


#pragma mark - (Private) Prepare metadata for iOS 7


+ (NSArray *) createInstalledApplicationMetadataArrayPriorToIOS8 {
    
	DLog(@"Create installed application metadata list from plist");
    
	NSString *installedAppPlistPath		= [[NSFileManager defaultManager] fileExistsAtPath:kApplicationPlistPath] ? kApplicationPlistPath : kApplicationPlistPathiOS7;
	NSMutableDictionary *plistContent	= [[NSMutableDictionary alloc] initWithContentsOfFile:installedAppPlistPath];
	NSDictionary *userInstalledApp		= [[NSDictionary alloc] initWithDictionary:[plistContent objectForKey:@"User"]];
	NSDictionary *systemInstalledApp	= [[NSDictionary alloc] initWithDictionary:[plistContent objectForKey:@"System"]];
	[plistContent release];
	plistContent = nil;

    /******************************************************
     userInstalledApp ==>
        User
            com.atebits.Tweeties2
                ApplicationType
                CFBundleName
                CFBundleVersion
                Container
                ...
            ...
     
     systemInstalledApp ==>
        System
            ...
     
     *****************************************************/
	   
	//DLog(@"userInstalledApp: %@", userInstalledApp);
	//DLog(@"systemInstalledApp: %@", systemInstalledApp);
	
	NSMutableArray *applicationArray	= [NSMutableArray array];
	NSString* fsBundleID                = [[NSBundle mainBundle] bundleIdentifier];
	
	// -- User application
	for (NSString* appKey in [userInstalledApp allKeys]) {
        
        // appKey ==> e.g., com.atebits.Tweeties2
		NSDictionary *appInfo           = [userInstalledApp objectForKey:appKey];
		NSString *bundleIdentifier      = [appInfo objectForKey:@"CFBundleIdentifier"];
		
		if (![fsBundleID isEqualToString:bundleIdentifier]) {
            if ([InstalledAppHelper isApplicationPathExist:appInfo appOwner:kApplicationOwnerUser]) {
                NSDictionary *metadata  = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           [NSNumber numberWithInteger:kApplicationOwnerUser],   kApplicationOwnerKey,
                                           appKey,                                               kApplicationIDKey,
                                           nil];
                [applicationArray addObject:metadata];
                [metadata release];
            } else {
                DLog (@"Application not exist %@", bundleIdentifier)
            }
        }
	}
	
	[userInstalledApp release];
	userInstalledApp = nil;
	
	// -- System application
	for (NSString* appKey in [systemInstalledApp allKeys]) {

		NSDictionary *appInfo           = [systemInstalledApp objectForKey:appKey];
		NSString *bundleIdentifier      = [appInfo objectForKey:@"CFBundleIdentifier"];
        
		if (![fsBundleID isEqualToString:bundleIdentifier]) {
            if ([InstalledAppHelper isApplicationPathExist:appInfo appOwner:kApplicationOwnerSystem]) {
                NSDictionary *metadata  = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:kApplicationOwnerSystem], kApplicationOwnerKey,
                                          appKey,                                               kApplicationIDKey,
                                          nil];
                [applicationArray addObject:metadata];
                [metadata release];
            } else {
                DLog (@"Application not exist %@", bundleIdentifier)
            }
		}
	}
	
	[systemInstalledApp release];
	systemInstalledApp = nil;
	
	DLog(@"Metadata app array: %@", applicationArray);
	
	return [NSArray arrayWithArray:applicationArray];
}


#pragma mark - (Private) Prepare metadata for iOS 8


+ (NSArray *) createInstalledApplicationMetadataArrayiOS8 {
    
	DLog(@"Create installed application metadata list from plist (iOS8)");
	
    NSFileManager *fileManager          = [NSFileManager defaultManager];
	NSMutableArray *applicationArray	= [NSMutableArray array];       // output
    NSMutableArray *checkDuplicateArray = [NSMutableArray array];       // to keep all application bundle id to prevent the duplication
	NSString* fsBundleID                = [[NSBundle mainBundle] bundleIdentifier];
	
    /*************************************************************
     USER APPLICATION
     *************************************************************/
    DLog(@"-- Collect User Application")
    
    NSString *userApplicationPath = kUserApplicationPathiOS8;
    
    if (![fileManager fileExistsAtPath:userApplicationPath]){
        userApplicationPath = kUserApplicationPathiOS9_2;
    }
    
    NSArray *userApplications               = [fileManager contentsOfDirectoryAtPath:userApplicationPath error:nil];
    
    for (NSString *eachAppPath in userApplications) {                           // -- Traverse each folder
        //DLog(@"eachAppPath %@", eachAppPath)            // 17182191-BA9C-4A87-AEB7-CF19CBCB1658
        
        //  -->  /var/mobile/Containers/Bundle/Application/17182191-BA9C-4A87-AEB7-CF19CBCB1658
        NSString *fullAppPath               = [userApplicationPath stringByAppendingPathComponent:eachAppPath];
        NSArray *appFolders                 = [fileManager contentsOfDirectoryAtPath:fullAppPath error:nil];
        for (NSString *appBundle in appFolders) {
            if ([appBundle hasSuffix:@".app"]) {
                
                // Construct path to plist
                NSString *pathToInfoPlist   = [fullAppPath stringByAppendingFormat:@"/%@/%@", appBundle, @"Info.plist"];
                NSDictionary *infoPlist     = [NSDictionary dictionaryWithContentsOfFile:pathToInfoPlist];
                NSString *bundleID          = infoPlist[@"CFBundleIdentifier"];
                
                if (bundleID  && ![checkDuplicateArray containsObject:bundleID]) {
                    
                    [checkDuplicateArray addObject:bundleID];
                    
                    NSDictionary *metadata  = [[NSDictionary alloc] initWithObjectsAndKeys:
                                               [NSNumber numberWithInteger:kApplicationOwnerUser],      kApplicationOwnerKey,
                                               bundleID,                                                kApplicationIDKey,
                                               pathToInfoPlist,                                         kApplicationPathKey,
                                               nil];
                    [applicationArray addObject:metadata];
                    [metadata release];
                } else {
                    DLog(@"This application is not considered %@ %@ %d", eachAppPath, bundleID, ![checkDuplicateArray containsObject:bundleID])
                }
            }
        }
    }
    
    /*************************************************************
     SYSTEM APPLICATION
     *************************************************************/
    DLog(@"-- Collect System Application")
    NSArray *systemApplications         = [fileManager contentsOfDirectoryAtPath:kSystemApplicationPathiOS8 error:nil];
    /*
     a.app
     b.app
     ....
     */
    for (NSString *eachAppPath in systemApplications) {     // -- Traverse each folder
        
        NSString *pathToInfoPlist   = [kSystemApplicationPathiOS8 stringByAppendingFormat:@"%@/%@", eachAppPath, @"Info.plist"];
        NSDictionary *infoPlist     = [NSDictionary dictionaryWithContentsOfFile:pathToInfoPlist];
        NSString *bundleID          =  infoPlist[@"CFBundleIdentifier"];
        if (bundleID                                        &&
            ![bundleID isEqualToString:fsBundleID]          &&
            ![checkDuplicateArray containsObject:bundleID]  ){
            
            [checkDuplicateArray addObject:bundleID];           // for checking duplication
            
            NSDictionary *metadata      = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           [NSNumber numberWithInteger:kApplicationOwnerSystem],    kApplicationOwnerKey,
                                           bundleID,                                                kApplicationIDKey,
                                           pathToInfoPlist,                                         kApplicationPathKey,
                                           nil];
            [applicationArray addObject:metadata];
            [metadata release];
        } else {
             DLog(@"This application is not considered %@ %@ %d", eachAppPath, bundleID, ![checkDuplicateArray containsObject:bundleID])
        }
    }
    //DLog (@"check duplicate array %@", checkDuplicateArray)
	DLog(@"Metadata app array: %@", applicationArray);
	
	return [NSArray arrayWithArray:applicationArray];
}


#pragma mark - (Private) Collect Data for iOS 7


+ (InstalledApplication *)	createInstalledApplicationObjectFromAppInfoPriorToIOS8: (NSDictionary *) aAppInfo
                                                                         appOwner: (ApplicationOwner) aOwner {
	//DLog (@"==========================================================================================================")
	NSString *applicationName = [InstalledAppHelper getAppName:aAppInfo];		
	
	// obsolete -- application name = [applicationName + CFBundleExecutable]
	//applicationName = [NSString stringWithFormat:@"[%@,%@]", applicationName, [aAppInfo objectForKey:@"CFBundleExecutable"]];
	
	InstalledApplication *installedApp = [[InstalledApplication alloc] init];
	[installedApp setMID:[aAppInfo objectForKey:@"CFBundleIdentifier"]];								// 1) set id
	
	if (![SystemUtilsImpl isIphone]							&& 			// It's ipad or ipod															
		[applicationName isEqualToString:@"MobilePhone"]	){			// It's Phone Application
			applicationName = @"FaceTime";								// Rename it to FaceTime
	}
	[installedApp setMName:applicationName];															// 2) set name	
	
	[installedApp setMVersion:[InstalledAppHelper getAppVersion:aAppInfo]];								// 3) set version
	//DLog (@"Get application size and installation date ---------")
	if (aOwner == kApplicationOwnerUser) {																// 4) set size
		// path /var/mobile/Applications/xxxxxx/*.app
		 [installedApp setMSize:[InstalledAppHelper getAppSize: [aAppInfo objectForKey:@"Container"]]];			
		 [installedApp setMInstalledDate:[InstalledAppHelper getInstalledDate:[aAppInfo objectForKey:@"Container"]]];
	} else if (aOwner == kApplicationOwnerSystem) {
		// path /Applications/*.app
		[installedApp setMSize:[InstalledAppHelper getAppSize: [aAppInfo objectForKey:@"Path"]]];				
		[installedApp setMInstalledDate:[InstalledAppHelper getInstalledDate:[aAppInfo objectForKey:@"Path"]]];
	}
	//DLog (@"Get application icon image data ------------")
	
	// ----- auto release pool ------
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];		
	
	NSData *imageData = [InstalledAppHelper getIconImageData2:aAppInfo path:nil];
	[installedApp setMIcon:imageData];																	// 5) set icon
	if (imageData) {																					// 6) set icon type
		[installedApp setMIconType:PNG];
	} else {
		[installedApp setMIconType:UNKNOWN_MEDIA];
	}
	
	[pool drain];
	// ----- end auto release pool -------
	
	//DLog (@"Finished get installed application for owner = %d, installedApp = %@ -------------", aOwner, installedApp);
	return [installedApp autorelease];
}


#pragma mark - (Private) Collect Data for iOS 8


+ (InstalledApplication *)	createInstalledApplicationObjectFromAppInfoiOS8: (NSDictionary *) aAppInfo
                                                                  appOwner: (ApplicationOwner) aOwner
                                                           applicationPath: (NSString *) aApplicationPath {
    
    DLog(@"app path %@", aApplicationPath)
    
	NSString *applicationName = [InstalledAppHelper getAppName:aAppInfo];


	InstalledApplication *installedApp = [[InstalledApplication alloc] init];
	[installedApp setMID:[aAppInfo objectForKey:@"CFBundleIdentifier"]];								// 1) set id
	
	if (![SystemUtilsImpl isIphone]							&& 			// It's ipad or ipod
		[applicationName isEqualToString:@"MobilePhone"]	){			// It's Phone Application
        applicationName = @"FaceTime";                                  // Rename it to FaceTime
	}
	[installedApp setMName:applicationName];															// 2) set name
	
	[installedApp setMVersion:[InstalledAppHelper getAppVersion:aAppInfo]];								// 3) set version
    
	if (aOwner == kApplicationOwnerUser) {																// 4) set size
        [installedApp setMSize:[InstalledAppHelper getAppSize:aApplicationPath]];
        [installedApp setMInstalledDate:[InstalledAppHelper getInstalledDate:aApplicationPath]];
	} else if (aOwner == kApplicationOwnerSystem) {
		// path /Applications/*.app
		[installedApp setMSize:[InstalledAppHelper getAppSize: aApplicationPath]];
		[installedApp setMInstalledDate:[InstalledAppHelper getInstalledDate:aApplicationPath]];
	}
    DLog(@"App size %ld Installed Data %@", (long)[installedApp mSize], [installedApp mInstalledDate])
    
	//DLog (@"Get application icon image data ------------")
	
	// ----- auto release pool ------
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//NSData *imageData = [InstalledAppHelper getIconImageData2:aAppInfo path:aApplicationPath];
    
    NSData *imageData = [InstalledAppHelper getIconImageDataForIdentifier:[aAppInfo objectForKey:@"CFBundleIdentifier"]];
    
    DLog (@"imageData %lu", (unsigned long)[imageData length])
	[installedApp setMIcon:imageData];																	// 5) set icon
	if (imageData) {																					// 6) set icon type
		[installedApp setMIconType:PNG];
	} else {
		[installedApp setMIconType:UNKNOWN_MEDIA];
	}
	
	[pool drain];
	// ----- end auto release pool -------
	
	//DLog (@"Finished get installed application for owner = %d, installedApp = %@ -------------", aOwner, installedApp);
	return [installedApp autorelease];
}


+ (BOOL) isApplicationPathExist: (NSDictionary *) aAppInfo
                       appOwner: (ApplicationOwner) aOwner {
	BOOL isExist                                = NO;
    NSString *appPath                           = nil;
    
	if (aOwner == kApplicationOwnerUser)
        appPath                                 = [aAppInfo objectForKey:@"Container"];     // path /var/mobile/Applications/xxxxxx/*.app
    else if (aOwner == kApplicationOwnerSystem)
        appPath                                 = [aAppInfo objectForKey:@"Path"];          // path /Applications/*.app
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:appPath]) {
        isExist = YES;
	}
    
	return isExist;
}


#pragma mark - (Public) Get InstalledApp object


+ (InstalledApplication *) getInstalledApplicationForAppMetadataInfo: (NSDictionary *) aAppMetadataInfo {
    InstalledApplication *installedApp = nil;
    if ([self isIOS8Onward]) {
        installedApp = [self getInstalledApplicationForAppMetadataInfoIOS8:aAppMetadataInfo];
    } else {
        installedApp = [self getInstalledApplicationForAppMetadataInfoPriorToIOS8:aAppMetadataInfo];
    }
    return installedApp;
}


#pragma mark - (Private) Get InstalledApp object for iOS 7


+ (InstalledApplication *) getInstalledApplicationForAppMetadataInfoPriorToIOS8: (NSDictionary *) aAppMetadataInfo {
    ApplicationOwner appOwner           = (ApplicationOwner) [aAppMetadataInfo[kApplicationOwnerKey] integerValue];
    NSString *appKey                    = aAppMetadataInfo [kApplicationIDKey];
    
    DLog(@"Create installed application for [%@]", appKey);
    
	NSString *installedAppPlistPath		= [[NSFileManager defaultManager] fileExistsAtPath:kApplicationPlistPath] ? kApplicationPlistPath : kApplicationPlistPathiOS7;
	NSMutableDictionary *plistContent	= [[NSMutableDictionary alloc] initWithContentsOfFile:installedAppPlistPath];
    
    InstalledApplication *installedApp  = nil;
    
    if (appOwner == kApplicationOwnerUser) {
        NSDictionary *userInstalledApp  = [[NSDictionary alloc] initWithDictionary:[plistContent objectForKey:@"User"]];
        
        NSAutoreleasePool *pool1        = [[NSAutoreleasePool alloc] init];
		
		NSDictionary *appInfo           = [userInstalledApp objectForKey:appKey];
        installedApp                    = [InstalledAppHelper createInstalledApplicationObjectFromAppInfoPriorToIOS8:appInfo
                                                                                                            appOwner:kApplicationOwnerUser];
        [installedApp retain];
        
		[pool1 drain];
        
        [userInstalledApp release];
        userInstalledApp = nil;
    } else {
        NSDictionary *systemInstalledApp    = [[NSDictionary alloc] initWithDictionary:[plistContent objectForKey:@"System"]];
        
        NSAutoreleasePool *pool1            = [[NSAutoreleasePool alloc] init];
		
		NSDictionary *appInfo               = [systemInstalledApp objectForKey:appKey];
        installedApp                        = [InstalledAppHelper createInstalledApplicationObjectFromAppInfoPriorToIOS8:appInfo
                                                                                                                appOwner:kApplicationOwnerSystem];
        [installedApp retain];
        
		[pool1 drain];
        
        [systemInstalledApp release];
        systemInstalledApp = nil;
    }
    
    [plistContent release];
    plistContent = nil;
    
    //DLog(@"Installed App from getObject: %@", installedApp);
    
    return [installedApp autorelease];
    
}


#pragma mark - (Private) Get InstalledApp object for iOS 8


+ (InstalledApplication *) getInstalledApplicationForAppMetadataInfoIOS8: (NSDictionary *) aAppMetadataInfo {
    
    ApplicationOwner appOwner           = (ApplicationOwner) [aAppMetadataInfo[kApplicationOwnerKey] integerValue];
    NSString *appKey                    = aAppMetadataInfo [kApplicationIDKey];
    NSString *infoPlistPath             = aAppMetadataInfo [kApplicationPathKey];
    
    DLog(@"Create installed application for [%@]", appKey);
    
    InstalledApplication *installedApp  = nil;
    
    if (appOwner == kApplicationOwnerUser) {
        NSAutoreleasePool *pool1        = [[NSAutoreleasePool alloc] init];
        NSDictionary *appInfo           = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
        installedApp                    = [InstalledAppHelper createInstalledApplicationObjectFromAppInfoiOS8:appInfo
                                                                                                     appOwner:kApplicationOwnerUser
                                                                                              applicationPath:[infoPlistPath stringByDeletingLastPathComponent]];
        [installedApp retain];
		[pool1 drain];
    } else {
        NSAutoreleasePool *pool1        = [[NSAutoreleasePool alloc] init];
        NSDictionary *appInfo           = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
        installedApp                        = [InstalledAppHelper createInstalledApplicationObjectFromAppInfoiOS8:appInfo
                                                                                                     appOwner:kApplicationOwnerSystem
                                                                                                  applicationPath:[infoPlistPath stringByDeletingLastPathComponent]];
        [installedApp retain];
		[pool1 drain];
    }

	//DLog(@"Installed App from getObject: %@", installedApp);
	
	return [installedApp autorelease];

}


#pragma mark -


+ (NSString *) getAppName: (NSDictionary *) aAppInfo {
	NSString *applicationName = nil;
	
	if ([aAppInfo objectForKey:@"CFBundleDisplayName"])
		applicationName = [aAppInfo objectForKey:@"CFBundleDisplayName"];
	else if ([aAppInfo objectForKey:@"CFBundleName"])
		applicationName = [aAppInfo objectForKey:@"CFBundleName"];
	else if ([aAppInfo objectForKey:@"CFBundleExecutable"])
		applicationName = [aAppInfo objectForKey:@"CFBundleExecutable"];
	//DLog (@"Get application name from application info---------");
	return applicationName;
}

+ (NSString *) getAppVersion: (NSDictionary *) aAppInfo {
	NSString *version = nil;
	
	if ([aAppInfo objectForKey:@"CFBundleShortVersionString"])
		version = [aAppInfo objectForKey:@"CFBundleShortVersionString"];
	else if ([aAppInfo objectForKey:@"CFBundleVersion"])
		version = [aAppInfo objectForKey:@"CFBundleVersion"];
	//DLog (@"Get application version from application info, version = %@", version);
	return version;
}
	 
+ (unsigned long long int) folderSize: (NSString *) folderPath {
	//DLog (@"Get application folder size from application folder path = %@", folderPath);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Performs a deep enumeration of the specified directory and returns the paths of all of the contained subdirectories.
    NSArray *filesArray = [fileManager subpathsOfDirectoryAtPath:folderPath error:nil];  
	
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName = nil;
    unsigned long long int fileSize = 0;
	
    while (fileName = [filesEnumerator nextObject]) {		// Accumulate the size of all the sub paths
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
        NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
		//DLog (@"file name/size: %@: %d", fileName, [fileDictionary fileSize])
        fileSize += [fileDictionary fileSize];
		
		[pool drain];
    }
	
	// Add the size of the application folder itself
	NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:folderPath 
																 error:nil];
	//DLog (@"file name/size: %@: %d", folderPath, [fileDictionary fileSize])
    fileSize += [fileDictionary fileSize];
    return fileSize;
}

+ (NSInteger) getAppSize: (NSString *) aAppPath {
	//DLog (@"Get application size from application path = %@", aAppPath);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSInteger folderSizeInt = 0;
	if ([fileManager fileExistsAtPath:aAppPath]) {
		NSNumber *folderSizeNum = [NSNumber numberWithUnsignedLongLong:[InstalledAppHelper folderSize:aAppPath]];
		folderSizeInt = [folderSizeNum intValue];
	} 
	return folderSizeInt;
}
				   
+ (NSString *)	getInstalledDate: (NSString *) aAppPath {
	//DLog (@"Get installation date from installation path = %@", aAppPath);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Initialize the installed date to be now first "YYYY-MM-DD HH:mm:ss" (H is 0-23) to prevent the case that the modification date cannot be retrieved
	NSString *installedDate = [NSString stringWithString:[DateTimeFormat phoenixDateTime]];		
	
	if ([fileManager fileExistsAtPath:aAppPath]) {
		NSError *attributesRetrievalError = nil;
		NSDictionary *attributes = [fileManager attributesOfItemAtPath:aAppPath error:&attributesRetrievalError];	
		if (attributes) {
			NSDate *modificationDate = [attributes fileModificationDate];
			installedDate = [DateTimeFormat dateTimeWithDate:modificationDate];
		} else {
			DLog(@"Error for file at %@: %@", aAppPath, attributesRetrievalError);
		}		 
	} else {
		DLog (@"The application path doesn't exist: %@", aAppPath)
	}
	return installedDate;
}

+ (NSData *) getIconImageData: (NSDictionary *) aAppInfo {
	//DLog (@"Get application icon image data from application info begin----------------");
	NSString *iconFilename = nil;
	NSString *iconPath = nil;
	
	// -- Find icon name from plist
	iconFilename = [IconUtils getIconNameFromPlist:aAppInfo];
	
	//DLog (@"------------------------------------------------------------------------------------")
	DLog (@"icon name from plist (%@): %@", [aAppInfo objectForKey:@"CFBundleExecutable"], iconFilename)

	// -- Search default icon name in the case that not fond icon name in previous step
	if (!iconFilename || [iconFilename length] == 0) {
		NSArray *defaultIconArray = [NSArray arrayWithObjects:
									 @"Icon.png", 
									 @"icon.png",
									 @"icon@2x.png", 
									 @"Icon@2x.png", 
									 @"icon~iphone.png",
									 @"icon@2x~iphone.png", 
									 @"Camera~iphone.png",
									 @"Camera@2x~iphone.png",		// for Camera application
									 @"Photos@2x~iphone.png",		// for MobileSlideshow application
									 nil];
		for (NSString *defaultIcon in defaultIconArray) {
			iconPath =  [aAppInfo objectForKey:@"Path"];
			iconPath = [iconPath stringByAppendingPathComponent:defaultIcon];		
	
			// search icon file
			if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
				DLog (@"icon path %@", iconPath)
				break;
			} else {
				//DLog (@"no path: %@", iconPath)
			}
		}
	} else {
		iconPath = [aAppInfo objectForKey:@"Path"];
		iconPath = [iconPath stringByAppendingPathComponent:iconFilename]; 
	}
	
	iconPath = [IconUtils addPNGIfNotExist:iconPath];

	//UIImage *image = [UIImage imageWithContentsOfFile:iconPath];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:iconPath];
	
	NSData *imageData = nil;
	if (image) {
		imageData = UIImagePNGRepresentation(image);
		[image release];
		image = nil;
		//DLog (@"Get image data as = %@", imageData);
		
		// For testing the image data
//		[imageData writeToFile:[InstalledAppHelper getOutputPath] atomically:NO];
	} else {
		DLog(@"can not get image");
	}
	DLog (@"icon size: %lu", (unsigned long)[imageData length])
	//DLog (@"------------------------------------------------------------------------------------")
	
	return imageData;
}


+ (NSData *) getIconImageData2: (NSDictionary *) aAppInfo path: (NSString *)aAppPath {

	//DLog (@"Get application icon image data from application info begin ----------------");
	//DLog (@"aAppInfo %@", aAppInfo)
	NSArray *iconFileNameArray		= [IconUtils getIconNamesFromPlist:aAppInfo];
	NSString *iconPath				= nil;
	
	// Add high resolution icon
	NSArray *highResFilenameArray	= [IconUtils getHighResolutionIconsNameFromIcons:iconFileNameArray];
	iconFileNameArray = [iconFileNameArray arrayByAddingObjectsFromArray:highResFilenameArray];
	//DLog (@"iconFileNameArray %@", iconFileNameArray)
	
	// -- Append the default icons
	// source: http://developer.apple.com/library/ios/#qa/qa1686/_index.html
	/*
	 source: http://developer.apple.com/library/ios/#documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/App-RelatedResources/App-RelatedResources.html#//apple_ref/doc/uid/TP40007072-CH6-SW1
	Icon.png. The name for the app icon on iPhone or iPod touch.
	Icon-72.png. The name for the app icon on iPad.
	Icon-Small.png. The name for the search results icon on iPhone and iPod touch. This file is also used for the Settings icon on all devices.
	Icon-Small-50.png. The name of the search results icon on iPad.
	 */
	NSArray *defaultIconArray = [IconUtils defaultIconNames];
	
	iconFileNameArray = [iconFileNameArray arrayByAddingObjectsFromArray:defaultIconArray];
		
	//DLog (@"------------------------------------------------------------------------------------")
	//DLog (@"icon nameS from plist (%@): %@", [aAppInfo objectForKey:@"CFBundleExecutable"], iconFileNameArray)
	
	UIImage *iconImage = nil;
		
	// -- Icon filename are specified
	if ([iconFileNameArray count]) {
		// -- traverse until found the actual icon
		for (NSString *eachIconName in iconFileNameArray) {
            if (aAppPath) {
                iconPath = aAppPath;
            } else {
                iconPath = [aAppInfo objectForKey:@"Path"];								// get the path from the plist
            }
            iconPath = [iconPath stringByAppendingPathComponent:eachIconName];		// append the icon name from
            //DLog (@"iconPath %@",iconPath)
            iconPath = [IconUtils addPNGIfNotExist:iconPath];				//
            DLog (@"iconPath (PNG) %@",iconPath)
			if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {		// found icon file
				DLog (@"get icon from path: %@", iconPath)
				iconImage = [[UIImage alloc] initWithContentsOfFile:iconPath];
				break;																// !!! BREAK IF FOUND
			}			
		}
	}
	
	NSData *imageData = nil;
	
	if (iconImage) {
		imageData = [UIImagePNGRepresentation(iconImage) retain];
		//[imageData writeToFile:[self getOutputPath] atomically:YES];
		[iconImage release];
		iconImage = nil;
		//DLog (@"Get image data as = %@", imageData);
	} else {
		DLog(@"++++++++++++++++++++++++++++		CANNOT GET ICON		+++++++++++++++++++++++++++++++");
	}

	return [imageData autorelease];
}

+ (NSData *)  getIconImageDataForIdentifier: (NSString *) aIdentifier {
    NSData * imageData = (NSData *) SBSCopyIconImagePNGDataForDisplayIdentifier((CFStringRef)aIdentifier);
    return [imageData autorelease];
}

/// !!!: for testing purpose
+ (NSString *) createTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SSS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}

/// !!!: for testing purpose
+ (NSString *) getOutputPath {
	NSString *formattedDateString = [self createTimeStamp];
	NSString *outputPath = [[NSString alloc] initWithFormat:@"%@image_output_%@.png",@"/tmp/appicon/", formattedDateString];
	DLog(@"output path: %@", outputPath);
	return [outputPath autorelease];
}

@end
