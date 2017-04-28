/** 
 - Project name: ServerUrlEncryption
 - Class name: ServerUrlEncryptionViewController
 - Version: 1.0
 - Purpose: Get server url to be encrypted
 - Copy right: 4/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "ServerUrlEncryptionViewController.h"
#import "EncryptionEngin.h"

@interface ServerUrlEncryptionViewController (private) 
- (void) setUp;
@end

@implementation ServerUrlEncryptionViewController

@synthesize mUrlText;
@synthesize mEncryptionEngin;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[self setUp];
    }
    return self;
}

- (void) awakeFromNib {
	[self setUp];
}

- (void) setUp {
	mEncryptionEngin = [[EncryptionEngin alloc] init];
}

- (IBAction) addButtonPressed: (id) aSender {
	if (![[mUrlText text] isEqual:@""]) {
		[mEncryptionEngin addUrl:[mUrlText text]];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" 
														message:@"Please enter URL"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (IBAction) encryptButtonPressed: (id) aSender {
	[mEncryptionEngin encryptURLsAndWriteToFile];
	[mEncryptionEngin encryptURLsAndWriteToFileWithTwoDiArray];
	
}

- (IBAction) decryptButtonPressed: (id) aSender {
	[mEncryptionEngin decryptURLs]; 
}
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[self mUrlText] setDelegate:self];
	[[self mUrlText] setReturnKeyType:UIReturnKeyDone];	
	[[self mUrlText] addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	
	
}

- (IBAction) textFieldFinished: (id) aSender
{
    [aSender resignFirstResponder];
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
	[mUrlText release];
	[mEncryptionEngin release];
    [super dealloc];
}

@end
