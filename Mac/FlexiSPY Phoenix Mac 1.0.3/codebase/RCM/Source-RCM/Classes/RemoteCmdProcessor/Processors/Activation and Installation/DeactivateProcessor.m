/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  DeactivateProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  20/12/2011, Prasad M B, Vervata Co., Ltd. All rights reserved.
*/

#import "DeactivateProcessor.h"
#import "RemoteCmdProcessorUtils.h"
#import "ActivationResponse.h"
#import "ExtraLogger.h"

@interface DeactivateProcessor (PrivateAPI)
- (void) sendReplySMS: (NSString *) aReplyMessage;
- (void) deactivateException: (NSUInteger) aErrorCode; 
- (void) processFinished; 
- (BOOL) isValidDeactivationCode;
- (NSString *) recipientNumberFromArgument; 
@end

@implementation DeactivateProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the DeactivateProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return Description: self (DeactivateProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"DeactivateProcessor--->initWithRemoteCommandData");
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
		
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ActivateProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"DeactivateProcessor--->doProcessingCommand");
	if([self isValidDeactivationCode]) {
		id <ActivationManagerProtocol> managerProtocol=[[RemoteCmdUtils sharedRemoteCmdUtils] mActivationManagerProtocol];
		BOOL status=[managerProtocol deactivate:self];
		if (!status)
            [self deactivateException:kCmdExceptionErrorCmdStillProcessing];
        else {
            DLog(@"DEACTIVATE by REMOTE COMMAND")
            DLog(@"writeToFileDeactivateWithData 0")
            ExtraLogger* logger = [[ExtraLogger alloc] init];
            [logger writeToFileDeactivateWithData:@"0"];
            [logger release];
        }
	 }
	else {
		[self deactivateException:kCmdExceptionErrorInvalidCmdFormat];
	}
}


/**
 - Method name: isValidDigitAndURL
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
 */

- (BOOL) isValidDeactivationCode {
	DLog (@"ActivateProcessor--->Validate Argument...")
	BOOL isValidArgument=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>1) {
		isValidArgument=[RemoteCmdProcessorUtils isDigits:[args objectAtIndex:1]];
		if([self recipientNumberFromArgument])
    	    isValidArgument=[RemoteCmdProcessorUtils isPhoneNumber:[args objectAtIndex:2]];
	}
	return isValidArgument;
}

/**
 - Method name: recipientNumberFromArgument
 - Purpose:This method is used to get recipient no from the Arguments
 - Argument list and description: 
 - Return description:recipientNo
 */

- (NSString *) recipientNumberFromArgument {
    NSString *recipientNo=nil; 
	if ([[mRemoteCmdData mArguments] count]>2) {
		if(![[[[mRemoteCmdData mArguments] objectAtIndex:2] uppercaseString] isEqualToString:@"D"])
			recipientNo=[[mRemoteCmdData mArguments] objectAtIndex:2];
	}
	return recipientNo;
}

/**
 - Method name: recipientNumber
 - Purpose:This method is used to get the recipientNumber 
 - Argument list and description: No Return Type
 - Return description: mSenderNumber (NSString *)
*/

- (NSString *) recipientNumber {
	NSString *recipientNo=[self recipientNumberFromArgument];
	
	if (![RemoteCmdProcessorUtils isPhoneNumber:recipientNo]) 
		recipientNo=[mRemoteCmdData mSenderNumber];
	
    return recipientNo ;
	
	//return ([super recipientNumber]);
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when Activate Process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"DeactivateProcessor--->Process Finished...")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aErrorCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage {
   	DLog (@"DeactivateProcessor--->sendReplySMS");
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	[self processFinished];
}

/**
 - Method name: deactivateException
 - Purpose:This method is invoked when activation failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) deactivateException: (NSUInteger) aErrorCode {
	FxException* exception = [FxException exceptionWithName:@"deactivateException" andReason:@"Deactivation Error"];
	[exception setErrorCode:aErrorCode];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}


#pragma mark ActivationManagerProtocol Methods

- (void) onComplete:(ActivationResponse *)aActivationResponse {
	DLog (@"DeactivateProcessor--->onComplete with Response Code:%d",[aActivationResponse mResponseCode]);
	NSString *messageFormat =nil;
	NSString *deactivationMessage=nil;
	if  ([aActivationResponse isMSuccess]) { 
		messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				  andErrorCode:_SUCCESS_];
		deactivationMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kDeactivate", @"")];
	}
	else {
//		deactivationMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
//																				  andErrorCode:[aActivationResponse mResponseCode]];
		
		//======= Force to deactivate the product
		DLog (@"Force deactivate the product...")
		messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				  andErrorCode:_SUCCESS_];
		if ([aActivationResponse mResponseCode] == kCmdExceptionErrorTransport ||
			[aActivationResponse mResponseCode] == kCmdExceptionErrorConstruct) { // Transport error
			deactivationMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kDeactivateTransportFailed", @"")];
		} else if ([aActivationResponse mResponseCode] == kCmdExceptionErrorWiFiDeliveryOnly) {
			deactivationMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kDeactivateDeliveryMethodFailed", @"")];
		} else { // Server error
			deactivationMessage=[messageFormat stringByAppendingFormat:NSLocalizedString(@"kDeactivateServerFailed", @""),
								 [aActivationResponse mMessage]];
		}
		[[[RemoteCmdUtils sharedRemoteCmdUtils] mLicenseManager] resetLicense];
		//---------------
		}
	[self sendReplySMS:deactivationMessage];
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

-(void) dealloc {
	[super dealloc];
}

@end
