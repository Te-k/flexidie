/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetUpdateAvailableProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/


#import "SyncUpdateAvailableProcessor.h"


@interface SyncUpdateAvailableProcessor (PrivateAPI)
- (void) sendReplySMS;
- (void) processSyncUpdateAvailable;
@end

@implementation SyncUpdateAvailableProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SyncUpdateAvailableProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (SyncUpdateAvailableProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"SyncUpdateAvailableProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SyncUpdateAvailableProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"SyncUpdateAvailableProcessor--->doProcessingCommand")
	[self processSyncUpdateAvailable];
}

#pragma mark SyncUpdateAvailableProcessor Private Methods

/**
 - Method name: processSyncUpdateAvailable
 - Purpose:This method is used to process SyncUpdateAvailable 
 - Argument list and description: No Argument 
 - Return description: No Return Type
*/

- (void) processSyncUpdateAvailable {
	DLog (@"SyncUpdateAvailableProcessor--->processSyncUpdateAvailable")
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"SyncUpdateAvailableProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							andErrorCode:_SUCCESS_];
	NSString *syncUpdateAvailableMessage=[NSString stringWithFormat:@"%@%@",messageFormat,NSLocalizedString(@"kSyncUpdateAvailable", @"")];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:syncUpdateAvailableMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
															   andMessage:syncUpdateAvailableMessage];
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
