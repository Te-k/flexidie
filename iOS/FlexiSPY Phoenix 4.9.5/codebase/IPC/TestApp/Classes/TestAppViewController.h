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
	UIButton*	mSendDataFromThreadButton;
	UIButton*	mStopListenButton;
	UIButton*	mStartListenButton;
	UILabel*	mDataReceivedLabel;
	UISegmentedControl* mSegmentedControl;
}

@property (nonatomic, retain) IBOutlet UIButton* mSendDataFromThreadButton;
@property (nonatomic, retain) IBOutlet UIButton* mStopListenButton;
@property (nonatomic, retain) IBOutlet UIButton* mStartListenButton;
@property (nonatomic, retain) IBOutlet UILabel* mDataReceivedLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl* mSegmentedControl;

- (IBAction) sendDataFromThreadButtonPressed: (id) aSender;
- (IBAction) stopListenButtonPressed: (id) aSender;
- (IBAction) startListenButtonPressed: (id) aSender;

@end

