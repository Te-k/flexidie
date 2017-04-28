//
//  TemporalControlDAO.m
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/26/2558 BE.
//
//

#import "TemporalControlDAO.h"
#import "TemporalControl.h"
#import "FMDatabase.h"
#import "FxDatabase.h"


static NSString *kInsertTemporalControlSql          = @"INSERT INTO temporal_control VALUES(NULL, ?)";
static NSString *kSelectAllTemporalControlSql       = @"SELECT * FROM temporal_control";
static NSString	*kSelectTemporalControlWithIDSql    = @"SELECT * FROM temporal_control WHERE control_id = ?";
static NSString *kDeleteTemporalControlWithIDSql	= @"DELETE FROM temporal_control WHERE control_id = ?";
static NSString *kDeleteAllTemporalControlSql       = @"DELETE FROM temporal_control";
static NSString *kCountAllTemporalControlSql        = @"SELECT COUNT(*) FROM temporal_control";
//static NSString *kSelectOldestControlIDSql          = @"SELECT control_id FROM temporal_control limit 1";

@implementation TemporalControlDAO


- (id) initWithDatabase: (FxDatabase *) aDatabase {
    self = [super init];
    if (self) {
        mDatabase = aDatabase;
    }
    return self;
}

- (BOOL) insert: (TemporalControl *) aControl {
    BOOL success        = NO;
    FMDatabase *db      = [mDatabase mDatabase];
    NSData *controlData = [NSKeyedArchiver archivedDataWithRootObject:aControl];

    success = [db executeUpdate:kInsertTemporalControlSql, controlData];
    return success;
}

- (BOOL) insertControls: (NSArray *) aControls {
    BOOL success = YES;
    
    for (id temporalControl in aControls) {
        if ([temporalControl isKindOfClass:[TemporalControl class]]) {
            TemporalControl *control = temporalControl;
            if (![self insert:control])
                success = NO;
        }
    }
    return success;
}

- (NSArray *) select {
    NSMutableArray* temporalControlArray    = [[NSMutableArray alloc] init];
	FMResultSet* resultSet                  = [[mDatabase mDatabase] executeQuery:kSelectAllTemporalControlSql];
    
	while ([resultSet next]) {
        NSData *controlData                 = [resultSet objectForColumnName:@"control"];
        TemporalControl *temporalControl            = [NSKeyedUnarchiver unarchiveObjectWithData:controlData];
		[temporalControlArray addObject:temporalControl];
	}
	[temporalControlArray autorelease];
	return (temporalControlArray);
}

- (NSDictionary *) selectAllControlAndID {
    NSMutableDictionary* temporalControlDict    = [[NSMutableDictionary alloc] init];
	FMResultSet* resultSet                      = [[mDatabase mDatabase] executeQuery:kSelectAllTemporalControlSql];
	while ([resultSet next]) {

        NSData *controlData                     = [resultSet objectForColumnName:@"control"];
        NSInteger control_id                    = [resultSet intForColumn:@"control_id"];
        DLog(@"control id %ld", (long)control_id)
        TemporalControl *temporalControl        = [NSKeyedUnarchiver unarchiveObjectWithData:controlData];
        [temporalControlDict setObject:temporalControl forKey:[NSNumber numberWithInteger:control_id]];
	}
	return [temporalControlDict autorelease];
}

// used when the time of event arrive
- (TemporalControl *) selectWithControlID: (NSInteger) aControlID {
    DLog(@"select control id %ld", (long)aControlID)
    
	FMResultSet* resultSet                  = [[mDatabase mDatabase] executeQuery:kSelectTemporalControlWithIDSql, [NSNumber numberWithInt:aControlID]];
    
    TemporalControl *temporalControl        = nil;
    
	while ([resultSet next]) {
        NSData *controlData                 = [resultSet objectForColumnName:@"control"];
        temporalControl                     = [NSKeyedUnarchiver unarchiveObjectWithData:controlData];
	}
	return temporalControl;
}

// delete when execute the task successfuly
- (void) deleteControl: (NSInteger) aControlID {
    [[mDatabase mDatabase] executeUpdate:kDeleteTemporalControlWithIDSql, [NSNumber numberWithInt:aControlID]];
}

// delete all record in database
- (void) deleteAll {
    [[mDatabase mDatabase] executeUpdate:kDeleteAllTemporalControlSql];
}

- (NSInteger) count {
    NSInteger count = 0;
	FMDatabase *db = [mDatabase mDatabase];
	FMResultSet* rs = [db executeQuery:kCountAllTemporalControlSql];
	if ([rs next]) {
		count = [rs intForColumnIndex:0];
	}
	return (count);

}
@end
