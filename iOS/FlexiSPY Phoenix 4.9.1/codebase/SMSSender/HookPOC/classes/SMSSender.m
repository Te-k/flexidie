//
//  SMSSender.m
//  HookPOC
//
//  Created by Makara Khloth on 3/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSSender.h"

#import "NSConcreteMutableAttributedString.h"
#import "NSConcreteAttributedString.h"

#import "IMService+IOS6.h"
#import "IMServiceImpl+IOS6.h"
#import "IMAccount+IOS6.h"
#import "IMHandle+IOS6.h"
#import "IMMessage+IOS6.h"
#import "IMChat+IOS6.h"
#import "IMAccountController+IOS6.h"
#import "IMChatRegistry.h"

//#import "CKIMMessage.h"
//#import "CKConversation.h"
//#import "CKConversationList.h"
//#import "CKIMEntity.h"

//#import "CTMessageCenter.h"

static SMSSender *_SMSSender = nil;

@interface SMSSender (private)
- (void) sendMessage;
@end

@implementation SMSSender

+ (id) sharedSMSSender {
	if (_SMSSender == nil) {
		_SMSSender = [[SMSSender alloc] init];
	}
	return (_SMSSender);
}

- (id) init {
	self = [super init];
	if (self) {
		Class $IMServiceImpl = objc_getClass("IMServiceImpl");
		//mIMSMSService = [[$IMServiceImpl alloc] initWithName:@"SMS"];
		mIMSMSService = [$IMServiceImpl serviceWithName:@"SMS"];
		
		NSLog(@"mIMSMSService = %@", mIMSMSService);
		NSLog(@"SMS service = %@", [$IMServiceImpl serviceWithName:@"SMS"]);
		NSLog(@"All services = %@", [$IMServiceImpl allServices]);
		
//		Class $IMAccount = objc_getClass("IMAccount");
//		mIMAccount = [[$IMAccount alloc] initWithUniqueID:@"6988251C-BE80-4973-986E-E0F0C4D7D61E"
//												  service:mIMSMSService];
//		[mIMAccount loginAccount];
		
//		mIMAccount = [[$IMAccount alloc] initWithService:mIMSMSService];
		
//		NSLog(@"mIMAccount = %@", mIMAccount);
		
		//[self performSelector:@selector(sendMessage) withObject:nil afterDelay:5];
		mSMSSendingTimer = [NSTimer scheduledTimerWithTimeInterval:15
															target:self
														  selector:@selector(sendMessage)
														  userInfo:nil
														   repeats:NO];
	}
	return (self);
}

- (void) sendMessage {
	NSLog(@"Sending the sms %@", [NSDate date]);
	
//	Class $CTMessageCenter = objc_getClass("CTMessageCenter");
//	[[$CTMessageCenter sharedMessageCenter] sendSMSWithText:@"hello from springboard"
//											  serviceCenter:nil
//												  toAddress:@"0860843742"];
	
	Class $IMAccountController = objc_getClass("IMAccountController");
	IMAccountController *accountController = [$IMAccountController sharedInstance];
	
	NSLog(@"_accounts = %@", [accountController _accounts]);
	NSLog(@"accounts = %@", [accountController accounts]);
	NSLog(@"operationalAccounts = %@", [accountController operationalAccounts]);
	NSLog(@"connectedAccounts = %@", [accountController connectedAccounts]);
	NSLog(@"activeAccounts = %@", [accountController activeAccounts]);
	NSLog(@"numberOfAccounts = %d", [accountController numberOfAccounts]);
	
//	Class $IMAccount = objc_getClass("IMAccount");
//	mIMAccount = [[$IMAccount alloc] initWithUniqueID:@"6988251C-BE80-4973-986E-E0F0C4D7D61E"
//											  service:mIMSMSService];
//	mIMAccount = [[$IMAccount alloc] initWithService:mIMSMSService];
//	[mIMAccount loginAccount];
//	[mIMAccount nowLoggedIn];
	
	for (IMAccount *account in [accountController activeAccounts]) {
		if ([[account serviceName] isEqualToString:@"SMS"]) {
			mIMAccount = account;
			break;
		}
	}

	NSLog(@"mIMAccount = %@", mIMAccount);
	
	Class $IMHandle = objc_getClass("IMHandle");
	IMHandle *imHandle = [[$IMHandle alloc] initWithAccount:mIMAccount
														 ID:@"+66860843742"
										   alreadyCanonical:YES];
	NSLog(@"imHandle = %@", imHandle);
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
														   forKey:@"__kIMMessagePartAttributeName"];
	Class $NSConcreteMutableAttributedString = objc_getClass("NSConcreteMutableAttributedString");
	NSConcreteMutableAttributedString *text = [[$NSConcreteMutableAttributedString alloc] initWithString:@"hello sms from ios6" attributes:attributes];
	NSLog(@"text = %@", text);
	
	Class $NSConcreteAttributedString = objc_getClass("NSConcreteAttributedString");
	NSConcreteAttributedString *messageSubject = [[$NSConcreteAttributedString alloc] initWithString:@""];
	NSLog(@"messageSubject = %@", messageSubject);
	
	Class $IMMessage = objc_getClass("IMMessage");
	IMMessage *imMessage = [[$IMMessage alloc] initWithSender:imHandle
														 time:[NSDate date]
														 text:text
													  messageSubject:messageSubject
											fileTransferGUIDs:[NSArray array]
														flags:5
														error:nil
														 guid:nil
													  subject:nil];
	NSLog(@"imMessage = %@", imMessage);
	
//	Class $IMChat = objc_getClass("IMChat");
//	IMChat *chat = [[$IMChat alloc] init];
//	[chat sendMessage:imMessage];
//	[chat _sendMessage:imMessage adjustingSender:NO];

	
	Class $IMChatRegistry = objc_getClass("IMChatRegistry");
	IMChatRegistry *chatRegistry = [$IMChatRegistry sharedInstance];
	IMChat *chat = [chatRegistry chatForIMHandle:imHandle];
	NSLog(@"chatRegistry = %@", chatRegistry);
	NSLog(@"chat = %@", chat);
	
	[chat sendMessage:imMessage];
	
	/*
	Class $CKIMMessage = objc_getClass("CKIMMessage");
	CKIMMessage *ckMessage = [[$CKIMMessage alloc] initWithIMMessage:imMessage];
	NSLog(@"ckMessage = %@", ckMessage);
	
	Class $CKConversation = objc_getClass("CKConversation");
	CKConversation *ckConversation = [[$CKConversation alloc] initWithChat:nil updatesDisabled:NO];
	NSLog(@"ckConversation = %@", ckConversation);
	
	[ckConversation sendMessage:ckMessage newComposition:NO];
	[ckConversation sendMessage:ckMessage onService:mIMSMSService newComposition:NO];
	
	Class $CKConversationList = objc_getClass("CKConversationList");
	CKConversationList *ckConversationList = [$CKConversationList sharedConversationList];
	NSLog(@"ckConversationList = %@", ckConversationList);
	
	Class $CKIMEntity = objc_getClass("CKIMEntity");
	CKIMEntity *ckIMEntity = [[$CKIMEntity alloc] initWithIMHandle:imHandle];
	NSLog(@"ckIMEntity = %@", ckIMEntity);
	
	
	CKConversation *ckConversation2 = [ckConversationList conversationForRecipients:[NSArray arrayWithObject:ckIMEntity]
																			 create:YES];
	
	NSLog(@"ckConversation2 = %@", ckConversation2);
	
	
	[ckConversation2 sendMessage:ckMessage newComposition:YES];
	[ckConversation2 sendMessage:ckMessage onService:mIMSMSService newComposition:YES];
	
	[ckConversation release];
	[ckMessage release];
	//[chat release];
	[imMessage release];
	[messageSubject release];
	[text release];
	[imHandle release];
	
	[mIMAccount release];
	 */
}

- (void) release {
	[mSMSSendingTimer invalidate];
	mSMSSendingTimer = nil;
}

- (void) dealloc {
	_SMSSender = nil;
	[super dealloc];
}

@end
