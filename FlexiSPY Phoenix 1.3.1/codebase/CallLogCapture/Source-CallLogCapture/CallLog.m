/**
 - Project name :  CallLogCapture 
 - Class name   :  CallLog
 - Version      :  1.0  
 - Purpose      :  For Call Log Capturing Component
 - Copy right   :  30/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "CallLog.h"


@implementation CallLog

@synthesize mContactNumber;
@synthesize mCallState;
@synthesize mDuration;
@synthesize mCallHistoryROWID;

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mContactNumber release];
	[super dealloc];
}

@end
