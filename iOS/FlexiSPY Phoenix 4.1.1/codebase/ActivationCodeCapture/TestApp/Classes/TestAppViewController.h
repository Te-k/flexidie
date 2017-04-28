//
//  TestAppViewController.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivationCodeCaptureManager;

@interface TestAppViewController : UIViewController {
@private
	ActivationCodeCaptureManager*	mActivationCodeCaptureManager;
	
	UIButton*	mCaptureActivationCodeButton;
}

@property (nonatomic, retain) IBOutlet UIButton* mCaptureActivationCodeButton;

- (IBAction) captureActivationCodeButtonPressed: (id) aSender;

@end

