//
//  TestPanicViewController.m
//  TestPanic
//
//  Created by Dominique  Mayrand on 11/16/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestPanicViewController.h"


@implementation TestPanicViewController

@synthesize panicButton;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	NSLog(@"----------initializing test app--------------");
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
          }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if(!panicButton){
		// Custom initialization
		NSLog(@"----------initializing panic delegate--------------");
		panicButton = [[PanicButton alloc] init];
		if(panicButton)
		{
			[panicButton setDelegate:self];
		}
	}
}


-(void) PanicButtonTriggered
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Panic" 
												message:@"TestApp Panic receive" 
												delegate:nil 
												cancelButtonTitle:@"OK" 
												otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}


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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[panicButton release];
    [super dealloc];
}

@end
