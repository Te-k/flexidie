//
//  FoursquarePasswordManager.m
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 3/6/2557 BE.
//
//
#import <objc/runtime.h>

#import "FoursquarePasswordManager.h"
#import "foursquareAppDelegate.h"

static FoursquarePasswordManager  *_FoursquarePasswordManager = nil;

@implementation FoursquarePasswordManager

+ (id) sharedFoursquarePasswordManager {
	if (_FoursquarePasswordManager == nil) {
		_FoursquarePasswordManager = [[FoursquarePasswordManager alloc] init];
	}
	return (_FoursquarePasswordManager);
}

- (void) clearRegisteredAccount {
    DLog(@"\n====== clearRegisteredAccount (Foursquare) =====");
    
    //[((foursquareAppDelegate *)[[UIApplication sharedApplication] delegate]) killUI];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    Class $foursquareAppDelegate = objc_getClass("foursquareAppDelegate");
    Class $FSCoreAppDelegate = objc_getClass("FSCoreAppDelegate");
    
    if ([delegate isKindOfClass:[$foursquareAppDelegate class]]) {
        [((foursquareAppDelegate *)[[UIApplication sharedApplication] delegate]) restoreUI];
        [((foursquareAppDelegate *)[[UIApplication sharedApplication] delegate]) logout];

    } else if ([delegate isKindOfClass:[$FSCoreAppDelegate class]]) {
        [((foursquareAppDelegate *)[[UIApplication sharedApplication] delegate]) logout];
    }
        
    
  

}

@end
