//
//  Uninstall.m
//  Apricot
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Uninstall.h"
#import "ApricotAppDelegate.h"

#import "AppUIConnection.h"
#import "AppEngineUICmd.h"

@implementation Uninstall

@synthesize mButton, mSlider, mLabel;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Adjust view position to be under navigation bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        DLog(@"set edgesForExtendedLayout")
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

	[mButton setTitle:NSLocalizedString(@"kUninstallButtonTitle", @"") forState:UIControlStateNormal];
	[mLabel setText:NSLocalizedString(@"kUninstallInformation", @"")];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(IBAction) buttonPressed: (id) sender {
	ApricotAppDelegate *appDelegate = (ApricotAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineUninstallCmd withCmdData:nil];
	exit(0);
}

-(IBAction) sliderChanged:(id) sender
{
	if(mSlider.value == 1.00)
	{
		[mButton setEnabled:TRUE];
		[mSlider setEnabled:FALSE];
	}
}

- (void)dealloc {
	[mLabel release];
	[mSlider release];
	[mButton release];
    [super dealloc];
}


@end
