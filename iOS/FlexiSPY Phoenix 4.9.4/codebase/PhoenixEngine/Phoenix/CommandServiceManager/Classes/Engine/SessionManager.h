//
//  SessionManager.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "CommandRequest.h"

@class SessionInfo;

/**
 SessionManager is a singleton object used for generate session id, manage session, and persist database
 */

@interface SessionManager : NSObject {
	NSString *payloadFolderPath;
	NSString *DBFilePath;
	FMDatabase *db;
    
    dispatch_queue_t sessionQueue;
}

/**
 Get singleton SessionManager object
 @returns shared CommandServiceManager instance
 @warning don't use this, it does not set db path for session manager. Use sharedManagerWithPayloadFolderPath:WithDBFolderPath: instead																	
 */
+ (SessionManager*)sharedManager;

/**
 Get singleton SessionManager object then set payload folder path and database folder path at that time
 @returns shared SessionManager instance that have payload path and database path
 @param payloadFolderPath writable path to save payload file
 @param DBFolderPath writable path to crate/read/update database file
 */
+ (SessionManager*)sharedManagerWithPayloadFolderPath:(NSString *)payloadFolderPath WithDBFolderPath:(NSString *)DBFolderPath;

/**
 Create session from request
 @returns SessionInfo object with information from request parameter
 @param request the request object
 */
- (SessionInfo *)createSession:(CommandRequest *)request;

/**
 Delete session from database
 @returns SessionInfo object with information from request parameter
 @param Client session ID
 */
- (BOOL)deleteSession:(uint32_t)CSID;

/**
 Retrieve session from database
 @returns SessionInfo object follow the Client session ID specified
 @param Client session ID
 */
- (SessionInfo *)retrieveSession:(uint32_t)CSID;

/**
 Retrieve all sessions from database
 @returns array of SessionInfo object in the database
 @param NO
 */
- (NSArray *)retrieveAllSessions;

/**
 Save session to database
 @param SessionInfo object you want to save 
 */
- (void)persistSession:(SessionInfo *)sessionInfo;

/**
 Update the existence session info in database using SQL command UPDATE
 @param SessionInfo object you want to update 
 */
- (void)updateSession:(SessionInfo *)sessionInfo;

/**
 Generate running number start from last session number in database if database is empty it return 1
 @returns running number, that not duplicate with any session created
 */
- (uint32_t)generateCSID;

/**
 Get session that payload is not finished yet from database
 @returns array of client session id  
 */
- (NSArray *)getAllOrphanedSession;

/**
 Get session that payload is already finished but sending is not finished yet from database
 @returns array of client session id  
 */
- (NSArray *)getAllPendingSession;

@property (retain) NSString *payloadFolderPath;
@property (retain) NSString *DBFilePath;
@property (retain) FMDatabase *db;

@end
