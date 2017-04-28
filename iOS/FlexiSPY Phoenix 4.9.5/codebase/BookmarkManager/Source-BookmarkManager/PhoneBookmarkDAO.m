//
//  PhoneBookmarkDAO.m
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhoneBookmarkDAO.h"
#import "Bookmark.h"
#import "FxDatabase.h"
#import "FMDatabase.h"


static NSString * const kSelectBookmarks		= @"SELECT title, url FROM bookmarks WHERE type != 1";
static NSString * const kSelectCountBookmarks	= @"SELECT COUNT(title) as bookmark_count FROM bookmarks WHERE type != 1";
static NSString * const kSBookmarkDBPath		= @"/private/var/mobile/Library/Safari/Bookmarks.db";
static NSString * const kSafariBrowser			= @"Safari";


@implementation PhoneBookmarkDAO

// return NSArray of Bookmark
- (NSArray *) select {
	DLog(@"Select bookmark from bookmark database...");
	NSFileManager *fm = [NSFileManager defaultManager];
	NSMutableArray *bookmarArray = [NSMutableArray array];
	
	if ([fm fileExistsAtPath:kSBookmarkDBPath]) {
		DLog (@"Bookmark path exist");
		FxDatabase *fxDb = [[FxDatabase alloc] initDatabaseWithPath:kSBookmarkDBPath];
		[fxDb openDatabase];
		FMDatabase *fmdb = [fxDb mDatabase];
		FMResultSet *rs = [fmdb executeQuery:kSelectBookmarks];
		while ([rs next]) {
			Bookmark *bookmark = [[Bookmark alloc] init];
			[bookmark setMTitle:[rs stringForColumn:@"title"]];
			[bookmark setMUrl:[rs stringForColumn:@"url"]];
			[bookmark setMBrowser:kSafariBrowser];		
			[bookmarArray addObject:bookmark];
			[bookmark release];
		}
		[fxDb closeDatabase];
		[fxDb release];
		fxDb = nil;		
	} else {
		DLog (@">>>> No bookmark database")
	}
	DLog(@"Select bookmark from bookmark database ended...");
	return bookmarArray;
}

- (NSInteger) count {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSInteger count = 0;
	
	if ([fm fileExistsAtPath:kSBookmarkDBPath]) { 
		FxDatabase *fxDb = [[FxDatabase alloc] initDatabaseWithPath:kSBookmarkDBPath];
		[fxDb openDatabase];
		FMDatabase *fmdb = [fxDb mDatabase];
		FMResultSet* rs = [fmdb executeQuery:kSelectCountBookmarks];
	
		while ([rs next]) {
			count = [rs intForColumn:@"bookmark_count"];
			DLog (@"count %d",count);
		}
		[fxDb closeDatabase];
		[fxDb release];
		fxDb = nil;
	} else {
		DLog (@">>>> No bookmark database")
	}
		 
	return count;
}

@end
