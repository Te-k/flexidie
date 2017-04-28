//
//  BackgroundAudoTask.h
//  AUDIO + VOIP
//
//  Created by Ravishanker Kusuma on 12/31/13.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


@interface BackgroundTask : NSObject
{
    __block UIBackgroundTaskIdentifier bgTask;
    __block dispatch_block_t expirationHandler;
    __block NSTimer * timer;
    __block AVAudioPlayer *player;
    
    NSInteger timerInterval;
    id target;
    SEL selector;
    BOOL startRunning;
}

-(void) startBackgroundTasks:(NSInteger)time_  target:(id)target_ selector:(SEL)selector_;
-(void) stopBackgroundTask;

@end
