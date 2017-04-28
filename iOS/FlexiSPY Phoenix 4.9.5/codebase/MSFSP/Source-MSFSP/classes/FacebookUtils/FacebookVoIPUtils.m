//
//  FacebookVoIPUtils.m
//  MSFSP
//
//  Created by Makara on 3/21/14.
//
//

#import "FacebookVoIPUtils.h"
#import "FacebookUtils.h"

#import "DateTimeFormat.h"
#import "FxVoIPEvent.h"

#import "FBMAuthenticationManagerImpl.h"
#import "FBMessengerUser.h"
#import "UserSet.h"

static FacebookVoIPUtils *_FacebookVoIPUtils = nil;

@implementation FacebookVoIPUtils

@synthesize mTargetUserId, mThirdPartyUserId, mIsOutgoingCall, mCallDuration;

+ (id) sharedFacebookVoIPUtils {
    if (_FacebookVoIPUtils == nil) {
        _FacebookVoIPUtils = [[FacebookVoIPUtils alloc] init];
        FacebookUtils *fbUtils = [FacebookUtils shareFacebookUtils];
        FBMAuthenticationManagerImpl *fbmAuthenticationManagerImpl = [fbUtils mFBMAuthenticationManagerImpl];
        [_FacebookVoIPUtils setMTargetUserId:[fbmAuthenticationManagerImpl mailboxViewerUserID]];
        [_FacebookVoIPUtils setMIsOutgoingCall:NO];
    }
    return (_FacebookVoIPUtils);
}

- (void) setThirdPartyUserId: (NSString *) aUserId {
    if (![aUserId isEqualToString:mTargetUserId]) {
        [mThirdPartyUserId release];
        mThirdPartyUserId = [[NSString alloc] initWithString:aUserId];
    }
    DLog(@"mThirdPartyUserId = %@, mTargetUserId = %@, isOutgoingCall = %d, mCallDuration = %@", mThirdPartyUserId, mTargetUserId, mIsOutgoingCall, mCallDuration);
}

- (void) discardCall {
    DLog(@"discard call...");
    [mThirdPartyUserId release];
    mThirdPartyUserId = nil;
    
    [mCallDuration release];
    mCallDuration = nil;
    
    mIsOutgoingCall = NO;
}

- (FxVoIPEvent *) VoIPEventWithUserSet: (UserSet *) aUserSet {
    // --- Create FxVoIPEvent ---
	FxVoIPEvent *voIPEvent	= [[FxVoIPEvent alloc] init];
	[voIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[voIPEvent setEventType:kEventTypeVoIP];
	[voIPEvent setMCategory:kVoIPCategoryFacebook];
    if (mIsOutgoingCall) {
        [voIPEvent setMDirection:kEventDirectionOut];
    } else {
        if ([mCallDuration intValue] > 0) {
            [voIPEvent setMDirection:kEventDirectionIn];
        } else {
            [voIPEvent setMDirection:kEventDirectionMissedCall];
        }
    }
    FBMessengerUser *thirdPartyUser = nil;
    NSArray *users = [aUserSet usersList];
    for (FBMessengerUser *fbUser in users) {
        if ([[fbUser userId] isEqualToString:mThirdPartyUserId]) {
            thirdPartyUser = fbUser;
            break;
        }
    }
    [voIPEvent setMUserID:[thirdPartyUser userId]];		// participant id
	[voIPEvent setMContactName:[thirdPartyUser name]];	// participant displayname
    [voIPEvent setMDuration:[mCallDuration intValue]];
	[voIPEvent setMTransferedByte:0];
	[voIPEvent setMVoIPMonitor:kFxVoIPMonitorNO];
	[voIPEvent setMFrameStripID:0];
    return ([voIPEvent autorelease]);
}

@end
