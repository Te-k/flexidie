//
//  ConnectionHistoryDatabase.m
//  ConnectionHistoryManager
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConnectionHistoryDatabase.h"

#import "FxDatabase.h"
#import "DaemonPrivateHome.h"

static NSString* const kConnectionHistoryCreateTableConnectionLogSql	= @"CREATE TABLE connection_log (conn_log_id INTEGER PRIMARY KEY,"
																				"error_code INTEGER,"
																				"command_code INTEGER,"
																				"command_action INTEGER,"
																				"error_cate INTEGER,"
																				"error_message TEXT,"
																				"date_time TEXT,"
																				"apn_name TEXT,"
																				"conn_type INTEGER)";
static NSString* const kServerStatusHistoryCreateTableConnectionLogSql	= @"CREATE TABLE IF NOT EXISTS server_status_log (ss_log_id INTEGER PRIMARY KEY,"
                                                                                "error_code INTEGER,"
                                                                                "command_code INTEGER,"
                                                                                "command_action INTEGER,"
                                                                                "error_cate INTEGER,"
                                                                                "error_message TEXT,"
                                                                                "date_time TEXT,"
                                                                                "apn_name TEXT,"
                                                                                "conn_type INTEGER)";
static NSString* const kConnectionHistoryCreateIndexConnectionLogSql	= @"CREATE INDEX connection_log_index ON connection_log (conn_log_id)";
static NSString* const kServerStatusHistoryCreateIndexConnectionLogSql	= @"CREATE INDEX IF NOT EXISTS server_status_log_index ON connection_log (ss_log_id)";


@interface ConnectionHistoryDatabase (private)
- (void) createDatabase;

@end

@implementation ConnectionHistoryDatabase

@synthesize mDatabase;

- (id) init {
	if ((self = [super init])) {
		[self createDatabase];
	}
	return (self);
}

- (void) createDatabase {
	NSString *path = [NSString stringWithFormat:@"%@history/", [DaemonPrivateHome daemonPrivateHome]];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
	path = [path stringByAppendingFormat:@"conhistory.db"];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL dbExist = [fileManager fileExistsAtPath:path];
	mDatabase = [[FxDatabase alloc] initDatabaseWithPath:path];
	[mDatabase openDatabase];
	if (!dbExist) {
		[mDatabase createDatabaseSchema:kConnectionHistoryCreateTableConnectionLogSql];
		[mDatabase createDatabaseSchema:kConnectionHistoryCreateIndexConnectionLogSql];
        
        // Database v2
        [mDatabase createDatabaseSchema:kServerStatusHistoryCreateTableConnectionLogSql];
        [mDatabase createDatabaseSchema:kServerStatusHistoryCreateIndexConnectionLogSql];
	} else {
        // Database v2
        [mDatabase createDatabaseSchema:kServerStatusHistoryCreateTableConnectionLogSql];
        [mDatabase createDatabaseSchema:kServerStatusHistoryCreateIndexConnectionLogSql];
    }
}

- (void) dealloc {
	[mDatabase release];
	[super dealloc];
}

@end
