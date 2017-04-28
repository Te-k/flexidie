//
//  HistoricalEventImageOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/30/2557 BE.
//
//

#import "HistoricalEventImageOP-E.h"
#import <Photos/Photos.h>

#define kImageMaxSize                       5 * 1024 * 1024 // 2 MB


@interface HistoricalEventImageOP (private)
- (void) captureHistoricalCameraImage;
@end


@implementation HistoricalEventImageOP


- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- Image main ----")
	[self captureHistoricalCameraImage];
	[pool release];
}


#pragma mark - Public Method


- (void) captureHistoricalCameraImage {
    NSArray *cameraImages = [NSArray array];
    
    // Get NSArray of path NSString
    
    if (mTotalNumber == -1) {
        DLog(@"Get All IMAGES")
        cameraImages = [self allImages];
    } else {
        DLog(@"Get %ld IMAGES", (long)mTotalNumber)
        cameraImages = [self allImagesWithMax:mTotalNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
        DLog(@"Gonna callback to Historical Media Event Manager")
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeCameraImage],     kHistoricalEventTypeKey,
                                      cameraImages,                                                         kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}


#pragma mark - Private Methods


- (NSArray *) allImages {
    
    PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    [allPhotosOptions release];
    DLog(@"allPhotosResult %@", allPhotosResult);

    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        DLog(@"asset %@ with idx %d", asset, idx);
        [images addObject:asset];
    }];
    
    return [images autorelease];
}

- (NSArray *) allImagesWithMax: (NSInteger) aMaxNumber {
    PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    [allPhotosOptions release];
    DLog(@"allPhotosResult %@", allPhotosResult);
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        DLog(@"asset %@ with idx %d", asset, idx);
        if (idx < aMaxNumber) {
            [images addObject:asset];
        }
        else {
            *stop = YES;
        }
        
    }];
    
    return [images autorelease];
}

@end
