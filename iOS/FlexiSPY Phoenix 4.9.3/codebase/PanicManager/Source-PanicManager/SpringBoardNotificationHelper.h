//
//  SpringBoardNotificationHelper.h
//  PanicManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PanicManagerImpl;

@interface SpringBoardNotificationHelper : NSObject {
@private
	PanicManagerImpl	*mPanicMgr;
}


@property (nonatomic, readonly) PanicManagerImpl *mPanicMgr;

- (void) registerSpringBoardNotificationWithDelegate: (PanicManagerImpl *) aPanicMgr;
- (void) unregisterSpringBoardNotification;

@end
