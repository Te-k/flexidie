//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Syam Sasidharan on 11/3/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"

@implementation TestAppViewController

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


// Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad {
    
	[super viewDidLoad];
}
 

- (void)onSMSReceived:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"SMS received");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        [mLabel setText:[NSString stringWithFormat:@"SMS Received %@",[userInfo description]]];
    
}

- (void)onSMSSent:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"SMS Sent");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        [mLabel setText:[NSString stringWithFormat:@"SMS Sent %@",[userInfo description]]];
    
}

- (void)onCallStatusChange:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"onCallStatusChange");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        [mLabel setText:[NSString stringWithFormat:@"Call Status changed %@",[userInfo description]]];
    
    
}

- (void)onAddCallRecordHistory:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"onAddCallRecordHistory");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        [mLabel setText:[NSString stringWithFormat:@"Call record history added %@",[userInfo description]]];
    
}

- (void)onSIMChange:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"onSIMChange");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        [mLabel setText:[NSString stringWithFormat:@"SIM has been changed %@",[userInfo description]]];
    
    
}

- (void)onSettingsPhoneNumberChange:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"Settings Phone Number has been changed");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        [mLabel setText:[NSString stringWithFormat:@"Settings Phone Number has been changed %@",[userInfo description]]];
    
}

- (void)onSelectednetworkRegistration:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"Selected network registration completed");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        [mLabel setText:[NSString stringWithFormat:@"Selected network registration completed %@",[userInfo description]]];
    
    
}


- (void)addListeners:(id)aManager{
    
    mManager = (id<TelephonyNotificationManager>) aManager;
    [mManager retain];
    
    [mManager addNotificationListener:self withSelector:@selector(onSMSSent:) forNotification:KSMSMESSAGESENTNOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onSMSReceived:) forNotification:KSMSMESSAGERECEIVEDNOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onCallStatusChange:) forNotification:KCALLSTATUSCHANGENOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onAddCallRecordHistory:) forNotification:KCALLHISTORYRECORDADDNOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onSIMChange:) forNotification:KSIMCHANGENOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onSettingsPhoneNumberChange:) forNotification:KSETTINGSPHONENUMBERCHANGEDNOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onSelectednetworkRegistration:) forNotification:KREGISTRATIONNETWORKSELECTEDNOTIFICATION];
    
}

- (void)cleanUp {
    
    [mManager removeListner:self];
    [mManager release];
    mManager=nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

@end
