//
//  HistoricalCallLog.m
//  CallLogCapture
//
//  Created by Benjawan Tanarattanakorn on 12/16/2557 BE.
//
//

#import "HistoricalCallLog.h"

@implementation HistoricalCallLog

@synthesize mDate;

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	[mDate release];
	[super dealloc];
}

@end
