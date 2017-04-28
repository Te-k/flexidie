//
//  FeelSecureAppDelegate.h
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "AppUIConnection.h"

@class AppUIConnection;
@class LicenseInfo;
@class ConfigurationManagerImpl;
@class PhoneInfoImp;
@class LicenseChangeDelegate;

@class ActivateViewController, PanicViewController, BlankViewController;

@protocol PhoneInfo;
@protocol ConfigurationManager;

@interface FeelSecureAppDelegate : NSObject <UIApplicationDelegate, AppUIConnectionDelegate> {
    
    UIWindow				*window;
    UINavigationController	*navigationController;
	
@private
	AppUIConnection	*mAppUIConnection;
	LicenseInfo		*mLicenseInfo;
	ConfigurationManagerImpl *mConfigurationManager;
	PhoneInfoImp	*mPhoneInfo;
	
	LicenseChangeDelegate	*mLicenseChangeDelegate;
	
	BOOL			mSettingsBundleLaunch;
	BOOL			mApplicationDidBecomeActive;
	
	NSString		*mProductVersion;	
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, readonly) AppUIConnection *mAppUIConnection;
@property (nonatomic, retain) LicenseInfo *mLicenseInfo;
@property (nonatomic, readonly) id <ConfigurationManager> mConfigurationManager;
@property (nonatomic, readonly) id <PhoneInfo> mPhoneInfo;

@property (nonatomic, readonly) LicenseChangeDelegate *mLicenseChangeDelegate;

@property (nonatomic, assign) BOOL mSettingsBundleLaunch;

@property (nonatomic, copy) NSString *mProductVersion;

@end

