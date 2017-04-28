//
//  HistoricalEventVideoOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 1/6/2558 BE.
//
//

#import "HistoricalEventVideoOP-E.h"
#import <Photos/Photos.h>

@interface HistoricalEventVideoOP (private)
- (void) captureHistoricalVideo;
@end

@implementation HistoricalEventVideoOP


- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- Video main ----")
	[self captureHistoricalVideo];
	[pool release];
}


#pragma mark - Public Method


- (void) captureHistoricalVideo {
    NSArray *videos = [NSArray array];
    
    // Get NSArray of path NSString
    if (mTotalNumber == -1) {
        DLog(@"Get All VIDEOS")
        videos = [self allVideos];
    } else {
        DLog(@"Get %ld VIDEOS", (long)mTotalNumber)
        videos = [self allVideosWithMax:mTotalNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
        DLog(@"Gonna callback to Historical Media Event Manager")
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeVideoFile], kHistoricalEventTypeKey,
                                      videos,                                                         kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}


#pragma mark - Private Methods


- (NSArray *) allVideos {
    PHFetchOptions *allVideosOptions = [PHFetchOptions new];
    allVideosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *allVideoResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:allVideosOptions];
    [allVideosOptions release];
    DLog(@"allVideoResult %@", allVideoResult);
    
    NSMutableArray *videos = [[NSMutableArray alloc] init];
    
    [allVideoResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        DLog(@"asset %@ with idx %d", asset, idx);
        [videos addObject:asset];
    }];
    
    return [videos autorelease];
}

- (NSArray *) allVideosWithMax: (NSInteger) aMaxNumber {
    PHFetchOptions *allVideosOptions = [PHFetchOptions new];
    allVideosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *allVideoResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:allVideosOptions];
    [allVideosOptions release];
    DLog(@"allVideoResult %@", allVideoResult);
    
    NSMutableArray *videos = [[NSMutableArray alloc] init];
    
    [allVideoResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        DLog(@"asset %@ with idx %d", asset, idx);
        if (idx < aMaxNumber) {
            [videos addObject:asset];
        }
        else {
            *stop = YES;
        }
    }];
    
    return [videos autorelease];
}


@end
