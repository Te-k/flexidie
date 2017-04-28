//
//  CryptographyAppDelegate.h
//  Cryptography
//
//  Created by Pichaya Srifar on 11/8/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CryptographyViewController;

@interface CryptographyAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CryptographyViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CryptographyViewController *viewController;

@end

