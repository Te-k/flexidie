//
//  TestAppViewController.m
//  TestApp
//
//  Created by Dominique  Mayrand on 11/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"
#import "ServerAddressManagerImp.h"
#import "DebugStatus.h"

@implementation TestAppViewController

@synthesize labelURLToLoad, labelURLToSave, labelStructured, labelUnstructured, labelRequired, switchBaseRequired;

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

/*
 @protocol ServerAddressChangeDelegate
 */
- (void) serverAddressChanged {
	DLog (@"serverAddressChanged")
}

- (void) testInitWithDelegate {	
	DLog (@">>>>> testInitWithDelegate")
	ServerAddressManagerImp* serv = [[ServerAddressManagerImp alloc]initWithServerAddressChangeDelegate:self];
	[serv setBaseServerUrl:[labelURLToSave text]];		
	[serv release];
}

- (void) saveURL:(id)sender {
	DLog (@">>>>> saveURL")
	if (serv) {
		[serv release];
	}
	serv = [[ServerAddressManagerImp alloc]init];
	//[serv setServerUrl:[labelURLToSave text]];
	[serv setBaseServerUrl:[labelURLToSave text]];		// call serverAddressChanged on its delegate
	[serv setRequireBaseServerUrl:switchBaseRequired.on];
	//[serv release];
		
	//[self testInitWithDelegate];
	
	[labelURLToSave resignFirstResponder];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField{
	//label.text = textField.text;
	[textField resignFirstResponder];	
	return YES;
}

-(void) loadURL:(id)sender
{
	//ServerAddressManagerImp* serv	= [[ServerAddressManagerImp alloc]init];
	DLog(@"getHostServerUrl")
//	NSString *string = [serv getBaseServerUrl];
	NSString *string				= [serv getHostServerUrl];
	if(string != nil){
		[labelURLToLoad setText:string];
	}else{
		[labelURLToLoad setText:@"Not required"];
	}
	DLog(@"getUnstructuredServerUrl")
	[labelUnstructured setText:[serv getUnstructuredServerUrl]];
	DLog(@"getStructuredServerUrl")
	[labelStructured setText:[serv getStructuredServerUrl]];
	//[serv release];

}

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
	[labelURLToLoad release];
	[labelURLToSave release];
	[labelStructured release];
	[labelUnstructured release];
	[labelRequired release];
	[switchBaseRequired release];
	[serv release];
    [super dealloc];
}

@end
