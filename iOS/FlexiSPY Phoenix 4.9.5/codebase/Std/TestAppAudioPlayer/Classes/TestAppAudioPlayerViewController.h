//
//  TestAppAudioPlayerViewController.h
//  TestAppAudioPlayer
//
//  Created by Benjawan Tanarattanakorn on 8/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioPlayer;

@interface TestAppAudioPlayerViewController : UIViewController {
	AudioPlayer *mAudioPlayer;
}

- (IBAction) startButtonPressed: (id) aSender;
- (IBAction) stopButtonPressed: (id) aSender;

@end

