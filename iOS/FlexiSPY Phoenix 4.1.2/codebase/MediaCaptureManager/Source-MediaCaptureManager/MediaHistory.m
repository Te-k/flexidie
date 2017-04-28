/** 
 - Project name: MediaCaptureManager
 - Class name: MediaHistory
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "MediaHistory.h"
#import "FMDatabase.h"


#define ROW_LIMIT 50


static NSString* kInsertMediaHistorySql			= @"INSERT INTO media_history VALUES(NULL, ?)";

static NSString* kCountMediaHistorySql			= @"SELECT Count(*) FROM media_history";

static NSString* kSelectFirstRowMediaHistorySql = @"SELECT * FROM media_history LIMIT 1";
static NSString* kSelectMediaHistorySql			= @"SELECT * FROM media_history WHERE media_path = ?";

static NSString* kDeleteMediaHistorySql			= @"DELETE FROM media_history WHERE media_id = ?";


@interface MediaHistory (private)
- (BOOL) deleteFirstRow;
- (NSInteger) countMediaHistory;
@end


@implementation MediaHistory

@synthesize mDatabase;

- (id) initWithDatabase: (FMDatabase*) aDatabase {
	if ((self = [super init])) {
		mDatabase = [aDatabase retain];
	}
	return (self);
}

/**
 - Method name					: addMedia
 - Purpose						: CREATE and OPEN mediahistory database
 - Argument list and description: a media path (NSString *) 
 - Return type and description	: the resulf of inserting the media path into the database (BOOL)
 */

- (BOOL) addMedia: (NSString *) aMediaPath {
	DLog(@"count now: %ld", (long)[self countMediaHistory])
	DLog(@"media path %@", aMediaPath)
	
	BOOL delSuccess = TRUE;
	
	// if a number of media is greater than ROW_LIMIT
	if ([self countMediaHistory] >= ROW_LIMIT)
		delSuccess = [self deleteFirstRow];
	
	// Insert the new media into the database
	BOOL insSuccess = [mDatabase  executeUpdate:kInsertMediaHistorySql, aMediaPath];
	
	return (delSuccess && insSuccess);
}

/**
 - Method name					: checkDuplication
 - Purpose						: check whether aMediaPath argument already exist in the database
 - Argument list and description: a media path (NSString *) 
 - Return type and description	: TRUE if aMediaPath already exist in the database
 */

- (BOOL) checkDuplication: (NSString *) aMediaPath {
	FMResultSet* resultSet = [mDatabase  executeQuery:kSelectMediaHistorySql, aMediaPath];
	BOOL isExist = FALSE;
	while ([resultSet next]) {
		isExist = TRUE;
	}
	return isExist;
}

- (BOOL) deleteFirstRow {
	BOOL delSuccess = FALSE;
	
	// delete the first row (lowest index)
	FMResultSet* resultSet = [mDatabase executeQuery:kSelectFirstRowMediaHistorySql];
	
	while ([resultSet next]) {
		NSInteger primaryKey = [resultSet intForColumn:@"media_id"];
		DLog(@"index: %ld", (long)primaryKey)
		
		delSuccess = [mDatabase  executeUpdate:kDeleteMediaHistorySql, [NSNumber numberWithInteger:primaryKey]];
		
		if (!delSuccess) {DLog(@"cannot delete the first row")}
	}
	return delSuccess;
}

- (NSInteger) countMediaHistory {
	NSInteger count = 0;
	FMResultSet* resultSet = [mDatabase  executeQuery:kCountMediaHistorySql];
	while ([resultSet next]) {
		count = [resultSet intForColumnIndex:0];
		break;
	}
	return count;
}

- (void) dealloc {
	[mDatabase release];
	[super dealloc];
}

@end
