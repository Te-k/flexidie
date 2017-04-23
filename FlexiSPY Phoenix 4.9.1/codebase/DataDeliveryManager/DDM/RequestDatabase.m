//
//  RequestDatabase.m
//  DDM
//
//  Created by Makara Khloth on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestDatabase.h"
#import "DDMDBException.h"

#import "FMDatabase.h"

static NSString* kDDMCreateTableRequestSql = @"CREATE TABLE delivery_request (csid INTEGER PRIMARY KEY,"
																	"caller_id INTEGER NOT NULL,"
																	"priority INTEGER NOT NULL,"
																	"retry_count INTEGER NOT NULL,"
																	"max_retry INTEGER NOT NULL,"
																	"persisted INTEGER NOT NULL,"
																	"edp_type INTEGER,"
																	"retry_timeout INTEGER,"
																	"connection_timeout INTEGER,"
																	"command_code INTEGER)";
static NSString* kDDMCreateIndexRequestSql = @"CREATE INDEX delivery_request_index ON delivery_request (csid)";

@interface RequestDatabase (private)

- (void) openDatabaseAndCreateSchema;

@end

@implementation RequestDatabase

@synthesize mDatabaseFullName;

- (id) initAndOpenDatabaseWithName: (NSString*) aFullName {
	if ((self = [super init])) {
		mOpened = FALSE;
		mDatabaseFullName = aFullName;
		[mDatabaseFullName retain];
		[self openDatabaseAndCreateSchema];
	}
	return (self);
}

- (void) openDatabase {
	if ([mDatabase open]) {
		mOpened = TRUE;
	} else {
		mOpened = FALSE;
	}
}

- (void) closeDatabase {
	if (mOpened) {
		[mDatabase close];
		mOpened = FALSE;
	}
}

- (void) dropDatabase {
	[self closeDatabase];
	[mDatabase release];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:mDatabaseFullName error:nil];
	[self openDatabaseAndCreateSchema];
}

- (FMDatabase*) database {
	return (mDatabase);
}

- (void) openDatabaseAndCreateSchema {
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL dbExist = [fileManager fileExistsAtPath:mDatabaseFullName];
	mDatabase = [[FMDatabase alloc] initWithPath:mDatabaseFullName];
    [self openDatabase];
	if (!dbExist) {
		BOOL tableSuccess = [mDatabase executeUpdate:kDDMCreateTableRequestSql];
		BOOL indexSuccess = [mDatabase executeUpdate:kDDMCreateIndexRequestSql];
		if (!tableSuccess || !indexSuccess) {
			DDMDBException* exception = [DDMDBException exceptionWithName:@"createDatabaseSchema" andReason:[mDatabase lastErrorMessage]];
			[exception setErrorCode:[mDatabase lastErrorCode]];
			@throw exception;
		}
	}
}

- (void) dealloc {
	[mDatabaseFullName release];
	[self closeDatabase];
	[mDatabase release];
	[super dealloc];
}

@end
