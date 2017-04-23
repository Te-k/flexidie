//
//  GZIPAppDelegate.h
//  GZIP
//
//  Created by Pichaya Srifar on 11/8/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GZIPViewController;

@interface GZIPAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GZIPViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GZIPViewController *viewController;

@end

