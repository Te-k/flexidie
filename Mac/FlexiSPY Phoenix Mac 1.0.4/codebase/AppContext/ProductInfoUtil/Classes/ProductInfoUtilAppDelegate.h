//
//  ProductInfoUtilAppDelegate.h
//  ProductInfoUtil
//
//  Created by Benjawan Tanarattanakorn on 12/2/54 BE.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductInfoUtilViewController;

@interface ProductInfoUtilAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ProductInfoUtilViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ProductInfoUtilViewController *viewController;

@end

