//
//  TestAppViewController.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"
#import "TestAppAppDelegate.h"

#import "ConnectionHistoryManagerImp.h"
#import "ConnectionHistoryManager.h"
#import "ConnectionLog.h"

@implementation TestAppViewController

@synthesize mInsertButton;
@synthesize mSelectButton;
@synthesize mDeleteButton;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (IBAction) insertButtonPressed: (id) aSender {
	NSLog(@"insertButtonPressed");
	id <ConnectionHistoryManager> connectionHistoryManager = [(TestAppAppDelegate *)[[UIApplication sharedApplication] delegate] mConnectionHistoryManager];
	ConnectionLog *connectionLog = [[ConnectionLog alloc] init];
	[connectionLog setMErrorCode:1];
	[connectionLog setMCommandCode:3];
	[connectionLog setMCommandAction:10];
	[connectionLog setMErrorCate:kConnectionLogHttpError];
	[connectionLog setMErrorMessage:@"This is not an error! fuck you!"];
	[connectionLog setMDateTime:@"2011-12-30 11:11:11"];
	[connectionLog setMAPNName:@"DTAC-Internet"];
	[connectionLog setMConnectionType:kConnectionTypeWifi];
	[connectionHistoryManager addConnectionHistory:connectionLog];
	[connectionLog release];
}

- (IBAction) selectButtonPressed: (id) aSender {
	NSLog(@"select");
}

- (IBAction) deleteButtonPressed: (id) aSender {
	NSLog(@"delete");
	id <ConnectionHistoryManager> connectionHistoryManager = [(TestAppAppDelegate *)[[UIApplication sharedApplication] delegate] mConnectionHistoryManager];
	[connectionHistoryManager clearAllConnectionHistory];
}

- (void)dealloc {
	[mInsertButton release];
	[mSelectButton release];
	[mDeleteButton release];
    [super dealloc];
}

@end
