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
	UIButton*	mSendNowButton;
}

@property (nonatomic, retain) IBOutlet UIButton* mSendNowButton;

- (IBAction) sendNowButtonPressed: (id) aSender;

@end

