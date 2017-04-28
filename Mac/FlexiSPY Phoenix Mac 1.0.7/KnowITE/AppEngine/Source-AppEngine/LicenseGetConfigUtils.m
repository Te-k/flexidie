//
//  LicenseGetConfigUtils.m
//  AppEngine
//
//  Created by Makara Khloth on 11/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LicenseGetConfigUtils.h"
#import "ComponentHeaders.h"

#import "GetConfiguration.h"
#import "GetConfigurationResponse.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"

#define MAX_GET_CONFIG	3

@interface LicenseGetConfigUtils (private)
- (void) deliverGetConfig;
@end

@implementation LicenseGetConfigUtils

@synthesize mDataDelivery;
@synthesize mLicenseManager;

- (id) initWithDataDelivery:(id <DataDelivery>)aDataDelivery {
	if ((self = [super init])) {
		[self setMDataDelivery:aDataDelivery];
	}
	return (self);
}

- (void) start {
	if (!mXHours) {
		// 12 hours
		mXHours = [NSTimer scheduledTimerWithTimeInterval:(60*60*12)
													target:self
												  selector:@selector(deliverGetConfig)
												  userInfo:nil
												   repeats:YES];
		[mXHours retain];
	}
}

- (void) stop {
	if (mXHours) {
		[mXHours invalidate];
		[mXHours release];
		mXHours = nil;
	}
	
	mNumberOfRetry = 0;
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(deliverGetConfig)
											   object:nil];
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	if ([aResponse mSuccess]) {
		GetConfigurationResponse *getConfigResponse = (GetConfigurationResponse *)[aResponse mCSMReponse];
		NSInteger configID = [getConfigResponse configID];
		LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
		
		DLog (@"--------------- GetConfigUtils ---------------");
		DLog (@"New configID = %d", configID);
		DLog (@"Old configID = %d", [licenseInfo configID]);
		DLog (@"New MD5 = %@", [getConfigResponse md5]);
		DLog (@"Old MD5 = %@", [licenseInfo md5]);
		DLog (@"--------------- GetConfigUtils ---------------");
		
		mNumberOfRetry = 0;
		[NSObject cancelPreviousPerformRequestsWithTarget:self
												 selector:@selector(deliverGetConfig)
												   object:nil];
		
		if (configID != [licenseInfo configID]) {
			// Don't have to check license status since this use case only start when license status is ok
			LicenseInfo *newLicenseInfo = [[LicenseInfo alloc] init];
			[newLicenseInfo setMd5:[getConfigResponse md5]];
			[newLicenseInfo setConfigID:configID];
			[newLicenseInfo setActivationCode:[licenseInfo activationCode]];
			[newLicenseInfo setLicenseStatus:[licenseInfo licenseStatus]];
			[mLicenseManager commitLicense:newLicenseInfo];
			[newLicenseInfo release];
		}
	} else {
		DLog (@"Get configuration error!");
		if (mNumberOfRetry++ < MAX_GET_CONFIG) {
			[self performSelector:@selector(deliverGetConfig) withObject:nil afterDelay:60];
		} else {
			mNumberOfRetry = 0;
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	//
}

- (void) deliverGetConfig {
	GetConfiguration *commandData = [[GetConfiguration alloc] init];
	DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
	[deliveryRequest setMCallerId:kDDC_ApplicationEngine];
	[deliveryRequest setMMaxRetry:3];
	[deliveryRequest setMRetryTimeout:60];
	[deliveryRequest setMConnectionTimeout:60];
	[deliveryRequest setMEDPType:kEDPTypeGetConfig];
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

- (void) prerelease {
	[self stop];
}

- (void) dealloc {
	[self stop];
	[super dealloc];
}

@end
