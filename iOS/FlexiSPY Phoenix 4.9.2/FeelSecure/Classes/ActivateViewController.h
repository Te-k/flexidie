//
//  ActivateViewController.h
//  FeelSecure
//
//  Created by Makara Khloth on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUIConnection.h"

@class PrefEmergencyNumber;

@interface ActivateViewController : UIViewController <AppUIConnectionDelegate> {
@private
	UITextField	*mActivationCodeTextField;
	UIButton	*mActivateButton;
	UIButton	*mFSLinkButton;
	UILabel		*mVersionLabel;
	UIActivityIndicatorView *mSpinner;
	
	PrefEmergencyNumber	*mPrefEmergencyNumber;
	
	BOOL	mIsActivating;
}

@property (nonatomic, retain) IBOutlet UITextField *mActivationCodeTextField;
@property (nonatomic, retain) IBOutlet UIButton *mActivateButton;
@property (nonatomic, retain) IBOutlet UIButton *mFSLinkButton;
@property (nonatomic, retain) IBOutlet UILabel *mVersionLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *mSpinner;

@property (nonatomic, retain) PrefEmergencyNumber *mPrefEmergencyNumber;

@property (nonatomic, assign) BOOL mIsActivating;


- (IBAction) activateButtonPressed: (id) aSender;
- (IBAction) fsLinkButtonPressed: (id) aSender;

@end
