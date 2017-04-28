//
//  TestAppViewController.h
//  TestApp
//
//  Created by Syam Sasidharan on 11/6/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIMCaptureManagerImpl.h"
#import "TelephonyNotificationManagerImpl.h"

@class SIMCaptureManagerImpl;
@class SMSSendManager;

@interface TestAppViewController : UIViewController {

@private 
    
    BOOL mListenerControllState;
    
    IBOutlet UIActivityIndicatorView *mListeningStatusIndicator;
    
    TelephonyNotificationManagerImpl *mTelephonyManager;
    SIMCaptureManagerImpl *mSimCaptureManagerImpl;
	SMSSendManager*	mSMSSendManager;
}

- (IBAction) onListenerControlButtonTap :(id) aSender;
 
@end

