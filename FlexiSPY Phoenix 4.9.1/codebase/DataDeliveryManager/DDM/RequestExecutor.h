//
//  RequestExecutor.h
//  DDM
//
//  Created by Makara Khloth on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DefDDM.h"
#import "RequestRetryTimer.h"

// CSM
#import "CommandDelegate.h"

@class DataDeliveryManager;
@class DeliveryRequest;
@class RequestStore;
@class CommandServiceManager;
@class CSMErrorWrapper;
@class ResponseData;

@interface RequestExecutor : NSObject <RequestRetryTimerListener, CommandDelegate> {
@private
	DataDeliveryManager*	mDDM;
	RequestStore*			mRequestStore;
	DeliveryRequest*		mExecuteRequest;
	NSMutableDictionary*	mTimerDictionary;
	CommandServiceManager*	mCSM;
	
	// Thread communication
	NSThread*				mCallerThread;
	
	DDMRequestExecutorStatus	mStatus;
}

@property (nonatomic, readonly) DDMRequestExecutorStatus mStatus;
@property (readonly) NSThread* mCallerThread;

- (id) initWithDDM: (DataDeliveryManager*) aDDM CSM: (CommandServiceManager*) aCSM andRequestStore: (RequestStore*) aReqStore;
- (void) execute;

@end
