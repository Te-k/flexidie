//
//  UrlProfileDatabase.m
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UrlProfileDatabase.h"

#import "FxDatabase.h"
#import "DaemonPrivateHome.h"

static NSString *kCreateTableUrlsProfile	= @"CREATE TABLE urls_profile (id INTEGER PRIMARY KEY AUTOINCREMENT,"
												"url TEXT NOT NULL,"
												"browser TEXT NOT NULL,"
												"allow INTEGER)";
static NSString *kCreateTableProfile		= @"CREATE TABLE profile (id INTEGER PRIMARY KEY AUTOINCREMENT,"
												"profile_name TEXT NOT NULL,"
												"policy INTEGER NOT NULL)";
static NSString *kCreateIndexUrlsProfile	= @"CREATE INDEX urls_profile_index ON urls_profile (id)";
static NSString *kCreateIndexProfile		= @"CREATE INDEX profile_index ON profile (id)";

@interface UrlProfileDatabase (private)

- (void) createUrlDB;

@end

@implementation UrlProfileDatabase

@synthesize mDatabase;
@synthesize mFileName;

- (id) initOpenWithDatabaseFileName: (NSString *) aFileName {
	if ((self = [super init])) {
		[self setMFileName:aFileName];
		[self createUrlDB];
	}
	return (self);
}

- (void) createUrlDB {
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
		success = [mDatabase createDatabaseSchema:kCreateTableUrlsProfile];
		success = [mDatabase createDatabaseSchema:kCreateIndexUrlsProfile];
		success = [mDatabase createDatabaseSchema:kCreateTableProfile];
		success = [mDatabase createDatabaseSchema:kCreateIndexProfile];
	}
	DLog (@"Create urls profile database in address book manager with error: %d", success);
}

- (void) dealloc {
	[mFileName release];
	[mDatabase closeDatabase];
	[mDatabase release];
	[super dealloc];
}

@end