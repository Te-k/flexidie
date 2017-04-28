//
//  LicenseHeartbeatUtils.m
//  AppEngine
//
//  Created by Makara Khloth on 8/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LicenseHeartbeatUtils.h"
#import "ComponentHeaders.h"

#import "SendHeartBeat.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"

@interface LicenseHeartbeatUtils (private)
- (void) deliverHeartbeat;
@end


@implementation LicenseHeartbeatUtils

@synthesize mDataDelivery;

- (id) initWithDataDelivery:(id <DataDelivery>)aDataDelivery {
	if ((self = [super init])) {
		[self setMDataDelivery:aDataDelivery];
	}
	return (self);
}

- (void) sendHeartbeat {
	// DDM checking
	[self deliverHeartbeat];
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	//
	DLog (@"requestFinished")
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	//
}

- (void) deliverHeartbeat {
	DLog (@"deliverHeartbeat")
	SendHeartBeat *commandData = [[SendHeartBeat alloc] init];
	DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
	[deliveryRequest setMCallerId:kDDC_ApplicationEngine];
	[deliveryRequest setMMaxRetry:3];
	[deliveryRequest setMRetryTimeout:60];
	[deliveryRequest setMConnectionTimeout:60];
	[deliveryRequest setMEDPType:kEDPTypeSendHeartbeat];
	[deliveryRequest setMPriority:kDDMRequestPriortyHigh];
	[deliveryRequest setMCommandCode:[commandData getCommand]];
	[deliveryRequest setMCommandData:commandData];
	[deliveryRequest setMCompressionFlag:1];
	[deliveryRequest setMEncryptionFlag:1];
	[deliveryRequest setMDeliveryListener:self];	
	if (![mDataDelivery isRequestIsPending:deliveryRequest]) {
		[mDataDelivery deliver:deliveryRequest];
	}
	[commandData release];
	[deliveryRequest release];
}

- (void) dealloc {
	[super dealloc];
}

@end
