//
//  CRC32ViewController.m
//  CRC32
//
//  Created by Pichaya Srifar on 11/8/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "CRC32ViewController.h"
#import "CRC32.h"

@implementation CRC32ViewController



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



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
}

- (IBAction) crc32Pressed:(id)sender {
	NSInteger result = [CRC32 crc32:[@"ASFSDFASFASDFSADFSDF" dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSString *msg = [NSString stringWithFormat:@"ASFSDFASFASDFSADFSDF \n expected = 599801767 \n result = %d", result];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CRC32 Testing!" message:msg
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    [super dealloc];
}

@end
