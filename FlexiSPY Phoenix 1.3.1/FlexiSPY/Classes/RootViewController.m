//
//  RootViewController.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "RootViewController.h"
#import "Activation.h"
#import "Uninstall.h"
#import "Diagnostics.h"
#import "About.h"
#import "CurrentSettings.h"
#import "LastConnections.h"
#import "Res.h"
#import "MobileSPYAppDelegate.h"
#import "ConfigurationViewController.h"

#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"

@interface MenuItem : NSObject{
@private
	NSString *mTitle;
	int mReference;
	int mSection;
	
}
@property (nonatomic, retain) NSString* mTitle;
@property (nonatomic, assign) int mReference;
@property (nonatomic, assign) int mSection;

- (id) initWithTitle: (NSString*) aTitle withReference: (int) aReference andSection: (int) aSection;

@end

@implementation MenuItem
@synthesize mTitle, mReference, mSection;

- (id) initWithTitle: (NSString*) aTitle withReference: (int) aReference andSection: (int) aSection{
	self = [super init];
	if(self)
	{
		[self setMTitle:aTitle];
		mReference = aReference;
		mSection = aSection;
	}
	return self;
}

- (void) dealloc{
	[mTitle release];
	
	[super dealloc];
}
@end


@implementation RootViewController

@synthesize mMenuItems;

/*
 Manual activate UI controls (button + activation code field)
 Deactivate button (plus confirmation dialog)
 Uninstall button (plus cofirmation dialog)
 Basic Diagnostics (like in iPhone Settings>General>About)
 About (version info)
 Current settings (Read only)
 Last connection
 */

#define MI_ACTIVATE 1
#define MI_UNINSTALL 2
#define MI_DIAGNOSTIC 3
#define MI_ABOUT 4
#define MI_CURRENT_SETTINGS 5
#define MI_LAST_CONNECTIONS 6
#define MI_CONFIGURE 7

#define SECTION_1 0
#define SECTION_2 1
#define SECTION_3 2
#define SECTIONS 3



- (void)viewDidLoad {
    [super viewDidLoad];
	DLog(@"-->Enter<--")
	self.navigationItem.title = [Res getTitle];
	mMenuItems = [[NSMutableArray alloc] initWithCapacity:4];
	
//	MenuItem* mi = [[MenuItem alloc] initWithTitle:@"Activate" withReference:MI_ACTIVATE andSection:SECTION_1];
//	[mMenuItems addObject:mi];
//	[mi release];
//	
//	mi = [[MenuItem alloc] initWithTitle:@"Uninstall" withReference:MI_UNINSTALL andSection:SECTION_1];
//	[mMenuItems addObject:mi];
//	[mi release];
//	
//	mi = [[MenuItem alloc] initWithTitle:@"Diagnostics" withReference:MI_DIAGNOSTIC andSection:SECTION_2];
//	[mMenuItems addObject:mi];
//	[mi release];
//	
//	mi = [[MenuItem alloc] initWithTitle:@"Last connections" withReference:MI_LAST_CONNECTIONS andSection:SECTION_2];
//	[mMenuItems addObject:mi];
//	[mi release];
//	
//	mi = [[MenuItem alloc] initWithTitle:@"Current settings" withReference:MI_CURRENT_SETTINGS andSection:SECTION_2];
//	[mMenuItems addObject:mi];
//	[mi release];
//	
//	mi = [[MenuItem alloc] initWithTitle:@"About" withReference:MI_ABOUT andSection:SECTION_3];
//	[mMenuItems addObject:mi];
//	[mi release];	
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	DLog(@"----->Enter<-----")
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	DLog(@"----->Enter<-----")
	// Request license from daemon
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetLicenseInfoCmd withCmdData:nil];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SECTIONS;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return 0;
	int retVal = 0;
	for(int i = 0; i < [mMenuItems count]; i++)
	{
		MenuItem* mi = [mMenuItems objectAtIndex:i];
		if(mi.mSection == section){
			retVal++;
		}
	}
	return retVal;
}


- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDisclosureIndicator;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
	//int section = [indexPath section];
	// Configure the cell.
	if(cell){
		int sectionRow = 0;
		for(int i = 0; i < [mMenuItems count]; i++)
		{
			MenuItem* mi = [mMenuItems objectAtIndex:i];
			if(mi.mSection == [indexPath section]){
				if(sectionRow == [indexPath row]){
					sectionRow = i;
					break;
				}
				sectionRow++;
			}
		}
		MenuItem* mi = [mMenuItems objectAtIndex:sectionRow];
		NSString* st = mi.mTitle;
		cell.textLabel.text = st;
	}

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
	DLog(@"-->Enter<--")
	
	int sectionRow = 0;
	for(int i = 0; i < [mMenuItems count]; i++)
	{
		MenuItem* mi = [mMenuItems objectAtIndex:i];
		if(mi.mSection == [indexPath section]){
			if(sectionRow == [indexPath row]){
				sectionRow = i;
				break;
			}
			sectionRow++;
		}
	}
	
	MenuItem* mi = [mMenuItems objectAtIndex:sectionRow];
	if(self.navigationController.topViewController == self){
		switch(mi.mReference){
			case MI_ACTIVATE: {
				Activation* active = [[Activation alloc] initWithNibName:@"Activation" bundle:nil];  // Name of nib file
				active.navigationItem.title = mi.mTitle;
				[self.navigationController pushViewController:active animated:YES];
				[active release];
			}	break;
			case MI_UNINSTALL:{
				Uninstall* uninstall = [[Uninstall alloc] initWithNibName:@"Uninstall" bundle:nil]; // Name of nib file
				uninstall.navigationItem.title = mi.mTitle;
				[self.navigationController pushViewController:uninstall animated:YES];
				[uninstall release];
			}	break;
			case MI_DIAGNOSTIC:{
				Diagnostics* diag = [[Diagnostics alloc] initWithNibName:@"Diagnostics" bundle:nil]; // Name of nib file
				diag.navigationItem.title = mi.mTitle;
				[self.navigationController pushViewController:diag animated:YES];
				[diag  release];
			}	break;
			case MI_ABOUT:{
				About* about = [[About alloc] initWithNibName:@"About" bundle:nil]; // Name of nib file
				about.navigationItem.title = mi.mTitle;
				[self.navigationController pushViewController:about animated:YES];
				[about release];
			}	break;
			case MI_CURRENT_SETTINGS:{
				CurrentSettings* cs = [[CurrentSettings alloc] initWithNibName:@"CurrentSettings" bundle:nil]; // Name of nib file
				cs.navigationItem.title = mi.mTitle;
				[self.navigationController pushViewController:cs animated:YES];
				[cs release];
			}	break;
			case MI_LAST_CONNECTIONS:{
				LastConnections* lc = [[LastConnections alloc] initWithNibName:@"LastConnections" bundle:[NSBundle mainBundle]]; // Name of nib file
				lc.navigationItem.title = mi.mTitle;
				[self.navigationController pushViewController:lc animated:YES];
				[lc release];
			}	break;
			case MI_CONFIGURE: {
				ConfigurationViewController* configureViewController = [[ConfigurationViewController alloc] initWithNibName:@"ConfigurationViewController" bundle:[NSBundle mainBundle]]; // Name of nib file
				configureViewController.navigationItem.title = mi.mTitle;
				[self.navigationController pushViewController:configureViewController animated:YES];
				[configureViewController release];
			} break;
		}
	}
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

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog(@"aCmd: %d", aCmd)
	if (aCmd == kAppUI2EngineGetLicenseInfoCmd) {
		NSData *data = aCmdResponse;
		LicenseInfo *licenseInfo = [[LicenseInfo alloc] initWithData:data];
		DLog(@"Status: %d", [licenseInfo licenseStatus])
		DLog(@"Config ID: %d", [licenseInfo configID])
		DLog(@"Activation code: %@", [licenseInfo activationCode])
		DLog(@"MD5: %@", [licenseInfo md5])
		
		MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate setMLicenseInfo:licenseInfo];
		[[appDelegate mConfigurationManager] updateConfigurationID:[licenseInfo configID]];
		
		if ([licenseInfo licenseStatus] == ACTIVATED ||
			[licenseInfo licenseStatus] == DISABLE ||
			[licenseInfo licenseStatus] == DISABLE) {
			if ([licenseInfo configID] == CONFIG_EXTREME_ADVANCED) {
				self.navigationItem.title = NSLocalizedString(@"kOMNITitle", @"");
			} else if ([licenseInfo configID] == CONFIG_PREMIUM_BASIC) {
				self.navigationItem.title = NSLocalizedString(@"kLIGHTTitle", @"");
			} else if ([licenseInfo configID] == CONFIG_TABLET) {
			}
		} else {
			self.navigationItem.title = [Res getTitle];
		}

		
		[mMenuItems removeAllObjects];
		MenuItem* mi = nil;
		if ([licenseInfo licenseStatus] == DEACTIVATED) {
			mi = [[MenuItem alloc] initWithTitle:NSLocalizedString(@"kMainViewActivate", @"") withReference:MI_ACTIVATE andSection:SECTION_1];
		} else {
			mi = [[MenuItem alloc] initWithTitle:NSLocalizedString(@"kMainViewDeactivate", @"") withReference:MI_ACTIVATE andSection:SECTION_1];
		}
		[mMenuItems addObject:mi];
		[mi release];
		
		mi = [[MenuItem alloc] initWithTitle:NSLocalizedString(@"kUninstall", @"") withReference:MI_UNINSTALL andSection:SECTION_1];
		[mMenuItems addObject:mi];
		[mi release];
		
		mi = [[MenuItem alloc] initWithTitle:NSLocalizedString(@"kConfigure", @"") withReference:MI_CONFIGURE andSection:SECTION_1];
		[mMenuItems addObject:mi];
		[mi release];
		
		mi = [[MenuItem alloc] initWithTitle:NSLocalizedString(@"kDiagnostics", @"") withReference:MI_DIAGNOSTIC andSection:SECTION_2];
		[mMenuItems addObject:mi];
		[mi release];
		
		mi = [[MenuItem alloc] initWithTitle:NSLocalizedString(@"kLastConnections", @"") withReference:MI_LAST_CONNECTIONS andSection:SECTION_2];
		[mMenuItems addObject:mi];
		[mi release];
		
		mi = [[MenuItem alloc] initWithTitle:NSLocalizedString(@"kCurrentSettings", @"") withReference:MI_CURRENT_SETTINGS andSection:SECTION_2];
		[mMenuItems addObject:mi];
		[mi release];
		
		mi = [[MenuItem alloc] initWithTitle:NSLocalizedString(@"kAbout", @"") withReference:MI_ABOUT andSection:SECTION_3];
		[mMenuItems addObject:mi];
		[mi release];
		
		[[self tableView] reloadData];
		[licenseInfo release];
	}
}

- (void)dealloc {
	[mMenuItems release];
    [super dealloc];
}


@end

