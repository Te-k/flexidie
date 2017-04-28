//
//  RequestExecutor.m
//  DDM
//
//  Created by Makara Khloth on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestExecutor.h"
#import "DataDeliveryManager.h"
#import "RequestStore.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"
#import "ConnectionLog.h"

// CSM
#import "CommandServiceManager.h"
#import "CommandRequest.h"
#import "ResponseData.h"
#import "CommandMetaData.h"

#import "AppContext.h"
#import "LicenseManager.h"
#import "ServerAddressManager.h"
#import "DefStd.h"

@interface CSMErrorWrapper : NSObject {
@private
	NSError*	mError;
	NSInteger	mCSID;
}

@property (retain) NSError* mError;
@property NSInteger mCSID;

@end

@implementation CSMErrorWrapper

@synthesize mError;
@synthesize mCSID;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[mError release];
	[super dealloc];
}

@end

@interface RequestExecutor (private)

- (void) retryRequest: (DeliveryRequest*) aRequest;
- (void) serveNextRequest;
- (void) doServeNextRequest;
- (BOOL) isResumeable: (NSInteger) aCSID;

- (void) handleRequestError:(uint32_t)CSID withError:(NSError *)error;

- (void) handleConstructError: (CSMErrorWrapper*) aError;
- (void) handleServerError: (ResponseData*) aResponse;
- (void) handleSuccess: (ResponseData*) aResponse;
- (void) handleTransportError: (CSMErrorWrapper*) aError;

- (CommandMetaData*) commandMetaData;

+ (ConnectionLog*) logConnection: (NSInteger) aErrorCode command: (NSInteger) aCommand cmdAction: (NSInteger) aCmdAction andErrMessage: (NSString*) aErrMessage;

@end

@implementation RequestExecutor

@synthesize mStatus;
@synthesize mCallerThread;

- (id) initWithDDM: (DataDeliveryManager*) aDDM CSM: (CommandServiceManager*) aCSM andRequestStore: (RequestStore*) aReqStore {
	if ((self = [super init])) {
		mDDM = aDDM;
		[mDDM retain];
		mCSM = aCSM;
		[mCSM retain];
		mRequestStore = aReqStore;
		[mRequestStore retain];
		mTimerDictionary = [[NSMutableDictionary alloc] init];
		mStatus = kDDMRequestExecutorStatusIdle;
		mCallerThread = [NSThread currentThread];
	}
	return (self);
}

- (void) execute {
	if (mStatus == kDDMRequestExecutorStatusIdle) {
		if ([mRequestStore countAllRequest] > 0) {
			DeliveryRequest* request = [mRequestStore scheduleRequest];
			DLog (@"Schedule the request = %@", request);
			if (request) { // Sometime there are requests but those are not ready to execute (wating timer for retry)
				mExecuteRequest = request;
				if ([mExecuteRequest mPersisted]) {
					if ([self isResumeable:[mExecuteRequest mCSID]]) {
						[mCSM resume:[mExecuteRequest mCSID] withDelegate:self];
						mStatus = kDDMRequestExecutorStatusBusyWithRequest;
					} else { // If this condition is TRUE, there must be BUG since the request which not resumable should be delete from start of one of callbacks from CSM
						DeliveryResponse* delivResponse = [[DeliveryResponse alloc] init];
						[delivResponse setMSuccess:FALSE];
						[delivResponse setMStillRetry:FALSE];
						[delivResponse setMDDMStatus:kDDMServerStatusUnknown];
						[delivResponse setMEDPType:[mExecuteRequest mEDPType]];
						[delivResponse setMEchoCommandCode:[mExecuteRequest mCommandCode]];
						[delivResponse setMStatusCode:kDDMPersistNoneResumableRequest];
						[delivResponse setMStatusMessage:@"Not resumable in the queue and persisted"];
						
						// Manipulate csm response
						ResponseData *csmResponse = [[ResponseData alloc] init];
						[csmResponse setStatusCode:[delivResponse mStatusCode]];
						[csmResponse setMessage:[delivResponse mStatusMessage]];
						[delivResponse setMCSMReponse:csmResponse];
						[csmResponse release];
						
						// 1. Remove deliver request from queue (both from store and persistent)
						[mExecuteRequest retain];
						[mRequestStore deleteDeliveryRequest:[mExecuteRequest mCSID]];
						
						// 2. Notify deliver request listener
						[[mExecuteRequest mDeliveryListener] requestFinished:delivResponse];
						[mExecuteRequest release];
						[delivResponse release];
						
						// 3. Serve next request with small internal delay
						[self serveNextRequest];
					}
				} else {
					CommandRequest* cmdRequest = [[CommandRequest alloc] init];
					[cmdRequest setDelegate:self];
					[cmdRequest setCommandData:[request mCommandData]];
					CommandMetaData* cmdMetaData = [self commandMetaData];
					[cmdMetaData setCompressionCode:[request mCompressionFlag]];
					[cmdMetaData setEncryptionCode:[request mEncryptionFlag]];
					[cmdRequest setMetaData:cmdMetaData];
					// Beware of priority value is match between CommandPriority in CSM and DDMRequestPriority in DDM for it's ok but next time of change priority value
					[cmdRequest setPriority:(CommandPriority)[request mPriority]];
					NSInteger csid = [mCSM execute:cmdRequest];
					[mExecuteRequest setMCSID:csid];
					[mRequestStore updatePersistStatusAndInsertRequest:mExecuteRequest];
					[cmdRequest release];
					mStatus = kDDMRequestExecutorStatusBusyWithRequest;
				}
			}
		}
	}
}

- (void) requestRetryTimeout: (NSInteger) aCSID {
	DLog(@"---> Request is timeout <--- [aRequest mCSID] = %d, mStatus = %d", aCSID, mStatus)
	[mRequestStore updateRequestStatusToReadyForSchedule:aCSID]; // After update status to READY the request is moved to mRequestQueue (ready queue)
	[mRequestStore increaseRetryCount:aCSID];
	[mTimerDictionary removeObjectForKey:[NSNumber numberWithInt:aCSID]];
	if (mStatus == kDDMRequestExecutorStatusIdle) {
		[self execute];
	}
}

- (void) retryRequest: (DeliveryRequest*) aRequest {
	DLog(@"---> Retry the request <--- [aRequest mCSID] = %d", [aRequest mCSID])
	RequestRetryTimer* timer = [RequestRetryTimer scheduleTimeFor:[aRequest mCSID] withListner:self andWithinSecond:[aRequest mRetryTimeout]];
	[mTimerDictionary setObject:timer forKey:[NSNumber numberWithInt:[aRequest mCSID]]];
}

- (void) serveNextRequest {
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doServeNextRequest) userInfo:nil repeats:NO];
}

- (void) doServeNextRequest {
	mStatus = kDDMRequestExecutorStatusIdle;
	[self execute];
}

- (BOOL) isResumeable: (NSInteger) aCSID {
	BOOL resumeable = FALSE;
	for (NSNumber* csid in [mCSM getAllPendingSession]) {
		if ([csid intValue] == aCSID) {
			resumeable = TRUE;
			break;
		}
	}
	return (resumeable);
}

+ (ConnectionLog*) logConnection: (NSInteger) aErrorCode command: (NSInteger) aCommand cmdAction: (NSInteger) aCmdAction andErrMessage: (NSString*) aErrMessage {
	ConnectionLog* connLog = [[ConnectionLog alloc] init];
	[connLog setMErrorCode:aErrorCode];
	[connLog setMCommandCode:aCommand];
	[connLog setMCommandAction:aCmdAction];
	[connLog setMErrorMessage:aErrMessage];
	
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
	NSString* dateTimeString = [formatter stringFromDate:[NSDate date]];
	[connLog setMDateTime:dateTimeString];
	[formatter release];
	
	[connLog autorelease];
	return (connLog);
}

- (CommandMetaData*) commandMetaData {
	CommandMetaData *metaData = [[CommandMetaData alloc] init];
	[metaData setCompressionCode:1];
	[metaData setConfID:[[mDDM mLicenseManager] getConfiguration]];
	[metaData setEncryptionCode:1];
	[metaData setProductID:[[[mDDM mAppContext] getProductInfo] getProductID]];
	[metaData setProtocolVersion:[[[mDDM mAppContext] getProductInfo] getProtocolVersion]];
	[metaData setLanguage:[[[mDDM mAppContext] getProductInfo] getLanguage]];
	[metaData setActivationCode:[[mDDM mLicenseManager] getActivationCode]];
	[metaData setDeviceID:[[[mDDM mAppContext] getPhoneInfo] getIMEI]];
	[metaData setIMSI:[[[mDDM mAppContext] getPhoneInfo] getIMSI]];
	[metaData setMCC:[[[mDDM mAppContext] getPhoneInfo] getMobileCountryCode]];
	[metaData setMNC:[[[mDDM mAppContext] getPhoneInfo] getMobileNetworkCode]];
	[metaData setPhoneNumber:[[[mDDM mAppContext] getPhoneInfo] getPhoneNumber]];
	//[metaData setProductVersion:[[[mDDM mAppContext] getProductInfo] getProductVersion]];
	[metaData setProductVersion:[[[mDDM mAppContext] getProductInfo] getProductFullVersion]];
	[metaData setHostURL:[[mDDM mServerAddressManager] getHostServerUrl]]; // http://58.137.119.229/RainbowCore/gateway
	[metaData autorelease];
	return (metaData);
}

#pragma mark -
#pragma mark Construct, Transport error
#pragma mark -

- (void) handleRequestError:(uint32_t)CSID withError:(NSError *)error {
	// 1. Construct deliver response
	DeliveryResponse* delivResponse = [[DeliveryResponse alloc] init];
	[delivResponse setMSuccess:FALSE];
	[delivResponse setMDDMStatus:kDDMServerStatusUnknown];
	[delivResponse setMEDPType:[mExecuteRequest mEDPType]];
	[delivResponse setMEchoCommandCode:[mExecuteRequest mCommandCode]];
	[delivResponse setMStatusCode:[error code]];
	[delivResponse setMStatusMessage:[error domain]];
	
	// Manipulate csm response
	ResponseData *csmResponse = [[ResponseData alloc] init];
	[csmResponse setStatusCode:[delivResponse mStatusCode]];
	[csmResponse setMessage:[delivResponse mStatusMessage]];
	[delivResponse setMCSMReponse:csmResponse];
	[csmResponse release];
	
	if (![self isResumeable:CSID]) {
		DLog (@"Not resumable CSID = %d", CSID);
		[delivResponse setMStillRetry:FALSE];
		
		// 2. Remove deliver request from queue (both from store and persistent)
		[mExecuteRequest retain];
		[mRequestStore deleteDeliveryRequest:[mExecuteRequest mCSID]];
		
		// 3. Delete session info and payload file
		[mCSM deleteSessionPayload:[mExecuteRequest mCSID]];
		
		// 4. Notify deliver request listener
		[[mExecuteRequest mDeliveryListener] requestFinished:delivResponse];
		[mExecuteRequest release];
		
		// 5. Serve next request with small internal delay
		[self serveNextRequest];
	} else {
		BOOL stillRetry = [mExecuteRequest mRetryCount] < [mExecuteRequest mMaxRetry] ? TRUE : FALSE;
		[delivResponse setMStillRetry:stillRetry];
		
		DLog (@"The request is still resumable? ... %d", stillRetry);
		if (stillRetry) {
			// 2. Move to wait request queue
			[mRequestStore addRequestToWaitQueue:mExecuteRequest];
			
			// 3. Retry the request
			[self retryRequest:mExecuteRequest];
			
			// 4. Notify request listener
			[[mExecuteRequest mDeliveryListener] updateRequestProgress:delivResponse];
			
			// 5. Serve next request with small internal delay
			[self serveNextRequest];
		} else {
			// 2. Remove deliver request from queue (both from store and persistent)
			[mExecuteRequest retain];
			[mRequestStore deleteDeliveryRequest:[mExecuteRequest mCSID]];
			
			// 3. Delete session info and payload file
			[mCSM deleteSessionPayload:[mExecuteRequest mCSID]];
			
			// 4. Notify deliver request listener
			[[mExecuteRequest mDeliveryListener] requestFinished:delivResponse];
			[mExecuteRequest release];
			
			// 5. Serve next request with small internal delay
			[self serveNextRequest];
		}
	}
	[delivResponse release];
}

#pragma mark -
#pragma mark CSM call back do functions
#pragma mark -

- (void) handleConstructError: (CSMErrorWrapper*) aError {
	NSError* error = [aError mError];
	NSInteger CSID = [aError mCSID];
	
	// 1. Log connection history
	ConnectionLog* connLog = [RequestExecutor logConnection:[error code] command:[mExecuteRequest mCommandCode] cmdAction:[mExecuteRequest mEDPType] andErrMessage:[error domain]];
	[connLog setMErrorCate:kConnectionLogPayloadError];
	[mDDM addNewConnectionHistory:connLog];
	
	// 2. Handle request error
	[self handleRequestError:CSID withError:error];
}

- (void) handleServerError: (ResponseData*) aResponse {
	ResponseData* response = aResponse;
	// 1. Log connection history
	ConnectionLog* connLog = [RequestExecutor logConnection:[response statusCode] command:[mExecuteRequest mCommandCode] cmdAction:[mExecuteRequest mEDPType] andErrMessage:[response message]];
	[connLog setMErrorCate:kConnectionLogServerError];
	[mDDM addNewConnectionHistory:connLog];
	
	// 2. Construct deliver response
	DeliveryResponse* delivResponse = [[DeliveryResponse alloc] init];
	[delivResponse setMSuccess:FALSE];
	[delivResponse setMDDMStatus:kDDMServerStatusUnknown];
	[delivResponse setMEDPType:[mExecuteRequest mEDPType]];
	[delivResponse setMEchoCommandCode:[mExecuteRequest mCommandCode]];
	[delivResponse setMStatusCode:[response statusCode]];
	[delivResponse setMStatusMessage:[response message]];
	[delivResponse setMCSMReponse:response];
	
	if (![self isResumeable:[response CSID]]) {
		DLog(@"Not resumeable CSID = %d", [response CSID])
		[delivResponse setMStillRetry:FALSE];
		
		// 3. Remove deliver request from queue (both from store and persistent)
		[mExecuteRequest retain];
		[mRequestStore deleteDeliveryRequest:[mExecuteRequest mCSID]];
		
		// 4. Delete session info and payload file
		[mCSM deleteSessionPayload:[mExecuteRequest mCSID]];
		
		// 5. Notify deliver request listener
		[[mExecuteRequest mDeliveryListener] requestFinished:delivResponse];
		[mExecuteRequest release];
		
		// 6. Check server license status
		[mDDM processServerError:[response statusCode]];
		
		// 7. Notify PCC
		[mDDM processPCC:[response PCCArray]];
		
		// 8. Serve next request with small internal delay
		[self serveNextRequest];
	} else {
		BOOL stillRetry = [mExecuteRequest mRetryCount] < [mExecuteRequest mMaxRetry] ? TRUE : FALSE;
		
		DLog(@"-------------- REQUESE -------------");
		DLog(@"Resumeable CSID = %d", [response CSID]);
		DLog(@"Retry count = %d", [mExecuteRequest mRetryCount]);
		DLog(@"Max retry = %d", [mExecuteRequest mMaxRetry]);
		DLog(@"-------------- REQUESE -------------");
		
		[delivResponse setMStillRetry:stillRetry];
		if (stillRetry) {
			// 3. Move to wait request queue
			[mRequestStore addRequestToWaitQueue:mExecuteRequest];
			
			// 4. Retry the request
			[self retryRequest:mExecuteRequest];
			
			// 5. Notify request listener
			[[mExecuteRequest mDeliveryListener] updateRequestProgress:delivResponse];
			
			// 6. Check server license status
			[mDDM processServerError:[response statusCode]];
			
			// 7. Notify PCC
			[mDDM processPCC:[response PCCArray]];
			
			// 8. Serve next request with small internal delay
			[self serveNextRequest];
		} else {
			// 3. Remove deliver request from queue (both from store and persistent)
			[mExecuteRequest retain];
			[mRequestStore deleteDeliveryRequest:[mExecuteRequest mCSID]];
			
			// 4. Delete session info and payload file
			[mCSM deleteSessionPayload:[mExecuteRequest mCSID]];
			
			// 5. Notify deliver request listener
			[[mExecuteRequest mDeliveryListener] requestFinished:delivResponse];
			[mExecuteRequest release];
			
			// 6. Check server license status
			[mDDM processServerError:[response statusCode]];
			
			// 7. Notify PCC
			[mDDM processPCC:[response PCCArray]];
			
			// 8. Serve next request with small internal delay
			[self serveNextRequest];
		}
	}
	[delivResponse release];
}

- (void) handleSuccess: (ResponseData*) aResponse {
	ResponseData* response = aResponse;
	
	// 1. Log connection history
	ConnectionLog* connLog = [RequestExecutor logConnection:[response statusCode] command:[mExecuteRequest mCommandCode] cmdAction:[mExecuteRequest mEDPType] andErrMessage:[response message]];
	[connLog setMErrorCate:kConnectionLogOK];
	[mDDM addNewConnectionHistory:connLog];
	
	// 2. Construct deliver response
	DeliveryResponse* delivResponse = [[DeliveryResponse alloc] init];
	[delivResponse setMSuccess:TRUE];
	[delivResponse setMStillRetry:FALSE];
	[delivResponse setMDDMStatus:kDDMServerStatusOK];
	[delivResponse setMEDPType:[mExecuteRequest mEDPType]];
	[delivResponse setMEchoCommandCode:[mExecuteRequest mCommandCode]];
	[delivResponse setMStatusCode:[response statusCode]];
	[delivResponse setMStatusMessage:[response message]];
	[delivResponse setMCSMReponse:response];
	
	// 3. Remove deliver request from queue (both from store and persistent)
	[mExecuteRequest retain];
	[mRequestStore deleteDeliveryRequest:[mExecuteRequest mCSID]];
	
	// 4. Notify deliver request listener
	[[mExecuteRequest mDeliveryListener] requestFinished:delivResponse];
	[mExecuteRequest release];
	[delivResponse release];
	
	// 5. Check server license status
	[mDDM processServerError:[response statusCode]];
	
	// 6. Notify PCC
	[mDDM processPCC:[response PCCArray]];
	
	// 7. Server next request with small internal delay
	[self serveNextRequest];
}

- (void) handleTransportError: (CSMErrorWrapper*) aError {
	NSError* error = [aError mError];
	NSInteger CSID = [aError mCSID];
	
	// 1. Log connection history
	ConnectionLog* connLog = [RequestExecutor logConnection:[error code] command:[mExecuteRequest mCommandCode] cmdAction:[mExecuteRequest mEDPType] andErrMessage:[error domain]];
	[connLog setMErrorCate:kConnectionLogHttpError]; // @todo could be transport error also
	[mDDM addNewConnectionHistory:connLog];
	
	// 2. Handle request error
	[self handleRequestError:CSID withError:error];
}

#pragma mark -
#pragma mark CSM callback
#pragma mark -

- (void)onConstructError:(uint32_t)CSID withError:(NSError *)error {
	DLog(@"Handle onConstructError; CSID = %d, error = %@", CSID, error);
	
	// Notify to caller thread
	CSMErrorWrapper* csmError = [[CSMErrorWrapper alloc] init];
	[csmError setMCSID:CSID];
	[csmError setMError:error];
	[self performSelector:@selector(handleConstructError:) onThread:[self mCallerThread] withObject:csmError waitUntilDone:FALSE];
	[csmError release];
}

- (void)onServerError:(ResponseData *)response {
	DLog (@"Handle server error, response = %@", response);
	
	// Notify to caller thread
	[self performSelector:@selector(handleServerError:) onThread:[self mCallerThread] withObject:response waitUntilDone:FALSE];
}

- (void)onSuccess:(ResponseData *)response {
	DLog (@"Handle server success, response = %@", response);
	
	// Notify to caller thread
	[self performSelector:@selector(handleSuccess:) onThread:[self mCallerThread] withObject:response waitUntilDone:FALSE];
}

- (void)onTransportError:(uint32_t)CSID withError:(NSError *)error {
	DLog (@"Handle transport; CSID = %d, error = %@", CSID, error);
	
	// Notify to caller thread
	CSMErrorWrapper* csmError = [[CSMErrorWrapper alloc] init];
	[csmError setMCSID:CSID];
	[csmError setMError:error];
	[self performSelector:@selector(handleTransportError:) onThread:[self mCallerThread] withObject:csmError waitUntilDone:FALSE];
	[csmError release];
}

- (void) dealloc {
	[mTimerDictionary release];
	[mRequestStore release];
	[mCSM release];
	[mDDM release];
	[super dealloc];
}

@end
