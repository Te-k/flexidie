//
//  main.m
//  TestApp-iOS
//
//  Created by Makara Khloth on 1/4/17.
//  Copyright © 2017 ophat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import "MobileAppScreenShot.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        //return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
        MobileAppScreenShot *appScreenShot = [[MobileAppScreenShot alloc] init];
        [appScreenShot startCapture];
        
        [[NSRunLoop currentRunLoop] run];
        
        return 0;
    }
}
