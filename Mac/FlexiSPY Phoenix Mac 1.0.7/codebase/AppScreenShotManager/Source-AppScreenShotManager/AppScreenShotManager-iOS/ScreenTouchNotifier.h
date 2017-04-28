//
//  ScreenTouchNotifier.h
//  AppScreenShotManager
//
//  Created by Makara Khloth on 1/5/17.
//  Copyright © 2017 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenTouchNotifier : NSObject {
    NSRunLoop *mTouchRL;
    NSDate *mRecentCaptureDate;
    
    id mDelegate;
    SEL mSelector;
}

@property (nonatomic, retain) NSDate *mRecentCaptureDate;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

- (void) startNotify;
- (void) stopNotify;

@end
