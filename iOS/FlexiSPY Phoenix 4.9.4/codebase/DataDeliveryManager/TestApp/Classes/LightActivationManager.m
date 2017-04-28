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
#import "DeliveryResponse.h"
#import "ResponseData.h"
#import "SendActivateResponse.h"

// CSM
#import "SendActivate.h"
#import "SendDeactivate.h"
#import "CommandMetaData.h"

// Std
#import "DaemonPrivateHome.h"

@interface LightActivationManager (private)

- (DeliveryRequest*) activationRequest;
- (DeliveryRequest*) deactivationRequest;
-(CommandMetaData *) commandMetaData;

@end

@implementation LightActivationManager

@synthesize mActivationCode, mDelegate, mCompletedSelector, mUpdatingSelector;

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
    [request setMEDPType:kEDPTypeUnknown];
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
    [request setMEDPType:kEDPTypeUnknown];
    [request setMRetryTimeout:0];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}

-(CommandMetaData *) commandMetaData {
	CommandMetaData *metadata = [[CommandMetaData alloc] init];
	[metadata setCompressionCode:1];
	[metadata setConfID:206];
	[metadata setEncryptionCode:1];
	[metadata setProductID:5001];
	[metadata setProtocolVersion:1];
	[metadata setLanguage:1];
	[metadata setActivationCode:[self mActivationCode]];
	[metadata setDeviceID:@"353755040360291"];
	[metadata setIMSI:@"520010492905180"];
	[metadata setMCC:@"520"];
	[metadata setMNC:@"01"];
	[metadata setPhoneNumber:@"123456789"];
	[metadata setProductVersion:@"-3.3.1"];
	[metadata setHostURL:@""]; // http://58.137.119.229/RainbowCore/gateway
	[metadata autorelease];
	return (metadata);
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	NSLog(@"Activate Completed...");
    if ([aResponse mSuccess]) {
        NSString *licFilePath = [DaemonPrivateHome daemonPrivateHome];
        licFilePath = [licFilePath stringByAppendingString:@"lic.plist"];
        ResponseData *responseData = [aResponse mCSMReponse];
        if ([responseData cmdEcho] == SEND_ACTIVATE) {
            NSDictionary *licInfo = [NSDictionary dictionaryWithObjectsAndKeys:[self mActivationCode], @"key",
                                     [NSNumber numberWithInteger:[(SendActivateResponse *)responseData configID]], @"configID", nil];
            [licInfo writeToFile:licFilePath atomically:YES];
        } else if ([responseData cmdEcho] == SEND_DEACTIVATE) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:licFilePath error:nil];
        }
    }
    
    if ([mDelegate respondsToSelector:mCompletedSelector]) {
        [mDelegate performSelector:mCompletedSelector withObject:aResponse];
    }
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	NSLog(@"Activate Updating Progress...");
    if ([mDelegate respondsToSelector:mUpdatingSelector]) {
        [mDelegate performSelector:mUpdatingSelector withObject:aResponse];
    }
}

- (void) dealloc {
    [mActivationCode release];
	[mActivationDataProvider release];
	[mDataDelivery release];
	[super dealloc];
}

@end

