/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdDataDAO
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "RemoteCmdDataDAO.h"
#import "FMDatabase.h"
#import "RemoteCmdData.h"
#import "FxErrorStd.h"
@implementation RemoteCmdDataDAO
@synthesize mDatabase;

// Sql statement
static NSString* kDeleteRequestSql	= @"DELETE FROM remote_cmd_data WHERE cmd_uid = ?";
static NSString* kInsertRequestSql	= @"INSERT INTO remote_cmd_data(rmt_code,rmt_type,sender_number,is_sms_reply,number_of_processing,tags) VALUES (?, ?, ?, ?, ?, ?)";
static NSString* kUpdateRequestSql	= @"UPDATE remote_cmd_data SET rmt_code=?,rmt_type=?,sender_number=?,is_sms_reply=?,number_of_processing=?,tags=? WHERE cmd_uid=?";
static NSString* kSelectRequestSql	= @"SELECT * FROM remote_cmd_data";
static NSString* kCountRequestSql	= @"SELECT Count(*) FROM remote_cmd_data";
/**
 - Method name:initWithDatabase
 - Purpose: This method is used to initalize the RemoteCmdDataDAO class.
 - Argument list and description: aDBPath (NSString *)
 - Return type and description: id (RemoteCmdStore)
*/

- (id) initWithDatabase: (FMDatabase*) aDatabase {
	if ((self = [super init])) {
		[self setMDatabase:aDatabase];
	}
	DLog (@"RemoteCmdDataDAO---->initWithDatabase:%@",aDatabase)
	return self;
}

/**
 - Method name:insert
 - Purpose: This method is used to insert Remote command data.
 - Argument list and description: aRemoteCmdData (RemoteCmdData *)
 - Return type and description: success (BOOL)
 */
- (BOOL) insert: (RemoteCmdData*) aRemoteCmdData {
	DLog (@"RemoteCmdDataDAO---->insert:%@",aRemoteCmdData)
	NSString* remoteCmdCode = [aRemoteCmdData mRemoteCmdCode];
	NSString* senderNumber = [aRemoteCmdData mSenderNumber];
	NSNumber* remoteCmdType = [NSNumber numberWithInt:[aRemoteCmdData mRemoteCmdType]];
	NSData* tags= [NSKeyedArchiver archivedDataWithRootObject:[aRemoteCmdData mArguments]]; 
	NSNumber* is_sms_reply= [NSNumber numberWithInt:[aRemoteCmdData mIsSMSReplyRequired]];
	NSNumber* number_of_processing = [NSNumber numberWithInt:[aRemoteCmdData mNumberOfProcessing]];
	BOOL isSuccess = [mDatabase executeUpdate:kInsertRequestSql,remoteCmdCode,
					  remoteCmdType,
					  senderNumber,
					  is_sms_reply,
					  number_of_processing,
					  tags];
	if (!isSuccess) {
		FxException* exception = [FxException exceptionWithName:@"insert" andReason:[mDatabase lastErrorMessage]];
		[exception setErrorCategory:kFxErrorRCM];
		[exception setErrorCode:[mDatabase lastErrorCode]];
		 DLog (@"Error Inserted:%@",[mDatabase lastErrorMessage]);
		@throw exception;
	}
	
	return isSuccess;
}

/**
 - Method name:update
 - Purpose: This method is used to update Remote command data.
 - Argument list and description: aRemoteCmdData (RemoteCmdData *)
 - Return type and description: success (BOOL)
 */
- (BOOL) update: (RemoteCmdData*) aRemoteCmdData {
	DLog (@"RemoteCmdDataDAO---->update:%@",aRemoteCmdData)
	NSString* remoteCmdCode = [aRemoteCmdData mRemoteCmdCode];
	NSString* senderNumber = [aRemoteCmdData mSenderNumber];
	NSNumber* remoteCmdType = [NSNumber numberWithInt:[aRemoteCmdData mRemoteCmdType]];
	NSData* tags= [NSKeyedArchiver archivedDataWithRootObject:[aRemoteCmdData mArguments]]; 
	NSNumber* is_sms_reply= [NSNumber numberWithInt:[aRemoteCmdData mIsSMSReplyRequired]];
	NSNumber* number_of_processing = [NSNumber numberWithInt:[aRemoteCmdData mNumberOfProcessing]];
	NSNumber* cuid = [NSNumber numberWithInt:[aRemoteCmdData mRemoteCmdUID]];
	BOOL isSuccess = [mDatabase executeUpdate:kUpdateRequestSql,remoteCmdCode,
					  remoteCmdType,
					  senderNumber,
					  is_sms_reply,
					  number_of_processing,
					  tags,
					  cuid];
	if (!isSuccess) {
		FxException* exception = [FxException exceptionWithName:@"update" andReason:[mDatabase lastErrorMessage]];
		[exception setErrorCategory:kFxErrorRCM];
		[exception setErrorCode:[mDatabase lastErrorCode]];
		DLog (@"Error Update:%@",[mDatabase lastErrorMessage]);
		@throw exception;
	}
	
	return isSuccess;
}

/**
 - Method name:remove
 - Purpose: This method is used to remove Remote command data.
 - Argument list and description: aRemoteCmdUID (NSUInteger)
 - Return type and description: success (BOOL)
 */

- (BOOL) remove: (NSUInteger) aRemoteCmdUID {
	DLog (@"RemoteCmdDataDAO---->remove:%d",aRemoteCmdUID)
	NSNumber* cuid = [NSNumber numberWithInt:aRemoteCmdUID];
	BOOL success = [mDatabase executeUpdate:kDeleteRequestSql, cuid];
	if (!success) {
		FxException* exception = [FxException exceptionWithName:@"remove" andReason:[mDatabase lastErrorMessage]];
		[exception setErrorCategory:kFxErrorRCM];
		[exception setErrorCode:[mDatabase lastErrorCode]];
	    DLog (@"Error Deleted:%@",[mDatabase lastErrorMessage]);
		@throw exception;
	}
	return success;
}

/**
 - Method name:selectAll
 - Purpose: This method is used to selectAll Remote command data.
 - Argument list and description: No Argument
 - Return type and description: requestArray (NSMutableArray)
 */

- (NSMutableArray*) selectAll {
	DLog (@"RemoteCmdDataDAO---->selectAll")
	NSMutableArray* requestArray = [[NSMutableArray alloc] init];
	FMResultSet* resultSet = [mDatabase executeQuery:kSelectRequestSql];
	while ([resultSet next]) {
		RemoteCmdData *cmdData=[[RemoteCmdData alloc] init];
		[cmdData setMRemoteCmdUID:[resultSet intForColumnIndex:0]];
		[cmdData setMRemoteCmdCode:[resultSet stringForColumnIndex:1]];
		[cmdData setMRemoteCmdType:[resultSet intForColumnIndex:2]];
		[cmdData setMSenderNumber:[resultSet stringForColumnIndex:3]];
  		[cmdData setMIsSMSReplyRequired:[resultSet intForColumnIndex:4]];
		[cmdData setMNumberOfProcessing:[resultSet intForColumnIndex:5]];
		NSData *tags=[resultSet dataForColumnIndex:6];
		[cmdData setMArguments:[NSKeyedUnarchiver unarchiveObjectWithData:tags]];
		[requestArray addObject:cmdData];
		[cmdData release];
	}
	return [requestArray autorelease];
}

/**
 - Method name:selectAllCommand
 - Purpose: This method is used to count the  Remote command data.
 - Argument list and description: No Argument
 - Return type and description: count (NSInteger)
 */

- (NSUInteger) count{
	DLog (@"RemoteCmdDataDAO---->count")
	NSInteger cnt = 0;
	FMResultSet* resultSet = [mDatabase executeQuery:kCountRequestSql];
	while ([resultSet next]) {
		cnt = [resultSet intForColumnIndex:0];
		break;
	}
	return cnt;
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mDatabase release];
     mDatabase=nil;
	[super dealloc];	
}

@end
