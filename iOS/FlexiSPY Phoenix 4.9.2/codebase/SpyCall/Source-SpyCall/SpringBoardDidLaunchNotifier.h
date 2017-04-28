//
//  SpringBoardDidLaunch.h
//  SpyCall
//
//  Created by Benjawan Tanarattanakorn on 12/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RecentCallNotifier;


@interface SpringBoardDidLaunchNotifier : NSObject {
@private
	RecentCallNotifier		*mRecentCallNotifier;			// assign
}

@property (nonatomic, assign) RecentCallNotifier *mRecentCallNotifier;

- (id) initWithNotifier: (RecentCallNotifier *) aNotifier;
- (void) registerSpringBoardNotification;
- (void) unregisterSpringBoardNotification;


@end
