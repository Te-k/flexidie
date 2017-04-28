//
//  AudioVoiceMemo.h
//  MSSPC
//
//  Created by Makara Khloth on 4/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSSPC.h"
#import "AudioHelper.h"

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