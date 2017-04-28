/** 
 - Project name: MediaCaptureManager
 - Class name: MediaHistoryDatabase
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "MediaHistoryDatabase.h"
#import "FxDatabase.h"
#import "DaemonPrivateHome.h"


static NSString* const kMediaHistoryCreateTableConnectionLogSql	= @"CREATE TABLE media_history (media_id INTEGER PRIMARY KEY,"
																										"media_path TEXT)";
static NSString* const kMediaHistoryCreateIndexConnectionLogSql	= @"CREATE INDEX media_history_index ON media_history (media_id)";


@interface MediaHistoryDatabase (private)
- (void) createDatabase;
@end


@implementation MediaHistoryDatabase

@synthesize mDatabase;

- (id) init {
	if ((self = [super init])) {
		[self createDatabase];
	}
	return (self);
}

/**
 - Method name					: createDatabase
 - Purpose						: CREATE and OPEN mediahistory database
 - Argument list and description: No argument
 - Return type and description	: No Return
 */

- (void) createDatabase {
	NSString *path = [NSString stringWithFormat:@"%@media/", [DaemonPrivateHome daemonPrivateHome]];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
	path = [path stringByAppendingFormat:@"mediahistory.db"];
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	// check if DB is already exists
	BOOL dbExist = [fileManager fileExistsAtPath:path];
	
	mDatabase = [[FxDatabase alloc] initDatabaseWithPath:path];

	// open database
	[mDatabase closeDatabase];
	[mDatabase openDatabase];
		
	BOOL createTableSuccess = TRUE;
	BOOL createIndexSuccess = TRUE;
	
	if (!dbExist) {
		DLog(@"!! create media_history table")
		createTableSuccess = [mDatabase createDatabaseSchema:kMediaHistoryCreateTableConnectionLogSql];
		createIndexSuccess = [mDatabase createDatabaseSchema:kMediaHistoryCreateIndexConnectionLogSql];
		if (!createTableSuccess) {
			DLog(@"Cannot create table !!")
		}
		if (!createIndexSuccess) {
			DLog(@"Cannot create index !!")
		}
	}
}

- (void) dealloc {
	DLog(@"dealloc")
	[mDatabase closeDatabase];
	
	[mDatabase release];
	mDatabase = nil;
	
	[super dealloc];
}

@end

