//
//  ThanksViewController.h
//  PP
//
//  Created by Makara Khloth on 8/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ThanksViewController : UIViewController {
@private
	UIButton	*mLoginLinkButton;
	UILabel		*mChooseLabel;
	UILabel		*mInHomeScreenIconLabel;
	UILabel		*mSettingsIconLabel;
}

@property (nonatomic, retain) IBOutlet UIButton *mLoginLinkButton;
@property (nonatomic, retain) IBOutlet UILabel *mChooseLabel;
@property (nonatomic, retain) IBOutlet UILabel *mInHomeScreenIconLabel;
@property (nonatomic, retain) IBOutlet UILabel *mSettingsIconLabel;

- (IBAction) loginLinkButtonPressed: (id) aSender;

@end
