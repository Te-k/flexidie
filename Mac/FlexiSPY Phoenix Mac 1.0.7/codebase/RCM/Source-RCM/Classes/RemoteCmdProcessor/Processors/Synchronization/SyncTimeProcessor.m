//
//  SyncTimeProcessor.m
//  RCM
//
//  Created by Makara Khloth on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncTimeProcessor.h"
#import "SyncTimeManager.h"

@interface SyncTimeProcessor (PrivateAPI)
- (void) processSyncTime;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end

@implementation SyncTimeProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the SyncTimeProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (SyncTimeProcessor).
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SyncTimeProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark SyncTimeProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SyncTimeProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"SyncTimeProcessor--->doProcessingCommand")
	[self processSyncTime];
}


#pragma mark SyncTimeProcessor Private Methods

/**
 - Method name: processSyncTime
 - Purpose:This method is used to process sync time
 - Argument list and description: No Argument
 - Return description: No return type
 */


- (void) processSyncTime {
	DLog (@"SyncTimeProcessor--->processSyncTime")
	SyncTimeManager *syncTimeManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mSyncTimeManager];
	[syncTimeManager appendSyncTimeDelegate:self];
	[syncTimeManager syncTime];
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
	NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kSyncTimeSucessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"SyncTimeProcessor--->sendReplySMS...")
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
	DLog (@"SyncTimeProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

#pragma mark SyncTimeManager Delegate Methods

/**
 - Method name: syncTimeSuccess
 - Purpose:This method is invoked when sync time is delivered successfully
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) syncTimeSuccess {
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *replyMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSyncTimeSucessMSG2", @"")];
	
	// Remove processor from the array inside SyncTimeManager
	[[[RemoteCmdUtils sharedRemoteCmdUtils] mSyncTimeManager] removeSyncTimeDelegate:self];
	
   	[self sendReplySMS:replyMessage isProcessCompleted:YES];
}

/**
 - Method name: syncTimeError:error:
 - Purpose:This method is invoked when time sync with server is failed
 - Argument list and description:aDDMErrorType (NSNumber *) aDDMErrorType, aError (NSError*) error from sync time manager
	which userInfo is nil, error code is server status
 - Return description: No return type
 */

- (void) syncTimeError: (NSNumber *) aDDMErrorType error: (NSError *) aError {
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:[aError code]];
	// Remove processor from the array inside SyncTimeManager
	[[[RemoteCmdUtils sharedRemoteCmdUtils] mSyncTimeManager] removeSyncTimeDelegate:self];
	
	[self sendReplySMS:messageFormat isProcessCompleted:YES];
}


/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
	DLog (@"SyncTimeProcessor is now dealloced")
	[super dealloc];
}

@end
