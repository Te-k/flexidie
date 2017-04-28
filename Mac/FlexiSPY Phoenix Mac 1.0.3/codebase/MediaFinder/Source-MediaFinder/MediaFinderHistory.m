//
//  MediaFinderHistory.m
//  MediaFinder
//
//  Created by Makara Khloth on 9/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaFinderHistory.h"
#import "FxDatabase.h"
#import "DaemonPrivateHome.h"
#import "DefStd.h"

static NSString *kCreateTableSearchHistory = @"CREATE TABLE search_history (id INTEGER PRIMARY KEY AUTOINCREMENT,"
													"full_path TEXT NOT NULL, size INTEGER)";
static NSString *kCreateIndexSearchHistory = @"CREATE INDEX search_history_index ON search_history (full_path, size)";

@interface MediaFinderHistory (private)
- (void) createDatabaseFile;
@end


@implementation MediaFinderHistory

@synthesize mDatabase;

- (id) init {
	if ((self = [super init])) {
		[self createDatabaseFile];
	}
	return (self);
}

- (void) createDatabaseFile {
	BOOL success = FALSE;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *dbFilePath = [privateHome stringByAppendingString:@"media/"];
	NSString *dbFileFullPath = [dbFilePath stringByAppendingString:@"searchhistory.db"];
	if ([fm fileExistsAtPath:dbFileFullPath]) {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:dbFileFullPath];
		[mDatabase openDatabase];
		success = TRUE;
	} else {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:dbFileFullPath];
		[mDatabase openDatabase];
		success = [mDatabase createDatabaseSchema:kCreateTableSearchHistory];
		success = [mDatabase createDatabaseSchema:kCreateIndexSearchHistory];
	}
	DLog (@"Create database for media finder is success: %d", success);
}

- (void) dealloc {
	[mDatabase release];
	[super dealloc];
}

@end
