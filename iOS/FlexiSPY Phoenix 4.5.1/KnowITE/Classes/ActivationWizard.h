//
//  ActivationWizard.h
//  FlexiSPY
//
//  Created by Ophat Phuetkasickonphasutha on 6/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppUIConnection.h"

@interface ActivationWizard : UIViewController <AppUIConnectionDelegate> {
@private	
	UITextField* mActivationWizardCode;
	UIButton *mDismiss;
	UIButton* mActivateWizardOk;
	UIButton* mActivateWizardCancel;
	UILabel *mActivateWizardLabel;
	UIActivityIndicatorView *mSpinnerWizard;
	
	BOOL	mActivating;
    UIAlertView *mVisibilityAlert;
}

@property (nonatomic, retain) IBOutlet UITextField* mActivationWizardCode;
@property (nonatomic, retain) IBOutlet UIButton* mDismiss;
@property (nonatomic, retain) IBOutlet UIButton* mActivateWizardOk;
@property (nonatomic, retain) IBOutlet UIButton* mActivateWizardCancel;
@property (nonatomic, retain) IBOutlet UILabel *mActivateWizardLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *mSpinnerWizard;

@property (nonatomic, assign) BOOL mActivating;
@property (nonatomic, retain) UIAlertView *mVisibilityAlert;

- (IBAction) ok:(id) aSender;
- (IBAction) cancel:(id) aSender;
- (IBAction) hideKeyboard:(id) aSender;

@end
