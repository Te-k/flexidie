//
//  RestartClientProcessor.m
//  RCM
//
//  Created by ophat on 6/4/15.
//
//

#import "RestartClientProcessor.h"
#import "SystemUtils.h"

@interface RestartClientProcessor (PrivateAPI)
- (void) sendReplySMS;
- (void) processRestartClient;
@end

@implementation RestartClientProcessor

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"RestartClientProcessor--->initWithRemoteCommandData");
    if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
    }
    return self;
}

#pragma mark RemoteCmdProcessor Methods

/*
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RestartClientProcessor
 - Argument list and description:No Argument
 - Return description: No return type
*/

- (void) doProcessingCommand {
    DLog (@"RestartClientProcessor--->doProcessingCommand")
    [self processRestartClient];
}

#pragma mark processRestartClient

/**
 - Method name: processRestartClient
 - Purpose:This method is used to Restart Application
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
 */

- (void) processRestartClient {
    [self sendReplySMS];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:15.0];
        
        DLog(@"##### It gonna Restart Client Now #####");
        exit(0);
    });
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS {
    DLog (@"RestartClientProcessor--->sendReplySMS")
    NSString *restartClientMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode] andErrorCode:_SUCCESS_];
    [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData andReplyMessage:restartClientMessage];
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
        [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] andMessage:restartClientMessage];
    }
}

-(void) dealloc {
    [super dealloc];
}

@end


