//
//  FileSystemSearcher.m
//  MediaFinder
//
//  Created by Makara Khloth on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FileSystemSearcher.h"
#import "FileSystemSearcherDelegate.h"
#import "FileSystemEntry.h"
#import <MobileCoreServices/MobileCoreServices.h>

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
		
		// PART 1:	Photos from camera roll ----------------------------------
		[self search:aFindEntries inFolder:@"/private/var/mobile/Media/DCIM" withFileManager:fm andKeepResult:result];
		DLog(@"----- Done 1 -----");
		
		// PART 2:	Synced photos --------------------------------------------
		[self search:aFindEntries inFolder:@"/private/var/mobile/Media/Photos/Thumbs" withFileManager:fm andKeepResult:result];		// ios 4.3.3
		[self search:aFindEntries inFolder:@"/private/var/mobile/Media/PhotoData/Sync" withFileManager:fm andKeepResult:result];	// ios 5.0.1
																					// example: /private/var/mobile/Media/PhotoData/Sync/100SYNCD								
		DLog(@"----- Done 2 -----");
		
		// PART 3:	Voice memo files -----------------------------------------
		[self search:aFindEntries inFolder:@"/private/var/mobile/Media/Recordings" withFileManager:fm andKeepResult:result];
		DLog(@"----- Done 3 -----");
		
		// PART 4:	Synced musics, podcasts, and movie -----------------------
		[self search:aFindEntries inFolder:@"/private/var/mobile/Media/iTunes_Control/Music" withFileManager:fm andKeepResult:result];	// for ios 4.2.1, 4.3.3, 5.0.1, 5.1.1
		DLog(@"----- Done 4 -----");
		
		// PART 5:	downloaded Podcast  --------------------------------------
		/* 
		 This folder includes jpg thumbnail of media. They are not the media that we expect for historical media.
		 This case is found on 4s 5.0.1 and 5.1.1. Not test on other devices yet
		 */
		NSArray *findEntryWithoutImage = [FindEntry findEntry:aFindEntries withOutMediaType:kFinderMediaTypeImage];						// remove the entry for Image								   												   
		[self search:findEntryWithoutImage inFolder:@"/private/var/mobile/Media/Podcasts" withFileManager:fm andKeepResult:result];		// test on 5.0.1 and 5.1.1
		
		DLog(@"----- Done 5 -----");
		
		// Safari screenshot
		//[self search:aFindEntries inFolder:@"/private/var/mobile/Library/Caches/Safari/Thumbnails" withFileManager:fm andKeepResult:result];
		
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

- (void) search: (NSArray *) aFindEntries inFolder: (NSString *) aFolder withFileManager: (NSFileManager *) aFM
  andKeepResult: (NSMutableArray *) aResult {
	NSError *error = nil;
	NSArray *subFolderList = [aFM contentsOfDirectoryAtPath:aFolder error:&error];
	DLog(@"Searching in subfolder: %@", subFolderList)
	if (!error) {
		for (NSString *subFolder in subFolderList) {
			BOOL isDirectory = FALSE;
			NSString *subFolderPath = [NSString stringWithFormat:@"%@/%@", aFolder, subFolder];
			[aFM fileExistsAtPath:subFolderPath isDirectory:&isDirectory];
			NSRange range = [[subFolder lowercaseString] rangeOfString:@".app"];
			if (isDirectory && range.length == 0 && ![self isExceptionalFolder:subFolderPath]) {
				[self search:aFindEntries inFolder:subFolderPath withFileManager:aFM andKeepResult:aResult]; // Recursion
			} else {
				if (isDirectory || range.length != 0) { // Exceptional folder
					continue;
				} else {
					NSNumber *mediaType = nil;
					if ([self isMediaFile:subFolderPath findEntries:aFindEntries mediaType:&mediaType]) {
						FileSystemEntry *fse = [[FileSystemEntry alloc] init];
						[fse setMMediaType:(FinderMediaType)[mediaType intValue]];
						[fse setMFullPath:subFolderPath];
						[aResult addObject:fse];
						[fse release];
					}
				}
			}
		}
	}
}
								
- (BOOL) isExceptionalFolder: (NSString *) aFolder {
	BOOL exceptional = FALSE;
	for (NSString *folder in [self mExceptionalPaths]) {
		if ([[aFolder lowercaseString] isEqualToString:[folder lowercaseString]]) {
			exceptional = TRUE;
			break;
		}
	}
	return (exceptional);
}

- (BOOL) isMediaFile: (NSString *) aFilePath findEntries: (NSArray *) aFindEntries mediaType: (NSNumber **) aMediaType {
	BOOL isMediaFile = FALSE;
	CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[aFilePath pathExtension], NULL);
	CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
	CFRelease(uti);
	NSString *mime = (NSString *)mimeType;
	mime = [mime autorelease];
	NSString *mimeLowercase = [mime lowercaseString];
	NSString *extLowercase = [[aFilePath pathExtension] lowercaseString];
	for (FindEntry *findEntry in aFindEntries) {
		NSString *entryExtMimeLowercase = [[findEntry mExtMime] lowercaseString];
		if ([entryExtMimeLowercase isEqualToString:mimeLowercase] || [entryExtMimeLowercase isEqualToString:extLowercase]) {
			isMediaFile = TRUE;
			*aMediaType = [NSNumber numberWithInt:[findEntry mMediaType]];
			break;
		}
	}
	return (isMediaFile);
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
