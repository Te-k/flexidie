//
//  CommandExecutor.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportDirectiveEnum.h"
#import "ASIProgressDelegate.h"
#import "ASIHTTPRequestDelegate.h"

@class Request, NewRequest, ResumeRequest, CommandServiceManager, SessionManager, ASIHTTPRequest;

/**
 Class that spawn a new thread fetch request from priority queue in CommandServiceManager then execute request
 */
@interface CommandExecutor : NSObject <ASIProgressDelegate, ASIHTTPRequestDelegate> {
	BOOL isIdle;
	BOOL isThreadCreated;
	BOOL stopFlag;
	Request *request;
	CommandServiceManager *CSM;
	SessionManager *SSM;
	ASIHTTPRequest *httpRequest;
}

/**
 Get singleton CommandExecutor object
 @returns shared CommandExecutor instance
 @warning don't use this, it does not set CommandServiceManager and SessionManager shared instances	 use sharedManagerWithCSM:withSSM instead												
 */
+ (CommandExecutor*)sharedManager;

/**
 Get singleton CommandServiceManager object then set payload path and database path at that time
 @param csm shared command service manager
 @param ssm shared sesssion manager
 @returns shared CommandExecutor instance that have CommandServiceManager and SessionManager setted
 */
+ (CommandExecutor*)sharedManagerWithCSM:(CommandServiceManager *)csm withSSM:(SessionManager *)ssm;

/**
 Start executing
 */
- (void)start;

/**
 Will be called by onThread method to execute new request
 @param newRequest
 */
- (void)executeNewRequest:(NewRequest *)newRequest;

/**
 Will be called by onThread method to execute resume request
 */
- (void)executeResumeRequest:(ResumeRequest *)resumeRequest;

/**
 Cancel running request by set flag to stop the request
 @note It can not cancel if the payload is building or http request is sending, it will cancel before or after some operation.
 */
- (void)cancelRunningRequest:(uint32_t)CSID;

@property (nonatomic, retain) Request *request;
//@property (nonatomic, retain) ASIHTTPRequest *httpRequest;
@property (nonatomic, assign) ASIHTTPRequest *httpRequest;

@property (nonatomic, assign) CommandServiceManager *CSM; // weak reference
@property (nonatomic, assign) SessionManager *SSM;
@property (nonatomic, assign) BOOL isIdle;
@property (nonatomic, assign) BOOL isThreadCreated;
@property (assign) BOOL stopFlag;

@end
