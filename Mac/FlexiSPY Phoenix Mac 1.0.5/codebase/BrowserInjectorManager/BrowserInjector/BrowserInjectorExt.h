//
//  FinderInj.h
//  FinderMenu
//
//  Created by Alexey Zhuchkov on 10/21/12.
//  Copyright (c) 2012 InfiniteLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <Cocoa/Cocoa.h>


@interface BrowserInjectorExt : NSObject
+ (void)load;
- (id)init;

@end
