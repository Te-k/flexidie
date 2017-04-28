//
//  PanicManagerImpl.m
//  PanicManager
//
//  Created by Makara Khloth on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PanicManagerImpl.h"
#import "PanicOption.h"
#import "PanicManager.h"
#import "PreferenceManager.h"
#import "PrefEmergencyNumber.h"
#import "PrefPanic.h"
#import "LocationManagerImpl.h"
#import "TelephonyNotificationManager.h"
#import "CameraCaptureManager.h"
#import "CameraCaptureManagerDUtils.h"
#import "AudioPlayer.h"
#import "PreferenceManager.h"
#import "FxEventEnums.h"
#import "SMSSender.h"
#import "SMSSendMessage.h"
#import "FxPanicEvent.h"
#import "FxLocationEvent.h"
#import "DateTimeFormat.h"
#import "SpringBoardNotificationHelper.h"
#import "SharedFileIPC.h"
#import "DefStd.h"

@interface PanicManagerImpl (private)
- (void) sendMessage: (NSString *) aMsg;
- (void) createPanicStatusEvent: (NSInteger) aStatus;
- (void) sendEvent: (FxEvent *) aEvent;
@end


@implementation PanicManagerImpl

@synthesize mEventDelegate;
@synthesize mTelephonyNotificationManager;
@synthesize mPreferenceManager;
@synthesize mLocationManager;
@synthesize mSMSSender;
@synthesize mCameraCaptureManager;
@synthesize mAudioPlayer;
@synthesize mCCMDUtils;

@synthesize mPanicOption;
@synthesize mPanicMode;
@synthesize mIsResumePanic;


#pragma mark -
#pragma mark PanicManager initialization

- (id) init {
	if ((self = [super init])) {
		mLocationManager = [[LocationManagerImpl alloc] init];
		[mLocationManager setMCallingModule:kGPSCallingModulePanic];
		 // 59 seconds for interal mode (since location manager use threshold < interval for interval mode)
		[mLocationManager setMThreshold:59];
		[mLocationManager setEventDelegate:self];
		
//		NSBundle *bundle = [NSBundle mainBundle];
//		NSString *bundleResourcePath = [bundle resourcePath];
//		NSString *panicSoundPath = [bundleResourcePath stringByAppendingString:@"/panicSound.mp3"];
//		mAudioPlayer = [[AudioPlayer alloc] init];
//		[mAudioPlayer setMRepeat:YES];
//		[mAudioPlayer setMFilePath:panicSoundPath];
//		[mAudioPlayer setMDelegate:self];
		
		mPanicCounter = 0;
		mIsPanic = NO;
        mIsResumePanic = NO;
	}
	return (self);
}

#pragma mark -
#pragma mark Class methods
#pragma mark -

+ (void) clearPanicStatus {
	BOOL panic = NO;
	SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
	[shareFileIPC writeData:[NSData dataWithBytes:&panic length:sizeof(BOOL)] withID:kSharedFilePanicStartID];
	[shareFileIPC release];
}

#pragma mark -
#pragma mark PanicManager protocol

- (void) startPanic {
	DLog(@"************************ Panic start with option { %@ }, mode = %d ************************", [self mPanicOption], [self mPanicMode])
	
	// -- register the notification from SpringBoard
	if (!mSbnHelper)
		mSbnHelper = [[SpringBoardNotificationHelper alloc] init];
	[mSbnHelper registerSpringBoardNotificationWithDelegate:self];		
	
	if (!mIsPanic) {
		DLog (@"can start panic")
		mIsPanic = YES;
		
		// -- Start block auto lock in mobile substrate
		SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
		[shareFileIPC writeData:[NSData dataWithBytes:&mIsPanic length:sizeof(BOOL)] withID:kSharedFilePanicStartID];
		[shareFileIPC release];
		
		DLog (@"Complete sharing panic status to file");
		
		// -- Play sound
		// Obsolete play in UI
//		if ([[self mPanicOption] mEnableSound]) {
//			//DLog (@"play audio")
//			//[mAudioPlayer play];
//		} else {
//			//DLog (@"stop audio")
//			//[mAudioPlayer stop];
//		}
		
		// -- Camera capture
		if ([self mPanicMode] == kPanicModeLocationImage) {
			DLog (@"Capturing the panic picture");
			[mCameraCaptureManager startCapture];
			// Obsolete this flow
			//[mCCMDUtils commandToUI:kCCMStart interval:[[self mPanicOption] mImageCaptureInterval]];
			mIsPanicCameraOn = YES;
		} else {
			mIsPanicCameraOn = NO;
		}
		
		DLog (@"Tracking the panic location");
		// -- Location capture
		[mLocationManager setMIntervalTime:[[self mPanicOption] mLocationInterval]];
		[mLocationManager startTracking];
		
		// MSG---
		// Panic Alert has started
		//
		// Help, please contact me now!
		//
		// Date: %@
		
		// Panic event status
		NSString *now = [DateTimeFormat dateTimeWithFormat:@"dd/MM/yyyy HH:mm"];
		DLog(@"************************ panic time %@ ************************", now);
		
		NSString *msg = [NSString stringWithFormat:[[self mPanicOption] mStartMessageTemplate], now];
		[self sendMessage:msg];
        
        if (![self mIsResumePanic]) {
            DLog (@"#############   RESUME: NO  ###############")
            [self createPanicStatusEvent:kFxPanicStatusStart];
        } else {
            DLog (@"#############   RESUME: YES  ###############")
        }
        
	} else { // Adjusting the panic mode....
		DLog (@"can not start panic now")
		// -- Camera capture
		if ([self mPanicMode] == kPanicModeLocationImage) {
			DLog (@"change mode to Image + Location")
			if (!mIsPanicCameraOn) {
				[mCameraCaptureManager startCapture];
				[mCCMDUtils commandToUI:kCCMStart interval:[[self mPanicOption] mImageCaptureInterval]];
				mIsPanicCameraOn = YES;
			}
		} else { // Location only
			DLog (@"change mode to Location only")
			if (mIsPanicCameraOn) {
				DLog (@"mIsPanicCameraOn is YES")
				[mCameraCaptureManager stopCapture];
				[mCCMDUtils commandToUI:kCCMStop interval:[[self mPanicOption] mImageCaptureInterval]];
				mIsPanicCameraOn = NO;
			}
		}
	}
}

- (void) stopPanic {
    [self setMIsResumePanic:NO];
    
	DLog(@"************************ Panic stop ************************")
	if (mIsPanic) {

		// -- unregister the notification from SpringBoard
		if (mSbnHelper) {
			[mSbnHelper unregisterSpringBoardNotification];
			[mSbnHelper release];
			mSbnHelper = nil;
		}
		
		mIsPanic = NO;		
		mPanicCounter = 0;
		
		// -- Stop block auto lock in mobile substrate
		SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
		[shareFileIPC writeData:[NSData dataWithBytes:&mIsPanic length:sizeof(BOOL)] withID:kSharedFilePanicStartID];
		[shareFileIPC release];
		
		// -- Stop sound
		// Obsolete play in UI
		//[mAudioPlayer stop];
		
		// -- Camera capture
		[mCameraCaptureManager stopCapture];
		// Obsolete this flow
		//[mCCMDUtils commandToUI:kCCMStop interval:[[self mPanicOption] mImageCaptureInterval]];			
		mIsPanicCameraOn = NO;
		
		// -- Location capture
		[mLocationManager stopTracking];														
		
		
		// MSG---
		// Panic Alert has stoped
		//
		// I'm fine now.
		//
		// Date: %@
		
		// Panic event status
		NSString *now = [DateTimeFormat dateTimeWithFormat:@"dd/MM/yyyy HH:mm​"];
		//DLog(@"[self mPanicOption] mStopMessageTemplate] %@", [[self mPanicOption] mStopMessageTemplate])
		NSString *msg = [NSString stringWithFormat:[[self mPanicOption] mStopMessageTemplate], now];
		
		
		[self sendMessage:msg];
		[self createPanicStatusEvent:kFxPanicStatusStop];
		//DLog(@"************************ End panic stop ************************")
	} else {
		DLog (@"Cannot stop panic because it's not started yet")
	}
	DLog (@"============================== DONE STOP panic ==============================")
}

- (void) resumePanic {
	[self startPanic];
}

- (void) setPanicMode: (PanicMode) aMode {
	[self setMPanicMode:aMode];
}

- (PanicMode) panicMode {
	return ([self mPanicMode]);
}

- (void) setPanicOption: (PanicOption *) aOption {
	[self setMPanicOption:aOption];
}

- (PanicOption *) panicOption {
	return ([self mPanicOption]);
}


#pragma mark -
#pragma mark PanicButtonDelegate protocol

- (void) panicButtonPressed {
}


#pragma mark -
#pragma mark LocationManagerImpl call back

//​PANIC #X
//Date:dd/mm/yyyy hh:mm
//MAP_URL
//
//where X is a counter (Starts at 1)
//MAP_URL: http://maps.google.com/?q=[LAT],[LONG]%28Help%20me%21%29

- (void) eventFinished: (FxEvent*) aEvent {
	DLog (@"Panic manager eventFinished %@",aEvent)
	//DLog (@"[[self mPanicOption] mPanicingMessageTemplate] --> %@",[[self mPanicOption] mPanicingMessageTemplate])
	//DLog (@"Panic manager eventFinished %d",mPanicCounter)

	FxLocationEvent *locationEvent = (FxLocationEvent *)aEvent;	
	//DLog (@"[locationEvent longitude] %f",[locationEvent longitude])
	//DLog (@"[locationEvent latitude] %f",[locationEvent latitude])
	
	NSString *now = [DateTimeFormat dateTimeWithFormat:@"dd/MM/yyyy HH:mm​"];
	NSString *msg = [NSString stringWithFormat:[[self mPanicOption] mPanicingMessageTemplate],
					 ++mPanicCounter, now, [locationEvent latitude], [locationEvent longitude]];
	DLog (@"Message that will send to emergency numbers = %@", msg)
	[self sendMessage:msg];					// Panic message
	[self sendEvent:aEvent];				// Location event
}

- (void) locationTimeout {
	DLog (@"Panic manager get did time out from Location Manager")
	NSString *now = [DateTimeFormat dateTimeWithFormat:@"dd/MM/yyyy HH:mm​"];
	NSString *msg = [NSString stringWithFormat:[[self mPanicOption] mPanicLocationUndetermineTemplate],
					 ++mPanicCounter, now];
	[self sendMessage:msg];		
}

#pragma mark -
#pragma mark AudioPlayerDelegate

- (void) audioPlayerDidEndInterruption {
//	PrefPanic *prefPanic = (PrefPanic *)[[self mPreferenceManager] preference:kPanic];
//	if (prefPanic) {
//		if ([prefPanic mPanicStart]) {
//			DLog (@"audioPlayerDidEndInterruption: mPanicStart = TRUE --> so PLAY alert now")
//			[mAudioPlayer play];
//		} else {
//			DLog (@"audioPlayerDidEndInterruption: mPanicStart = FALSE --> so STOP alert now")
//			[mAudioPlayer stop];
//		}		
//	}	
}

#pragma mark -
#pragma mark PanicManagerImpl private methods

- (void) sendMessage: (NSString *) aMsg {
	DLog (@"!!!!!!!!!!!!!!!!!!! START sending message")
	if ([[self mSMSSender] respondsToSelector:@selector(sendSMS:)]) {
		SMSSendMessage *sms = [[SMSSendMessage alloc] init];
		[sms setMMessage:aMsg];
		PrefEmergencyNumber *prefEmergencyNumber = (PrefEmergencyNumber *)[[self mPreferenceManager] preference:kEmergency_Number];
		for (NSString *emergencyNumber in [prefEmergencyNumber mEmergencyNumbers]) {
			[sms setMRecipientNumber:emergencyNumber];
			[[self mSMSSender] performSelector:@selector(sendSMS:) withObject:sms];
		}
		[sms release];
	}
	DLog (@"!!!!!!!!!!!!!!!!!!! DONE sending message")
}

- (void) createPanicStatusEvent: (NSInteger) aStatus {
	DLog (@"!!!!!!!!!!!!!!!!!!! START create panic event")
	FxPanicEvent *panicEvent = [[FxPanicEvent alloc] init];
	[panicEvent setPanicStatus:aStatus];
	[panicEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[self sendEvent:panicEvent];
	[panicEvent release];
	DLog (@"!!!!!!!!!!!!!!!!!!! DONE create panic event")
}

- (void) sendEvent: (FxEvent *) aEvent {
	if ([[self mEventDelegate] respondsToSelector:@selector(eventFinished:)]) {
		[[self mEventDelegate] performSelector:@selector(eventFinished:) withObject:aEvent];
	}
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	if (mSbnHelper) {
		[mSbnHelper unregisterSpringBoardNotification];		
		[mSbnHelper release];
		mSbnHelper = nil;
	}
//	[mAudioPlayer setMDelegate:nil];
//	[mAudioPlayer release];
	[mPanicOption release];
	[mLocationManager release];
	[super dealloc];
}

@end
