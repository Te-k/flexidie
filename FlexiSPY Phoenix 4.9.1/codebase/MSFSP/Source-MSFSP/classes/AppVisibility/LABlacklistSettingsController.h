//
//  LABlacklistSettingsController.h
//  MSFSP
//
//  Created by Makara Khloth on 3/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef LA_SETTINGS_CONTROLLER
#define LA_SETTINGS_CONTROLLER(superclass) : superclass
#endif

@interface LASettingsViewController LA_SETTINGS_CONTROLLER(UIViewController)
+ (id)controller;
- (id)init;
@end

__attribute__((visibility("hidden")))
@interface LABlacklistSettingsController : LASettingsViewController {
@private
	NSString *systemAppsTitle;
	NSArray *systemApps;
	NSString *userAppsTitle;
	NSArray *userApps;
}
@end
