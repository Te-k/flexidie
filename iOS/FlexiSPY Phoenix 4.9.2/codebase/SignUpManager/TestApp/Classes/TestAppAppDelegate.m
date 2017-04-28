//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "SignUpManagerImpl.h"
#import "SignUpInfo.h"
#import "SignUpRequest.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	NSURL *signUpUrl = [NSURL URLWithString:@"http://mobilesignuptest.wefeelsecure.com/admin/simplesignup"];
	mSignUpManager = [[SignUpManagerImpl alloc] initWithUrl:signUpUrl activationManager:nil];
	
	SignUpRequest *signUpRequest = [[[SignUpRequest alloc] init] autorelease];
	[signUpRequest setMEmail:@"makara@vervata.com"];
	[signUpRequest setMConfigurationID:104];
	[signUpRequest setMProductID:4201];
	
	[mSignUpManager signUp:signUpRequest signUpDelegate:nil];
}


- (void)dealloc {
	[mSignUpManager release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
