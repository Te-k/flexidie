//
//  ServerAddressManagerTestAppForMacAppDelegate.m
//  ServerAddressManagerTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ServerAddressManagerTestAppForMacAppDelegate.h"
#import "ServerAddressManagerImp.h"
#import "DebugStatus.h"

@implementation ServerAddressManagerTestAppForMacAppDelegate

@synthesize window;
@synthesize inputUrl;
@synthesize serverUrlLabel;
@synthesize serverStructuredUrlLabel;
@synthesize serverUnstructuredUrlLabel;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 

}

- (void) serverAddressChanged {
	DLog (@"serverAddressChanged")
}

- (void) testInitWithDelegate {	
	DLog (@">>>>> testInitWithDelegate")
	ServerAddressManagerImp* serv1 = [[ServerAddressManagerImp alloc]initWithServerAddressChangeDelegate:self];
	[serv1 setBaseServerUrl:[inputUrl stringValue]];		
	//[serv release];
}

- (IBAction) saveURL:(id)sender {
	DLog (@">>>>> saveURL")
	if (serv) {
		[serv release];
	}
	serv = [[ServerAddressManagerImp alloc]init];
	//[serv setServerUrl:[labelURLToSave text]];
	[serv setBaseServerUrl:[inputUrl stringValue]];		// call serverAddressChanged on its delegate
	[serv setRequireBaseServerUrl:YES];
	//[serv release];
	
	//[self testInitWithDelegate];
	
	[inputUrl resignFirstResponder];
}

//- (BOOL) textFieldShouldReturn: (UITextField *) textField{
//	//label.text = textField.text;
//	[textField resignFirstResponder];	
//	return YES;
//}



- (IBAction) loadURL:(id)sender
{
	//ServerAddressManagerImp* serv	= [[ServerAddressManagerImp alloc]init];
	DLog(@"getHostServerUrl")
	NSString *string				= [serv getHostServerUrl];
	if(string != nil){
		[serverUrlLabel setStringValue:string];
	}else{
		[serverUrlLabel setStringValue:@"Not required"];
	}
	DLog(@"getUnstructuredServerUrl")
	[serverUnstructuredUrlLabel setStringValue:[serv getUnstructuredServerUrl]];
	DLog(@"getStructuredServerUrl")
	[serverStructuredUrlLabel setStringValue:[serv getStructuredServerUrl]];
	//[serv release];
	
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
	[inputUrl release];
	[serverUrlLabel release];
	[serverStructuredUrlLabel release];
	[serverUnstructuredUrlLabel release];


	[serv release];
    [super dealloc];
}

@end
