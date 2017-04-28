//
//  Diagnostics.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Diagnostics.h"
#import "DiagnosticCell.h"
#import "Utils.h"
#import "MobileSPYAppDelegate.h"

#import "AppEngineUICmd.h"
#import "DbHealthInfo.h"
#import "EventCount.h"

@implementation Diagnostics

@synthesize mTableView, mDiagnosticItems;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
//	mDiagnosticItems = [Utils getDiagnostics];
//	[mDiagnosticItems retain];
	[mTableView setDelegate:self];
	[mTableView setDataSource:self];
	
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetDiagnosticCmd withCmdData:nil];
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
	[mTableView release];
	[mDiagnosticItems release];
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [mDiagnosticItems count];
    
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = (UITableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {		
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	DiagnosticObject*  row = [mDiagnosticItems objectAtIndex:[indexPath section]];
	
	//[cell setValues: row.mName: row.mValue];
	cell.textLabel.text = row.mValue;
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	DiagnosticObject*  row = [mDiagnosticItems objectAtIndex:section];
	return row.mName;
}

- (void)viewWillAppear:(BOOL)animated {
	DLog(@"view appeared");
	[super viewWillAppear:animated];
	[self.view setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	DLog(@"----->Enter<-----")
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
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

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	if (aCmd == kAppUI2EngineGetDiagnosticCmd) {
		NSInteger location = 0;
		NSInteger length = 0;
		NSData *data = aCmdResponse;
		//DLog(@"Data totally get from daemon: %@", data)
		[data getBytes:&length length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		//DLog(@"Event count object's length: %d", length)
		EventCount *eventCount = [[EventCount alloc] initWithData:[data subdataWithRange:NSMakeRange(location, length)]];
		location += length;
		[data getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		//DLog(@"Database health object's length: %d", length)
		DbHealthInfo *dbHealthInfo = [[DbHealthInfo alloc] initWithData:[data subdataWithRange:NSMakeRange(location, length)]];
		location += length;
		[data getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		//DLog(@"Last connection string object's length: %d", length)
		NSString *lastConnectionTime = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(location, length)] encoding:NSUTF8StringEncoding];
		[mDiagnosticItems release];
		mDiagnosticItems = nil;
		mDiagnosticItems = [Utils getDiagnosticsWithDBHealthInfo:dbHealthInfo withEventCount:eventCount andLastConnectionTime:lastConnectionTime];
		[mDiagnosticItems retain];
		[lastConnectionTime release];
		[dbHealthInfo release];
		[eventCount release];
		[mTableView reloadData];
	}
}

@end
