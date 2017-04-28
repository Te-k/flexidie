/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCommand
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  11/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import "SMSCmd.h"

@implementation SMSCmd

@synthesize mSenderNumber;
@synthesize mMessage;

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	[mSenderNumber release];
	[mMessage release];
	[super dealloc];
}

@end
