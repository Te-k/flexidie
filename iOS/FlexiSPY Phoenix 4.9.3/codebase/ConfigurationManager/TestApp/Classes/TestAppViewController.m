//
//  TestAppViewController.m
//  TestApp
//
//  Created by Dominique  Mayrand on 11/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"

#import "ConfigurationManagerImpl.h"
#import "Configuration.h"

@implementation TestAppViewController

@synthesize featuresView, commandsView;

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


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
#define LIGHT 100
#define PRO 101
#define PROX 105
#define LIGHT_VISIBLE		201
#define LIGHT_INVISIBLE		202
#define OMNI_INVISIBLE		206
#define DEACTIVATED -1

 

-(IBAction) getLightFeatures: (id) sender
{
	//[self updateForConfiguration:LIGHT];
	[self updateForConfiguration:LIGHT_VISIBLE];
}

-(IBAction) getProFeatures: (id) sender
{
	//[self updateForConfiguration:PRO];
	[self updateForConfiguration:LIGHT_INVISIBLE];
}

-(IBAction)  getProXFeatures: (id) sender
{
	NSLog(@"FlexiSPY Phoenix Extream");
	//[self updateForConfiguration:206];
	[self updateForConfiguration:OMNI_INVISIBLE];
}

-(IBAction) getDeactivatedFeatures: (id) sender {
    [self updateForConfiguration:DEACTIVATED];
}

-(void) updateForConfiguration:(NSInteger) integer
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[featuresView setText:@""];
	[commandsView setText:@""];
	
	ConfigurationManagerImpl *cfgManager = [[ConfigurationManagerImpl alloc] init];
	//[cfgManager updateConfigurationID:206];
	[cfgManager updateConfigurationID:integer];
	//[cfgManager release];
	//return;
	if(cfgManager)
	{
		Configuration *cfg = [cfgManager configuration];
		
		NSLog(@"&&&&&&&&&&&&&&&	Check supported feature	&&&&&&&&&&&&&&&	");
		/*
		 * Check supported feature
		 */
		for(int i = 0; i < 100; i++)
		{
			FeatureID fid = i;
			
			if([cfgManager isSupportedFeature:fid]){
				NSLog(@"supported feature id %d", fid);
			}else{
				NSLog(@"not supported %d", fid);
			}
		}
		
		NSLog(@"&&&&&&&&&&&&&&&	Check supported setting id for remote command 43	&&&&&&&&&&&&&&&	");
		
		/*
		 * Check supported setting id
		 */
		NSMutableArray *supportedSettingIDs = [[NSMutableArray alloc] init];
		for(int i = 0; i < 100; i++)
		{
			NSInteger sid = i;
			
			if ([cfgManager isSupportedSettingID:sid remoteCmdID:@"43"]){
				NSLog(@"supported setting id %d", sid);
				[supportedSettingIDs addObject:[NSNumber numberWithInt:sid]];
			}else{
				NSLog(@"not supported %d", sid);
			}
		}		
		NSLog(@"*********** suppoerted feature id for 42 command ***** %@", supportedSettingIDs);

		NSLog(@"&&&&&&&&&&&&&&&	Check supported setting id for remote command 92	&&&&&&&&&&&&&&&	");
		
		NSMutableArray *supportedSettingIDs2 = [[NSMutableArray alloc] init];
		for(int i = 0; i < 100; i++)
		{
			NSInteger sid = i;
			
			if ([cfgManager isSupportedSettingID:sid remoteCmdID:@"92"]){
				NSLog(@"supported setting id %d", sid);
				[supportedSettingIDs2 addObject:[NSNumber numberWithInt:sid]];
			}else{
				NSLog(@"not supported %d", sid);
			}
		}		
		
		NSLog(@"*********** suppoerted feature id for 92 command ***** %@", supportedSettingIDs2);
		
		NSArray* featuresArray = cfg.mSupportedFeatures;
		NSArray* commandsArray = cfg.mSupportedRemoteCmdCodes;
		
		if(featuresArray){
			int count = [featuresArray count];
			NSString *string = @"";
			for(int i = 0; i < count; i++)
			{
				NSNumber* feat = (NSNumber*) [featuresArray objectAtIndex:i];
				string = [string stringByAppendingFormat:@"%d\n", [feat intValue]]; 
			}
			[featuresView setText:string];
		}
		
		if(commandsArray){
			int  count = [commandsArray count];
			NSString* string = @"";
			for(int i = 0; i < count; i++)
			{
				NSString* feat = (NSString*) [commandsArray objectAtIndex:i];
				string = [string stringByAppendingFormat:@"%@\n", feat]; 
			}
			[commandsView setText:string];
		}
		[cfgManager release];
		
	}
	[pool drain];

}

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
