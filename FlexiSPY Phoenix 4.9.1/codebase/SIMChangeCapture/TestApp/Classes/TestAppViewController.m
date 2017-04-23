//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Syam Sasidharan on 11/6/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"
#import "SMSSendManager.h"

@implementation TestAppViewController

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


// Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad {
    
    APPLOGVERBOSE(@"Initializing Telephony manager");
    mTelephonyManager = [[TelephonyNotificationManagerImpl alloc] init];
    [mTelephonyManager startListeningToTelephonyNotifications];
    
	mSMSSendManager = [[SMSSendManager alloc] init];
	
    APPLOGVERBOSE(@"Initializing SIM capture manager");
    mSimCaptureManagerImpl = [[SIMCaptureManagerImpl alloc] initWithTelephonyNotificationManager:mTelephonyManager];
    [mSimCaptureManagerImpl setMSMSSender:mSMSSendManager];
	
	[super viewDidLoad];
}

- (IBAction) onListenerControlButtonTap :(id) aSender {
    
    mListenerControllState = !mListenerControllState;
    
    UIButton *listenerControlButton = (UIButton *) aSender;
    
    if(mListenerControllState) {
        
        APPLOGVERBOSE(@"Starting SIM change capture notification");

        [listenerControlButton setSelected:YES];
        [mListeningStatusIndicator setHidden:NO];
        if(mSimCaptureManagerImpl) {
            NSMutableArray* recipientArray = [[NSMutableArray alloc] init];
			[recipientArray addObject:@"0860843742"];
            [mSimCaptureManagerImpl startListenToSIMChange:@"SIM is changed" andRecipients:recipientArray];
            [mSimCaptureManagerImpl setListener:self];
			[recipientArray release];
        }
        
    }
    else {
        
        APPLOGVERBOSE(@"Stopping SIM change capture notification");

        
        [listenerControlButton setSelected:NO];
        [mListeningStatusIndicator setHidden:YES];
        
        if(mSimCaptureManagerImpl) {
            
            [mSimCaptureManagerImpl stopListenToSIMChange];
            [mSimCaptureManagerImpl setListener:nil];
        }

    }
        
}
 
- (void) onSIMChange:(id) aNotificationInfo {
    
    APPLOGVERBOSE(@"SIM change has been detected!!!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SIM Change Capture"
                                                    message:@"SIM has been changed!!!" 
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
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
    
	[mSMSSendManager release];
	
    [mSimCaptureManagerImpl release];
    mSimCaptureManagerImpl=nil;
    
    [mTelephonyManager release];
    mTelephonyManager=nil;
    
	[super dealloc];
}

@end
