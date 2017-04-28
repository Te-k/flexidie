//
//  AlertLockHook.h
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFCR.h"

#import "SpringBoard.h"
#import "SBUIController.h"
#import "SBApplication.h"
#import "SBApplicationController.h"
#import "VolumeControl.h"
#import "DeviceLockManagerUtils.h"
#import "SBApplication.h"
#import "SBAwayController.h"
#import "AlertLockStatus.h"
#import "SBAlertItemsController.h"
#import "SBBulletinBannerController.h"
#import "SBBulletinBannerItem.h"
#import "SMSAlertItem.h"
#import "BBBulletin.h"


// Restriction
#import "SBSMSAlertItem.h"
#import "BlockEvent.h"
#import "RestrictionHandler.h"
#import "RestrictionManagerUtils.h"
#import "WhatsAppUtils.h"

#import "CKIMDBMessage.h"
#import "SharedFileIPC.h"
#import "DefStd.h"


#pragma mark SpringBoard

// ********************************************************************************************
//					SpringBoard
// ********************************************************************************************

HOOK(SpringBoard, menuButtonDown$, void, struct __GSEvent * arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> menu button DOWN");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		//DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, menuButtonDown$, arg1);
	}
}

HOOK(SpringBoard, menuButtonUp$, void, struct __GSEvent *arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> menu button UP");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		//DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, menuButtonUp$, arg1);
	}
}

HOOK(SpringBoard, lockButtonDown$, void, struct __GSEvent *arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> lock Button Down");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		//DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, lockButtonDown$, arg1);
	}
}

HOOK(SpringBoard, lockButtonUp$, void, struct __GSEvent *arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> lock Button UP");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		//DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, lockButtonUp$, arg1);
	}
}

HOOK(SpringBoard, lockButtonWasHeld, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> lock Button was hold");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		//DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, lockButtonWasHeld);
	}
}

HOOK(SpringBoard, quitTopApplication$, void, struct __GSEvent * arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>quitTopApplication: %@", arg1);
	CALL_ORIG(SpringBoard, quitTopApplication$, arg1);	
}

HOOK(SpringBoard, showSpringBoardStatusBar, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> showSpringBoardStatusBar ");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, showSpringBoardStatusBar);
	}
}


#pragma mark VolumeControl

// ********************************************************************************************
//					VolumeControl
// ********************************************************************************************

// This is called when volume up button is pressed
HOOK(VolumeControl, increaseVolume, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> increaseVolume %f", [self volume]);
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		//DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(VolumeControl, increaseVolume);
	}
}

// This is called when volume down button is pressed
HOOK(VolumeControl, decreaseVolume, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> decreaseVolume %f", [self volume]);
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		//DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(VolumeControl, decreaseVolume);
	}
}

#pragma mark SBUIController

// ********************************************************************************************
//					SBUIController
// ********************************************************************************************

/**
 - Method name:		SBUIController --> _showNotificationsGestureBeganWithLocation& 
 - Purpose:			prevent the gesture begin. As a result, user cannot drag down Notification Center sheet
 - Arg(s):			struct CGPoint
 - Return:			none
 */
HOOK(SBUIController, _showNotificationsGestureBeganWithLocation$, void, struct CGPoint arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, _showNotificationsGesture	Began	WithLocation");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SBUIController, _showNotificationsGestureBeganWithLocation$, arg1);
	}
}

/**
 - Method name:		SBUIController --> finishLaunching
 - Purpose:			check a previous lock state of the device and then lock or unlock the device according to the previous state
 - Arg(s):			none
 - Return:			none
 */
HOOK(SBUIController, finishLaunching, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> finishLaunching");
	CALL_ORIG(SBUIController, finishLaunching);
	
	// check previous lock state before respring or reboot
	DeviceLockManagerUtils *deviceLockMgrUtil = [DeviceLockManagerUtils sharedDeviceLockManagerUtils];
	[deviceLockMgrUtil performSelector:@selector(checkPreviousLockStateAndKeepLockOrUnlockDevice)
							 withObject:nil
							 afterDelay:1.5];
}

/**
 - Method name:		SBUIController --> activateApplicationAnimated& 
 - Purpose:			This is required to stop some applications from launching
 - Arg(s):			SBApplication
 - Return:			none
 */
HOOK(SBUIController, activateApplicationAnimated$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, activateApplicationAnimated$");
	DLog(@"arg1 %@", arg1);
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SBUIController, activateApplicationAnimated$, arg1);
	}
}


#pragma mark SBApplication

// ********************************************************************************************
//					SBApplication
// ********************************************************************************************

HOOK(SBApplication, launchSucceeded$, void, BOOL arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, launchSucceeded");
	DLog(@"bool %d self, %@",arg1, self);
	
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
		
		CALL_ORIG(SBApplication, launchSucceeded$, arg1);
		
		UIApplication *uiApplication = [objc_getClass("UIApplication") sharedApplication];
		
		[(SpringBoard *) uiApplication quitTopApplication:nil];		// quit the application running on top
		[(SpringBoard *) uiApplication hideSpringBoardStatusBar];	// hide spring board status bar
		[uiApplication setStatusBarHidden:YES];
		
		//		DeviceLockManagerUtils *util = [DeviceLockManagerUtils sharedDeviceLockManagerUtils];
		//		[util performSelector:@selector(bringLockViewToFront) withObject:nil afterDelay:1];
		
	} else {
		CALL_ORIG(SBApplication, launchSucceeded$, arg1);	
	}
}

#pragma mark SBAwayController


// ********************************************************************************************
//					SBAwayController
// ********************************************************************************************

// prevent device to undim the screen
HOOK(SBAwayController, dimScreen$, void, BOOL arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAwayController, dimScreen");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
	} else {
		CALL_ORIG(SBAwayController, dimScreen$, arg1);
	}
}


#pragma mark SBAlertItemsController

// ********************************************************************************************
//					SBAlertItemsController
// ********************************************************************************************


id getInstanceVariable(id x, NSString * s) {
    Ivar ivar = class_getInstanceVariable([x class], [s UTF8String]);
    return object_getIvar(x, ivar);
}


// block alerts on the middle of screen
// block incoming WhatsApp notification
HOOK(SBAlertItemsController, activateAlertItem$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAlertItemsController, activateAlertItem$, %@", arg1);
	// --PRIORITY--
	// 1. Block first
	// 2. Lock device later
	BOOL blockOrginalCall = NO;
	
	// Known issue even we hook SBSMSManager to block incoming sms/mms from there, sometime this method still called
	// if this method called a long with the one in SBSMSManager, there will be two popup dialog box of blocking
	// this method is called associate with settings of notification in Settings application (specified to alert)
	
	if ([arg1 isKindOfClass:NSClassFromString(@"SBSMSAlertItem")]) { // IOS 5 SMSAlertItem
		SBSMSAlertItem *smsAlertItem = arg1;
		NSString *address = [smsAlertItem address];
		DLog (@"Address of this alert item = %@", address);
		
		CKSMSMessage *ckSMSMessage = nil;
		object_getInstanceVariable(smsAlertItem, "_message", (void **)&ckSMSMessage);
		DLog (@"Instance variable of SBSMSAlertItem is = %@", ckSMSMessage);
		
		if (ckSMSMessage) {
			// In SMS: one part is text, no subject
			NSArray *parts = [SMSUtils messageParts:ckSMSMessage];
			NSInteger blockEventType = ([SMSUtils isSMS:parts] &&
										[[ckSMSMessage subject] length] == 0) ? kSMSEvent : kMMSEvent;
			BlockEvent *blockEvent = [MessageManager blockEventWithType:blockEventType
															  direction:kBlockEventDirectionIn
														telephoneNumber:address
															contactName:nil
														   participants:[NSArray arrayWithObject:address]
																   data:nil];
			
			if ([RestrictionHandler blockForEvent:blockEvent]) {
				[ckSMSMessage permanentlyRemoveMessage];
				
				if (![[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
					[RestrictionHandler showBlockMessage];
				}
				blockOrginalCall = YES;
			}
		}
	} 
	else if ([arg1 isKindOfClass:NSClassFromString(@"SMSAlertItem")]) {
		//
		// If it's SMS or MMS IMChat and IMAccount will return nil
		CKIMDBMessage *ckIMDBMessage = nil;
		object_getInstanceVariable(arg1, "_message", (void **)&ckIMDBMessage);
		DLog (@"Instance variable of SMSAlertItem is = %@, IMChat = %@, IMAccount = %@", ckIMDBMessage,
			  [ckIMDBMessage chat], [ckIMDBMessage account]);
		
		if (ckIMDBMessage) {
			NSInteger blockEventType = kSMSEvent;
			NSString *address = [ckIMDBMessage address];
			if ([ckIMDBMessage isMadrid]) { // IMessage
				blockEventType = kIMEvent;
			} else { // SMS, MMS
				// In SMS: one part is text, no subject
				NSArray *parts = [ckIMDBMessage messageParts];
				blockEventType = ([SMSUtils isSMS:parts] &&
								  [[ckIMDBMessage subject] length] == 0) ? kSMSEvent : kMMSEvent;
			}
			DLog (@"Blocking event type = %d, address = %@", blockEventType, address);
			BlockEvent *blockEvent = [MessageManager blockEventWithType:blockEventType
															  direction:kBlockEventDirectionIn
														telephoneNumber:address
															contactName:nil
														   participants:[NSArray arrayWithObject:address]
																   data:nil];
			
			if ([RestrictionHandler blockForEvent:blockEvent]) {
				if (blockEventType == kIMEvent && ![ckIMDBMessage hasAttachments]) {
					// Create IM event capture
					IMChat *madridChat = [ckIMDBMessage chat];
					DLog (@"IMChat of this madrid message = %@, IMMessage = %@", madridChat, [madridChat lastMessage]);
					Class $CKMadridMessage = objc_getClass("CKMadridMessage");
					DLog (@"CKMadridMessage class object = %@", $CKMadridMessage);
					CKMadridMessage *ckMadridMessage = [[$CKMadridMessage alloc] initWithIMMessage:[madridChat lastMessage]];
					DLog (@"Object of class CKMadridMessage = %@", ckMadridMessage)
					
					[SMSUtils createEvent:ckMadridMessage
								recipient:[madridChat participants]
						   blockEventType:kIMEvent
								direction:kBlockEventDirectionIn];
					[ckMadridMessage release];
				}
				
				[MessageManager permanentlyRemoveMessage:[ckIMDBMessage identifier]];
				
				if (![[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
					[RestrictionHandler showBlockMessage];
				}
				blockOrginalCall = YES;
			}
		}
	} else if ([arg1 isKindOfClass:NSClassFromString(@"SBBulletinModalAlert")]) {		// for blocking WhatsApp
		//DLog (@"Alert item > %@", arg1)
		//DLog (@"Alert item > %@", [arg1 class])
		BBBulletin *bulletin				= getInstanceVariable(arg1, @"_bulletin");
		//DLog (@"bulletin %@", [bulletin title])	// WhatsApp
		//DLog (@"bulletin %@", [bulletin sectionID]) // net.whatsapp.WhatsApp
		if ([[bulletin sectionID] isEqualToString:@"net.whatsapp.WhatsApp"]) {
			if ([[RestrictionManagerUtils sharedRestrictionManagerUtils] restrictionEnabled]) {
				DLog(@"--------------------- WhatsApp Alert Notification is BLOCKED  ---------------------- ")
				blockOrginalCall = YES;
			}				
		}
	}
	
	if (!blockOrginalCall && [[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		blockOrginalCall = YES;
	}
	
	if (!blockOrginalCall) {
		CALL_ORIG(SBAlertItemsController, activateAlertItem$, arg1);
	}
}


#pragma mark SBBulletinBannerController

// ********************************************************************************************
//					SBBulletinBannerController
// ********************************************************************************************

// block banner alert for alert and lock feature
HOOK(SBBulletinBannerController, _presentBannerForItem$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBBulletinBannerController, _presentBannerForItem");
	DLog(@"_presentBannerForItem arg1: %@", arg1) // SBBulletinBannerItem
	SBBulletinBannerItem *bannerItem = arg1;
	DLog(@"_appName %@", [bannerItem _appName])
	DLog(@"title %@", [bannerItem title])
	DLog(@"message %@", [bannerItem message])

	BOOL isRequiredToCallOriginal = YES;
	
	
	// -- Alert and Lock checking
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {		
		isRequiredToCallOriginal = NO;
	
	// -- WhatsApp blocking
	} else if ([[bannerItem _appName] isEqualToString:@"WhatsApp"]	||
			   [[bannerItem _appName] isEqualToString:@"Messages"]) {					// Check only WhatsApp		
		if ([[RestrictionManagerUtils sharedRestrictionManagerUtils] restrictionEnabled]) {
			DLog(@"--------------------- WhatsApp (%d) or Messages (%d) Banner Notificaiton is blocked ----------------------", 
				 [[bannerItem _appName] isEqualToString:@"WhatsApp"], [[bannerItem _appName] isEqualToString:@"Messages"])
			//isRequiredToDismissBanner = YES;		
			isRequiredToCallOriginal = NO;
		}		
	} else {
		isRequiredToCallOriginal = YES;
	}			   
	
	if (isRequiredToCallOriginal)
		CALL_ORIG(SBBulletinBannerController, _presentBannerForItem$, arg1);
	
//	if (isRequiredToDismissBanner)
//		[self performSelector:@selector(dismissBanner) withObject:nil afterDelay:1];
}



#pragma mark -
#pragma mark Auto lock
#pragma mark -
HOOK(SpringBoard, autoLock, void) {
	DLog (@"SpringBoard autoLock -----------------");
	
	BOOL block = NO;
	// Lock device
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		block = YES;
	}
	
	if (!block) { // Panic
		// -- Stop block auto lock in mobile substrate
		SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
		NSData *panicStartData = [shareFileIPC readDataWithID:kSharedFilePanicStartID];
		if (panicStartData) {
			BOOL panicStart = NO;
			[panicStartData getBytes:&panicStart length:sizeof(BOOL)];
			block = panicStart;
		}
		[shareFileIPC release];
	}
	
	if (!block) {
		CALL_ORIG(SpringBoard, autoLock);
	}
}



/*
 // not used
 HOOK(SpringBoard, applicationExited$, void, struct __GSEvent * arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> applicationExited");
 CALL_ORIG(SpringBoard, applicationExited$, arg1);
 }
 
 // not used
 HOOK(SpringBoard, anotherApplicationFinishedLaunching$, void, struct __GSEvent * arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> anotherApplicationFinishedLaunching%@", arg1);
 CALL_ORIG(SpringBoard, anotherApplicationFinishedLaunching$, arg1);
 }
 
 // not used
 HOOK(SpringBoard, applicationSuspend$, void, struct __GSEvent * arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> applicationSuspend ");
 CALL_ORIG(SpringBoard, applicationSuspend$, arg1);
 }
 */

/*
// not used
HOOK(SBUIController, activateApplicationFromSwitcher$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, activateApplication FromSwitcher");
	DLog(@"arg1 %@", arg1);
	CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
}

// not used
HOOK(SBUIController, animateApplicationSuspend$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, animateApplication Suspend");
	DLog(@"arg1 %@", arg1);
	CALL_ORIG(SBUIController, animateApplicationSuspend$, arg1);
}

// not used
HOOK(SBUIController, animateApplicationActivation$animateDefaultImage$scatterIcons$, void, id arg1, BOOL arg2, BOOL arg3) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, animateApplication Activation ");
	DLog(@"arg1 %@", arg1);
	CALL_ORIG(SBUIController, animateApplicationActivation$animateDefaultImage$scatterIcons$, arg1,arg2, arg3);
}
*/



/*
 // not used
 HOOK(SBApplication, activate, void) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, activate");
 DLog(@"self, %@", self);
 CALL_ORIG(SBApplication, activate);
 }
 */

/**
 - Method name:		SBApplication --> launchSucceeded& 
 - Purpose:			This method is called when an application is already launched and appeared on the screen
 - Arg(s):			BOOL
 - Return:			none
 */

/*
 // not used
 HOOK(SBApplication, launch, void) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, launch");
 DLog(@"self, %@", self);
 CALL_ORIG(SBApplication, launch);
 }
 
 // not used
 // class method
 HOOK(SBApplication, initialize, void) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, initialize");
 CALL_ORIG(SBApplication, initialize);	
 }
 */

// ********************************************************************************************
//					SBAlertWindow
// ********************************************************************************************

// doesn't work on ios 4.3.3
// work on ios 5.0.1
/**
 - Method name:		SBAlertWindow --> displayAlert& 
 - Purpose:			prevent the calling view to show on top of our lock screen
 - Arg(s):			SBUIFullscreenAlertAdapter
 - Return:			none
 */
//HOOK(SBAlertWindow, displayAlert$, void, id arg1) {
//	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAlertWindow, displayAlert %@",arg1);
//	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
//		CALL_ORIG(SBAlertWindow, displayAlert$, arg1);
//		[self dismissWindow:arg1];
//	} else {
//		CALL_ORIG(SBAlertWindow, displayAlert$, arg1);	// need to call, otherwise ALL app can not be open when unlock
//	}
//}
//HOOK(SBAwayController, lock, void) {
//	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAwayController, lock");
//	CALL_ORIG(SBAwayController, lock);
//	
//}
//
//HOOK(SBAwayController, unlockWithSound$, void, BOOL arg1) {
//	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAwayController, unlockWithSound");
//	CALL_ORIG(SBAwayController, unlockWithSound$, arg1);
//}

