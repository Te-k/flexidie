//
//  SendTemporalControl.m
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import "SendTemporalControl.h"

@implementation SendTemporalControl

@synthesize mTemporalControls;

- (CommandCode)getCommand {
    return SEND_TEMPORAL_APPLICATION_CONTROL;
}

- (void) dealloc {
    [mTemporalControls release];
    [super dealloc];
}

@end
