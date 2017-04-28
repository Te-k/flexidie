//
//  OTCTestAppApp.h
//  OTCTestApp
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// include for the sdk compiler and open toolchain headers
#ifndef UIKIT_UIFont_UIColor_H
#define UIKIT_UIFont_UIColor_H
typedef float CGFloat;
#import <UIKit/UIFont.h>
#import <UIKit/UIColor.h>
#endif


@interface OTCTestAppApp : UIApplication {
    UIWindow *window;
    UIView *mainView;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIView *mainView;

@end
