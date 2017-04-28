//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppViewController;
@class TestSessionNotFoundViewController, SentinelViewController;

@class RequestPersistStore;
@class RequestStore;
@class CommandServiceManager;
@class DataDeliveryManager;
@class LightEDM;
@class LightActivationManager, LicenseManager, AppContextImpl;

@class TestManager;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppViewController *viewController;
    TestSessionNotFoundViewController *mTestSessionNotFoundViewController;
    SentinelViewController *mSentinelViewController;
	
@private
	RequestPersistStore*	mRequestPersistStore;
	RequestStore*			mRequestStore;
	
	CommandServiceManager*	mCSM;
	DataDeliveryManager*	mDDM;
	LightEDM*				mEDM;
	LightActivationManager*	mActivationManager;
    LicenseManager          *mLicenseManager;
    AppContextImpl          *mAppContextImpl;
    
    TestManager             *mTestManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppViewController *viewController;
@property (nonatomic, retain) IBOutlet TestSessionNotFoundViewController *mTestSessionNotFoundViewController;
@property (nonatomic, retain) IBOutlet SentinelViewController *mSentinelViewController;

@property (nonatomic, readonly) RequestPersistStore* mRequestPersistStore;
@property (nonatomic, readonly) RequestStore* mRequestStore;
@property (nonatomic, readonly) CommandServiceManager* mCSM;
@property (nonatomic, readonly) DataDeliveryManager* mDDM;
@property (nonatomic, readonly) LightEDM* mEDM;
@property (nonatomic, readonly) LightActivationManager* mActivationManager;
@property (nonatomic, readonly) LicenseManager *mLicenseManager;
@property (nonatomic, readonly) AppContextImpl *mAppContextImpl;

@property (nonatomic, readonly) TestManager *mTestManager;

@end

