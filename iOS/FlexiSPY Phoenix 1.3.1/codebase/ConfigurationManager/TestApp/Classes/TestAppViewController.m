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

-(IBAction) getLightFeatures: (id) sender
{
	[self updateForConfiguration:LIGHT];
}

-(IBAction) getProFeatures: (id) sender
{
	[self updateForConfiguration:PRO];
}

-(IBAction)  getProXFeatures: (id) sender
{
	[self updateForConfiguration:PROX];
}

-(void) updateForConfiguration:(NSInteger) integer
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[featuresView setText:@""];
	[commandsView setText:@""];
	
	ConfigurationManagerImpl *cfgManager = [[ConfigurationManagerImpl alloc] init];
	[cfgManager updateConfigurationID:integer];
	//[cfgManager release];
	//return;
	if(cfgManager)
	{
		Configuration *cfg = [cfgManager configuration];
		
		for(int i = 0; i < 100; i++)
		{
			FeatureID fid = i;
			
			if([cfgManager isSupportedFeature:fid]){
				NSLog(@"supported");
			}else{
				NSLog(@"not supported");
			}
		}
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
	[pool release];
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
