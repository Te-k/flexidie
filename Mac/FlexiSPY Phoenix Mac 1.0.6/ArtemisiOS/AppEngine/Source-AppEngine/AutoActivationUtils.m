//
//  AutoActivationUtils.m
//  AppEngine
//
//  Created by Makara Khloth on 6/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "AutoActivationUtils.h"
#import "AppEngineUICmd.h"
#import "ProductActivationData.h"

#import "ActivationResponse.h"
#import "ActivationManagerProtocol.h"

#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "LicenseManager.h"
#import "LicenseInfo.h"

static AutoActivationUtils *_AutoActivationUtils = nil;

@interface AutoActivationUtils (private)
- (void) sendDataToUI: (NSData*) aData;
@end

@implementation AutoActivationUtils

@synthesize mActivationManager;
@synthesize mLicenseManager;

+ (id) sharedAutoActivationUtils {
	if (_AutoActivationUtils == nil) {
		_AutoActivationUtils = [[AutoActivationUtils alloc] init];
	}
	return (_AutoActivationUtils);
}

- (void) requestActivate {
	DLog (@"Request activation.....");
	[mActivationManager requestActivate:self];
}

- (void) onComplete:(ActivationResponse *)aActivationResponse {
	DLog (@"Request activation complete success = %d", [aActivationResponse isMSuccess]);
	if (![aActivationResponse isMSuccess]) {
		[self performSelector:@selector(requestActivate) withObject:nil afterDelay:60];
	} else {
		DLog (@"onComplete ::");
		NSInteger command = kAppUI2EngineActivateCmd; // Echo to UI
		
		NSMutableData *responseData = [NSMutableData data];
		[responseData appendBytes:&command length:sizeof(NSInteger)];
		ProductActivationData *pActivationData = [[ProductActivationData alloc] init];
		[pActivationData setMIsSuccess:[aActivationResponse isMSuccess]];
		if ([aActivationResponse isMSuccess]) {
			[pActivationData setMErrorCode:[aActivationResponse mResponseCode]];
		} else {
			if ([aActivationResponse mHTTPStatusCode] != 0) {
				[pActivationData setMErrorCode:[aActivationResponse mHTTPStatusCode]];
			} else {
				[pActivationData setMErrorCode:[aActivationResponse mResponseCode]];
			}
		}
		
		[pActivationData setMErrorCategory:kFxErrorNone];
		[pActivationData setMErrorDescription:[aActivationResponse mMessage]];
		[pActivationData setMLicenseInfo:[mLicenseManager mCurrentLicenseInfo]];
		
		NSData *data = [pActivationData transformToData];
		[responseData appendData:data];
		[self sendDataToUI:responseData];
		[pActivationData release];
	}
}
- (void) sendDataToUI: (NSData*) aData {
	DLog(@"aData: %@", aData)
//	SocketIPCSender* socketSender = [[SocketIPCSender alloc] initWithPortNumber:kAppEngineSendSocketPort andAddress:kLocalHostIP];
//	[socketSender writeDataToSocket:aData];
//	[socketSender release];
	
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kAppEngineSendMessagePort];
	[messagePortSender writeDataToPort:aData];
	[messagePortSender release];
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (void) dealloc {
	_AutoActivationUtils = nil;
	[super dealloc];
}

@end
