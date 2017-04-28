//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"
#import "LightEDM.h"
#import "LightActivationManager.h"

#import "RequestPersistStore.h"
#import "DeliveryRequest.h"
#import "RequestStore.h"

#import "CommandServiceManager.h"
#import "DataDeliveryManager.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize mRequestPersistStore;
@synthesize mRequestStore;
@synthesize mCSM;
@synthesize mDDM;
@synthesize mEDM;
@synthesize mActivationManager;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	mRequestPersistStore = [[RequestPersistStore alloc] init];
	[mRequestPersistStore dropAllRequests];
	
	mRequestStore = [[RequestStore alloc] init];
	
	NSString* csmDoc = @"/tmp";
	mCSM = [CommandServiceManager sharedManagerWithPayloadPath:csmDoc withDBPath:csmDoc];
	mDDM = [[DataDeliveryManager alloc] initWithCSM:mCSM];
	
	mEDM = [[LightEDM alloc] initWithDataDelivery:mDDM];
	mActivationManager = [[LightActivationManager alloc] initWithDataDelivery:mDDM];
	
	/*
	NSInteger csid = 0;
	// 0
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 1
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 2
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 3
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 4
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 5
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	
	// 6
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 7
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	
	// 8
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 9
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 10
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 11
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 12
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 13
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 14
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 15
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 16
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 17
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 18
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	// 19
	request = [[DeliveryRequest alloc] init];
    [request setMCSID:csid++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[mRequestStore addRequest:request];
	[request release];
	 */
}

- (void)dealloc {
	[mDDM release];
	[mCSM release];
	[mRequestPersistStore release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
