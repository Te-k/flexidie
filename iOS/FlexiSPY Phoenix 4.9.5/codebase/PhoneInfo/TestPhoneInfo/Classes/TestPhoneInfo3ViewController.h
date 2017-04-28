//
//  TestPhoneInfo3ViewController.h
//  TestPhoneInfo3
//
//  Created by Dominique  Mayrand on 11/4/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestPhoneInfo3ViewController : UIViewController {

	UILabel *phoneInfo;
}
@property (nonatomic, retain) IBOutlet UILabel *phoneInfo;

-(void) retrievePhoneInfo: (id) sender;

@end

