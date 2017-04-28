//
//  ActivationManager.m
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ActivationManager.h"
#import "DataDelivery.h"
#import "CommandRequest.h"

#import "SendActivate.h"
#import "GetActivationCode.h"
#import "GetActivationCodeResponse.h"

#import "SendDeactivate.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"
#import "ActivationInfo.h"
#import "ActivationResponse.h"
#import "ActivationListener.h"
#import "ResponseData.h"
#import "SendActivateResponse.h"
#import "CommandCodeEnum.h"
#import "ServerResponseCodeEnum.h"

#import "LicenseManager.h"
#import "LicenseInfo.h"
#import "LicenseStatusEnum.h"

#import "ServerAddressManager.h"

#import "AppContext.h"
#import "DefStd.h"

@interface ActivationManager (private)
- (NSString *) trimEndSlashs: (NSString *) aURL;
@end


@implementation ActivationManager

@synthesize mDeliverer;
@synthesize mServerAddressManager;
@synthesize mActivationListener;
@synthesize mLicenseManager;
@synthesize mAppContext;
@synthesize mOldActivationCode;
@synthesize mLastCmdID;

- (ActivationManager *)initWithDataDelivery:(id<DataDelivery>)aDeliverer withAppContext: (id <AppContext>) aAppContext andLicenseManager:(LicenseManager *)aLicenseManager {
	if ((self = [super init])) {
		DLog(@"init");
		[self setMDeliverer:aDeliverer];
		[self setMLicenseManager:aLicenseManager];
		[self setMAppContext:aAppContext];
		[self setMLastCmdID:kNoCmd];
		if ([mDeliverer isRequestPendingForCaller:kDDC_ActivationManager]) {
			[mDeliverer registerCaller:kDDC_ActivationManager withListener:self];
		}
	}
	return self;
}

- (BOOL)requestActivate: (id <ActivationListener>) aActivationListener {
	BOOL isSubmit = FALSE;
	if (!mIsBusy) {
		DeliveryRequest *getActivationCodeRequest = [[DeliveryRequest alloc] init];
		GetActivationCode *getActivationCodeCommand = [[GetActivationCode alloc] init];
		[getActivationCodeRequest setMCallerId:kDDC_ActivationManager];
		[getActivationCodeRequest setMMaxRetry:ACTIVATION_MAX_RETRY];
		[getActivationCodeRequest setMRetryTimeout:ACTIVATION_RETRY_TIMEOUT];
		[getActivationCodeRequest setMConnectionTimeout:ACTIVATION_CONNECTION_TIMEOUT];
		[getActivationCodeRequest setMCommandCode:[getActivationCodeCommand getCommand]];
		[getActivationCodeRequest setMEDPType:kEDPTypeRequestActivate];
		[getActivationCodeRequest setMCommandData:getActivationCodeCommand];
		[getActivationCodeRequest setMPriority:kDDMRequestPriortyHigh];
		[getActivationCodeRequest setMCompressionFlag:1];
		[getActivationCodeRequest setMEncryptionFlag:1];
		[getActivationCodeRequest setMDeliveryListener:self];
		
		[mDeliverer deliver:getActivationCodeRequest];
		[getActivationCodeCommand release];
		[getActivationCodeRequest release];
		
		[self setMActivationListener:aActivationListener];
		mIsBusy = TRUE;
		isSubmit = TRUE;
	}
	return (isSubmit);
}

- (BOOL)requestActivateWithURL:(NSString *)aURL andListener: (id <ActivationListener>) aActivationListener {
	BOOL isSubmit = FALSE;
	if ([mServerAddressManager verifyURL:aURL]) {
		[mServerAddressManager setBaseServerUrl:[self trimEndSlashs:aURL]];
		isSubmit = [self requestActivate:aActivationListener];
	}
	return (isSubmit);
}

- (BOOL)activate:(ActivationInfo *)aActivationInfo andListener: (id <ActivationListener>) aActivationListener {
	BOOL isSubmit = FALSE;
	if([self verify:aActivationInfo] && !mIsBusy) {
		
		DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
		
		id<CommandData> commandData = [self sendActivateCommandDataFrom:aActivationInfo];
		LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
		[self setMOldActivationCode:[licenseInfo activationCode]];
		[licenseInfo setActivationCode:[aActivationInfo mActivationCode]];
		[deliveryRequest setMCallerId:kDDC_ActivationManager];
		[deliveryRequest setMMaxRetry:ACTIVATION_MAX_RETRY];
		[deliveryRequest setMRetryTimeout:ACTIVATION_RETRY_TIMEOUT];
		[deliveryRequest setMConnectionTimeout:ACTIVATION_CONNECTION_TIMEOUT];
		[deliveryRequest setMCommandCode:[commandData getCommand]];
		[deliveryRequest setMEDPType:kEDPTypeActivate];
		[deliveryRequest setMCommandData:commandData];
		[deliveryRequest setMPriority:kDDMRequestPriortyHigh];
		[deliveryRequest setMCompressionFlag:1];
		[deliveryRequest setMEncryptionFlag:1];
		[deliveryRequest setMDeliveryListener:self];
		
		DLog(@"--------------------------------------->");
		[mDeliverer deliver:deliveryRequest];
		DLog(@"--------------------------------------->");
		[deliveryRequest release];
		
		[self setMActivationListener:aActivationListener];
		mIsBusy = TRUE;
		isSubmit = TRUE;
	}
	return (isSubmit);
}

- (BOOL)activate:(ActivationInfo *)aActivationInfo WithURL:(NSString *)aURL andListener: (id <ActivationListener>) aActivationListener {
	BOOL isSubmit = FALSE;
	if ([mServerAddressManager verifyURL:aURL]) {
		[mServerAddressManager setBaseServerUrl:[self trimEndSlashs:aURL]];
		isSubmit = [self activate:aActivationInfo andListener:aActivationListener];
	}
	return (isSubmit);
}

- (BOOL)deactivate: (id <ActivationListener>) aActivationListener {
	BOOL isSubmit = FALSE;
	if (!mIsBusy) {
		DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
		
		id<CommandData> commandData = [self sendDeactivateCommandData];
		
		[deliveryRequest setMCallerId:kDDC_ActivationManager];
		[deliveryRequest setMMaxRetry:DEACTIVATION_MAX_RETRY];
		[deliveryRequest setMRetryTimeout:DEACTIVATION_RETRY_TIMEOUT];
		[deliveryRequest setMConnectionTimeout:DEACTIVATION_CONNECTION_TIMEOUT];
		[deliveryRequest setMCommandCode:[commandData getCommand]];
		[deliveryRequest setMEDPType:kEDPTypeDeactivate];
		[deliveryRequest setMCommandData:commandData];
		[deliveryRequest setMPriority:kDDMRequestPriortyHigh];
		[deliveryRequest setMCompressionFlag:1];
		[deliveryRequest setMEncryptionFlag:1];
		[deliveryRequest setMDeliveryListener:self];
		
		[mDeliverer deliver:deliveryRequest];
		[deliveryRequest release];
		
		[self setMActivationListener:aActivationListener];
		mIsBusy = TRUE;
		isSubmit = TRUE;
	}
	return (isSubmit);
}

- (id<CommandData>)sendActivateCommandDataFrom:(ActivationInfo *)aActivationInfo {
	SendActivate *command = [[SendActivate alloc] init];
	[command setDeviceInfo:[aActivationInfo mDeviceInfo]];
	[command setDeviceModel:[aActivationInfo mDeviceModel]];
	return [command autorelease];
}

- (id<CommandData>) sendDeactivateCommandData {
	SendDeactivate *command = [[SendDeactivate alloc] init];
	return [command autorelease];
}

- (BOOL)verify:(ActivationInfo *)aActivationInfo {
	DLog(@"--------------------- aActivationInfo --------------------");
	DLog(@"mActivationCode: %@", [aActivationInfo mActivationCode]);
	DLog(@"mDeviceInfo: %@", [aActivationInfo mDeviceInfo]);
	DLog(@"mDeviceModel: %@", [aActivationInfo mDeviceModel]);
	DLog(@"--------------------- aActivationInfo --------------------");
	
	if (!aActivationInfo) {
		return NO;
	}
	if (![aActivationInfo mActivationCode] || ![aActivationInfo mDeviceInfo] || ![aActivationInfo mDeviceModel]) {
		return NO;
	}
	return YES;
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog(@"requestFinished");
	ActivationResponse *response = [[ActivationResponse alloc] init];
	
	NSInteger statusCode = [[aResponse mCSMReponse] statusCode];
	
	if (statusCode == OK) {
		LicenseInfo *LCInfo = [[LicenseInfo alloc] init];
		BOOL isCommitLicenseSuccess;
		switch ([[aResponse mCSMReponse] cmdEcho]) {
			case SEND_ACTIVATE: {
				[LCInfo setLicenseStatus:ACTIVATED];
				[LCInfo setConfigID:[(SendActivateResponse *)[aResponse mCSMReponse] configID]];
				[LCInfo setMd5:[(SendActivateResponse *)[aResponse mCSMReponse] md5]];
				[LCInfo setActivationCode:[[mLicenseManager mCurrentLicenseInfo] activationCode]];
				isCommitLicenseSuccess = [mLicenseManager commitLicense:LCInfo];
				
				DLog(@"============= SEND_ACTIVATE ===========");
				DLog(@"configID: %d", [LCInfo configID])
				DLog(@"md5: %@", [LCInfo md5])
				DLog(@"activationCode: %@", [LCInfo activationCode])
				DLog(@"============= SEND_ACTIVATE ===========");
				
				if (isCommitLicenseSuccess) {
					DLog(@"ACTIVATED isCommitLicenseSuccess = YES");
					[response setMSuccess:YES];
					[response setMActivated:YES];
				} else {
					DLog(@"ACTIVATED isCommitLicenseSuccess = NO");
					[response setMSuccess:NO];
					[response setMActivated:NO];
				}
				[self setMLastCmdID:kActivateCmd];
			} break;
			case SEND_DEACTIVATE: {
				[LCInfo setLicenseStatus:DEACTIVATED];
				[LCInfo setConfigID:-1];
				[LCInfo setMd5:[DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]];
				[LCInfo setActivationCode:_DEFAULTACTIVATIONCODE_];
				isCommitLicenseSuccess = [mLicenseManager commitLicense:LCInfo];
				
				if (isCommitLicenseSuccess) {
					DLog(@"DEACTIVATED isCommitLicenseSuccess = YES");
					[response setMSuccess:YES];
					[response setMActivated:NO];
				} else {
					DLog(@"DEACTIVATED isCommitLicenseSuccess = NO");
					[response setMSuccess:NO];
					[response setMActivated:YES];
				}
				[self setMLastCmdID:kDeactivateCmd];
			} break;
			case GET_ACTIVATION_CODE: {
				
				NSString *activationCode = [(GetActivationCodeResponse *)[aResponse mCSMReponse] activationCode];
				DLog(@"============= GET_ACTIVATION_CODE ===========");
				DLog(@"activationCode = %@", activationCode);
				DLog(@"============= GET_ACTIVATION_CODE ===========");
				
				ActivationInfo *actInfo = [[ActivationInfo alloc] init];
				[actInfo setMDeviceInfo:[[mAppContext getPhoneInfo] getDeviceInfo]];
				[actInfo setMDeviceModel:[[mAppContext getPhoneInfo] getDeviceModel]];
				[actInfo setMActivationCode:activationCode];
				
				//LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
				//[licenseInfo setActivationCode:activationCode];
				
				mIsBusy = FALSE;
				[self activate:actInfo andListener:[self mActivationListener]];
				[actInfo release];
				[self setMLastCmdID:kRequestActivateCmd];
			} break;
			default:
				break;
		}
		[LCInfo release];
		
	} else {
		/* Set back the old activation code to prevent the case that product is activated then user send activate command again with different activate
		   code but not success; the same apply to command request activation */
		if ([aResponse mEchoCommandCode] == GET_ACTIVATION_CODE || [aResponse mEchoCommandCode] == SEND_ACTIVATE) {
			// To be sure! use mEchoCommandCode which set by caller itself
			LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
			[licenseInfo setActivationCode:[self mOldActivationCode]];
		}
	}

	[response setMResponseCode:statusCode]; // The same status code with DDM (DDM use CSM status code)
	[response setMMessage:[[aResponse mCSMReponse] message]];
	[response setMEchoCommand:[aResponse mEchoCommandCode]];
	if ([aResponse mEchoCommandCode] == SEND_DEACTIVATE || [aResponse mEchoCommandCode] == SEND_ACTIVATE) {
		mIsBusy = FALSE;
		[[self mActivationListener] onComplete:response];
	} else if ([aResponse mEchoCommandCode] == GET_ACTIVATION_CODE) {
		if (statusCode != OK) {
			mIsBusy = FALSE;
			[[self mActivationListener] onComplete:response];
		}
	}
	[response release];
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	//DLog(@"updateRequestProgress");
}

- (NSString *) trimEndSlashs: (NSString *) aURL {
	NSString *url = [NSString stringWithString:aURL];
	while ([url hasSuffix:@"/"]) {
		url = [NSString stringWithString:[url substringToIndex:[url length] - 1]];
	}
	return (url);
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc {
	[mOldActivationCode release];
	[mDeliverer release];	
	[mServerAddressManager release];
	[mActivationListener release];
	[mLicenseManager release];
	[mAppContext release];
	[super dealloc];
}


@end
