/** 
 - Project name: MediaThumbnail
 - Class name: AudioThumnailCreatorOperation
 - Version: 1.0
 - Purpose: 
 - Copy right: 13/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

@class AudioThumbnailCreator;
@class AVAssetExportSession;
@class AVURLAsset;

@interface AudioThumbnailCreatorOperation : NSOperation {
@private
	NSString				*mInputPath;					// used in timer function
	NSString				*mOutputPath;	
	NSString				*mOutputPathWithExtension;		// used in timer function
	NSThread				*mThread;
	NSNumber				*mAttempt;
	NSInteger				mDuration;
	
	AudioThumbnailCreator	*mAudioThumbnailCreator;		// assign property, it's a creator of this object	
	BOOL					mCanExit;
	BOOL					mShouldFinishOperation;
}


@property (nonatomic, copy)		NSString *mInputPath;
@property (nonatomic, copy)		NSString *mOutputPath;
@property (nonatomic, copy)		NSString *mOutputPathWithExtension;
@property (nonatomic, retain)	NSThread *mThread;
@property (nonatomic, retain)	NSNumber *mAttempt;
@property (assign)				BOOL mCanExit;
@property (assign)				BOOL mShouldFinishOperation;

@property (nonatomic, readonly, assign) AudioThumbnailCreator *mAudioThumbnailCreator;  // property is 'assign' because the creator will live longer than the operation

- (id) initWithInputPath: (NSString *) aInputPath 
			  outputPath: (NSString *) aOutputPath
   audioThumbnailCreator: (AudioThumbnailCreator *) aAudioThumbnailCreator
	 threadToRunCallback: (NSThread *) aThread;

@end
