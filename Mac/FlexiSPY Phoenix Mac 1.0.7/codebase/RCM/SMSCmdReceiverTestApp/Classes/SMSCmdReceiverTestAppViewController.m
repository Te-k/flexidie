/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCommandReceiverViewController
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  11/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "SMSCmdReceiverTestAppViewController.h"
#import "SMSCmdReceiver.h"
#import "SMSCmd.h"

@interface SMSCmdReceiverTestAppViewController (Private)
- (void) cancelCurrentOperation;
@end
@implementation SMSCmdReceiverTestAppViewController

/**
 - Method name:stopMonitoring
 - Purpose:  Implement viewDidLoad if you need to do additional setup after loading the view
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void)viewDidLoad {
	[super viewDidLoad];
}

/**
 - Method name:start
 - Purpose:  To start monitoring sms command
 - Argument list and description: sender (UIButton instance)
 - Return type and description: IBAction
 */

- (IBAction) start: (id) sender {
	[self cancelCurrentOperation];
	mSMSCommandReceiver =[[SMSCmdReceiver alloc] init];
	[mSMSCommandReceiver setMDelegate:self];
	[mSMSCommandReceiver startMonitoring];
}

/**
 - Method name:stop
 - Purpose:  To stop monitoring sms command
 - Argument list and description: sender (UIButton instance)
 - Return type and description: IBAction
 */

- (IBAction) stop: (id) sender {
	[self cancelCurrentOperation];
}

/**
 - Method name:cancelCurrentOperation
 - Purpose:  To cancel the current operation
 - Argument list and description: sender (UIButton instance)
 - Return type and description: IBAction
 */

- (void) cancelCurrentOperation {
	if(mSMSCommandReceiver!=nil) {
		[mSMSCommandReceiver stopMonitoring];
		[mSMSCommandReceiver setMDelegate:nil];
		[mSMSCommandReceiver release];
		mSMSCommandReceiver=nil;
	}
}

/**
 - Method name: didSMSCommandReceived
 - Purpose: Callback function when sms command is received via socket
 - Argument list and description: aCommand, the sms command
 - Return description: No return type
 */

- (void) didSMSCommandReceived: (SMSCmd*) aCommand {
	NSString *smsCommand=[NSString stringWithFormat:@"Command:%@,Sender:%@",aCommand.mMessage,aCommand.mSenderNumber];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomming SMS Sommand" message:smsCommand delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void)dealloc {
	[super dealloc];
}

@end
