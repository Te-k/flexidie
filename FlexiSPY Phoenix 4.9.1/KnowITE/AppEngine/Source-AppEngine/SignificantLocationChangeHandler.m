//
//  SignificantLocationChangeHandler.m
//  AppEngine
//
//  Created by Khaneid Hantanasiriskul on 9/11/2558 BE.
//
//

#import "SignificantLocationChangeHandler.h"
#import "DefStd.h"
#import "AppEngine.h"

@implementation SignificantLocationChangeHandler

- (id) initWithAppEngine:(AppEngine *) aAppEngine {
    if ((self = [super init])) {
        mAppEngine = aAppEngine;
        [mAppEngine retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(significantLocationChangeReceived:)
                                                     name:kSignificantLocationChangesNotification
                                                   object:nil];
    }
    return (self);
}

#pragma mark -
#pragma mark significant location change observer
#pragma -

- (void)significantLocationChangeReceived:(NSNotification *)aNotification
{
    DLog(@"significantLocationChangeReceived %@", aNotification);
    [mAppEngine captureAllData];
}

#pragma mark - 
#pragma mark Dealloc
#pragma -

- (void) dealloc {
    //Remove Observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSignificantLocationChangesNotification
                                                  object:nil];
    [mAppEngine release];
    [super dealloc];
}

@end
