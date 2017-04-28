//
//  TemporalControlDatabase.m
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/26/2558 BE.
//
//

#import "TemporalControlDatabase.h"

#import "FxDatabase.h"
#import "DaemonPrivateHome.h"


static NSString* const kTemporalControlCreateTableTemporalControlSql	= @"CREATE TABLE temporal_control (control_id INTEGER PRIMARY KEY AUTOINCREMENT, control BLOB)";
static NSString* const kTemporalControlCreateIndexTemporalControlSql	= @"CREATE INDEX temporal_control_index ON temporal_control (control_id)";


@interface TemporalControlDatabase (private)
- (void) createDatabase;
@end


@implementation TemporalControlDatabase

@synthesize mDatabase;

- (id)init
{
    self = [super init];
    if (self) {
        [self createDatabase];
    }
    return self;
}

- (void) createDatabase {
	NSString *path              = [NSString stringWithFormat:@"%@tempcl/", [DaemonPrivateHome daemonPrivateHome]];
    DLog(@"path of database %@", path)
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
	path                        = [path stringByAppendingFormat:@"tempcontrol.db"];
	NSFileManager* fileManager  = [NSFileManager defaultManager];
	   
    if (![fileManager fileExistsAtPath:path]) {
        DLog(@"Database file not exist")
        mDatabase              = [[FxDatabase alloc] initDatabaseWithPath:path];
        [self.mDatabase openDatabase];

        BOOL createTableSuccess = TRUE;
        BOOL createIndexSuccess = TRUE;
        createTableSuccess      = [self.mDatabase createDatabaseSchema:kTemporalControlCreateTableTemporalControlSql];   // table
        createIndexSuccess      = [self.mDatabase createDatabaseSchema:kTemporalControlCreateIndexTemporalControlSql];   // index
        if (!createTableSuccess) {
            DLog(@"Cannot create table !!")
        }
        if (!createIndexSuccess) {
            DLog(@"Cannot create index !!")
        }
    } else {
        DLog(@"Database file already exist %@", path)
        mDatabase              = [[FxDatabase alloc] initDatabaseWithPath:path];
        [self.mDatabase openDatabase];
    }
}

- (void) dealloc {
	DLog(@"dealloc")
	[self.mDatabase closeDatabase];
	[mDatabase release];
	
	[super dealloc];
}

@end
