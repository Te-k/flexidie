/**
 - Project name :  MediaCaptureManager
 - Class name   :  MediaCaptureManager
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>

@class MediaThumbnailManagerImp, MediaCaptureNotifier;
@protocol EventDelegate;

@class AudioCapture;
@class VideoCapture;
@class WallPaperCapture;
@class PhotoCapture;
@class MediaHistoryDatabase;
//@class PhotoAlbumChangeNotifier;


@interface MediaCaptureManager : NSObject {
@private
	MediaHistoryDatabase	*mMediaHistoryDB;
	MediaCaptureNotifier	*mMediaCaptureNotifier;
	MediaThumbnailManagerImp* mMediaThumbnailManagerImp;
	id <EventDelegate>		mEventDelegate;
	AudioCapture*           mAudioCapture;
	VideoCapture*           mVideoCapture;
	WallPaperCapture*       mWallPaperCapture;
	PhotoCapture*           mPhotoCapture;
	NSString*               mThumbnailDirectoryPath;
	
	NSOperationQueue		*mMediaOPQueue;
	NSMutableArray			*mTimers;
	
	NSInteger				mMediaNotificationCount;
	BOOL					mMediaIsCapturing;
	
	//PhotoAlbumChangeNotifier *mPhotoAlbumChangeNotifier;
}

@property (nonatomic,copy) NSString* mThumbnailDirectoryPath;
@property (readonly) AudioCapture *mAudioCapture;
@property (readonly) VideoCapture *mVideoCapture;
@property (readonly) PhotoCapture *mPhotoCapture;
@property (readonly) NSOperationQueue *mMediaOPQueue;
@property (nonatomic, retain) NSMutableArray *mTimers;
@property (assign) NSInteger mMediaNotificationCount;
@property (assign) BOOL mMediaIsCapturing;
@property (nonatomic, readonly, retain) MediaHistoryDatabase *mMediaHistoryDB; 

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate andThumbnailDirectoryPath:(NSString *) aDirectoryPath; 
- (void) startAudioCapture;
- (void) stopAudioCapture;
- (void) startVideoCapture;
- (void) stopVideoCapture;
- (void) startCameraImageCapture;
- (void) stopCameraImageCapture;
- (void) startWallPaperCapture;
- (void) stopWallPaperCapture;

- (void) resetTS: (NSString *) aTSFilePath;

//- (void) processDataFromMessagePort: (NSData *) aRawData;
- (void) processDataFromMessagePort: (NSNotification *) aNotification;
@end
