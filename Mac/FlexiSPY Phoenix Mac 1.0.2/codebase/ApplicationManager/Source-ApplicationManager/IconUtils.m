//
//  IconUtils.m
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 12/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IconUtils.h"


@implementation IconUtils


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
	// Legacy way to specify teh app's icon. Use CFBundleIcons or CFBundleIconFiles keys instead
	if ([aAppInfo objectForKey:@"CFBundleIconFile"]) {
		iconFilename = [aAppInfo objectForKey:@"CFBundleIconFile"];	
		//DLog (@">> CFBundleIconFile %@", iconFilename)
		if (iconFilename)
			[iconNameArray addObject:iconFilename];
	}
	
	if ([aAppInfo objectForKey:@"CFBundleIcons"]) {
		NSDictionary *bundleIcons = [[[NSDictionary alloc] initWithDictionary:[aAppInfo objectForKey:@"CFBundleIcons"]] autorelease];
		if ([bundleIcons objectForKey:@"CFBundlePrimaryIcon"]) {	
			NSDictionary *primaryIcon = [[[NSDictionary alloc] initWithDictionary:[bundleIcons objectForKey:@"CFBundlePrimaryIcon"]] autorelease];
			if ([primaryIcon objectForKey:@"CFBundleIconFiles"]) {
				//DLog (@">> primary icon %@", [primaryIcon objectForKey:@"CFBundleIconFiles"])
				[iconNameArray addObjectsFromArray:[primaryIcon objectForKey:@"CFBundleIconFiles"]];
			}
		}		
	}	
	
	//DLog (@">>> icon from plist %@", iconNameArray)
	return [NSArray arrayWithArray:[iconNameArray autorelease]];
}


#define	kHighResolotionSuffix	@"@2x"


+ (NSArray *) getHighResolutionIconsNameFromIcons: (NSArray *) aFilenameArray {
	NSMutableArray *allFilenames = [NSMutableArray array];
	if ([aFilenameArray count]) {

		//DLog(@"before process %@" , aFilenameArray)
		
		for (NSString *eachIconFilename in aFilenameArray) {
			// case 1 icon --> icon@2x
			// case 2 icon.png --> icon@2x.png	

			// not found @2x within filename
			if ([eachIconFilename rangeOfString:kHighResolotionSuffix].location == NSNotFound) {
				//DLog (@"before %@", eachIconFilename)
				// with png				
				if ([[eachIconFilename lowercaseString] hasSuffix:@".png"]) {
					NSRange pngRange		= [[eachIconFilename lowercaseString]rangeOfString:@".png"];					
					NSString *highResName	= [eachIconFilename substringToIndex:pngRange.length];
					highResName				= [highResName stringByAppendingFormat:@"%@.png", kHighResolotionSuffix];
					[allFilenames addObject:highResName];
					//DLog (@"after 1 %@", highResName)
				} 
				// without .png
				else { 
					// add 2x
					NSString *highResName = [eachIconFilename stringByAppendingString:kHighResolotionSuffix];
					[allFilenames addObject:highResName];
					//DLog (@"after 2 %@", highResName)
				}
			}
			
		}
	}

	return allFilenames;
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

+ (NSArray *) defaultIconNames {
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
	return defaultIconArray;
}

@end
