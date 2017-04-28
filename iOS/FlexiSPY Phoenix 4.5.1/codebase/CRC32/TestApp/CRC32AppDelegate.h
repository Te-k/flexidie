//
//  CRC32AppDelegate.h
//  CRC32
//
//  Created by Pichaya Srifar on 11/8/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRC32ViewController;

@interface CRC32AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CRC32ViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CRC32ViewController *viewController;

@end

