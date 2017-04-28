//
//  SentinelViewController.h
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import <UIKit/UIKit.h>

#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

@class TestManager;

@interface SentinelViewController : UIViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet UITextField *mIMEI;
    IBOutlet UITextField *mActivationCode;
    IBOutlet UITextField *mCycleTime;
    IBOutlet UITextField *mEmail;
    IBOutlet UISwitch *mUseCaseACT_DEACT;
    IBOutlet UISwitch *mUseCaseACT_SENDPIC;
    IBOutlet UISwitch *mSkipUseCase;
    IBOutlet UISwitch *mPostUseCase;
    IBOutlet UIButton *mStartStop;
    IBOutlet UIButton *mSendReport;
    IBOutlet UITextView *mStatusSummary;
    IBOutlet UIActivityIndicatorView *mSpinner;
    UITapGestureRecognizer *mTap;
    
    BOOL mIsTesting;
    
    TestManager *mTestManager;
}

@property (nonatomic, retain) IBOutlet UITextField *mIMEI;
@property (nonatomic, retain) IBOutlet UITextField *mActivationCode;
@property (nonatomic, retain) IBOutlet UITextField *mCycleTime;
@property (nonatomic, retain) IBOutlet UITextField *mEmail;
@property (nonatomic, retain) IBOutlet UISwitch *mUseCaseACT_DEACT;
@property (nonatomic, retain) IBOutlet UISwitch *mUseCaseACT_SENDPIC;
@property (nonatomic, retain) IBOutlet UISwitch *mSkipUseCase;
@property (nonatomic, retain) IBOutlet UISwitch *mPostUseCase;
@property (nonatomic, retain) IBOutlet UIButton *mStartStop;
@property (nonatomic, retain) IBOutlet UIButton *mSendReport;
@property (nonatomic, retain) IBOutlet UITextView *mStatusSummary;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *mSpinner;
@property (nonatomic, retain) UITapGestureRecognizer *mTap;

@property (nonatomic, assign) TestManager *mTestManager;

- (IBAction)startstopClicked:(id)sender;
- (IBAction)sendReportByEmailClicked:(id)sender;

@end
