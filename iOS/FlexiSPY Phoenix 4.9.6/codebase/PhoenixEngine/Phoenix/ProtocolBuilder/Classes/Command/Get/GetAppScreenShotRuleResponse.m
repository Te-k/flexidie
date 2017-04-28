//
//  GetAppScreenShotRuleResponse.m
//  ProtocolBuilder
//
//  Created by ophat on 4/4/16.
//
//

#import "GetAppScreenShotRuleResponse.h"

@implementation GetAppScreenShotRuleResponse
@synthesize mAppScreenShotRule;

- (void) dealloc {
    [mAppScreenShotRule release];
    [super dealloc];
}
@end 
