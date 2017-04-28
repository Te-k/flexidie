//
//  LightActivationManager.m
//  TestApp
//
//  Created by Makara Khloth on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LightActivationManager.h"
#import "ActivationDataProvider.h"

// DDM
#import "DefDDM.h"
#import "DataDelivery.h"
#import "DeliveryRequest.h"

// CSM
#import "SendActivate.h"
#import "SendDeactivate.h"
#import "CommandMetaData.h"

@interface LightActivationManager (private)

- (DeliveryRequest*) activationRequest;
- (DeliveryRequest*) deactivationRequest;
-(CommandMetaData *) commandMetaData;

@end

@implementation LightActivationManager

- (id) initWithDataDelivery: (id <DataDelivery>) aDataDelivery {
	if ((self = [super init])) {
		mDataDelivery = aDataDelivery;
		[mDataDelivery retain];
		if ([mDataDelivery isRequestPendingForCaller:kDDC_ActivationManager]) {
			[mDataDelivery registerCaller:kDDC_ActivationManager withListener:self];
		}
		mActivationDataProvider = [[ActivationDataProvider alloc] init];
	}
	return (self);
}

- (void) sendActivation {
	DeliveryRequest* request = [self activationRequest];
	if (![mDataDelivery isRequestIsPending:request]) {
		SendActivate* sendActivate = [mActivationDataProvider commandData];
		[request setMCommandCode:[sendActivate getCommand]];
		[request setMCommandMetaData:[self commandMetaData]];
		[request setMCommandData:sendActivate];
		[request setMDeliveryListener:self];
		[mDataDelivery deliver:request];
	}
}

- (void) sendDeactivation {
	DeliveryRequest* request = [self activationRequest];
	if (![mDataDelivery isRequestIsPending:request]) {
		SendDeactivate* sendDeactivate = [[SendDeactivate alloc] init];
		[request setMCommandCode:[sendDeactivate getCommand]];
		[request setMCommandMetaData:[self commandMetaData]];
		[request setMCommandData:sendDeactivate];
		[request setMDeliveryListener:self];
		[mDataDelivery deliver:request];
	}
}

- (DeliveryRequest*) activationRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_ActivationManager];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMMaxRetry:0];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:0];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}

- (DeliveryRequest*) deactivationRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_ActivationManager];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMMaxRetry:0];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:0];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}

-(CommandMetaData *) commandMetaData {
	CommandMetaData *metadata = [[CommandMetaData alloc] init];
	[metadata setCompressionCode:1];
	[metadata setConfID:105];
	[metadata setEncryptionCode:1];
	[metadata setProductID:4200];
	[metadata setProtocolVersion:1];
	[metadata setLanguage:0];
	[metadata setActivationCode:@"01387"];
	[metadata setDeviceID:@"353755040360291"];
	[metadata setIMSI:@"520010492905180"];
	[metadata setMCC:@"520"];
	[metadata setMNC:@"01"];
	[metadata setPhoneNumber:@"123456789"];
	[metadata setProductVersion:@"-1.00"];
	[metadata setHostURL:@""]; // http://58.137.119.229/RainbowCore/gateway
	[metadata autorelease];
	return (metadata);
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	
}

- (void) dealloc {
	[mActivationDataProvider release];
	[mDataDelivery release];
	[super dealloc];
}

@end

