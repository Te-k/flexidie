//
//  TestSessionNotFoundViewController.m
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import "TestSessionNotFoundViewController.h"
#import "TestAppAppDelegate.h"
#import "LightActivationManager.h"
#import "LightEDM.h"
#import "LicenseManager+Dummy.h"

#import "DeliveryResponse.h"
#import "ResponseData.h"
#import "DateTimeFormat.h"

@interface TestSessionNotFoundViewController (private)
- (void) completedRequest: (id) aResponse;
- (void) UpdatingRequest: (id) aResponse;
- (void) dismissKeyboard;
@end

@implementation TestSessionNotFoundViewController

@synthesize mActivationCode, mActivate, mDeactivate, mSendEvents, mStatus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        NSLog(@"set edgesForExtendedLayout");
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    mStatus.lineBreakMode = NSLineBreakByWordWrapping;
    mStatus.numberOfLines = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)activateClicked:(id)sender {
    [mStatus setText:@""];
    [mActivationCode resignFirstResponder];
    LicenseManager *licManager = [(TestAppAppDelegate *)[[UIApplication sharedApplication] delegate] mLicenseManager];
    [licManager setMActivationCode:[mActivationCode text]];
    LightActivationManager *activationManager = [(TestAppAppDelegate *)[[UIApplication sharedApplication] delegate] mActivationManager];
    [activationManager setMCompletedSelector:@selector(completedRequest:)];
    [activationManager setMUpdatingSelector:@selector(UpdatingRequest:)];
    [activationManager setMDelegate:self];
    [activationManager setMActivationCode:[mActivationCode text]];
    [activationManager sendActivation];
}

- (IBAction)deactivateClicked:(id)sender {
    [mStatus setText:@""];
    [mActivationCode resignFirstResponder];
    LicenseManager *licManager = [(TestAppAppDelegate *)[[UIApplication sharedApplication] delegate] mLicenseManager];
    [licManager setMActivationCode:[mActivationCode text]];
    LightActivationManager *activationManager = [(TestAppAppDelegate *)[[UIApplication sharedApplication] delegate] mActivationManager];
    [activationManager setMCompletedSelector:@selector(completedRequest:)];
    [activationManager setMUpdatingSelector:@selector(UpdatingRequest:)];
    [activationManager setMDelegate:self];
    [activationManager setMActivationCode:[mActivationCode text]];
    [activationManager sendDeactivation];
}

- (IBAction)sendEventsClicked:(id)sender {
    [mStatus setText:@""];
    [mActivationCode resignFirstResponder];
    LightEDM *EDM = [(TestAppAppDelegate *)[[UIApplication sharedApplication] delegate] mEDM];
    [EDM setMCompletedSelector:@selector(completedRequest:)];
    [EDM setMUpdatingSelector:@selector(UpdatingRequest:)];
    [EDM setMDelegate:self];
    [EDM sendRegularEvent];
}
    
- (void) completedRequest: (id) aResponse {
    ResponseData *response = [(DeliveryResponse *)aResponse mCSMReponse];
    NSString *date = [DateTimeFormat phoenixDateTime];
    NSString *yesno = [(DeliveryResponse *)aResponse mStillRetry] ? @"yes" : @"no";
    NSString *text = [NSString stringWithFormat:@"DATE: %@\nBEING RETRY: %@\nMESSAGE:%@", date, yesno, [response message]];
    [mStatus setText:text];
}
    
- (void) UpdatingRequest: (id) aResponse {
    ResponseData *response = [(DeliveryResponse *)aResponse mCSMReponse];
    NSString *date = [DateTimeFormat phoenixDateTime];
    NSString *yesno = [(DeliveryResponse *)aResponse mStillRetry] ? @"yes" : @"no";
    NSString *text = [NSString stringWithFormat:@"DATE: %@\nBEING RETRY: %@\nMESSAGE:%@", date, yesno, [response message]];
    [mStatus setText:text];
}
    
- (void) dismissKeyboard {
    [mActivationCode resignFirstResponder];
}

- (void) dealloc {
    [mActivationCode release];
    [mActivate release];
    [mDeactivate release];
    [mSendEvents release];
    [super dealloc];
}

@end
