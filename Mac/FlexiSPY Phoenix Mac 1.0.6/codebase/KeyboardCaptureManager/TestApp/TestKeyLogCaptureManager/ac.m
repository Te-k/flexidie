//
//  ac.m
//  TestKeyLogCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ac.h"


@implementation ac
static ac *_ac = nil;

+ (ac *) shareActivate {
	if (_ac == nil) {
		_ac = [[ac alloc] init];
	}
	return (_ac);
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
