//
//  PhoneBookmarkDAO.m
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhoneBookmarkDAO-E.h"
#import "Bookmark.h"

#import "WebBookmarkCollection.h"
#import "WebBookmarkList.h"
#import "WebBookmark.h"

static NSString * const kSafariBrowser			= @"Safari";


@implementation PhoneBookmarkDAO

// return NSArray of Bookmark
- (NSArray *) select {
	DLog(@"Select bookmark from bookmark database...");
	NSMutableArray *bookmarkArray = [NSMutableArray array];
	NSMutableArray *allBookmarkArray = [NSMutableArray array];
    
    WebBookmarkCollection *bookmarkCollection = [WebBookmarkCollection safariBookmarkCollection];
    WebBookmarkList *bookmarkList = [bookmarkCollection rootList];
    NSArray *bookmarkListArray = [bookmarkList bookmarkArray];
    
    [bookmarkListArray enumerateObjectsUsingBlock:^(WebBookmark *webbookmark, NSUInteger idx, BOOL *stop) {
        [self recursiveImportBookmark:webbookmark intoBookmarkArray:allBookmarkArray];
    }];
    
    [self recursiveImportBookmark:[bookmarkCollection favoritesFolder] intoBookmarkArray:allBookmarkArray];
    
	if (allBookmarkArray.count > 0) {
		DLog (@"Bookmark exist");
        [allBookmarkArray enumerateObjectsUsingBlock:^(WebBookmark *webbookmark, NSUInteger idx, BOOL *stop) {
            DLog(@"--------------BOOKMARK---------------");
            DLog(@"identifier %u", webbookmark.identifier);
            DLog(@"title %@", webbookmark.title);
            DLog(@"address %@", webbookmark.address);
            
            Bookmark *bookmark = [[Bookmark alloc] init];
            [bookmark setMTitle:webbookmark.title];
            [bookmark setMUrl:webbookmark.address];
            [bookmark setMBrowser:kSafariBrowser];
            [bookmarkArray addObject:bookmark];
            [bookmark release];
        }];
	} else {
		DLog (@">>>> No bookmark database")
	}
	DLog(@"Select bookmark from bookmark database ended...");

    return bookmarkArray;
}

- (NSInteger) count {
    NSMutableArray *bookmarkArray = [NSMutableArray array];
    
    WebBookmarkCollection *bookmarkCollection = [WebBookmarkCollection safariBookmarkCollection];
    WebBookmarkList *bookmarkList = [bookmarkCollection rootList];
    NSArray *bookmarkListArray = [bookmarkList bookmarkArray];
    
    [bookmarkListArray enumerateObjectsUsingBlock:^(WebBookmark *webbookmark, NSUInteger idx, BOOL *stop) {
        [self recursiveImportBookmark:webbookmark intoBookmarkArray:bookmarkArray];
    }];
    
    NSInteger count = bookmarkArray.count;
		 
	return count;
}

#pragma mark -
#pragma mark WebBookmark Util

- (void)recursiveImportBookmark:(WebBookmark *)aBookmark intoBookmarkArray:(NSMutableArray *)aBookmarkArray;
{
    if (aBookmark.isFolder == 1) {
        WebBookmarkList *bookmarkList = [[WebBookmarkList alloc] initWithFolderID:aBookmark.identifier inCollection:[WebBookmarkCollection safariBookmarkCollection] bookmarkCount:1000000 skipOffset:0 includeHidden:1];
        [[bookmarkList bookmarkArray] enumerateObjectsUsingBlock:^(WebBookmark *bookmarkObject, NSUInteger idx, BOOL *stop) {
            [self recursiveImportBookmark:bookmarkObject intoBookmarkArray:aBookmarkArray];
        }];
    }
    else {
        [aBookmarkArray addObject:aBookmark];
    }
}

@end
