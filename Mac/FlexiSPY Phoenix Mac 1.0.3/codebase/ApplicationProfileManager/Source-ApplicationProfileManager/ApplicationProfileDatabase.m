//
//  ApplicationProfileDatabase.m
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationProfileDatabase.h"

#import "FxDatabase.h"
#import "DaemonPrivateHome.h"

static NSString *kCreateTableAppProfile		= @"CREATE TABLE app_profile (id INTEGER PRIMARY KEY AUTOINCREMENT,"
												"identifier TEXT NOT NULL,"
												"name TEXT NOT NULL,"
												"type INTEGER,"
												"allow INTEGER)";
static NSString *kCreateTableProfile		= @"CREATE TABLE profile (id INTEGER PRIMARY KEY AUTOINCREMENT,"
												"profile_name TEXT NOT NULL,"
												"policy INTEGER NOT NULL)";
static NSString *kCreateIndexAppProfile		= @"CREATE INDEX app_profile_index ON app_profile (id)";
static NSString *kCreateIndexProfile		= @"CREATE INDEX profile_index ON profile (id)";

@interface ApplicationProfileDatabase (private)

- (void) createContactDB;

@end

@implementation ApplicationProfileDatabase

@synthesize mDatabase;
@synthesize mFileName;

- (id) initOpenWithDatabaseFileName: (NSString *) aFileName {
	if ((self = [super init])) {
		[self setMFileName:aFileName];
		[self createContactDB];
	}
	return (self);
}

- (void) createContactDB {
	BOOL success = NO;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:[privateHome stringByAppendingString:@"profiles/"]];
	NSString *dbFullPath = [NSString stringWithFormat:@"%@profiles/%@", privateHome, [self mFileName]];
	if ([fm fileExistsAtPath:dbFullPath]) {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:dbFullPath];
		[mDatabase openDatabase];
		success = YES;
	} else {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:dbFullPath];
		[mDatabase openDatabase];
		success = [mDatabase createDatabaseSchema:kCreateTableAppProfile];
		success = [mDatabase createDatabaseSchema:kCreateIndexAppProfile];
		success = [mDatabase createDatabaseSchema:kCreateTableProfile];
		success = [mDatabase createDatabaseSchema:kCreateIndexProfile];
	}
	DLog (@"Create application profile database in address book manager with error: %d", success);
}

- (void) dealloc {
	[mFileName release];
	[mDatabase closeDatabase];
	[mDatabase release];
	[super dealloc];
}

@end