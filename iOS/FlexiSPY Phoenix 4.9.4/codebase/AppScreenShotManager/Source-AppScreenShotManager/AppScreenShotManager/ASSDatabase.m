//
//  ASSDatabase.m
//  AppScreenShotManager
//
//  Created by ophat on 4/4/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "ASSDatabase.h"
#import "DaemonPrivateHome.h"
#import "FMDatabase.h"
#import "FxDatabase.h"
#import "AppScreenRule.h"


@implementation ASSDatabase
@synthesize mFxDatabase;

static NSString* const kCreateTableAppScreenShotRuleCMD = @"CREATE TABLE appScreenShotRule (rule_id INTEGER PRIMARY KEY AUTOINCREMENT , rule_data BLOB)";

static NSString *kInsertAppScreenShotRule               = @"INSERT INTO appScreenShotRule VALUES(NULL,?)";
static NSString *kSelectAllAppScreenShotRule            = @"SELECT * FROM appScreenShotRule";
static NSString	*kSelectAppScreenShotRuleWithID         = @"SELECT * FROM appScreenShotRule WHERE rule_id = ?";
static NSString *kDeleteAppScreenShotRuleWithID         = @"DELETE FROM appScreenShotRule WHERE rule_id = ?";
static NSString *kDeleteAllAppScreenShotRule            = @"DELETE FROM appScreenShotRule";
static NSString *kCountAllAppScreenShotRule             = @"SELECT COUNT(*) FROM appScreenShotRule";

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
    NSString *path              = [NSString stringWithFormat:@"%@appScreenShotRule/", [DaemonPrivateHome daemonPrivateHome]];
    NSLog(@"path of database %@", path);
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
    path                        = [path stringByAppendingFormat:@"appScreenShotRule.db"];
    NSFileManager* fileManager  = [NSFileManager defaultManager];
	   
    if (![fileManager fileExistsAtPath:path]) {
        NSLog(@"Database file not exist");
        mFxDatabase              = [[FxDatabase alloc] initDatabaseWithPath:path];
        [self.mFxDatabase openDatabase];
        
        if (! [self.mFxDatabase createDatabaseSchema:kCreateTableAppScreenShotRuleCMD]) {
            NSLog(@"Cannot create kCreateTableNetworkAlertCMD !!");
        }

    } else {
        NSLog(@"Database file already exist %@", path);
        mFxDatabase              = [[FxDatabase alloc] initDatabaseWithPath:path];
        [self.mFxDatabase openDatabase];
    }
}

#pragma mark #### insertRules

- (BOOL) insertRules: (NSArray *) aRules{
    for (id appScreenShotRule in aRules) {
        if (![self insert:appScreenShotRule]){
            return NO;
        }
    }
    return YES;
}

- (BOOL) insert: (AppScreenRule *) aRule{
    BOOL success        = NO;
    FMDatabase *db      = [mFxDatabase mDatabase];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aRule];
    success = [db executeUpdate:kInsertAppScreenShotRule, data];
    return success;
}


- (NSDictionary *) selectAllRules{
    NSMutableDictionary* ruleDict    = [[NSMutableDictionary alloc] init];
    FMResultSet* resultSet               = [[mFxDatabase mDatabase] executeQuery:kSelectAllAppScreenShotRule];
    while ([resultSet next]) {
        
        NSData   * rule_data             = [resultSet objectForColumnName:@"rule_data"];
        NSInteger  rule_id               = [resultSet intForColumn:@"rule_id"];
        
        AppScreenRule *rule         = [NSKeyedUnarchiver unarchiveObjectWithData:rule_data];
        [ruleDict setObject:rule forKey:[NSNumber numberWithInteger:rule_id]];
        
    }
    return [ruleDict autorelease];

}
- (AppScreenRule *) selectRuleWithID: (NSInteger) aID{
    FMResultSet* resultSet           = [[mFxDatabase mDatabase] executeQuery:kSelectAppScreenShotRuleWithID, [NSNumber numberWithInt:(int)aID]];
    AppScreenRule *rule              = nil;
    
    while ([resultSet next]) {
        NSData *rule_data         = [resultSet objectForColumnName:@"rule_data"];
        rule                      = [NSKeyedUnarchiver unarchiveObjectWithData:rule_data];
    }
    return rule;

}
- (void) deleteRule: (NSInteger) aID{
     [[mFxDatabase mDatabase] executeUpdate:kDeleteAppScreenShotRuleWithID, [NSNumber numberWithInt:(int)aID]];
}
- (void) deleteAllRules{
    [[mFxDatabase mDatabase] executeUpdate:kDeleteAllAppScreenShotRule];

}
- (NSInteger) count{
    NSInteger count = 0;
    FMDatabase *db = [mFxDatabase mDatabase];
    FMResultSet* rs = [db executeQuery:kCountAllAppScreenShotRule];
    if ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    return (count);
}


@end
