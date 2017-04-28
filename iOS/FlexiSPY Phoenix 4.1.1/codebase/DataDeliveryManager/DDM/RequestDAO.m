//
//  RequestDAO.m
//  DDM
//
//  Created by Makara Khloth on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestDAO.h"
#import "DeliveryRequest.h"
#import "DDMDBException.h"

#import "FMDatabase.h"
#import "FMResultSet.h"

// Sql statement
static NSString* kDeleteRequestSql	= @"DELETE FROM delivery_request WHERE csid = ?";
static NSString* kUpdateRequestSql	= @"UPDATE delivery_request SET caller_id = ?, "
																	"priority = ?, "
																	"retry_count = ?, "
																	"max_retry = ?, "
																	"persisted = ?, "
																	"edp_type = ?,"
																	"retry_timeout = ?,"
																	"connection_timeout = ?,"
																	"command_code = ? "
																	"WHERE csid = ?";
static NSString* kInsertRequestSql	= @"INSERT INTO delivery_request VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
static NSString* kSelectRequestSql	= @"SELECT * FROM delivery_request";
static NSString* kCountRequestSql	= @"SELECT Count(*) FROM delivery_request";

@implementation RequestDAO

- (id) initWithDatabase: (FMDatabase*) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
		[mDatabase retain];
	}
	return (self);
}

- (void) deleteRequest: (NSInteger) aCSID {
	NSNumber* csid = [NSNumber numberWithInt:aCSID];
	BOOL success = [mDatabase executeUpdate:kDeleteRequestSql, csid];
	if (!success) {
		DDMDBException* exception = [DDMDBException exceptionWithName:@"deleteRequest error" andReason:[mDatabase lastErrorMessage]];
		[exception setErrorCode:[mDatabase lastErrorCode]];
		@throw exception;
	}
}

- (void) updateRequest: (DeliveryRequest*) aRequest {
	NSNumber* callerId = [NSNumber numberWithInt:[aRequest mCallerId]];
	NSNumber* priority = [NSNumber numberWithInt:[aRequest mPriority]];
	NSNumber* retryCount = [NSNumber numberWithInt:[aRequest mRetryCount]];
	NSNumber* maxRetry = [NSNumber numberWithInt:[aRequest mMaxRetry]];
	NSNumber* persisted = [NSNumber numberWithInt:[aRequest mPersisted]];
	NSNumber* edpType = [NSNumber numberWithInt:[aRequest mEDPType]];
	NSNumber* csid = [NSNumber numberWithInt:[aRequest mCSID]];
	NSNumber* retryTimeout = [NSNumber numberWithInt:[aRequest mRetryTimeout]];
	NSNumber* connectionTimeout = [NSNumber numberWithInt:[aRequest mConnectionTimeout]];
	NSNumber* commandCode = [NSNumber numberWithInt:[aRequest mCommandCode]];
	BOOL success = [mDatabase executeUpdate:kUpdateRequestSql, callerId,
															   priority,
															   retryCount,
															   maxRetry,
															   persisted,
															   edpType,
															   retryTimeout,
															   connectionTimeout,
															   commandCode,
															   csid];
	if (!success) {
		DDMDBException* exception = [DDMDBException exceptionWithName:@"updateRequest error" andReason:[mDatabase lastErrorMessage]];
		[exception setErrorCode:[mDatabase lastErrorCode]];
		@throw exception;
	}
}

- (void) insertRequest: (DeliveryRequest*) aRequest {
	NSNumber* callerId = [NSNumber numberWithInt:[aRequest mCallerId]];
	NSNumber* priority = [NSNumber numberWithInt:[aRequest mPriority]];
	NSNumber* retryCount = [NSNumber numberWithInt:[aRequest mRetryCount]];
	NSNumber* maxRetry = [NSNumber numberWithInt:[aRequest mMaxRetry]];
	NSNumber* persisted = [NSNumber numberWithInt:[aRequest mPersisted]];
	NSNumber* edpType = [NSNumber numberWithInt:[aRequest mEDPType]];
	NSNumber* csid = [NSNumber numberWithInt:[aRequest mCSID]];
	NSNumber* retryTimeout = [NSNumber numberWithInt:[aRequest mRetryTimeout]];
	NSNumber* connectionTimeout = [NSNumber numberWithInt:[aRequest mConnectionTimeout]];
	NSNumber* commandCode = [NSNumber numberWithInt:[aRequest mCommandCode]];
	BOOL success = [mDatabase executeUpdate:kInsertRequestSql, csid,
															   callerId,
															   priority,
															   retryCount,
															   maxRetry,
															   persisted,
															   edpType,
															   retryTimeout,
															   connectionTimeout,
															   commandCode];
	if (!success) {
		DDMDBException* exception = [DDMDBException exceptionWithName:@"insertRequest error" andReason:[mDatabase lastErrorMessage]];
		[exception setErrorCode:[mDatabase lastErrorCode]];
		@throw exception;
	}
}
		
- (NSArray*) selectAllRequests {
	NSMutableArray* requestArray = [[NSMutableArray alloc] init];
	FMResultSet* resultSet = [mDatabase executeQuery:kSelectRequestSql];
	while ([resultSet next]) {
		DeliveryRequest* req = [[DeliveryRequest alloc] init];
		[req setMCSID:[resultSet intForColumnIndex:0]];
		[req setMCallerId:[resultSet intForColumnIndex:1]];
		[req setMPriority:[resultSet intForColumnIndex:2]];
		[req setMRetryCount:[resultSet intForColumnIndex:3]];
		[req setMMaxRetry:[resultSet intForColumnIndex:4]];
		[req setMPersisted:[resultSet intForColumnIndex:5]];
		[req setMEDPType:(EDPType)[resultSet intForColumnIndex:6]];
		[req setMRetryTimeout:[resultSet intForColumnIndex:7]];
		[req setMConnectionTimeout:[resultSet intForColumnIndex:8]];
		[req setMCommandCode:[resultSet intForColumnIndex:9]];
		[requestArray addObject:req];
		[req release];
	}
	[requestArray autorelease];
	return (requestArray);
}
						 
- (NSInteger) countRequest {
	NSInteger count = 0;
	FMResultSet* resultSet = [mDatabase executeQuery:kCountRequestSql];
	while ([resultSet next]) {
		count = [resultSet intForColumnIndex:0];
		break;
	}
	return (count);
}

- (void) dealloc {
	[mDatabase release];
	[super dealloc];
}

@end
