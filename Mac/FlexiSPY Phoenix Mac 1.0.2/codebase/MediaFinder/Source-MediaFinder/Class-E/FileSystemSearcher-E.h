//
//  FileSystemSearcher.h
//  MediaFinder
//
//  Created by Makara Khloth on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileSystemSearcherDelegate;

@interface FileSystemSearcher : NSObject {
@private
	id <FileSystemSearcherDelegate>	mDelegate;
	NSThread		*mMyThread;
	NSMutableArray	*mSpawnedThreads;
	NSArray			*mExceptionalPaths;
}

@property (readonly) NSThread *mMyThread;
@property (readonly) NSMutableArray *mSpawnedThreads;
@property (retain) NSArray *mExceptionalPaths;

- (id) initWithFileSystemSearcherDelegate: (id <FileSystemSearcherDelegate>) aDelegate;

- (void) start: (NSArray *) aFindEntries;
- (void) stop;

@end
