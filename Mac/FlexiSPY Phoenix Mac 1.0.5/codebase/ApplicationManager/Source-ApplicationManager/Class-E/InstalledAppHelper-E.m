//
//  InstalledAppHelper.m
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InstalledAppHelper-E.h"
#import "InstalledApplication.h"
#import "DateTimeFormat.h"
#import "MediaTypeEnum.h"
#import "SystemUtilsImpl.h"

#import "IconUtils.h"

#import "SpringBoardServices+IOS8.h"

#import "LSApplicationWorkspace.h"
#import "LSApplicationProxy.h"

static NSString* const kApplicationOwnerKey                     = @"kApplicationTypeKey";
static NSString* const kApplicationIDKey                        = @"kApplicationIDKey";
static NSString* const kApplicationNameKey                      = @"kApplicationNameKey";
static NSString* const kApplicationVersionKey                   = @"kApplicationVersionKey";
static NSString* const kApplicationPathKey                      = @"kApplicationPathKey";
static NSString* const kApplicationSizeKey                      = @"kApplicationSizeKey";
static NSString* const kApplicationIconKey                      = @"kApplicationIconKey";
static NSString* const kApplicationIconTypeKey                  = @"kApplicationIconTypeKey";

@interface UIImage ()
+ (id)_iconForResourceProxy:(id)arg1 variant:(int)arg2 variantsScale:(float)arg3;
+ (id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;
@end

@interface InstalledAppHelper (private)

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
    NSMutableArray *applicationArray = [[NSMutableArray alloc] init];
    
    [[[LSApplicationWorkspace defaultWorkspace] allInstalledApplications] enumerateObjectsUsingBlock:^(LSApplicationProxy *appObject, NSUInteger idx, BOOL *stop) {
        NSDictionary *metadataDic  = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   appObject.bundleIdentifier,kApplicationIDKey,
                                   appObject.localizedName, kApplicationNameKey,
                                   nil];
        
        [applicationArray addObject:metadataDic];
        [metadataDic release];
    }];
    
     NSArray *metadata = [NSArray arrayWithArray:applicationArray];
    [applicationArray release];
    
    return metadata;
}

#pragma mark - (Public) Get InstalledApp object


+ (InstalledApplication *) getInstalledApplicationForAppMetadataInfo: (NSDictionary *) aAppMetadataInfo {
    
    InstalledApplication *installedApp = [[InstalledApplication alloc] init];
    
    NSString *appKey                    = aAppMetadataInfo [kApplicationIDKey];
    NSString *applicationName           = aAppMetadataInfo [kApplicationNameKey];
 
    [installedApp setMID:appKey];								// 1) set id
    
    LSApplicationProxy *appObject = [LSApplicationProxy applicationProxyForIdentifier:appKey];
    
    UIImage *iconImage = [UIImage _iconForResourceProxy:appObject variant:15 variantsScale:2.0];
    NSData *iconImageData = UIImagePNGRepresentation(iconImage);
    MediaType iconImageType = UNKNOWN_MEDIA;
    
    if (iconImageData) {
        iconImageType = PNG;
    }
    
    ApplicationOwner appOwner = kApplicationOwnerSystem;
    
    if ([appObject.applicationType isEqualToString:@"User"]) {
        appOwner = kApplicationOwnerUser;
    }
    else if ([appObject.applicationType isEqualToString:@"System"]) {
        appOwner = kApplicationOwnerSystem;
    }
    
    if (![SystemUtilsImpl isIphone]							&& 			// It's ipad or ipod
        [applicationName isEqualToString:@"MobilePhone"]	){			// It's Phone Application
        applicationName = @"FaceTime";                                  // Rename it to FaceTime
    }
    [installedApp setMName:applicationName];															// 2) set name
    
    [installedApp setMVersion:appObject.bundleVersion];								// 3) set version
    
    NSString *applicationPath = appObject.bundleURL.path;
    
    
    //[installedApp setMSize:[InstalledAppHelper getAppSize:applicationPath]];
    [installedApp setMSize:[NSNumber numberWithInteger:[self getAppSize:appObject.bundleURL.path]]];
    [installedApp setMInstalledDate:[InstalledAppHelper getInstalledDate:applicationPath]];
    
    DLog(@"App size %ld Installed Data %@", (long)[installedApp mSize], [installedApp mInstalledDate])

    [installedApp setMIcon:iconImageData];
    [installedApp setMIconType:[NSNumber numberWithInt:iconImageType]];
    
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
