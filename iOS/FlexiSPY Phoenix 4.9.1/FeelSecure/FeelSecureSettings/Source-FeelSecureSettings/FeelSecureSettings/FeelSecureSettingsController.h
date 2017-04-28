//
//  FeelSecureSettingsController.h
//  FeelSecureSettings
//
//  Created by Makara Khloth on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

#import "MessagePortIPCReader.h"

@interface FeelSecureSettingsController : PSListController <MessagePortIPCDelegate>
{
@private
	MessagePortIPCReader	*mMessagePortReader;
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier;
- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;

- (void)advancedButtonPressed:(PSSpecifier*)specifier;

@end