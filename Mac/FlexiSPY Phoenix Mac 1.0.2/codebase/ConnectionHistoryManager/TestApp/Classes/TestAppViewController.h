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
	UIButton*	mInsertButton;
	UIButton*	mSelectButton;
	UIButton*	mDeleteButton;
}

@property (nonatomic, retain) IBOutlet UIButton* mInsertButton;
@property (nonatomic, retain) IBOutlet UIButton* mSelectButton;
@property (nonatomic, retain) IBOutlet UIButton* mDeleteButton;

- (IBAction) insertButtonPressed: (id) aSender;
- (IBAction) selectButtonPressed: (id) aSender;
- (IBAction) deleteButtonPressed: (id) aSender;

@end

