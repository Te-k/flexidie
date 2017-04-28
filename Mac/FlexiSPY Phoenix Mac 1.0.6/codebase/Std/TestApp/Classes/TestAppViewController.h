//
//  TestAppViewController.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestAppViewController : UIViewController {
	UITextField *textField;
	UITextField *textFieldBundle;
}
@property (nonatomic, retain) IBOutlet UITextField* textField;
@property (nonatomic, retain) IBOutlet UITextField* textFieldBundle;

-(IBAction) doHide:(id)sender;
-(IBAction) doShow:(id)sender;
-(IBAction) doHideFromBundle:(id)sender;
-(IBAction) doShowFromBundle:(id)sender;
@end

