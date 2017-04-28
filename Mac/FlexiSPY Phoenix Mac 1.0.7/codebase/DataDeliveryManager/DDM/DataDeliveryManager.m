//
//  DataDeliveryManager.m
//  DDM
//
//  Created by Makara Khloth on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataDeliveryManager.h"
#import "RequestStore.h"
#import "ServerStatusErrorListener.h"
#import "RequestExecutor.h"
#import "DeliveryRequest.h"

#import "AppContext.h"
#import "ServerAddressManager.h"
#import "LicenseManager.h"
#import "ServerResponseCodeEnum.h"

#import "ConnectionLog.h"

@interface DataDeliveryManager (private)

- (void) deliverResumeableRequest;

@end


@implementation DataDeliveryManager

@synthesize mConnectionHistory;
@synthesize mRemoteCommand;
@synthesize mServerStatusErrorListener;
@synthesize mAppContext;
@synthesize mServerAddressManager;
@synthesize mLicenseManager;
@synthesize mDataDeliveryMethod;

- (id) initWithCSM: (CommandServiceManager*) aCSM {
	if ((self = [super init])) {
		mCSM = aCSM;
		[mCSM retain];
		[self setMDataDeliveryMethod:kDataDeliveryViaWifiWWAN];
		mRequestStore = [[RequestStore alloc] initWithCSM:mCSM];
		mRequestExecutor = [[RequestExecutor alloc] initWithDDM:self CSM:mCSM andRequestStore:mRequestStore];
		// To trigger to deliver requests in request store in case of phone has restarted or app has crashed
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(deliverResumeableRequest) userInfo:nil repeats:NO];
	}
	return (self);
}

- (void) deliver: (DeliveryRequest*) aRequest {
	[mRequestStore addRequest:aRequest];
	if ([mRequestExecutor mStatus] == kDDMRequestExecutorStatusIdle) {
		[mRequestExecutor execute];
	} else {
        DLog(@"Request executor is busy...")
    }
}

- (BOOL) isRequestIsPending: (DeliveryRequest*) aRequest {
    BOOL isRequestPending = [mRequestStore isRequestExist:aRequest];
    DLog(@"EDPType          = %d", [aRequest mEDPType])
    DLog(@"listener         = %@", [aRequest mDeliveryListener])
    DLog(@"isRequestPending = %d", isRequestPending)
    
	return (isRequestPending);
}

- (BOOL) isRequestPendingForCaller: (NSInteger) aCallerId {
    BOOL isCallIDPending = [mRequestStore isOrphanRequestForCaller:aCallerId];
    DLog(@"isCallIDPending = %d", isCallIDPending)
    
	return (isCallIDPending);
}

- (void) registerCaller: (NSInteger) aCallerId withListener: (id <DeliveryListener>) aListener {
	[mRequestStore adoptOrphanRequestForCaller:aCallerId withDeliveryListener:aListener];
}

- (void) processPCC: (id) aPCCArray {
	[mRemoteCommand remoteCommandPCCRecieved:aPCCArray];
}

- (void) addNewConnectionHistory: (ConnectionLog*) aConnHistory {
	[mConnectionHistory connectionLogAdded:aConnHistory];
    
    if ([aConnHistory mErrorCate] == kConnectionLogServerError) {
        if ([mConnectionHistory respondsToSelector:@selector(serverStatusLogAdded:)]) {
            ConnectionLog *serverStatusLog = aConnHistory;
            [mConnectionHistory performSelector:@selector(serverStatusLogAdded:) withObject:serverStatusLog];
        }
    }
}

- (void) processServerError: (NSInteger) aServerStatusError {
	if (aServerStatusError == kServerStatusLicenseExpired) {
		[mServerStatusErrorListener serverStatusErrorRecieved:kDDMServerStatusLicenseExpired];
	} else if (aServerStatusError == kServerStatusLicenseDisabled) {
		[mServerStatusErrorListener serverStatusErrorRecieved:kDDMServerStatusLicenseDisabled];
	} else if (aServerStatusError == kServerStatusDeviceIdNotFound) {
		[mServerStatusErrorListener serverStatusErrorRecieved:kDDMServerStatusDeviceIdNotFound];
	} else if (aServerStatusError == kServerStatusLicenseNotFound) {
		[mServerStatusErrorListener serverStatusErrorRecieved:kDDMServerStatusLicenseNotFound];
	} else if (aServerStatusError == OK) {
		[mServerStatusErrorListener serverStatusErrorRecieved:kDDMServerStatusOK];
	}

}

- (void) cleanAllRequests {
	[mRequestStore clearAllRequest];
}

- (void) deliverResumeableRequest {
	if ([mRequestStore countAllRequest] > 0 && [mRequestExecutor mStatus] == kDDMRequestExecutorStatusIdle) {
		DLog(@"--------> Trigger to deliver pending requests in request store <---------")
		[mRequestExecutor execute];
	}
}

- (void) dealloc {
	[mConnectionHistory release];
	[mRemoteCommand release];
	[mServerStatusErrorListener release];
	[mAppContext release];
	[mServerAddressManager release];
	[mLicenseManager release];
	[mRequestExecutor release];
	[mRequestStore release];
	[mCSM release];
	[super dealloc];
}

@end
