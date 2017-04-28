//
//  EventKeysDatabase.m
//  EDM
//
//  Created by Makara Khloth on 10/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventKeysDatabase.h"
#import "FxException.h"
#import "FMDatabase.h"

static NSString* kEDMCreateTableRequestSql = @"CREATE TABLE edmeventkeys (edp_type INTEGER NOT NULL,"
																			"event_id INTEGER NOT NULL,"
																			"event_type INTEGER NOT NULL)";
static NSString* kEDMCreateIndexRequestSql = @"CREATE INDEX edmeventkeys_index ON edmeventkeys (edp_type)";

@interface EventKeysDatabase (private)

- (void) openDatabaseAndCreateSchema;

@end

@implementation EventKeysDatabase

@synthesize mDatabaseFullName;
@synthesize mDatabase;
@synthesize mOpened;

- (id) initWithDatabasePathAndOpen: (NSString*) aDBPath {
	if ((self = [super init])) {
		mDatabaseFullName = aDBPath;
		[mDatabaseFullName retain];
		[self openDatabaseAndCreateSchema];
	}
	return (self);
}

- (void) openDB {
	if ([mDatabase open]) {
		[self setMOpened:TRUE];
	} else {
		[self setMOpened:FALSE];
	}
}

- (void) closeDB {
	if ([self mOpened]) {
		[mDatabase close];
		[self setMOpened:FALSE];
	}
}

- (void) dropDB {
	[self closeDB];
	[mDatabase release];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:mDatabaseFullName error:nil];
	[self openDatabaseAndCreateSchema];
}

- (void) openDatabaseAndCreateSchema {
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL dbExist = [fileManager fileExistsAtPath:mDatabaseFullName];
	mDatabase = [[FMDatabase alloc] initWithPath:mDatabaseFullName];
    [self openDB];
	if (!dbExist) {
		BOOL tableSuccess = [mDatabase executeUpdate:kEDMCreateTableRequestSql];
		BOOL indexSuccess = [mDatabase executeUpdate:kEDMCreateIndexRequestSql];
		DLog(@"tableSuccess: %d, indexSuccess: %d", tableSuccess, indexSuccess)
		if (!tableSuccess || !indexSuccess) {
			FxException* exception = [FxException exceptionWithName:@"openDatabaseAndCreateSchema" andReason:[mDatabase lastErrorMessage]];
			[exception setErrorCode:[mDatabase lastErrorCode]];
			[exception setErrorCategory:kFxErrorEDMDatabase];
			@throw exception;
		}
	}
}

- (void) dealloc {
	[mDatabaseFullName release];
	[super dealloc];
}

@end
