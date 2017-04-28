//
//  YahooPasswordManager.m
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 2/26/2557 BE.
//
//

#import "YahooPasswordManager.h"
#import "YAAppDelegate.h"

static YahooPasswordManager  *_YahooPasswordManager = nil;


@implementation YahooPasswordManager


+ (id) sharedYahooPasswordManager {
	if (_YahooPasswordManager == nil) {
		_YahooPasswordManager = [[YahooPasswordManager alloc] init];
	}
	return (_YahooPasswordManager);
}

- (void) clearRegisteredAccount {
    DLog(@"====== clearRegisteredAccount (YAHOO) =====");

    YAAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [delegate removeAllAccounts];

}




@end
