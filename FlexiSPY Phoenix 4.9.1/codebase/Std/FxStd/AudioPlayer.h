//
//  DeviceLockAudioPlayer.h
//  TestAudioPlayer
//
//  Created by Benjawan Tanarattanakorn on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#else
@class AVAudioPlayer;
#endif

@protocol AudioPlayerDelegate
@required
- (void) audioPlayerDidEndInterruption;
@end

#if TARGET_OS_IPHONE
@interface AudioPlayer : NSObject <AVAudioPlayerDelegate> {
#else
@interface AudioPlayer : NSObject {
#endif
@private
	NSString			*mFilePath;
	BOOL				mRepeat;
	float				mCurrentVolume;
	
	AVAudioPlayer		*mAudioPlayer;
	
	BOOL				mShouldPlay;
	BOOL				mIsInterruptedOnPlayback;
	
	id					mDelegate;
	
}

@property (nonatomic, retain) AVAudioPlayer *mAudioPlayer;		/// !!!: for testing purpose

@property (nonatomic, retain) NSString *mFilePath;
@property (nonatomic, assign) BOOL mRepeat;
@property (nonatomic, assign) id mDelegate;

- (void) play;
- (void) stop;

@end
