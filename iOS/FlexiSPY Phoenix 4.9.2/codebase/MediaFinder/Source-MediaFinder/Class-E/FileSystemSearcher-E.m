//
//  FileSystemSearcher.m
//  MediaFinder
//
//  Created by Makara Khloth on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FileSystemSearcher-E.h"
#import "FileSystemSearcherDelegate.h"
#import "FileSystemEntry.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

@interface FileSystemSearcher (private)
- (void) main: (NSArray *) aFindEntries;
- (void) search: (NSArray *) aFindEntries inFolder: (NSString *) aFolder withFileManager: (NSFileManager *) aFM
  andKeepResult: (NSMutableArray *) aResult;
- (BOOL) isExceptionalFolder: (NSString *) aFolder;
- (BOOL) isMediaFile: (NSString *) aFilePath findEntries: (NSArray *) aFindEntries mediaType: (NSNumber **) aMediaType;
- (void) fireFileSystemSearcherFinished: (NSArray *) aFileSystemEntries;
@end

@implementation FileSystemSearcher

@synthesize mMyThread;
@synthesize mSpawnedThreads;
@synthesize mExceptionalPaths;

- (id) initWithFileSystemSearcherDelegate: (id <FileSystemSearcherDelegate>) aDelegate {
	if ((self = [super init])) {
		mDelegate = aDelegate;
		mMyThread = [NSThread currentThread];
		mSpawnedThreads = [[NSMutableArray array] retain];
	}
	return (self);
}

- (void) start: (NSArray *) aFindEntries {
	// Method 1
	//[NSThread detachNewThreadSelector:@selector(main:) toTarget:self withObject:aFindEntries];
	
	// Method 2 with stack size is configured
	NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(main:) object:aFindEntries];
	[newThread setStackSize:(1024 * 4 * 128)]; // 512 Kb
	[newThread start];
	[mSpawnedThreads addObject:newThread];
	[newThread release];
}

- (void) stop {
	for (NSThread *thread in mSpawnedThreads) {
		[thread cancel];
	}
	[mSpawnedThreads removeAllObjects];
}
			  
- (void) main: (NSArray *) aFindEntries {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSMutableArray *result = [NSMutableArray array];
		
        __block BOOL isNeedTofindPhoto = NO;
        
        [aFindEntries enumerateObjectsUsingBlock:^(FindEntry *aFindEntry, NSUInteger idx, BOOL * _Nonnull stop) {
            if (aFindEntry.mMediaType == kFinderMediaTypeImage) {
                isNeedTofindPhoto = YES;
                *stop = YES;
            }
        }];
        
        if (isNeedTofindPhoto) {
            // PART 1:	Photos from camera roll ----------------------------------
            PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            
            PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
            [allPhotosOptions release];
         
            [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                DLog(@"asset %@ with idx %lu", asset, (unsigned long)idx);
                
                FileSystemEntry *fse = [[FileSystemEntry alloc] init];
                [fse setMMediaType:kFinderMediaTypeImage];
                [fse setMAssetIdentifier:asset.localIdentifier];
                //File path of PHAsset is undocument property
                NSString *assetFilePath = [[asset performSelector:@selector(mainFileURL)] absoluteString];
                [fse setMFullPath:assetFilePath];
                
                //Request file size of PHAsset by PHImageManager
                PHImageRequestOptions * imageRequestOptions = [[[PHImageRequestOptions alloc] init] autorelease];
                imageRequestOptions.synchronous = YES;
                
                [[PHImageManager defaultManager]
                 requestImageDataForAsset:asset
                 options:imageRequestOptions
                 resultHandler:^(NSData *imageData, NSString *dataUTI,
                                 UIImageOrientation orientation,
                                 NSDictionary *info)
                 {
                     NSInteger assetFileSize = [imageData length];
                     [fse setMFileSize:assetFileSize];
                     [result addObject:fse];
                     [fse release];
                 }];
            }];
        }

        __block BOOL isNeedToFindVideo = NO;
        
        [aFindEntries enumerateObjectsUsingBlock:^(FindEntry *aFindEntry, NSUInteger idx, BOOL * _Nonnull stop) {
            if (aFindEntry.mMediaType == kFinderMediaTypeVideo) {
                isNeedToFindVideo = YES;
                *stop = YES;
            }
        }];

		DLog(@"----- Done 1 -----");
		
        if (isNeedToFindVideo) {
            // PART 2:	Videos from camera roll --------------------------------------------
            PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            
            PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:allPhotosOptions];
            [allPhotosOptions release];
            
            [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                DLog(@"asset %@ with idx %lu", asset, (unsigned long)idx);
                
                FileSystemEntry *fse = [[FileSystemEntry alloc] init];
                [fse setMMediaType:kFinderMediaTypeVideo];
                [fse setMAssetIdentifier:asset.localIdentifier];
                //File path of PHAsset is undocument property
                NSString *assetFilePath = [[asset performSelector:@selector(mainFileURL)] absoluteString];
                [fse setMFullPath:assetFilePath];
                
                //Request file size of PHAsset by PHImageManager
                PHImageRequestOptions * imageRequestOptions = [[[PHImageRequestOptions alloc] init] autorelease];
                imageRequestOptions.synchronous = YES;
                
                [[PHImageManager defaultManager]
                 requestImageDataForAsset:asset
                 options:imageRequestOptions
                 resultHandler:^(NSData *imageData, NSString *dataUTI,
                                 UIImageOrientation orientation,
                                 NSDictionary *info)
                 {
                     NSInteger assetFileSize = [imageData length];
                     [fse setMFileSize:assetFileSize];
                     [result addObject:fse];
                     [fse release];
                 }];
            }];
            
            DLog(@"----- Done 2 -----");
        }

		DLog (@"media files that are going to be processed %@", result)
		@synchronized (self) {
			if ([[NSThread currentThread] isCancelled]) {
				[NSThread exit];
			} else {
				[self performSelector:@selector(fireFileSystemSearcherFinished:) onThread:[self mMyThread] withObject:result waitUntilDone:FALSE];
			}
		}
	}
	@catch (...) {
		@synchronized (self) {
			if ([[NSThread currentThread] isCancelled]) {
				//[NSThread exit];
			} else {
				[self performSelector:@selector(fireFileSystemSearcherFinished:) onThread:[self mMyThread] withObject:[NSArray array] waitUntilDone:FALSE];
			}
		}
	}
	@finally {
		;
	}
	[[self mSpawnedThreads] removeObject:[NSThread currentThread]];
	[pool release];
}

- (void) fireFileSystemSearcherFinished: (NSArray *) aFileSystemEntries {
	[aFileSystemEntries retain];
	if ([mDelegate respondsToSelector:@selector(fileSystemSearchFinished:)]) {
		[mDelegate performSelector:@selector(fileSystemSearchFinished:) withObject:aFileSystemEntries];
	}
	[aFileSystemEntries release];
}

- (void) dealloc {
	[self stop];
	[mSpawnedThreads release];
	[mExceptionalPaths release];
	[super dealloc];
}

@end
