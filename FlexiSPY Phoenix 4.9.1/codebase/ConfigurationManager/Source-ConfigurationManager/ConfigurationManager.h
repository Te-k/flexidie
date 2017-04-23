//
//  ConfigurationManager.h
//  ConfigurationManager
//
//  Created by Makara Khloth on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigurationID.h"

@class Configuration;

@protocol ConfigurationManager <NSObject>
@required
- (void) updateConfigurationID: (NSInteger) aConfigurationID;
- (BOOL) isSupportedFeature: (FeatureID) aFeatureID;

- (BOOL) isSupportedSettingID: (NSInteger) aSettingID
				  remoteCmdID: (NSString *) aRemoteCmdID;

- (Configuration*) configuration;

@end

