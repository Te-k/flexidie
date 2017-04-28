//
//  AdvancedSettingsLockViewController.h
//  PP
//
//  Created by Makara Khloth on 9/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AdvancedSettingsLockViewController : UIViewController {
@private
	UILabel		*mACNotMatchLabel;
	UIButton	*mGoButton;
	UITextField	*mACTextField;
}

@property (nonatomic, retain) IBOutlet UILabel *mACNotMatchLabel;
@property (nonatomic, retain) IBOutlet UIButton *mGoButton;
@property (nonatomic, retain) IBOutlet UITextField *mACTextField;

- (IBAction) goButtonPressed: (id) aSender;

@end
