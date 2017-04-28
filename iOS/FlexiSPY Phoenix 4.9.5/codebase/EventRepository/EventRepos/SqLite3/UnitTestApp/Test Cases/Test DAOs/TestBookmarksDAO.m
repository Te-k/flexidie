//
//  TestBookmarksDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "DAOFactory.h"
#import "BookmarksDAO.h"
#import "BookmarkDAO.h"
#import "FxBookmarkEvent.h"
#import "FxBookmarkWrapper.h"

NSString* const kBookmarksDateTime = @"20-09-2011 11:08:11 AM";

@interface TestBookmarksDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestBookmarksDAO

- (void) setUp {
    if (!mDatabaseManager) {
        mDatabaseManager = [[DatabaseManager alloc] init];
        [mDatabaseManager dropDB];
    } else {
        [mDatabaseManager dropDB];
    }
}

- (void) tearDown {
    
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

- (void) testNormalTest {
    FxBookmarkEvent* event = [[FxBookmarkEvent alloc] init];
    [event setDateTime:kBookmarksDateTime];
    NSInteger maxBookmark = 53;
    for (NSInteger i = 0; i < maxBookmark; i++) {
        FxBookmark *bookmark = [[FxBookmark alloc] init];
        [bookmark setMTitle:[NSString stringWithFormat:@"Network Programming: Chapter %d", i]];
        [bookmark setMUrl:[NSString stringWithFormat:@"http://oreilly.com/iphone/excerpts/iphone-sdk/network-programming-%d.html", i]];
        [event addBookmark:bookmark];
        [bookmark release];
    }
    BookmarksDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    BookmarkDAO *bookmarkDAO = [[BookmarkDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    NSInteger lastInsertedRowId = 0;
    [dao insertEvent:event];
    lastInsertedRowId = [mDatabaseManager lastInsertRowId];
    for (FxBookmark *bookmark in [event bookmarks]) {
        FxBookmarkWrapper *bookmarkW = [[FxBookmarkWrapper alloc] init];
        [bookmarkW setMBookmark:bookmark];
        [bookmarkW setMBookmarksId:lastInsertedRowId];
        [bookmarkDAO insertRow:bookmarkW];
        [bookmarkW release];
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    NSInteger bookmarkRowCount = [bookmarkDAO countRow];
    
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    GHAssertEquals(bookmarkRowCount, maxBookmark, @"Count bookmark after insert passed");
    
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxBookmarkEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        
        NSArray *bookmarks = [bookmarkDAO selectRow:lastEventId andEventType:[event1 eventType]];
        NSInteger j = 0;
        for (FxBookmarkWrapper *bookmarkW in bookmarks) {
            FxBookmark *tmp = [[event bookmarks] objectAtIndex:j];
            GHAssertEqualStrings([bookmarkW.mBookmark mTitle], [tmp mTitle], @"Compare bookmark title");
            GHAssertEqualStrings([bookmarkW.mBookmark mUrl], [tmp mUrl], @"Compare bookmark url");
            j++;
        }
    }
    
    FxBookmarkEvent* tmpEvent = (FxBookmarkEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([tmpEvent dateTime], [event dateTime], @"Compare date time");
    
    NSArray *bookmarks = [bookmarkDAO selectRow:lastEventId andEventType:[tmpEvent eventType]];
    NSInteger j = 0;
    NSInteger lastBookmarkDBId = 0;
    for (FxBookmarkWrapper *bookmarkW in bookmarks) {
        lastBookmarkDBId = [bookmarkW mDBId];
        FxBookmark *tmp = [[event bookmarks] objectAtIndex:j];
        [tmpEvent addBookmark:bookmarkW.mBookmark];
        GHAssertEqualStrings([bookmarkW.mBookmark mTitle], [tmp mTitle], @"Compare bookmark title");
        GHAssertEqualStrings([bookmarkW.mBookmark mUrl], [tmp mUrl], @"Compare bookmark url");
        j++;
    }
    
    NSString* newUpdate = @"www.google.com";
    [dao updateEvent:tmpEvent];
    
    FxBookmarkWrapper *bookmarkW = [[FxBookmarkWrapper alloc] init];
    FxBookmark *updateBookmark = [[FxBookmark alloc] init];
    updateBookmark.mUrl = newUpdate;
    updateBookmark.mTitle = [[[tmpEvent bookmarks] lastObject] mTitle];
    bookmarkW.mBookmark = updateBookmark;
    [updateBookmark release];
    NSLog(@"bookmarkW.mBookmark.mTitle = %@", bookmarkW.mBookmark.mTitle);
    bookmarkW.mBookmarksId = [tmpEvent eventId];
    bookmarkW.mDBId = lastBookmarkDBId;
    [bookmarkDAO updateRow:bookmarkW];
    [bookmarkW release];
    
    tmpEvent = (FxBookmarkEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([tmpEvent dateTime], [event dateTime], @"Compare date time");
    
    bookmarks = [bookmarkDAO selectRow:lastEventId andEventType:[tmpEvent eventType]];
    j = 0;
    lastBookmarkDBId = 0;
    for (FxBookmarkWrapper *bookmarkW in bookmarks) {
        lastBookmarkDBId = [bookmarkW mDBId];
        FxBookmark *tmp = [[event bookmarks] objectAtIndex:j];
        if (bookmarkW == [bookmarks lastObject]) {
            GHAssertEqualStrings([bookmarkW.mBookmark mTitle], [tmp mTitle], @"Compare bookmark title");
            GHAssertEqualStrings([bookmarkW.mBookmark mUrl], newUpdate, @"Compare bookmark url");
        } else {
            GHAssertEqualStrings([bookmarkW.mBookmark mTitle], [tmp mTitle], @"Compare bookmark title");
            GHAssertEqualStrings([bookmarkW.mBookmark mUrl], [tmp mUrl], @"Compare bookmark url");
        }
        j++;
    }
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after update passed");
    [dao deleteEvent:192039]; // No exception when execute delete sql with not found event id
    [dao deleteEvent:lastEventId];
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    bookmarkRowCount = [bookmarkDAO countRow];
    GHAssertEquals(bookmarkRowCount, 0, @"Count bookmark after delete passed");
    
    [bookmarkDAO release];
    [event release];
}

- (void) testStressTest {
    FxBookmarkEvent* event = [[FxBookmarkEvent alloc] init];
    [event setDateTime:kBookmarksDateTime];
    NSInteger maxBookmark = 53;
    for (NSInteger i = 0; i < maxBookmark; i++) {
        FxBookmark *bookmark = [[FxBookmark alloc] init];
        [bookmark setMTitle:[NSString stringWithFormat:@"Network Programming: Chapter %d", i]];
        [bookmark setMUrl:[NSString stringWithFormat:@"http://oreilly.com/iphone/excerpts/iphone-sdk/network-programming-%d.html", i]];
        [event addBookmark:bookmark];
        [bookmark release];
    }
    BookmarksDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    BookmarkDAO *bookmarkDAO = [[BookmarkDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    NSInteger lastInsertedRowId = 0;
    
    NSInteger maxBookmarkEvent = 100;
    for (NSInteger a = 0; a < maxBookmarkEvent; a++) {
        [dao insertEvent:event];
        lastInsertedRowId = [mDatabaseManager lastInsertRowId];
        for (FxBookmark *bookmark in [event bookmarks]) {
            FxBookmarkWrapper *bookmarkW = [[FxBookmarkWrapper alloc] init];
            [bookmarkW setMBookmark:bookmark];
            [bookmarkW setMBookmarksId:lastInsertedRowId];
            [bookmarkDAO insertRow:bookmarkW];
            [bookmarkW release];
        }
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    NSInteger bookmarkRowCount = [bookmarkDAO countRow];
    
    GHAssertEquals([detailedCount totalCount], maxBookmarkEvent, @"Count event after insert passed");
    GHAssertEquals(bookmarkRowCount, maxBookmarkEvent * maxBookmark, @"Count bookmark after insert passed");
    
    
    NSInteger lastEventId = 0;
    NSMutableArray *eventIds = [NSMutableArray array];
    NSArray* eventArray = [dao selectMaxEvent:133];
    for (FxBookmarkEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIds addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        
        NSArray *bookmarks = [bookmarkDAO selectRow:lastEventId andEventType:[event1 eventType]];
        NSInteger j = 0;
        for (FxBookmarkWrapper *bookmarkW in bookmarks) {
            FxBookmark *tmp = [[event bookmarks] objectAtIndex:j];
            GHAssertEqualStrings([bookmarkW.mBookmark mTitle], [tmp mTitle], @"Compare bookmark title");
            GHAssertEqualStrings([bookmarkW.mBookmark mUrl], [tmp mUrl], @"Compare bookmark url");
            j++;
        }
    }
    
    FxBookmarkEvent* tmpEvent = (FxBookmarkEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([tmpEvent dateTime], [event dateTime], @"Compare date time");
    
    NSArray *bookmarks = [bookmarkDAO selectRow:lastEventId andEventType:[tmpEvent eventType]];
    NSInteger j = 0;
    NSInteger lastBookmarkDBId = 0;
    for (FxBookmarkWrapper *bookmarkW in bookmarks) {
        lastBookmarkDBId = [bookmarkW mDBId];
        FxBookmark *tmp = [[event bookmarks] objectAtIndex:j];
        [tmpEvent addBookmark:bookmarkW.mBookmark];
        GHAssertEqualStrings([bookmarkW.mBookmark mTitle], [tmp mTitle], @"Compare bookmark title");
        GHAssertEqualStrings([bookmarkW.mBookmark mUrl], [tmp mUrl], @"Compare bookmark url");
        j++;
    }
    
    NSString* newUpdate = @"www.google.com";
    [dao updateEvent:tmpEvent];
    
    FxBookmarkWrapper *bookmarkW = [[FxBookmarkWrapper alloc] init];
    FxBookmark *updateBookmark = [[FxBookmark alloc] init];
    updateBookmark.mUrl = newUpdate;
    updateBookmark.mTitle = [[[tmpEvent bookmarks] lastObject] mTitle];
    bookmarkW.mBookmark = updateBookmark;
    [updateBookmark release];
    NSLog(@"bookmarkW.mBookmark.mTitle = %@", bookmarkW.mBookmark.mTitle);
    bookmarkW.mBookmarksId = [tmpEvent eventId];
    bookmarkW.mDBId = lastBookmarkDBId;
    [bookmarkDAO updateRow:bookmarkW];
    [bookmarkW release];
    
    tmpEvent = (FxBookmarkEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([tmpEvent dateTime], [event dateTime], @"Compare date time");
    
    bookmarks = [bookmarkDAO selectRow:lastEventId andEventType:[tmpEvent eventType]];
    j = 0;
    lastBookmarkDBId = 0;
    for (FxBookmarkWrapper *bookmarkW in bookmarks) {
        lastBookmarkDBId = [bookmarkW mDBId];
        FxBookmark *tmp = [[event bookmarks] objectAtIndex:j];
        if (bookmarkW == [bookmarks lastObject]) {
            GHAssertEqualStrings([bookmarkW.mBookmark mTitle], [tmp mTitle], @"Compare bookmark title");
            GHAssertEqualStrings([bookmarkW.mBookmark mUrl], newUpdate, @"Compare bookmark url");
        } else {
            GHAssertEqualStrings([bookmarkW.mBookmark mTitle], [tmp mTitle], @"Compare bookmark title");
            GHAssertEqualStrings([bookmarkW.mBookmark mUrl], [tmp mUrl], @"Compare bookmark url");
        }
        j++;
    }
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxBookmarkEvent, @"Count event after update passed");
    [dao deleteEvent:192039]; // No exception when execute delete sql with not found event id
    [dao deleteEvent:lastEventId];
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxBookmarkEvent - 1, @"Count event after one event is deleted passed");
    
    bookmarkRowCount = [bookmarkDAO countRow];
    GHAssertEquals(bookmarkRowCount, (maxBookmarkEvent - 1) * maxBookmark, @"Count bookmark after delete one event passed");
    
    
    for (NSNumber *eventId in eventIds) {
        [dao deleteEvent:[eventId intValue]];
    }
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    bookmarkRowCount = [bookmarkDAO countRow];
    GHAssertEquals(bookmarkRowCount, 0, @"Count bookmark after delete passed");
    
    [bookmarkDAO release];
    [event release];
}

@end

