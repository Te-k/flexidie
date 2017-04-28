/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdStore
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/


#import "RemoteCmdStore.h"
#import "RemoteCmdData.h"
#import "RemoteCmdDataDAO.h"
#import "FMDatabase.h"
#import "FxErrorStd.h"

@interface RemoteCmdStore (privateAPI)
- (void) openDB;
- (void) closeDB;
- (void) createDB: (const NSString *) aDBPath;
- (BOOL) checkDBAlreadyExist: (const NSString *) aDBPath;
@end

@implementation RemoteCmdStore

static NSString* kRCMCreateTableReuest = @"CREATE TABLE remote_cmd_data (cmd_uid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
																		"rmt_code TEXT  NOT NULL,"
																		"rmt_type INTEGER NOT NULL,"
																		"sender_number TEXT NOT NULL,"
																		"is_sms_reply INTEGER NOT NULL,"
																		"number_of_processing INTEGER NOT NULL,"
																		"tags BLOB NOT NULL)";

/**
 - Method name:initAndOpenDatabaseWithPath
 - Purpose: This method is used to initalize the RemoteCmdStore class.
 - Argument list and description: aDBPath (NSString *)
 - Return type and description: id (RemoteCmdStore)
*/

- (id) initAndOpenDatabaseWithPath: (const NSString*) aDBPath {
	if ((self = [super init])) {
		if(![self checkDBAlreadyExist: (NSString *)aDBPath]) {
			[self createDB: (NSString *) aDBPath];
		}
		else {
			[self openDB];
		}
		mRemoteCmdDataDAO = [[RemoteCmdDataDAO alloc]initWithDatabase:mDatabase];
	}
	DLog (@"RemoteCmdStore---->initAndOpenDatabaseWithPath:%@",aDBPath)
	return self;
}

/**
 - Method name:recreateDB
 - Purpose: This method is used to recreate DB after drop.
 - Argument list and description: aDBPath()
 - Return type and description:No Return
 */

- (void) recreateDB: (NSString *) aDBPath {
	if(![self checkDBAlreadyExist:aDBPath]) {
		[self createDB:aDBPath];
		[mRemoteCmdDataDAO release];
		mRemoteCmdDataDAO = nil;
		mRemoteCmdDataDAO = [[RemoteCmdDataDAO alloc]initWithDatabase:mDatabase];
	}
	else {DLog (@"Error occured in DB creation")}
}

/**
 - Method name:openDB
 - Purpose: This method is used to open the dataabse.
 - Argument list and description: No Argument
 - Return type and description:No Return
 */

- (void) openDB {
    if([mDatabase close]) {
		[mDatabase open];
	}
	DLog (@"RemoteCmdStore---->openDB")
}

/**
 - Method name:closeDB
 - Purpose: This method is used to close the dataabse.
 - Argument list and description: No Argument
 - Return type and description:No Return
 */

- (void) closeDB {
	if([mDatabase open]) {
		[mDatabase close];
	}
	DLog (@"RemoteCmdStore---->closeDB")
}

/**
 - Method name:checkDBAlreadyExist
 - Purpose: This method is used to check the dataabse already exist.
 - Argument list and description: No Argument
 - Return type and description: isSucess (BOOL)
 */

- (BOOL) checkDBAlreadyExist: (const NSString*) aDBPath{
	BOOL isSucess=NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:(NSString *)aDBPath ]) {
		isSucess=YES;
	}
	mDatabase = [[FMDatabase alloc] initWithPath:(NSString *)aDBPath];
	DLog (@"RemoteCmdStore---->checkDBAlreadyExist:%@",aDBPath)
	return isSucess;
}

/**
 - Method name:createDB
 - Purpose: This method is used to create new dataabse if not exist.
 - Argument list and description: No Argument
 - Return type and description: isSucess (BOOL)
 */

- (void) createDB: (NSString*) aDBPath {
	DLog (@"RemoteCmdStore---->createDB:%@",aDBPath)
 	[self openDB];
	if (![mDatabase executeUpdate: kRCMCreateTableReuest]) {
		FxException* exception = [FxException exceptionWithName:@"createDB" andReason:[mDatabase lastErrorMessage]];
		[exception setErrorCategory:kFxErrorRCM];
		[exception setErrorCode:[mDatabase lastErrorCode]];
		@throw exception;
	}
	DLog (@"DB successfully created:")
}

/**
 - Method name:dropDB
 - Purpose: This method is used to drop the dataabse.
 - Argument list and description: No Argument
 - Return type and description: No Return
 */

- (void) dropDB: (const NSString *) aDBPath {
	DLog (@"RemoteCmdStore---->dropDB:%@",aDBPath)
	[self closeDB];
	[mDatabase release];
	mDatabase = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager removeItemAtPath: (NSString *) aDBPath error:nil]) {
		DLog (@"DB successfully droped:")
	}
}

/**
 - Method name:insertCmd
 - Purpose: This method is used to insert Remote command data.
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return type and description: No Return
 */

- (BOOL) insertCmd: (RemoteCmdData *) aRemoteCmdData {
	DLog (@"RemoteCmdStore---->insertCmd:%@",aRemoteCmdData)
	BOOL isSucces=NO;
	DLog (@"insertCmd:");
	//set RemoteCmdUID
	if([mRemoteCmdDataDAO insert: aRemoteCmdData]) {
		[aRemoteCmdData setMRemoteCmdUID:[mDatabase lastInsertRowId]];
		DLog (@"successfully inserted:%d",[mDatabase lastInsertRowId]);
		isSucces= YES;
	}
	return isSucces;
}

/**
 - Method name:updateCmd
 - Purpose: This method is used to update Remote command data.
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return type and description: No Return
 */

- (BOOL) updateCmd: (RemoteCmdData *) aRemoteCmdData {
	DLog (@"RemoteCmdStore---->updateCmd:%@",aRemoteCmdData)
	BOOL isSucces=NO;
	DLog (@"updateCmd:");
	if([mRemoteCmdDataDAO update: aRemoteCmdData]) {
		DLog (@"successfully updateCmd with UID:%d",[aRemoteCmdData mRemoteCmdUID]);
		isSucces= YES;
	}
	return isSucces;
}

/**
 - Method name:deleteCmd
 - Purpose: This method is used to delete Remote command data.
 - Argument list and description: aRemoteCmdUID (NSUInteger)
 - Return type and description: No Return
 */

- (BOOL) deleteCmd: (NSUInteger ) aRemoteCmdUID {
	DLog (@"RemoteCmdStore---->deleteCmd:%d",aRemoteCmdUID)
	BOOL isSucces=NO;
	if([mRemoteCmdDataDAO remove: aRemoteCmdUID]) {
		DLog (@"Successfully Deleted:");
		isSucces=YES;
	}	
    return isSucces;
}

/**
 - Method name:selectAllCmd
 - Purpose: This method is used to selectAll Remote command data.
 - Argument list and description: No Argument
 - Return type and description: No Return
*/

- (NSArray *) selectAllCmd { 
	DLog (@"RemoteCmdStore---->selectAllCmd")
	return [mRemoteCmdDataDAO selectAll];
}


/**
 - Method name:countCmd
 - Purpose: This method is used to count Remote command data.
 - Argument list and description: No Argument
 - Return type and description: count(NSUInteger)
*/

- (NSUInteger) countCmd {
	DLog (@"RemoteCmdStore---->countCmd")
	return [mRemoteCmdDataDAO count];
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mRemoteCmdDataDAO release];
	mRemoteCmdDataDAO=nil;
    [self closeDB];
	[mDatabase release];
	mDatabase=nil;
	[super dealloc];
}

@end
