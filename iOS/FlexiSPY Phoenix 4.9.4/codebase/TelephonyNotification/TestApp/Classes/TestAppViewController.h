//
//  TestAppViewController.h
//  TestApp
//
//  Created by Syam Sasidharan on 11/3/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TelephonyNotificationManager.h"
#import "FXLoggerHelper.h"

@interface TestAppViewController : UIViewController {

    id <TelephonyNotificationManager> mManager;
    
    IBOutlet UITextView *mLabel;
}


- (void)addListeners:(id)aManager;
- (void)cleanUp;


@end

