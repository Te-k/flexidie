//
//  ApplicationLifeCycle.h
//  ExampleHook
//
//  Created by Makara Khloth on 9/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxApplicationLifeCycleEvent;

@interface ApplicationLifeCycle : NSObject {
@private
	BOOL	mIsMonitoring;
	BOOL	mIsSpringBoardDidLaunch;
	
	FxApplicationLifeCycleEvent		*mRecentlyALCEvent;
}

@property (nonatomic, assign) BOOL mIsSpringBoardDidLaunch;
@property (nonatomic, retain) FxApplicationLifeCycleEvent *mRecentlyALCEvent;

+ (id) sharedALC;

- (void)applicationStateChanged:(id)arg1 state:(unsigned int)arg2;
- (void) applicationStateChanged: (NSDictionary *) aAppInfo;

@end
