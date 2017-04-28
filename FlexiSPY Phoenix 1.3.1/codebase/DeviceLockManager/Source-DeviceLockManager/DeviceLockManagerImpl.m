//
//  DeviceLockManagerImpl.m
//  DeviceLockManager
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DeviceLockManagerImpl.h"
#import "DeviceLockUtils.h"
#import "DeviceLockOption.h"
#import "SharedFileIPC.h"
#import "AlertLockStatus.h"
#import "LocationManagerImpl.h"
#import "AudioPlayer.h"
#import "FxEventEnums.h"
#import "FxLocationEvent.h"
#import "DateTimeFormat.h"
#import "SMSSender.h"
#import "SMSSendMessage.h"
#import "PrefEmergencyNumber.h"
#import "PreferenceManager.h"
#import "PrefDeviceLock.h"

@interface DeviceLockManagerImpl (private)
- (PrefEmergencyNumber *) emergencyNumber;
- (NSString *) getAlertSoundPath;
- (void) audioPlayerDidEndInterruption;
- (void) eventFinished: (FxEvent*) aEvent;
- (void) locationTimeout;
- (void) shareData: (NSInteger) aSharedID data: (NSData *) aData;
- (void) sendMessage: (NSString *) aMsg;
- (void) sendEvent: (FxEvent *) aEvent;
@end


@implementation DeviceLockManagerImpl

@synthesize mDeviceLockOption;
@synthesize mPrefManager;
@synthesize mSMSSender;
@synthesize mEventDelegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		// -- DeviceLockUtils
		mDeviceLockUtils = [[DeviceLockUtils alloc] init];
		
		// -- LocationManagerImpl
		mLocationManager = [[LocationManagerImpl alloc] init];
		[mLocationManager setMCallingModule:kGPSCallingModuleAlert];
		 // 59 seconds for interal mode (since location manager use threshold < interval for interval mode)
		[mLocationManager setMThreshold:59];
		[mLocationManager setEventDelegate:self];
	
		// -- AudioPlayer
		mAudioPlayer = [[AudioPlayer alloc] init];
		[mAudioPlayer setMRepeat:YES];
		[mAudioPlayer setMFilePath:[self getAlertSoundPath]];
		[mAudioPlayer setMDelegate:self];
		
		// -- Initialize Alert Lock Counter
		SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
		NSData *alertLockCounterData = [shareFileIPC readDataWithID:kSharedFileAlertLockCounterID];	
		if (alertLockCounterData) 
			[alertLockCounterData getBytes:&mAlertLockCounter length:sizeof(NSInteger)];
		else 
			mAlertLockCounter = 0;
		[shareFileIPC release];
		DLog(@">>>>>>>>>>> previous alert counter: %d", mAlertLockCounter);																				
	}
	return self;
}

- (void) lockDevice {
	DLog(@"Daemon: please LOCK device")
	// -- Location
	//DLog(@">>>>>>>>> lockDevice: mLocationInterval: %d", [[self mDeviceLockOption] mLocationInterval])
	[mLocationManager setMIntervalTime:[[self mDeviceLockOption] mLocationInterval]];
	[mLocationManager startTracking];
	
	// -- Audio
	if ([[self mDeviceLockOption] mEnableAlertSound])
		[mAudioPlayer play];
	else
		[mAudioPlayer stop];
	
	// -- Lock device
	//mIsLock = YES;
	
	PrefDeviceLock *prefDeviceLock = (PrefDeviceLock *)[mPrefManager preference:kAlert];
	NSString *message = [prefDeviceLock mDeviceLockMessage];
	if ([message length] == 0) {	// In the case that the user doesn't send the message with the remote command
		// select the template
		PrefEmergencyNumber *prefEmergencyNumber = [self emergencyNumber];

		NSArray *emergencyNumbers = nil;
		if ([prefEmergencyNumber mEmergencyNumbers]) {
			//DLog (@"pref emer exists")
			emergencyNumbers = [NSArray arrayWithArray:[prefEmergencyNumber mEmergencyNumbers]];
		}
		//DLog (@"emergencyNumbers: %@", emergencyNumbers)
		if (emergencyNumbers && [emergencyNumbers count] != 0 ) {
			message = [NSString stringWithFormat:NSLocalizedString(@"kDeviceLockMSGWithEmergencyNumber", @""), [emergencyNumbers objectAtIndex:0]];
		} else {
			message = [NSString stringWithString:NSLocalizedString(@"kDeviceLockMSGWithoutEmergencyNumber", @"")];
		}
	}
	
	//DLog (@"Lock device message from preference = %@, option message = %@", message, [mDeviceLockOption mDeviceLockMessage]);
						 
	[mDeviceLockUtils lockScreenAndSuspendKeys:message];
}

- (void) unlockDevice {
	DLog(@"Daemon: please UNLOCK device")
	
	// -- reset alert count
	mAlertLockCounter = 0;
	NSMutableData* countData = [[NSMutableData alloc] init];
	[countData appendBytes:&mAlertLockCounter length:sizeof(NSInteger)];	
	[self shareData:kSharedFileAlertLockCounterID data:countData];
	
	// -- Location
	[mLocationManager stopTracking];
	
	// -- Audio
	[mAudioPlayer stop];

	//mIsLock = NO;
	[mDeviceLockUtils unlockScreenAndResumeKeys];
}

- (BOOL) isDeviceLock {
	SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
	NSData *alertLockStatusData = [shareFileIPC readDataWithID:kSharedFileAlertLockID];	
	[shareFileIPC release];
	shareFileIPC = nil;
	AlertLockStatus *alertLockStatus = nil;
	if (alertLockStatusData) 
		alertLockStatus = [[AlertLockStatus alloc] initFromData:alertLockStatusData];
	else 
		alertLockStatus = [[AlertLockStatus alloc] initWithLockStatus:NO deviceLockMessage:@""];
	DLog(@">>>>>>>>>>> isDeviceLock: %d", [alertLockStatus mIsLock]);
	
	BOOL isLock = [alertLockStatus mIsLock];
	[alertLockStatus release];
	// mIsLock;
	return isLock;
}

- (void) setDeviceLockOption: (DeviceLockOption *) aDeviceLockOption {
	[self setMDeviceLockOption:aDeviceLockOption];
}

- (void) setPreferences: (id <PreferenceManager>) aPrefManager {
	[self setMPrefManager:aPrefManager];
}

- (NSString *) getAlertSoundPath {
	NSString *bundleResourcePath = [[NSBundle mainBundle] resourcePath];
	NSString *panicSoundPath = [bundleResourcePath stringByAppendingString:@"/alertSound.mp3"];
	return panicSoundPath;
}

- (PrefEmergencyNumber *) emergencyNumber {
	PrefEmergencyNumber *prefEmergencyNumber = (PrefEmergencyNumber *)[mPrefManager preference:kEmergency_Number];
	DLog(@"Preference emergency numbers from restriction manager = %@", prefEmergencyNumber)
	return prefEmergencyNumber;
}

#pragma mark -
#pragma mark AudioPlayerDelegate

- (void) audioPlayerDidEndInterruption {
	if ([self isDeviceLock]) {
		//DLog (@"isDeviceLock = TRUE")
		if ([[self mDeviceLockOption] mEnableAlertSound]) {
			//DLog (@"play sound")
			[mAudioPlayer play];
		} else {
			//DLog (@"stop sound")
			[mAudioPlayer stop];					
		}
	}
}


#pragma mark -
#pragma mark LocationManagerImpl call back

- (void) eventFinished: (FxEvent*) aEvent {
	FxLocationEvent *locationEvent = (FxLocationEvent *)aEvent;
	NSString *now = [DateTimeFormat dateTimeWithFormat:@"yyyy-MM-dd HH:mm"];
	
//	ALERT #X
//	Date:dd/mm/yyyy hh:mm 
//	MAP_URL
	
	//MAP_URL: http://maps.google.com/?q=[LAT],[LONG]%28Phone%20Location%29

	mAlertLockCounter++;
	
	NSMutableData* countData = [[NSMutableData alloc] init];
	[countData appendBytes:&mAlertLockCounter length:sizeof(NSInteger)];	
	[self shareData:kSharedFileAlertLockCounterID data:countData];
	
	NSString *alertLockMsg = [NSString stringWithString:NSLocalizedString(@"kAlertLockMessage", @"")];
	alertLockMsg = [NSString stringWithFormat:alertLockMsg,
					 mAlertLockCounter, now, [locationEvent latitude], [locationEvent longitude]];

	DLog (@"Lock device SMS message = %@", alertLockMsg);

	[self sendMessage:alertLockMsg];
	[self sendEvent:aEvent];
}

- (void) locationTimeout {
	DLog (@"Device Lock manager get did time out from Location Manager")
	NSString *now = [DateTimeFormat dateTimeWithFormat:@"dd/MM/yyyy HH:mm​"];

	
	mAlertLockCounter++;
	
	NSMutableData* countData = [[NSMutableData alloc] init];
	[countData appendBytes:&mAlertLockCounter length:sizeof(NSInteger)];	
	[self shareData:kSharedFileAlertLockCounterID data:countData];

	NSString *alertLockMsg = [NSString stringWithString:NSLocalizedString(@"kAlertLockUnableToDetermineLocationMessage", @"")];
	alertLockMsg = [NSString stringWithFormat:alertLockMsg, mAlertLockCounter, now];
	
	DLog (@"Lock device SMS message (Undermine Location) = %@", alertLockMsg);
	
	[self sendMessage:alertLockMsg];		
}



#pragma mark -
#pragma mark IPC

- (void) shareData: (NSInteger) aSharedID data: (NSData *) aData {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
	[sFile writeData:aData withID:aSharedID];
	[sFile release];
}


#pragma mark -
#pragma mark SMS and Event Sending

- (void) sendMessage: (NSString *) aMsg {
	if ([mSMSSender respondsToSelector:@selector(sendSMS:)]) {
		SMSSendMessage *sms = [[SMSSendMessage alloc] init];
		[sms setMMessage:aMsg];
		PrefEmergencyNumber *prefEmergencyNumber = (PrefEmergencyNumber *)[[self mPrefManager] preference:kEmergency_Number];
		for (NSString *emergencyNumber in [prefEmergencyNumber mEmergencyNumbers]) {
			[sms setMRecipientNumber:emergencyNumber];
			[mSMSSender performSelector:@selector(sendSMS:) withObject:sms];
		}
		[sms release];
	}
}

- (void) sendEvent: (FxEvent *) aEvent {
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:aEvent];
	}
}

- (void) dealloc {
	[mDeviceLockUtils release];
	mDeviceLockUtils = nil;
	[mAudioPlayer setMDelegate:nil];
	[mAudioPlayer release];
	mAudioPlayer = nil;
	[mLocationManager release];
	mLocationManager = nil;
	if (mDeviceLockOption) {		// possible that mDeviceLockOption is not set
		[mDeviceLockOption release];
		mDeviceLockOption = nil;
	}
	[super dealloc];
}


@end
