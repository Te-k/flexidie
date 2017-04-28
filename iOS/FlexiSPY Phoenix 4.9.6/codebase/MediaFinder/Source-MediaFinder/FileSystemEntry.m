//
//  FileSystemEntry.m
//  MediaFinder
//
//  Created by Makara Khloth on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FileSystemEntry.h"

@implementation FindEntry

@synthesize mMediaType;
@synthesize mExtMime;

- (id) init {
	if ((self = [super init])) {
		mMediaType = kFinderMediaTypeUnknown;
	}
	return (self);
}

// -- remove the specific find entries according
+ (NSArray *) findEntry: (NSArray *) aFindEntries withOutMediaType: (FinderMediaType) aFinderMediaType {		
	NSMutableArray *findEntriesWithoutSpecifiMediaType = [NSMutableArray array]; 	
	if (aFindEntries) {
		for (FindEntry *findEntry in aFindEntries) {
			if ([findEntry mMediaType] != aFinderMediaType) {
				[findEntriesWithoutSpecifiMediaType addObject:findEntry];
			}
		}
	}	
	return findEntriesWithoutSpecifiMediaType;		
}

- (void) dealloc {
	[mExtMime release];
	[super dealloc];
}

@end

@implementation FileSystemEntry

@synthesize mMediaType;
@synthesize mFullPath;
@synthesize mAssetIdentifier;
@synthesize mFileSize;

- (id) init {
	if ((self = [super init])) {
		mMediaType = kFinderMediaTypeUnknown;
	}
	return (self);
}

- (void) dealloc {
	[mFullPath release];
	[super dealloc];
}

@end
