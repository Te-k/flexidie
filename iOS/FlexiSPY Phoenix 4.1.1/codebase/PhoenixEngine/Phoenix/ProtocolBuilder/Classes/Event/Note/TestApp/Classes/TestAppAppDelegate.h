//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Ophat on 1/16/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "NoteProtocolConverter.h"

@class TestAppViewController;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppViewController *viewController;

@end

