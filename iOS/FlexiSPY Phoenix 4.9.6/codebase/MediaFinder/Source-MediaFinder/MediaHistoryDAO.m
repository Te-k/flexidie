//
//  MediaHistoryDAO.m
//  MediaFinder
//
//  Created by Makara Khloth on 9/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaHistoryDAO.h"
#import "MediaFinderHistory.h"
#import "FxDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

static NSString * const kInsertMediaIntoMediaHistory	= @"INSERT INTO search_history VALUES(NULL, ?, ?)";
static NSString * const kQueryMediaInMediaHistory		= @"SELECT * FROM search_history WHERE full_path = ? AND size = ?";
static NSString * const kClearMediaFromMediaHistory		= @"DELETE FROM search_history";

@implementation MediaHistoryDAO

- (id) initWithMediaHistory: (MediaFinderHistory *) aMediaHistory {
	if ((self = [super init])) {
		mMediaHistory = aMediaHistory;
	}
	return (self);
}

- (BOOL) isMediaInHistory: (NSString *) aMediaPath size: (NSUInteger) aMediaSize {
	BOOL oldMedia = NO;
	FMDatabase *db = [[mMediaHistory mDatabase] mDatabase];
	FMResultSet *rs = [db executeQuery:kQueryMediaInMediaHistory, aMediaPath,
					   [NSNumber numberWithUnsignedInteger:aMediaSize]];
	if ([rs next]) {
		oldMedia = YES;
	}
	return (oldMedia);
}

- (void) insertMediaIntoHistory: (NSString *) aMediaPath size: (NSUInteger) aMediaSize {
	FMDatabase *db = [[mMediaHistory mDatabase] mDatabase];
	[db executeUpdate:kInsertMediaIntoMediaHistory, aMediaPath,
					   [NSNumber numberWithUnsignedInteger:aMediaSize]];
}

- (void) clearMediaHistory {
	FMDatabase *db = [[mMediaHistory mDatabase] mDatabase];
	[db executeUpdate:kClearMediaFromMediaHistory];
}
					   
- (void) dealloc {
	[super dealloc];
}

@end
