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

@class VideoCapture;
@class PhotoCapture;
@class MediaHistoryDatabase;
//@class PhotoAlbumChangeNotifier;


@interface MediaCaptureManager : NSObject {
@private
	MediaHistoryDatabase	*mMediaHistoryDB;
	MediaThumbnailManagerImp* mMediaThumbnailManagerImp;
	id <EventDelegate>		mEventDelegate;
	VideoCapture*           mVideoCapture;
	PhotoCapture*           mPhotoCapture;
	NSString*               mThumbnailDirectoryPath;
	
	NSOperationQueue		*mMediaOPQueue;
	NSMutableArray			*mTimers;
	
	NSInteger				mMediaNotificationCount;
	BOOL					mMediaIsCapturing;
	
	//PhotoAlbumChangeNotifier *mPhotoAlbumChangeNotifier;
}

@property (nonatomic,copy) NSString* mThumbnailDirectoryPath;
@property (readonly) VideoCapture *mVideoCapture;
@property (readonly) PhotoCapture *mPhotoCapture;
@property (readonly) NSOperationQueue *mMediaOPQueue;
@property (nonatomic, retain) NSMutableArray *mTimers;
@property (assign) NSInteger mMediaNotificationCount;
@property (assign) BOOL mMediaIsCapturing;
@property (nonatomic, readonly, retain) MediaHistoryDatabase *mMediaHistoryDB; 

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate andThumbnailDirectoryPath:(NSString *) aDirectoryPath;
- (void)captureNewPhotos;
- (void)captureNewVideos;
- (void) resetTS: (NSString *) aTSFilePath;
+ (void)clearCapturedData;

@end
