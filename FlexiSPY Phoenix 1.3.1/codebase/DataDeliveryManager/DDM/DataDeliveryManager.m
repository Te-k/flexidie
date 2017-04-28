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

#import "AppContext.h"
#import "ServerAddressManager.h"
#import "LicenseManager.h"
#import "ServerResponseCodeEnum.h"

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

- (id) initWithCSM: (CommandServiceManager*) aCSM {
	if ((self = [super init])) {
		mCSM = aCSM;
		[mCSM retain];
		mRequestStore = [[RequestStore alloc] initWithCSM:mCSM];
		mRequestExecutor = [[RequestExecutor alloc] initWithDDM:self CSM:mCSM andRequestStore:mRequestStore];
		// Trigger to deliver requests in request store in case of phone restarted or app crashed
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(deliverResumeableRequest) userInfo:nil repeats:NO];
	}
	return (self);
}

- (void) deliver: (DeliveryRequest*) aRequest {
	[mRequestStore addRequest:aRequest];
	if ([mRequestExecutor mStatus] == kDDMRequestExecutorStatusIdle) {
		[mRequestExecutor execute];
	}
}

- (BOOL) isRequestIsPending: (DeliveryRequest*) aRequest {
	return ([mRequestStore isRequestExist:aRequest]);
}

- (BOOL) isRequestPendingForCaller: (NSInteger) aCallerId {
	return ([mRequestStore isOrphanRequestForCaller:aCallerId]);
}

- (void) registerCaller: (NSInteger) aCallerId withListener: (id <DeliveryListener>) aListener {
	[mRequestStore adoptOrphanRequestForCaller:aCallerId withDeliveryListener:aListener];
}

- (void) processPCC: (id) aPCCArray {
	[mRemoteCommand remoteCommandPCCRecieved:aPCCArray];
}

- (void) addNewConnectionHistory: (ConnectionLog*) aConnHistory {
	[mConnectionHistory connectionLogAdded:aConnHistory];
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
