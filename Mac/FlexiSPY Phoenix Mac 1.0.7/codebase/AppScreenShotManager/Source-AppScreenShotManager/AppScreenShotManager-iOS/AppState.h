//
//  AppState.h
//  AppScreenShotManager
//
//  Created by Makara Khloth on 1/5/17.
//  Copyright © 2017 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kAppStateActivate   = 1,
    kAppStateDeactivate = 2
};

@interface AppState : NSObject {
    NSUInteger mState;
    NSString *mBundleID;
    NSString *mDisplayName;
}

@property (nonatomic, assign) NSUInteger mState;
@property (nonatomic, copy) NSString *mBundleID;
@property (nonatomic, copy) NSString *mDisplayName;

@end
