//
//  ServerUrlEncryptionMacAppDelegate.m
//  ServerUrlEncryptionMac
//
//  Created by Ophat Phuetkasickonphasutha on 10/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ServerUrlEncryptionMacAppDelegate.h"
#import "EncryptionEngin.h"

@implementation ServerUrlEncryptionMacAppDelegate

@synthesize window;
@synthesize URLField;
@synthesize mEncryptionEngin;
BOOL encrypted = false;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    mEncryptionEngin = [[EncryptionEngin alloc] init];
}

- (IBAction)Encrypt:(id)sender {
    if (![[URLField stringValue] isEqual:@""]) {
		[mEncryptionEngin addUrl:[URLField stringValue]];
        [mEncryptionEngin encryptURLsAndWriteToFile];
        [mEncryptionEngin encryptURLsAndWriteToFileWithTwoDiArray];
        [URLField setStringValue:@""];
        encrypted= true;
	}
	else {
        NSAlert * alert = [[NSAlert alloc]init];
        [alert setMessageText: @"Please enter URL"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle: @"OK"];
        [alert runModal];
    }
}

- (IBAction)Decrypt:(id)sender {
    if (![[URLField stringValue] isEqual:@""] && encrypted) {
	    [mEncryptionEngin decryptURLs]; 
        [URLField setStringValue:@""];
        encrypted = false;
	}
	else {
        NSAlert * alert = [[NSAlert alloc]init];
        [alert setMessageText: @"Please enter URL And Encrypt"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle: @"OK"];
        [alert runModal];
    }
}

- (void)dealloc {
	[URLField release];
	[mEncryptionEngin release];
    [super dealloc];
}

@end
