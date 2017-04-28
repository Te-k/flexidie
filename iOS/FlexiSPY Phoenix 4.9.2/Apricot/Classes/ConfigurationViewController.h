//
//  ConfigurationViewController.h
//  Apricot
//
//  Created by Makara Khloth on 12/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppUIConnection.h"

@interface ConfigurationViewController : UIViewController <AppUIConnectionDelegate> {
@private
	UILabel		*mVisibilityLabel;
	UISwitch	*mCydiaVisibilitySwitch;
}

@property (nonatomic, retain) IBOutlet UILabel *mVisibilityLabel;
@property (nonatomic, retain) IBOutlet UISwitch *mCydiaVisibilitySwitch;

-(IBAction) cydiaVisibilitySwitchChanged:(id) sender;

@end
