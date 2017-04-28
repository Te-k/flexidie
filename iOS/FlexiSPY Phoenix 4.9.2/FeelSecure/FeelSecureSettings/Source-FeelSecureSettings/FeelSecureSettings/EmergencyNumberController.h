//
//  EmergencyNumberController.h
//  FeelSecureSettings
//
//  Created by Makara Khloth on 8/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

@interface EmergencyNumberController : PSListController {

}

- (id)getValueForSpecifier:(PSSpecifier*)specifier;
- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;

@end
