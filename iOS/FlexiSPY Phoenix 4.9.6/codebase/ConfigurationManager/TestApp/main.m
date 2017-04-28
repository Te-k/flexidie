//
//  main.m
//  TestApp
//
//  Created by Dominique  Mayrand on 11/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConfigurationManagerImpl.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    ConfigurationManagerImpl *cfgManager = [[ConfigurationManagerImpl alloc] init];
//	[cfgManager updateConfigurationID:-1];
//	[cfgManager release];
//    [pool release];
//    return 0;
}
