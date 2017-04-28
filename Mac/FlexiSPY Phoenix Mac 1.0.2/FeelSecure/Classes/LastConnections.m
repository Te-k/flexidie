//
//  LastConnections.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LastConnections.h"
#import "LastConnectionCell.h"
#import "FeelSecureAppDelegate.h"

#import "AppEngineUICmd.h"
#import "ConnectionLog.h"

//static NSString *kActionUnknown				= @"Unknown";
//static NSString *kActionActivate			= @"Activate";
//static NSString *kActionRequestActivate		= @"Request activate";
//static NSString *kActionDeactivate			= @"Deactivate";
//static NSString *kActionSendRegularEvent	= @"Send regular event";
//static NSString *kActionSendSystemEvent		= @"Send system event";
//static NSString *kActionSendPanicEvent		= @"Send panic event";
//static NSString *kActionSendSettingsEvent	= @"Send settings event";
//static NSString *kActionSendActualEvent		= @"Send actual event";
//static NSString *kActionSendThumbnailEvent	= @"Send thumbnail event";
//static NSString *kActionSendHeartbeat		= @"Send heartbeat";
//static NSString *kActionSendAddressbook		= @"Send address book";
//static NSString *kActionSendAddressbookForApproval = @"Send address book for approval";
//static NSString *kConnectionStatusError		= @"Error";
//static NSString *kConnectionStatusOk		= @"Ok";
//static NSString *kNoConnectionHaveMade		= @"No connection have been made";

@implementation LastConnectionItem
@synthesize mLabItemNo, mLabAction, mLabStatus, mLabMSG, mLabDate;

-(id) initWithValues: (NSString*)aLabItemNo: (NSString*)aLabAction: (NSString*)aLabStatus: (NSString*)aLabMSG: (NSString*)aLabDate{
	self = [super init];
	if(self){
		[self setMLabItemNo:aLabItemNo];
		[self setMLabAction:aLabAction];
		[self setMLabStatus:aLabStatus];
		[self setMLabMSG:aLabMSG];
		[self setMLabDate:aLabDate];
	}
	return self;
}

-(void)dealloc{
	[mLabItemNo release];
	[mLabAction release];
	[mLabStatus release];
	[mLabMSG release];
	[mLabDate release];
	
	[super dealloc];
}
@end


@implementation LastConnections

@synthesize mTableView, mArray;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
    }
    return self;
}*/

/*

 Item no: 0, 1, .., 5
 Action: Send event, Activation, Deactivation, Send Address book
 Status: Operation success, Operation failed
 Msg: Ok, Error no [xx], error text
 Date: dd/mm/yyyy HH:MM:ss
 */
 
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//mTableView.delegate = self;
	[mTableView setDelegate:self];
	[mTableView setDataSource:self];
	
	mArray = [[NSMutableArray alloc] init];
//	for(int i = 0; i < 50; i++){
//		LastConnectionItem* lci = [[LastConnectionItem alloc] init];
//		lci.mLabItemNo = [NSString stringWithFormat:@"%d", i];
//		lci.mLabMSG =  [NSString stringWithFormat:@"Sample data for item %d", i];
//		lci.mLabAction = @"Activate";
//		lci.mLabStatus = @"Ok";
//		lci.mLabDate = @"dd/dd/dd hh/hh/hh";
//		
//		[mArray addObject:lci];
//		[lci release];
//	}
	
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetLastConnectionsCmd withCmdData:nil];
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
	[mArray release];
	[mTableView release];
    [super dealloc];
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [mArray count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    LastConnectionCell *cell = (LastConnectionCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {		
        cell = [[[LastConnectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	LastConnectionItem*  row = [ mArray objectAtIndex:[indexPath section]];
	
	[cell setItemNo: row.mLabItemNo];
	[cell setAction: row.mLabAction];
	[cell setStatus: row.mLabStatus];
	[cell setMSG: row.mLabMSG];
	[cell setDate: row.mLabDate];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	LastConnectionItem*  row = [mArray objectAtIndex:section];
	return [NSString stringWithFormat:NSLocalizedString(@"kConnectionOrderNumber", @""), row.mLabItemNo];
}

- (void)viewWillAppear:(BOOL)animated {
	DLog(@"view appeared");
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
    return 100; //[indexPath row]; // your dynamic height...
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    LastConnectionCell *cell = (LastConnectionCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[LastConnectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	LastConnectionItem*  row = [ mArray objectAtIndex:[indexPath section]];
	
	[cell setItemNo: row.mLabItemNo];
	[cell setAction: row.mLabAction];
	[cell setStatus: row.mLabStatus];
	[cell setMSG: row.mLabMSG];
	[cell setDate: row.mLabDate];
	if ([cell isLablesTextOverlapCellFrame]) {
		NSString *message = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", cell.mLabAction.text, cell.mLabStatus.text, cell.mLabMSG.text, cell.mLabDate.text];
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:[NSString stringWithFormat:NSLocalizedString(@"kConnectionOrderNumber", @""), row.mLabItemNo]];
		[alert setMessage:message];
		[alert setDelegate:self];
		[alert addButtonWithTitle:NSLocalizedString(@"kLastConnectionOkButtonTitle", @"")];
		NSArray *subViewArray = alert.subviews;
		for (int x = 1; x < [subViewArray count]; x++) { // 0 index is title label
			if([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]]) {
				UILabel *label = [subViewArray objectAtIndex:x];
				label.textAlignment = UITextAlignmentLeft;
			}
		}
		[alert show];
		[alert release];
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
	if (aCmd ==kAppUI2EngineGetLastConnectionsCmd) {
		NSData *connectionLogsData = aCmdResponse;
		NSInteger location = 0;
		NSInteger count = 0;
		[connectionLogsData getBytes:&count length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		[mArray removeAllObjects];
		for (int i = 0; i < count; i++) {
			NSInteger length = 0;
			[connectionLogsData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			ConnectionLog *connectionLog = [[ConnectionLog alloc] initWithData:[connectionLogsData subdataWithRange:NSMakeRange(location, length)]];
			location += length;
			
			NSString *action = nil;
			NSString *status = nil;
			if ([connectionLog mErrorCode] == 0) {
				status = [NSString stringWithString:NSLocalizedString(@"kConnectionStatusOk", @"")];
			} else {
				status = [NSString stringWithString:NSLocalizedString(@"kConnectionStatusError", @"")];
			}

			switch ([connectionLog mCommandAction]) {
				case kEDPTypePanic:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendPanicEvent", @"")];
					break;
				case kEDPTypeSystem:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendSystemEvent", @"")];
					break;
				case kEDPTypeAllRegular:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendRegularEvent", @"")];
					break;
				case kEDPTypeSettings:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendSettingsEvent", @"")];
					break;
				case kEDPTypeActualMeida:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendActualEvent", @"")];
					break;
				case kEDPTypeThumbnail:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendThumbnailEvent", @"")];
					break;
				case kEDPTypeActivate:
					action = [NSString stringWithString:NSLocalizedString(@"kActionActivate", @"")];
					break;
				case kEDPTypeDeactivate:
					action = [NSString stringWithString:NSLocalizedString(@"kActionDeactivate", @"")];
					break;
				case kEDPTypeRequestActivate:
					action = [NSString stringWithString:NSLocalizedString(@"kActionRequestActivate", @"")];
					break;
				case kEDPTypeSendHeartbeat:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendHeartbeat", @"")];
					break;
				case kEDPTypeSendAddressbook:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendAddressbook", @"")];
					break;
				case kEDPTypeSendAddressbookForApproval:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendAddressbookForApproval", @"")];
					break;
				case kEDPTypeGetAddressbook:
					action = [NSString stringWithString:NSLocalizedString(@"kActionGetAddressbook", @"")];
					break;
				case kEDPTypeGetTime:
					action = [NSString stringWithString:NSLocalizedString(@"kActionGetTime", @"")];
					break;
				case kEDPTypeGetCommunicationDirectives:
					action = [NSString stringWithString:NSLocalizedString(@"kActionGetCommunicationDirectives", @"")];
					break;
				case kEDPTypeSendInstalledApps:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendInstalledApps", @"")];
					break;
				case kEDPTypeSendRunningApps:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendRunningApps", @"")];
					break;
				case kEDPTypeSendBookmarks:
					action = [NSString stringWithString:NSLocalizedString(@"kActionSendBookmark", @"")];
					break;
				case kEDPTypeGetAppsProfile:
					action = [NSString stringWithString:NSLocalizedString(@"kActionGetAppProfile", @"")];
					break;
				case kEDPTypeGetUrlProfile:
					action = [NSString stringWithString:NSLocalizedString(@"kActionGetUrlProfile", @"")];
					break;
				case kEDPTypeGetConfig:
					action = [NSString stringWithString:NSLocalizedString(@"kActionGetConfig", @"")];
					break;
				default:
					action = [NSString stringWithString:NSLocalizedString(@"kActionUnknown", @"")];
					break;
			}
			LastConnectionItem* lci = [[LastConnectionItem alloc] init];
			lci.mLabItemNo = [NSString stringWithFormat:@"%d", i + 1];
			lci.mLabMSG = [NSString stringWithString:[connectionLog mErrorMessage]];
			lci.mLabAction = [NSString stringWithString:action];
			lci.mLabStatus = [NSString stringWithString:status];
			lci.mLabDate = [connectionLog mDateTime];
			[mArray addObject:lci];
			[lci release];
			
			[connectionLog release];
		}
		
		if (count == 0) {
			LastConnectionItem* lci = [[LastConnectionItem alloc] init];
			lci.mLabItemNo = [NSString stringWithString:NSLocalizedString(@"kNoConnectionHaveMade", @"")];
			[mArray addObject:lci];
			[lci release];
		}
		[mTableView reloadData];
	}
}

@end
