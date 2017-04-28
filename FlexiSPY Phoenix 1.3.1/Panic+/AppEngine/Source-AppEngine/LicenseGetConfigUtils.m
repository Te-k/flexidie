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
	if (!m24Hours) {
		m24Hours = [NSTimer scheduledTimerWithTimeInterval:(60*60*24)
													target:self
												  selector:@selector(deliverGetConfig)
												  userInfo:nil
												   repeats:YES];
		[m24Hours retain];
	}
}

- (void) stop {
	if (m24Hours) {
		[m24Hours invalidate];
		[m24Hours release];
		m24Hours = nil;
	}
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	if ([aResponse mSuccess]) {
		GetConfigurationResponse *getConfigResponse = (GetConfigurationResponse *)[aResponse mCSMReponse];
		NSInteger configID = [getConfigResponse configID];
		LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
		
		DLog (@"New configID = %d, Old configID = %d", configID, [licenseInfo configID]);
		DLog (@"New MD5 = %@, Old MD5 = %@", [getConfigResponse md5], [licenseInfo md5]);
		
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
		// !!!: Retry 3 times according to the spec
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

- (void) release {
	[self stop];
	[super release];
}

- (void) dealloc {
	[self stop];
	[super dealloc];
}

@end
