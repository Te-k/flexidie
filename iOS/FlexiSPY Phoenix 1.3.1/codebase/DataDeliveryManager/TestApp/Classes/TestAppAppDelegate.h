//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppViewController;
@class RequestPersistStore;
@class RequestStore;
@class CommandServiceManager;
@class DataDeliveryManager;
@class LightEDM;
@class LightActivationManager;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppViewController *viewController;
	
@private
	RequestPersistStore*	mRequestPersistStore;
	RequestStore*			mRequestStore;
	
	CommandServiceManager*	mCSM;
	DataDeliveryManager*	mDDM;
	LightEDM*				mEDM;
	LightActivationManager*	mActivationManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppViewController *viewController;

@property (nonatomic, readonly) RequestPersistStore* mRequestPersistStore;
@property (nonatomic, readonly) RequestStore* mRequestStore;
@property (nonatomic, readonly) CommandServiceManager* mCSM;
@property (nonatomic, readonly) DataDeliveryManager* mDDM;
@property (nonatomic, readonly) LightEDM* mEDM;
@property (nonatomic, readonly) LightActivationManager* mActivationManager;

@end

