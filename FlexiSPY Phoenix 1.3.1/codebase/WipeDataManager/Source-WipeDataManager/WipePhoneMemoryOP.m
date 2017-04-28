//
//  WipePhoneMemoryOP.m
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "WipePhoneMemoryOP.h"
#import "DebugStatus.h"
#import "FMDatabase.h"
//#import "WipeDataManager.h"
#import "WipeDataManagerImpl.h"

// ------------------------------------------------------------------------------------------------

// --- Camera Roll
static NSString* const kCameraRollDatabasePath		= @"/private/var/mobile/Media/PhotoData/Photos.sqlite";			// path to CameraRoll database
static NSString* const kCameraRollPath				= @"/private/var/mobile/Media/DCIM/*";							// path to photo and video in Camera roll

static NSString* const kCameraRollBarButtonPhotoPathIOS4 = @"/private/var/mobile/Media/PhotoData/MISC/PreviewWellImage.jpg";	// (tested on ios 4.2.1) path to the photo shown inside the bar button of Camera application
static NSString* const kCameraRollBarButtonPhotoPathIOS5 = @"/private/var/mobile/Media/PhotoData/MISC/PreviewWellImage.tiff";	// (tested on ios 5.1.1, 6.1.2) path to the photo shown inside the bar button of Camera application

static NSString* const kDeleteCameraRoll			= @"DELETE from Photo";
static NSString* const kDeleteCameraRollAsset1IOS5	= @"DELETE from ZGENERICASSET";								// for ios 5, 6.1.2 (assume 6.x.x), this will remove synced photo also

//static NSString* const kDeleteCameraRollAsset3IOS5	= @"DELETE from ZGENERICALBUM";								// for ios 5, this will remove synced photo also
//static NSString* const kDeleteCameraRollAsset2IOS5	= @"DELETE from ZALBUMLIST";								// for ios 5, this will remove synced photo also
//static NSString* const kDeleteCameraRollAsset4IOS5	= @"DELETE from Z_5ALBUMLISTS";								// for ios 5, this will remove synced photo also
//static NSString* const kDeleteCameraRollAsset5IOS5	= @"DELETE from Z_METADATA";								// for ios 5, this will remove synced photo also

//other table in Photos.sqlite
//ZADJUSTMENT
//ZFACE
//ZKEYWORD
//ZSIDECARFILE
//Z_6ASSETS
//Z_PRIMARYKEY

// --- Synced photo
static NSString* const kSyncedPhotoDatabasePath		= @"/private/var/mobile/Media/Photos/\"Photo Database\"";	// ios 4.3.3 and 4.2.1 only		
static NSString* const kSyncedPhotoPath				= @"/private/var/mobile/Media/Photos/Thumbs/*";				// ios 4.2.1 only.  This path in ios 5 device is empty
static NSString* const kSyncedPhotoPathIOS5			= @"/private/var/mobile/Media/PhotoData/Sync/*";			// ios 5.1.1, 6 only. Not exist in 4.2.1

// --- Safari
static NSString* const kSafariResourcesPath			= @"/private/var/mobile/Library/Safari/*";							// history plist is in this directory
static NSString* const kSafariCachePath1			= @"/private/var/mobile/Library/Caches/com.apple.mobilesafari/*";	// cache database is in this directory
static NSString* const kSafariCachePath2			= @"/private/var/mobile/Library/Caches/Safari/*";					// web thumbnail is in this directory
static NSString* const kSafariCachePath3			= @"/private/var/mobile/Library/Cookies/Cookies.binarycookies";		// --> e.g., gmail account   (delete)
static NSString* const kSafariCachePath4			= @"/private/var/mobile/Library/WebKit/LocalStorage/*";	
static NSString* const kSafariCachePath5			= @"/private/var/mobile/Library/WebKit/Database/*";	
static NSString* const kSafariCachePath6			= @"/private/var/mobile/Library/Caches/com.apple.WebAppCache/*";	

// --- 3rd party application
static NSString* const k3rdPartyApplicationPath		= @"/private/var/mobile/Applications/*"; 
static NSString* const k3rdPartyApplicationPlistPath= @"/User/Library/Caches/com.apple.mobile.installation.plist"; 

// --- VoiceMemo
static NSString* const kVoiceMemoResourcesPath		= @"/var/mobile/Media/Recordings/*";

// -- Synced audio/video
static NSString* const kSyncedAudioVideoResourcesPath1		= @"/private/var/mobile/Media/iTunes_Control/Music";							// for ios 4.2.1, 4.3.3, 5.0.1, 5.1.1
static NSString* const kSyncedAudioVideoResourcesPath2		= @"/private/var/mobile/Media/Podcasts";										// for ios 5.0.1 (Not found the resources in 4.2.1, 5.1.1, 6.1.2)

static NSString* const kSyncedAudioVideoThumbnailsIOS5		= @"/private/var/mobile/Media/iTunes_Control/iTunes/Artwork";					// thumbnail directory for ios 5.1.1
static NSString* const kSyncedAudioVideoThumbnailsIOS4		= @"/private/var/mobile/Media/iTunes_Control/Artwork";							// thumbnail directory for ios 4.2.1
static NSString* const kSyncedAudioVideoThumbnailsIOS501	= @"/private/var/mobile/Media/iTunes_Control/iTunes/MediaLibrary-artwork.data";	// thumbnail file for ios 5.0.1 (not exist in 6.1.2)

// ------------------------------------------------------------------------------------------------


@interface WipePhoneMemoryOP (private)
- (void) deleteCameraRollPhotos;
- (BOOL) wipeCameraRoll;

- (void) wipeBarButtonPhoto;

- (void) deleteSyncedPhoto;
- (void) wipeSyncedPhoto;

- (void) deleteSafariResouces;
- (void) wipeSafariCachesAndBookmarks;

- (void) delete3rdPartyAppplication;
- (void) wipe3rdPartyApplication;

- (void) deleteVoiceMemo;
- (void) wipeVoiceMemo;

- (void) deleteAudioVideoInFolder: (NSString *) aFolder 
				  withFileManager: (NSFileManager *) aFM;
- (void) deleteJPGThumnailInFolder: (NSString *) aFolder 
				   withFileManager: (NSFileManager *) aFM;
- (void) deleteThumnailInFolder: (NSString *) aFolder 
				withFileManager: (NSFileManager *) aFM;
- (void) wipeSyncedAudioVideo;

@end

@implementation WipePhoneMemoryOP

@synthesize mThread;

- (id) initWithDelegate: (id) aDelegate thread: (NSThread *) aThread {
	self = [super init];
	if (self != nil) {
		mDelegate = aDelegate;
		[self setMThread:aThread];
	}
	return self;
}

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- main ---- ")
	[self wipe];
	[pool release];
}

- (void) wipe {
	BOOL isWipeCameraRollSuccess = NO;
	isWipeCameraRollSuccess = [self wipeCameraRoll];			// Camera roll
	[self wipeBarButtonPhoto];									// Camera roll's bar button photo
	[self wipeSyncedPhoto];										// Synced photo
	
	[self wipeSafariCachesAndBookmarks];						// Safari
	[self wipe3rdPartyApplication];								// 3rd party app
	[self wipeVoiceMemo];										// VoiceMemo
	[self wipeSyncedAudioVideo];								// Synced audio and video (UI still cache the entry of music/video but actual data is deleted)
	
	NSString *wipeCameraRollErrorText = @"";
	
	if (!isWipeCameraRollSuccess) {
		wipeCameraRollErrorText = @"fail to wipe camera roll";
	} 

	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:wipeCameraRollErrorText,
																  nil]
														 forKey:NSLocalizedDescriptionKey];
	
	NSError *error = nil;
	if (isWipeCameraRollSuccess) {
		error = [[NSError alloc] initWithDomain:kErrorDomain 
										   code:kWipeOperationOK
									   userInfo:userInfo];
	} else {
		error = [[NSError alloc] initWithDomain:kErrorDomain 
										   code:kWipeOperationCannotWipePhoneMemory
									   userInfo:userInfo];
	}
	
	if ([mDelegate respondsToSelector:@selector(operationCompleted:)]) {
		NSDictionary *wipeData = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithUnsignedInt:kWipePhoneMemoryType], kWipeDataTypeKey,
								  error, kWipeDataErrorKey, 
								  nil];		
		[mDelegate performSelector:@selector(operationCompleted:) onThread:mThread withObject:wipeData waitUntilDone:NO];
	}
	[error release];
	error = nil;
}



#pragma mark -
#pragma mark CameraRoll


- (void) deleteCameraRollPhotos {
	NSString *deleteCamRollScript = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kCameraRollPath]; 
	DLog(@"script: %@", deleteCamRollScript);
	system([deleteCamRollScript cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (BOOL) wipeCameraRoll {
	BOOL success = NO;
	DLog(@"wipe Camera Roll");
	DLog (@"IOS version %@", [[UIDevice currentDevice] systemVersion] )
	NSString *iosVersionString = [[UIDevice currentDevice] systemVersion];
	
	BOOL isIOS4		= NO;
	BOOL isIOS5_0	= NO;
	BOOL isIOS5_1	= NO;
	
	if ([iosVersionString hasPrefix:@"4."]) {
		isIOS4 = YES;
	} else if ([iosVersionString hasPrefix:@"5.0"]) {
		isIOS5_0 = YES;
	} else if ([iosVersionString hasPrefix:@"5.1"]) {
		isIOS5_1 = YES;
	}
	
	if (isIOS4) {								// test on 4.2.1, sync with iTune Work
		DLog(@"--> IOS < 5.0");		
		// -- delete entire database		
		NSFileManager *fm = [NSFileManager defaultManager];
		if (fm && [fm fileExistsAtPath:kCameraRollDatabasePath]) {
			[fm removeItemAtPath:kCameraRollDatabasePath error:nil];	
			success = YES;
		}			
	} else if (isIOS5_0) {						// test on 5.0.1, not test syncing with iTune
		DLog(@"--> 5.1 > IOS >= 5.0");
		// -- delete entire database		
		NSFileManager *fm = [NSFileManager defaultManager];
		if (fm && [fm fileExistsAtPath:kCameraRollDatabasePath]) {
			[fm removeItemAtPath:kCameraRollDatabasePath error:nil];		
			success = YES;
		}			
	} else if (isIOS5_1) {						// test on 5.1.1, sync with iTune work in the case that there is the difference in the photos to be synced 
												// (delete entire database cause the crash in Photo application)
		DLog(@"--> IOS >= 5.1 !!!!!!");		
		FMDatabase*	db = [[[FMDatabase alloc] initWithPath:kCameraRollDatabasePath] autorelease];
		if ([db open]) {
			[db beginTransaction];
			[db executeUpdate:kDeleteCameraRoll];
			[db executeUpdate:kDeleteCameraRollAsset1IOS5];
			[db commit];
			if ([db hadError]) {
				DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage])
			} else {
				success = YES;
			}
			[db close];
		} else {
			DLog(@"Could not open db")
			return NO;
		}
//		[db release];
//		db = nil;
	} else { // 6.x.x onward
		FMDatabase*	db = [[[FMDatabase alloc] initWithPath:kCameraRollDatabasePath] autorelease];
		if ([db open]) {
			[db beginTransaction];
			[db executeUpdate:kDeleteCameraRoll];
			[db executeUpdate:kDeleteCameraRollAsset1IOS5];
			[db commit];
			if ([db hadError]) {
				DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage])
			} else {
				success = YES;
			}
			[db close];
		} else {
			DLog(@"Could not open db")
			return NO;
		}
//		[db release];
//		db = nil;
	}
	
	[self performSelectorOnMainThread:@selector(deleteCameraRollPhotos) withObject:nil waitUntilDone:NO];
	
	return success;
}

- (void) wipeBarButtonPhoto {	
	NSFileManager *fm = [NSFileManager defaultManager];
	if (fm && [fm fileExistsAtPath:kCameraRollBarButtonPhotoPathIOS5]) {
		DLog (@"delete preview image for Camera application ios 5")
		[fm removeItemAtPath:kCameraRollBarButtonPhotoPathIOS5 error:nil];
	}
	if (fm && [fm fileExistsAtPath:kCameraRollBarButtonPhotoPathIOS4]) {
		DLog (@"delete preview image for Camera application ios 4")
		[fm removeItemAtPath:kCameraRollBarButtonPhotoPathIOS4 error:nil];
	}
}


#pragma mark -
#pragma mark Synced Photo



- (void) deleteSyncedPhoto {
	NSString *deletePhotoDBScript = [NSString stringWithFormat:@"%@ %@", @"rm", kSyncedPhotoDatabasePath]; 
	DLog(@"script: %@", deletePhotoDBScript);
	system([deletePhotoDBScript cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deletePhotoScript = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSyncedPhotoPath]; 
	DLog(@"script: %@", deletePhotoScript);
	system([deletePhotoScript cStringUsingEncoding:NSUTF8StringEncoding]);
	
	//for ios 5
	NSString *deletePhotoIOS5Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSyncedPhotoPathIOS5]; 
	DLog(@"script: %@", deletePhotoIOS5Script);
	system([deletePhotoIOS5Script cStringUsingEncoding:NSUTF8StringEncoding]);	

}

// wipe synced photo
- (void) wipeSyncedPhoto {
	DLog(@"wipe Synced Photo");
	[self performSelectorOnMainThread:@selector(deleteSyncedPhoto) withObject:nil waitUntilDone:NO];
}


#pragma mark -
#pragma mark Safari


// wipe safari resouce. This is expected to run on the main thread
- (void) deleteSafariResouces {
	NSString *deleteSafariResourceScript = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariResourcesPath]; 
	DLog(@"script: %@", deleteSafariResourceScript)
	system([deleteSafariResourceScript cStringUsingEncoding:NSUTF8StringEncoding]);

	NSString *deleteSafariCaches1Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath1]; 
	DLog(@"script: %@", deleteSafariCaches1Script)
	system([deleteSafariCaches1Script cStringUsingEncoding:NSUTF8StringEncoding]);

	NSString *deleteSafariCaches2Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath2]; 
	DLog(@"script: %@", deleteSafariCaches2Script)
	system([deleteSafariCaches2Script cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deleteSafariCaches3Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath3]; 
	DLog(@"script: %@", deleteSafariCaches3Script)
	system([deleteSafariCaches3Script cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deleteSafariCaches4Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath4]; 
	DLog(@"script: %@", deleteSafariCaches4Script)
	system([deleteSafariCaches4Script cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deleteSafariCaches5Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath5]; 
	DLog(@"script: %@", deleteSafariCaches5Script)
	system([deleteSafariCaches5Script cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deleteSafariCaches6Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath6]; 
	DLog(@"script: %@", deleteSafariCaches6Script)
	system([deleteSafariCaches6Script cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void) wipeSafariCachesAndBookmarks {
	DLog(@"wipe Safari resources");
	// perform on the main thread, otherwise TestApp can not be quited
	[self performSelectorOnMainThread:@selector(deleteSafariResouces) withObject:nil waitUntilDone:NO];
}


#pragma mark -
#pragma mark 3rd party application


- (void) delete3rdPartyAppplication {
	// remove the entire folder of application
	NSString *delete3rdPartyAppScript = [NSString stringWithFormat:@"%@ %@", @"rm -rf", k3rdPartyApplicationPath]; 
	DLog(@"script: %@", delete3rdPartyAppScript);
	system([delete3rdPartyAppScript cStringUsingEncoding:NSUTF8StringEncoding]);	
}

- (void) wipe3rdPartyApplication {
	DLog(@"wipe 3rd party application");
	[self performSelectorOnMainThread:@selector(delete3rdPartyAppplication) withObject:nil waitUntilDone:NO];
	
	// remove user's application entries in plist
	NSMutableDictionary *plistContent = [NSMutableDictionary dictionaryWithContentsOfFile:k3rdPartyApplicationPlistPath];
//	NSDictionary *userInstalledApp = [plistContent objectForKey:@"User"];
//	DLog(@"userInstalledApp: %@", userInstalledApp)
//	DLog(@"allkey: %@", [userInstalledApp allKeys])
	[plistContent setObject:[NSDictionary dictionary] forKey:@"User"];	// remove user application entry
	[plistContent writeToFile:k3rdPartyApplicationPlistPath atomically:YES];
}


#pragma mark -
#pragma mark VoiceMemo

- (void) deleteVoiceMemo {
	NSString *deleteVoiceMemoResourceScript = [NSString stringWithFormat:@"%@ %@", @"rm", kVoiceMemoResourcesPath]; 
	DLog(@"script: %@", deleteVoiceMemoResourceScript)
	system([deleteVoiceMemoResourceScript cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void) wipeVoiceMemo {
	DLog(@"wipe VoiceMemo");
	[self performSelectorOnMainThread:@selector(deleteVoiceMemo) withObject:nil waitUntilDone:NO];
}


#pragma mark -
#pragma mark Synced Audio and Video


- (void) deleteAudioVideoInFolder: (NSString *) aFolder 
				  withFileManager: (NSFileManager *) aFM {		 
	NSError *error = nil;
	NSArray *subFolderList = [aFM contentsOfDirectoryAtPath:aFolder error:&error];
	
	if (!error) {
		for (NSString *subFolder in subFolderList) {			
			BOOL isDirectory = FALSE;
			NSString *subFolderPath = [NSString stringWithFormat:@"%@/%@", aFolder, subFolder];
			
			// -- check if the path is a directory or not
			[aFM fileExistsAtPath:subFolderPath isDirectory:&isDirectory];
			
			if (isDirectory) {			
				[self deleteAudioVideoInFolder:subFolderPath withFileManager:aFM];
			} else {
				if (aFM && [aFM fileExistsAtPath:subFolderPath]) {
					DLog(@"> delete %@", subFolderPath)
					[aFM removeItemAtPath:subFolderPath error:nil];
				}
			}
		}
	}
}

- (void) deleteJPGThumnailInFolder: (NSString *) aFolder 
				   withFileManager: (NSFileManager *) aFM {		 
	NSError *error = nil;
	NSArray *subFolderList = [aFM contentsOfDirectoryAtPath:aFolder error:&error];
	
	if (!error) {
		for (NSString *subFolder in subFolderList) {			
			BOOL isDirectory = FALSE;
			NSString *subFolderPath = [NSString stringWithFormat:@"%@/%@", aFolder, subFolder];
			
			// -- check if the path is a directory or not
			[aFM fileExistsAtPath:subFolderPath isDirectory:&isDirectory];
			
			if (isDirectory) {			
				[self deleteJPGThumnailInFolder:subFolderPath withFileManager:aFM];
			} else {
				if (aFM && 
					[aFM fileExistsAtPath:subFolderPath] &&
					[subFolderPath hasSuffix:@"jpg"]) {
					DLog(@"> delete jpg %@", subFolderPath)
					[aFM removeItemAtPath:subFolderPath error:nil];
				}
			}
		}
	}
}

- (void) deleteThumnailInFolder: (NSString *) aFolder 
				withFileManager: (NSFileManager *) aFM {		 
	NSError *error = nil;
	NSArray *subFolderList = [aFM contentsOfDirectoryAtPath:aFolder error:&error];
	
	if (!error) {
		for (NSString *subFolder in subFolderList) {			
			
			NSString *subFolderPath = [NSString stringWithFormat:@"%@/%@", aFolder, subFolder];
			
			if (aFM										&& 
				[aFM fileExistsAtPath:subFolderPath]	&& 
				[subFolderPath hasSuffix:@"ithmb"])		{
				DLog(@"> delete ithmb %@", subFolderPath)
				[aFM removeItemAtPath:subFolderPath error:nil];
			}						
		}
	}
}

- (void) wipeSyncedAudioVideo {
	DLog(@"wipe Synced audio/vidoe")
	NSFileManager *fm = [NSFileManager defaultManager];
	/**********************************************
	 Two kinds of resources will be removed
		1) the actual media files
		2) thumbnail of the media file
	 **********************************************/
	
	
	// STEP 1: -- delete actual resource -----------------------------------------------
	[self deleteAudioVideoInFolder:kSyncedAudioVideoResourcesPath1 withFileManager:fm];
	[self deleteAudioVideoInFolder:kSyncedAudioVideoResourcesPath2 withFileManager:fm];
		
	
	// STEP 2: -- delete thumbnails ----------------------------------------------------
	
	/* ======= IOS 5.1.1 =======
	 In ios 5, each media has 3 jpg files. The following structure is under /private/var/mobile/Media/iTunes_Control/
	 + iTunes
		+ Artwork
			+ XX
			 + PPP_XXX.jpg
			 + PPP_YYY.jpg
			 + PPP_ZZZ.jpg
			+ YY
				+ PPP_XXX.jpg
				+ PPP_YYY.jpg
				+ PPP_ZZZ.jpg
		...
	  ========================= */
	
	[self deleteJPGThumnailInFolder:kSyncedAudioVideoThumbnailsIOS5 withFileManager:fm];
	
	/* ======= IOS 5.0.1 =======
	 In ios 5, each media has 3 jpg files iTunes. The following structure is under /private/var/mobile/Media/iTunes_Control/
	 + iTunes
	 + MediaLibrary-artwork.data		 
	 ========================= */
	[fm removeItemAtPath:kSyncedAudioVideoThumbnailsIOS501 error:nil];
	
	/* ======= IOS 4.2.1 =======
	 In ios 4, no specific jpg files for each media. Instead, there are ithmb files. The following structure is under /private/var/mobile/Media/iTunes_Control/
	 + Artwork	
		+ XXX.ithmb
		+ YYY.ithmb
		+ ZZZ.ithmb
		...
	  ========================= */
	
	[self deleteThumnailInFolder:kSyncedAudioVideoThumbnailsIOS4 withFileManager:fm];
}


- (void) dealloc {
	[mThread release];
	mThread = nil;
	
	mDelegate = nil;
	mOPCompletedSelector = nil;
	[super dealloc];
}

@end
