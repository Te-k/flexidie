/** 
 - Project name: ProductInfoUtil
 - Class name: ProductInfoUtilViewController
 - Version: 1.0
 - Purpose: Get information about product
 - Copy right: 2/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "ProductInfoUtilViewController.h"
#import "DataConvertion.h"

@implementation ProductInfoUtilViewController

@synthesize mProductId;
@synthesize mProtocolLanguage;
@synthesize mProtocolVersion;
@synthesize mVersionTextField;
@synthesize mNameTextField;
@synthesize mDescriptionTextField;
@synthesize mLanguageTextField;
@synthesize mHashtailTextField;

- (IBAction) buttonSavePressed: (UIButton *) aSender {
	NSLog(@"\n\nsize of NSInteger:	%d", sizeof(NSInteger));
	NSString *version = [[self mVersionTextField] text];
	NSString *name = [[self mNameTextField] text];
	NSString *description = [[self mDescriptionTextField] text];
	NSString *language = [[self mLanguageTextField] text];
	NSString *hashtail = [[self mHashtailTextField] text] ;
	
	DataConvertion *dataConverion = [[DataConvertion alloc] initWithProductInfoVersion:version 
																				  name:name 
																		   description:description 
																			  language:language 
																			  hashtail:hashtail];
	[dataConverion setMProductId:[[self mProductId] text]];
	[dataConverion setMProtocolLanguage:[[self mProtocolLanguage] text]];
	[dataConverion setMProtocolVersion:[[self mProtocolVersion] text]];
//	Here is the mock data. So if you put these info in UI, AppContext can encrypt it now because
//	I put the char array that is resulted from encrypting these info in ProductInfoHelper (a class
//	in AppContext component) that does decryption.
//	DataConvertion *dataConverion = [[DataConvertion alloc] initWithProductInfoVersion:@"1.1"
//																				  name:@"FeelSecure" 
//																		   description:@"Feel this and that?"
//																			  language:@"12"
//																			  hashtail:@"Unknown"];

	[dataConverion encryptAndWriteToFile];
 	[dataConverion decryptAndRetrieveProductInfo];
	[dataConverion release];
}

- (IBAction) textFieldFinished: (id) aSender
{
    [aSender resignFirstResponder];
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
	[[self mVersionTextField] setDelegate:self];
	[[self mNameTextField] setDelegate:self];
	[[self mDescriptionTextField] setDelegate:self];
	[[self mLanguageTextField] setDelegate:self];
	[[self mHashtailTextField] setDelegate:self];
	[[self mProductId] setDelegate:self];
	[[self mProtocolLanguage] setDelegate:self];
	[[self mProtocolVersion] setDelegate:self];
	
	
	[[self mVersionTextField] setReturnKeyType:UIReturnKeyDone];
	[[self mNameTextField] setReturnKeyType:UIReturnKeyDone];
	[[self mDescriptionTextField] setReturnKeyType:UIReturnKeyDone];
	[[self mLanguageTextField] setReturnKeyType:UIReturnKeyDone];
	[[self mHashtailTextField] setReturnKeyType:UIReturnKeyDone];
	[[self mProductId] setReturnKeyType:UIReturnKeyDone];
	[[self mProtocolLanguage] setReturnKeyType:UIReturnKeyDone];
	[[self mProtocolVersion] setReturnKeyType:UIReturnKeyDone];
		
	[[self mVersionTextField] addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[[self mNameTextField]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[[self mDescriptionTextField]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[[self mLanguageTextField]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[[self mHashtailTextField]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[[self mProductId]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[[self mProtocolLanguage]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[[self mProtocolVersion]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];	
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
	[mProductId release];
	[mProtocolLanguage release];
	[mProtocolVersion release];
	[mVersionTextField release];
	[mNameTextField release];
	[mDescriptionTextField release];
	[mLanguageTextField release];
	[mHashtailTextField release];
    [super dealloc];
}

@end
