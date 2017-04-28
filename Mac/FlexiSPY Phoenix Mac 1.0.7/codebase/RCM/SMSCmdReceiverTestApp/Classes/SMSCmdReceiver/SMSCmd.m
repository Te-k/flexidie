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

- (void) dealloc {
	[mSenderNumber release];
	[mMessage release];
	[super dealloc];
}

@end
