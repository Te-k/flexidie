//
//  TestPhoneInfo3AppDelegate.m
//  TestPhoneInfo3
//
//  Created by Dominique  Mayrand on 11/4/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestPhoneInfo3ViewController.h"
#import "PhoneInfoImp.h"

@implementation TestPhoneInfo3ViewController

@synthesize phoneInfo;

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad {
	[super viewDidLoad];
}
 */
-(void) retrievePhoneInfo: (id) sender
{
	PhoneInfoImp *pi = [[PhoneInfoImp alloc]init];
	if(pi)
	{
		//[pi setPhoneInfo];
		NSString *labelText = @"";
		NSString *val = @"";
		NSString *retVal = [pi getIMEI];
		if(retVal)
		{
			val = [[[NSString alloc] initWithFormat:@"IMEI:%@", retVal] autorelease];
		}else{
			val = @"IMEI not found";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@",labelText, val] autorelease];
		
		retVal = [pi getMEID];
		if(retVal)
		{
			//val = phoneInfo.mMEID;
			val = [[[NSString alloc] initWithFormat:@"MEID:%@", retVal] autorelease];
		}else
		{
			val = @"MEID not found";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		
		/*
		if(pi.mIMSI)
		{
			//val = phoneInfo.mMCC;
			val = [[[NSString alloc] initWithFormat:@"IMSI:%@", pi.mIMSI] autorelease];
		}else
		{
			val = @"IMSI not found";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		*/
		
		/*
		if(pi.mCellID)
		{
			//val = phoneInfo.mCellID;
			val = [[[NSString alloc] initWithFormat:@"CellID:%@", pi.mCellID] autorelease];
		}else
		{
			val = @"CellID not found";
		}
		 
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		*/
		retVal = [pi getMobileNetworkCode];
		if(retVal)
		{
			//val = phoneInfo.mMNC;
			
			val = [[[NSString alloc] initWithFormat:@"MNC:%@", retVal] autorelease];
		}else
		{
			val = @"MNC not found";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		
		
		retVal = [pi getMobileCountryCode];
		if(retVal)
		{
			//val = phoneInfo.mMCC;
			val = [[[NSString alloc] initWithFormat:@"MCC:%@", retVal] autorelease];
		}else
		{
			val = @"MCC not found";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		
		/*
		retVal = [pi getLAC];
		if(pi.mLAC)
		{
			val = [[[NSString alloc] initWithFormat:@"LAC:%@", pi.mLAC] autorelease];
		}else
		{
			val = @"LAC not found";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		*/
		
		retVal = [pi getPhoneNumber];
		if(retVal)
		{
			val = [[[NSString alloc] initWithFormat:@"Phone Number:%@", retVal] autorelease];
		}else
		{
			val = @"Owner Phone Number not found";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		
		retVal = [pi getNetworkName];
		if(retVal)
		{
			val = [[[NSString alloc] initWithFormat:@"Network name:%@", retVal] autorelease];
		}else
		{
			val = @"Network name not found";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		
		retVal = [pi getDeviceInfo];
		if(retVal)
		{
			val = [[[NSString alloc] initWithFormat:@"Device Info:%@", retVal] autorelease];
		}else
		{
			val = @"No Phone Info";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		
		retVal = [pi getDeviceModel];
		if(retVal)
		{
			val = [[[NSString alloc] initWithFormat:@"Device Model:%@", retVal] autorelease];
		}else
		{
			val = @"No Device model";
		}
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		
		NetworkType nt = [pi getNetworkType];

		val = [[[NSString alloc] initWithFormat:@"Device Model:%d", nt] autorelease];
		
		labelText = [[[NSString alloc] initWithFormat:@"%@\r%@", labelText, val] autorelease];
		
		
		[phoneInfo setText:labelText];
		
		[pi release];

	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	NSLog(@"Did received memory warning");
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

@end
