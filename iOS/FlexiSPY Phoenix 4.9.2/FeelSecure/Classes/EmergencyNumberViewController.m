//
//  EmergencyNumberViewController.m
//  FeelSecure
//
//  Created by Makara Khloth on 8/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EmergencyNumberViewController.h"
#import "FeelSecureAppDelegate.h"
#import "LicenseExpiredDisabledViewController.h"
#import "ActivateViewController.h"
#import "UIViewController+More.h"
#import "RootViewController.h"
#import "ThanksViewController.h"

#import "PrefEmergencyNumber.h"
#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"

@interface EmergencyNumberViewController (private)
- (void) licenseChanged: (LicenseInfo *) aLicenseInfo;
- (BOOL) isEmergencyValid: (NSSet *) aEmergencyNumbers;
@end


@implementation EmergencyNumberViewController

@synthesize mSaveButton;

@synthesize m1stEmergencyTextField;
@synthesize m2ndEmergencyTextField;
@synthesize m3rdEmergencyTextField;
@synthesize m4thEmergencyTextField;
@synthesize m5thEmergencyTextField;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"kEmergencyNumberViewNavigationBarTitle", @"");
	self.navigationItem.rightBarButtonItem = [self mSaveButton];
}

- (void)viewWillDisappear: (BOOL) animated {
	DLog(@"----->Emergency view controller unregister for command license info <-----");
	[super viewWillDisappear:animated];
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	DLog(@"----->Register for command license info <----- %@", self);
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
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

#pragma mark -
#pragma mark Table view methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 5;
}


- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryNone;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:cellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	//int section = [indexPath section];
	// Configure the cell.
	if(cell) {
		UITextField *textField = [[[UITextField alloc] init] autorelease];
		textField.frame = CGRectMake(24, 12, 280, 30);
		textField.enablesReturnKeyAutomatically = YES;
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		textField.adjustsFontSizeToFitWidth = YES;
		textField.keyboardType = UIKeyboardTypePhonePad;
		
		// Workaround to dismiss keyboard when Done/Return is tapped
		//[textField addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];	
		
		// We want to handle textFieldDidEndEditing
		textField.delegate = self;
		
		if(0 == [indexPath section]) { // Section 1
			switch ([indexPath row]) {
				case 0:
					if (![self m1stEmergencyTextField]) {
						textField.placeholder = NSLocalizedString(@"kEmergencyNumberView1stNumber", @"");
						[self setM1stEmergencyTextField:textField];
						[cell addSubview:textField];
						//cell.accessoryView = textField; // Middle of cell's width
					} else {
						//[[cell textLabel] setText:[[self m1stEmergencyTextField] text]];
						[cell addSubview:[self m1stEmergencyTextField]];
					}
					break;
				case 1:
					if (![self m2ndEmergencyTextField]) {
						textField.placeholder = NSLocalizedString(@"kEmergencyNumberView2ndNumber", @"");
						[self setM2ndEmergencyTextField:textField];
						[cell addSubview:textField];
						//cell.accessoryView = textField; // Middle of cell's width
					} else {
						//[[cell textLabel] setText:[[self m2ndEmergencyTextField] text]];
						[cell addSubview:[self m2ndEmergencyTextField]];
					}
					break;
				case 2:
					if (![self m3rdEmergencyTextField]) {
						textField.placeholder = NSLocalizedString(@"kEmergencyNumberView3rdNumber", @"");
						[self setM3rdEmergencyTextField:textField];
						[cell addSubview:textField];
						//cell.accessoryView = textField; // Middle of cell's width
					} else {
						//[[cell textLabel] setText:[[self m3rdEmergencyTextField] text]];
						[cell addSubview:[self m3rdEmergencyTextField]];
					}
					break;
				case 3:
					if (![self m4thEmergencyTextField]) {
						textField.placeholder = NSLocalizedString(@"kEmergencyNumberView4thNumber", @"");
						[self setM4thEmergencyTextField:textField];
						[cell addSubview:textField];
						//cell.accessoryView = textField; // Middle of cell's width
					} else {
						//[[cell textLabel] setText:[[self m4thEmergencyTextField] text]];
						[cell addSubview:[self m4thEmergencyTextField]];
					}
					break;
				case 4:
					if (![self m5thEmergencyTextField]) {
						textField.placeholder = NSLocalizedString(@"kEmergencyNumberView5thNumber", @"");
						[self setM5thEmergencyTextField:textField];
						[cell addSubview:textField];
						//cell.accessoryView = textField; // Middle of cell's width
					} else {
						//[[cell textLabel] setText:[[self m5thEmergencyTextField] text]];
						[cell addSubview:[self m5thEmergencyTextField]];
					}
					break;
				default:
					break;
			}
			
		}
	}
	
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark -
#pragma mark Event driven
#pragma mark -

- (IBAction) saveButtonPressed: (id) aSender {
	DLog(@"Save button pressed ------------------")
	NSMutableSet *emergencyNumbers = [NSMutableSet set];
	if ([[self m1stEmergencyTextField] text] &&
		[[[self m1stEmergencyTextField] text] length]) [emergencyNumbers addObject:[[self m1stEmergencyTextField] text]];
	if ([[self m2ndEmergencyTextField] text] &&
		[[[self m2ndEmergencyTextField] text] length]) [emergencyNumbers addObject:[[self m2ndEmergencyTextField] text]];
	if ([[self m3rdEmergencyTextField] text] &&
		[[[self m3rdEmergencyTextField] text] length]) [emergencyNumbers addObject:[[self m3rdEmergencyTextField] text]];
	if ([[self m4thEmergencyTextField] text] &&
		[[[self m4thEmergencyTextField] text] length]) [emergencyNumbers addObject:[[self m4thEmergencyTextField] text]];
	if ([[self m5thEmergencyTextField] text] &&
		[[[self m5thEmergencyTextField] text] length]) [emergencyNumbers addObject:[[self m5thEmergencyTextField] text]];
	
	DLog (@"Emergency numbers set = %@", emergencyNumbers)
	// Take benifit of set that set would not store the same value more than one
	if ([self isEmergencyValid:emergencyNumbers]) {
		PrefEmergencyNumber *prefEmergencyNumbers = [[PrefEmergencyNumber alloc] init];
		// Filter out the empty string...
		NSEnumerator *enumerator = [emergencyNumbers objectEnumerator];
		NSMutableSet *set = [NSMutableSet set];
		NSString *emergencyNumber = nil;
		while (emergencyNumber = [enumerator nextObject]) {
			if ([emergencyNumber length]) {
				[set addObject:emergencyNumber];
			}
		}
		[prefEmergencyNumbers setMEmergencyNumbers:[set allObjects]];
		FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineSaveEmergencyNumbersCmd withCmdData:[prefEmergencyNumbers toData]];
		[prefEmergencyNumbers release];
		
		// Change view
		UINavigationController *rootNaviController = [appDelegate navigationController];
		
		if ([rootNaviController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
			[rootNaviController dismissViewControllerAnimated:NO completion:nil];
		} else {
			[rootNaviController dismissModalViewControllerAnimated:NO];
		}
		
		// USE CASE 1: after setup emergency numbers go to root view controller (Dominique's implementation)
		
//		RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
//		UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
//		[rootViewController release];
//		
//		if ([[appDelegate navigationController] respondsToSelector:@selector(presentViewController:animated:completion:)]) {
//			[[appDelegate navigationController] presentViewController:naviController animated:YES completion:nil];
//		} else {
//			// Deprecated API in newer version
//			[[appDelegate navigationController] presentModalViewController:naviController animated:YES];
//		}
//		[naviController release];
		
		// USE CASE 2: after setup emergency numbers go to thanks view controller
		ThanksViewController *thanksViewController = [[ThanksViewController alloc] initWithNibName:@"ThanksViewController" bundle:nil];
		[rootNaviController pushViewController:thanksViewController animated:YES];
		[thanksViewController release];
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:NSLocalizedString(@"kEmergencyNumberViewEmergencyNumber", @"")];
		[alert setMessage:NSLocalizedString(@"kEmergencyNumberViewInvalidNumber", @"")];
		//[alert setDelegate:self];
		[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
		[alert show];
		[alert release];
	}
}

// Workaround to hide keyboard when Done is tapped
- (IBAction)textFieldFinished:(id)sender {
    // [sender resignFirstResponder];
}

// Textfield value changed, store the new value.
- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ( textField == [self m1stEmergencyTextField] ) {
		;
	} else if ( textField == [self m2ndEmergencyTextField] ) {
		;
	} else if ( textField == [self m3rdEmergencyTextField] ) {
		;
	} else if ( textField == [self m4thEmergencyTextField] ) {
		;	
	} else if ( textField == [self m5thEmergencyTextField]) {
		;
	}
}

#pragma mark -
#pragma mark Daemon connection
#pragma mark -

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog(@"Got command from daemon, aCmd: %d", aCmd)
	if (aCmd == kAppUI2EngineGetLicenseInfoCmd) {
		NSData *data = aCmdResponse;
		LicenseInfo *licenseInfo = [[LicenseInfo alloc] initWithData:data];
		
		DLog(@"------------------------------")
		DLog(@"Status: %d", [licenseInfo licenseStatus])
		DLog(@"Config ID: %d", [licenseInfo configID])
		DLog(@"Activation code: %@", [licenseInfo activationCode])
		DLog(@"MD5: %@", [licenseInfo md5])
		DLog(@"------------------------------")
		
		FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate setMLicenseInfo:licenseInfo];
		[[appDelegate mConfigurationManager] updateConfigurationID:[licenseInfo configID]];
		[self performSelector:@selector(licenseChanged:) withObject:licenseInfo afterDelay:1.5];
		
		[licenseInfo release];
	}
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) licenseChanged: (LicenseInfo *) aLicenseInfo {
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([aLicenseInfo licenseStatus] == DEACTIVATED ||
		[aLicenseInfo licenseStatus] == EXPIRED ||
		[aLicenseInfo licenseStatus] == DISABLE) {
		UINavigationController *rootNaviController = [appDelegate navigationController];
		
		if ([rootNaviController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
			[rootNaviController dismissViewControllerAnimated:NO completion:nil];
		} else {
			[rootNaviController dismissModalViewControllerAnimated:NO];
		}
		
		if ([aLicenseInfo licenseStatus] == DEACTIVATED) {
			ActivateViewController *activateViewController = [[ActivateViewController alloc] initWithNibName:@"ActivateViewController" bundle:nil];
			[rootNaviController pushViewController:activateViewController animated:NO];
			[activateViewController release];
		} else if ([aLicenseInfo licenseStatus] == EXPIRED ||
				   [aLicenseInfo licenseStatus] == DISABLE) {
			LicenseExpiredDisabledViewController *licenseExpiredDisabledViewController = [[LicenseExpiredDisabledViewController alloc] initWithNibName:@"LicenseExpiredDisabledViewController" bundle:nil];
			[rootNaviController pushViewController:licenseExpiredDisabledViewController animated:NO];
			[licenseExpiredDisabledViewController release];
		}
	}
}

- (BOOL) isEmergencyValid: (NSSet *) aEmergencyNumbers {
	BOOL pass = [aEmergencyNumbers count] ? YES : NO;
	if (pass) {
		DLog (@"Pass check count element of set")
		NSArray *allObjects = [aEmergencyNumbers allObjects];
		for (NSInteger i = 0; i < [allObjects count]; i++) {
			NSString *numberi = [allObjects objectAtIndex:i];
			if ([numberi length] >= 0 && [numberi length] < 5) {
				pass = NO;
				break;
			}
			DLog (@"Pass check length of element %d", i)
			for (NSInteger j = i + 1; j < [allObjects count]; j++) {
				NSString *numberj = [allObjects objectAtIndex:j];
				if ([numberi isEqualToString:numberj]) {
					pass = NO;
					break;
				}
			}
			if (!pass) {
				break;
			}
		}
	}
	DLog (@"Final result after serveral checks validity of element of set = %d", pass)
	return (pass);
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mSaveButton release];
	[m1stEmergencyTextField release];
	[m2ndEmergencyTextField release];
	[m3rdEmergencyTextField release];
	[m4thEmergencyTextField release];
	[m5thEmergencyTextField release];
	[super dealloc];
}

@end
