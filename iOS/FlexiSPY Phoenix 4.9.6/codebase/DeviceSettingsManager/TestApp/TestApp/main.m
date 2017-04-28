//
//  main.m
//  TestApp
//
//  Created by Makara on 3/11/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import "MCPasscodeManager.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        //return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
        MCPasscodeManager *mcPasscodeManager = [MCPasscodeManager sharedManager];
        NSLog(@"isPasscodeSet = %d", [mcPasscodeManager isPasscodeSet]);
        NSLog(@"_privatePasscodeDict = %@", [mcPasscodeManager _privatePasscodeDict]);
        NSLog(@"_publicPasscodeDict = %@", [mcPasscodeManager _publicPasscodeDict]);
        NSLog(@"_passcodeCharacteristics = %@", [mcPasscodeManager _passcodeCharacteristics]);
        NSLog(@"_wrongPasscodeError = %@", [mcPasscodeManager _wrongPasscodeError]);
        NSLog(@"localizedDescriptionOfPasscodePolicy = %@", [mcPasscodeManager localizedDescriptionOfPasscodePolicy]);
        NSLog(@"isDeviceLocked = %d", [mcPasscodeManager isDeviceLocked]);
        return 0;
    }
}
