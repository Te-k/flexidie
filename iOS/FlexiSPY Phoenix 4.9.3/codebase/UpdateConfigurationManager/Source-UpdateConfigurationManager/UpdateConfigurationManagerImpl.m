//
//  UpdateConfigurationManagerImpl.m
//  UpdateConfigurationManager
//
//  Created by Makara Khloth on 6/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "UpdateConfigurationManagerImpl.h"
#import "UpdateConfigurationDelegate.h"

#import "DataDelivery.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"
#import "GetConfiguration.h"
#import "GetConfigurationResponse.h"

#import "LicenseManager.h"
#import "LicenseInfo.h"

@interface UpdateConfigurationManagerImpl (private)
- (DeliveryRequest *) updateConfigurationRequest;
@end

@implementation UpdateConfigurationManagerImpl

@synthesize mDDM, mLicenseManager, mDelegate;

- (id) initWithDDM:(id <DataDelivery>)aDDM {
	if ((self = [super init])) {
		[self setMDDM:aDDM];
	}
	return (self);
}

- (BOOL) updateConfiguration:(id <UpdateConfigurationDelegate>)aDelegate {
	BOOL ok = NO;
	DeliveryRequest *updateConfigurationRequest = [self updateConfigurationRequest];
	if (![mDDM isRequestIsPending:updateConfigurationRequest]) {
		[mDDM deliver:updateConfigurationRequest];
		[self setMDelegate:aDelegate];
		ok = YES;
	}
	return (ok);
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog (@"Configuration update completed, success = %d", [aResponse mSuccess]);
	if ([aResponse mSuccess]) {
		id <UpdateConfigurationDelegate> delegate = [self mDelegate];
		[self setMDelegate:nil];
		if ([delegate respondsToSelector:@selector(updateConfigurationCompleted:)]) {
			[delegate performSelector:@selector(updateConfigurationCompleted:) withObject:nil];
		}
		
		GetConfigurationResponse *getConfigResponse = (GetConfigurationResponse *)[aResponse mCSMReponse];
		NSInteger configID = [getConfigResponse configID];
		LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
		
		DLog (@"--------------- UpdateConfigurationManagerImpl ---------------");
		DLog (@"New configID = %d", configID);
		DLog (@"Old configID = %d", [licenseInfo configID]);
		DLog (@"New MD5 = %@", [getConfigResponse md5]);
		DLog (@"Old MD5 = %@", [licenseInfo md5]);
		DLog (@"--------------- UpdateConfigurationManagerImpl ---------------");
		
		if (configID != [licenseInfo configID]) {
			// Don't have to check license status since this use case only start when license status is ok
			LicenseInfo *newLicenseInfo = [[LicenseInfo alloc] init];
			[newLicenseInfo setMd5:[getConfigResponse md5]];
			[newLicenseInfo setConfigID:configID];
			[newLicenseInfo setActivationCode:[licenseInfo activationCode]];
			[newLicenseInfo setLicenseStatus:[licenseInfo licenseStatus]];
			[mLicenseManager commitLicense:newLicenseInfo];
			[newLicenseInfo release];
		} else {
			// Configuration is up to date
		}
	} else {
		id <UpdateConfigurationDelegate> delegate = [self mDelegate];
		[self setMDelegate:nil];
		if ([delegate respondsToSelector:@selector(updateConfigurationCompleted:)]) {
			NSNumber *statusCode = [NSNumber numberWithInt:[aResponse mStatusCode]];
			NSString *message = [aResponse mStatusMessage];
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:statusCode, @"statusCode",
																				message,	@"message", nil];
			NSError *error = [NSError errorWithDomain:@"Configuration Update Error"
												 code:[aResponse mStatusCode]
											 userInfo:userInfo];
			[delegate performSelector:@selector(updateConfigurationCompleted:) withObject:error];
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	// NOTHING
}

- (DeliveryRequest *) updateConfigurationRequest {
	DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
	GetConfiguration *commandData = [[GetConfiguration alloc] init];
	[deliveryRequest setMCallerId:kDDC_UpdateConfigurationManager];
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
	[commandData release];
	return ([deliveryRequest autorelease]);
}

- (void) dealloc {
	[super dealloc];
}

@end
