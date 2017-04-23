//
//  MediaFinder.h
//  MediaFinder
//
//  Created by Makara Khloth on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileSystemSearcherDelegate.h"

@class FileSystemSearcher, MediaFoundThumbnailHelper, MediaFinderHistory;
@protocol EventDelegate;

@interface MediaFinder : NSObject <FileSystemSearcherDelegate> {
@private
	FileSystemSearcher			*mFileSystemSearcher;
	id <EventDelegate>			mDelegate;
	NSString					*mPath;
	NSMutableArray				*mHelpers;
	
	id <FileSystemSearcherDelegate>	mSearchDelegate; // Not own
	
	MediaFinderHistory		*mMediaHistory;
}

@property (nonatomic, copy) NSString *mPath;
@property (nonatomic, assign) id <FileSystemSearcherDelegate> mSearchDelegate;

- (id) initWithEventDelegate: (id <EventDelegate>) aDelegate andMediaPath: (NSString *) aPath;

- (void) findMediaFileWithExtMime: (NSArray *) aFindEntries;

- (void) thumbnailCreationCompleted: (MediaFoundThumbnailHelper *) aHelper;

+ (void) clearMediaHistory;

+ (void) setImageFindEntry: (NSMutableArray *) aFindEntries;
+ (void) setVideoFindEntry: (NSMutableArray *) aFindEntries;
+ (void) setAudioFindEntry: (NSMutableArray *) aFindEntries;

@end
