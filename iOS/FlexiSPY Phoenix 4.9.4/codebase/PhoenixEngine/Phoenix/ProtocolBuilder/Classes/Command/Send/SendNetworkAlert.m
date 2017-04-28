//
//  SendNetworkAlertCritiria.m
//  ProtocolBuilder
//
//  Created by ophat on 1/11/16.
//
//

#import "SendNetworkAlert.h"

@implementation SendNetworkAlert
@synthesize mClientAlerts;

- (CommandCode)getCommand {
    return SEND_NETWORK_ALERT;
}

- (void) dealloc {
    [mClientAlerts release];
    [super dealloc];
}
@end
