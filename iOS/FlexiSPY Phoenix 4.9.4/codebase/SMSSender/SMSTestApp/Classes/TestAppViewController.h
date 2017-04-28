//
//  TestAppViewController.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestAppViewController : UIViewController {
@private
	UITextField		*mMessageTextTextField;
	UITextField		*mAddressTextField;
	UIButton		*mSendSMSButton;
}

@property (nonatomic, retain) IBOutlet UITextField *mMessageTextTextField;
@property (nonatomic, retain) IBOutlet UITextField *mAddressTextField;
@property (nonatomic, retain) IBOutlet UIButton *mSendSMSButton;

- (IBAction) sendSMSButtonClicked: (id) aSender;

+ (void) sendMessage000: (NSString *) aText toAddress: (NSString *) aAddress;

@end

