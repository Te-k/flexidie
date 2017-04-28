//
//  HistoricalEventImageOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/30/2557 BE.
//
//

#import "HistoricalEventImageOP.h"


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
    NSArray *images = [self getAllFilePathsWithSize:kImageMaxSize
                                               type:[self imageTypes]
                                           rootPath:kCameraRollPath];
    return images;
}

- (NSArray *) allImagesWithMax: (NSInteger) aMaxNumber {
    NSArray *images = [self getAllFilePathsWithSize:kImageMaxSize
                                               type:[self imageTypes]
                                           rootPath:kCameraRollPath
                                              count:aMaxNumber];
    return images;
}

@end
