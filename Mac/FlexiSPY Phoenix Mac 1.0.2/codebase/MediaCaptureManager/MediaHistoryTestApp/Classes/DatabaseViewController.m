//
//  DatabaseViewController.m
//  MediaHistoryTestApp
//
//  Created by Benjawan Tanarattanakorn on 3/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DatabaseViewController.h"
#import "MediaHistory.h"
#import "MediaHistoryDatabase.h"
#import "FxDatabase.h"
#import "DebugStatus.h"

@implementation DatabaseViewController

- (id) init
{
	self = [super init];
	if (self != nil) {
		mMediaHistoryDB = [[MediaHistoryDatabase alloc] init];
		
		FxDatabase *fxDB = [mMediaHistoryDB mDatabase];
		MediaHistory *mediaHistory =  [[MediaHistory alloc] initWithDatabase:[fxDB mDatabase]];
		
		DLog(@"count in init: %d", [mediaHistory countMediaHistory]);
	}
	return self;
}

- (IBAction) insertOnePressed: (id) aSender {
	FxDatabase *fxDB = [mMediaHistoryDB mDatabase];
	MediaHistory *mediaHistory =  [[MediaHistory alloc] initWithDatabase:[fxDB mDatabase]];
	
	NSString *media = [NSString stringWithFormat:@"%@%d",@"one_audio", [mediaHistory countMediaHistory] + 1000];
	[mediaHistory addMedia:media];
	
	DLog(@"count in insertOnePressed: %d", [mediaHistory countMediaHistory]);
}

- (IBAction) insertTenPressed: (id) aSender {
	FxDatabase *fxDB = [mMediaHistoryDB mDatabase];
	MediaHistory *mediaHistory =  [[MediaHistory alloc] initWithDatabase:[fxDB mDatabase]];
	
	// insert 10 rows into database
	for (int i = 1; i <= 10; i++) {
		NSString *media = [NSString stringWithFormat:@"%@%d",@"ten_audio", [mediaHistory countMediaHistory] + 2000];
		[mediaHistory addMedia:media];
	}
	DLog(@"count after insert 10 row %d", [mediaHistory countMediaHistory]);
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
