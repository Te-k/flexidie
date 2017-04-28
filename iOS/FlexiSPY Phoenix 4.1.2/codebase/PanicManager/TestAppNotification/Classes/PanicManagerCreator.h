//
//  PanicManagerCreator.h
//  TestAppNotification
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PanicManagerImpl;
@class SpringBoardNotificationHelper;

@interface PanicManagerCreator : NSObject {
@private
	PanicManagerImpl *mPmgr;
	SpringBoardNotificationHelper *sbnHelper;
}

- (void) registerSpringboardNotification;
//- (void) stopPanic;
@end
