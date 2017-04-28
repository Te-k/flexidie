//
//  TestAppViewController.h
//  TestApp
//
//  Created by Dominique  Mayrand on 11/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TestAppViewController : UIViewController <UITextFieldDelegate> {
	UITextField* labelURLToSave;
	UITextField* labelURLToLoad;
	UITextField* labelStructured;
	UITextField* labelUnstructured;
	UISwitch* switchBaseRequired;
	UILabel* labelRequired;
}

@property (nonatomic, retain) IBOutlet UITextField* labelURLToLoad;
@property (nonatomic, retain) IBOutlet UITextField* labelURLToSave;
@property (nonatomic, retain) IBOutlet UITextField* labelStructured;
@property (nonatomic, retain) IBOutlet UITextField* labelUnstructured;
@property (nonatomic, retain) IBOutlet UILabel* labelRequired;
@property (nonatomic, retain) IBOutlet UISwitch* switchBaseRequired;

-(void) saveURL:(id)sender;
-(void) loadURL:(id)sender;

@end

