//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppViewController;

@class EventRepositoryManager;
@class CommandServiceManager;
@class DataDeliveryManager;
@class EventDeliveryManager;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppViewController *viewController;
	
	CommandServiceManager*		mCSM;
	DataDeliveryManager*		mDDM;
	EventDeliveryManager*		mEDM;
	
	EventRepositoryManager*		mEventRepository;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppViewController *viewController;

@property (nonatomic, readonly) EventDeliveryManager* mEDM;
@property (nonatomic, readonly) EventRepositoryManager* mEventRepository;

@end

