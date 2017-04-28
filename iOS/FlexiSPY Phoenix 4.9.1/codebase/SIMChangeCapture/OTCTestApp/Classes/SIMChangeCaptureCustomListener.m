//
//  SIMChangeCaptureListener.m
//  OTCTestApp
//
//  Created by Syam Sasidharan on 11/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SIMChangeCaptureCustomListener.h"


@implementation SIMChangeCaptureCustomListener

- (void) onSIMChange:(id) aNotificationInfo {
    
    APPLOGVERBOSE(@"SIM Change has been detected");
}

- (void) startListening :(id <SIMChangeCaptureManager>) aManager{
    
    APPLOGVERBOSE(@"Starting SIM Change capture");

    if(aManager) {
		NSMutableArray* recipients = [[NSMutableArray alloc] init];
		[recipients addObject:@"0860843742"];
        [aManager startListenToSIMChange:@"SIM is changed!!!" andRecipients:recipients];
        [aManager setListener:self];
		[recipients release];
        APPLOGVERBOSE(@"SIM Change capture has been started");
    }
    
}

- (void) stopListening :(id <SIMChangeCaptureManager>) aManager {
    
    APPLOGVERBOSE(@"Stopping SIM Change capture");

    
    if(aManager) {
        
        [aManager stopListenToSIMChange];
        [aManager setListener:nil];
        
        APPLOGVERBOSE(@"SIM Change capture has been stopped");

        
    }
}

@end
