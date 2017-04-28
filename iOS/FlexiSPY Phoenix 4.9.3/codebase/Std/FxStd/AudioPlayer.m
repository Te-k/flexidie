//
//  DeviceLockAudioPlayer.m
//  TestAudioPlayer
//
//  Created by Benjawan Tanarattanakorn on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioPlayer.h"

#if TARGET_OS_IPHONE
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>


static float kMAX_SOUND_VALUE	= 1;	/// !!!: 0.3 is testing purpose


@interface AudioPlayer (private)
- (void) maximizeDeviceSound;
- (void) initializeAudioSession;
- (void) clearAudioSession;
- (void) volumeChanged: (id) aNotification;
void audioRouteChangeListenerCallback (
									   void                      *inUserData,
									   AudioSessionPropertyID    inPropertyID,
									   UInt32                    inPropertyValueSize,
									   const void                *inPropertyValue
									   );
- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player;
- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withFlags: (NSUInteger) flags;
@end


@implementation AudioPlayer

@synthesize mFilePath;
@synthesize mRepeat;
@synthesize mAudioPlayer;
@synthesize mDelegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		mRepeat = NO;						// default value is to not repeat playing a sound		
		mShouldPlay = NO;					
		mIsInterruptedOnPlayback = NO;	
	}
	return self;
}

// start playing audio
- (void) play {
	DLog(@">>>>>>>>>>>>>>>>>>>>>> try to start audio %@", mAudioPlayer);
//	// -- Audio player exist	
//	if (mAudioPlayer) {
//		
//		// -- Audio is playing now
//		if ([mAudioPlayer isPlaying]) {
//			// Do nothing
//			
//		// -- Audio is NOT playing now
//		} else {
//			// play
//		}
//	
//	// -- Audio player does not exist
//	} else { 
//		// init
//		// play
//	}
	
	if (mFilePath && ![mAudioPlayer isPlaying])	{
		
		/*******************************************************
		 This case will be processed when 
		 - mAudioPlayer is not inited yet
		 - mAudioPlayer exist and not playing
		 *******************************************************/
		
		DLog (@"can play audio")
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) 
													 name:@"AVSystemController_SystemVolumeDidChangeNotification" 
												   object:nil];  
		NSError *error	= nil;
		NSURL *url		= [NSURL fileURLWithPath:mFilePath];
		
		if (mAudioPlayer) {
			DLog (@"!!!!!!!!!!!!!!!!! release the pending Audio Player !!!!!!!!!!!!!!!")
			[mAudioPlayer release];
			mAudioPlayer = nil;
		}
		
		mAudioPlayer	= [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
		
		[self initializeAudioSession];		// This method requires mAudioPlayer to be set
		
		[self maximizeDeviceSound];

		if (!error) {
			if (mRepeat) {
				[mAudioPlayer setNumberOfLoops:-1];	// repeat infinitely
			} else {
				[mAudioPlayer setNumberOfLoops:0];	// play once
			}
			[mAudioPlayer setVolume:1];					
			[mAudioPlayer setDelegate:self];		/// !!!: Testing purpose
			[mAudioPlayer prepareToPlay];
			[mAudioPlayer play];
			mShouldPlay = YES;						/// !!!: Testing purpose
		} else {
			DLog(@"error to initiate audio player");
		}
	} else {
		DLog (@"can not play audio")
	}

}

- (void) stop {
	DLog(@">>>>>>>>>>>>>>>>>>>>>> try to stop audio");
	if (mAudioPlayer && [mAudioPlayer isPlaying])  {		// -- stop if audio player exist and is playing
		DLog (@"can stop audio")
		
		[mAudioPlayer stop];		
		DLog (@"stop debug 1")
		
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:@"AVSystemController_SystemVolumeDidChangeNotification" 
													  object:nil]; 		
		DLog (@"stop debug 2")
		
		[[MPMusicPlayerController applicationMusicPlayer] setVolume:mCurrentVolume];
		//DLog(@"volume after stop alert %f",  [[MPMusicPlayerController applicationMusicPlayer] volume]);		
		DLog (@"stop debug 3")
	
		[mAudioPlayer setDelegate:nil];			
		[mAudioPlayer release];
		mAudioPlayer = nil;				
		DLog (@"stop debug 4")
		
		mShouldPlay = NO;	
		
		[self clearAudioSession];		
		DLog (@"stop debug 5")
	} else {
		DLog (@"can not stop %@ %d", mAudioPlayer, [mAudioPlayer isPlaying])		
		// Audio player does not exist
		// or exist but not playing
		if (mAudioPlayer) {
			DLog (@"!!! release Audio player !!!")
			[mAudioPlayer release];
			mAudioPlayer = nil;	
		}
		
	}

}

// This is for in crease the global sound
- (void) maximizeDeviceSound {
	mCurrentVolume = [[MPMusicPlayerController applicationMusicPlayer] volume];
	//DLog(@"current volume %f", mCurrentVolume);
	[[MPMusicPlayerController applicationMusicPlayer] setVolume:kMAX_SOUND_VALUE];		
	//DLog(@"current volume %f",  [[MPMusicPlayerController applicationMusicPlayer] volume]);
}

- (void) initializeAudioSession {
	//DLog (@"---- initializeAudioSession ----")
	//AudioSessionInitialize(NULL, NULL, nil, nil);										// 1) initialize audio session

	/* AVAudioSessionCategoryPlayback: 
	 -- Not silenced by the Ring/Silent switch and by screen locking
	 -- Not allows audio from other applications
	 */
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback		// 2) set audio session category  (category request is sent immediately)
										   error: &setCategoryError];	
	if (setCategoryError) {
		DLog (@"!!!!!!!!! ERROR: setting audio category error: %@", setCategoryError)
    }
		
	UInt32 doSetProperty = YES;
	AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers,
							 sizeof (doSetProperty),
							 &doSetProperty
							 );
	
	AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,			// 3) REGISTER the audio route change listener callback function
									 audioRouteChangeListenerCallback,
									 self
									 );
	NSError *activationError = nil;
	[[AVAudioSession sharedInstance] setActive:YES error:&activationError];				// 4) ACTIVE audio session ACTIVE (The system deactivates the audio session for a Clock or Calendar alarm or incoming phone call)
}

- (void) clearAudioSession {
	DLog (@"---- clearAudioSession 1 ----")	
	AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange,	// 1) UNREGISTER the audio route change listener callback function
												   audioRouteChangeListenerCallback,
												   self);   
	NSError *deactivationError = nil;
	[[AVAudioSession sharedInstance] setActive:NO error:&deactivationError];				// 2) DEACTIVE audio session DEACTIVE
	DLog (@"---- clearAudioSession 2 ----")	
}



#pragma mark -
#pragma mark Volume change callback


- (void) volumeChanged: (id) aNotification {
	//DLog (@">>>>>>>>>>>>>>>> changed %@", aNotification)
	//DLog (@"volume/max %f/%f",[[MPMusicPlayerController applicationMusicPlayer] volume], kMAX_SOUND_VALUE)
	if ([[MPMusicPlayerController applicationMusicPlayer] volume] != kMAX_SOUND_VALUE)
		[self maximizeDeviceSound];
}



#pragma mark -
#pragma mark Route change callback

void audioRouteChangeListenerCallback (
									   void                      *inUserData,
									   AudioSessionPropertyID    inPropertyID,
									   UInt32                    inPropertyValueSize,
									   const void                *inPropertyValue
									   ) {
	DLog (@"****************************************************** ")
	DLog (@"******************** Route change ******************** ")
	DLog (@"****************************************************** ")
	
	DLog (@"now playing item %@", [[MPMusicPlayerController applicationMusicPlayer] nowPlayingItem])
	DLog (@"playback state %d", [[MPMusicPlayerController applicationMusicPlayer] playbackState])
	
	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) { 
		DLog(@"-------------- (NOT audio route change) --------------")		
		return;										/// !!! make sure that nothing is retained til this point
	}
				
	AudioPlayer *audioPlayer = (AudioPlayer *) inUserData;
	
	// - Determines the reason for the route change, to ensure that it is not because of a category change.
	CFDictionaryRef	routeChangeDictionary	= inPropertyValue;	
	CFNumberRef routeChangeReasonRef		= CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason));	
	SInt32 routeChangeReason = 0;	
	CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);

	// -- CASE 1: UNPLUGGED: The old device became unavailable (e.g. headphones have been unplugged).
	/*
		"Old device unavailable" indicates that a headset was UNPLUGGED, or that the
		device was removed from a dock connector that supports audio output. This is
		the recommended test for when to pause audio.
	 */
	if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable ) {
		// previous device is Headphone
		if (![audioPlayer.mAudioPlayer isPlaying]) {			
			DLog (@"---- reason: <UNPLUG> + NOT playing --> play")
			[audioPlayer.mAudioPlayer play];			
		} else {	
			DLog (@"---- reason: <UNPLUG> + playing --> do nothing")			
		}				
	// -- CASE 2: PLUGGED:  A new device became available (e.g. headphones have been plugged in).
	} else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {					
		if (![audioPlayer.mAudioPlayer isPlaying]) {			
			DLog (@"---- reason: <PLUG> + not playing --> play")
			[audioPlayer.mAudioPlayer play];
		} else {			
			DLog (@"---- reason: <PLUG> + playing --> do nothing")
		}		 
	} else if (routeChangeReason == kAudioSessionRouteChangeReason_Override) {
		// The audio route has been overridden. 
		DLog (@"---- reason: <override the route>")
	} else {
		DLog (@"-----reason: Other route change reason: <%d>", routeChangeReason)
	}
}


#pragma mark -
#pragma mark AVAudioPlayerDelegate


- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
	// The system automatically 'pauses' playback or recording upon interruption, and 'reactivates' your audio session when you resume playback or recording.
	DLog (@"******************************************************************************************")
	DLog (@"-- BEGIN Interrupted. The system has paused audio playback.")	
	DLog (@"******************************************************************************************")
	
	DLog (@"now playing item iPodMusicPlayer %@", [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem])
	DLog (@"playback state iPodMusicPlayer %d", [[MPMusicPlayerController iPodMusicPlayer] playbackState])
	
	if ([player isPlaying]) {						
		DLog (@"audioPlayerBeginInterruption -- We're playing")		
		mIsInterruptedOnPlayback = YES;
	} else {									// normal cas
		DLog (@"audioPlayerBeginInterruption -- We're NOT playing")
		// -- Case 1: iPod application
		if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) {		// ipod application is playing
			DLog (@"iPod app is playing, so we can play our sound")
			[player play];	
		// -- Case 2: Phone call
		} else {			
			mIsInterruptedOnPlayback = YES;
		}

	}
}

// Deprecated in iOS 6.0
- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withFlags:(NSUInteger)flags {
    [self handleAudioPlayerInterruptionEnd:player];
}

-  (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
   [self handleAudioPlayerInterruptionEnd:player];
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	DLog (@"audioPlayerDidFinishPlaying");
}

#pragma mark -


- (void) handleAudioPlayerInterruptionEnd: (AVAudioPlayer *) aPlayer {
    // The system automatically pauses playback or recording upon interruption, and reactivates your audio session when you resume playback or recording.
	DLog (@"******************************************************************************************")
	DLog (@"-- END Interrupted. Resuming audio playback.");
	DLog (@"******************************************************************************************")
	
	
	// no need to active audio session because the system automatically do it
	//[[AVAudioSession sharedInstance] setActive:YES error:nil];
	
	if (mIsInterruptedOnPlayback) {
		if (![aPlayer isPlaying]) {
			DLog (@"-- our audio is not played now")
			// inform the delegate that the inturruption has already been ended
			if (mDelegate) {  // mDelegate is DeviceLockManager or PanicManager
				DLog (@"delegate: %@", mDelegate)
				if ([mDelegate respondsToSelector:@selector(audioPlayerDidEndInterruption)]) {
					DLog (@"delegate response to selector %@", mDelegate)
					[mDelegate audioPlayerDidEndInterruption];
				}
			}
		} 			
		mIsInterruptedOnPlayback = NO;
	}
}


#else
@implementation AudioPlayer

@synthesize mFilePath;
@synthesize mRepeat;
@synthesize mAudioPlayer;
@synthesize mDelegate;

- (void) play {
    
}

- (void) stop {
    
}

#endif

- (void) dealloc {
	if (mFilePath) {	// the caller may init and then release
		[mFilePath release];
		mFilePath = nil;
	}
	[super dealloc];
}

@end
