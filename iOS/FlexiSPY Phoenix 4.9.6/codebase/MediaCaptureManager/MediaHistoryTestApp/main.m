//
//  main.m
//  MediaHistoryTestApp
//
//  Created by Benjawan Tanarattanakorn on 3/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaHistory.h"
#import "MediaHistoryDatabase.h"
#import "FxDatabase.h"
#import "DebugStatus.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	
	MediaHistoryDatabase *mMediaHistoryDB = [[MediaHistoryDatabase alloc] init];
	
	FxDatabase *fxDB = [mMediaHistoryDB mDatabase];
	MediaHistory *mediaHistory =  [[MediaHistory alloc] initWithDatabase:[fxDB mDatabase]];
	
	DLog(@"count in init: %d", [mediaHistory countMediaHistory]);
	
	NSString *media = [NSString stringWithFormat:@"%@%d",@"one_audio", [mediaHistory countMediaHistory] + 1000];
	[mediaHistory addMedia:media];
	
	DLog(@"count in insertOnePressed: %d", [mediaHistory countMediaHistory]);
	
	DLog(@"one_audio1053 exist?: %d", [mediaHistory checkDuplication:@"one_audio1004"]);
	DLog(@"one_audio1054 exist?: %d", [mediaHistory checkDuplication:@"one_audio1010"]);
   	DLog(@"audio8: %d", [mediaHistory checkDuplication:@"audio8"]);

	//[mediaHistory release];
	[mMediaHistoryDB release];

	CFRunLoopRun();
	
    [pool release];
    return retVal;
}
