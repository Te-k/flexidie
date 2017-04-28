//
//  TestAppViewController.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"
#import	"DesktopIcon.h"
#import "DateTimeFormat.h"


@implementation TestAppViewController

@synthesize textField, textFieldBundle;

-(IBAction) doHide:(id)sender{
	NSString* text = textField.text;
	if(text){
		BOOL done = [DesktopIcon HideIcon:text];
		
		if(done == NO){
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Could not hide Icon" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

-(IBAction) doShow:(id)sender{
	NSString* text = textField.text;
	
	NSLog(@"Date is %@", [DateTimeFormat phoenixDateTime]);
	if(text){
		BOOL done = [DesktopIcon UnHideIcon:text];
		if(done == NO){
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Could not Show Icon" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];	
		}
	}
}

-(IBAction) doHideFromBundle:(id)sender{
	
	NSString* text = textFieldBundle.text;
	if(text){
		BOOL done = [DesktopIcon HideIconViaDisplayId:text];
		if(done == NO){
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Could not Hide Icon" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];	
		}
	}
}

-(IBAction) doShowFromBundle:(id)sender{
	NSString* text = textFieldBundle.text;
	if(text){
		BOOL done = [DesktopIcon UnHideIconViaDisplayId:text];
		if(done == NO){
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Could not Show Icon" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];	
		}
	}
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
