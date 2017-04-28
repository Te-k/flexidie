//
//  TestAppViewController.h
//  TestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestAppViewController : UIViewController {

	IBOutlet UITextField *txtInput;
	IBOutlet UILabel * lblOutPut;
}

- (IBAction) search: (id) aSender;
@end

