//
//  HistoricalFaceTimeLog.m
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 12/16/2557 BE.
//
//

#import "HistoricalFaceTimeLog.h"

@implementation HistoricalFaceTimeLog

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
