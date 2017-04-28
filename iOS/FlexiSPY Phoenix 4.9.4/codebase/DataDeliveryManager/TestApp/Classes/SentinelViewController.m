//
//  SentinelViewController.m
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import "SentinelViewController.h"
#import "TestAppAppDelegate.h"

#import "UseCases.h"
#import "TestManager.h"
#import "SentinelLogger.h"
#import "UseCaseFailureSender.h"

#import "AppContextImpl+Dummy.h"
#import "PhoneInfoImpl+Dummy.h"
#import "LicenseManager+Dummy.h"
#import "LightActivationManager.h"

#import "DeliveryResponse.h"

@interface SentinelViewController (private)
- (void) dismissKeyboard;
- (void) usecaseIDCompleted:(NSNumber *) aUseCaseID result: (id) aResult;
@end

@implementation SentinelViewController

@synthesize mIMEI, mActivationCode, mCycleTime, mEmail;
@synthesize mUseCaseACT_DEACT, mUseCaseACT_SENDPIC, mSkipUseCase, mPostUseCase;
@synthesize mStartStop, mSendReport;
@synthesize mStatusSummary, mSpinner, mTap;

@synthesize mTestManager;

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.mTap = tap;
    [tap release];
    
    self.mStatusSummary.text = @"";
    self.mStatusSummary.scrollEnabled = YES;
    self.mStatusSummary.userInteractionEnabled = NO;
    
    if (mIsTesting) {
        self.mSpinner.hidden = NO;
        [self.mSpinner startAnimating];
    } else {
        [self.mSpinner stopAnimating];
        self.mSpinner.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startstopClicked:(id)sender {
    TestAppAppDelegate *applicationDelegate = (TestAppAppDelegate *)[[UIApplication sharedApplication] delegate];
    id <AppContext> applicationContext = [applicationDelegate mAppContextImpl];
    id <PhoneInfo> phoneInfo = [applicationContext getPhoneInfo];
    [phoneInfo setPhoneIMEI:self.mIMEI.text];
    
    LicenseManager *licenseManager = [applicationDelegate mLicenseManager];
    [licenseManager setMActivationCode:self.mActivationCode.text];
    
    self.mTestManager = [applicationDelegate mTestManager];
    self.mTestManager.mActivationManager.mActivationCode = self.mActivationCode.text;
    
    if (!mIsTesting) {
        self.mStatusSummary.text = @"";
        
        self.mTestManager.mDelegate = self;
        self.mTestManager.mSelector = @selector(usecaseIDCompleted:result:);
        
        UseCases *usecases = [[[UseCases alloc] init] autorelease];
        NSMutableArray *usecaseDicts = [NSMutableArray array];
        
        if (mUseCaseACT_DEACT.on) {
            NSMutableDictionary *usecaseDict = [NSMutableDictionary dictionary];
            [usecaseDict setObject:[NSNumber numberWithInteger:kSentinelUseCaseACT] forKey:@"usecaseAction"];
            [usecaseDict setObject:@"Activate" forKey:@"usecaseActionName"];
            [usecaseDict setObject:@"Activate and Deactivate" forKey:@"usecaseName"];
            [usecaseDict setObject:[NSNumber numberWithUnsignedInteger:NSUIntegerMax] forKey:@"numberOfExecute"];
            [usecaseDicts addObject:usecaseDict];
            
            usecaseDict = [NSMutableDictionary dictionary];
            [usecaseDict setObject:[NSNumber numberWithInteger:kSentinelUseCaseDEACT] forKey:@"usecaseAction"];
            [usecaseDict setObject:@"Deactivate" forKey:@"usecaseActionName"];
            [usecaseDict setObject:@"Activate and Deactivate" forKey:@"usecaseName"];
            [usecaseDict setObject:[NSNumber numberWithUnsignedInteger:NSUIntegerMax] forKey:@"numberOfExecute"];
            [usecaseDicts addObject:usecaseDict];
        }
        
        if (mUseCaseACT_SENDPIC.on) {
            NSMutableDictionary *usecaseDict = [NSMutableDictionary dictionary];
            [usecaseDict setObject:[NSNumber numberWithInteger:kSentinelUseCaseACT] forKey:@"usecaseAction"];
            [usecaseDict setObject:@"Activate" forKey:@"usecaseActionName"];
            [usecaseDict setObject:@"Activate and Send Pictures" forKey:@"usecaseName"];
            [usecaseDict setObject:[NSNumber numberWithUnsignedInteger:1] forKey:@"numberOfExecute"];
            [usecaseDicts addObject:usecaseDict];
            
            usecaseDict = [NSMutableDictionary dictionary];
            [usecaseDict setObject:[NSNumber numberWithInteger:kSentinelUseCaseSENDPIC] forKey:@"usecaseAction"];
            [usecaseDict setObject:@"Send Pictures" forKey:@"usecaseActionName"];
            [usecaseDict setObject:@"Activate and Send Pictures" forKey:@"usecaseName"];
            [usecaseDict setObject:[NSNumber numberWithUnsignedInteger:NSUIntegerMax] forKey:@"numberOfExecute"];
            [usecaseDicts addObject:usecaseDict];
        }
        
        NSInteger cycleTime = [[mCycleTime text] integerValue];
        
        usecases.mCycleTime = cycleTime;
        usecases.mUseCaseDicts = usecaseDicts;
        usecases.mSkipFailedUseCase = mSkipUseCase.on;
        usecases.mPostFailedUseCase = mPostUseCase.on;
        usecases.mEmail = mEmail.text;
        
        [self.mTestManager setMUseCases:usecases];
        [mTestManager startTesting];
        
        self.mSpinner.hidden = NO;
        [self.mSpinner startAnimating];
        [self.mStartStop setTitle:@"Stop" forState:UIControlStateNormal];
        mIsTesting = true;
    } else {
        [mTestManager stopTesting];
        
        self.mSpinner.hidden = YES;
        [self.mSpinner stopAnimating];
        [self.mStartStop setTitle:@"Start" forState:UIControlStateNormal];
        mIsTesting = false;
    }
}

- (IBAction)sendReportByEmailClicked:(id)sender {
    SentinelLogger *logger = [SentinelLogger sharedSentinelLogger];
    NSString *logFilePath = [logger getLogFilePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:logFilePath]) {
        // -- Send by Messages
        /*
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        [picker setSubject:@"iOS Sentinel Test Report"];

        NSURL *url = [NSURL fileURLWithPath:logFilePath];
        
        [picker addAttachmentURL:url withAlternateFilename:nil];
        
        [self presentViewController:picker animated:NO completion:nil];
        
        [picker release];
         */
        
        // -- Send by Mail
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            if (self.mEmail.text) {
                NSArray *to = [NSArray arrayWithObject:self.mEmail.text];
                [picker setToRecipients:to];
            }
            
            [picker setSubject:@"iOS Sentinel Test Report"];
            
            NSURL *url = [NSURL fileURLWithPath:logFilePath];
            
            NSData *attData = [NSData dataWithContentsOfURL:url];
            
            [picker addAttachmentData:attData mimeType:@"text/csv" fileName:[logFilePath lastPathComponent]];
            
            [self presentViewController:picker animated:NO completion:nil];
            
            [picker release];
        } else {
            // Please set up email properly
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:@"Sentinel"];
            [alert setMessage:@"Please set up email properly"];
            //[alert setDelegate:self];
            [alert addButtonWithTitle:@"Ok"];
            [alert show];
            [alert release];
        }
    } else {
        // Please run the to generate report file
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Sentinel"];
        [alert setMessage:@"Please run the to generate report file"];
        //[alert setDelegate:self];
        [alert addButtonWithTitle:@"Ok"];
        [alert show];
        [alert release];
    }
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultSent:
            NSLog(@"Sent");
            SentinelLogger *logger = [SentinelLogger sharedSentinelLogger];
            [logger deleteLogFile];
            break;
        case MessageComposeResultFailed:
            NSLog(@"Failed");
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Sent");
            SentinelLogger *logger = [SentinelLogger sharedSentinelLogger];
            [logger deleteLogFile];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Sent");
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void) dismissKeyboard {
    [mIMEI resignFirstResponder];
    [mActivationCode resignFirstResponder];
    [mCycleTime resignFirstResponder];
    [mEmail resignFirstResponder];
    [mStatusSummary resignFirstResponder];
}

- (void) usecaseIDCompleted:(NSNumber *) aUseCaseID result: (id) aResult {
    NSString *action = nil;
    if ([aUseCaseID integerValue] == kSentinelUseCaseACT) {
        action = @"ACT";
    } else if ([aUseCaseID integerValue] == kSentinelUseCaseSENDPIC) {
        action = @"SEND_PIC";
    } else if ([aUseCaseID integerValue] == kSentinelUseCaseDEACT) {
        action = @"DEACT";
    }
    
    NSLog(@"use case ID: %@, action: %@", aUseCaseID, action);
    
    DeliveryResponse *response = aResult;
    NSString *statusSummary = [NSString stringWithFormat:@"*** %@ (%@)\nInfo: %ld, %@\n", action, [NSDate date], (long)[response mStatusCode], [response mStatusMessage]];
    
    self.mStatusSummary.text = [NSString stringWithFormat:@"%@%@", statusSummary, self.mStatusSummary.text];
}

- (void) dealloc {
    [self setMIMEI:nil];
    [self setMActivationCode:nil];
    [self setMCycleTime:nil];
    [self setMEmail:nil];
    [self setMUseCaseACT_DEACT:nil];
    [self setMUseCaseACT_SENDPIC:nil];
    [self setMSkipUseCase:nil];
    [self setMPostUseCase:nil];
    [self setMStartStop:nil];
    [self setMSendReport:nil];
    [self setMStatusSummary:nil];
    [self setMTap:nil];
    [super dealloc];
}

@end
