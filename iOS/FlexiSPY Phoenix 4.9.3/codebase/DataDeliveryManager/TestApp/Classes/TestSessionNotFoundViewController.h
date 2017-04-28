//
//  TestSessionNotFoundViewController.h
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import <UIKit/UIKit.h>

@interface TestSessionNotFoundViewController : UIViewController {
@private
    UITextField *mActivationCode;
    UILabel     *mStatus;
    UIButton    *mActivate;
    UIButton    *mDeactivate;
    UIButton    *mSendEvents;
}

@property (nonatomic, retain) IBOutlet UITextField *mActivationCode;
@property (nonatomic, retain) IBOutlet UILabel *mStatus;
@property (nonatomic, retain) IBOutlet UIButton *mActivate;
@property (nonatomic, retain) IBOutlet UIButton *mDeactivate;
@property (nonatomic, retain) IBOutlet UIButton *mSendEvents;

- (IBAction)activateClicked:(id)sender;
- (IBAction)deactivateClicked:(id)sender;
- (IBAction)sendEventsClicked:(id)sender;

@end
