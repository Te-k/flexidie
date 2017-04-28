//
//  ConnectionHistoryDAO.m
//  ConnectionHistoryManager
//
//  Created by Makara Khloth on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConnectionHistoryDAO.h"

#import "FMDatabase.h"
#import "ConnectionLog.h"

// Sql statement
static NSString* kDeleteConnectionLogSql	= @"DELETE FROM connection_log WHERE conn_log_id = ?";
static NSString* kDeleteAllConnectionLogSql	= @"DELETE FROM connection_log";
static NSString* kInsertConnectionLogSql	= @"INSERT INTO connection_log VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?)";
static NSString* kSelectConnectionLogSql	= @"SELECT * FROM connection_log LIMIT ?";
static NSString* kCountConnectionLogSql		= @"SELECT Count(*) FROM connection_log";

@implementation ConnectionHistoryDAO

- (id) initWithDatabase: (FMDatabase*) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
	}
	return (self);
}

- (BOOL) deleteAllConnectionHistory {
	BOOL success = [mDatabase executeUpdate:kDeleteAllConnectionLogSql];
	return (success);
}

- (BOOL) deleteConnectionHistory: (NSInteger) aRowId {
	NSNumber* rowId = [NSNumber numberWithInt:aRowId];
	BOOL success = [mDatabase executeUpdate:kDeleteConnectionLogSql, rowId];
	return (success);
}

- (BOOL) insertConnectionHistory: (ConnectionLog*) aConnectionLog {
	NSNumber* errorCode = [NSNumber numberWithInt:[aConnectionLog mErrorCode]];
	NSNumber* commandCode = [NSNumber numberWithInt:[aConnectionLog mCommandCode]];
	NSNumber* commandAction = [NSNumber numberWithInt:[aConnectionLog mCommandAction]];
	NSNumber* errorCate = [NSNumber numberWithInt:[aConnectionLog mErrorCate]];
	NSNumber* connectionType = [NSNumber numberWithInt:[aConnectionLog mConnectionType]];
	
	BOOL success = [mDatabase executeUpdate:kInsertConnectionLogSql,
					errorCode,
					commandCode,
					commandAction,
					errorCate,
					[aConnectionLog mErrorMessage],
					[aConnectionLog mDateTime],
					[aConnectionLog mAPNName],
					connectionType];
	return (success);
}

- (NSArray*) selectConnectionHistory: (NSInteger) aNumberOfConnectionHistory {
	NSMutableArray* connectionLogArray = [[NSMutableArray alloc] init];
	FMResultSet* resultSet = [mDatabase executeQuery:kSelectConnectionLogSql, [NSNumber numberWithInt:aNumberOfConnectionHistory]];
	while ([resultSet next]) {
		ConnectionLog* connectionLog = [[ConnectionLog alloc] init];
		[connectionLog setMLogId:[resultSet intForColumnIndex:0]];
		[connectionLog setMErrorCode:[resultSet intForColumnIndex:1]];
		[connectionLog setMCommandCode:[resultSet intForColumnIndex:2]];
		[connectionLog setMCommandAction:[resultSet intForColumnIndex:3]];
		[connectionLog setMErrorCate:(ConnectionLogError)[resultSet intForColumnIndex:4]];
		[connectionLog setMErrorMessage:[resultSet stringForColumnIndex:5]];
		[connectionLog setMDateTime:[resultSet stringForColumnIndex:6]];
		[connectionLog setMAPNName:[resultSet stringForColumnIndex:7]];
		[connectionLog setMConnectionType:(ConnectionHistoryConnectionType)[resultSet intForColumnIndex:8]];
		[connectionLogArray addObject:connectionLog];
		[connectionLog release];
	}
	[connectionLogArray autorelease];
	return (connectionLogArray);
}

- (NSInteger) countConnectionHistory {
	NSInteger count = 0;
	FMResultSet* resultSet = [mDatabase executeQuery:kCountConnectionLogSql];
	while ([resultSet next]) {
		count = [resultSet intForColumnIndex:0];
		break;
	}
	return (count);
}

- (void) dealloc {
	[super dealloc];
}

@end
