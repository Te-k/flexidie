//
//  SMSSendManager.m
//  SMSSender
//
//  Created by Makara Khloth on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SMSSendManager.h"
#import "SMSSendMessage.h"
#import "CTMessageCenter.h"

#import "MessagePortIPCSender.h"
#import "DefStd.h"

#import <UIKit/UIKit.h>

@interface SMSSendManager (private)
- (void) sendMessage000: (NSString *) aText toAddress: (NSString *) aAddress;
@end

@implementation SMSSendManager

- (id) init {
	if ((self = [super init])) {
		mSendMessageQueue = [[NSMutableArray alloc] init];
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
			mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kSentSMSCmdReplyMessagePort
													 withMessagePortIPCDelegate:self];
			[mMessagePortReader start];
		}
	}
	return (self);
}

- (void) sendSMS: (SMSSendMessage*) aSendMessage {
	if ([[[UIDevice currentDevice] systemVersion] intValue] < 6) {
		[[CTMessageCenter sharedMessageCenter] sendSMSWithText:[aSendMessage mMessage]
												 serviceCenter:nil
													 toAddress:[aSendMessage mRecipientNumber]];
	} else {
		[self sendMessage000:[aSendMessage mMessage]
				   toAddress:[aSendMessage mRecipientNumber]];
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"SMS sending is finished .... ");
	system("killall MobileSMS"); // To clear the cache in MobileSMS UI
	system("killall biteSMS"); // To clear the cache in biteSMS UI
}

- (void) sendMessage000: (NSString *) aText toAddress: (NSString *) aAddress {
	DLog (@"Sending aText = %@ to aAddress = %@", aText, aAddress);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kSendSMSCmdReplyMessagePort];
	NSMutableData *messageData = [NSMutableData data];
	
	NSInteger lengthOfText = [aText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSInteger lengthOfAddress = [aAddress lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	[messageData appendBytes:&lengthOfText length:sizeof(NSInteger)];
	[messageData appendData:[aText dataUsingEncoding:NSUTF8StringEncoding]];
	[messageData appendBytes:&lengthOfAddress length:sizeof(NSInteger)];
	[messageData appendData:[aAddress dataUsingEncoding:NSUTF8StringEncoding]];
	
	[messagePortSender writeDataToPort:messageData];
	[messagePortSender release];
	[pool release];
}

- (void) dealloc {
	[mSendMessageQueue release];
	[mMessagePortReader release];
	[super dealloc];
}

@end
