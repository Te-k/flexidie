//
//  NTADatabase.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/6/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "NTADatabase.h"
#import "DaemonPrivateHome.h"
#import "FMDatabase.h"
#import "FxDatabase.h"
#import "NTAlertCriteria.h"

#import "ClientAlert.h"

static NSString* const kCreateTableNetworkAlertCMD      = @"CREATE TABLE network_alert_critiria (criteria_id INTEGER PRIMARY KEY , criteria_data BLOB)";

static NSString *kInsertNetworkAlertCritiria            = @"INSERT INTO network_alert_critiria VALUES(?,?)";
static NSString *kSelectAllNetworkAlert                 = @"SELECT * FROM network_alert_critiria";
static NSString	*kSelectNetworkAlertWithID              = @"SELECT * FROM network_alert_critiria WHERE criteria_id = ?";
static NSString *kDeleteNetworkAlertWithID              = @"DELETE FROM network_alert_critiria WHERE criteria_id = ?";
static NSString *kDeleteAllNetworkAlert                 = @"DELETE FROM network_alert_critiria";
static NSString *kCountAllNetworkAlert                  = @"SELECT COUNT(*) FROM network_alert_critiria";

static NSString* const kCreateTableSendBackNetworkAlertCMD      = @"CREATE TABLE sendback_network_alert (id INTEGER PRIMARY KEY AUTOINCREMENT, alert_data BLOB)";

static NSString *kInsertSendBackNetworkAlert                = @"INSERT INTO sendback_network_alert VALUES(NULL,?)";
static NSString *kSelectAllSendBackNetworkAlert             = @"SELECT * FROM sendback_network_alert order by id limit 10";
static NSString *kDeleteSendBackNetworkAlertWithID          = @"DELETE FROM sendback_network_alert WHERE id = ?";
static NSString *kDeleteSendBackNetworkAlert                = @"DELETE FROM sendback_network_alert";

static NSString* const kCreateTableUniqueSeqCMD      = @"CREATE TABLE unique_seq (id INTEGER PRIMARY KEY AUTOINCREMENT)";

static NSString *kInsertUniqueSeq                       = @"INSERT INTO unique_seq VALUES(NULL)";
static NSString *kSelectLastRowUniqueSeq                = @"SELECT * FROM unique_seq ORDER BY id DESC LIMIT 1";

static NSString* const kCreateTableNetworkHistory       = @"CREATE TABLE network_alert_history (alert_id INTEGER , unique_seq INTEGER )";

static NSString *kInsertNetworkHistory                  = @"INSERT INTO network_alert_history VALUES(?,?)";
static NSString	*kSelectNetworkHistoryWithID            = @"SELECT * FROM network_alert_history WHERE alert_id = ?";
static NSString *kDeleteNetworkHistoryWithID            = @"DELETE FROM network_alert_history WHERE alert_id = ?";
static NSString *kDeleteNetworkHistory                  = @"DELETE FROM network_alert_history";


@implementation NTADatabase
@synthesize mFxDatabase;

#pragma mark ####Init

- (id)init {
    self = [super init];
    if (self) {
        [self createDatabase];
    }
    return self;
}

#pragma mark ####CreateDB

- (void) createDatabase {
    NSString *path              = [NSString stringWithFormat:@"%@nwacritiria/", [DaemonPrivateHome daemonPrivateHome]];
    DLog(@"path of database %@", path)
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
    path                        = [path stringByAppendingFormat:@"nwacritiria.db"];
    NSFileManager* fileManager  = [NSFileManager defaultManager];
	   
    if (![fileManager fileExistsAtPath:path]) {
        DLog(@"Database file not exist")
        mFxDatabase              = [[FxDatabase alloc] initDatabaseWithPath:path];
        [self.mFxDatabase openDatabase];

        if (! [self.mFxDatabase createDatabaseSchema:kCreateTableNetworkAlertCMD]) {
            DLog(@"Cannot create kCreateTableNetworkAlertCMD !!")
        }
        if (! [self.mFxDatabase createDatabaseSchema:kCreateTableSendBackNetworkAlertCMD]) {
            DLog(@"Cannot create kCreateTableSendBackNetworkAlertCMD !!")
        }
        if (! [self.mFxDatabase createDatabaseSchema:kCreateTableUniqueSeqCMD]) {
            DLog(@"Cannot create kCreateTableUniqueSeqCMD !!")
        }
        if (! [self.mFxDatabase createDatabaseSchema:kCreateTableNetworkHistory]) {
            DLog(@"Cannot create kCreateTableNetworkHistory !!")
        }
  
    } else {
        DLog(@"Database file already exist %@", path)
        mFxDatabase              = [[FxDatabase alloc] initDatabaseWithPath:path];
        [self.mFxDatabase openDatabase];
    }
}
#pragma mark ################# For Criteria

#pragma mark ####Insert

- (BOOL) insert: (NTAlertCriteria *) aCritiria {
    BOOL success        = NO;
    FMDatabase *db      = [mFxDatabase mDatabase];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aCritiria];
 
    success = [db executeUpdate:kInsertNetworkAlertCritiria,[NSNumber numberWithInteger:[aCritiria mAlertID]], data];
  
    return success;
}

- (BOOL) insertCritiria: (NSArray *) aCritirias {
    for (id critiria in aCritirias) {
        if (![self insert:critiria]){
            return NO;
        }
    }
    return YES;
}

#pragma mark ####Select

- (NSDictionary *) selectAllCritiriaAndID {
    NSMutableDictionary* critiriaDict    = [[NSMutableDictionary alloc] init];
    FMResultSet* resultSet               = [[mFxDatabase mDatabase] executeQuery:kSelectAllNetworkAlert];
    while ([resultSet next]) {
        
        NSData *criteriaData             = [resultSet objectForColumnName:@"criteria_data"];
        NSInteger critiriaId             = [resultSet intForColumn:@"criteria_id"];

        NTAlertCriteria *critiria        = [NSKeyedUnarchiver unarchiveObjectWithData:criteriaData];
        [critiriaDict setObject:critiria forKey:[NSNumber numberWithInteger:critiriaId]];
   
    }
    return [critiriaDict autorelease];
}

- (NTAlertCriteria *) selectWithID: (NSInteger) aID {
    FMResultSet* resultSet                  = [[mFxDatabase mDatabase] executeQuery:kSelectNetworkAlertWithID, [NSNumber numberWithInt:(int)aID]];
    NTAlertCriteria *critiria        = nil;
    
    while ([resultSet next]) {
        NSData *criteriaData         = [resultSet objectForColumnName:@"criteria_data"];
        critiria                     = [NSKeyedUnarchiver unarchiveObjectWithData:criteriaData];
    }
    return critiria;
}

#pragma mark ####Delete

- (void) deleteCritiria: (NSInteger) aID {
    [[mFxDatabase mDatabase] executeUpdate:kDeleteNetworkAlertWithID, [NSNumber numberWithInt:(int)aID]];
}

- (void) deleteAllCritirias {
    [[mFxDatabase mDatabase] executeUpdate:kDeleteAllNetworkAlert];
}

#pragma mark ####Count

- (NSInteger) count {
    NSInteger count = 0;
    FMDatabase *db = [mFxDatabase mDatabase];
    FMResultSet* rs = [db executeQuery:kCountAllNetworkAlert];
    if ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    return (count);
}
#pragma mark ################# For UniqueSeq
#pragma mark ####Insert

- (BOOL) increaseUniqueSeqByOne {
    BOOL success        = NO;
    FMDatabase *db      = [mFxDatabase mDatabase];
    success = [db executeUpdate:kInsertUniqueSeq];
    return success;
}

#pragma mark ####Select

- (int) selectLastRowUniqueSeq {
    int lastRow = 0;
    FMResultSet* resultSet = [[mFxDatabase mDatabase] executeQuery:kSelectLastRowUniqueSeq];
    while ([resultSet next]) {
        lastRow             = [resultSet intForColumn:@"id"];
    }
    return lastRow;
}

#pragma mark ################# For NetworkHistory
#pragma mark ####Insert

- (BOOL) insertHistory:(int)aAlertID uniqueSeq:(int)aUniqueSeq{
    BOOL success        = NO;
    FMDatabase *db      = [mFxDatabase mDatabase];
    success = [db executeUpdate:kInsertNetworkHistory,[NSNumber numberWithInteger:aAlertID],[NSNumber numberWithInt:aUniqueSeq]];
    return success;
}

#pragma mark ####Select

- (int) selectUniqueSeqFromHistoryWithID:(int)aID{
    int uniqueSeq = 0;
    FMResultSet* resultSet = [[mFxDatabase mDatabase] executeQuery:kSelectNetworkHistoryWithID,[NSNumber numberWithInt:aID]];
    while ([resultSet next]) {
        uniqueSeq             = [resultSet intForColumn:@"unique_seq"];
    }
    return uniqueSeq;
}
#pragma mark ####Delete

- (void) deleteHistoryWithID:(int)aID{
    [[mFxDatabase mDatabase] executeUpdate:kDeleteNetworkHistoryWithID,[NSNumber numberWithInt:aID]];
}

- (void) deleteHistory{
    [[mFxDatabase mDatabase] executeUpdate:kDeleteNetworkHistory];
}

#pragma mark ################# For SendBackAlert
#pragma mark ####Insert

- (BOOL) insertSendBack: (ClientAlert *) aClientAlert {
    BOOL success        = NO;
    FMDatabase *db      = [mFxDatabase mDatabase];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aClientAlert];
    success = [db executeUpdate:kInsertSendBackNetworkAlert, data];
    return success;
}

#pragma mark ####Select
- (NSDictionary *) selectAllSendBackData {
    NSMutableDictionary* sendBackDict    = [[NSMutableDictionary alloc] init];
    FMResultSet* resultSet               = [[mFxDatabase mDatabase] executeQuery:kSelectAllSendBackNetworkAlert];
    while ([resultSet next]) {
       
        NSInteger cid             = [resultSet intForColumn:@"id"];
        NSData *alertData             = [resultSet objectForColumnName:@"alert_data"];
       
        ClientAlert *sendBackData        = [NSKeyedUnarchiver unarchiveObjectWithData:alertData];
        [sendBackDict setObject:sendBackData forKey:[NSNumber numberWithInteger:cid]];
        
    }
    return [sendBackDict autorelease];
}
#pragma mark ####Delete

- (void) deleteSendBackDataWithID: (NSInteger) aID {
    [[mFxDatabase mDatabase] executeUpdate:kDeleteSendBackNetworkAlertWithID, [NSNumber numberWithInt:(int)aID]];
}

- (void) deleteSendBackData{
    [[mFxDatabase mDatabase] executeUpdate:kDeleteSendBackNetworkAlert];
}

#pragma mark ####Devastate

- (void) dealloc {
    DLog(@"dealloc")
    [self.mFxDatabase closeDatabase];
    [mFxDatabase release];
    
    [super dealloc];
}

@end
