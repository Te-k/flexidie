//
//  TestAppViewController.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface TestAppViewController : UIViewController <MFMessageComposeViewControllerDelegate> {
@private
	UIButton*	mSendSmsButton;
}

@property (nonatomic, retain) IBOutlet UIButton* mSendSmsButton;

- (IBAction) sendSmsButtonPressed: (id) aSender;

@end

