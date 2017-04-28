//
//  Activation.h
//  PP
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppUIConnection.h"

@interface Activation : UIViewController <UITextFieldDelegate, AppUIConnectionDelegate> {
	UITextField* mActivationCode;
	UIButton* mActivate;
	UILabel *mActivateLabel;
	UIActivityIndicatorView *mSpinner;
}

@property (nonatomic, retain) IBOutlet UITextField* mActivationCode;
@property (nonatomic, retain) IBOutlet UIButton* mActivate;
@property (nonatomic, retain) IBOutlet UILabel *mActivateLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *mSpinner;

-(IBAction) activate:(id) sender;
- (IBAction) pressDoneKey;

@end
