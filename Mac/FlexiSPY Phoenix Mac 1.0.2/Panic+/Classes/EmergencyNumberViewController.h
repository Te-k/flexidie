//
//  EmergencyNumberViewController.h
//  PP
//
//  Created by Makara Khloth on 8/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUIConnection.h"

@interface EmergencyNumberViewController : UITableViewController <UITextFieldDelegate, AppUIConnectionDelegate>{
@private
	UIBarButtonItem		*mSaveButton;
	
	UITextField	*m1stEmergencyTextField;
	UITextField	*m2ndEmergencyTextField;
	UITextField	*m3rdEmergencyTextField;
	UITextField	*m4thEmergencyTextField;
	UITextField	*m5thEmergencyTextField;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *mSaveButton;

@property (nonatomic, retain) UITextField *m1stEmergencyTextField;
@property (nonatomic, retain) UITextField *m2ndEmergencyTextField;
@property (nonatomic, retain) UITextField *m3rdEmergencyTextField;
@property (nonatomic, retain) UITextField *m4thEmergencyTextField;
@property (nonatomic, retain) UITextField *m5thEmergencyTextField;

- (IBAction) saveButtonPressed: (id) aSender;
// Handles UIControlEventEditingDidEndOnExit
- (IBAction)textFieldFinished:(id)sender ;

@end
