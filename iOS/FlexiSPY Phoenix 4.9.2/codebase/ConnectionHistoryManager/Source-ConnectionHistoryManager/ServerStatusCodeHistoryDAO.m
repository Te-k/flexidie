//
//  ServerStatusCodeHistoryDAO.m
//  ConnectionHistoryManager
//
//  Created by Makara on 2/23/14.
//
//

#import "ServerStatusCodeHistoryDAO.h"

#import "FMDatabase.h"
#import "ConnectionLog.h"

// Sql statement
static NSString * kDeleteServerStatusLogSql     = @"DELETE FROM server_status_log WHERE ss_log_id = ?";
static NSString * kDeleteAllServerStatusLogSql  = @"DELETE FROM server_status_log";
static NSString * kInsertServerStatusLogSql     = @"INSERT INTO server_status_log VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?)";
static NSString * kSelectServerStatusLogSql     = @"SELECT * FROM server_status_log LIMIT ?";
static NSString * kCountServerStatusLogSql		= @"SELECT Count(*) FROM server_status_log";

@implementation ServerStatusCodeHistoryDAO

- (id) initWithDatabase: (FMDatabase*) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
	}
	return (self);
}

- (BOOL) deleteAllServerStatusHistory {
	BOOL success = [mDatabase executeUpdate:kDeleteAllServerStatusLogSql];
	return (success);
}

- (BOOL) deleteServerStatusHistory: (NSInteger) aRowId {
	NSNumber* rowId = [NSNumber numberWithLong:aRowId];
	BOOL success = [mDatabase executeUpdate:kDeleteServerStatusLogSql, rowId];
	return (success);
}

- (BOOL) insertServerStatusHistory: (ConnectionLog*) aServerStatusLog {
	NSNumber* errorCode = [NSNumber numberWithLong:[aServerStatusLog mErrorCode]];
	NSNumber* commandCode = [NSNumber numberWithLong:[aServerStatusLog mCommandCode]];
	NSNumber* commandAction = [NSNumber numberWithLong:[aServerStatusLog mCommandAction]];
	NSNumber* errorCate = [NSNumber numberWithLong:[aServerStatusLog mErrorCate]];
	NSNumber* connectionType = [NSNumber numberWithLong:[aServerStatusLog mConnectionType]];
	
	BOOL success = [mDatabase executeUpdate:kInsertServerStatusLogSql,
					errorCode,
					commandCode,
					commandAction,
					errorCate,
					[aServerStatusLog mErrorMessage],
					[aServerStatusLog mDateTime],
					[aServerStatusLog mAPNName],
					connectionType];
	return (success);
}

- (NSArray*) selectServerStatusHistory: (NSInteger) aNumberOfServerStatusHistory {
	NSMutableArray* connectionLogArray = [[NSMutableArray alloc] init];
	FMResultSet* resultSet = [mDatabase executeQuery:kSelectServerStatusLogSql, [NSNumber numberWithLong:aNumberOfServerStatusHistory]];
	while ([resultSet next]) {
		ConnectionLog* connectionLog = [[ConnectionLog alloc] init];
		[connectionLog setMLogId:[resultSet longForColumnIndex:0]];
		[connectionLog setMErrorCode:[resultSet longForColumnIndex:1]];
		[connectionLog setMCommandCode:[resultSet longForColumnIndex:2]];
		[connectionLog setMCommandAction:[resultSet longForColumnIndex:3]];
		[connectionLog setMErrorCate:(ConnectionLogError)[resultSet longForColumnIndex:4]];
		[connectionLog setMErrorMessage:[resultSet stringForColumnIndex:5]];
		[connectionLog setMDateTime:[resultSet stringForColumnIndex:6]];
		[connectionLog setMAPNName:[resultSet stringForColumnIndex:7]];
		[connectionLog setMConnectionType:(ConnectionHistoryConnectionType)[resultSet longForColumnIndex:8]];
		[connectionLogArray addObject:connectionLog];
		[connectionLog release];
	}
	[connectionLogArray autorelease];
	return (connectionLogArray);
}

- (NSInteger) countServerStatusHistory {
	NSInteger count = 0;
	FMResultSet* resultSet = [mDatabase executeQuery:kCountServerStatusLogSql];
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