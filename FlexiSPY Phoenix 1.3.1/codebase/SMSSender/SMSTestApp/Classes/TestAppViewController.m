//
//  TestAppViewController.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"

#import "IMService+IOS6.h"
#import "IMServiceImpl+IOS6.h"
#import "IMAccount+IOS6.h"
#import "IMAccountController+IOS6.h"
#import "IMHandle+IOS6.h"
#import "IMChat+IOS6.h"
#import "IMChatRegistry.h"
#import "IMMessage+IOS6.h"

#import "NSConcreteMutableAttributedString.h"
#import "NSConcreteAttributedString.h"

#import "MessagePortIPCSender.h"

#import <objc/runtime.h>

#import <dlfcn.h>

@interface TestAppViewController (private)
- (void) sendMessage: (NSString *) aText toAddress: (NSString *) aAddress;
- (void) sendMessage000: (NSString *) aText toAddress: (NSString *) aAddress;
@end

@implementation TestAppViewController

@synthesize mMessageTextTextField, mAddressTextField, mSendSMSButton;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction) sendSMSButtonClicked: (id) aSender {
	if ([[mMessageTextTextField text] length] > 0 &&
		[[mAddressTextField text] length] > 0) {
		//[self sendMessage:[mMessageTextTextField text] toAddress:[mAddressTextField text]];
		[self sendMessage000:[mMessageTextTextField text] toAddress:[mAddressTextField text]];
	}
}

- (void) sendMessage: (NSString *) aText toAddress: (NSString *) aAddress {
	
	// Not work because of entitlement:
	// [Warning] Not entitled, *Not* granting listener port: com.yourcompany.TestApp pid: 5838 process: TestApp
	// [Warning] Bad response from daemon for setup info
	
	void *framework_handle = dlopen("/System/Library/PrivateFrameworks/IMCore.framework/IMCore", RTLD_LAZY);
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
	
	dlclose(framework_handle);
}

- (void) sendMessage000: (NSString *) aText toAddress: (NSString *) aAddress {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"SMSSENDERMSGPORT"];
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

- (void)dealloc {
	[mAddressTextField release];
	[mMessageTextTextField release];
	[mSendSMSButton release];
    [super dealloc];
}

@end
