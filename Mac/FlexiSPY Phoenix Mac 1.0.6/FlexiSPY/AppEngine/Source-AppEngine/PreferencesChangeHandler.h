//
//  PreferencesChangeHandler.h
//  AppEngine
//
//  Created by Makara Khloth on 12/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PreferenceChangeListener.h"

@class AppEngine;

@interface PreferencesChangeHandler : NSObject <PreferenceChangeListener> {
@private
	AppEngine	*mAppEngine;
}

- (id) initWithAppEngine: (AppEngine *) aAppEngine;
- (BOOL) isSupportSettingIDOfRemoteCmdCodeSettings: (NSInteger) aSettingID;

@end
