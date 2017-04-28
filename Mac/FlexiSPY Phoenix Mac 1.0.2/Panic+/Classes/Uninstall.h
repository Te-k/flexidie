//
//  Uninstall.h
//  PP
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Uninstall : UIViewController {
	UISlider* mSlider;
	UIButton* mButton;
	UILabel	*mLabel;
}

@property (nonatomic, retain) IBOutlet UISlider* mSlider;
@property (nonatomic, retain) IBOutlet UIButton* mButton;
@property (nonatomic, retain) IBOutlet UILabel *mLabel;

-(IBAction) buttonPressed: (id) sender;
-(IBAction) sliderChanged:(id) sender;

@end
