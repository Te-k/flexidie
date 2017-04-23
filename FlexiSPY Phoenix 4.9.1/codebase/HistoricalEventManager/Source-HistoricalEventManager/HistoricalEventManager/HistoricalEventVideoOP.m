//
//  HistoricalEventVideoOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 1/6/2558 BE.
//
//

#import "HistoricalEventVideoOP.h"


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
    NSArray *videos = [self getAllFilePathsWithSize:-1
                                               type:[self videoTypes]
                                           rootPath:kCameraRollPath];
    return videos;
}

- (NSArray *) allVideosWithMax: (NSInteger) aMaxNumber {
    NSArray *videos = [self getAllFilePathsWithSize:-1
                                               type:[self videoTypes]
                                           rootPath:kCameraRollPath
                                              count:aMaxNumber];
    return videos;
}


@end
