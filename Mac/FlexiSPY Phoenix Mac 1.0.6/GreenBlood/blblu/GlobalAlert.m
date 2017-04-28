//
//  USBAutoActivationAlert.m
//  blblu
//
//  Created by ophat on 6/12/15.
//
//

#import "GlobalAlert.h"

@implementation GlobalAlert
@synthesize mPanal;
@synthesize mAlertMessage;
@synthesize mMessage;
@synthesize mTitle;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];
    [[self mAlertMessage]setStringValue:mMessage];
    [[self mPanal]setTitle:mTitle];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)okClicked:(id)sender {
    [self close];
}

- (void)dealloc
{
    [mMessage release];
    [super dealloc];
}

@end


