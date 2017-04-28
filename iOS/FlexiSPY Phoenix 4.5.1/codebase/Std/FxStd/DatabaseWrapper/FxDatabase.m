//
//  FxDatabase.m
//  FxStd
//
//  Created by Makara Khloth on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxDatabase.h"
#import "FMDatabase.h"

@interface FxDatabase (private)
- (id) initWithPath: (NSString *) aFullPath;
@end

@implementation FxDatabase

@synthesize mFullPath;
@synthesize mDatabase;

+ (id) databaseWithPath: (NSString *) aFullPath {
	FxDatabase *db = [[FxDatabase alloc] initWithPath:aFullPath];
	return ([db autorelease]);
}

- (id) initDatabaseWithPath: (NSString*) aFullPath {
	if ((self = [super init])) {
		mIsOpen = FALSE;
		mFullPath = [[NSString alloc] initWithString:aFullPath];
		mDatabase = [[FMDatabase alloc] initWithPath:mFullPath];
	}
	return (self);
}

- (id) initWithPath: (NSString *) aFullPath {
	if ((self = [super init])) {
		mIsOpen = FALSE;
		mFullPath = [[NSString alloc] initWithString:aFullPath];
		mDatabase = [FMDatabase databaseWithPath:mFullPath];
		[mDatabase retain];
	}
	return (self);
}

- (void) openDatabase {
	if ([mDatabase open]) {
		mIsOpen = TRUE;
	} else {
		mIsOpen = FALSE;
	}
}

- (void) closeDatabase {
	if (mIsOpen) {
		[mDatabase close];
		mIsOpen = FALSE;
	}
}

/**
 - Method Name                    : dropDatabase
 - Purpose                        : Drop the database and create an empty database, caller must call createDatabaseSchema to create for new empty database 
 - Argument list and description  : No argument
 - Return description             : No return
 **/

- (void) dropDatabase {
	[self closeDatabase];
	[mDatabase release];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:mFullPath error:nil];
	mDatabase = [[FMDatabase alloc] initWithPath:mFullPath];
	[self openDatabase];
}

/**
 - Method Name                    : createDatabaseSchema
 - Purpose                        : Create table, index and trigger, this method must call after initDatabaseWithPath and openDatabase
 - Argument list and description  : aSqlStatement, contain sql statement
 - Return description             : TRUE, if success
 **/
- (BOOL) createDatabaseSchema: (NSString*) aSqlStatement {
	BOOL schemaSuccess = [mDatabase executeUpdate:aSqlStatement];
	return (schemaSuccess);
}

- (void) dealloc {
	[mFullPath release];
	[self closeDatabase];
	[mDatabase release];
	[super dealloc];
}

@end