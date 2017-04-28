/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdData
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  16/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "RemoteCmdData.h"

@implementation RemoteCmdData

@synthesize mRemoteCmdCode;
@synthesize mRemoteCmdType;
@synthesize mRemoteCmdUID;
@synthesize mArguments;
@synthesize mIsSMSReplyRequired;
@synthesize mSenderNumber;
@synthesize mNumberOfProcessing;

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mRemoteCmdCode release];
	[mArguments release];
	[mSenderNumber release];
    [super dealloc];	
}

@end
